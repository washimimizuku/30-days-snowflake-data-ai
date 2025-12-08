/*
Day 19: Time Travel & Fail-Safe - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
-- ============================================================================

USE ROLE ACCOUNTADMIN;

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY19_TIME_TRAVEL;
USE SCHEMA DAY19_TIME_TRAVEL;

-- Create sample table
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  region VARCHAR(50),
  total_orders INT,
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Insert initial data
INSERT INTO customers (customer_id, customer_name, email, region, total_orders) VALUES
  (1, 'Acme Corp', 'acme@example.com', 'NORTH', 25),
  (2, 'Beta Inc', 'beta@example.com', 'SOUTH', 18),
  (3, 'Gamma LLC', 'gamma@example.com', 'EAST', 32),
  (4, 'Delta Co', 'delta@example.com', 'WEST', 15),
  (5, 'Epsilon Ltd', 'epsilon@example.com', 'NORTH', 28);

-- Record timestamp for later use
SELECT CURRENT_TIMESTAMP() as initial_timestamp;

-- Wait a moment, then make changes
SELECT SYSTEM$WAIT(5);

-- Update some records
UPDATE customers SET total_orders = 30 WHERE customer_id = 1;
UPDATE customers SET region = 'CENTRAL' WHERE customer_id = 3;

-- Wait again
SELECT SYSTEM$WAIT(5);

-- Delete a record
DELETE FROM customers WHERE customer_id = 5;


-- ============================================================================
-- Exercise 1: Query Historical Data
-- ============================================================================

-- Query current data
SELECT * FROM customers ORDER BY customer_id;

-- Query data from 10 seconds ago
SELECT * FROM customers
AT(OFFSET => -10)
ORDER BY customer_id;

-- Get current timestamp
SELECT CURRENT_TIMESTAMP();

-- Query data at specific timestamp
-- Note: Replace with actual timestamp
SELECT * FROM customers
AT(TIMESTAMP => DATEADD(second, -30, CURRENT_TIMESTAMP()))
ORDER BY customer_id;

-- Find query ID of the DELETE statement
SELECT query_id, query_text, start_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%DELETE FROM customers%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 1;

-- Query data before the DELETE
-- Note: Replace <query_id> with actual query ID from above
-- SELECT * FROM customers
-- BEFORE(STATEMENT => '<query_id>')
-- ORDER BY customer_id;


-- ============================================================================
-- Exercise 2: Recover Deleted Data
-- ============================================================================

-- Verify customer_id 5 is deleted
SELECT * FROM customers WHERE customer_id = 5;
-- Should return 0 rows

-- Get query ID of DELETE statement
SELECT query_id, query_text
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%DELETE FROM customers WHERE customer_id = 5%'
ORDER BY start_time DESC
LIMIT 1;

-- Restore the deleted record using Time Travel
-- Method 1: Insert from historical data
INSERT INTO customers
SELECT * FROM customers
AT(OFFSET => -20)  -- Adjust offset as needed
WHERE customer_id = 5;

-- Verify restoration
SELECT * FROM customers WHERE customer_id = 5;

-- Alternative Method 2: Restore entire table
-- Save query ID first
SET delete_query_id = (
  SELECT query_id
  FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
  WHERE query_text ILIKE '%DELETE FROM customers WHERE customer_id = 5%'
  ORDER BY start_time DESC
  LIMIT 1
);

-- Restore entire table to before delete
-- CREATE OR REPLACE TABLE customers AS
-- SELECT * FROM customers
-- BEFORE(STATEMENT => $delete_query_id);

-- Verify all data restored
SELECT * FROM customers ORDER BY customer_id;


-- ============================================================================
-- Exercise 3: Undrop Objects
-- ============================================================================

-- Create a test table
CREATE TABLE test_table (
  id INT,
  description STRING
);

-- Insert data
INSERT INTO test_table VALUES (1, 'Test record 1'), (2, 'Test record 2');

-- Verify data
SELECT * FROM test_table;

-- Drop the table
DROP TABLE test_table;

-- Verify table is dropped
SHOW TABLES LIKE 'test_table';

-- Undrop the table
UNDROP TABLE test_table;

-- Verify table is restored
SELECT * FROM test_table;

-- Test schema undrop
CREATE SCHEMA test_schema;
CREATE TABLE test_schema.test_data (id INT);
INSERT INTO test_schema.test_data VALUES (1), (2), (3);

-- Drop schema
DROP SCHEMA test_schema;

-- Undrop schema
UNDROP SCHEMA test_schema;

-- Verify schema restored
SHOW SCHEMAS LIKE 'test_schema';
SELECT * FROM test_schema.test_data;


-- ============================================================================
-- Exercise 4: Clone Historical Data
-- ============================================================================

-- Clone current table
CREATE TABLE customers_current CLONE customers;

-- Clone table from 30 seconds ago
CREATE TABLE customers_30sec_ago CLONE customers
AT(OFFSET => -30);

-- Clone table at specific timestamp
CREATE TABLE customers_snapshot CLONE customers
AT(TIMESTAMP => DATEADD(minute, -1, CURRENT_TIMESTAMP()));

-- Clone before a specific statement (before DELETE)
-- CREATE TABLE customers_before_delete CLONE customers
-- BEFORE(STATEMENT => '<query_id>');

-- Compare clones
SELECT 'Current' as version, COUNT(*) as record_count FROM customers_current
UNION ALL
SELECT '30 seconds ago', COUNT(*) FROM customers_30sec_ago
UNION ALL
SELECT 'Snapshot', COUNT(*) FROM customers_snapshot;

-- View differences between current and historical
SELECT * FROM customers_30sec_ago
MINUS
SELECT * FROM customers_current;

-- View what was added
SELECT * FROM customers_current
MINUS
SELECT * FROM customers_30sec_ago;


-- ============================================================================
-- Exercise 5: Audit Data Changes
-- ============================================================================

-- Find records added in last minute
SELECT 
  'Added' as change_type,
  *
FROM customers
WHERE customer_id NOT IN (
  SELECT customer_id FROM customers
  AT(OFFSET => -60)
);

-- Find records removed in last minute
SELECT 
  'Removed' as change_type,
  *
FROM customers
AT(OFFSET => -60)
WHERE customer_id NOT IN (
  SELECT customer_id FROM customers
);

-- Find records modified in last minute
SELECT 
  c.customer_id,
  c.customer_name,
  c.total_orders as current_orders,
  h.total_orders as previous_orders,
  c.total_orders - h.total_orders as change,
  c.region as current_region,
  h.region as previous_region
FROM customers c
JOIN customers AT(OFFSET => -60) h
  ON c.customer_id = h.customer_id
WHERE c.total_orders != h.total_orders
   OR c.region != h.region;

-- Create audit log
CREATE TABLE customer_audit_log AS
SELECT 
  CURRENT_TIMESTAMP() as audit_time,
  'MODIFIED' as change_type,
  c.customer_id,
  c.customer_name,
  h.total_orders as old_value,
  c.total_orders as new_value,
  h.region as old_region,
  c.region as new_region
FROM customers c
JOIN customers AT(OFFSET => -60) h
  ON c.customer_id = h.customer_id
WHERE c.total_orders != h.total_orders
   OR c.region != h.region;

-- View audit log
SELECT * FROM customer_audit_log;


-- ============================================================================
-- Exercise 6: Configure Retention Periods
-- ============================================================================

-- Check current retention settings
SHOW TABLES;

-- Set retention at table level
ALTER TABLE customers SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- Verify change
SHOW TABLES LIKE 'customers';

-- Create table with specific retention
CREATE TABLE short_retention_table (
  id INT,
  data STRING
) DATA_RETENTION_TIME_IN_DAYS = 1
COMMENT = 'Table with 1-day retention for temporary data';

-- Create transient table (no Fail-Safe, lower storage cost)
CREATE TRANSIENT TABLE staging_data (
  id INT,
  data STRING,
  load_date DATE
) DATA_RETENTION_TIME_IN_DAYS = 1
COMMENT = 'Transient table for ETL staging';

-- Insert test data
INSERT INTO staging_data VALUES 
  (1, 'Staging record 1', CURRENT_DATE()),
  (2, 'Staging record 2', CURRENT_DATE());

-- Create temporary table (no Time Travel or Fail-Safe)
CREATE TEMPORARY TABLE temp_processing (
  id INT,
  data STRING
);

-- Insert test data
INSERT INTO temp_processing VALUES (1, 'Temp data');

-- View retention settings
SELECT 
  table_name,
  table_type,
  retention_time,
  comment
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'DAY19_TIME_TRAVEL'
ORDER BY table_name;


-- ============================================================================
-- Exercise 7: Monitor Storage
-- ============================================================================

-- View storage metrics
SELECT 
  table_name,
  ROUND(active_bytes / 1024 / 1024, 2) as active_mb,
  ROUND(time_travel_bytes / 1024 / 1024, 2) as time_travel_mb,
  ROUND(failsafe_bytes / 1024 / 1024, 2) as failsafe_mb,
  ROUND((active_bytes + time_travel_bytes + failsafe_bytes) / 1024 / 1024, 2) as total_mb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'BOOTCAMP_DB'
  AND table_schema = 'DAY19_TIME_TRAVEL'
  AND deleted IS NULL
ORDER BY total_mb DESC;

-- Calculate storage overhead
SELECT 
  table_name,
  ROUND(active_bytes / 1024 / 1024, 2) as active_mb,
  ROUND((time_travel_bytes + failsafe_bytes) / 1024 / 1024, 2) as overhead_mb,
  ROUND((time_travel_bytes + failsafe_bytes) / 
    NULLIF(active_bytes, 0) * 100, 2) as overhead_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'BOOTCAMP_DB'
  AND table_schema = 'DAY19_TIME_TRAVEL'
  AND deleted IS NULL
ORDER BY overhead_pct DESC;

-- Create comprehensive storage monitoring view
CREATE OR REPLACE VIEW storage_monitor AS
SELECT 
  table_catalog,
  table_schema,
  table_name,
  ROUND(active_bytes / 1024 / 1024 / 1024, 2) as active_gb,
  ROUND(time_travel_bytes / 1024 / 1024 / 1024, 2) as time_travel_gb,
  ROUND(failsafe_bytes / 1024 / 1024 / 1024, 2) as failsafe_gb,
  ROUND((active_bytes + time_travel_bytes + failsafe_bytes) / 1024 / 1024 / 1024, 2) as total_gb,
  ROUND((time_travel_bytes + failsafe_bytes) / 
    NULLIF(active_bytes, 0) * 100, 2) as overhead_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE deleted IS NULL
ORDER BY time_travel_bytes + failsafe_bytes DESC;

-- Query monitoring view
SELECT * FROM storage_monitor
WHERE table_schema = 'DAY19_TIME_TRAVEL';


-- ============================================================================
-- Bonus: Advanced Time Travel Patterns
-- ============================================================================

-- Point-in-time reporting
SELECT 
  region,
  COUNT(*) as customer_count,
  SUM(total_orders) as total_orders,
  AVG(total_orders) as avg_orders
FROM customers
AT(OFFSET => -30)
GROUP BY region
ORDER BY total_orders DESC;

-- Track changes over time
WITH snapshots AS (
  SELECT 'Now' as snapshot, COUNT(*) as count, SUM(total_orders) as total FROM customers
  UNION ALL
  SELECT '30 sec ago', COUNT(*), SUM(total_orders) FROM customers AT(OFFSET => -30)
  UNION ALL
  SELECT '60 sec ago', COUNT(*), SUM(total_orders) FROM customers AT(OFFSET => -60)
)
SELECT * FROM snapshots;

-- Create change history table
CREATE TABLE customer_change_history AS
SELECT 
  CURRENT_TIMESTAMP() as snapshot_time,
  customer_id,
  customer_name,
  total_orders,
  region
FROM customers;

-- Restore specific columns from historical data
-- Example: Restore total_orders for customer_id 1
UPDATE customers c
SET total_orders = (
  SELECT total_orders 
  FROM customers AT(OFFSET => -60) h
  WHERE h.customer_id = c.customer_id
)
WHERE customer_id = 1;

-- Verify restoration
SELECT * FROM customers WHERE customer_id = 1;

-- Best practices summary
SELECT 
  'Time Travel Best Practices' as category,
  'Set appropriate retention periods' as practice,
  'Balance recovery needs vs. storage costs' as benefit
UNION ALL
SELECT 'Time Travel', 'Use transient tables for staging', 'No Fail-Safe, lower costs'
UNION ALL
SELECT 'Time Travel', 'Use temporary tables for session data', 'No Time Travel or Fail-Safe'
UNION ALL
SELECT 'Time Travel', 'Document important query IDs', 'Easy recovery reference'
UNION ALL
SELECT 'Time Travel', 'Regular recovery testing', 'Verify procedures work'
UNION ALL
SELECT 'Time Travel', 'Monitor storage overhead', 'Control costs'
UNION ALL
SELECT 'Time Travel', 'Clone for testing', 'Safe environment for changes'
UNION ALL
SELECT 'Time Travel', 'Audit data changes', 'Compliance and tracking';


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Drop cloned tables
-- DROP TABLE IF EXISTS customers_current;
-- DROP TABLE IF EXISTS customers_30sec_ago;
-- DROP TABLE IF EXISTS customers_snapshot;
-- DROP TABLE IF EXISTS customers_before_delete;
-- DROP TABLE IF EXISTS test_table;
-- DROP TABLE IF EXISTS short_retention_table;
-- DROP TABLE IF EXISTS staging_data;
-- DROP TABLE IF EXISTS customer_audit_log;
-- DROP TABLE IF EXISTS customer_change_history;

-- Drop schema
-- DROP SCHEMA IF EXISTS test_schema;

-- Drop views
-- DROP VIEW IF EXISTS storage_monitor;

-- Drop main table
-- DROP TABLE IF EXISTS customers;
