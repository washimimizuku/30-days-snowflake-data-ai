# Day 5: Dynamic Tables

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Dynamic Tables and their use cases
- Know when to use Dynamic Tables vs. Streams + Tasks
- Configure TARGET_LAG for refresh frequency
- Build multi-layer Dynamic Table pipelines
- Understand refresh modes (incremental vs. full)
- Monitor Dynamic Table performance and costs
- Optimize Dynamic Tables for production
- Compare Dynamic Tables with Materialized Views

---

## Theory

### What are Dynamic Tables?

Dynamic Tables are a declarative way to define data transformations that automatically refresh based on changes in source data. They simplify pipeline creation by eliminating the need for streams and tasks.

**Key Characteristics:**
- **Declarative**: Define WHAT you want, not HOW to get it
- **Automatic refresh**: Snowflake manages the refresh process
- **Incremental**: Processes only changed data when possible
- **Target lag**: Specify maximum data freshness
- **Serverless**: No warehouse management required

### Dynamic Tables vs. Streams + Tasks

| Feature | Dynamic Tables | Streams + Tasks |
|---------|---------------|-----------------|
| **Approach** | Declarative (WHAT) | Imperative (HOW) |
| **Complexity** | Simple SQL query | Streams + Tasks + MERGE logic |
| **Refresh** | Automatic | Manual orchestration |
| **Incremental** | Automatic when possible | Manual implementation |
| **Monitoring** | Built-in | Custom queries needed |
| **Use Case** | Most transformations | Complex logic, custom control |

### When to Use Dynamic Tables

✅ **Use Dynamic Tables for:**
- Standard transformations (aggregations, joins, filters)
- Multi-layer data pipelines
- Incremental processing without complexity
- When you want automatic refresh management
- Simplified pipeline maintenance

❌ **Use Streams + Tasks for:**
- Complex business logic requiring stored procedures
- Custom error handling requirements
- Need for fine-grained control over execution
- Integration with external systems
- When you need to process multiple targets differently

### Basic Dynamic Table Syntax

```sql
CREATE DYNAMIC TABLE my_dynamic_table
  TARGET_LAG = '5 minutes'
  WAREHOUSE = my_wh
AS
  SELECT 
    customer_id,
    SUM(amount) as total_amount,
    COUNT(*) as order_count
  FROM orders
  GROUP BY customer_id;
```

### TARGET_LAG

TARGET_LAG specifies the maximum acceptable data freshness.

**Syntax options:**
```sql
-- Time-based lag
TARGET_LAG = '1 minute'
TARGET_LAG = '5 minutes'
TARGET_LAG = '1 hour'
TARGET_LAG = '1 day'

-- Downstream lag (for dependent tables)
TARGET_LAG = DOWNSTREAM
```

**How it works:**
- Snowflake monitors source table changes
- Refreshes Dynamic Table to meet TARGET_LAG
- Shorter lag = more frequent refreshes = higher cost
- Longer lag = less frequent refreshes = lower cost

**Choosing TARGET_LAG:**
- Real-time dashboards: 1-5 minutes
- Hourly reports: 1 hour
- Daily reports: 1 day
- Dependent tables: DOWNSTREAM

### Refresh Modes

#### Incremental Refresh
Processes only changed data (most efficient)

**Supported for:**
- Simple aggregations (SUM, COUNT, AVG, MIN, MAX)
- Filters (WHERE clauses)
- Simple joins
- GROUP BY operations

```sql
-- Incremental refresh example
CREATE DYNAMIC TABLE sales_summary
  TARGET_LAG = '10 minutes'
  WAREHOUSE = my_wh
AS
  SELECT 
    product_id,
    DATE_TRUNC('day', order_date) as day,
    SUM(amount) as daily_sales,
    COUNT(*) as order_count
  FROM orders
  GROUP BY product_id, day;
```

#### Full Refresh
Reprocesses entire dataset

**Required for:**
- Complex joins
- Window functions
- DISTINCT operations
- Subqueries
- Set operations (UNION, INTERSECT, EXCEPT)

```sql
-- Full refresh example (window function)
CREATE DYNAMIC TABLE customer_rankings
  TARGET_LAG = '1 hour'
  WAREHOUSE = my_wh
AS
  SELECT 
    customer_id,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) as rank
  FROM customer_totals;
```

### Multi-Layer Pipelines

Build data pipelines with dependent Dynamic Tables:

```
Source Table → Dynamic Table 1 → Dynamic Table 2 → Dynamic Table 3
```

**Example:**
```sql
-- Layer 1: Clean and filter
CREATE DYNAMIC TABLE orders_clean
  TARGET_LAG = '5 minutes'
  WAREHOUSE = my_wh
AS
  SELECT *
  FROM orders_raw
  WHERE amount > 0 AND quantity > 0;

-- Layer 2: Daily aggregation (depends on Layer 1)
CREATE DYNAMIC TABLE daily_sales
  TARGET_LAG = DOWNSTREAM  -- Inherits from orders_clean
  WAREHOUSE = my_wh
AS
  SELECT 
    DATE_TRUNC('day', order_date) as day,
    SUM(amount) as total_sales,
    COUNT(*) as order_count
  FROM orders_clean
  GROUP BY day;

-- Layer 3: Weekly rollup (depends on Layer 2)
CREATE DYNAMIC TABLE weekly_sales
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = my_wh
AS
  SELECT 
    DATE_TRUNC('week', day) as week,
    SUM(total_sales) as weekly_sales,
    SUM(order_count) as weekly_orders
  FROM daily_sales
  GROUP BY week;
```

### Dynamic Tables vs. Materialized Views

| Feature | Dynamic Tables | Materialized Views |
|---------|---------------|-------------------|
| **Refresh control** | TARGET_LAG | Automatic (no control) |
| **Incremental** | Yes (when possible) | Yes (always) |
| **Complexity** | Any query | Limited (no joins, subqueries) |
| **Cost visibility** | Clear (warehouse usage) | Hidden (background maintenance) |
| **Dependencies** | Can chain | Cannot chain |
| **Best for** | Pipelines, transformations | Simple aggregations |

### Monitoring Dynamic Tables

#### Check Refresh Status

```sql
-- Show Dynamic Tables
SHOW DYNAMIC TABLES;

-- View refresh history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
  NAME => 'MY_DYNAMIC_TABLE'
))
ORDER BY REFRESH_START_TIME DESC;

-- Check current lag
SELECT 
  name,
  target_lag,
  data_timestamp,
  DATEDIFF(second, data_timestamp, CURRENT_TIMESTAMP()) as current_lag_seconds
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLES())
WHERE name = 'MY_DYNAMIC_TABLE';
```

#### Monitor Costs

```sql
-- Credit usage by Dynamic Table
SELECT 
  dynamic_table_name,
  DATE_TRUNC('day', refresh_start_time) as day,
  SUM(credits_used) as total_credits,
  COUNT(*) as refresh_count,
  AVG(credits_used) as avg_credits_per_refresh
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLE_REFRESH_HISTORY
WHERE dynamic_table_name = 'MY_DYNAMIC_TABLE'
  AND refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 2 DESC;
```

### Managing Dynamic Tables

```sql
-- Suspend refresh (manual control)
ALTER DYNAMIC TABLE my_table SUSPEND;

-- Resume refresh
ALTER DYNAMIC TABLE my_table RESUME;

-- Change TARGET_LAG
ALTER DYNAMIC TABLE my_table SET TARGET_LAG = '10 minutes';

-- Change warehouse
ALTER DYNAMIC TABLE my_table SET WAREHOUSE = new_wh;

-- Manual refresh
ALTER DYNAMIC TABLE my_table REFRESH;

-- Drop Dynamic Table
DROP DYNAMIC TABLE my_table;
```

### Performance Optimization

#### 1. Choose Appropriate TARGET_LAG
```sql
-- Too aggressive (expensive)
TARGET_LAG = '1 minute'  -- Only if truly needed

-- Balanced (most use cases)
TARGET_LAG = '5 minutes'  -- Good for dashboards
TARGET_LAG = '1 hour'     -- Good for reports

-- Relaxed (cost-effective)
TARGET_LAG = '1 day'      -- Good for daily summaries
```

#### 2. Use Incremental Refresh When Possible
```sql
-- Good: Incremental refresh
SELECT product_id, SUM(amount)
FROM orders
GROUP BY product_id;

-- Avoid: Full refresh (window functions)
SELECT product_id, amount,
       RANK() OVER (ORDER BY amount DESC)
FROM orders;
```

#### 3. Optimize Query Performance
```sql
-- Add clustering keys to source tables
ALTER TABLE orders CLUSTER BY (order_date);

-- Use appropriate warehouse size
ALTER DYNAMIC TABLE my_table SET WAREHOUSE = large_wh;

-- Filter early in pipeline
CREATE DYNAMIC TABLE filtered_orders
  TARGET_LAG = '5 minutes'
  WAREHOUSE = my_wh
AS
  SELECT *
  FROM orders
  WHERE order_date >= DATEADD(day, -30, CURRENT_DATE());
```

#### 4. Layer Your Pipeline
```sql
-- Good: Multiple simple layers
Layer 1: Filter and clean
Layer 2: Aggregate
Layer 3: Join and enrich

-- Avoid: One complex layer with everything
```

### Best Practices

**1. Start Simple**
- Begin with longer TARGET_LAG (1 hour)
- Monitor costs and performance
- Reduce lag only if needed

**2. Use DOWNSTREAM for Dependencies**
```sql
CREATE DYNAMIC TABLE dependent_table
  TARGET_LAG = DOWNSTREAM  -- Inherits from upstream
  WAREHOUSE = my_wh
AS
  SELECT * FROM upstream_dynamic_table;
```

**3. Monitor Refresh Patterns**
- Check refresh frequency
- Monitor credit usage
- Identify full vs. incremental refreshes
- Optimize queries for incremental refresh

**4. Design for Incremental Refresh**
- Use simple aggregations when possible
- Avoid window functions unless necessary
- Keep transformations straightforward
- Test refresh mode (incremental vs. full)

**5. Handle Dependencies Carefully**
- Use DOWNSTREAM for dependent tables
- Don't create circular dependencies
- Document pipeline architecture
- Test cascade refreshes

**6. Cost Management**
- Use appropriate warehouse sizes
- Set realistic TARGET_LAG values
- Monitor credit consumption
- Suspend tables during maintenance

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Basic Dynamic Table
Create a simple Dynamic Table with aggregation.

### Exercise 2: Configure TARGET_LAG
Test different TARGET_LAG values and observe refresh behavior.

### Exercise 3: Multi-Layer Pipeline
Build a 3-layer Dynamic Table pipeline.

### Exercise 4: Incremental vs. Full Refresh
Compare incremental and full refresh modes.

### Exercise 5: Monitor Refresh History
Query refresh history and analyze performance.

### Exercise 6: Cost Analysis
Analyze credit usage and optimize costs.

### Exercise 7: Dynamic Tables vs. Materialized Views
Compare both approaches for the same use case.

### Exercise 8: Production Pipeline
Build a complete production-ready Dynamic Table pipeline.

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:

1. What does TARGET_LAG specify in a Dynamic Table?
2. When does Snowflake use incremental refresh?
3. What's the difference between Dynamic Tables and Materialized Views?
4. Can you chain Dynamic Tables together?
5. What does TARGET_LAG = DOWNSTREAM mean?
6. How do you manually refresh a Dynamic Table?
7. Which operations prevent incremental refresh?
8. How do you monitor Dynamic Table costs?
9. Can you suspend a Dynamic Table?
10. When should you use Dynamic Tables vs. Streams + Tasks?

---

## 🎯 Key Takeaways

- Dynamic Tables provide declarative data transformations
- TARGET_LAG controls refresh frequency and data freshness
- Incremental refresh processes only changed data (most efficient)
- Full refresh required for complex operations (window functions, DISTINCT)
- Use DOWNSTREAM for dependent Dynamic Tables
- Multi-layer pipelines enable complex transformations
- Monitor refresh history and credit usage
- Simpler than Streams + Tasks for standard transformations
- Choose appropriate TARGET_LAG to balance freshness and cost
- Dynamic Tables can be suspended, resumed, and manually refreshed
- Better than Materialized Views for complex queries and pipelines

---

## 📚 Additional Resources

- [Snowflake Docs: Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-intro)
- [Dynamic Tables vs. Streams and Tasks](https://docs.snowflake.com/en/user-guide/dynamic-tables-comparison)
- [Dynamic Table Refresh](https://docs.snowflake.com/en/user-guide/dynamic-tables-refresh)
- [Dynamic Table Best Practices](https://docs.snowflake.com/en/user-guide/dynamic-tables-best-practices)

---

## 🔜 Tomorrow: Day 6 - Advanced SQL Transformations

We'll learn advanced SQL techniques for data transformations including window functions, QUALIFY, lateral joins, and JSON processing.
