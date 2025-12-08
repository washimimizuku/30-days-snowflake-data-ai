/*
Day 13: Result Caching & Persisted Results - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY13_CACHING;
USE SCHEMA DAY13_CACHING;

-- Create test tables
CREATE OR REPLACE TABLE sales_data (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region VARCHAR(50)
);

CREATE OR REPLACE TABLE customer_data (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  signup_date DATE
);

-- Insert sample data
INSERT INTO sales_data
SELECT 
  SEQ4() as sale_id,
  UNIFORM(1, 100, RANDOM()) as product_id,
  UNIFORM(1, 1000, RANDOM()) as customer_id,
  DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as sale_date,
  ROUND(UNIFORM(10, 1000, RANDOM()), 2) as amount,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'NORTH'
    WHEN 2 THEN 'SOUTH'
    WHEN 3 THEN 'EAST'
    ELSE 'WEST'
  END as region
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

INSERT INTO customer_data
SELECT 
  SEQ4() as customer_id,
  'Customer_' || SEQ4() as customer_name,
  'customer' || SEQ4() || '@example.com' as email,
  DATEADD(day, UNIFORM(0, 730, RANDOM()), '2023-01-01'::DATE) as signup_date
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


-- ============================================================================
-- Exercise 1: Test Result Cache Behavior (10 min)
-- ============================================================================

-- TODO: Run a query and note execution time
-- SELECT 
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales,
--   AVG(amount) as avg_sale
-- FROM sales_data
-- WHERE sale_date >= '2024-01-01'
-- GROUP BY region
-- ORDER BY total_sales DESC;

-- TODO: Run the EXACT same query again
-- Should be instant (result cache hit)
-- SELECT 
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales,
--   AVG(amount) as avg_sale
-- FROM sales_data
-- WHERE sale_date >= '2024-01-01'
-- GROUP BY region
-- ORDER BY total_sales DESC;

-- TODO: Run a slightly different query (cache miss)
-- SELECT 
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales,
--   AVG(amount) as avg_sale
-- FROM sales_data
-- WHERE sale_date>='2024-01-01'  -- No space after >=
-- GROUP BY region
-- ORDER BY total_sales DESC;

-- TODO: Check query history for cache hits
-- SELECT 
--   query_id,
--   query_text,
--   execution_time,
--   query_result_cache_hit,
--   bytes_scanned
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%sales_data%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;


-- ============================================================================
-- Exercise 2: Metadata-Only Queries (5 min)
-- ============================================================================

-- TODO: Test metadata-only queries (should be instant)
-- SELECT COUNT(*) FROM sales_data;

-- SELECT MIN(sale_date) FROM sales_data;

-- SELECT MAX(sale_date) FROM sales_data;

-- TODO: Check if queries used metadata
-- SELECT 
--   query_id,
--   LEFT(query_text, 50) as query_preview,
--   execution_time,
--   bytes_scanned,
--   CASE WHEN bytes_scanned = 0 THEN 'Metadata-only' ELSE 'Data scan' END as query_type
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%sales_data%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;


-- ============================================================================
-- Exercise 3: Warehouse Cache Testing (10 min)
-- ============================================================================

-- TODO: Create a new warehouse for testing
-- CREATE WAREHOUSE IF NOT EXISTS cache_test_wh WITH
--   WAREHOUSE_SIZE = 'XSMALL'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE;

-- TODO: Use the new warehouse
-- USE WAREHOUSE cache_test_wh;

-- TODO: First query - loads data to warehouse cache
-- SELECT 
--   product_id,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales
-- FROM sales_data
-- WHERE region = 'NORTH'
-- GROUP BY product_id
-- ORDER BY total_sales DESC
-- LIMIT 10;

-- TODO: Second query - should use warehouse cache
-- SELECT 
--   product_id,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales
-- FROM sales_data
-- WHERE region = 'SOUTH'
-- GROUP BY product_id
-- ORDER BY total_sales DESC
-- LIMIT 10;

-- TODO: Check cache usage
-- SELECT 
--   query_id,
--   LEFT(query_text, 60) as query_preview,
--   execution_time,
--   bytes_scanned / 1024 / 1024 as mb_scanned,
--   percentage_scanned_from_cache
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE warehouse_name = 'CACHE_TEST_WH'
--   AND query_text ILIKE '%sales_data%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;

-- TODO: Suspend warehouse (clears warehouse cache)
-- ALTER WAREHOUSE cache_test_wh SUSPEND;

-- TODO: Run query again - cache cleared, slower
-- USE WAREHOUSE cache_test_wh;
-- SELECT 
--   product_id,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales
-- FROM sales_data
-- WHERE region = 'EAST'
-- GROUP BY product_id
-- ORDER BY total_sales DESC
-- LIMIT 10;


-- ============================================================================
-- Exercise 4: Cache Invalidation (5 min)
-- ============================================================================

-- TODO: Run a query and cache it
-- SELECT COUNT(*) as total_sales FROM sales_data;

-- TODO: Run again - should be cached
-- SELECT COUNT(*) as total_sales FROM sales_data;

-- TODO: Modify the table (invalidates result cache)
-- INSERT INTO sales_data VALUES 
--   (99999, 999, 999, '2024-12-08', 999.99, 'NORTH');

-- TODO: Run query again - cache invalidated, recomputes
-- SELECT COUNT(*) as total_sales FROM sales_data;

-- TODO: Verify cache behavior
-- SELECT 
--   query_id,
--   LEFT(query_text, 50) as query_preview,
--   execution_time,
--   query_result_cache_hit
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%total_sales%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;


-- ============================================================================
-- Exercise 5: Optimize for Caching (10 min)
-- ============================================================================

-- TODO: Bad practice - non-deterministic function (never cached)
-- SELECT 
--   COUNT(*) as today_sales
-- FROM sales_data
-- WHERE sale_date = CURRENT_DATE();

-- TODO: Run again - still not cached
-- SELECT 
--   COUNT(*) as today_sales
-- FROM sales_data
-- WHERE sale_date = CURRENT_DATE();

-- TODO: Good practice - deterministic value (cacheable)
-- SELECT 
--   COUNT(*) as today_sales
-- FROM sales_data
-- WHERE sale_date = '2024-12-08';

-- TODO: Run again - should be cached
-- SELECT 
--   COUNT(*) as today_sales
-- FROM sales_data
-- WHERE sale_date = '2024-12-08';

-- TODO: Create a view with consistent formatting
-- CREATE OR REPLACE VIEW sales_by_region AS
-- SELECT 
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales,
--   AVG(amount) as avg_sale
-- FROM sales_data
-- GROUP BY region;

-- TODO: Query the view multiple times (consistent formatting)
-- SELECT * FROM sales_by_region ORDER BY total_sales DESC;
-- SELECT * FROM sales_by_region ORDER BY total_sales DESC;

-- TODO: Check cache hits
-- SELECT 
--   query_id,
--   LEFT(query_text, 60) as query_preview,
--   execution_time,
--   query_result_cache_hit
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%sales_by_region%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;


-- ============================================================================
-- Exercise 6: Monitor Cache Effectiveness (5 min)
-- ============================================================================

-- TODO: Calculate result cache hit rate
-- SELECT 
--   COUNT(*) as total_queries,
--   SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as cache_hits,
--   ROUND((cache_hits / NULLIF(total_queries, 0)) * 100, 2) as cache_hit_rate_pct
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND execution_status = 'SUCCESS'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%';

-- TODO: Identify queries with high warehouse cache usage
-- SELECT 
--   query_id,
--   LEFT(query_text, 80) as query_preview,
--   execution_time,
--   bytes_scanned / 1024 / 1024 as mb_scanned,
--   percentage_scanned_from_cache,
--   ROUND(bytes_scanned * percentage_scanned_from_cache / 100 / 1024 / 1024, 2) as mb_from_cache
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND bytes_scanned > 0
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY percentage_scanned_from_cache DESC
-- LIMIT 10;

-- TODO: Find metadata-only queries
-- SELECT 
--   query_id,
--   LEFT(query_text, 80) as query_preview,
--   execution_time,
--   bytes_scanned
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND bytes_scanned = 0
--   AND execution_status = 'SUCCESS'
--   AND query_text NOT ILIKE '%SHOW%'
--   AND query_text NOT ILIKE '%DESCRIBE%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 10;


-- ============================================================================
-- Exercise 7: Real-World Caching Strategy (5 min)
-- ============================================================================

-- TODO: Create a dashboard query with consistent formatting
-- CREATE OR REPLACE VIEW daily_sales_dashboard AS
-- SELECT 
--   sale_date,
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_sales,
--   AVG(amount) as avg_sale,
--   MIN(amount) as min_sale,
--   MAX(amount) as max_sale
-- FROM sales_data
-- WHERE sale_date >= DATEADD(day, -30, CURRENT_DATE())
-- GROUP BY sale_date, region;

-- TODO: Query dashboard (first time - computes)
-- SELECT * FROM daily_sales_dashboard
-- WHERE region = 'NORTH'
-- ORDER BY sale_date DESC;

-- TODO: Query dashboard again (should be cached)
-- SELECT * FROM daily_sales_dashboard
-- WHERE region = 'NORTH'
-- ORDER BY sale_date DESC;

-- TODO: Create monitoring query for cache effectiveness
-- CREATE OR REPLACE VIEW cache_monitoring AS
-- SELECT 
--   DATE(start_time) as query_date,
--   COUNT(*) as total_queries,
--   SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as result_cache_hits,
--   SUM(CASE WHEN bytes_scanned = 0 THEN 1 ELSE 0 END) as metadata_queries,
--   AVG(percentage_scanned_from_cache) as avg_warehouse_cache_pct,
--   ROUND((result_cache_hits / NULLIF(total_queries, 0)) * 100, 2) as result_cache_hit_rate_pct
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND execution_status = 'SUCCESS'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- GROUP BY 1;

-- TODO: View cache monitoring results
-- SELECT * FROM cache_monitoring
-- ORDER BY query_date DESC;


-- ============================================================================
-- Bonus: Advanced Cache Optimization (Optional)
-- ============================================================================

-- TODO: Test query with different formatting (cache miss)
-- SELECT region,COUNT(*),SUM(amount) FROM sales_data GROUP BY region;
-- SELECT region, COUNT(*), SUM(amount) FROM sales_data GROUP BY region;

-- TODO: Create a stored procedure for consistent queries
-- CREATE OR REPLACE PROCEDURE get_sales_by_region(region_name VARCHAR)
-- RETURNS TABLE(region VARCHAR, sale_count NUMBER, total_sales NUMBER)
-- LANGUAGE SQL
-- AS
-- $$
-- BEGIN
--   LET result RESULTSET := (
--     SELECT 
--       region,
--       COUNT(*) as sale_count,
--       SUM(amount) as total_sales
--     FROM sales_data
--     WHERE region = :region_name
--     GROUP BY region
--   );
--   RETURN TABLE(result);
-- END;
-- $$;

-- TODO: Call procedure multiple times (consistent query text)
-- CALL get_sales_by_region('NORTH');
-- CALL get_sales_by_region('SOUTH');


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Drop test warehouse
-- DROP WAREHOUSE IF EXISTS cache_test_wh;

-- Drop views
-- DROP VIEW IF EXISTS sales_by_region;
-- DROP VIEW IF EXISTS daily_sales_dashboard;
-- DROP VIEW IF EXISTS cache_monitoring;

-- Drop procedure
-- DROP PROCEDURE IF EXISTS get_sales_by_region(VARCHAR);

-- Drop tables
-- DROP TABLE IF EXISTS sales_data;
-- DROP TABLE IF EXISTS customer_data;
