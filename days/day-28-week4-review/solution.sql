/*******************************************************************************
 * Day 28: Week 4 Review & Final Preparation - Solution
 * 
 * This file contains the completed cheat sheet template
 * 
 *******************************************************************************/

/*******************************************************************************
 * FINAL CHEAT SHEET - COMPLETE VERSION
 *******************************************************************************/

/*******************************************************************************
 * SECTION 1: Critical Numbers
 *******************************************************************************/

-- Time Travel
-- - Enterprise Edition: 90 days max
-- - Standard Edition: 1 day max
--
-- Fail-safe
-- - Period: 7 days
-- - Accessible by: Snowflake Support only (not users)
--
-- Clustering
-- - Maximum keys: 4
-- - Good clustering depth: < 10
--
-- Tasks
-- - Minimum schedule: 1 minute
-- - Maximum overlapping: Controlled by ALLOW_OVERLAPPING_EXECUTION
--
-- Caching
-- - Result cache TTL: 24 hours
-- - Requires: Exact query match
--
-- History Retention
-- - Snowpipe: 14 days
-- - Query (INFORMATION_SCHEMA): 7 days
-- - Query (ACCOUNT_USAGE): 365 days
--
-- Multi-cluster
-- - Maximum clusters: 10
--
-- Monitoring
-- - ACCOUNT_USAGE latency: 45 minutes to 3 hours
-- - INFORMATION_SCHEMA latency: Real-time

/*******************************************************************************
 * SECTION 2: Key Differences
 *******************************************************************************/

-- Streams vs. Dynamic Tables
-- - Streams: CDC (Change Data Capture), tracks changes with metadata columns
-- - Dynamic Tables: Materialized tables with automatic refresh based on TARGET_LAG
--
-- Masking vs. Row Access Policies
-- - Masking: Hides/transforms column values based on role
-- - Row Access: Filters which rows are visible based on role
--
-- EXECUTE AS CALLER vs. OWNER
-- - CALLER: Procedure runs with caller's privileges
-- - OWNER: Procedure runs with owner's privileges
--
-- Standard vs. Economy Scaling
-- - Standard: Scales up/down quickly, prioritizes performance
-- - Economy: Keeps clusters running longer, prioritizes cost savings
--
-- ACCOUNT_USAGE vs. INFORMATION_SCHEMA
-- - ACCOUNT_USAGE: 45 min to 3-hour latency, 365-day retention, historical data
-- - INFORMATION_SCHEMA: Real-time, 7-day retention, current state
--
-- Stored Procedures vs. UDFs
-- - Stored Procedures: Can contain DML (INSERT, UPDATE, DELETE), procedural logic
-- - UDFs: Cannot contain DML, only expressions and SELECT, return values
--
-- Time Travel vs. Fail-safe
-- - Time Travel: 0-90 days, user-accessible, query historical data, UNDROP
-- - Fail-safe: 7 days, Snowflake Support only, disaster recovery

/*******************************************************************************
 * SECTION 3: Common Patterns
 *******************************************************************************/

-- Stream + Task Pattern
-- 1. CREATE STREAM orders_stream ON TABLE orders;
-- 2. CREATE TASK process_task
--      WAREHOUSE = wh
--      SCHEDULE = '5 MINUTE'
--      WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
--    AS
--      MERGE INTO target USING orders_stream ...;
-- 3. ALTER TASK process_task RESUME;
-- 4. Stream offset advances after MERGE consumes data

-- Clustering Strategy
-- 1. Identify frequently filtered columns (WHERE, JOIN)
-- 2. Choose high-cardinality columns (many unique values)
-- 3. Maximum 4 columns in clustering key
-- 4. Monitor: SELECT SYSTEM$CLUSTERING_INFORMATION('table');
-- 5. Recluster if clustering_depth > 10

-- Security Policy Application
-- 1. CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
--      CASE WHEN CURRENT_ROLE() = 'ADMIN' THEN val ELSE '***' END;
-- 2. ALTER TABLE customers MODIFY COLUMN email SET MASKING POLICY email_mask;
-- 3. CREATE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
--      CASE WHEN CURRENT_ROLE() = 'MANAGER_NORTH' AND region = 'NORTH' THEN TRUE ELSE FALSE END;
-- 4. ALTER TABLE orders ADD ROW ACCESS POLICY regional_access ON (region);

/*******************************************************************************
 * SECTION 4: Troubleshooting Guide
 *******************************************************************************/

-- Task Failures
-- → Check: SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) WHERE name = 'task_name';
-- → Look for: error_code, error_message
-- → Verify: SYSTEM$STREAM_HAS_DATA(), task owner privileges, warehouse exists

-- Slow Queries
-- → Check: Query Profile in Snowsight
-- → Look for: Spilling to disk, low partition pruning %, inefficient joins
-- → Fix: Increase warehouse size, add clustering, optimize query, add filters

-- Snowpipe Issues
-- → Check: SELECT SYSTEM$PIPE_STATUS('pipe_name');
-- → Verify: S3 event notifications configured, file format correct, stage accessible
-- → Review: SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(pipe_name => 'pipe_name', ...));

-- High Costs
-- → Check: SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY;
-- → Identify: Which warehouse consuming most credits, query patterns
-- → Fix: Right-size warehouses, adjust auto-suspend, optimize queries, use result cache

/*******************************************************************************
 * SECTION 5: Exam Strategy
 *******************************************************************************/

-- Time Management
-- - 115 minutes for 65 questions = ~1.75 minutes per question
-- - First 60 min: Answer 35 questions
-- - Next 45 min: Answer 30 questions
-- - Last 10 min: Review flagged questions

-- Question Approach
-- 1. Read carefully (watch for "NOT", "EXCEPT", "LEAST")
-- 2. Eliminate obviously wrong answers
-- 3. Choose between remaining 2 options
-- 4. Don't overthink - trust first instinct
-- 5. Flag if unsure, move on, return later

-- Common Traps
-- - Absolute words: "always", "never", "must" → Usually wrong
-- - "All of the above" → Verify EACH option is correct
-- - Similar options → Look for subtle differences
-- - Scenario questions → Identify key requirement (cost, performance, security)

/*******************************************************************************
 * GOOD LUCK ON YOUR EXAM!
 *******************************************************************************/

-- You've completed 30 days of intensive preparation
-- You've practiced extensively with hands-on exercises
-- You've taken 2 full practice exams
-- You're ready for this!
--
-- Trust your preparation
-- Stay calm and focused
-- Read questions carefully
-- Manage your time
-- You've got this!
--
-- 🚀 GO PASS THAT EXAM! 🚀

