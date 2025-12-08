# Day 19: Time Travel & Fail-Safe

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake Time Travel
- Query historical data at specific points in time
- Recover dropped tables and databases
- Understand Fail-Safe and its purpose
- Configure Time Travel retention periods
- Use Time Travel for auditing and compliance
- Understand storage costs for Time Travel
- Apply best practices for data recovery

---

## Theory

### What is Time Travel?

**Time Travel** allows you to access historical data that has been changed or deleted within a defined period.

**Key Features**:
- Query data as it existed in the past
- Restore dropped tables/schemas/databases
- Undo accidental changes
- Audit data changes
- Clone historical data

**Retention Period**:
- **Standard Edition**: 1 day (24 hours)
- **Enterprise Edition**: Up to 90 days (configurable)
- **Default**: 1 day for all editions

```
Current Data
    ↓
Time Travel (1-90 days)
    ↓
Fail-Safe (7 days)
    ↓
Permanently Deleted
```

### Time Travel Use Cases

**1. Accidental Deletion Recovery**
```sql
-- Oops! Dropped the wrong table
DROP TABLE important_data;

-- Recover it with Time Travel
UNDROP TABLE important_data;
```

**2. Query Historical Data**
```sql
-- See data as it was yesterday
SELECT * FROM orders
AT(OFFSET => -86400);  -- 86400 seconds = 24 hours

-- See data at specific timestamp
SELECT * FROM orders
AT(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);
```

**3. Audit Changes**
```sql
-- Compare current vs. historical data
SELECT * FROM customers
MINUS
SELECT * FROM customers
AT(TIMESTAMP => '2024-01-01 00:00:00'::TIMESTAMP);
```

**4. Undo Mistakes**
```sql
-- Accidentally deleted data
DELETE FROM orders WHERE region = 'NORTH';

-- Restore from before the delete
CREATE OR REPLACE TABLE orders AS
SELECT * FROM orders
BEFORE(STATEMENT => '<query_id>');
```

### Time Travel Syntax

#### AT Clause

Query data at a specific point:

```sql
-- By timestamp
SELECT * FROM table_name
AT(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);

-- By offset (seconds ago)
SELECT * FROM table_name
AT(OFFSET => -3600);  -- 1 hour ago

-- By statement/query ID
SELECT * FROM table_name
AT(STATEMENT => '01a2b3c4-5678-90ab-cdef-1234567890ab');
```

#### BEFORE Clause

Query data before a change:

```sql
-- Before a specific statement
SELECT * FROM table_name
BEFORE(STATEMENT => '<query_id>');

-- Before a timestamp
SELECT * FROM table_name
BEFORE(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);
```

### Configuring Time Travel

#### Set Retention Period

```sql
-- At account level (requires ACCOUNTADMIN)
ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS = 90;

-- At database level
ALTER DATABASE mydb SET DATA_RETENTION_TIME_IN_DAYS = 30;

-- At schema level
ALTER SCHEMA myschema SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- At table level
ALTER TABLE mytable SET DATA_RETENTION_TIME_IN_DAYS = 14;

-- At table creation
CREATE TABLE mytable (
  id INT,
  name STRING
) DATA_RETENTION_TIME_IN_DAYS = 30;
```

#### View Retention Settings

```sql
-- Show table retention
SHOW TABLES;
-- Look at RETENTION_TIME column

-- Show database retention
SHOW DATABASES;

-- Show schema retention
SHOW SCHEMAS;
```

### Recovering Dropped Objects

#### UNDROP Command

```sql
-- Undrop table
UNDROP TABLE mytable;

-- Undrop schema
UNDROP SCHEMA myschema;

-- Undrop database
UNDROP DATABASE mydb;
```

#### Restore with Rename

```sql
-- If table name conflicts, restore with new name
CREATE TABLE mytable_restored AS
SELECT * FROM mytable
AT(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);
```

### Cloning with Time Travel

Create clones from historical data:

```sql
-- Clone table as it was yesterday
CREATE TABLE orders_yesterday CLONE orders
AT(OFFSET => -86400);

-- Clone table at specific timestamp
CREATE TABLE orders_jan15 CLONE orders
AT(TIMESTAMP => '2024-01-15 00:00:00'::TIMESTAMP);

-- Clone before a statement
CREATE TABLE orders_before_delete CLONE orders
BEFORE(STATEMENT => '<query_id>');
```

### Fail-Safe

**Fail-Safe** is a 7-day period after Time Travel for disaster recovery.

**Key Characteristics**:
- **Duration**: 7 days (non-configurable)
- **Access**: Only Snowflake Support can recover
- **Purpose**: Disaster recovery only
- **Cost**: Storage charges apply
- **Automatic**: Always enabled

```
Timeline:
Day 0: Data deleted/changed
Day 1-90: Time Travel (user accessible)
Day 91-97: Fail-Safe (Snowflake Support only)
Day 98+: Permanently deleted
```

**When to Use Fail-Safe**:
- Catastrophic data loss
- Time Travel period expired
- Contact Snowflake Support
- Last resort recovery

### Time Travel vs. Fail-Safe

| Feature | Time Travel | Fail-Safe |
|---------|------------|-----------|
| **Duration** | 1-90 days | 7 days |
| **Access** | User | Snowflake Support only |
| **Purpose** | User recovery | Disaster recovery |
| **Configurable** | Yes | No |
| **Cost** | Storage | Storage |
| **Queries** | Yes | No |

### Storage Costs

Time Travel and Fail-Safe incur storage costs:

```sql
-- View storage usage
SELECT 
  table_name,
  active_bytes / 1024 / 1024 / 1024 as active_gb,
  time_travel_bytes / 1024 / 1024 / 1024 as time_travel_gb,
  failsafe_bytes / 1024 / 1024 / 1024 as failsafe_gb,
  (active_bytes + time_travel_bytes + failsafe_bytes) / 1024 / 1024 / 1024 as total_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'MYDB'
  AND table_schema = 'PUBLIC'
ORDER BY total_gb DESC;
```

**Cost Optimization**:
- Reduce retention period for non-critical tables
- Use transient tables (no Fail-Safe)
- Use temporary tables (no Time Travel or Fail-Safe)
- Regular data cleanup

### Transient and Temporary Tables

#### Transient Tables

No Fail-Safe, reduced Time Travel:

```sql
-- Create transient table
CREATE TRANSIENT TABLE staging_data (
  id INT,
  data STRING
) DATA_RETENTION_TIME_IN_DAYS = 1;

-- Benefits:
-- - No Fail-Safe (saves storage)
-- - Max 1 day Time Travel
-- - Lower storage costs
-- - Good for staging/ETL
```

#### Temporary Tables

No Time Travel or Fail-Safe:

```sql
-- Create temporary table
CREATE TEMPORARY TABLE temp_data (
  id INT,
  data STRING
);

-- Characteristics:
-- - No Time Travel
-- - No Fail-Safe
-- - Session-scoped
-- - Automatically dropped
-- - Lowest storage cost
```

### Practical Examples

#### Example 1: Recover Deleted Data

```sql
-- Accidentally deleted data
DELETE FROM customers WHERE region = 'NORTH';

-- Get query ID of the DELETE
SELECT query_id, query_text
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%DELETE FROM customers%'
ORDER BY start_time DESC
LIMIT 1;

-- Restore data from before the delete
INSERT INTO customers
SELECT * FROM customers
BEFORE(STATEMENT => '<query_id>')
WHERE region = 'NORTH';
```

#### Example 2: Audit Data Changes

```sql
-- Find what changed in last 24 hours
SELECT 
  'Added' as change_type,
  *
FROM customers
WHERE customer_id NOT IN (
  SELECT customer_id FROM customers
  AT(OFFSET => -86400)
)
UNION ALL
SELECT 
  'Removed' as change_type,
  *
FROM customers
AT(OFFSET => -86400)
WHERE customer_id NOT IN (
  SELECT customer_id FROM customers
);
```

#### Example 3: Point-in-Time Reporting

```sql
-- Generate report as of month-end
SELECT 
  region,
  COUNT(*) as customer_count,
  SUM(total_revenue) as total_revenue
FROM customers
AT(TIMESTAMP => '2024-01-31 23:59:59'::TIMESTAMP)
GROUP BY region;
```

#### Example 4: Compare Versions

```sql
-- Compare current vs. last week
WITH current AS (
  SELECT * FROM sales
),
last_week AS (
  SELECT * FROM sales
  AT(OFFSET => -604800)  -- 7 days in seconds
)
SELECT 
  c.product_id,
  c.total_sales as current_sales,
  l.total_sales as last_week_sales,
  c.total_sales - l.total_sales as change
FROM current c
LEFT JOIN last_week l ON c.product_id = l.product_id;
```

### Best Practices

#### 1. Set Appropriate Retention

```sql
-- Critical data: longer retention
ALTER TABLE financial_records 
SET DATA_RETENTION_TIME_IN_DAYS = 90;

-- Staging data: minimal retention
ALTER TABLE staging_temp 
SET DATA_RETENTION_TIME_IN_DAYS = 1;

-- Use transient for ETL
CREATE TRANSIENT TABLE etl_staging (...);
```

#### 2. Document Query IDs

```sql
-- Save query IDs for important operations
CREATE TABLE operation_log (
  operation_date TIMESTAMP,
  operation_type STRING,
  query_id STRING,
  description STRING
);

-- Log important operations
INSERT INTO operation_log VALUES (
  CURRENT_TIMESTAMP(),
  'BULK_DELETE',
  '<query_id>',
  'Deleted old records from orders table'
);
```

#### 3. Regular Testing

```sql
-- Test recovery procedures
-- 1. Create test table
CREATE TABLE recovery_test AS SELECT * FROM important_table;

-- 2. Make changes
DELETE FROM recovery_test WHERE id < 100;

-- 3. Recover
CREATE TABLE recovery_test_restored AS
SELECT * FROM recovery_test
BEFORE(STATEMENT => '<query_id>');

-- 4. Verify
SELECT COUNT(*) FROM recovery_test_restored;

-- 5. Cleanup
DROP TABLE recovery_test;
DROP TABLE recovery_test_restored;
```

#### 4. Monitor Storage

```sql
-- Create monitoring view
CREATE VIEW time_travel_storage AS
SELECT 
  table_catalog,
  table_schema,
  table_name,
  active_bytes / 1024 / 1024 / 1024 as active_gb,
  time_travel_bytes / 1024 / 1024 / 1024 as time_travel_gb,
  failsafe_bytes / 1024 / 1024 / 1024 as failsafe_gb,
  ROUND((time_travel_bytes + failsafe_bytes) / 
    NULLIF(active_bytes, 0) * 100, 2) as overhead_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE deleted IS NULL
ORDER BY time_travel_bytes + failsafe_bytes DESC;

-- Review regularly
SELECT * FROM time_travel_storage
WHERE overhead_pct > 50;  -- High overhead
```

### Limitations

**Time Travel Cannot**:
- Recover permanently deleted data (after retention + Fail-Safe)
- Query external tables
- Query views (query underlying tables instead)
- Recover data from before table creation
- Extend beyond 90 days (Enterprise max)

**Performance Considerations**:
- Historical queries may be slower
- Large time ranges require more compute
- Consider materialized views for frequent historical queries

### Troubleshooting

#### Issue 1: Cannot Query Historical Data

**Cause**: Outside retention period

**Solution**:
```sql
-- Check retention setting
SHOW TABLES LIKE 'mytable';
-- Look at RETENTION_TIME column

-- Check when data was changed
SELECT 
  table_name,
  deleted,
  retention_time
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE table_name = 'MYTABLE';
```

#### Issue 2: UNDROP Fails

**Cause**: Table name already exists or retention expired

**Solution**:
```sql
-- Check if table exists
SHOW TABLES LIKE 'mytable';

-- If exists, drop current version first
DROP TABLE mytable;
UNDROP TABLE mytable;

-- Or restore with different name
CREATE TABLE mytable_recovered AS
SELECT * FROM mytable
AT(TIMESTAMP => '<timestamp>');
```

#### Issue 3: High Storage Costs

**Cause**: Long retention periods or frequent changes

**Solution**:
```sql
-- Reduce retention for non-critical tables
ALTER TABLE staging_data 
SET DATA_RETENTION_TIME_IN_DAYS = 1;

-- Use transient tables
CREATE TRANSIENT TABLE temp_staging (...);

-- Monitor and cleanup
SELECT * FROM time_travel_storage
WHERE overhead_pct > 100;
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Query Historical Data
Use Time Travel to query past data.

### Exercise 2: Recover Deleted Data
Restore accidentally deleted data.

### Exercise 3: Undrop Objects
Recover dropped tables and schemas.

### Exercise 4: Clone Historical Data
Create clones from specific points in time.

### Exercise 5: Audit Data Changes
Track and compare data changes.

### Exercise 6: Configure Retention
Set appropriate retention periods.

### Exercise 7: Monitor Storage
Track Time Travel and Fail-Safe storage.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Time Travel enables querying and recovering historical data
- Retention period: 1 day (Standard) to 90 days (Enterprise)
- Fail-Safe provides 7 additional days (Snowflake Support only)
- Use AT and BEFORE clauses for historical queries
- UNDROP recovers dropped objects
- Cloning works with Time Travel
- Storage costs apply for Time Travel and Fail-Safe
- Transient tables have no Fail-Safe
- Temporary tables have no Time Travel or Fail-Safe
- Set appropriate retention based on data criticality

---

## 📚 Additional Resources

- [Snowflake Docs: Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel)
- [Fail-Safe](https://docs.snowflake.com/en/user-guide/data-failsafe)
- [Understanding Storage](https://docs.snowflake.com/en/user-guide/tables-storage-considerations)

---

## 🔜 Tomorrow: Day 20 - Cloning & Zero-Copy Cloning

We'll learn about Snowflake's zero-copy cloning feature for creating instant copies of databases, schemas, and tables.
