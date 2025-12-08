/*
Day 19: Time Travel & Fail-Safe - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
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

-- Wait a moment, then make changes
SELECT SYSTEM$WAIT(5);  -- Wait 5 seconds

-- Update some records
UPDATE customers SET total_orders = 30 WHERE customer_id = 1;
UPDATE customers SET region = 'CENTRAL' WHERE customer_id = 3;

-- Wait again
SELECT SYSTEM$WAIT(5);

-- Delete a record
DELETE FROM customers WHERE customer_id = 5;


-- ============================================================================
-- Exercise 1: Query Historical Data (10 min)
-- ============================================================================

-- TODO: Query current data
-- SELECT * FROM customers ORDER BY customer_id;

-- TODO: Query data from 10 seconds ago
-- SELECT * FROM customers
-- AT(OFFSET => -10)
-- ORDER BY customer_id;

-- TODO: Get current timestamp
-- SELECT CURRENT_TIMESTAMP();

-- TODO: Query data at specific timestamp (use timestamp from above)
-- SELECT * FROM customers
-- AT(TIMESTAMP => '2024-12-08 10:00:00'::TIMESTAMP)
-- ORDER BY customer_id;

-- TODO: Find query ID of the DELETE statement
-- SELECT query_id, query_text, start_time
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%DELETE FROM customers%'
-- ORDER BY start_time DESC
-- LIMIT 1;

-- TODO: Query data before the DELETE (use query_id from above)
-- SELECT * FROM customers
-- BEFORE(STATEMENT => '<query_id>')
-- ORDER BY customer_id;


-- ============================================================================
-- Exercise 2: Recover Deleted Data (10 min)
-- ============================================================================

-- TODO: Verify customer_id 5 is deleted
-- SELECT * FROM customers WHERE customer_id = 5;

-- TODO: Get query ID of DELETE statement
-- SELECT query_id
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%DELETE FROM customers WHERE customer_id = 5%'
-- ORDER BY start_time DESC
-- LIMIT 1;

-- TODO: Restore the deleted record
-- INSERT INTO customers
-- SELECT * FROM customers
-- BEFORE(STATEMENT => '<query_id>')
-- WHERE customer_id = 5;

-- TODO: Verify restoration
-- SELECT * FROM customers WHERE customer_id = 5;

-- TODO: Alternative: Restore entire table to before delete
-- CREATE OR REPLACE TABLE customers AS
-- SELECT * FROM customers
-- BEFORE(STATEMENT => '<query_id>');

-- TODO: Verify all data restored
-- SELECT * FROM customers ORDER BY customer_id;


-- ============================================================================
-- Exercise 3: Undrop Objects (5 min)
-- ============================================================================

-- TODO: Create a test table
-- CREATE TABLE test_table (
--   id INT,
--   description STRING
-- );

-- TODO: Insert data
-- INSERT INTO test_table VALUES (1, 'Test record 1'), (2, 'Test record 2');

-- TODO: Drop the table
-- DROP TABLE test_table;

-- TODO: Verify table is dropped
-- SHOW TABLES LIKE 'test_table';

-- TODO: Undrop the table
-- UNDROP TABLE test_table;

-- TODO: Verify table is restored
-- SELECT * FROM test_table;

-- TODO: Test schema undrop
-- CREATE SCHEMA test_schema;
-- CREATE TABLE test_schema.test_data (id INT);
-- DROP SCHEMA test_schema;
-- UNDROP SCHEMA test_schema;
-- SHOW SCHEMAS LIKE 'test_schema';


-- ============================================================================
-- Exercise 4: Clone Historical Data (10 min)
-- ============================================================================

-- TODO: Clone current table
-- CREATE TABLE customers_current CLONE customers;

-- TODO: Clone table from 30 seconds ago
-- CREATE TABLE customers_30sec_ago CLONE customers
-- AT(OFFSET => -30);

-- TODO: Clone table at specific timestamp
-- CREATE TABLE customers_snapshot CLONE customers
-- AT(TIMESTAMP => '<timestamp>');

-- TODO: Clone before a specific statement
-- CREATE TABLE customers_before_delete CLONE customers
-- BEFORE(STATEMENT => '<query_id>');

-- TODO: Compare clones
-- SELECT 'Current' as version, COUNT(*) as record_count FROM customers_current
-- UNION ALL
-- SELECT '30 seconds ago', COUNT(*) FROM customers_30sec_ago
-- UNION ALL
-- SELECT 'Before delete', COUNT(*) FROM customers_before_delete;

-- TODO: View differences
-- SELECT * FROM customers_before_delete
-- MINUS
-- SELECT * FROM customers_current;


-- ============================================================================
-- Exercise 5: Audit Data Changes (5 min)
-- ============================================================================

-- TODO: Find records added in last minute
-- SELECT 
--   'Added' as change_type,
--   *
-- FROM customers
-- WHERE customer_id NOT IN (
--   SELECT customer_id FROM customers
--   AT(OFFSET => -60)
-- );

-- TODO: Find records removed in last minute
-- SELECT 
--   'Removed' as change_type,
--   *
-- FROM customers
-- AT(OFFSET => -60)
-- WHERE customer_id NOT IN (
--   SELECT customer_id FROM customers
-- );

-- TODO: Find records modified in last minute
-- SELECT 
--   c.customer_id,
--   c.customer_name,
--   c.total_orders as current_orders,
--   h.total_orders as previous_orders,
--   c.total_orders - h.total_orders as change
-- FROM customers c
-- JOIN customers AT(OFFSET => -60) h
--   ON c.customer_id = h.customer_id
-- WHERE c.total_orders != h.total_orders;

-- TODO: Create audit log
-- CREATE TABLE customer_audit_log AS
-- SELECT 
--   CURRENT_TIMESTAMP() as audit_time,
--   'MODIFIED' as change_type,
--   c.customer_id,
--   h.total_orders as old_value,
--   c.total_orders as new_value
-- FROM customers c
-- JOIN customers AT(OFFSET => -60) h
--   ON c.customer_id = h.customer_id
-- WHERE c.total_orders != h.total_orders;


-- ============================================================================
-- Exercise 6: Configure Retention Periods (5 min)
-- ============================================================================

-- TODO: Check current retention settings
-- SHOW TABLES;
-- -- Look at RETENTION_TIME column

-- TODO: Set retention at table level
-- ALTER TABLE customers SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- TODO: Create table with specific retention
-- CREATE TABLE short_retention_table (
--   id INT,
--   data STRING
-- ) DATA_RETENTION_TIME_IN_DAYS = 1;

-- TODO: Create transient table (no Fail-Safe)
-- CREATE TRANSIENT TABLE staging_data (
--   id INT,
--   data STRING,
--   load_date DATE
-- ) DATA_RETENTION_TIME_IN_DAYS = 1;

-- TODO: Create temporary table (no Time Travel or Fail-Safe)
-- CREATE TEMPORARY TABLE temp_processing (
--   id INT,
--   data STRING
-- );

-- TODO: View retention settings
-- SELECT 
--   table_name,
--   table_type,
--   retention_time
-- FROM INFORMATION_SCHEMA.TABLES
-- WHERE table_schema = 'DAY19_TIME_TRAVEL'
-- ORDER BY table_name;


-- ============================================================================
-- Exercise 7: Monitor Storage (5 min)
-- ============================================================================

-- TODO: View storage metrics
-- SELECT 
--   table_name,
--   active_bytes / 1024 / 1024 as active_mb,
--   time_travel_bytes / 1024 / 1024 as time_travel_mb,
--   failsafe_bytes / 1024 / 1024 as failsafe_mb,
--   (active_bytes + time_travel_bytes + failsafe_bytes) / 1024 / 1024 as total_mb
-- FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
-- WHERE table_catalog = 'BOOTCAMP_DB'
--   AND table_schema = 'DAY19_TIME_TRAVEL'
--   AND deleted IS NULL
-- ORDER BY total_mb DESC;

-- TODO: Calculate storage overhead
-- SELECT 
--   table_name,
--   active_bytes / 1024 / 1024 as active_mb,
--   (time_travel_bytes + failsafe_bytes) / 1024 / 1024 as overhead_mb,
--   ROUND((time_travel_bytes + failsafe_bytes) / 
--     NULLIF(active_bytes, 0) * 100, 2) as overhead_pct
-- FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
-- WHERE table_catalog = 'BOOTCAMP_DB'
--   AND table_schema = 'DAY19_TIME_TRAVEL'
--   AND deleted IS NULL
-- ORDER BY overhead_pct DESC;

-- TODO: Create storage monitoring view
-- CREATE OR REPLACE VIEW storage_monitor AS
-- SELECT 
--   table_catalog,
--   table_schema,
--   table_name,
--   ROUND(active_bytes / 1024 / 1024 / 1024, 2) as active_gb,
--   ROUND(time_travel_bytes / 1024 / 1024 / 1024, 2) as time_travel_gb,
--   ROUND(failsafe_bytes / 1024 / 1024 / 1024, 2) as failsafe_gb,
--   ROUND((time_travel_bytes + failsafe_bytes) / 
--     NULLIF(active_bytes, 0) * 100, 2) as overhead_pct
-- FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
-- WHERE deleted IS NULL
-- ORDER BY time_travel_bytes + failsafe_bytes DESC;

-- TODO: Query monitoring view
-- SELECT * FROM storage_monitor
-- WHERE table_schema = 'DAY19_TIME_TRAVEL';


-- ============================================================================
-- Bonus: Advanced Time Travel Patterns (Optional)
-- ============================================================================

-- TODO: Point-in-time reporting
-- SELECT 
--   region,
--   COUNT(*) as customer_count,
--   SUM(total_orders) as total_orders
-- FROM customers
-- AT(TIMESTAMP => '<specific_timestamp>')
-- GROUP BY region;

-- TODO: Track changes over time
-- WITH snapshots AS (
--   SELECT 'Now' as snapshot, COUNT(*) as count FROM customers
--   UNION ALL
--   SELECT '1 min ago', COUNT(*) FROM customers AT(OFFSET => -60)
--   UNION ALL
--   SELECT '2 min ago', COUNT(*) FROM customers AT(OFFSET => -120)
-- )
-- SELECT * FROM snapshots;

-- TODO: Create change history table
-- CREATE TABLE customer_change_history AS
-- SELECT 
--   CURRENT_TIMESTAMP() as snapshot_time,
--   customer_id,
--   customer_name,
--   total_orders,
--   region
-- FROM customers;

-- TODO: Restore specific columns
-- UPDATE customers c
-- SET total_orders = (
--   SELECT total_orders 
--   FROM customers AT(OFFSET => -60) h
--   WHERE h.customer_id = c.customer_id
-- )
-- WHERE customer_id = 1;


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
