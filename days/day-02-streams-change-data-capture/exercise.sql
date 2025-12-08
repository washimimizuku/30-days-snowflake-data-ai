/*
Day 2: Streams for Change Data Capture - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

-- Use bootcamp database and schema
USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY02_STREAMS;
USE SCHEMA DAY02_STREAMS;
USE WAREHOUSE BOOTCAMP_WH;

-- Create source table for customers
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20),
  last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert initial data
INSERT INTO customers (customer_id, customer_name, email, status) VALUES
  (1, 'Alice Johnson', 'alice@example.com', 'active'),
  (2, 'Bob Smith', 'bob@example.com', 'active'),
  (3, 'Carol White', 'carol@example.com', 'inactive');

-- Verify initial data
SELECT * FROM customers;


-- ============================================================================
-- Exercise 1: Create Standard Stream (5 min)
-- ============================================================================

-- TODO: Create a standard stream on the customers table
-- CREATE STREAM customer_stream ON TABLE customers;

-- TODO: Show streams to verify creation
-- SHOW STREAMS;

-- TODO: Describe the stream
-- DESC STREAM customer_stream;

-- TODO: Query the stream (should be empty initially)
-- SELECT * FROM customer_stream;

-- TODO: Check if stream has data
-- SELECT SYSTEM$STREAM_HAS_DATA('customer_stream');


-- ============================================================================
-- Exercise 2: Test INSERT Operations (5 min)
-- ============================================================================

-- TODO: Insert new customers
-- INSERT INTO customers (customer_id, customer_name, email, status) VALUES
--   (4, 'David Brown', 'david@example.com', 'active'),
--   (5, 'Eve Davis', 'eve@example.com', 'active');

-- TODO: Query the stream to see INSERT records
-- SELECT * FROM customer_stream;

-- TODO: Check metadata columns
-- SELECT 
--   METADATA$ACTION,
--   METADATA$ISUPDATE,
--   METADATA$ROW_ID,
--   customer_id,
--   customer_name,
--   email,
--   status
-- FROM customer_stream;

-- TODO: Verify stream has data
-- SELECT SYSTEM$STREAM_HAS_DATA('customer_stream');


-- ============================================================================
-- Exercise 3: Test UPDATE Operations (5 min)
-- ============================================================================

-- TODO: Update a customer's status
-- UPDATE customers 
-- SET status = 'inactive', last_updated = CURRENT_TIMESTAMP()
-- WHERE customer_id = 2;

-- TODO: Query the stream to see UPDATE represented as DELETE + INSERT
-- SELECT 
--   METADATA$ACTION,
--   METADATA$ISUPDATE,
--   customer_id,
--   customer_name,
--   status
-- FROM customer_stream
-- ORDER BY customer_id, METADATA$ACTION;

-- TODO: Count DELETE and INSERT records for the update
-- SELECT 
--   METADATA$ACTION,
--   METADATA$ISUPDATE,
--   COUNT(*) as record_count
-- FROM customer_stream
-- GROUP BY 1, 2;


-- ============================================================================
-- Exercise 4: Test DELETE Operations (5 min)
-- ============================================================================

-- TODO: Delete a customer
-- DELETE FROM customers WHERE customer_id = 3;

-- TODO: Query the stream to see all changes
-- SELECT 
--   METADATA$ACTION,
--   METADATA$ISUPDATE,
--   customer_id,
--   customer_name,
--   status
-- FROM customer_stream
-- ORDER BY customer_id, METADATA$ACTION;

-- TODO: Summarize changes by action type
-- SELECT 
--   METADATA$ACTION,
--   COUNT(*) as count
-- FROM customer_stream
-- GROUP BY 1;


-- ============================================================================
-- Exercise 5: Stream Metadata Analysis (5 min)
-- ============================================================================

-- TODO: Analyze all metadata columns
-- SELECT 
--   METADATA$ACTION as action,
--   METADATA$ISUPDATE as is_update,
--   METADATA$ROW_ID as row_id,
--   customer_id,
--   customer_name,
--   email,
--   status,
--   last_updated
-- FROM customer_stream
-- ORDER BY customer_id;

-- TODO: Identify which records are part of updates
-- SELECT 
--   customer_id,
--   customer_name,
--   METADATA$ACTION,
--   CASE 
--     WHEN METADATA$ISUPDATE = TRUE THEN 'Part of UPDATE'
--     ELSE 'Standalone ' || METADATA$ACTION
--   END as change_type
-- FROM customer_stream
-- ORDER BY customer_id;


-- ============================================================================
-- Exercise 6: Consume Stream (5 min)
-- ============================================================================

-- Create target table for processed changes
CREATE OR REPLACE TABLE customers_history (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20),
  change_action VARCHAR(10),
  change_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- TODO: Consume stream by inserting into history table
-- INSERT INTO customers_history (customer_id, customer_name, email, status, change_action)
-- SELECT 
--   customer_id,
--   customer_name,
--   email,
--   status,
--   METADATA$ACTION
-- FROM customer_stream;

-- TODO: Verify data was inserted
-- SELECT * FROM customers_history ORDER BY change_timestamp;

-- TODO: Query stream again (should be empty now - consumed!)
-- SELECT * FROM customer_stream;

-- TODO: Check if stream has data
-- SELECT SYSTEM$STREAM_HAS_DATA('customer_stream');


-- ============================================================================
-- Exercise 7: Append-Only Stream (5 min)
-- ============================================================================

-- Create events table (append-only by nature)
CREATE OR REPLACE TABLE customer_events (
  event_id INT AUTOINCREMENT,
  customer_id INT,
  event_type VARCHAR(50),
  event_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- TODO: Create append-only stream
-- CREATE STREAM customer_events_stream 
-- ON TABLE customer_events 
-- APPEND_ONLY = TRUE;

-- TODO: Insert events
-- INSERT INTO customer_events (customer_id, event_type) VALUES
--   (1, 'login'),
--   (2, 'purchase'),
--   (1, 'logout');

-- TODO: Query append-only stream
-- SELECT * FROM customer_events_stream;

-- TODO: Try updating an event (stream won't capture it)
-- UPDATE customer_events SET event_type = 'login_updated' WHERE event_id = 1;

-- TODO: Query stream again (UPDATE not captured in append-only)
-- SELECT * FROM customer_events_stream;

-- TODO: Insert more events
-- INSERT INTO customer_events (customer_id, event_type) VALUES
--   (3, 'login'),
--   (3, 'view_product');

-- TODO: Query stream (only new INSERTs visible)
-- SELECT * FROM customer_events_stream;


-- ============================================================================
-- Exercise 8: Build CDC Pipeline with MERGE (10 min)
-- ============================================================================

-- Create target table (replica of customers)
CREATE OR REPLACE TABLE customers_replica (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20),
  last_updated TIMESTAMP_NTZ
);

-- Initial load
INSERT INTO customers_replica 
SELECT customer_id, customer_name, email, status, last_updated 
FROM customers;

-- Recreate stream (since we consumed it earlier)
CREATE OR REPLACE STREAM customer_stream ON TABLE customers;

-- Make some changes to source
INSERT INTO customers (customer_id, customer_name, email, status) VALUES
  (6, 'Frank Miller', 'frank@example.com', 'active');

UPDATE customers 
SET status = 'active', last_updated = CURRENT_TIMESTAMP()
WHERE customer_id = 1;

DELETE FROM customers WHERE customer_id = 5;

-- TODO: View changes in stream
-- SELECT 
--   METADATA$ACTION,
--   METADATA$ISUPDATE,
--   customer_id,
--   customer_name,
--   status
-- FROM customer_stream
-- ORDER BY customer_id;

-- TODO: Use MERGE to sync changes to replica
-- MERGE INTO customers_replica AS target
-- USING (
--   SELECT 
--     customer_id,
--     customer_name,
--     email,
--     status,
--     last_updated,
--     METADATA$ACTION,
--     METADATA$ISUPDATE
--   FROM customer_stream
-- ) AS source
-- ON target.customer_id = source.customer_id
-- WHEN MATCHED AND source.METADATA$ACTION = 'DELETE' AND source.METADATA$ISUPDATE = FALSE THEN
--   DELETE
-- WHEN MATCHED AND source.METADATA$ACTION = 'INSERT' AND source.METADATA$ISUPDATE = TRUE THEN
--   UPDATE SET
--     target.customer_name = source.customer_name,
--     target.email = source.email,
--     target.status = source.status,
--     target.last_updated = source.last_updated
-- WHEN NOT MATCHED AND source.METADATA$ACTION = 'INSERT' THEN
--   INSERT (customer_id, customer_name, email, status, last_updated)
--   VALUES (source.customer_id, source.customer_name, source.email, source.status, source.last_updated);

-- TODO: Verify replica matches source
-- SELECT 'Source' as table_name, * FROM customers
-- UNION ALL
-- SELECT 'Replica' as table_name, * FROM customers_replica
-- ORDER BY table_name, customer_id;

-- TODO: Check stream is consumed
-- SELECT * FROM customer_stream;


-- ============================================================================
-- Bonus Challenge: SCD Type 2 with Streams
-- ============================================================================

-- Create SCD Type 2 dimension table
CREATE OR REPLACE TABLE dim_customers (
  surrogate_key INT AUTOINCREMENT,
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20),
  valid_from TIMESTAMP_NTZ,
  valid_to TIMESTAMP_NTZ,
  is_current BOOLEAN,
  PRIMARY KEY (surrogate_key)
);

-- TODO: Initial load with current records
-- INSERT INTO dim_customers (customer_id, customer_name, email, status, valid_from, valid_to, is_current)
-- SELECT 
--   customer_id,
--   customer_name,
--   email,
--   status,
--   last_updated as valid_from,
--   '9999-12-31'::TIMESTAMP_NTZ as valid_to,
--   TRUE as is_current
-- FROM customers;

-- Recreate stream for SCD processing
CREATE OR REPLACE STREAM customer_stream ON TABLE customers;

-- Make a change
UPDATE customers 
SET status = 'inactive', last_updated = CURRENT_TIMESTAMP()
WHERE customer_id = 4;

-- TODO: Process SCD Type 2 changes
-- Step 1: Close out old records
-- UPDATE dim_customers
-- SET 
--   valid_to = CURRENT_TIMESTAMP(),
--   is_current = FALSE
-- WHERE customer_id IN (
--   SELECT DISTINCT customer_id 
--   FROM customer_stream 
--   WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE
-- )
-- AND is_current = TRUE;

-- Step 2: Insert new versions
-- INSERT INTO dim_customers (customer_id, customer_name, email, status, valid_from, valid_to, is_current)
-- SELECT 
--   customer_id,
--   customer_name,
--   email,
--   status,
--   CURRENT_TIMESTAMP() as valid_from,
--   '9999-12-31'::TIMESTAMP_NTZ as valid_to,
--   TRUE as is_current
-- FROM customer_stream
-- WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE;

-- TODO: View SCD Type 2 history
-- SELECT * FROM dim_customers ORDER BY customer_id, valid_from;


-- ============================================================================
-- Monitoring and Troubleshooting
-- ============================================================================

-- TODO: Show all streams in schema
-- SHOW STREAMS IN SCHEMA DAY02_STREAMS;

-- TODO: Check stream status
-- SELECT 
--   "name" as stream_name,
--   "table_name",
--   "type",
--   "stale",
--   "mode"
-- FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- TODO: View stream dependencies
-- SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STREAMS
-- WHERE STREAM_SCHEMA = 'DAY02_STREAMS'
-- ORDER BY CREATED;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- TODO: Drop streams
-- DROP STREAM IF EXISTS customer_stream;
-- DROP STREAM IF EXISTS customer_events_stream;

-- TODO: Drop tables
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS customers_history;
-- DROP TABLE IF EXISTS customers_replica;
-- DROP TABLE IF EXISTS customer_events;
-- DROP TABLE IF EXISTS dim_customers;
