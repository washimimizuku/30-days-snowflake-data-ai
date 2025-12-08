/*******************************************************************************
 * Day 27: Practice Exam 2 - Solution
 * 
 * This file contains a comprehensive review framework based on both practice exams
 * 
 *******************************************************************************/

/*******************************************************************************
 * COMPREHENSIVE REVIEW: Key Concepts from Both Practice Exams
 *******************************************************************************/

-- Setup
USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS final_review;
USE DATABASE final_review;
CREATE SCHEMA IF NOT EXISTS concepts;
USE SCHEMA concepts;
CREATE WAREHOUSE IF NOT EXISTS review_wh WITH WAREHOUSE_SIZE = 'XSMALL';
USE WAREHOUSE review_wh;

/*******************************************************************************
 * CONCEPT 1: Streams - Complete CDC Pattern
 *******************************************************************************/

-- Create source table
CREATE OR REPLACE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  status STRING,
  order_date DATE
);

-- Create stream
CREATE OR REPLACE STREAM orders_stream ON TABLE customer_orders;

-- Insert initial data
INSERT INTO customer_orders VALUES
  (1, 101, 100.00, 'PENDING', '2024-01-15'),
  (2, 102, 200.00, 'COMPLETED', '2024-01-15'),
  (3, 103, 150.00, 'PENDING', '2024-01-16');

-- Update a record
UPDATE customer_orders SET status = 'COMPLETED' WHERE order_id = 1;

-- Delete a record
DELETE FROM customer_orders WHERE order_id = 3;

-- Query stream to see all changes
SELECT 
  order_id,
  customer_id,
  amount,
  status,
  METADATA$ACTION as action,
  METADATA$ISUPDATE as is_update,
  METADATA$ROW_ID as row_id
FROM orders_stream
ORDER BY order_id, METADATA$ACTION;

-- Check if stream has data
SELECT SYSTEM$STREAM_HAS_DATA('orders_stream') as has_data;

-- Get stream's table timestamp
SELECT SYSTEM$STREAM_GET_TABLE_TIMESTAMP('orders_stream') as stream_timestamp;

/*******************************************************************************
 * CONCEPT 2: Tasks - Complete Orchestration Pattern
 *******************************************************************************/

-- Create target table
CREATE OR REPLACE TABLE orders_processed (
  order_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  status STRING,
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create task to process stream
CREATE OR REPLACE TASK process_orders_task
  WAREHOUSE = review_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
AS
  INSERT INTO orders_processed (order_id, customer_id, amount, status)
  SELECT order_id, customer_id, amount, status
  FROM orders_stream
  WHERE METADATA$ACTION = 'INSERT';

-- Create dependent task
CREATE OR REPLACE TASK update_metrics_task
  WAREHOUSE = review_wh
  AFTER process_orders_task
AS
  INSERT INTO task_log VALUES (CURRENT_TIMESTAMP(), 'Metrics updated');

-- Create task log
CREATE OR REPLACE TABLE task_log (
  log_time TIMESTAMP,
  message STRING
);

-- Resume tasks (child first, then parent)
ALTER TASK update_metrics_task RESUME;
ALTER TASK process_orders_task RESUME;

-- Check task status
SHOW TASKS;

-- View task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name LIKE '%_TASK'
ORDER BY scheduled_time DESC
LIMIT 10;

-- Manually execute for testing
EXECUTE TASK process_orders_task;

/*******************************************************************************
 * CONCEPT 3: Clustering - Performance Optimization
 *******************************************************************************/

-- Create table with clustering
CREATE OR REPLACE TABLE sales_data (
  sale_id INT,
  sale_date DATE,
  region STRING,
  product_id INT,
  amount DECIMAL(10,2)
) CLUSTER BY (sale_date, region);

-- Insert sample data
INSERT INTO sales_data
SELECT 
  SEQ4() as sale_id,
  DATEADD(day, UNIFORM(1, 365, RANDOM()), '2023-01-01') as sale_date,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'NORTH'
    WHEN 2 THEN 'SOUTH'
    WHEN 3 THEN 'EAST'
    ELSE 'WEST'
  END as region,
  UNIFORM(1, 100, RANDOM()) as product_id,
  UNIFORM(10, 1000, RANDOM()) as amount
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('sales_data');

-- Check clustering depth
SELECT SYSTEM$CLUSTERING_DEPTH('sales_data');

-- Query that benefits from clustering
SELECT 
  region,
  COUNT(*) as sales_count,
  SUM(amount) as total_sales
FROM sales_data
WHERE sale_date BETWEEN '2023-06-01' AND '2023-06-30'
  AND region = 'NORTH'
GROUP BY region;

/*******************************************************************************
 * CONCEPT 4: Security Policies - Complete Implementation
 *******************************************************************************/

-- Create table with sensitive data
CREATE OR REPLACE TABLE employee_data (
  employee_id INT,
  name STRING,
  email STRING,
  salary DECIMAL(10,2),
  department STRING,
  ssn STRING
);

INSERT INTO employee_data VALUES
  (1, 'John Doe', 'john@company.com', 75000, 'ENGINEERING', '123-45-6789'),
  (2, 'Jane Smith', 'jane@company.com', 85000, 'SALES', '987-65-4321'),
  (3, 'Bob Johnson', 'bob@company.com', 65000, 'MARKETING', '456-78-9012');

-- Create masking policy for email
CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN', 'HR_ROLE') THEN val
    ELSE REGEXP_REPLACE(val, '^[^@]+', '***')
  END;

-- Create masking policy for SSN
CREATE OR REPLACE MASKING POLICY ssn_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN', 'HR_ROLE') THEN val
    ELSE 'XXX-XX-' || RIGHT(val, 4)
  END;

-- Create masking policy for salary
CREATE OR REPLACE MASKING POLICY salary_mask AS (val DECIMAL(10,2)) RETURNS DECIMAL(10,2) ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN', 'HR_ROLE', 'FINANCE_ROLE') THEN val
    ELSE NULL
  END;

-- Apply masking policies
ALTER TABLE employee_data MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE employee_data MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;
ALTER TABLE employee_data MODIFY COLUMN salary SET MASKING POLICY salary_mask;

-- Create row access policy for department-based access
CREATE OR REPLACE ROW ACCESS POLICY department_access AS (dept STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN', 'HR_ROLE') THEN TRUE
    WHEN CURRENT_ROLE() = 'ENGINEERING_MANAGER' AND dept = 'ENGINEERING' THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_MANAGER' AND dept = 'SALES' THEN TRUE
    ELSE FALSE
  END;

-- Apply row access policy
ALTER TABLE employee_data ADD ROW ACCESS POLICY department_access ON (department);

-- Query as SYSADMIN (sees all data unmasked)
SELECT * FROM employee_data;

/*******************************************************************************
 * CONCEPT 5: Monitoring - Complete Observability
 *******************************************************************************/

-- Create monitoring views

-- 1. Query Performance Monitor
CREATE OR REPLACE VIEW query_performance_monitor AS
SELECT 
  query_id,
  user_name,
  role_name,
  warehouse_name,
  query_text,
  start_time,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned,
  rows_produced,
  partitions_scanned,
  partitions_total,
  CASE 
    WHEN partitions_total > 0 
    THEN ROUND((1 - partitions_scanned::FLOAT / partitions_total) * 100, 2)
    ELSE 0
  END as partition_pruning_pct,
  execution_status
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time > DATEADD(hour, -24, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- 2. Warehouse Credit Usage
CREATE OR REPLACE VIEW warehouse_credit_usage AS
SELECT 
  warehouse_name,
  DATE(start_time) as usage_date,
  SUM(credits_used) as total_credits,
  COUNT(*) as query_count,
  AVG(credits_used) as avg_credits_per_query
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time > DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY warehouse_name, DATE(start_time)
ORDER BY usage_date DESC, warehouse_name;

-- 3. Task Execution Monitor
CREATE OR REPLACE VIEW task_execution_monitor AS
SELECT 
  name as task_name,
  database_name,
  schema_name,
  state,
  scheduled_time,
  completed_time,
  DATEDIFF(second, scheduled_time, completed_time) as duration_seconds,
  error_code,
  error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE scheduled_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY scheduled_time DESC;

-- 4. Result Cache Effectiveness
CREATE OR REPLACE VIEW cache_effectiveness AS
SELECT 
  DATE(start_time) as query_date,
  warehouse_name,
  COUNT(*) as total_queries,
  SUM(CASE WHEN query_result_cache_hit THEN 1 ELSE 0 END) as cache_hits,
  ROUND(SUM(CASE WHEN query_result_cache_hit THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 2) as cache_hit_rate_pct
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY DATE(start_time), warehouse_name
ORDER BY query_date DESC, warehouse_name;

-- Query the monitoring views
SELECT * FROM query_performance_monitor LIMIT 10;
SELECT * FROM warehouse_credit_usage LIMIT 10;
SELECT * FROM task_execution_monitor LIMIT 10;
SELECT * FROM cache_effectiveness LIMIT 10;

/*******************************************************************************
 * CONCEPT 6: Time Travel and Data Recovery
 *******************************************************************************/

-- Create table with Time Travel
CREATE OR REPLACE TABLE critical_data (
  id INT,
  value STRING,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) DATA_RETENTION_TIME_IN_DAYS = 30;

-- Insert data
INSERT INTO critical_data VALUES
  (1, 'Important Value 1', CURRENT_TIMESTAMP()),
  (2, 'Important Value 2', CURRENT_TIMESTAMP()),
  (3, 'Important Value 3', CURRENT_TIMESTAMP());

-- Simulate accidental update
UPDATE critical_data SET value = 'WRONG VALUE' WHERE id = 1;

-- Query historical data (before the update)
SELECT * FROM critical_data AT(OFFSET => -60);  -- 60 seconds ago

-- Restore the correct value
UPDATE critical_data
SET value = (SELECT value FROM critical_data AT(OFFSET => -60) WHERE id = 1)
WHERE id = 1;

-- Simulate accidental delete
DELETE FROM critical_data WHERE id = 2;

-- Restore deleted row
INSERT INTO critical_data
SELECT * FROM critical_data BEFORE(STATEMENT => LAST_QUERY_ID())
WHERE id = 2;

-- Drop table accidentally
DROP TABLE critical_data;

-- Undrop the table
UNDROP TABLE critical_data;

-- Verify restoration
SELECT * FROM critical_data;

/*******************************************************************************
 * CONCEPT 7: Stored Procedures and UDFs
 *******************************************************************************/

-- Create a scalar UDF
CREATE OR REPLACE FUNCTION calculate_tax(amount DECIMAL(10,2), tax_rate DECIMAL(3,2))
RETURNS DECIMAL(10,2)
AS
$
  amount * tax_rate
$;

-- Create a memoizable UDF (caches results)
CREATE OR REPLACE FUNCTION fibonacci(n INT)
RETURNS INT
MEMOIZABLE
AS
$
  CASE
    WHEN n <= 1 THEN n
    ELSE fibonacci(n-1) + fibonacci(n-2)
  END
$;

-- Create a UDTF (table function)
CREATE OR REPLACE FUNCTION split_string(input STRING, delimiter STRING)
RETURNS TABLE (value STRING)
AS
$
  SELECT value
  FROM TABLE(SPLIT_TO_TABLE(input, delimiter))
$;

-- Create a stored procedure
CREATE OR REPLACE PROCEDURE daily_etl_process(process_date DATE)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$
DECLARE
  rows_processed INT DEFAULT 0;
  result_message STRING;
BEGIN
  -- Process orders
  INSERT INTO orders_processed
  SELECT * FROM customer_orders
  WHERE order_date = :process_date;
  
  rows_processed := SQLROWCOUNT;
  
  -- Log execution
  INSERT INTO task_log VALUES (CURRENT_TIMESTAMP(), 'ETL completed for ' || process_date);
  
  result_message := 'Processed ' || rows_processed || ' orders for ' || process_date;
  RETURN result_message;
END;
$;

-- Test UDFs
SELECT calculate_tax(100, 0.08) as tax_amount;
SELECT fibonacci(10) as fib_result;
SELECT * FROM TABLE(split_string('apple,banana,cherry', ','));

-- Test stored procedure
CALL daily_etl_process('2024-01-15');

/*******************************************************************************
 * CONCEPT 8: Materialized Views
 *******************************************************************************/

-- Create materialized view
CREATE OR REPLACE MATERIALIZED VIEW daily_sales_mv AS
SELECT 
  sale_date,
  region,
  COUNT(*) as order_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale,
  MIN(amount) as min_sale,
  MAX(amount) as max_sale
FROM sales_data
GROUP BY sale_date, region;

-- Query materialized view (fast!)
SELECT * FROM daily_sales_mv
WHERE sale_date >= '2023-06-01'
ORDER BY sale_date, region
LIMIT 20;

-- Show materialized views
SHOW MATERIALIZED VIEWS;

/*******************************************************************************
 * KEY FACTS CHEAT SHEET
 *******************************************************************************/

CREATE OR REPLACE VIEW exam_cheat_sheet AS
SELECT 'Time Travel Max (Enterprise)' as concept, '90 days' as value
UNION ALL SELECT 'Time Travel Max (Standard)', '1 day'
UNION ALL SELECT 'Fail-safe Period', '7 days (Snowflake Support only)'
UNION ALL SELECT 'Max Clustering Keys', '4 columns'
UNION ALL SELECT 'Min Task Schedule', '1 minute'
UNION ALL SELECT 'Result Cache TTL', '24 hours'
UNION ALL SELECT 'Snowpipe History Retention', '14 days'
UNION ALL SELECT 'Max Multi-cluster Warehouses', '10 clusters'
UNION ALL SELECT 'ACCOUNT_USAGE Latency', '45 min to 3 hours'
UNION ALL SELECT 'INFORMATION_SCHEMA Latency', 'Real-time'
UNION ALL SELECT 'Query History (INFORMATION_SCHEMA)', '7 days'
UNION ALL SELECT 'Query History (ACCOUNT_USAGE)', '365 days'
UNION ALL SELECT 'Encryption at Rest', 'AES-256'
UNION ALL SELECT 'Max File Size (COPY)', 'No hard limit (100-250 MB recommended)'
UNION ALL SELECT 'Stream Retention', 'Same as table Time Travel'
UNION ALL SELECT 'Warehouse Sizes', 'XS, S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL'
UNION ALL SELECT 'Scaling Policies', 'Standard, Economy'
UNION ALL SELECT 'Stored Procedure Languages', 'JavaScript, SQL, Python'
UNION ALL SELECT 'UDF Languages', 'JavaScript, SQL, Python, Java, Scala'
UNION ALL SELECT 'Max Warehouse Auto-suspend', 'No maximum';

-- Query the cheat sheet
SELECT * FROM exam_cheat_sheet ORDER BY concept;

/*******************************************************************************
 * CLEANUP
 *******************************************************************************/

-- Suspend tasks
ALTER TASK IF EXISTS process_orders_task SUSPEND;
ALTER TASK IF EXISTS update_metrics_task SUSPEND;

-- Optionally drop review database
-- DROP DATABASE final_review;
-- DROP WAREHOUSE review_wh;

/*******************************************************************************
 * FINAL EXAM PREPARATION SUMMARY
 *******************************************************************************/

-- You've now completed:
-- ✅ 25 days of intensive study
-- ✅ Hands-on project integrating all concepts
-- ✅ Practice Exam 1 (65 questions)
-- ✅ Practice Exam 2 (65 questions)
-- ✅ Comprehensive review of all key concepts
--
-- Tomorrow (Day 28): Final comprehensive review with 50 questions
-- Day 29: Light review and confidence building
-- Day 30: EXAM DAY!
--
-- You're ready for this! Trust your preparation and stay confident.
--
-- Good luck! 🚀

