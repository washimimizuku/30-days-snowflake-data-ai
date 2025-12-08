/*
Day 8: Clustering & Micro-Partitions - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY08_CLUSTERING;
USE SCHEMA DAY08_CLUSTERING;
USE WAREHOUSE BOOTCAMP_WH;

-- Create large sample table (simulating multi-TB table)
CREATE OR REPLACE TABLE sales_data (
  sale_id INT,
  sale_date DATE,
  sale_timestamp TIMESTAMP_NTZ,
  customer_id INT,
  product_id INT,
  category VARCHAR(50),
  region VARCHAR(50),
  amount DECIMAL(10,2),
  quantity INT,
  discount_pct DECIMAL(5,2)
);

-- Insert sample data (in production, this would be millions/billions of rows)
INSERT INTO sales_data
SELECT 
  SEQ4() as sale_id,
  DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as sale_date,
  DATEADD(second, UNIFORM(0, 86400, RANDOM()), sale_date) as sale_timestamp,
  UNIFORM(1, 10000, RANDOM()) as customer_id,
  UNIFORM(1, 1000, RANDOM()) as product_id,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'Electronics'
    WHEN 2 THEN 'Clothing'
    WHEN 3 THEN 'Food'
    WHEN 4 THEN 'Home'
    ELSE 'Sports'
  END as category,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'NORTH'
    WHEN 2 THEN 'SOUTH'
    WHEN 3 THEN 'EAST'
    ELSE 'WEST'
  END as region,
  UNIFORM(10, 1000, RANDOM()) as amount,
  UNIFORM(1, 10, RANDOM()) as quantity,
  UNIFORM(0, 30, RANDOM()) as discount_pct
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Create additional test table
CREATE OR REPLACE TABLE events_data (
  event_id INT,
  event_timestamp TIMESTAMP_NTZ,
  event_date DATE,
  event_type VARCHAR(50),
  user_id INT,
  session_id VARCHAR(100),
  page_url VARCHAR(500),
  duration_seconds INT
);

-- Insert sample events
INSERT INTO events_data
SELECT 
  SEQ4() as event_id,
  DATEADD(second, UNIFORM(0, 31536000, RANDOM()), '2024-01-01'::TIMESTAMP_NTZ) as event_timestamp,
  DATE(event_timestamp) as event_date,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'page_view'
    WHEN 2 THEN 'click'
    WHEN 3 THEN 'purchase'
    ELSE 'logout'
  END as event_type,
  UNIFORM(1, 5000, RANDOM()) as user_id,
  'SESSION_' || UNIFORM(1, 20000, RANDOM()) as session_id,
  '/page/' || UNIFORM(1, 100, RANDOM()) as page_url,
  UNIFORM(1, 600, RANDOM()) as duration_seconds
FROM TABLE(GENERATOR(ROWCOUNT => 100000));


-- ============================================================================
-- Exercise 1: Analyze Micro-Partitions (5 min)
-- ============================================================================

-- TODO: Check table statistics
-- SELECT 
--   table_name,
--   row_count,
--   bytes,
--   ROUND(bytes / 1024 / 1024, 2) as size_mb
-- FROM INFORMATION_SCHEMA.TABLES
-- WHERE table_schema = 'DAY08_CLUSTERING'
--   AND table_name IN ('SALES_DATA', 'EVENTS_DATA');

-- TODO: Query to understand partition pruning
-- Run this query and check the query profile
-- SELECT * FROM sales_data WHERE sale_date = '2024-06-15';

-- TODO: Check how many partitions were scanned
-- Go to Query History → Click on query → View Profile
-- Note: Partitions scanned vs. Partitions total

-- TODO: Run query with broader date range
-- SELECT * FROM sales_data 
-- WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30';

-- TODO: Compare partitions scanned for both queries
-- Which query scanned more partitions? Why?


-- ============================================================================
-- Exercise 2: Implement Clustering Keys (10 min)
-- ============================================================================

-- TODO: Add clustering key on sale_date
-- ALTER TABLE sales_data CLUSTER BY (sale_date);

-- TODO: Check clustering information
-- SELECT SYSTEM$CLUSTERING_INFORMATION('sales_data', '(sale_date)');

-- TODO: Check clustering depth
-- SELECT SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date)');

-- TODO: Create table with clustering key from start
-- CREATE OR REPLACE TABLE orders_clustered (
--   order_id INT,
--   order_date DATE,
--   customer_id INT,
--   region VARCHAR(50),
--   amount DECIMAL(10,2)
-- )
-- CLUSTER BY (order_date);

-- TODO: Insert data into clustered table
-- INSERT INTO orders_clustered
-- SELECT 
--   SEQ4() as order_id,
--   DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as order_date,
--   UNIFORM(1, 5000, RANDOM()) as customer_id,
--   CASE UNIFORM(1, 4, RANDOM())
--     WHEN 1 THEN 'NORTH'
--     WHEN 2 THEN 'SOUTH'
--     WHEN 3 THEN 'EAST'
--     ELSE 'WEST'
--   END as region,
--   UNIFORM(50, 5000, RANDOM()) as amount
-- FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- TODO: Add multi-column clustering
-- ALTER TABLE sales_data CLUSTER BY (sale_date, region);

-- TODO: Check new clustering information
-- SELECT SYSTEM$CLUSTERING_INFORMATION('sales_data', '(sale_date, region)');


-- ============================================================================
-- Exercise 3: Analyze Clustering Metrics (10 min)
-- ============================================================================

-- TODO: Parse clustering information JSON
-- SELECT 
--   PARSE_JSON(SYSTEM$CLUSTERING_INFORMATION('sales_data', '(sale_date)')) as cluster_info;

-- TODO: Extract specific metrics from clustering info
-- WITH cluster_data AS (
--   SELECT PARSE_JSON(SYSTEM$CLUSTERING_INFORMATION('sales_data', '(sale_date)')) as info
-- )
-- SELECT 
--   info:cluster_by_keys::STRING as clustering_keys,
--   info:total_partition_count::INT as total_partitions,
--   info:total_constant_partition_count::INT as constant_partitions,
--   info:average_overlaps::FLOAT as avg_overlaps,
--   info:average_depth::FLOAT as avg_depth,
--   ROUND(
--     (constant_partitions::FLOAT / NULLIF(total_partitions, 0)) * 100, 
--     2
--   ) as clustering_ratio_pct
-- FROM cluster_data;

-- TODO: Check clustering depth for multiple tables
-- SELECT 
--   'sales_data' as table_name,
--   SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date)') as clustering_depth
-- UNION ALL
-- SELECT 
--   'orders_clustered' as table_name,
--   SYSTEM$CLUSTERING_DEPTH('orders_clustered', '(order_date)') as clustering_depth;

-- TODO: Create monitoring query for clustering health
-- CREATE OR REPLACE VIEW clustering_health AS
-- SELECT 
--   table_name,
--   clustering_key,
--   clustering_depth,
--   CASE 
--     WHEN clustering_depth <= 2 THEN 'Excellent'
--     WHEN clustering_depth <= 5 THEN 'Good'
--     WHEN clustering_depth <= 10 THEN 'Fair'
--     ELSE 'Poor'
--   END as health_status,
--   CASE 
--     WHEN clustering_depth > 10 THEN 'Consider re-clustering'
--     WHEN clustering_depth > 5 THEN 'Monitor closely'
--     ELSE 'Healthy'
--   END as recommendation
-- FROM (
--   SELECT 
--     'sales_data' as table_name,
--     '(sale_date, region)' as clustering_key,
--     SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date, region)') as clustering_depth
--   UNION ALL
--   SELECT 
--     'orders_clustered' as table_name,
--     '(order_date)' as clustering_key,
--     SYSTEM$CLUSTERING_DEPTH('orders_clustered', '(order_date)') as clustering_depth
-- );

-- TODO: Query clustering health view
-- SELECT * FROM clustering_health;


-- ============================================================================
-- Exercise 4: Measure Query Performance (10 min)
-- ============================================================================

-- TODO: Baseline query performance (before clustering optimization)
-- Run and note execution time and partitions scanned
-- SELECT 
--   sale_date,
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_amount,
--   AVG(amount) as avg_amount
-- FROM sales_data
-- WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30'
--   AND region = 'WEST'
-- GROUP BY sale_date, region
-- ORDER BY sale_date;

-- TODO: Check query profile
-- Go to Query History → View Profile
-- Note: Execution time, Partitions scanned, Bytes scanned

-- TODO: Create comparison table without clustering
-- CREATE OR REPLACE TABLE sales_data_unclustered AS
-- SELECT * FROM sales_data;

-- TODO: Remove clustering from original table temporarily
-- ALTER TABLE sales_data DROP CLUSTERING KEY;

-- TODO: Run same query on unclustered table
-- SELECT 
--   sale_date,
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_amount,
--   AVG(amount) as avg_amount
-- FROM sales_data
-- WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30'
--   AND region = 'WEST'
-- GROUP BY sale_date, region
-- ORDER BY sale_date;

-- TODO: Re-add clustering
-- ALTER TABLE sales_data CLUSTER BY (sale_date, region);

-- TODO: Run query again on clustered table
-- SELECT 
--   sale_date,
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_amount,
--   AVG(amount) as avg_amount
-- FROM sales_data
-- WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30'
--   AND region = 'WEST'
-- GROUP BY sale_date, region
-- ORDER BY sale_date;

-- TODO: Compare results
-- Create a summary of performance differences


-- ============================================================================
-- Exercise 5: Automatic Clustering (5 min)
-- ============================================================================

-- TODO: Check current clustering status
-- SHOW TABLES LIKE 'sales_data';
-- Look at AUTOMATIC_CLUSTERING column

-- TODO: Enable automatic clustering
-- ALTER TABLE sales_data RESUME RECLUSTER;

-- TODO: Verify automatic clustering is enabled
-- SHOW TABLES LIKE 'sales_data';

-- TODO: Insert new data to trigger re-clustering
-- INSERT INTO sales_data
-- SELECT 
--   SEQ4() + 100000 as sale_id,
--   DATEADD(day, UNIFORM(0, 30, RANDOM()), '2025-01-01'::DATE) as sale_date,
--   DATEADD(second, UNIFORM(0, 86400, RANDOM()), sale_date) as sale_timestamp,
--   UNIFORM(1, 10000, RANDOM()) as customer_id,
--   UNIFORM(1, 1000, RANDOM()) as product_id,
--   CASE UNIFORM(1, 5, RANDOM())
--     WHEN 1 THEN 'Electronics'
--     WHEN 2 THEN 'Clothing'
--     WHEN 3 THEN 'Food'
--     WHEN 4 THEN 'Home'
--     ELSE 'Sports'
--   END as category,
--   CASE UNIFORM(1, 4, RANDOM())
--     WHEN 1 THEN 'NORTH'
--     WHEN 2 THEN 'SOUTH'
--     WHEN 3 THEN 'EAST'
--     ELSE 'WEST'
--   END as region,
--   UNIFORM(10, 1000, RANDOM()) as amount,
--   UNIFORM(1, 10, RANDOM()) as quantity,
--   UNIFORM(0, 30, RANDOM()) as discount_pct
-- FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- TODO: Check clustering depth after insert
-- SELECT SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date, region)');

-- TODO: Suspend automatic clustering (for cost control)
-- ALTER TABLE sales_data SUSPEND RECLUSTER;


-- ============================================================================
-- Exercise 6: Cost Analysis (5 min)
-- ============================================================================

-- TODO: View automatic clustering history
-- Note: This requires ACCOUNT_USAGE access and may not show immediate results
-- SELECT 
--   start_time,
--   end_time,
--   table_name,
--   credits_used,
--   num_bytes_reclustered,
--   num_rows_reclustered
-- FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
-- WHERE table_name = 'SALES_DATA'
--   AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
-- ORDER BY start_time DESC;

-- TODO: Calculate daily re-clustering costs
-- SELECT 
--   DATE(start_time) as date,
--   COUNT(*) as recluster_operations,
--   SUM(credits_used) as total_credits,
--   ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd,
--   SUM(num_bytes_reclustered) / 1024 / 1024 / 1024 as gb_reclustered
-- FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
-- WHERE table_name = 'SALES_DATA'
--   AND start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
-- GROUP BY 1
-- ORDER BY 1 DESC;

-- TODO: Create cost monitoring view
-- CREATE OR REPLACE VIEW clustering_costs AS
-- SELECT 
--   table_name,
--   DATE(start_time) as date,
--   SUM(credits_used) as daily_credits,
--   ROUND(SUM(credits_used) * 3, 2) as daily_cost_usd,
--   SUM(num_rows_reclustered) as rows_reclustered,
--   COUNT(*) as recluster_count
-- FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
-- WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
-- GROUP BY table_name, DATE(start_time);

-- TODO: Query cost view
-- SELECT * FROM clustering_costs ORDER BY date DESC, table_name;


-- ============================================================================
-- Exercise 7: Optimize Clustering Strategy (5 min)
-- ============================================================================

-- TODO: Analyze query patterns
-- What columns are most frequently used in WHERE clauses?
-- SELECT 
--   query_text,
--   execution_time,
--   partitions_scanned,
--   partitions_total
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE query_text ILIKE '%sales_data%'
--   AND query_text ILIKE '%WHERE%'
--   AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
-- ORDER BY execution_time DESC
-- LIMIT 20;

-- TODO: Test different clustering strategies
-- Strategy 1: Single column (date only)
-- ALTER TABLE sales_data CLUSTER BY (sale_date);
-- Run test queries and measure performance

-- Strategy 2: Two columns (date + region)
-- ALTER TABLE sales_data CLUSTER BY (sale_date, region);
-- Run test queries and measure performance

-- Strategy 3: Expression-based (date part + category)
-- ALTER TABLE sales_data CLUSTER BY (DATE(sale_timestamp), category);
-- Run test queries and measure performance

-- TODO: Compare clustering depths for different strategies
-- SELECT 
--   'Strategy 1: sale_date' as strategy,
--   SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date)') as depth
-- UNION ALL
-- SELECT 
--   'Strategy 2: sale_date, region' as strategy,
--   SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date, region)') as depth;

-- TODO: Document recommended clustering strategy
-- Based on:
-- - Query patterns
-- - Clustering depth
-- - Re-clustering costs
-- - Query performance improvements


-- ============================================================================
-- Bonus Challenge: Advanced Clustering Analysis (Optional)
-- ============================================================================

-- TODO: Create comprehensive clustering report
-- CREATE OR REPLACE VIEW clustering_report AS
-- WITH table_stats AS (
--   SELECT 
--     table_name,
--     row_count,
--     bytes,
--     ROUND(bytes / 1024 / 1024 / 1024, 2) as size_gb
--   FROM INFORMATION_SCHEMA.TABLES
--   WHERE table_schema = 'DAY08_CLUSTERING'
-- ),
-- clustering_info AS (
--   SELECT 
--     'sales_data' as table_name,
--     '(sale_date, region)' as clustering_key,
--     SYSTEM$CLUSTERING_DEPTH('sales_data', '(sale_date, region)') as depth
-- )
-- SELECT 
--   ts.table_name,
--   ts.row_count,
--   ts.size_gb,
--   ci.clustering_key,
--   ci.depth as clustering_depth,
--   CASE 
--     WHEN ci.depth <= 2 THEN 'Excellent'
--     WHEN ci.depth <= 5 THEN 'Good'
--     WHEN ci.depth <= 10 THEN 'Fair'
--     ELSE 'Poor'
--   END as clustering_health,
--   CASE 
--     WHEN ts.size_gb < 1 THEN 'Table too small for clustering'
--     WHEN ci.depth > 10 THEN 'Re-cluster recommended'
--     WHEN ci.depth > 5 THEN 'Monitor and consider re-clustering'
--     ELSE 'Clustering optimal'
--   END as recommendation
-- FROM table_stats ts
-- LEFT JOIN clustering_info ci ON ts.table_name = ci.table_name;

-- TODO: Query the report
-- SELECT * FROM clustering_report;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- DROP TABLE IF EXISTS sales_data;
-- DROP TABLE IF EXISTS sales_data_unclustered;
-- DROP TABLE IF EXISTS events_data;
-- DROP TABLE IF EXISTS orders_clustered;
-- DROP VIEW IF EXISTS clustering_health;
-- DROP VIEW IF EXISTS clustering_costs;
-- DROP VIEW IF EXISTS clustering_report;
