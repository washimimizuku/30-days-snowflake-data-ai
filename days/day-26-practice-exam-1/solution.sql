/*******************************************************************************
 * Day 26: Practice Exam 1 - Solution
 * 
 * This file contains example implementations for reviewing exam concepts
 * 
 *******************************************************************************/

/*******************************************************************************
 * SOLUTION: Post-Exam Review Queries
 * 
 * These queries demonstrate concepts from the practice exam
 *******************************************************************************/

-- Setup
USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS exam_review;
USE DATABASE exam_review;
CREATE SCHEMA IF NOT EXISTS review;
USE SCHEMA review;
CREATE WAREHOUSE IF NOT EXISTS review_wh WITH WAREHOUSE_SIZE = 'XSMALL';
USE WAREHOUSE review_wh;

/*******************************************************************************
 * TOPIC 1: Streams and Change Data Capture
 *******************************************************************************/

-- Create a sample table
CREATE OR REPLACE TABLE orders (
  order_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  order_date DATE,
  status STRING
);

-- Create a stream to track changes
CREATE OR REPLACE STREAM orders_stream ON TABLE orders;

-- Insert initial data
INSERT INTO orders VALUES
  (1, 101, 99.99, '2024-01-15', 'COMPLETED'),
  (2, 102, 149.99, '2024-01-15', 'PENDING'),
  (3, 103, 299.99, '2024-01-16', 'COMPLETED');

-- Query the stream (shows all rows as INSERT since SHOW_INITIAL_ROWS defaults to FALSE)
SELECT * FROM orders_stream;

-- Check if stream has data
SELECT SYSTEM$STREAM_HAS_DATA('orders_stream');

-- Update a row
UPDATE orders SET status = 'SHIPPED' WHERE order_id = 2;

-- Stream now shows the change (DELETE of old state, INSERT of new state)
SELECT 
  order_id,
  amount,
  status,
  METADATA$ACTION,
  METADATA$ISUPDATE,
  METADATA$ROW_ID
FROM orders_stream;

-- Consume the stream
CREATE OR REPLACE TABLE orders_history AS
SELECT * FROM orders_stream;

-- Stream is now empty after consumption
SELECT * FROM orders_stream;

/*******************************************************************************
 * TOPIC 2: Tasks and Orchestration
 *******************************************************************************/

-- Create a log table
CREATE OR REPLACE TABLE task_execution_log (
  execution_time TIMESTAMP,
  message STRING
);

-- Create a simple task
CREATE OR REPLACE TASK log_task
  WAREHOUSE = review_wh
  SCHEDULE = '5 MINUTE'
AS
  INSERT INTO task_execution_log 
  VALUES (CURRENT_TIMESTAMP(), 'Task executed successfully');

-- Create a task that depends on a stream
CREATE OR REPLACE TASK process_orders_task
  WAREHOUSE = review_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
AS
  INSERT INTO orders_history
  SELECT * FROM orders_stream;

-- Show tasks
SHOW TASKS;

-- Resume tasks (required for them to run)
ALTER TASK log_task RESUME;
ALTER TASK process_orders_task RESUME;

-- Check task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name IN ('LOG_TASK', 'PROCESS_ORDERS_TASK')
ORDER BY scheduled_time DESC
LIMIT 10;

-- Suspend tasks (to stop them)
ALTER TASK log_task SUSPEND;
ALTER TASK process_orders_task SUSPEND;

/*******************************************************************************
 * TOPIC 3: Clustering and Performance
 *******************************************************************************/

-- Create a table with clustering
CREATE OR REPLACE TABLE sales (
  sale_id INT,
  sale_date DATE,
  region STRING,
  amount DECIMAL(10,2)
) CLUSTER BY (sale_date, region);

-- Insert sample data
INSERT INTO sales
SELECT 
  SEQ4() as sale_id,
  DATEADD(day, UNIFORM(1, 365, RANDOM()), '2023-01-01') as sale_date,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'NORTH'
    WHEN 2 THEN 'SOUTH'
    WHEN 3 THEN 'EAST'
    ELSE 'WEST'
  END as region,
  UNIFORM(10, 1000, RANDOM()) as amount
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- Check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('sales');

-- Query that benefits from clustering
SELECT 
  region,
  COUNT(*) as order_count,
  SUM(amount) as total_sales
FROM sales
WHERE sale_date BETWEEN '2023-06-01' AND '2023-06-30'
  AND region = 'NORTH'
GROUP BY region;

-- Check query profile to see partition pruning
SELECT 
  query_id,
  query_text,
  total_elapsed_time / 1000 as seconds,
  partitions_scanned,
  partitions_total
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sale_date BETWEEN%'
ORDER BY start_time DESC
LIMIT 1;

/*******************************************************************************
 * TOPIC 4: Security Policies
 *******************************************************************************/

-- Create a customer table with PII
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  name STRING,
  email STRING,
  phone STRING,
  region STRING
);

INSERT INTO customers VALUES
  (1, 'John Doe', 'john@example.com', '555-0101', 'NORTH'),
  (2, 'Jane Smith', 'jane@example.com', '555-0102', 'SOUTH'),
  (3, 'Bob Johnson', 'bob@example.com', '555-0103', 'EAST');

-- Create masking policy for email
CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN') THEN val
    ELSE REGEXP_REPLACE(val, '^[^@]+', '***')
  END;

-- Apply masking policy
ALTER TABLE customers MODIFY COLUMN email SET MASKING POLICY email_mask;

-- Create masking policy for phone
CREATE OR REPLACE MASKING POLICY phone_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN') THEN val
    ELSE REGEXP_REPLACE(val, '\\d{4}$', 'XXXX')
  END;

-- Apply masking policy
ALTER TABLE customers MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- Query as SYSADMIN (sees full data)
SELECT * FROM customers;

-- Create row access policy for regional access
CREATE OR REPLACE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_NORTH' AND region = 'NORTH' THEN TRUE
    WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_SOUTH' AND region = 'SOUTH' THEN TRUE
    ELSE FALSE
  END;

-- Apply row access policy
ALTER TABLE customers ADD ROW ACCESS POLICY regional_access ON (region);

-- Show policies
SHOW MASKING POLICIES;
SHOW ROW ACCESS POLICIES;

/*******************************************************************************
 * TOPIC 5: Monitoring and Troubleshooting
 *******************************************************************************/

-- Query recent query history
SELECT 
  query_id,
  user_name,
  role_name,
  warehouse_name,
  query_text,
  start_time,
  end_time,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned,
  rows_produced,
  execution_status
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time > DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 20;

-- Check warehouse usage
SELECT 
  warehouse_name,
  SUM(credits_used) as total_credits,
  COUNT(*) as query_count
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY warehouse_name
ORDER BY total_credits DESC;

-- Check for slow queries
SELECT 
  query_id,
  user_name,
  query_text,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time > DATEADD(day, -1, CURRENT_TIMESTAMP())
  AND total_elapsed_time > 10000  -- More than 10 seconds
ORDER BY total_elapsed_time DESC
LIMIT 10;

-- Check result cache effectiveness
SELECT 
  DATE(start_time) as query_date,
  COUNT(*) as total_queries,
  SUM(CASE WHEN query_result_cache_hit THEN 1 ELSE 0 END) as cache_hits,
  ROUND(SUM(CASE WHEN query_result_cache_hit THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as cache_hit_rate
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY DATE(start_time)
ORDER BY query_date DESC;

/*******************************************************************************
 * TOPIC 6: Time Travel and Data Recovery
 *******************************************************************************/

-- Create a table
CREATE OR REPLACE TABLE important_data (
  id INT,
  value STRING,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO important_data VALUES
  (1, 'Original Value 1', CURRENT_TIMESTAMP()),
  (2, 'Original Value 2', CURRENT_TIMESTAMP()),
  (3, 'Original Value 3', CURRENT_TIMESTAMP());

-- Accidentally delete data
DELETE FROM important_data WHERE id = 2;

-- Query historical data using Time Travel
SELECT * FROM important_data AT(OFFSET => -60);  -- 60 seconds ago

-- Restore deleted data
INSERT INTO important_data
SELECT * FROM important_data BEFORE(STATEMENT => LAST_QUERY_ID())
WHERE id = 2;

-- Verify restoration
SELECT * FROM important_data;

-- Drop table accidentally
DROP TABLE important_data;

-- Undrop the table
UNDROP TABLE important_data;

-- Verify table is restored
SELECT * FROM important_data;

/*******************************************************************************
 * TOPIC 7: Materialized Views
 *******************************************************************************/

-- Create a materialized view
CREATE OR REPLACE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
  sale_date,
  region,
  COUNT(*) as order_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales
GROUP BY sale_date, region;

-- Query the materialized view (fast!)
SELECT * FROM daily_sales_summary
WHERE sale_date >= '2023-06-01'
ORDER BY sale_date, region;

-- Show materialized views
SHOW MATERIALIZED VIEWS;

/*******************************************************************************
 * TOPIC 8: Stored Procedures and UDFs
 *******************************************************************************/

-- Create a simple UDF
CREATE OR REPLACE FUNCTION calculate_discount(amount DECIMAL(10,2), tier STRING)
RETURNS DECIMAL(10,2)
AS
$
  amount * CASE tier
    WHEN 'PLATINUM' THEN 0.20
    WHEN 'GOLD' THEN 0.15
    WHEN 'SILVER' THEN 0.10
    ELSE 0.05
  END
$;

-- Test the UDF
SELECT 
  100 as amount,
  'GOLD' as tier,
  calculate_discount(100, 'GOLD') as discount;

-- Create a stored procedure
CREATE OR REPLACE PROCEDURE process_daily_sales(sale_date DATE)
RETURNS STRING
LANGUAGE SQL
AS
$
DECLARE
  row_count INT;
BEGIN
  INSERT INTO daily_sales_summary
  SELECT 
    sale_date,
    region,
    COUNT(*),
    SUM(amount),
    AVG(amount)
  FROM sales
  WHERE sale_date = :sale_date
  GROUP BY sale_date, region;
  
  row_count := SQLROWCOUNT;
  RETURN 'Processed ' || row_count || ' rows for ' || sale_date;
END;
$;

-- Call the stored procedure
CALL process_daily_sales('2023-06-15');

/*******************************************************************************
 * CLEANUP
 *******************************************************************************/

-- Optionally clean up review objects
-- DROP DATABASE exam_review;
-- DROP WAREHOUSE review_wh;

/*******************************************************************************
 * EXAM REVIEW SUMMARY
 *******************************************************************************/

-- This solution file demonstrates key concepts from the practice exam:
-- 
-- ✅ Streams for Change Data Capture
-- ✅ Tasks for automation and orchestration
-- ✅ Clustering for performance optimization
-- ✅ Masking and row access policies for security
-- ✅ Monitoring queries for troubleshooting
-- ✅ Time Travel for data recovery
-- ✅ Materialized views for performance
-- ✅ Stored procedures and UDFs for business logic
--
-- Use these examples to reinforce concepts from questions you missed.
-- Focus your study time on topics where you scored lowest.
--
-- Good luck on Practice Exam 2!

