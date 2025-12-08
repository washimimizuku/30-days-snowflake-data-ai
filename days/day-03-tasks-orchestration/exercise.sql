/*
Day 3: Tasks & Task Orchestration - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY03_TASKS;
USE SCHEMA DAY03_TASKS;
USE WAREHOUSE BOOTCAMP_WH;

-- Create source and target tables
CREATE OR REPLACE TABLE sales_raw (
  sale_id INT,
  product_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  sale_date DATE,
  loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE sales_processed (
  sale_id INT,
  product_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  sale_date DATE,
  processed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE sales_summary (
  summary_date DATE,
  total_sales DECIMAL(12,2),
  transaction_count INT,
  created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert sample data
INSERT INTO sales_raw (sale_id, product_id, customer_id, amount, sale_date) VALUES
  (1, 101, 1001, 99.99, '2025-12-01'),
  (2, 102, 1002, 149.99, '2025-12-01'),
  (3, 103, 1003, 79.99, '2025-12-02');


-- ============================================================================
-- Exercise 1: Create Standalone Task (5 min)
-- ============================================================================

-- TODO: Create a simple task that runs every 5 minutes
-- This task should insert a log entry into a log table

-- First, create a log table
CREATE OR REPLACE TABLE task_log (
  log_id INT AUTOINCREMENT,
  task_name VARCHAR(100),
  execution_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  message VARCHAR(500)
);

-- TODO: Create the task
-- CREATE TASK simple_log_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '5 MINUTE'
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('simple_log_task', 'Task executed successfully');

-- TODO: Show the task
-- SHOW TASKS;

-- TODO: Resume the task (tasks are created in SUSPENDED state)
-- ALTER TASK simple_log_task RESUME;

-- TODO: Execute the task manually to test
-- EXECUTE TASK simple_log_task;

-- TODO: Check the log
-- SELECT * FROM task_log;

-- TODO: Suspend the task (to avoid continuous execution during exercises)
-- ALTER TASK simple_log_task SUSPEND;


-- ============================================================================
-- Exercise 2: CRON Scheduling (5 min)
-- ============================================================================

-- TODO: Create a task that runs every day at 9 AM UTC
-- CREATE TASK daily_morning_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = 'USING CRON 0 9 * * * UTC'
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('daily_morning_task', 'Daily morning execution');

-- TODO: Create a task that runs every Monday at 8 AM UTC
-- CREATE TASK weekly_monday_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = 'USING CRON 0 8 * * 1 UTC'
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('weekly_monday_task', 'Weekly Monday execution');

-- TODO: Create a task that runs on the first day of every month at midnight
-- CREATE TASK monthly_first_day_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = 'USING CRON 0 0 1 * * UTC'
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('monthly_first_day_task', 'Monthly first day execution');

-- TODO: Show all tasks
-- SHOW TASKS;

-- TODO: Describe a specific task to see its schedule
-- DESC TASK daily_morning_task;


-- ============================================================================
-- Exercise 3: Create Task Tree (10 min)
-- ============================================================================

-- TODO: Create a root task that processes raw sales data
-- CREATE TASK root_process_sales
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '10 MINUTE'
-- AS
--   INSERT INTO sales_processed (sale_id, product_id, customer_id, amount, sale_date)
--   SELECT sale_id, product_id, customer_id, amount, sale_date
--   FROM sales_raw
--   WHERE sale_id NOT IN (SELECT sale_id FROM sales_processed);

-- TODO: Create a child task that creates daily summaries
-- CREATE TASK child_create_summary
--   WAREHOUSE = BOOTCAMP_WH
--   AFTER root_process_sales
-- AS
--   INSERT INTO sales_summary (summary_date, total_sales, transaction_count)
--   SELECT 
--     sale_date,
--     SUM(amount) as total_sales,
--     COUNT(*) as transaction_count
--   FROM sales_processed
--   WHERE sale_date NOT IN (SELECT summary_date FROM sales_summary)
--   GROUP BY sale_date;

-- TODO: Create another child task that logs completion
-- CREATE TASK child_log_completion
--   WAREHOUSE = BOOTCAMP_WH
--   AFTER root_process_sales
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('child_log_completion', 'Sales processing completed');

-- TODO: View task dependencies
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
--   TASK_NAME => 'ROOT_PROCESS_SALES'
-- ));

-- TODO: Resume tasks (must resume children first, then root)
-- ALTER TASK child_create_summary RESUME;
-- ALTER TASK child_log_completion RESUME;
-- ALTER TASK root_process_sales RESUME;

-- TODO: Execute the root task manually
-- EXECUTE TASK root_process_sales;

-- TODO: Check results
-- SELECT * FROM sales_processed;
-- SELECT * FROM sales_summary;
-- SELECT * FROM task_log WHERE task_name = 'child_log_completion';

-- TODO: Suspend all tasks
-- ALTER TASK root_process_sales SUSPEND;
-- ALTER TASK child_create_summary SUSPEND;
-- ALTER TASK child_log_completion SUSPEND;


-- ============================================================================
-- Exercise 4: Serverless Task (5 min)
-- ============================================================================

-- TODO: Create a serverless task
-- CREATE TASK serverless_task
--   SCHEDULE = '5 MINUTE'
--   USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('serverless_task', 'Serverless execution');

-- TODO: Show the task and note it has no warehouse
-- SHOW TASKS LIKE 'serverless_task';

-- TODO: Resume and execute
-- ALTER TASK serverless_task RESUME;
-- EXECUTE TASK serverless_task;

-- TODO: Check log
-- SELECT * FROM task_log WHERE task_name = 'serverless_task';

-- TODO: Suspend
-- ALTER TASK serverless_task SUSPEND;


-- ============================================================================
-- Exercise 5: Conditional Execution with Streams (10 min)
-- ============================================================================

-- Create a stream on sales_raw
CREATE OR REPLACE STREAM sales_stream ON TABLE sales_raw;

-- TODO: Create a task that runs only when the stream has data
-- CREATE TASK conditional_stream_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '1 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('sales_stream')
-- AS
--   INSERT INTO sales_processed (sale_id, product_id, customer_id, amount, sale_date)
--   SELECT sale_id, product_id, customer_id, amount, sale_date
--   FROM sales_stream
--   WHERE METADATA$ACTION = 'INSERT';

-- TODO: Resume the task
-- ALTER TASK conditional_stream_task RESUME;

-- TODO: Check if stream has data
-- SELECT SYSTEM$STREAM_HAS_DATA('sales_stream');

-- TODO: Insert new data to trigger the stream
-- INSERT INTO sales_raw (sale_id, product_id, customer_id, amount, sale_date) VALUES
--   (4, 104, 1004, 199.99, '2025-12-03'),
--   (5, 105, 1005, 299.99, '2025-12-03');

-- TODO: Verify stream has data now
-- SELECT SYSTEM$STREAM_HAS_DATA('sales_stream');

-- TODO: Execute the task manually
-- EXECUTE TASK conditional_stream_task;

-- TODO: Verify data was processed
-- SELECT * FROM sales_processed WHERE sale_id IN (4, 5);

-- TODO: Verify stream is consumed
-- SELECT * FROM sales_stream;

-- TODO: Suspend task
-- ALTER TASK conditional_stream_task SUSPEND;


-- ============================================================================
-- Exercise 6: Task Monitoring (5 min)
-- ============================================================================

-- TODO: View task execution history
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ))
-- ORDER BY SCHEDULED_TIME DESC;

-- TODO: View history for a specific task
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   TASK_NAME => 'ROOT_PROCESS_SALES',
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ))
-- ORDER BY SCHEDULED_TIME DESC;

-- TODO: Check task run statistics
-- SELECT 
--   NAME,
--   STATE,
--   SCHEDULED_TIME,
--   COMPLETED_TIME,
--   DATEDIFF(second, SCHEDULED_TIME, COMPLETED_TIME) as duration_seconds,
--   ERROR_CODE,
--   ERROR_MESSAGE
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -24, CURRENT_TIMESTAMP())
-- ))
-- WHERE STATE IN ('SUCCEEDED', 'FAILED')
-- ORDER BY SCHEDULED_TIME DESC;

-- TODO: View task dependencies
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
--   TASK_NAME => 'ROOT_PROCESS_SALES'
-- ));


-- ============================================================================
-- Exercise 7: Error Handling (5 min)
-- ============================================================================

-- TODO: Create a task that will fail
-- CREATE TASK failing_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '5 MINUTE'
-- AS
--   -- This will fail because the table doesn't exist
--   INSERT INTO non_existent_table VALUES (1, 'test');

-- TODO: Resume and execute the task
-- ALTER TASK failing_task RESUME;
-- EXECUTE TASK failing_task;

-- TODO: Check task history for the error
-- SELECT 
--   NAME,
--   STATE,
--   ERROR_CODE,
--   ERROR_MESSAGE
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   TASK_NAME => 'FAILING_TASK',
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ))
-- ORDER BY SCHEDULED_TIME DESC;

-- TODO: Fix the task
-- CREATE OR REPLACE TASK failing_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '5 MINUTE'
-- AS
--   INSERT INTO task_log (task_name, message)
--   VALUES ('failing_task', 'Now working correctly');

-- TODO: Resume and execute again
-- ALTER TASK failing_task RESUME;
-- EXECUTE TASK failing_task;

-- TODO: Verify it succeeded
-- SELECT * FROM task_log WHERE task_name = 'failing_task';

-- TODO: Suspend
-- ALTER TASK failing_task SUSPEND;


-- ============================================================================
-- Bonus Challenge: Complete ETL Pipeline (10 min)
-- ============================================================================

-- Build a complete automated ETL pipeline with error handling

-- TODO: Create staging table
CREATE OR REPLACE TABLE sales_staging (
  sale_id INT,
  product_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  sale_date DATE,
  loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- TODO: Create error log table
CREATE OR REPLACE TABLE etl_error_log (
  error_id INT AUTOINCREMENT,
  task_name VARCHAR(100),
  error_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  error_message VARCHAR(1000)
);

-- TODO: Create root task - Extract (load from staging)
-- CREATE TASK etl_extract
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '5 MINUTE'
-- AS
-- BEGIN
--   -- Load new data from staging
--   INSERT INTO sales_raw (sale_id, product_id, customer_id, amount, sale_date)
--   SELECT sale_id, product_id, customer_id, amount, sale_date
--   FROM sales_staging
--   WHERE sale_id NOT IN (SELECT sale_id FROM sales_raw);
--   
--   -- Clear staging
--   DELETE FROM sales_staging;
-- END;

-- TODO: Create child task - Transform
-- CREATE TASK etl_transform
--   WAREHOUSE = BOOTCAMP_WH
--   AFTER etl_extract
-- AS
--   INSERT INTO sales_processed (sale_id, product_id, customer_id, amount, sale_date)
--   SELECT sale_id, product_id, customer_id, amount, sale_date
--   FROM sales_raw
--   WHERE sale_id NOT IN (SELECT sale_id FROM sales_processed);

-- TODO: Create child task - Load (aggregate)
-- CREATE TASK etl_load
--   WAREHOUSE = BOOTCAMP_WH
--   AFTER etl_transform
-- AS
--   MERGE INTO sales_summary AS target
--   USING (
--     SELECT 
--       sale_date,
--       SUM(amount) as total_sales,
--       COUNT(*) as transaction_count
--     FROM sales_processed
--     GROUP BY sale_date
--   ) AS source
--   ON target.summary_date = source.sale_date
--   WHEN MATCHED THEN
--     UPDATE SET
--       target.total_sales = source.total_sales,
--       target.transaction_count = source.transaction_count,
--       target.created_at = CURRENT_TIMESTAMP()
--   WHEN NOT MATCHED THEN
--     INSERT (summary_date, total_sales, transaction_count)
--     VALUES (source.sale_date, source.total_sales, source.transaction_count);

-- TODO: Resume all tasks (children first, then root)
-- ALTER TASK etl_transform RESUME;
-- ALTER TASK etl_load RESUME;
-- ALTER TASK etl_extract RESUME;

-- TODO: Test the pipeline
-- Insert test data into staging
-- INSERT INTO sales_staging (sale_id, product_id, customer_id, amount, sale_date) VALUES
--   (6, 106, 1006, 399.99, '2025-12-04'),
--   (7, 107, 1007, 499.99, '2025-12-04');

-- TODO: Execute the root task
-- EXECUTE TASK etl_extract;

-- TODO: Verify the pipeline worked
-- SELECT * FROM sales_raw WHERE sale_id IN (6, 7);
-- SELECT * FROM sales_processed WHERE sale_id IN (6, 7);
-- SELECT * FROM sales_summary WHERE summary_date = '2025-12-04';

-- TODO: Check task execution history
-- SELECT 
--   NAME,
--   STATE,
--   SCHEDULED_TIME,
--   COMPLETED_TIME
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ))
-- WHERE NAME IN ('ETL_EXTRACT', 'ETL_TRANSFORM', 'ETL_LOAD')
-- ORDER BY SCHEDULED_TIME DESC, NAME;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- TODO: Suspend all tasks
-- ALTER TASK etl_extract SUSPEND;
-- ALTER TASK etl_transform SUSPEND;
-- ALTER TASK etl_load SUSPEND;
-- ALTER TASK simple_log_task SUSPEND;
-- ALTER TASK daily_morning_task SUSPEND;
-- ALTER TASK weekly_monday_task SUSPEND;
-- ALTER TASK monthly_first_day_task SUSPEND;
-- ALTER TASK serverless_task SUSPEND;
-- ALTER TASK conditional_stream_task SUSPEND;
-- ALTER TASK failing_task SUSPEND;

-- TODO: Drop tasks
-- DROP TASK IF EXISTS etl_extract;
-- DROP TASK IF EXISTS etl_transform;
-- DROP TASK IF EXISTS etl_load;
-- DROP TASK IF EXISTS simple_log_task;
-- DROP TASK IF EXISTS daily_morning_task;
-- DROP TASK IF EXISTS weekly_monday_task;
-- DROP TASK IF EXISTS monthly_first_day_task;
-- DROP TASK IF EXISTS root_process_sales;
-- DROP TASK IF EXISTS child_create_summary;
-- DROP TASK IF EXISTS child_log_completion;
-- DROP TASK IF EXISTS serverless_task;
-- DROP TASK IF EXISTS conditional_stream_task;
-- DROP TASK IF EXISTS failing_task;

-- TODO: Drop tables
-- DROP TABLE IF EXISTS sales_raw;
-- DROP TABLE IF EXISTS sales_processed;
-- DROP TABLE IF EXISTS sales_summary;
-- DROP TABLE IF EXISTS sales_staging;
-- DROP TABLE IF EXISTS task_log;
-- DROP TABLE IF EXISTS etl_error_log;
-- DROP STREAM IF EXISTS sales_stream;
