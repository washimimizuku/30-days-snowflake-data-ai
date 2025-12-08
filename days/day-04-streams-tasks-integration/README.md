# Day 4: Streams + Tasks Integration

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Combine Streams and Tasks for automated CDC pipelines
- Implement incremental data processing patterns
- Build SCD Type 2 dimensions with automation
- Use SYSTEM$STREAM_HAS_DATA() for conditional task execution
- Handle errors in automated pipelines
- Monitor and troubleshoot stream-task workflows
- Optimize performance of CDC pipelines
- Understand best practices for production deployments

---

## Theory

### Why Combine Streams and Tasks?

Streams track changes, Tasks automate processing. Together, they create powerful, self-managing data pipelines.

**Benefits:**
- **Automated CDC**: No manual intervention required
- **Incremental processing**: Only process changed data
- **Efficient**: Skip execution when no changes exist
- **Scalable**: Handle high-volume change streams
- **Reliable**: Built-in error handling and monitoring

### The CDC Pattern

```
Source Table → Stream (tracks changes) → Task (processes changes) → Target Table
```

**Flow:**
1. Changes occur in source table (INSERT, UPDATE, DELETE)
2. Stream captures changes with metadata
3. Task checks if stream has data (WHEN clause)
4. Task processes changes (MERGE, INSERT, etc.)
5. Stream offset advances (changes consumed)
6. Repeat on schedule

### Basic Stream-Task Pattern

```sql
-- 1. Create stream on source
CREATE STREAM customer_stream ON TABLE customers;

-- 2. Create task with conditional execution
CREATE TASK process_customer_changes
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('customer_stream')
AS
  MERGE INTO customers_target AS t
  USING customer_stream AS s
  ON t.customer_id = s.customer_id
  WHEN MATCHED AND s.METADATA$ACTION = 'DELETE' THEN DELETE
  WHEN MATCHED THEN UPDATE SET ...
  WHEN NOT MATCHED THEN INSERT ...;

-- 3. Resume task
ALTER TASK process_customer_changes RESUME;
```

### Incremental Processing Patterns

#### Pattern 1: Simple Append
For append-only tables (logs, events)

```sql
CREATE STREAM events_stream ON TABLE events APPEND_ONLY = TRUE;

CREATE TASK process_events
  WAREHOUSE = my_wh
  SCHEDULE = '1 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('events_stream')
AS
  INSERT INTO events_processed
  SELECT * FROM events_stream;
```

#### Pattern 2: Upsert (MERGE)
For tables with updates and deletes

```sql
CREATE STREAM products_stream ON TABLE products;

CREATE TASK sync_products
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('products_stream')
AS
  MERGE INTO products_replica AS target
  USING (
    SELECT * FROM products_stream
    WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = FALSE
  ) AS source
  ON target.product_id = source.product_id
  WHEN MATCHED THEN UPDATE SET ...
  WHEN NOT MATCHED THEN INSERT ...;
```

#### Pattern 3: SCD Type 2
Maintain historical versions

```sql
CREATE STREAM dim_customer_stream ON TABLE customers;

CREATE TASK maintain_customer_dimension
  WAREHOUSE = my_wh
  SCHEDULE = '10 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('dim_customer_stream')
AS
BEGIN
  -- Close out old records
  UPDATE dim_customers
  SET valid_to = CURRENT_TIMESTAMP(), is_current = FALSE
  WHERE customer_id IN (
    SELECT customer_id FROM dim_customer_stream
    WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE
  ) AND is_current = TRUE;
  
  -- Insert new versions
  INSERT INTO dim_customers
  SELECT customer_id, ..., CURRENT_TIMESTAMP() as valid_from,
         '9999-12-31' as valid_to, TRUE as is_current
  FROM dim_customer_stream
  WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE;
END;
```

### Multi-Stage Pipelines

Build complex workflows with task trees:

```
Stream 1 → Task A (extract) → Stream 2 → Task B (transform) → Stream 3 → Task C (load)
```

**Example:**
```sql
-- Stage 1: Extract changes
CREATE TASK extract_changes
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('source_stream')
AS
  INSERT INTO staging_table
  SELECT * FROM source_stream;

-- Stage 2: Transform (runs after extract)
CREATE TASK transform_data
  WAREHOUSE = my_wh
  AFTER extract_changes
AS
  INSERT INTO transformed_table
  SELECT ..., complex_transformations(...)
  FROM staging_table;

-- Stage 3: Load (runs after transform)
CREATE TASK load_target
  WAREHOUSE = my_wh
  AFTER transform_data
AS
  MERGE INTO target_table ...;
```

### Error Handling Strategies

#### Strategy 1: Separate Error Table
```sql
CREATE TABLE cdc_errors (
  error_id INT AUTOINCREMENT,
  error_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_table VARCHAR,
  error_message VARCHAR,
  failed_record VARIANT
);

CREATE TASK process_with_error_handling
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('my_stream')
AS
BEGIN
  -- Try to process
  INSERT INTO target
  SELECT * FROM my_stream
  WHERE validate_record(column1, column2);
  
  -- Log errors
  INSERT INTO cdc_errors (source_table, error_message, failed_record)
  SELECT 
    'my_table',
    'Validation failed',
    OBJECT_CONSTRUCT(*)
  FROM my_stream
  WHERE NOT validate_record(column1, column2);
END;
```

#### Strategy 2: Dead Letter Queue
```sql
CREATE TABLE dlq_table (
  dlq_id INT AUTOINCREMENT,
  original_record VARIANT,
  error_reason VARCHAR,
  created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TASK process_with_dlq
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('my_stream')
AS
BEGIN
  -- Process valid records
  INSERT INTO target
  SELECT * FROM my_stream
  WHERE is_valid = TRUE;
  
  -- Send invalid to DLQ
  INSERT INTO dlq_table (original_record, error_reason)
  SELECT 
    OBJECT_CONSTRUCT(*),
    'Invalid data format'
  FROM my_stream
  WHERE is_valid = FALSE;
END;
```

### Performance Optimization

#### 1. Batch Processing
Process in batches to reduce overhead:

```sql
CREATE TASK batch_processor
  WAREHOUSE = my_wh
  SCHEDULE = '10 MINUTE'  -- Less frequent = larger batches
  WHEN SYSTEM$STREAM_HAS_DATA('my_stream')
AS
  MERGE INTO target ...;
```

#### 2. Warehouse Sizing
Use appropriate warehouse for workload:

```sql
-- Small changes: XSMALL
CREATE TASK small_changes
  WAREHOUSE = xsmall_wh
  SCHEDULE = '1 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('my_stream')
AS ...;

-- Large changes: LARGE or serverless
CREATE TASK large_changes
  SCHEDULE = '10 MINUTE'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'LARGE'
  WHEN SYSTEM$STREAM_HAS_DATA('my_stream')
AS ...;
```

#### 3. Conditional Processing
Skip processing when not needed:

```sql
CREATE TASK conditional_processor
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN 
    SYSTEM$STREAM_HAS_DATA('my_stream')
    AND (SELECT COUNT(*) FROM my_stream) > 100  -- Only if enough changes
AS ...;
```

### Monitoring Stream-Task Pipelines

#### Key Metrics to Track

1. **Stream lag**: Time between change and processing
2. **Task success rate**: Percentage of successful runs
3. **Processing time**: How long tasks take
4. **Error rate**: Failed records or tasks
5. **Credit consumption**: Cost of pipeline

#### Monitoring Queries

```sql
-- Stream lag
SELECT 
  stream_name,
  table_name,
  DATEDIFF(minute, 
    (SELECT MAX(last_updated) FROM source_table),
    CURRENT_TIMESTAMP()
  ) as lag_minutes
FROM streams_metadata;

-- Task execution summary
SELECT 
  NAME,
  COUNT(*) as total_runs,
  SUM(CASE WHEN STATE = 'SUCCEEDED' THEN 1 ELSE 0 END) as successful,
  SUM(CASE WHEN STATE = 'FAILED' THEN 1 ELSE 0 END) as failed,
  AVG(DATEDIFF(second, SCHEDULED_TIME, COMPLETED_TIME)) as avg_duration_sec
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD(day, -7, CURRENT_TIMESTAMP())
))
GROUP BY NAME;

-- Stream consumption rate
SELECT 
  DATE_TRUNC('hour', processed_time) as hour,
  COUNT(*) as records_processed
FROM processing_log
GROUP BY 1
ORDER BY 1 DESC;
```

### Best Practices

**1. Stream Management**
- Create streams on stable tables (not frequently dropped/recreated)
- Monitor stream staleness
- Use APPEND_ONLY when possible for better performance
- Process streams regularly (within retention period)

**2. Task Configuration**
- Use WHEN SYSTEM$STREAM_HAS_DATA() to avoid unnecessary runs
- Set appropriate schedule intervals (balance latency vs. cost)
- Use serverless for variable workloads
- Implement error handling and logging

**3. MERGE Operations**
- Handle all three cases: INSERT, UPDATE, DELETE
- Use METADATA$ISUPDATE to distinguish updates
- Consider performance with large change sets
- Add indexes on join columns

**4. Error Handling**
- Log all errors to dedicated table
- Implement retry logic for transient failures
- Use dead letter queues for invalid data
- Set up alerts for task failures

**5. Testing**
- Test with small data sets first
- Verify stream consumption (offset advances)
- Test failure scenarios
- Monitor resource usage

**6. Production Deployment**
- Start with longer intervals, optimize later
- Monitor for first 24 hours
- Set up alerting
- Document pipeline architecture
- Plan for maintenance windows

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Basic Stream-Task Integration
Create a simple CDC pipeline with stream and task.

### Exercise 2: Incremental MERGE Pattern
Implement upsert logic with MERGE statement.

### Exercise 3: SCD Type 2 Automation
Build automated slowly changing dimension.

### Exercise 4: Multi-Stage Pipeline
Create task tree with multiple processing stages.

### Exercise 5: Error Handling
Implement error logging and dead letter queue.

### Exercise 6: Performance Optimization
Optimize pipeline with batching and warehouse sizing.

### Exercise 7: Monitoring Dashboard
Build queries to monitor pipeline health.

### Exercise 8: Production-Ready Pipeline
Create complete, production-ready CDC pipeline.

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:

1. What does SYSTEM$STREAM_HAS_DATA() return?
2. When should you use APPEND_ONLY streams with tasks?
3. How do you handle UPDATEs in a MERGE statement with streams?
4. What happens if a task fails while processing a stream?
5. Why use WHEN clause with SYSTEM$STREAM_HAS_DATA()?
6. Can multiple tasks consume the same stream?
7. What's the recommended schedule interval for CDC tasks?
8. How do you implement SCD Type 2 with streams and tasks?
9. What's the best way to handle errors in stream processing?
10. How do you monitor stream-task pipeline performance?

---

## 🎯 Key Takeaways

- Streams + Tasks = Automated CDC pipelines
- Use WHEN SYSTEM$STREAM_HAS_DATA() to skip unnecessary runs
- MERGE statement handles INSERT, UPDATE, DELETE in one operation
- Handle METADATA$ISUPDATE to distinguish updates from standalone operations
- Implement error handling with error tables or dead letter queues
- Monitor stream lag, task success rate, and processing time
- Use appropriate warehouse sizes for workload
- Process streams regularly to avoid staleness
- Test thoroughly before production deployment
- SCD Type 2 requires closing old records and inserting new versions
- Multi-stage pipelines use task trees with AFTER clause
- Batch processing reduces overhead and costs

---

## 📚 Additional Resources

- [Snowflake Docs: Streams](https://docs.snowflake.com/en/user-guide/streams)
- [Snowflake Docs: Tasks](https://docs.snowflake.com/en/user-guide/tasks-intro)
- [CDC with Streams and Tasks](https://docs.snowflake.com/en/user-guide/streams-intro#change-data-capture)
- [Task Graphs](https://docs.snowflake.com/en/user-guide/tasks-graphs)

---

## 🔜 Tomorrow: Day 5 - Dynamic Tables

We'll learn about Dynamic Tables, which provide a declarative alternative to streams and tasks for incremental processing.
