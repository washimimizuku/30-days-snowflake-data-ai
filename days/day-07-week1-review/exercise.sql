/*
Day 7: Week 1 Review - End-to-End Pipeline Project
Build a complete production-grade data pipeline
Time: 90 minutes
*/

-- ============================================================================
-- PROJECT: Real-Time Customer Analytics Pipeline
-- ============================================================================
-- 
-- Scenario: E-commerce company needs real-time customer analytics
-- 
-- Requirements:
-- 1. Ingest customer events from S3 continuously (Snowpipe)
-- 2. Clean and validate events (Stream + Task)
-- 3. Maintain customer profiles with history (SCD Type 2)
-- 4. Calculate real-time metrics (Dynamic Table)
-- 5. Monitor pipeline health
--
-- Architecture:
-- S3 → Snowpipe → raw_events → Stream → Task → customer_events
--                                                      ↓
--                                                   Stream
--                                                      ↓
--                                                    Task
--                                                      ↓
--                                              customer_profiles (SCD2)
--                                                      ↓
--                                              customer_metrics (Dynamic)
-- ============================================================================


-- ============================================================================
-- STEP 1: Environment Setup (10 min)
-- ============================================================================

-- TODO: Create database and schema
-- CREATE DATABASE IF NOT EXISTS BOOTCAMP_DB;
-- USE DATABASE BOOTCAMP_DB;
-- CREATE SCHEMA IF NOT EXISTS WEEK1_PROJECT;
-- USE SCHEMA WEEK1_PROJECT;

-- TODO: Create or use warehouse
-- CREATE WAREHOUSE IF NOT EXISTS BOOTCAMP_WH
--   WAREHOUSE_SIZE = 'XSMALL'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE;
-- USE WAREHOUSE BOOTCAMP_WH;

-- TODO: Create storage integration for S3
-- Note: Replace with your actual AWS details
-- CREATE OR REPLACE STORAGE INTEGRATION s3_integration
--   TYPE = EXTERNAL_STAGE
--   STORAGE_PROVIDER = 'S3'
--   ENABLED = TRUE
--   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_ACCOUNT:role/snowflake-role'
--   STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket/events/');

-- TODO: Create file format for JSON events
-- CREATE OR REPLACE FILE FORMAT json_format
--   TYPE = 'JSON'
--   COMPRESSION = 'AUTO'
--   STRIP_OUTER_ARRAY = TRUE
--   DATE_FORMAT = 'AUTO'
--   TIMESTAMP_FORMAT = 'AUTO';

-- TODO: Create external stage
-- CREATE OR REPLACE STAGE events_stage
--   STORAGE_INTEGRATION = s3_integration
--   URL = 's3://your-bucket/events/'
--   FILE_FORMAT = json_format;

-- Test stage
-- LIST @events_stage;


-- ============================================================================
-- STEP 2: Ingestion Layer - Snowpipe (15 min)
-- ============================================================================

-- TODO: Create raw events table
-- This table receives all events from S3 via Snowpipe
-- CREATE OR REPLACE TABLE raw_events (
--   event_id VARCHAR(50),
--   customer_id VARCHAR(50),
--   event_type VARCHAR(50),
--   event_timestamp TIMESTAMP_NTZ,
--   product_id VARCHAR(50),
--   product_name VARCHAR(200),
--   category VARCHAR(100),
--   price DECIMAL(10,2),
--   quantity INT,
--   session_id VARCHAR(100),
--   device_type VARCHAR(50),
--   ip_address VARCHAR(50),
--   user_agent VARCHAR(500),
--   event_data VARIANT,
--   loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
--   file_name VARCHAR(500) DEFAULT METADATA$FILENAME,
--   file_row_number INT DEFAULT METADATA$FILE_ROW_NUMBER
-- );

-- TODO: Create Snowpipe for continuous loading
-- CREATE OR REPLACE PIPE events_pipe
--   AUTO_INGEST = TRUE
--   AWS_SNS_TOPIC = 'arn:aws:sns:us-east-1:YOUR_ACCOUNT:snowflake-events'
-- AS
--   COPY INTO raw_events
--   FROM @events_stage
--   FILE_FORMAT = json_format
--   MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
--   ON_ERROR = 'CONTINUE';

-- TODO: Check pipe status
-- SELECT SYSTEM$PIPE_STATUS('events_pipe');

-- TODO: Manually test load (for development)
-- COPY INTO raw_events
-- FROM @events_stage
-- FILE_FORMAT = json_format
-- ON_ERROR = 'CONTINUE';

-- TODO: Verify data loaded
-- SELECT COUNT(*) FROM raw_events;
-- SELECT * FROM raw_events LIMIT 10;

-- TODO: Check for load errors
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
--   TABLE_NAME => 'RAW_EVENTS',
--   START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
-- ))
-- WHERE STATUS = 'LOAD_FAILED';


-- ============================================================================
-- STEP 3: Processing Layer - Clean & Validate (20 min)
-- ============================================================================

-- TODO: Create cleaned events table
-- This table contains validated and enriched events
-- CREATE OR REPLACE TABLE customer_events (
--   event_id VARCHAR(50) PRIMARY KEY,
--   customer_id VARCHAR(50) NOT NULL,
--   event_type VARCHAR(50) NOT NULL,
--   event_timestamp TIMESTAMP_NTZ NOT NULL,
--   product_id VARCHAR(50),
--   product_name VARCHAR(200),
--   category VARCHAR(100),
--   price DECIMAL(10,2),
--   quantity INT,
--   revenue DECIMAL(10,2),  -- Calculated: price * quantity
--   session_id VARCHAR(100),
--   device_type VARCHAR(50),
--   is_mobile BOOLEAN,  -- Derived from device_type
--   event_date DATE,  -- Extracted from event_timestamp
--   event_hour INT,  -- Extracted from event_timestamp
--   processed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
-- );

-- TODO: Create stream on raw events
-- CREATE OR REPLACE STREAM raw_events_stream ON TABLE raw_events;

-- TODO: Create task to process events
-- This task:
-- 1. Validates data quality
-- 2. Enriches events with calculated fields
-- 3. Filters out invalid events
-- 4. Loads into customer_events table
-- 
-- CREATE OR REPLACE TASK process_events_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '1 MINUTE'
--   WHEN SYSTEM$STREAM_HAS_DATA('raw_events_stream')
-- AS
-- INSERT INTO customer_events (
--   event_id,
--   customer_id,
--   event_type,
--   event_timestamp,
--   product_id,
--   product_name,
--   category,
--   price,
--   quantity,
--   revenue,
--   session_id,
--   device_type,
--   is_mobile,
--   event_date,
--   event_hour
-- )
-- SELECT 
--   event_id,
--   customer_id,
--   event_type,
--   event_timestamp,
--   product_id,
--   product_name,
--   category,
--   price,
--   quantity,
--   price * COALESCE(quantity, 1) as revenue,
--   session_id,
--   device_type,
--   CASE 
--     WHEN LOWER(device_type) IN ('mobile', 'tablet', 'ios', 'android') THEN TRUE
--     ELSE FALSE
--   END as is_mobile,
--   DATE(event_timestamp) as event_date,
--   HOUR(event_timestamp) as event_hour
-- FROM raw_events_stream
-- WHERE METADATA$ACTION = 'INSERT'
--   AND event_id IS NOT NULL
--   AND customer_id IS NOT NULL
--   AND event_type IS NOT NULL
--   AND event_timestamp IS NOT NULL
--   AND event_timestamp <= CURRENT_TIMESTAMP()  -- Reject future timestamps
--   AND event_timestamp >= DATEADD(year, -1, CURRENT_TIMESTAMP());  -- Reject old data

-- TODO: Resume task
-- ALTER TASK process_events_task RESUME;

-- TODO: Test task execution
-- Wait 1-2 minutes, then check:
-- SELECT COUNT(*) FROM customer_events;
-- SELECT * FROM customer_events ORDER BY processed_at DESC LIMIT 10;

-- TODO: Check task history
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   TASK_NAME => 'PROCESS_EVENTS_TASK',
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ))
-- ORDER BY SCHEDULED_TIME DESC;


-- ============================================================================
-- STEP 4: CDC Layer - Customer Profiles with SCD Type 2 (20 min)
-- ============================================================================

-- TODO: Create customer profiles table (SCD Type 2)
-- This table maintains historical customer information
-- CREATE OR REPLACE TABLE customer_profiles (
--   profile_id INT AUTOINCREMENT PRIMARY KEY,
--   customer_id VARCHAR(50) NOT NULL,
--   email VARCHAR(200),
--   first_name VARCHAR(100),
--   last_name VARCHAR(100),
--   phone VARCHAR(50),
--   address VARCHAR(500),
--   city VARCHAR(100),
--   state VARCHAR(50),
--   country VARCHAR(50),
--   postal_code VARCHAR(20),
--   customer_tier VARCHAR(20),  -- bronze, silver, gold, platinum
--   total_orders INT DEFAULT 0,
--   total_revenue DECIMAL(12,2) DEFAULT 0,
--   first_order_date DATE,
--   last_order_date DATE,
--   is_active BOOLEAN DEFAULT TRUE,
--   effective_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
--   end_date TIMESTAMP_NTZ DEFAULT '9999-12-31'::TIMESTAMP_NTZ,
--   is_current BOOLEAN DEFAULT TRUE
-- );

-- TODO: Create stream on customer events
-- CREATE OR REPLACE STREAM customer_events_stream ON TABLE customer_events;

-- TODO: Create task to update customer profiles
-- This task implements SCD Type 2:
-- 1. Closes old records (set end_date, is_current = FALSE)
-- 2. Inserts new records with updated information
-- 
-- CREATE OR REPLACE TASK update_profiles_task
--   WAREHOUSE = BOOTCAMP_WH
--   SCHEDULE = '5 MINUTE'
--   AFTER process_events_task
--   WHEN SYSTEM$STREAM_HAS_DATA('customer_events_stream')
-- AS
-- BEGIN
--   -- Step 1: Close old records for customers with changes
--   UPDATE customer_profiles
--   SET 
--     end_date = CURRENT_TIMESTAMP(),
--     is_current = FALSE
--   WHERE customer_id IN (
--     SELECT DISTINCT customer_id 
--     FROM customer_events_stream
--     WHERE METADATA$ACTION = 'INSERT'
--       AND event_type IN ('purchase', 'profile_update')
--   )
--   AND is_current = TRUE;
--   
--   -- Step 2: Insert new records with updated metrics
--   INSERT INTO customer_profiles (
--     customer_id,
--     customer_tier,
--     total_orders,
--     total_revenue,
--     first_order_date,
--     last_order_date,
--     is_active,
--     effective_date,
--     is_current
--   )
--   SELECT 
--     customer_id,
--     CASE 
--       WHEN SUM(revenue) >= 10000 THEN 'platinum'
--       WHEN SUM(revenue) >= 5000 THEN 'gold'
--       WHEN SUM(revenue) >= 1000 THEN 'silver'
--       ELSE 'bronze'
--     END as customer_tier,
--     COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN event_id END) as total_orders,
--     SUM(revenue) as total_revenue,
--     MIN(CASE WHEN event_type = 'purchase' THEN event_date END) as first_order_date,
--     MAX(CASE WHEN event_type = 'purchase' THEN event_date END) as last_order_date,
--     TRUE as is_active,
--     CURRENT_TIMESTAMP() as effective_date,
--     TRUE as is_current
--   FROM customer_events
--   WHERE customer_id IN (
--     SELECT DISTINCT customer_id 
--     FROM customer_events_stream
--     WHERE METADATA$ACTION = 'INSERT'
--   )
--   GROUP BY customer_id;
-- END;

-- TODO: Resume task
-- ALTER TASK update_profiles_task RESUME;

-- TODO: Verify SCD Type 2 implementation
-- Check current profiles:
-- SELECT * FROM customer_profiles WHERE is_current = TRUE;

-- Check historical profiles:
-- SELECT * FROM customer_profiles WHERE is_current = FALSE;

-- View profile history for a specific customer:
-- SELECT 
--   customer_id,
--   customer_tier,
--   total_orders,
--   total_revenue,
--   effective_date,
--   end_date,
--   is_current
-- FROM customer_profiles
-- WHERE customer_id = 'CUST001'
-- ORDER BY effective_date DESC;


-- ============================================================================
-- STEP 5: Analytics Layer - Dynamic Tables (15 min)
-- ============================================================================

-- TODO: Create dynamic table for customer metrics
-- This table automatically refreshes with latest customer analytics
-- CREATE OR REPLACE DYNAMIC TABLE customer_metrics
--   TARGET_LAG = '5 minutes'
--   WAREHOUSE = BOOTCAMP_WH
-- AS
-- SELECT 
--   cp.customer_id,
--   cp.customer_tier,
--   cp.total_orders,
--   cp.total_revenue,
--   cp.first_order_date,
--   cp.last_order_date,
--   DATEDIFF(day, cp.first_order_date, cp.last_order_date) as customer_lifetime_days,
--   CASE 
--     WHEN cp.total_orders > 0 THEN cp.total_revenue / cp.total_orders
--     ELSE 0
--   END as avg_order_value,
--   DATEDIFF(day, cp.last_order_date, CURRENT_DATE()) as days_since_last_order,
--   CASE 
--     WHEN DATEDIFF(day, cp.last_order_date, CURRENT_DATE()) <= 30 THEN 'Active'
--     WHEN DATEDIFF(day, cp.last_order_date, CURRENT_DATE()) <= 90 THEN 'At Risk'
--     ELSE 'Churned'
--   END as customer_status,
--   -- Recent activity (last 30 days)
--   recent.orders_last_30d,
--   recent.revenue_last_30d,
--   recent.unique_categories_last_30d,
--   recent.mobile_orders_last_30d,
--   -- Favorite category
--   fav.favorite_category,
--   fav.favorite_category_orders
-- FROM customer_profiles cp
-- LEFT JOIN (
--   SELECT 
--     customer_id,
--     COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN event_id END) as orders_last_30d,
--     SUM(revenue) as revenue_last_30d,
--     COUNT(DISTINCT category) as unique_categories_last_30d,
--     COUNT(DISTINCT CASE WHEN is_mobile = TRUE AND event_type = 'purchase' THEN event_id END) as mobile_orders_last_30d
--   FROM customer_events
--   WHERE event_date >= DATEADD(day, -30, CURRENT_DATE())
--   GROUP BY customer_id
-- ) recent ON cp.customer_id = recent.customer_id
-- LEFT JOIN (
--   SELECT 
--     customer_id,
--     category as favorite_category,
--     COUNT(*) as favorite_category_orders,
--     ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) as rn
--   FROM customer_events
--   WHERE event_type = 'purchase'
--     AND category IS NOT NULL
--   GROUP BY customer_id, category
--   QUALIFY rn = 1
-- ) fav ON cp.customer_id = fav.customer_id
-- WHERE cp.is_current = TRUE;

-- TODO: Query dynamic table
-- SELECT * FROM customer_metrics LIMIT 10;

-- TODO: Check dynamic table refresh history
-- SELECT *
-- FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
--   NAME => 'CUSTOMER_METRICS'
-- ))
-- ORDER BY REFRESH_START_TIME DESC;

-- TODO: Create additional dynamic table for daily metrics
-- CREATE OR REPLACE DYNAMIC TABLE daily_metrics
--   TARGET_LAG = '10 minutes'
--   WAREHOUSE = BOOTCAMP_WH
-- AS
-- SELECT 
--   event_date,
--   COUNT(DISTINCT customer_id) as unique_customers,
--   COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN event_id END) as total_orders,
--   SUM(CASE WHEN event_type = 'purchase' THEN revenue ELSE 0 END) as total_revenue,
--   AVG(CASE WHEN event_type = 'purchase' THEN revenue END) as avg_order_value,
--   COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN session_id END) as total_sessions,
--   COUNT(DISTINCT CASE WHEN is_mobile = TRUE THEN customer_id END) as mobile_users,
--   COUNT(DISTINCT category) as unique_categories
-- FROM customer_events
-- GROUP BY event_date;

-- TODO: Query daily metrics
-- SELECT * FROM daily_metrics ORDER BY event_date DESC LIMIT 7;


-- ============================================================================
-- STEP 6: Monitoring & Observability (10 min)
-- ============================================================================

-- TODO: Create monitoring view for pipeline health
-- CREATE OR REPLACE VIEW pipeline_health AS
-- SELECT 
--   'Snowpipe' as component,
--   'events_pipe' as name,
--   (SELECT COUNT(*) FROM raw_events) as total_records,
--   (SELECT MAX(loaded_at) FROM raw_events) as last_update,
--   DATEDIFF(minute, last_update, CURRENT_TIMESTAMP()) as minutes_since_update,
--   CASE 
--     WHEN minutes_since_update <= 5 THEN 'Healthy'
--     WHEN minutes_since_update <= 15 THEN 'Warning'
--     ELSE 'Critical'
--   END as health_status
-- UNION ALL
-- SELECT 
--   'Processing Task' as component,
--   'process_events_task' as name,
--   (SELECT COUNT(*) FROM customer_events) as total_records,
--   (SELECT MAX(processed_at) FROM customer_events) as last_update,
--   DATEDIFF(minute, last_update, CURRENT_TIMESTAMP()) as minutes_since_update,
--   CASE 
--     WHEN minutes_since_update <= 10 THEN 'Healthy'
--     WHEN minutes_since_update <= 30 THEN 'Warning'
--     ELSE 'Critical'
--   END as health_status
-- UNION ALL
-- SELECT 
--   'Customer Profiles' as component,
--   'customer_profiles' as name,
--   (SELECT COUNT(*) FROM customer_profiles WHERE is_current = TRUE) as total_records,
--   (SELECT MAX(effective_date) FROM customer_profiles) as last_update,
--   DATEDIFF(minute, last_update, CURRENT_TIMESTAMP()) as minutes_since_update,
--   CASE 
--     WHEN minutes_since_update <= 15 THEN 'Healthy'
--     WHEN minutes_since_update <= 60 THEN 'Warning'
--     ELSE 'Critical'
--   END as health_status;

-- TODO: Query pipeline health
-- SELECT * FROM pipeline_health;

-- TODO: Create data quality checks
-- Check for duplicate events:
-- SELECT 
--   event_id,
--   COUNT(*) as duplicate_count
-- FROM customer_events
-- GROUP BY event_id
-- HAVING COUNT(*) > 1;

-- Check for missing customer IDs:
-- SELECT COUNT(*) as missing_customer_ids
-- FROM raw_events
-- WHERE customer_id IS NULL;

-- Check for invalid timestamps:
-- SELECT COUNT(*) as invalid_timestamps
-- FROM raw_events
-- WHERE event_timestamp > CURRENT_TIMESTAMP()
--    OR event_timestamp < DATEADD(year, -2, CURRENT_TIMESTAMP());

-- TODO: Create cost monitoring query
-- SELECT 
--   DATE_TRUNC('day', START_TIME) as day,
--   WAREHOUSE_NAME,
--   SUM(CREDITS_USED) as total_credits,
--   ROUND(total_credits * 3, 2) as estimated_cost_usd
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND WAREHOUSE_NAME = 'BOOTCAMP_WH'
-- GROUP BY 1, 2
-- ORDER BY 1 DESC;

-- TODO: Create task execution monitoring
-- SELECT 
--   NAME as task_name,
--   STATE,
--   SCHEDULED_TIME,
--   COMPLETED_TIME,
--   DATEDIFF(second, SCHEDULED_TIME, COMPLETED_TIME) as execution_seconds,
--   ERROR_CODE,
--   ERROR_MESSAGE
-- FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   SCHEDULED_TIME_RANGE_START => DATEADD(hour, -24, CURRENT_TIMESTAMP())
-- ))
-- WHERE NAME IN ('PROCESS_EVENTS_TASK', 'UPDATE_PROFILES_TASK')
-- ORDER BY SCHEDULED_TIME DESC;


-- ============================================================================
-- BONUS: Advanced Analytics Queries (Optional)
-- ============================================================================

-- TODO: Customer segmentation analysis
-- SELECT 
--   customer_tier,
--   customer_status,
--   COUNT(*) as customer_count,
--   AVG(total_revenue) as avg_revenue,
--   AVG(total_orders) as avg_orders,
--   AVG(avg_order_value) as avg_order_value
-- FROM customer_metrics
-- GROUP BY customer_tier, customer_status
-- ORDER BY customer_tier, customer_status;

-- TODO: Cohort analysis (customers by first order month)
-- SELECT 
--   DATE_TRUNC('month', first_order_date) as cohort_month,
--   COUNT(DISTINCT customer_id) as cohort_size,
--   SUM(total_revenue) as cohort_revenue,
--   AVG(total_orders) as avg_orders_per_customer
-- FROM customer_metrics
-- GROUP BY cohort_month
-- ORDER BY cohort_month DESC;

-- TODO: Product category performance
-- SELECT 
--   category,
--   COUNT(DISTINCT customer_id) as unique_customers,
--   COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN event_id END) as total_orders,
--   SUM(revenue) as total_revenue,
--   AVG(revenue) as avg_order_value
-- FROM customer_events
-- WHERE category IS NOT NULL
-- GROUP BY category
-- ORDER BY total_revenue DESC;

-- TODO: Mobile vs Desktop analysis
-- SELECT 
--   is_mobile,
--   COUNT(DISTINCT customer_id) as unique_customers,
--   COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN event_id END) as total_orders,
--   SUM(revenue) as total_revenue,
--   AVG(revenue) as avg_order_value
-- FROM customer_events
-- GROUP BY is_mobile;


-- ============================================================================
-- Cleanup (Optional - DO NOT RUN unless you want to remove everything)
-- ============================================================================

-- Suspend tasks first
-- ALTER TASK update_profiles_task SUSPEND;
-- ALTER TASK process_events_task SUSPEND;

-- Drop objects
-- DROP PIPE IF EXISTS events_pipe;
-- DROP TASK IF EXISTS update_profiles_task;
-- DROP TASK IF EXISTS process_events_task;
-- DROP STREAM IF EXISTS customer_events_stream;
-- DROP STREAM IF EXISTS raw_events_stream;
-- DROP DYNAMIC TABLE IF EXISTS daily_metrics;
-- DROP DYNAMIC TABLE IF EXISTS customer_metrics;
-- DROP TABLE IF EXISTS customer_profiles;
-- DROP TABLE IF EXISTS customer_events;
-- DROP TABLE IF EXISTS raw_events;
-- DROP VIEW IF EXISTS pipeline_health;
-- DROP STAGE IF EXISTS events_stage;
-- DROP FILE FORMAT IF EXISTS json_format;
-- DROP STORAGE INTEGRATION IF EXISTS s3_integration;


-- ============================================================================
-- PROJECT COMPLETION CHECKLIST
-- ============================================================================

-- [ ] Environment setup complete
-- [ ] Snowpipe created and loading data
-- [ ] Stream on raw events created
-- [ ] Task processing events successfully
-- [ ] Customer profiles table with SCD Type 2
-- [ ] Dynamic tables for analytics
-- [ ] Monitoring queries working
-- [ ] Pipeline health dashboard created
-- [ ] Data quality checks implemented
-- [ ] Cost monitoring in place
-- [ ] Documentation complete

-- Congratulations! You've built a complete production-grade data pipeline! 🎉
