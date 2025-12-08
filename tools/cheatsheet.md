# Snowflake Quick Reference Cheat Sheet

Essential commands and concepts for the SnowPro Advanced: Data Engineer bootcamp.

---

## Snowpipe

```sql
-- Create pipe with auto-ingest
CREATE PIPE my_pipe
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC = 'arn:aws:sns:region:account:topic'
AS
  COPY INTO my_table FROM @my_stage;

-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('my_pipe');

-- View load history
SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'MY_TABLE',
  START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
));

-- Pause/Resume pipe
ALTER PIPE my_pipe SET PIPE_EXECUTION_PAUSED = TRUE;
ALTER PIPE my_pipe SET PIPE_EXECUTION_PAUSED = FALSE;

-- Refresh pipe manually
ALTER PIPE my_pipe REFRESH;
```

---

## Streams

```sql
-- Create standard stream
CREATE STREAM my_stream ON TABLE my_table;

-- Create append-only stream
CREATE STREAM my_stream ON TABLE my_table APPEND_ONLY = TRUE;

-- Query stream
SELECT * FROM my_stream;

-- Check if stream has data
SELECT SYSTEM$STREAM_HAS_DATA('my_stream');

-- Stream metadata columns
SELECT 
  METADATA$ACTION,
  METADATA$ISUPDATE,
  METADATA$ROW_ID,
  *
FROM my_stream;
```

---

## Tasks

```sql
-- Create standalone task
CREATE TASK my_task
  WAREHOUSE = my_wh
  SCHEDULE = 'USING CRON 0 9 * * * UTC'
AS
  INSERT INTO target SELECT * FROM source;

-- Create task with predecessor
CREATE TASK child_task
  WAREHOUSE = my_wh
  AFTER parent_task
AS
  SELECT * FROM my_table;

-- Serverless task
CREATE TASK my_task
  SCHEDULE = '5 MINUTE'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
  CALL my_procedure();

-- Resume/Suspend task
ALTER TASK my_task RESUME;
ALTER TASK my_task SUSPEND;

-- Execute task manually
EXECUTE TASK my_task;

-- View task history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  TASK_NAME => 'MY_TASK',
  SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
));
```

---

## Dynamic Tables

```sql
-- Create dynamic table
CREATE DYNAMIC TABLE my_dynamic_table
  TARGET_LAG = '5 minutes'
  WAREHOUSE = my_wh
AS
  SELECT * FROM source_table WHERE status = 'active';

-- Check refresh status
SELECT * FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
  NAME => 'MY_DYNAMIC_TABLE'
));

-- Alter target lag
ALTER DYNAMIC TABLE my_dynamic_table SET TARGET_LAG = '10 minutes';
```

---

## Clustering

```sql
-- Add clustering key
ALTER TABLE my_table CLUSTER BY (date, region);

-- Check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('my_table');

-- View clustering depth
SELECT SYSTEM$CLUSTERING_DEPTH('my_table');

-- Enable automatic clustering
ALTER TABLE my_table RESUME RECLUSTER;

-- Disable automatic clustering
ALTER TABLE my_table SUSPEND RECLUSTER;
```

---

## Search Optimization

```sql
-- Enable search optimization
ALTER TABLE my_table ADD SEARCH OPTIMIZATION;

-- Check search optimization status
SHOW TABLES LIKE 'my_table';

-- Remove search optimization
ALTER TABLE my_table DROP SEARCH OPTIMIZATION;
```

---

## Materialized Views

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW my_mv AS
  SELECT region, SUM(sales) as total_sales
  FROM sales_table
  GROUP BY region;

-- Refresh materialized view (automatic by default)
-- Manual refresh not supported

-- Check if MV is up to date
SHOW MATERIALIZED VIEWS LIKE 'my_mv';
```

---

## Query Performance

```sql
-- View query profile
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_ID = 'your_query_id';

-- Find slow queries
SELECT 
  QUERY_ID,
  QUERY_TEXT,
  EXECUTION_TIME,
  WAREHOUSE_SIZE
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE EXECUTION_TIME > 60000  -- 60 seconds
ORDER BY EXECUTION_TIME DESC
LIMIT 10;

-- Check for spilling
SELECT 
  QUERY_ID,
  BYTES_SPILLED_TO_LOCAL_STORAGE,
  BYTES_SPILLED_TO_REMOTE_STORAGE
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE BYTES_SPILLED_TO_REMOTE_STORAGE > 0;
```

---

## Warehouses

```sql
-- Create warehouse
CREATE WAREHOUSE my_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 3
  SCALING_POLICY = 'STANDARD';

-- Resize warehouse
ALTER WAREHOUSE my_wh SET WAREHOUSE_SIZE = 'SMALL';

-- Multi-cluster settings
ALTER WAREHOUSE my_wh SET 
  MIN_CLUSTER_COUNT = 2
  MAX_CLUSTER_COUNT = 5
  SCALING_POLICY = 'ECONOMY';

-- Suspend/Resume
ALTER WAREHOUSE my_wh SUSPEND;
ALTER WAREHOUSE my_wh RESUME;
```

---

## Security

```sql
-- Create role
CREATE ROLE my_role;

-- Grant privileges
GRANT USAGE ON DATABASE my_db TO ROLE my_role;
GRANT USAGE ON SCHEMA my_schema TO ROLE my_role;
GRANT SELECT ON TABLE my_table TO ROLE my_role;

-- Row access policy
CREATE ROW ACCESS POLICY region_policy AS (region VARCHAR)
  RETURNS BOOLEAN ->
    CURRENT_ROLE() = 'ADMIN' OR region = CURRENT_REGION();

-- Apply row access policy
ALTER TABLE my_table ADD ROW ACCESS POLICY region_policy ON (region);

-- Masking policy
CREATE MASKING POLICY email_mask AS (val STRING)
  RETURNS STRING ->
    CASE
      WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
      ELSE '***@***.com'
    END;

-- Apply masking policy
ALTER TABLE my_table MODIFY COLUMN email SET MASKING POLICY email_mask;
```

---

## Time Travel

```sql
-- Query historical data
SELECT * FROM my_table AT(OFFSET => -3600);  -- 1 hour ago
SELECT * FROM my_table BEFORE(STATEMENT => 'query_id');

-- Clone table at specific time
CREATE TABLE my_table_clone CLONE my_table
  AT(TIMESTAMP => '2025-12-08 10:00:00'::TIMESTAMP);

-- Restore dropped table
UNDROP TABLE my_table;

-- Set retention period
ALTER TABLE my_table SET DATA_RETENTION_TIME_IN_DAYS = 7;
```

---

## Data Sharing

```sql
-- Create share
CREATE SHARE my_share;

-- Grant usage on database
GRANT USAGE ON DATABASE my_db TO SHARE my_share;
GRANT USAGE ON SCHEMA my_schema TO SHARE my_share;
GRANT SELECT ON TABLE my_table TO SHARE my_share;

-- Add accounts to share
ALTER SHARE my_share ADD ACCOUNTS = account1, account2;

-- Create reader account
CREATE MANAGED ACCOUNT reader_account
  ADMIN_NAME = 'admin'
  ADMIN_PASSWORD = 'password'
  TYPE = READER;
```

---

## Monitoring

```sql
-- Credit usage
SELECT 
  DATE_TRUNC('day', START_TIME) as day,
  WAREHOUSE_NAME,
  SUM(CREDITS_USED) as credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC;

-- Query history
SELECT 
  QUERY_ID,
  USER_NAME,
  QUERY_TEXT,
  EXECUTION_TIME,
  ROWS_PRODUCED
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;

-- Storage usage
SELECT 
  TABLE_NAME,
  ACTIVE_BYTES / (1024*1024*1024) as active_gb,
  TIME_TRAVEL_BYTES / (1024*1024*1024) as time_travel_gb,
  FAILSAFE_BYTES / (1024*1024*1024) as failsafe_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'MY_DB'
ORDER BY active_gb DESC;
```

---

## External Tables

```sql
-- Create external table
CREATE EXTERNAL TABLE my_ext_table
  WITH LOCATION = @my_stage
  FILE_FORMAT = (TYPE = 'PARQUET')
  PATTERN = '.*[.]parquet';

-- Refresh external table metadata
ALTER EXTERNAL TABLE my_ext_table REFRESH;

-- Partitioned external table
CREATE EXTERNAL TABLE my_ext_table
  WITH LOCATION = @my_stage
  PARTITION BY (year, month)
  FILE_FORMAT = (TYPE = 'PARQUET');
```

---

## Stored Procedures & UDFs

```sql
-- JavaScript stored procedure
CREATE PROCEDURE my_proc(arg1 VARCHAR)
  RETURNS VARCHAR
  LANGUAGE JAVASCRIPT
AS
$$
  return "Hello " + ARG1;
$$;

-- Python UDF
CREATE FUNCTION my_udf(x FLOAT, y FLOAT)
  RETURNS FLOAT
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.8'
  HANDLER = 'compute'
AS
$$
def compute(x, y):
    return x + y
$$;

-- Call stored procedure
CALL my_proc('World');

-- Use UDF
SELECT my_udf(10.5, 20.3);
```

---

## Key Limits to Remember

| Feature | Limit |
|---------|-------|
| Time Travel (Standard) | 0-90 days |
| Time Travel (Transient) | 0-1 day |
| Fail-safe | 7 days |
| Max clustering keys | 4 |
| Max file size (Snowpipe) | 5 GB |
| Max tasks per account | 10,000 |
| Max child tasks per parent | 100 |
| Result cache TTL | 24 hours |

---

## Exam Tips

**High-weight topics (focus here):**
- Data Movement (30%): Snowpipe, Streams, Tasks, Dynamic Tables
- Performance (25%): Clustering, Query Tuning, Warehouses
- Security (20%): RBAC, Masking, Row Access Policies
- Monitoring (15%): Account Usage, Query History

**Common question patterns:**
- When to use X vs Y (Snowpipe vs COPY, Streams vs Dynamic Tables)
- How to troubleshoot issues (pipe not loading, query slow)
- Best practices (file sizes, warehouse sizing, clustering)
- Architecture components (what's needed for auto-ingest)

**Remember:**
- Snowpipe is serverless (no warehouse)
- Streams are idempotent (consume once)
- Tasks can be serverless or user-managed
- Clustering is automatic (if enabled)
- Time Travel != Fail-safe
