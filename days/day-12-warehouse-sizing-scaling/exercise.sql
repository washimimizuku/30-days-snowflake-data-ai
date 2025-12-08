/*
Day 12: Warehouse Sizing & Scaling - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY12_WAREHOUSES;
USE SCHEMA DAY12_WAREHOUSES;

-- Create test table for exercises
CREATE OR REPLACE TABLE test_data (
  id INT,
  data VARCHAR(1000),
  created_date DATE
);

-- Insert sample data
INSERT INTO test_data
SELECT 
  SEQ4() as id,
  RANDSTR(1000, RANDOM()) as data,
  DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as created_date
FROM TABLE(GENERATOR(ROWCOUNT => 100000));


-- ============================================================================
-- Exercise 1: Create and Configure Warehouses (10 min)
-- ============================================================================

-- TODO: Create development warehouse (X-Small, aggressive suspend)
-- CREATE WAREHOUSE dev_wh WITH
--   WAREHOUSE_SIZE = 'XSMALL'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Development and testing warehouse';

-- TODO: Create ETL warehouse (Large, quick suspend)
-- CREATE WAREHOUSE etl_wh WITH
--   WAREHOUSE_SIZE = 'LARGE'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'ETL and batch processing';

-- TODO: Create BI warehouse (Medium, longer suspend)
-- CREATE WAREHOUSE bi_wh WITH
--   WAREHOUSE_SIZE = 'MEDIUM'
--   AUTO_SUSPEND = 300
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Business intelligence and reporting';

-- TODO: View all warehouses
-- SHOW WAREHOUSES;

-- TODO: Check warehouse details
-- DESCRIBE WAREHOUSE dev_wh;
-- DESCRIBE WAREHOUSE etl_wh;
-- DESCRIBE WAREHOUSE bi_wh;


-- ============================================================================
-- Exercise 2: Test Scaling Behavior (10 min)
-- ============================================================================

-- TODO: Test X-Small warehouse
-- USE WAREHOUSE dev_wh;
-- 
-- SELECT COUNT(*), AVG(LENGTH(data))
-- FROM test_data;
-- 
-- -- Note execution time

-- TODO: Scale up to Small
-- ALTER WAREHOUSE dev_wh SET WAREHOUSE_SIZE = 'SMALL';
-- 
-- SELECT COUNT(*), AVG(LENGTH(data))
-- FROM test_data;
-- 
-- -- Compare execution time

-- TODO: Scale up to Medium
-- ALTER WAREHOUSE dev_wh SET WAREHOUSE_SIZE = 'MEDIUM';
-- 
-- SELECT COUNT(*), AVG(LENGTH(data))
-- FROM test_data;
-- 
-- -- Compare execution time

-- TODO: Scale back down
-- ALTER WAREHOUSE dev_wh SET WAREHOUSE_SIZE = 'XSMALL';

-- TODO: Test complex query on different sizes
-- USE WAREHOUSE dev_wh;
-- 
-- SELECT 
--   created_date,
--   COUNT(*) as record_count,
--   AVG(LENGTH(data)) as avg_data_length,
--   MIN(id) as min_id,
--   MAX(id) as max_id
-- FROM test_data
-- GROUP BY created_date
-- ORDER BY created_date;

-- TODO: Compare execution times in Query History
-- Go to Query History and compare the same query on different warehouse sizes


-- ============================================================================
-- Exercise 3: Configure Multi-Cluster Warehouses (10 min)
-- ============================================================================

-- TODO: Create multi-cluster warehouse with Standard policy
-- CREATE WAREHOUSE multi_standard_wh WITH
--   WAREHOUSE_SIZE = 'MEDIUM'
--   MIN_CLUSTER_COUNT = 1
--   MAX_CLUSTER_COUNT = 3
--   SCALING_POLICY = 'STANDARD'
--   AUTO_SUSPEND = 300
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Multi-cluster with Standard scaling';

-- TODO: Create multi-cluster warehouse with Economy policy
-- CREATE WAREHOUSE multi_economy_wh WITH
--   WAREHOUSE_SIZE = 'MEDIUM'
--   MIN_CLUSTER_COUNT = 1
--   MAX_CLUSTER_COUNT = 3
--   SCALING_POLICY = 'ECONOMY'
--   AUTO_SUSPEND = 300
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Multi-cluster with Economy scaling';

-- TODO: View multi-cluster configuration
-- SHOW WAREHOUSES LIKE 'multi_%';

-- TODO: Modify multi-cluster settings
-- ALTER WAREHOUSE multi_standard_wh SET
--   MIN_CLUSTER_COUNT = 2
--   MAX_CLUSTER_COUNT = 5;

-- TODO: Test multi-cluster behavior
-- Note: Requires multiple concurrent queries to trigger scaling
-- USE WAREHOUSE multi_standard_wh;
-- 
-- -- Run multiple queries concurrently (in different sessions)
-- SELECT COUNT(*) FROM test_data WHERE created_date >= '2024-01-01';


-- ============================================================================
-- Exercise 4: Monitor Warehouse Utilization (10 min)
-- ============================================================================

-- TODO: Check warehouse credit consumption
-- SELECT 
--   warehouse_name,
--   DATE(start_time) as date,
--   SUM(credits_used) as total_credits,
--   ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND warehouse_name IN ('DEV_WH', 'ETL_WH', 'BI_WH')
-- GROUP BY 1, 2
-- ORDER BY 1, 2 DESC;

-- TODO: Check warehouse load history
-- SELECT 
--   warehouse_name,
--   DATE(start_time) as date,
--   AVG(avg_running) as avg_queries_running,
--   AVG(avg_queued_load) as avg_queries_queued,
--   AVG(avg_queued_provisioning) as avg_provisioning_queue
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND warehouse_name IN ('DEV_WH', 'ETL_WH', 'BI_WH')
-- GROUP BY 1, 2
-- ORDER BY 1, 2 DESC;

-- TODO: Calculate warehouse efficiency
-- SELECT 
--   warehouse_name,
--   COUNT(DISTINCT query_id) as query_count,
--   SUM(execution_time) / 1000 as total_execution_seconds,
--   AVG(execution_time) / 1000 as avg_execution_seconds
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND warehouse_name IN ('DEV_WH', 'ETL_WH', 'BI_WH')
-- GROUP BY 1
-- ORDER BY 2 DESC;

-- TODO: Identify queued queries
-- SELECT 
--   warehouse_name,
--   query_id,
--   query_text,
--   queued_overload_time,
--   queued_provisioning_time,
--   execution_time
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE start_time >= DATEADD(day, -1, CURRENT_TIMESTAMP())
--   AND (queued_overload_time > 0 OR queued_provisioning_time > 0)
-- ORDER BY queued_overload_time DESC
-- LIMIT 10;

-- TODO: Create monitoring view
-- CREATE OR REPLACE VIEW warehouse_metrics AS
-- SELECT 
--   w.warehouse_name,
--   w.warehouse_size,
--   w.min_cluster_count,
--   w.max_cluster_count,
--   w.auto_suspend,
--   m.total_credits_7d,
--   m.estimated_cost_7d_usd,
--   q.query_count_7d,
--   q.avg_execution_seconds
-- FROM (
--   SELECT name as warehouse_name, size as warehouse_size,
--          min_cluster_count, max_cluster_count, auto_suspend
--   FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
--   WHERE deleted IS NULL
-- ) w
-- LEFT JOIN (
--   SELECT 
--     warehouse_name,
--     SUM(credits_used) as total_credits_7d,
--     ROUND(SUM(credits_used) * 3, 2) as estimated_cost_7d_usd
--   FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
--   WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   GROUP BY warehouse_name
-- ) m ON w.warehouse_name = m.warehouse_name
-- LEFT JOIN (
--   SELECT 
--     warehouse_name,
--     COUNT(*) as query_count_7d,
--     AVG(execution_time) / 1000 as avg_execution_seconds
--   FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
--   WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   GROUP BY warehouse_name
-- ) q ON w.warehouse_name = q.warehouse_name;

-- TODO: Query monitoring view
-- SELECT * FROM warehouse_metrics
-- ORDER BY total_credits_7d DESC;


-- ============================================================================
-- Exercise 5: Implement Resource Monitors (5 min)
-- ============================================================================

-- TODO: Create resource monitor for development
-- CREATE RESOURCE MONITOR dev_monthly_limit WITH
--   CREDIT_QUOTA = 100
--   FREQUENCY = MONTHLY
--   START_TIMESTAMP = IMMEDIATELY
--   TRIGGERS
--     ON 75 PERCENT DO NOTIFY
--     ON 90 PERCENT DO NOTIFY
--     ON 100 PERCENT DO SUSPEND
--     ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- TODO: Assign resource monitor to warehouse
-- ALTER WAREHOUSE dev_wh SET RESOURCE_MONITOR = dev_monthly_limit;

-- TODO: Create resource monitor for production
-- CREATE RESOURCE MONITOR prod_monthly_limit WITH
--   CREDIT_QUOTA = 1000
--   FREQUENCY = MONTHLY
--   START_TIMESTAMP = IMMEDIATELY
--   TRIGGERS
--     ON 80 PERCENT DO NOTIFY
--     ON 100 PERCENT DO NOTIFY
--     ON 120 PERCENT DO SUSPEND_IMMEDIATE;

-- TODO: Assign to production warehouses
-- ALTER WAREHOUSE etl_wh SET RESOURCE_MONITOR = prod_monthly_limit;
-- ALTER WAREHOUSE bi_wh SET RESOURCE_MONITOR = prod_monthly_limit;

-- TODO: View resource monitors
-- SHOW RESOURCE MONITORS;

-- TODO: Check resource monitor usage
-- SELECT 
--   name,
--   credit_quota,
--   used_credits,
--   remaining_credits,
--   ROUND((used_credits / NULLIF(credit_quota, 0)) * 100, 2) as usage_pct
-- FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
-- WHERE start_time >= DATEADD(month, -1, CURRENT_TIMESTAMP());


-- ============================================================================
-- Exercise 6: Right-Size Warehouses (5 min)
-- ============================================================================

-- TODO: Analyze warehouse utilization
-- SELECT 
--   warehouse_name,
--   warehouse_size,
--   SUM(credits_used) as total_credits,
--   COUNT(DISTINCT DATE(start_time)) as active_days,
--   ROUND(SUM(credits_used) / NULLIF(COUNT(DISTINCT DATE(start_time)), 0), 2) as avg_credits_per_day
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
-- GROUP BY 1, 2
-- ORDER BY 3 DESC;

-- TODO: Identify underutilized warehouses
-- SELECT 
--   warehouse_name,
--   SUM(credits_used) as total_credits,
--   COUNT(*) as query_count,
--   ROUND(SUM(credits_used) / NULLIF(COUNT(*), 0), 4) as credits_per_query
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
-- GROUP BY 1
-- HAVING query_count < 100  -- Low query count
-- ORDER BY 2 DESC;

-- TODO: Identify oversized warehouses
-- Look for warehouses with:
-- - Low query count
-- - High credits per query
-- - Minimal queuing
-- Consider downsizing

-- TODO: Identify undersized warehouses
-- SELECT 
--   warehouse_name,
--   COUNT(*) as queued_queries,
--   AVG(queued_overload_time) as avg_queue_time_ms,
--   MAX(queued_overload_time) as max_queue_time_ms
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND queued_overload_time > 0
-- GROUP BY 1
-- ORDER BY 2 DESC;


-- ============================================================================
-- Bonus: Cost Optimization Analysis (Optional)
-- ============================================================================

-- TODO: Calculate potential savings from auto-suspend optimization
-- SELECT 
--   warehouse_name,
--   auto_suspend,
--   SUM(credits_used) as total_credits,
--   -- Estimate savings if auto-suspend was 60 seconds
--   CASE 
--     WHEN auto_suspend > 60 THEN 
--       ROUND(SUM(credits_used) * 0.1, 2)  -- Estimate 10% savings
--     ELSE 0
--   END as potential_savings_credits
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY wm
-- JOIN SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES w 
--   ON wm.warehouse_name = w.name
-- WHERE wm.start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
--   AND w.deleted IS NULL
-- GROUP BY 1, 2
-- ORDER BY 4 DESC;

-- TODO: Identify opportunities for warehouse consolidation
-- SELECT 
--   warehouse_name,
--   COUNT(DISTINCT DATE(start_time)) as active_days,
--   SUM(credits_used) as total_credits,
--   COUNT(*) as query_count
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
-- GROUP BY 1
-- HAVING active_days < 10  -- Rarely used
--   AND query_count < 100
-- ORDER BY 2;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Suspend warehouses
-- ALTER WAREHOUSE dev_wh SUSPEND;
-- ALTER WAREHOUSE etl_wh SUSPEND;
-- ALTER WAREHOUSE bi_wh SUSPEND;
-- ALTER WAREHOUSE multi_standard_wh SUSPEND;
-- ALTER WAREHOUSE multi_economy_wh SUSPEND;

-- Drop warehouses (careful!)
-- DROP WAREHOUSE IF EXISTS dev_wh;
-- DROP WAREHOUSE IF EXISTS etl_wh;
-- DROP WAREHOUSE IF EXISTS bi_wh;
-- DROP WAREHOUSE IF EXISTS multi_standard_wh;
-- DROP WAREHOUSE IF EXISTS multi_economy_wh;

-- Drop resource monitors
-- DROP RESOURCE MONITOR IF EXISTS dev_monthly_limit;
-- DROP RESOURCE MONITOR IF EXISTS prod_monthly_limit;

-- Drop test data
-- DROP TABLE IF EXISTS test_data;
-- DROP VIEW IF EXISTS warehouse_metrics;
