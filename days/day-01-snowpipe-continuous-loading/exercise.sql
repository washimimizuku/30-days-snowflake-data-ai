/*
Day 1: Snowpipe & Continuous Data Loading - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Exercise 1: Setup Environment (5 min)
-- ============================================================================

-- TODO: Create database for bootcamp
-- CREATE DATABASE IF NOT EXISTS ?;

-- TODO: Use the database
-- USE DATABASE ?;

-- TODO: Create schema for Day 1
-- CREATE SCHEMA IF NOT EXISTS ?;

-- TODO: Use the schema
-- USE SCHEMA ?;

-- TODO: Create warehouse for setup tasks
-- CREATE WAREHOUSE IF NOT EXISTS ?
--   WAREHOUSE_SIZE = 'XSMALL'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE;

-- TODO: Use the warehouse
-- USE WAREHOUSE ?;

-- TODO: Create target table for customer events
-- CREATE OR REPLACE TABLE customer_events (
--   event_id VARCHAR(50),
--   customer_id VARCHAR(50),
--   event_type VARCHAR(50),
--   event_timestamp TIMESTAMP_NTZ,
--   event_data VARIANT,
--   loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
-- );


-- ============================================================================
-- Exercise 2: Create Storage Integration (10 min)
-- ============================================================================

-- TODO: Create storage integration for S3
-- Note: Replace YOUR_AWS_ACCOUNT and your-bucket-name with actual values
-- CREATE OR REPLACE STORAGE INTEGRATION s3_integration
--   TYPE = EXTERNAL_STAGE
--   STORAGE_PROVIDER = 'S3'
--   ENABLED = TRUE
--   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_AWS_ACCOUNT:role/snowflake-s3-role'
--   STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket-name/');

-- TODO: Get the IAM user for Snowflake (use this in AWS IAM trust policy)
-- DESC STORAGE INTEGRATION s3_integration;

-- TODO: Create file format for JSON
-- CREATE OR REPLACE FILE FORMAT json_format
--   TYPE = 'JSON'
--   COMPRESSION = 'AUTO'
--   STRIP_OUTER_ARRAY = TRUE;

-- TODO: Create external stage
-- CREATE OR REPLACE STAGE s3_stage
--   STORAGE_INTEGRATION = s3_integration
--   URL = 's3://your-bucket-name/'
--   FILE_FORMAT = json_format;

-- TODO: Test stage (list files)
-- LIST @s3_stage;


-- ============================================================================
-- Exercise 3: Manual Load Test (5 min)
-- ============================================================================

-- TODO: Manually load data using COPY command
-- COPY INTO customer_events
-- FROM @s3_stage
-- FILE_FORMAT = json_format
-- PATTERN = '.*customer_events_.*[.]json';

-- TODO: Verify data loaded
-- SELECT * FROM customer_events;

-- TODO: Check load history
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--   TABLE_NAME => 'CUSTOMER_EVENTS',
--   START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
-- ));

-- TODO: Count rows loaded
-- SELECT COUNT(*) as total_rows FROM customer_events;

-- TODO: Truncate table for Snowpipe test
-- TRUNCATE TABLE customer_events;


-- ============================================================================
-- Exercise 4: Create Snowpipe (10 min)
-- ============================================================================

-- TODO: Create pipe with auto-ingest
-- Note: Replace YOUR_ACCOUNT and your-topic with actual SNS topic ARN
-- CREATE OR REPLACE PIPE customer_events_pipe
--   AUTO_INGEST = TRUE
--   AWS_SNS_TOPIC = 'arn:aws:sns:us-east-1:YOUR_ACCOUNT:your-topic'
-- AS
--   COPY INTO customer_events
--   FROM @s3_stage
--   FILE_FORMAT = json_format
--   MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- TODO: Show pipe details
-- SHOW PIPES;

-- TODO: Get pipe status and notification channel
-- SELECT SYSTEM$PIPE_STATUS('customer_events_pipe');

-- TODO: Describe the pipe
-- DESC PIPE customer_events_pipe;


-- ============================================================================
-- Exercise 5: Test Auto-Ingest (5 min)
-- ============================================================================

-- After uploading new files to S3, wait 1-2 minutes then run:

-- TODO: Check pipe status
-- SELECT SYSTEM$PIPE_STATUS('customer_events_pipe');

-- TODO: Check if data loaded
-- SELECT COUNT(*) FROM customer_events;

-- TODO: View recent data
-- SELECT * FROM customer_events ORDER BY loaded_at DESC LIMIT 10;

-- TODO: View load history
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--   TABLE_NAME => 'CUSTOMER_EVENTS',
--   START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
-- ));


-- ============================================================================
-- Exercise 6: Error Handling (5 min)
-- ============================================================================

-- TODO: Check for load errors
-- SELECT *
-- FROM TABLE(VALIDATE_PIPE_LOAD(
--   PIPE_NAME => 'customer_events_pipe',
--   START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
-- ));

-- TODO: View detailed error messages
-- SELECT 
--   FILE_NAME,
--   STATUS,
--   FIRST_ERROR_MESSAGE,
--   FIRST_ERROR_LINE_NUMBER,
--   FIRST_ERROR_CHARACTER_POS,
--   ERROR_COUNT,
--   ERROR_LIMIT
-- FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--   TABLE_NAME => 'CUSTOMER_EVENTS',
--   START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
-- ))
-- WHERE STATUS = 'LOAD_FAILED';

-- TODO: Check files that were partially loaded
-- SELECT 
--   FILE_NAME,
--   ROW_COUNT,
--   ROW_PARSED,
--   FIRST_ERROR_MESSAGE
-- FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--   TABLE_NAME => 'CUSTOMER_EVENTS',
--   START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
-- ))
-- WHERE STATUS = 'PARTIALLY_LOADED';


-- ============================================================================
-- Exercise 7: Monitoring Dashboard (5 min)
-- ============================================================================

-- TODO: Load summary by hour
-- SELECT 
--   DATE_TRUNC('hour', loaded_at) as load_hour,
--   COUNT(*) as rows_loaded,
--   COUNT(DISTINCT event_type) as event_types,
--   COUNT(DISTINCT customer_id) as unique_customers
-- FROM customer_events
-- GROUP BY 1
-- ORDER BY 1 DESC;

-- TODO: Pipe performance metrics
-- SELECT 
--   PIPE_NAME,
--   COUNT(*) as files_loaded,
--   SUM(ROW_COUNT) as total_rows,
--   AVG(ROW_COUNT) as avg_rows_per_file,
--   MIN(LAST_LOAD_TIME) as first_load,
--   MAX(LAST_LOAD_TIME) as last_load
-- FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
-- WHERE PIPE_NAME = 'CUSTOMER_EVENTS_PIPE'
--   AND START_TIME >= DATEADD(day, -1, CURRENT_TIMESTAMP())
-- GROUP BY 1;

-- TODO: Error rate calculation
-- SELECT 
--   DATE_TRUNC('hour', START_TIME) as hour,
--   COUNT(*) as total_files,
--   SUM(CASE WHEN STATUS = 'LOADED' THEN 1 ELSE 0 END) as successful_files,
--   SUM(CASE WHEN STATUS = 'LOAD_FAILED' THEN 1 ELSE 0 END) as failed_files,
--   ROUND(failed_files / NULLIF(total_files, 0) * 100, 2) as error_rate_pct
-- FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--   TABLE_NAME => 'CUSTOMER_EVENTS',
--   START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
-- ))
-- GROUP BY 1
-- ORDER BY 1 DESC;

-- TODO: Credit usage (requires ACCOUNT_USAGE access)
-- SELECT 
--   DATE_TRUNC('day', START_TIME) as day,
--   PIPE_NAME,
--   SUM(CREDITS_USED) as total_credits,
--   ROUND(total_credits * 3, 2) as estimated_cost_usd  -- Assuming $3/credit
-- FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
-- WHERE PIPE_NAME = 'CUSTOMER_EVENTS_PIPE'
--   AND START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
-- GROUP BY 1, 2
-- ORDER BY 1 DESC;


-- ============================================================================
-- Bonus Challenge: Advanced Monitoring
-- ============================================================================

-- TODO: Create a view for real-time monitoring
-- CREATE OR REPLACE VIEW pipe_monitoring AS
-- SELECT 
--   CURRENT_TIMESTAMP() as check_time,
--   'customer_events_pipe' as pipe_name,
--   (SELECT COUNT(*) FROM customer_events) as total_rows,
--   (SELECT MAX(loaded_at) FROM customer_events) as last_load_time,
--   DATEDIFF(minute, last_load_time, CURRENT_TIMESTAMP()) as minutes_since_last_load
-- ;

-- TODO: Query the monitoring view
-- SELECT * FROM pipe_monitoring;

-- TODO: Pause the pipe (for testing)
-- ALTER PIPE customer_events_pipe SET PIPE_EXECUTION_PAUSED = TRUE;

-- TODO: Resume the pipe
-- ALTER PIPE customer_events_pipe SET PIPE_EXECUTION_PAUSED = FALSE;

-- TODO: Refresh the pipe manually (forces check for new files)
-- ALTER PIPE customer_events_pipe REFRESH;


-- ============================================================================
-- Cleanup (Optional - only if you want to remove everything)
-- ============================================================================

-- TODO: Drop pipe
-- DROP PIPE IF EXISTS customer_events_pipe;

-- TODO: Drop stage
-- DROP STAGE IF EXISTS s3_stage;

-- TODO: Drop storage integration
-- DROP STORAGE INTEGRATION IF EXISTS s3_integration;

-- TODO: Drop table
-- DROP TABLE IF EXISTS customer_events;
