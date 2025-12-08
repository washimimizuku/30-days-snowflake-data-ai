/*
Day 1: Snowpipe & Continuous Data Loading - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Exercise 1: Setup Environment
-- ============================================================================

-- Create database for bootcamp
CREATE DATABASE IF NOT EXISTS BOOTCAMP_DB;

-- Use the database
USE DATABASE BOOTCAMP_DB;

-- Create schema for Day 1
CREATE SCHEMA IF NOT EXISTS DAY01_SNOWPIPE;

-- Use the schema
USE SCHEMA DAY01_SNOWPIPE;

-- Create warehouse for setup tasks
CREATE WAREHOUSE IF NOT EXISTS BOOTCAMP_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Use the warehouse
USE WAREHOUSE BOOTCAMP_WH;

-- Create target table for customer events
CREATE OR REPLACE TABLE customer_events (
  event_id VARCHAR(50),
  customer_id VARCHAR(50),
  event_type VARCHAR(50),
  event_timestamp TIMESTAMP_NTZ,
  event_data VARIANT,
  loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- ============================================================================
-- Exercise 2: Create Storage Integration
-- ============================================================================

-- Create storage integration for S3
-- Note: Replace YOUR_AWS_ACCOUNT and your-bucket-name with actual values
CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-bootcamp-day01/');

-- Get the IAM user for Snowflake (use this in AWS IAM trust policy)
DESC STORAGE INTEGRATION s3_integration;

-- Create file format for JSON
CREATE OR REPLACE FILE FORMAT json_format
  TYPE = 'JSON'
  COMPRESSION = 'AUTO'
  STRIP_OUTER_ARRAY = TRUE;

-- Create external stage
CREATE OR REPLACE STAGE s3_stage
  STORAGE_INTEGRATION = s3_integration
  URL = 's3://snowflake-bootcamp-day01/'
  FILE_FORMAT = json_format;

-- Test stage (list files)
LIST @s3_stage;


-- ============================================================================
-- Exercise 3: Manual Load Test
-- ============================================================================

-- Manually load data using COPY command
COPY INTO customer_events
FROM @s3_stage
FILE_FORMAT = json_format
PATTERN = '.*customer_events_.*[.]json';

-- Verify data loaded
SELECT * FROM customer_events;

-- Check load history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
));

-- Count rows loaded
SELECT COUNT(*) as total_rows FROM customer_events;

-- Truncate table for Snowpipe test
TRUNCATE TABLE customer_events;


-- ============================================================================
-- Exercise 4: Create Snowpipe
-- ============================================================================

-- Create pipe with auto-ingest
-- Note: Replace YOUR_ACCOUNT and your-topic with actual SNS topic ARN
CREATE OR REPLACE PIPE customer_events_pipe
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC = 'arn:aws:sns:us-east-1:123456789012:snowflake-bootcamp-topic'
AS
  COPY INTO customer_events
  FROM @s3_stage
  FILE_FORMAT = json_format
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- Show pipe details
SHOW PIPES;

-- Get pipe status and notification channel
SELECT SYSTEM$PIPE_STATUS('customer_events_pipe');

-- Describe the pipe
DESC PIPE customer_events_pipe;


-- ============================================================================
-- Exercise 5: Test Auto-Ingest
-- ============================================================================

-- After uploading new files to S3, wait 1-2 minutes then run:

-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('customer_events_pipe');

-- Check if data loaded
SELECT COUNT(*) FROM customer_events;

-- View recent data
SELECT * FROM customer_events ORDER BY loaded_at DESC LIMIT 10;

-- View load history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
));


-- ============================================================================
-- Exercise 6: Error Handling
-- ============================================================================

-- Check for load errors
SELECT *
FROM TABLE(VALIDATE_PIPE_LOAD(
  PIPE_NAME => 'customer_events_pipe',
  START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
));

-- View detailed error messages
SELECT 
  FILE_NAME,
  STATUS,
  FIRST_ERROR_MESSAGE,
  FIRST_ERROR_LINE_NUMBER,
  FIRST_ERROR_CHARACTER_POS,
  ERROR_COUNT,
  ERROR_LIMIT
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
))
WHERE STATUS = 'LOAD_FAILED';

-- Check files that were partially loaded
SELECT 
  FILE_NAME,
  ROW_COUNT,
  ROW_PARSED,
  FIRST_ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
))
WHERE STATUS = 'PARTIALLY_LOADED';


-- ============================================================================
-- Exercise 7: Monitoring Dashboard
-- ============================================================================

-- Load summary by hour
SELECT 
  DATE_TRUNC('hour', loaded_at) as load_hour,
  COUNT(*) as rows_loaded,
  COUNT(DISTINCT event_type) as event_types,
  COUNT(DISTINCT customer_id) as unique_customers
FROM customer_events
GROUP BY 1
ORDER BY 1 DESC;

-- Pipe performance metrics
SELECT 
  PIPE_NAME,
  COUNT(*) as files_loaded,
  SUM(ROW_COUNT) as total_rows,
  AVG(ROW_COUNT) as avg_rows_per_file,
  MIN(LAST_LOAD_TIME) as first_load,
  MAX(LAST_LOAD_TIME) as last_load
FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
WHERE PIPE_NAME = 'CUSTOMER_EVENTS_PIPE'
  AND START_TIME >= DATEADD(day, -1, CURRENT_TIMESTAMP())
GROUP BY 1;

-- Error rate calculation
SELECT 
  DATE_TRUNC('hour', START_TIME) as hour,
  COUNT(*) as total_files,
  SUM(CASE WHEN STATUS = 'LOADED' THEN 1 ELSE 0 END) as successful_files,
  SUM(CASE WHEN STATUS = 'LOAD_FAILED' THEN 1 ELSE 0 END) as failed_files,
  ROUND(failed_files / NULLIF(total_files, 0) * 100, 2) as error_rate_pct
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
))
GROUP BY 1
ORDER BY 1 DESC;

-- Credit usage (requires ACCOUNT_USAGE access)
SELECT 
  DATE_TRUNC('day', START_TIME) as day,
  PIPE_NAME,
  SUM(CREDITS_USED) as total_credits,
  ROUND(total_credits * 3, 2) as estimated_cost_usd  -- Assuming $3/credit
FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
WHERE PIPE_NAME = 'CUSTOMER_EVENTS_PIPE'
  AND START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC;


-- ============================================================================
-- Bonus Challenge: Advanced Monitoring
-- ============================================================================

-- Create a view for real-time monitoring
CREATE OR REPLACE VIEW pipe_monitoring AS
SELECT 
  CURRENT_TIMESTAMP() as check_time,
  'customer_events_pipe' as pipe_name,
  (SELECT COUNT(*) FROM customer_events) as total_rows,
  (SELECT MAX(loaded_at) FROM customer_events) as last_load_time,
  DATEDIFF(minute, last_load_time, CURRENT_TIMESTAMP()) as minutes_since_last_load
;

-- Query the monitoring view
SELECT * FROM pipe_monitoring;

-- Pause the pipe (for testing)
ALTER PIPE customer_events_pipe SET PIPE_EXECUTION_PAUSED = TRUE;

-- Resume the pipe
ALTER PIPE customer_events_pipe SET PIPE_EXECUTION_PAUSED = FALSE;

-- Refresh the pipe manually (forces check for new files)
ALTER PIPE customer_events_pipe REFRESH;


-- ============================================================================
-- Additional Monitoring Queries
-- ============================================================================

-- Check pipe execution history
SELECT 
  FILE_NAME,
  STAGE_LOCATION,
  LAST_LOAD_TIME,
  ROW_COUNT,
  ROW_PARSED,
  FILE_SIZE,
  STATUS,
  FIRST_ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
))
ORDER BY LAST_LOAD_TIME DESC;

-- Calculate average load time per file
SELECT 
  AVG(DATEDIFF(second, START_TIME, LAST_LOAD_TIME)) as avg_load_seconds,
  MIN(DATEDIFF(second, START_TIME, LAST_LOAD_TIME)) as min_load_seconds,
  MAX(DATEDIFF(second, START_TIME, LAST_LOAD_TIME)) as max_load_seconds
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
))
WHERE STATUS = 'LOADED';

-- Event type distribution
SELECT 
  event_type,
  COUNT(*) as event_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM customer_events
GROUP BY event_type
ORDER BY event_count DESC;

-- Customer activity summary
SELECT 
  customer_id,
  COUNT(*) as total_events,
  COUNT(DISTINCT event_type) as unique_event_types,
  MIN(event_timestamp) as first_event,
  MAX(event_timestamp) as last_event
FROM customer_events
GROUP BY customer_id
ORDER BY total_events DESC
LIMIT 10;


-- ============================================================================
-- Troubleshooting Queries
-- ============================================================================

-- Check if pipe is paused
SHOW PIPES LIKE 'customer_events_pipe';

-- Check storage integration status
SHOW STORAGE INTEGRATIONS LIKE 's3_integration';

-- Check stage configuration
SHOW STAGES LIKE 's3_stage';

-- Verify file format
SHOW FILE FORMATS LIKE 'json_format';

-- Check recent errors
SELECT 
  FILE_NAME,
  FIRST_ERROR_MESSAGE,
  ERROR_COUNT,
  LAST_LOAD_TIME
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'CUSTOMER_EVENTS',
  START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
))
WHERE STATUS IN ('LOAD_FAILED', 'PARTIALLY_LOADED')
ORDER BY LAST_LOAD_TIME DESC;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Drop pipe
-- DROP PIPE IF EXISTS customer_events_pipe;

-- Drop stage
-- DROP STAGE IF EXISTS s3_stage;

-- Drop storage integration
-- DROP STORAGE INTEGRATION IF EXISTS s3_integration;

-- Drop table
-- DROP TABLE IF EXISTS customer_events;

-- Drop file format
-- DROP FILE FORMAT IF EXISTS json_format;

-- Drop warehouse
-- DROP WAREHOUSE IF EXISTS BOOTCAMP_WH;

-- Drop schema
-- DROP SCHEMA IF EXISTS DAY01_SNOWPIPE;

-- Drop database
-- DROP DATABASE IF EXISTS BOOTCAMP_DB;
