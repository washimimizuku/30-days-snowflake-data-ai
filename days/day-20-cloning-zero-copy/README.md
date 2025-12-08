# Day 20: Cloning & Zero-Copy Cloning

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake's zero-copy cloning feature
- Clone databases, schemas, and tables instantly
- Use cloning for development and testing environments
- Combine cloning with Time Travel
- Understand storage implications of cloning
- Apply cloning for data backup and recovery
- Use cloning in CI/CD pipelines
- Understand clone inheritance and metadata

---

## Theory

### What is Zero-Copy Cloning?

**Zero-Copy Cloning** creates a copy of a database, schema, or table without physically copying the underlying data.

**Key Features**:
- **Instant**: Clones are created in seconds, regardless of size
- **Zero-Copy**: No data duplication at creation time
- **Independent**: Changes to clone don't affect source
- **Cost-Effective**: Only pay for storage when data diverges
- **Metadata-Only**: Initially shares micro-partitions with source

```
Source Table (1 TB)
       ↓
   CLONE (instant)
       ↓
Clone Table (0 bytes initially)
       ↓
   Modifications
       ↓
Clone Table (only changed data stored)
```

### How Zero-Copy Cloning Works

**At Clone Creation**:
```sql
CREATE TABLE orders_clone CLONE orders;
```

**What Happens**:
1. Snowflake copies metadata (table definition, statistics)
2. Clone points to same micro-partitions as source
3. No data is physically copied
4. Clone is immediately available

**After Modifications**:
```sql
-- Modify clone
INSERT INTO orders_clone VALUES (1001, 'New Order');
DELETE FROM orders_clone WHERE order_id = 100;
```

**What Happens**:
1. Modified micro-partitions are copied (copy-on-write)
2. New micro-partitions created for inserts
3. Source table remains unchanged
4. Storage increases only for changed data

### Cloning Syntax

#### Clone Table

```sql
-- Basic clone
CREATE TABLE orders_clone CLONE orders;

-- Clone with Time Travel
CREATE TABLE orders_yesterday CLONE orders
AT(OFFSET => -86400);

CREATE TABLE orders_jan15 CLONE orders
AT(TIMESTAMP => '2024-01-15 00:00:00'::TIMESTAMP);

CREATE TABLE orders_before_delete CLONE orders
BEFORE(STATEMENT => '<query_id>');

-- Clone to different schema
CREATE TABLE dev_schema.orders_clone 
CLONE prod_schema.orders;
```

#### Clone Schema

```sql
-- Clone entire schema
CREATE SCHEMA sales_dev CLONE sales_prod;

-- Clone schema with Time Travel
CREATE SCHEMA sales_backup CLONE sales_prod
AT(TIMESTAMP => '2024-01-15 00:00:00'::TIMESTAMP);
```

#### Clone Database

```sql
-- Clone entire database
CREATE DATABASE mydb_dev CLONE mydb_prod;

-- Clone database with Time Travel
CREATE DATABASE mydb_backup CLONE mydb_prod
AT(TIMESTAMP => '2024-01-15 00:00:00'::TIMESTAMP);
```

### Use Cases

#### 1. Development & Testing Environments

```sql
-- Create dev environment from production
CREATE DATABASE dev_db CLONE prod_db;

-- Grant access to developers
GRANT USAGE ON DATABASE dev_db TO ROLE developer;
GRANT ALL ON ALL SCHEMAS IN DATABASE dev_db TO ROLE developer;
GRANT ALL ON ALL TABLES IN SCHEMA dev_db.public TO ROLE developer;

-- Developers can test without affecting production
USE DATABASE dev_db;
-- Make changes, test queries, etc.
```

#### 2. Data Backup & Recovery

```sql
-- Daily backup
CREATE DATABASE mydb_backup_20240115 CLONE mydb_prod;

-- Restore from backup if needed
CREATE DATABASE mydb_prod_restored CLONE mydb_backup_20240115;

-- Or restore specific table
CREATE TABLE orders_restored CLONE mydb_backup_20240115.public.orders;
```

#### 3. Testing Schema Changes

```sql
-- Clone production table
CREATE TABLE customers_test CLONE customers;

-- Test schema changes
ALTER TABLE customers_test ADD COLUMN loyalty_points INT;
UPDATE customers_test SET loyalty_points = 0;

-- Verify changes work
SELECT * FROM customers_test LIMIT 10;

-- If successful, apply to production
ALTER TABLE customers ADD COLUMN loyalty_points INT;
UPDATE customers SET loyalty_points = 0;

-- Cleanup test table
DROP TABLE customers_test;
```

#### 4. Data Analysis & Experimentation

```sql
-- Clone for analysis
CREATE TABLE sales_analysis CLONE sales;

-- Experiment with data
UPDATE sales_analysis SET region = 'UNKNOWN' WHERE region IS NULL;
DELETE FROM sales_analysis WHERE amount < 0;

-- Analyze without affecting source
SELECT region, SUM(amount) FROM sales_analysis GROUP BY region;

-- Drop when done
DROP TABLE sales_analysis;
```

#### 5. CI/CD Pipelines

```sql
-- In deployment script
-- 1. Clone production to staging
CREATE DATABASE staging_db CLONE prod_db;

-- 2. Run migrations on staging
USE DATABASE staging_db;
-- Apply schema changes

-- 3. Run tests
-- Execute test suite

-- 4. If tests pass, apply to production
USE DATABASE prod_db;
-- Apply same migrations

-- 5. Cleanup staging
DROP DATABASE staging_db;
```

#### 6. Point-in-Time Snapshots

```sql
-- Create monthly snapshots
CREATE DATABASE mydb_snapshot_202401 CLONE mydb_prod
AT(TIMESTAMP => '2024-01-31 23:59:59'::TIMESTAMP);

CREATE DATABASE mydb_snapshot_202402 CLONE mydb_prod
AT(TIMESTAMP => '2024-02-29 23:59:59'::TIMESTAMP);

-- Query historical snapshots
SELECT * FROM mydb_snapshot_202401.public.orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';
```

### Cloning with Time Travel

Combine cloning with Time Travel for powerful recovery:

```sql
-- Clone table as it was yesterday
CREATE TABLE orders_yesterday CLONE orders
AT(OFFSET => -86400);

-- Clone before accidental deletion
-- 1. Get query ID of DELETE
SELECT query_id FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%DELETE FROM orders%'
ORDER BY start_time DESC LIMIT 1;

-- 2. Clone from before the delete
CREATE TABLE orders_recovered CLONE orders
BEFORE(STATEMENT => '<query_id>');

-- Clone at specific timestamp
CREATE TABLE orders_month_end CLONE orders
AT(TIMESTAMP => '2024-01-31 23:59:59'::TIMESTAMP);
```

### Storage Implications

#### Initial Clone

```sql
-- Source table: 1 TB
-- Clone table: 0 bytes (shares micro-partitions)
CREATE TABLE large_table_clone CLONE large_table;
```

#### After Modifications

```sql
-- Insert 100 GB of new data
INSERT INTO large_table_clone SELECT * FROM new_data;
-- Clone storage: 100 GB

-- Update 50 GB of existing data
UPDATE large_table_clone SET status = 'PROCESSED' WHERE status = 'PENDING';
-- Clone storage: 100 GB + 50 GB = 150 GB

-- Delete 25 GB of data
DELETE FROM large_table_clone WHERE created_date < '2023-01-01';
-- Clone storage: 150 GB (deleted data still in Time Travel)
```

#### Monitoring Clone Storage

```sql
-- View storage by table
SELECT 
  table_catalog,
  table_schema,
  table_name,
  active_bytes / 1024 / 1024 / 1024 as active_gb,
  time_travel_bytes / 1024 / 1024 / 1024 as time_travel_gb,
  failsafe_bytes / 1024 / 1024 / 1024 as failsafe_gb,
  clone_group_id,
  is_clone
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_name LIKE '%clone%'
ORDER BY active_bytes DESC;
```

### Clone Metadata & Inheritance

#### What Gets Cloned

**Cloned**:
- Table structure (columns, data types)
- Data (via micro-partition pointers)
- Clustering keys
- Comments
- Constraints (NOT NULL, etc.)

**Not Cloned**:
- External stages
- Internal stages (data files)
- Pipes
- Streams (must be recreated)
- Tasks (must be recreated)
- Grants/privileges (must be re-granted)

#### Checking Clone Relationships

```sql
-- View clone relationships
SELECT 
  table_catalog,
  table_schema,
  table_name,
  clone_group_id,
  is_clone,
  bytes,
  row_count
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE clone_group_id IS NOT NULL
ORDER BY clone_group_id, table_name;
```

### Practical Examples

#### Example 1: Dev/Test Environment

```sql
-- Create development database from production
CREATE DATABASE dev_analytics CLONE prod_analytics;

-- Verify clone
SHOW DATABASES LIKE 'dev_analytics';

-- Check table count
SELECT COUNT(*) as table_count
FROM dev_analytics.information_schema.tables;

-- Grant access to dev team
GRANT USAGE ON DATABASE dev_analytics TO ROLE developer;
GRANT USAGE ON ALL SCHEMAS IN DATABASE dev_analytics TO ROLE developer;
GRANT SELECT ON ALL TABLES IN SCHEMA dev_analytics.public TO ROLE developer;
GRANT SELECT ON ALL VIEWS IN SCHEMA dev_analytics.public TO ROLE developer;
```

#### Example 2: Safe Schema Migration

```sql
-- 1. Clone production table
CREATE TABLE customers_v2 CLONE customers;

-- 2. Apply schema changes
ALTER TABLE customers_v2 ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE customers_v2 ADD COLUMN last_login TIMESTAMP;

-- 3. Backfill new columns
UPDATE customers_v2 
SET email_verified = TRUE 
WHERE email IS NOT NULL;

-- 4. Test queries
SELECT * FROM customers_v2 WHERE email_verified = FALSE;

-- 5. If successful, swap tables
ALTER TABLE customers RENAME TO customers_old;
ALTER TABLE customers_v2 RENAME TO customers;

-- 6. Verify
SELECT COUNT(*) FROM customers;

-- 7. Drop old table after verification period
DROP TABLE customers_old;
```

#### Example 3: Data Quality Testing

```sql
-- Clone for data quality checks
CREATE TABLE orders_dq_check CLONE orders;

-- Run data quality tests
SELECT 
  'Null Order IDs' as issue,
  COUNT(*) as count
FROM orders_dq_check
WHERE order_id IS NULL
UNION ALL
SELECT 
  'Negative Amounts' as issue,
  COUNT(*) as count
FROM orders_dq_check
WHERE amount < 0
UNION ALL
SELECT 
  'Future Dates' as issue,
  COUNT(*) as count
FROM orders_dq_check
WHERE order_date > CURRENT_DATE();

-- Fix issues in clone
DELETE FROM orders_dq_check WHERE order_id IS NULL;
UPDATE orders_dq_check SET amount = ABS(amount) WHERE amount < 0;

-- If fixes work, apply to source
-- (repeat fixes on source table)

-- Cleanup
DROP TABLE orders_dq_check;
```

#### Example 4: Automated Backup Strategy

```sql
-- Create backup procedure
CREATE OR REPLACE PROCEDURE create_daily_backup()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  backup_name STRING;
  result STRING;
BEGIN
  -- Generate backup name with date
  backup_name := 'PROD_DB_BACKUP_' || TO_CHAR(CURRENT_DATE(), 'YYYYMMDD');
  
  -- Create clone
  EXECUTE IMMEDIATE 'CREATE DATABASE ' || backup_name || ' CLONE PROD_DB';
  
  result := 'Backup created: ' || backup_name;
  RETURN result;
END;
$$;

-- Schedule with task
CREATE OR REPLACE TASK daily_backup_task
  WAREHOUSE = backup_wh
  SCHEDULE = 'USING CRON 0 2 * * * America/New_York'  -- 2 AM daily
AS
  CALL create_daily_backup();

-- Enable task
ALTER TASK daily_backup_task RESUME;
```

#### Example 5: A/B Testing

```sql
-- Clone for A/B test
CREATE TABLE customers_test_group_a CLONE customers;
CREATE TABLE customers_test_group_b CLONE customers;

-- Apply different strategies
-- Group A: 10% discount
UPDATE customers_test_group_a 
SET discount_rate = 0.10 
WHERE segment = 'PREMIUM';

-- Group B: 15% discount
UPDATE customers_test_group_b 
SET discount_rate = 0.15 
WHERE segment = 'PREMIUM';

-- Simulate and compare results
SELECT 'Group A' as test_group, 
       SUM(projected_revenue) as revenue
FROM customers_test_group_a
UNION ALL
SELECT 'Group B' as test_group,
       SUM(projected_revenue) as revenue
FROM customers_test_group_b;

-- Cleanup
DROP TABLE customers_test_group_a;
DROP TABLE customers_test_group_b;
```

### Best Practices

#### 1. Use Clones for Non-Production

```sql
-- Good: Clone for development
CREATE DATABASE dev_db CLONE prod_db;

-- Good: Clone for testing
CREATE TABLE test_orders CLONE orders;

-- Avoid: Cloning in production for regular operations
-- (use views or materialized views instead)
```

#### 2. Clean Up Unused Clones

```sql
-- List all clones
SELECT 
  table_catalog,
  table_schema,
  table_name,
  created,
  last_altered,
  bytes / 1024 / 1024 / 1024 as size_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE is_clone = 'YES'
  AND deleted IS NULL
ORDER BY last_altered;

-- Drop old clones
DROP TABLE old_test_clone;
DROP DATABASE old_dev_db;
```

#### 3. Document Clone Purpose

```sql
-- Add comments to clones
CREATE TABLE orders_clone CLONE orders;
COMMENT ON TABLE orders_clone IS 
  'Clone for testing new ETL logic. Created: 2024-01-15. Owner: data_team';

-- View comments
SHOW TABLES LIKE '%clone%';
```

#### 4. Combine with Time Travel

```sql
-- Clone from specific point for investigation
CREATE TABLE orders_incident_investigation CLONE orders
AT(TIMESTAMP => '2024-01-15 14:30:00'::TIMESTAMP);

COMMENT ON TABLE orders_incident_investigation IS
  'Clone from incident time for root cause analysis. Ticket: INC-12345';
```

#### 5. Automate Clone Lifecycle

```sql
-- Create clone with expiration
CREATE TABLE temp_analysis_clone CLONE large_table;

-- Set reminder to drop (use external scheduler)
-- Or create task to auto-drop after N days

CREATE OR REPLACE TASK cleanup_old_clones
  WAREHOUSE = admin_wh
  SCHEDULE = 'USING CRON 0 3 * * * America/New_York'
AS
  -- Drop clones older than 7 days
  DECLARE
    clone_name STRING;
  BEGIN
    FOR clone_name IN (
      SELECT table_name 
      FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
      WHERE is_clone = 'YES'
        AND table_name LIKE '%_clone'
        AND DATEDIFF(day, created, CURRENT_TIMESTAMP()) > 7
    ) DO
      EXECUTE IMMEDIATE 'DROP TABLE IF EXISTS ' || clone_name;
    END FOR;
  END;
```

### Limitations

**Cannot Clone**:
- External tables
- Temporary tables
- Transient tables to permanent (or vice versa)
- Tables with active streams (streams must be recreated)
- Cross-region (must be in same region)
- Cross-cloud (must be on same cloud platform)

**Performance Considerations**:
- Cloning is instant regardless of size
- First queries on clone may be slower (metadata loading)
- Modifications trigger copy-on-write (slight overhead)

### Troubleshooting

#### Issue 1: Clone Fails with "Object Does Not Exist"

**Cause**: Source object dropped or insufficient privileges

**Solution**:
```sql
-- Check if source exists
SHOW TABLES LIKE 'source_table';

-- Check privileges
SHOW GRANTS ON TABLE source_table;

-- Need SELECT privilege to clone
GRANT SELECT ON TABLE source_table TO ROLE my_role;
```

#### Issue 2: Unexpected Storage Costs

**Cause**: Clones diverging significantly from source

**Solution**:
```sql
-- Monitor clone storage
SELECT 
  table_name,
  active_bytes / 1024 / 1024 / 1024 as active_gb,
  clone_group_id
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE is_clone = 'YES'
ORDER BY active_bytes DESC;

-- Drop unnecessary clones
DROP TABLE expensive_clone;
```

#### Issue 3: Cannot Clone with Time Travel

**Cause**: Outside retention period

**Solution**:
```sql
-- Check retention period
SHOW TABLES LIKE 'source_table';
-- Look at RETENTION_TIME column

-- Check if timestamp is within retention
SELECT DATEDIFF(day, '2024-01-15'::DATE, CURRENT_DATE()) as days_ago;

-- If within retention, clone should work
CREATE TABLE my_clone CLONE source_table
AT(TIMESTAMP => '2024-01-15 00:00:00'::TIMESTAMP);
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Basic Cloning
Clone tables, schemas, and databases.

### Exercise 2: Clone with Time Travel
Create clones from historical points.

### Exercise 3: Development Environment
Set up complete dev environment using clones.

### Exercise 4: Schema Migration Testing
Test schema changes safely with clones.

### Exercise 5: Data Recovery
Use cloning for data recovery scenarios.

### Exercise 6: Storage Analysis
Monitor and analyze clone storage.

### Exercise 7: Automated Backup
Create automated backup strategy with clones.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Zero-copy cloning creates instant copies without duplicating data
- Clones share micro-partitions with source initially
- Storage increases only when data diverges (copy-on-write)
- Can clone databases, schemas, and tables
- Combine cloning with Time Travel for point-in-time copies
- Perfect for dev/test environments, backups, and testing
- Clones are independent - changes don't affect source
- Metadata and structure are cloned, but not streams/tasks/pipes
- Clean up unused clones to manage storage costs
- Cloning is instant regardless of data size

---

## 📚 Additional Resources

- [Snowflake Docs: Cloning](https://docs.snowflake.com/en/user-guide/tables-storage-considerations#label-cloning-tables)
- [Zero-Copy Cloning](https://docs.snowflake.com/en/user-guide/object-clone)
- [Storage Costs](https://docs.snowflake.com/en/user-guide/tables-storage-considerations)

---

## 🔜 Tomorrow: Day 21 - Week 3 Review & Governance Lab

We'll review all Week 3 concepts and build a comprehensive security and governance implementation.
