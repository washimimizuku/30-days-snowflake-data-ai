/*
Day 4: Streams + Tasks Integration - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY04_STREAMS_TASKS;
USE SCHEMA DAY04_STREAMS_TASKS;
USE WAREHOUSE BOOTCAMP_WH;

-- Create source table (orders)
CREATE OR REPLACE TABLE orders (
  order_id INT,
  customer_id INT,
  product_id INT,
  quantity INT,
  amount DECIMAL(10,2),
  order_status VARCHAR(20),
  order_date DATE,
  last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create target table (orders replica)
CREATE OR REPLACE TABLE orders_replica (
  order_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  quantity INT,
  amount DECIMAL(10,2),
  order_status VARCHAR(20),
  order_date DATE,
  last_updated TIMESTAMP_NTZ
);

-- Insert initial data
INSERT INTO orders (order_id, customer_id, product_id, quantity, amount, order_status, order_date) VALUES
  (1, 101, 1001, 2, 199.98, 'completed', '2025-12-01'),
  (2, 102, 1002, 1, 149.99, 'completed', '2025-12-01'),
  (3, 103, 1003, 3, 299.97, 'pending', '2025-12-02');

-- Initial load to replica
INSERT INTO orders_replica 
SELECT order_id, customer_id, product_id, quantity, amount, order_status, order_date, last_updated
FROM orders;


-- ============================================================================
-- Exercise 1: Basic Stream-Task Integration (5 min)
-- ============================================================================

-- TODO: Create a stream on the orders table
-- CREATE STREAM orders_stream ON TABLE orders;

-- TODO: Create a task that processes the stream
-- CREATE TASK sync_orders_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '1 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
-- AS
--   INSERT INTO orders_replica
--   SELECT order_id, customer_id, product_id, quantity, amount, order_status, order_date, last_updated
--   FROM orders_stream
--   WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = FALSE;

-- TODO: Resume the task
-- ALTER TASK sync_orders_task RESUME;

-- TODO: Make a change to test
-- INSERT INTO orders (order_id, customer_id, product_id, quantity, amount, order_status, order_date) VALUES
--   (4, 104, 1004, 1, 99.99, 'pending', '2025-12-03');

-- TODO: Check if stream has data
-- SELECT SYSTEM$STREAM_HAS_DATA('orders_stream');

-- TODO: Execute task manually
-- EXECUTE TASK sync_orders_task;

-- TODO: Verify data was synced
-- SELECT * FROM orders_replica WHERE order_id = 4;

-- TODO: Suspend task
-- ALTER TASK sync_orders_task SUSPEND;


-- ============================================================================
-- Exercise 2: Incremental MERGE Pattern (10 min)
-- ============================================================================

-- Recreate stream and task with MERGE logic
CREATE OR REPLACE STREAM orders_stream ON TABLE orders;

-- TODO: Create task with MERGE statement
-- CREATE TASK merge_orders_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '2 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
-- AS
--   MERGE INTO orders_replica AS target
--   USING (
--     SELECT 
--       order_id,
--       customer_id,
--       product_id,
--       quantity,
--       amount,
--       order_status,
--       order_date,
--       last_updated,
--       METADATA$ACTION,
--       METADATA$ISUPDATE
--     FROM orders_stream
--   ) AS source
--   ON target.order_id = source.order_id
--   WHEN MATCHED AND source.METADATA$ACTION = 'DELETE' AND source.METADATA$ISUPDATE = FALSE THEN
--     DELETE
--   WHEN MATCHED AND source.METADATA$ACTION = 'INSERT' AND source.METADATA$ISUPDATE = TRUE THEN
--     UPDATE SET
--       target.customer_id = source.customer_id,
--       target.product_id = source.product_id,
--       target.quantity = source.quantity,
--       target.amount = source.amount,
--       target.order_status = source.order_status,
--       target.order_date = source.order_date,
--       target.last_updated = source.last_updated
--   WHEN NOT MATCHED AND source.METADATA$ACTION = 'INSERT' THEN
--     INSERT (order_id, customer_id, product_id, quantity, amount, order_status, order_date, last_updated)
--     VALUES (source.order_id, source.customer_id, source.product_id, source.quantity, 
--             source.amount, source.order_status, source.order_date, source.last_updated);

-- TODO: Resume task
-- ALTER TASK merge_orders_task RESUME;

-- TODO: Test INSERT
-- INSERT INTO orders (order_id, customer_id, product_id, quantity, amount, order_status, order_date) VALUES
--   (5, 105, 1005, 2, 299.98, 'pending', '2025-12-03');

-- TODO: Test UPDATE
-- UPDATE orders SET order_status = 'completed', last_updated = CURRENT_TIMESTAMP() WHERE order_id = 3;

-- TODO: Test DELETE
-- DELETE FROM orders WHERE order_id = 1;

-- TODO: Execute task
-- EXECUTE TASK merge_orders_task;

-- TODO: Verify all changes were applied
-- SELECT * FROM orders_replica ORDER BY order_id;

-- TODO: Suspend task
-- ALTER TASK merge_orders_task SUSPEND;


-- ============================================================================
-- Exercise 3: SCD Type 2 Automation (10 min)
-- ============================================================================

-- Create customer dimension table
CREATE OR REPLACE TABLE dim_customers (
  surrogate_key INT AUTOINCREMENT,
  customer_id INT,
  customer_name VARCHAR(100),
  customer_tier VARCHAR(20),
  email VARCHAR(100),
  valid_from TIMESTAMP_NTZ,
  valid_to TIMESTAMP_NTZ,
  is_current BOOLEAN,
  PRIMARY KEY (surrogate_key)
);

-- Create source customer table
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  customer_tier VARCHAR(20),
  email VARCHAR(100),
  last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert initial customers
INSERT INTO customers (customer_id, customer_name, customer_tier, email) VALUES
  (101, 'Alice Johnson', 'gold', 'alice@example.com'),
  (102, 'Bob Smith', 'silver', 'bob@example.com'),
  (103, 'Carol White', 'bronze', 'carol@example.com');

-- Initial load to dimension
INSERT INTO dim_customers (customer_id, customer_name, customer_tier, email, valid_from, valid_to, is_current)
SELECT 
  customer_id,
  customer_name,
  customer_tier,
  email,
  last_updated as valid_from,
  '9999-12-31'::TIMESTAMP_NTZ as valid_to,
  TRUE as is_current
FROM customers;

-- TODO: Create stream on customers
-- CREATE STREAM customers_stream ON TABLE customers;

-- TODO: Create task for SCD Type 2 processing
-- CREATE TASK maintain_customer_scd
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '5 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('customers_stream')
-- AS
-- BEGIN
--   -- Step 1: Close out old records
--   UPDATE dim_customers
--   SET 
--     valid_to = CURRENT_TIMESTAMP(),
--     is_current = FALSE
--   WHERE customer_id IN (
--     SELECT DISTINCT customer_id 
--     FROM customers_stream 
--     WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE
--   )
--   AND is_current = TRUE;
--   
--   -- Step 2: Insert new versions
--   INSERT INTO dim_customers (customer_id, customer_name, customer_tier, email, valid_from, valid_to, is_current)
--   SELECT 
--     customer_id,
--     customer_name,
--     customer_tier,
--     email,
--     CURRENT_TIMESTAMP() as valid_from,
--     '9999-12-31'::TIMESTAMP_NTZ as valid_to,
--     TRUE as is_current
--   FROM customers_stream
--   WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE;
-- END;

-- TODO: Resume task
-- ALTER TASK maintain_customer_scd RESUME;

-- TODO: Update a customer to trigger SCD
-- UPDATE customers 
-- SET customer_tier = 'platinum', last_updated = CURRENT_TIMESTAMP()
-- WHERE customer_id = 101;

-- TODO: Execute task
-- EXECUTE TASK maintain_customer_scd;

-- TODO: View SCD history
-- SELECT * FROM dim_customers WHERE customer_id = 101 ORDER BY valid_from;

-- TODO: Suspend task
-- ALTER TASK maintain_customer_scd SUSPEND;


-- ============================================================================
-- Exercise 4: Multi-Stage Pipeline (10 min)
-- ============================================================================

-- Create staging and final tables
CREATE OR REPLACE TABLE orders_staging (
  order_id INT,
  customer_id INT,
  product_id INT,
  quantity INT,
  amount DECIMAL(10,2),
  order_status VARCHAR(20),
  order_date DATE,
  loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE orders_final (
  order_id INT,
  customer_id INT,
  product_id INT,
  quantity INT,
  amount DECIMAL(10,2),
  order_status VARCHAR(20),
  order_date DATE,
  processed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE orders_summary (
  summary_date DATE,
  total_orders INT,
  total_amount DECIMAL(12,2),
  created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create streams
CREATE OR REPLACE STREAM orders_stream ON TABLE orders;
CREATE OR REPLACE STREAM staging_stream ON TABLE orders_staging;

-- TODO: Create root task - Extract to staging
-- CREATE TASK extract_orders
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '2 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
-- AS
--   INSERT INTO orders_staging
--   SELECT order_id, customer_id, product_id, quantity, amount, order_status, order_date
--   FROM orders_stream
--   WHERE METADATA$ACTION = 'INSERT';

-- TODO: Create child task - Transform and load to final
-- CREATE TASK transform_orders
--   WAREHOUSE = BOOTCAMP_WH
--   AFTER extract_orders
-- AS
--   INSERT INTO orders_final
--   SELECT 
--     order_id,
--     customer_id,
--     product_id,
--     quantity,
--     amount,
--     order_status,
--     order_date
--   FROM orders_staging;

-- TODO: Create child task - Create summary
-- CREATE TASK summarize_orders
--   WAREHOUSE = BOOTCAMP_WH
--   AFTER transform_orders
-- AS
--   MERGE INTO orders_summary AS target
--   USING (
--     SELECT 
--       order_date,
--       COUNT(*) as total_orders,
--       SUM(amount) as total_amount
--     FROM orders_final
--     GROUP BY order_date
--   ) AS source
--   ON target.summary_date = source.order_date
--   WHEN MATCHED THEN
--     UPDATE SET
--       target.total_orders = source.total_orders,
--       target.total_amount = source.total_amount,
--       target.created_at = CURRENT_TIMESTAMP()
--   WHEN NOT MATCHED THEN
--     INSERT (summary_date, total_orders, total_amount)
--     VALUES (source.order_date, source.total_orders, source.total_amount);

-- TODO: Resume tasks (children first, then root)
-- ALTER TASK transform_orders RESUME;
-- ALTER TASK summarize_orders RESUME;
-- ALTER TASK extract_orders RESUME;

-- TODO: Insert test data
-- INSERT INTO orders (order_id, customer_id, product_id, quantity, amount, order_status, order_date) VALUES
--   (6, 106, 1006, 1, 199.99, 'pending', '2025-12-04'),
--   (7, 107, 1007, 2, 399.98, 'pending', '2025-12-04');

-- TODO: Execute root task
-- EXECUTE TASK extract_orders;

-- TODO: Verify pipeline results
-- SELECT * FROM orders_staging WHERE order_id IN (6, 7);
-- SELECT * FROM orders_final WHERE order_id IN (6, 7);
-- SELECT * FROM orders_summary WHERE summary_date = '2025-12-04';

-- TODO: Suspend all tasks
-- ALTER TASK extract_orders SUSPEND;
-- ALTER TASK transform_orders SUSPEND;
-- ALTER TASK summarize_orders SUSPEND;


-- ============================================================================
-- Exercise 5: Error Handling (5 min)
-- ============================================================================

-- Create error log table
CREATE OR REPLACE TABLE cdc_error_log (
  error_id INT AUTOINCREMENT,
  error_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  task_name VARCHAR(100),
  error_message VARCHAR(1000),
  failed_record VARIANT
);

-- Create dead letter queue
CREATE OR REPLACE TABLE dlq_orders (
  dlq_id INT AUTOINCREMENT,
  original_record VARIANT,
  error_reason VARCHAR(500),
  created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- TODO: Create task with error handling
-- CREATE TASK process_with_errors
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '2 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
-- AS
-- BEGIN
--   -- Process valid records
--   INSERT INTO orders_replica
--   SELECT order_id, customer_id, product_id, quantity, amount, order_status, order_date, last_updated
--   FROM orders_stream
--   WHERE METADATA$ACTION = 'INSERT' 
--     AND amount > 0  -- Validation rule
--     AND quantity > 0;
--   
--   -- Log invalid records to DLQ
--   INSERT INTO dlq_orders (original_record, error_reason)
--   SELECT 
--     OBJECT_CONSTRUCT(*),
--     'Invalid amount or quantity'
--   FROM orders_stream
--   WHERE METADATA$ACTION = 'INSERT'
--     AND (amount <= 0 OR quantity <= 0);
-- EXCEPTION
--   WHEN OTHER THEN
--     INSERT INTO cdc_error_log (task_name, error_message)
--     VALUES ('process_with_errors', SQLERRM);
-- END;


-- ============================================================================
-- Exercise 6: Monitoring Dashboard (5 min)
-- ============================================================================

-- TODO: Create monitoring view for stream status
-- CREATE OR REPLACE VIEW stream_monitoring AS
-- SELECT 
--   'orders_stream' as stream_name,
--   SYSTEM$STREAM_HAS_DATA('orders_stream') as has_data,
--   (SELECT COUNT(*) FROM orders_stream) as pending_changes,
--   CURRENT_TIMESTAMP() as check_time;

-- TODO: Query stream monitoring
-- SELECT * FROM stream_monitoring;

-- TODO: Create view for task execution summary
-- CREATE OR REPLACE VIEW task_execution_summary AS
-- SELECT 
--   NAME as task_name,
--   STATE,
--   SCHEDULED_TIME,
--   COMPLETED_TIME,
--   DATEDIFF(second, SCHEDULED_TIME, COMPLETED_TIME) as duration_seconds,
--   ERROR_CODE,
--   ERROR_MESSAGE
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -24, CURRENT_TIMESTAMP())
-- ))
-- WHERE NAME LIKE '%orders%'
-- ORDER BY SCHEDULED_TIME DESC;

-- TODO: Query task execution summary
-- SELECT * FROM task_execution_summary LIMIT 10;

-- TODO: Create pipeline health check
-- SELECT 
--   'Pipeline Health' as metric,
--   COUNT(DISTINCT NAME) as active_tasks,
--   SUM(CASE WHEN STATE = 'SUCCEEDED' THEN 1 ELSE 0 END) as successful_runs,
--   SUM(CASE WHEN STATE = 'FAILED' THEN 1 ELSE 0 END) as failed_runs,
--   ROUND(successful_runs / NULLIF(COUNT(*), 0) * 100, 2) as success_rate_pct
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   SCHEDULED_TIME_RANGE_START => DATEADD(day, -1, CURRENT_TIMESTAMP())
-- ));


-- ============================================================================
-- Bonus Challenge: Production-Ready Pipeline (10 min)
-- ============================================================================

-- TODO: Build a complete production-ready CDC pipeline with:
-- 1. Stream on source table
-- 2. Task with conditional execution
-- 3. MERGE logic for all DML operations
-- 4. Error handling and logging
-- 5. Monitoring views
-- 6. Performance optimization (appropriate schedule, warehouse size)

-- Example structure:
-- CREATE STREAM production_stream ON TABLE orders;
-- 
-- CREATE TASK production_cdc_pipeline
--   SCHEDULE = '5 MINUTE'
--   USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
--   WHEN SYSTEM$STREAM_HAS_DATA('production_stream')
-- AS
-- BEGIN
--   -- Your complete MERGE logic here with error handling
-- END;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- TODO: Suspend all tasks
-- ALTER TASK sync_orders_task SUSPEND;
-- ALTER TASK merge_orders_task SUSPEND;
-- ALTER TASK maintain_customer_scd SUSPEND;
-- ALTER TASK extract_orders SUSPEND;
-- ALTER TASK transform_orders SUSPEND;
-- ALTER TASK summarize_orders SUSPEND;

-- TODO: Drop tasks
-- DROP TASK IF EXISTS sync_orders_task;
-- DROP TASK IF EXISTS merge_orders_task;
-- DROP TASK IF EXISTS maintain_customer_scd;
-- DROP TASK IF EXISTS extract_orders;
-- DROP TASK IF EXISTS transform_orders;
-- DROP TASK IF EXISTS summarize_orders;
-- DROP TASK IF EXISTS process_with_errors;

-- TODO: Drop streams
-- DROP STREAM IF EXISTS orders_stream;
-- DROP STREAM IF EXISTS customers_stream;
-- DROP STREAM IF EXISTS staging_stream;

-- TODO: Drop tables
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS orders_replica;
-- DROP TABLE IF EXISTS orders_staging;
-- DROP TABLE IF EXISTS orders_final;
-- DROP TABLE IF EXISTS orders_summary;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS dim_customers;
-- DROP TABLE IF EXISTS cdc_error_log;
-- DROP TABLE IF EXISTS dlq_orders;
