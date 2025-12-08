/*
Day 13: Result Caching & Persisted Results - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
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
-- Exercise 1: Test Result Cache Behavior
-- ============================================================================

-- First execution - computes and caches result
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales_data
WHERE sale_date >= '2024-01-01'
GROUP BY region
ORDER BY total_sales DESC;

-- Second execution - returns cached result (instant, FREE)
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales_data
WHERE sale_date >= '2024-01-01'
GROUP BY region
ORDER BY total_sales DESC;

-- Different query - cache miss (no space after >=)
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales_data
WHERE sale_date>='2024-01-01'
GROUP BY region
ORDER BY total_sales DESC;

-- Check query history for cache hits
SELECT 
  query_id,
  LEFT(query_text, 80) as query_preview,
  execution_time,
  query_result_cache_hit,
  bytes_scanned,
  CASE 
    WHEN query_result_cache_hit THEN 'Result Cache HIT'
    WHEN bytes_scanned = 0 THEN 'Metadata Cache'
    ELSE 'Cache MISS'
  END as cache_status
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales_data%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 10;


-- ============================================================================
-- Exercise 2: Metadata-Only Queries
-- ============================================================================

-- Metadata-only queries (instant, FREE)
SELECT COUNT(*) FROM sales_data;

SELECT MIN(sale_date) FROM sales_data;

SELECT MAX(sale_date) FROM sales_data;

SELECT MIN(sale_id), MAX(sale_id) FROM sales_data;

-- Check if queries used metadata
SELECT 
  query_id,
  LEFT(query_text, 60) as query_preview,
  execution_time,
  bytes_scanned,
  CASE 
    WHEN bytes_scanned = 0 AND query_text ILIKE '%COUNT%' THEN 'Metadata-only (COUNT)'
    WHEN bytes_scanned = 0 AND query_text ILIKE '%MIN%' THEN 'Metadata-only (MIN/MAX)'
    WHEN bytes_scanned = 0 THEN 'Metadata-only'
    ELSE 'Data scan'
  END as query_type
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales_data%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 10;


-- ============================================================================
-- Exercise 3: Warehouse Cache Testing
-- ============================================================================

-- Create test warehouse
CREATE WAREHOUSE IF NOT EXISTS cache_test_wh WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE cache_test_wh;

-- First query - loads data to warehouse cache
SELECT 
  product_id,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales
FROM sales_data
WHERE region = 'NORTH'
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- Second query - uses warehouse cache (faster)
SELECT 
  product_id,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales
FROM sales_data
WHERE region = 'SOUTH'
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- Third query - also uses warehouse cache
SELECT 
  product_id,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales
FROM sales_data
WHERE region = 'EAST'
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- Check cache usage
SELECT 
  query_id,
  LEFT(query_text, 70) as query_preview,
  execution_time,
  bytes_scanned / 1024 / 1024 as mb_scanned,
  percentage_scanned_from_cache,
  ROUND(bytes_scanned * percentage_scanned_from_cache / 100 / 1024 / 1024, 2) as mb_from_cache
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE warehouse_name = 'CACHE_TEST_WH'
  AND query_text ILIKE '%sales_data%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 10;

-- Suspend warehouse (clears warehouse cache)
ALTER WAREHOUSE cache_test_wh SUSPEND;

-- Run query again - cache cleared, slower
USE WAREHOUSE cache_test_wh;

SELECT 
  product_id,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales
FROM sales_data
WHERE region = 'WEST'
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;


-- ============================================================================
-- Exercise 4: Cache Invalidation
-- ============================================================================

-- Run a query and cache it
SELECT COUNT(*) as total_sales FROM sales_data;

-- Run again - should be cached (instant)
SELECT COUNT(*) as total_sales FROM sales_data;

-- Modify the table (invalidates result cache)
INSERT INTO sales_data VALUES 
  (99999, 999, 999, '2024-12-08', 999.99, 'NORTH');

-- Run query again - cache invalidated, recomputes
SELECT COUNT(*) as total_sales FROM sales_data;

-- Verify cache behavior
SELECT 
  query_id,
  LEFT(query_text, 60) as query_preview,
  execution_time,
  query_result_cache_hit,
  CASE 
    WHEN query_result_cache_hit THEN 'Cached (FREE)'
    ELSE 'Computed (credits used)'
  END as execution_type
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%total_sales%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 10;

-- Additional cache invalidation examples
UPDATE sales_data SET amount = 1000.00 WHERE sale_id = 99999;
-- Cache invalidated

DELETE FROM sales_data WHERE sale_id = 99999;
-- Cache invalidated

TRUNCATE TABLE sales_data;
-- Cache invalidated (don't actually run this!)


-- ============================================================================
-- Exercise 5: Optimize for Caching
-- ============================================================================

-- Bad practice - non-deterministic function (never cached)
SELECT 
  COUNT(*) as today_sales
FROM sales_data
WHERE sale_date = CURRENT_DATE();

-- Run again - still not cached (CURRENT_DATE() changes)
SELECT 
  COUNT(*) as today_sales
FROM sales_data
WHERE sale_date = CURRENT_DATE();

-- Good practice - deterministic value (cacheable)
SELECT 
  COUNT(*) as today_sales
FROM sales_data
WHERE sale_date = '2024-12-08';

-- Run again - should be cached
SELECT 
  COUNT(*) as today_sales
FROM sales_data
WHERE sale_date = '2024-12-08';

-- Create view with consistent formatting
CREATE OR REPLACE VIEW sales_by_region AS
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales_data
GROUP BY region;

-- Query the view multiple times (consistent formatting = cache hits)
SELECT * FROM sales_by_region ORDER BY total_sales DESC;
SELECT * FROM sales_by_region ORDER BY total_sales DESC;
SELECT * FROM sales_by_region ORDER BY total_sales DESC;

-- Check cache hits
SELECT 
  query_id,
  LEFT(query_text, 70) as query_preview,
  execution_time,
  query_result_cache_hit,
  CASE 
    WHEN query_result_cache_hit THEN 'HIT (FREE)'
    ELSE 'MISS (computed)'
  END as cache_result
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales_by_region%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 10;

-- More optimization examples
-- Bad: Different formatting (cache misses)
SELECT region,COUNT(*) FROM sales_data GROUP BY region;
SELECT region, COUNT(*) FROM sales_data GROUP BY region;
SELECT REGION, COUNT(*) FROM sales_data GROUP BY REGION;

-- Good: Consistent formatting (cache hits)
SELECT region, COUNT(*) FROM sales_data GROUP BY region;
SELECT region, COUNT(*) FROM sales_data GROUP BY region;
SELECT region, COUNT(*) FROM sales_data GROUP BY region;


-- ============================================================================
-- Exercise 6: Monitor Cache Effectiveness
-- ============================================================================

-- Calculate result cache hit rate
SELECT 
  COUNT(*) as total_queries,
  SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as cache_hits,
  SUM(CASE WHEN query_result_cache_hit = FALSE THEN 1 ELSE 0 END) as cache_misses,
  ROUND((cache_hits / NULLIF(total_queries, 0)) * 100, 2) as cache_hit_rate_pct
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
  AND query_text NOT ILIKE '%QUERY_HISTORY%';

-- Identify queries with high warehouse cache usage
SELECT 
  query_id,
  LEFT(query_text, 80) as query_preview,
  execution_time,
  bytes_scanned / 1024 / 1024 as mb_scanned,
  percentage_scanned_from_cache,
  ROUND(bytes_scanned * percentage_scanned_from_cache / 100 / 1024 / 1024, 2) as mb_from_cache
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND bytes_scanned > 0
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY percentage_scanned_from_cache DESC
LIMIT 10;

-- Find metadata-only queries
SELECT 
  query_id,
  LEFT(query_text, 80) as query_preview,
  execution_time,
  bytes_scanned,
  'Metadata-only (FREE)' as query_type
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND bytes_scanned = 0
  AND execution_status = 'SUCCESS'
  AND query_text NOT ILIKE '%SHOW%'
  AND query_text NOT ILIKE '%DESCRIBE%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 10;

-- Comprehensive cache analysis
SELECT 
  query_id,
  LEFT(query_text, 60) as query_preview,
  execution_time,
  bytes_scanned / 1024 / 1024 as mb_scanned,
  query_result_cache_hit,
  percentage_scanned_from_cache,
  CASE 
    WHEN query_result_cache_hit THEN 'Result Cache (FREE)'
    WHEN bytes_scanned = 0 THEN 'Metadata Cache (FREE)'
    WHEN percentage_scanned_from_cache > 80 THEN 'Warehouse Cache (High)'
    WHEN percentage_scanned_from_cache > 50 THEN 'Warehouse Cache (Medium)'
    WHEN percentage_scanned_from_cache > 0 THEN 'Warehouse Cache (Low)'
    ELSE 'No Cache (Full Scan)'
  END as cache_type
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 20;


-- ============================================================================
-- Exercise 7: Real-World Caching Strategy
-- ============================================================================

-- Create dashboard query with consistent formatting
CREATE OR REPLACE VIEW daily_sales_dashboard AS
SELECT 
  sale_date,
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale,
  MIN(amount) as min_sale,
  MAX(amount) as max_sale
FROM sales_data
WHERE sale_date >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY sale_date, region;

-- Query dashboard (first time - computes)
SELECT * FROM daily_sales_dashboard
WHERE region = 'NORTH'
ORDER BY sale_date DESC;

-- Query dashboard again (should be cached)
SELECT * FROM daily_sales_dashboard
WHERE region = 'NORTH'
ORDER BY sale_date DESC;

-- Different region (still cached if view query is same)
SELECT * FROM daily_sales_dashboard
WHERE region = 'SOUTH'
ORDER BY sale_date DESC;

-- Create monitoring view for cache effectiveness
CREATE OR REPLACE VIEW cache_monitoring AS
SELECT 
  DATE(start_time) as query_date,
  COUNT(*) as total_queries,
  SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as result_cache_hits,
  SUM(CASE WHEN bytes_scanned = 0 AND query_result_cache_hit = FALSE THEN 1 ELSE 0 END) as metadata_queries,
  AVG(percentage_scanned_from_cache) as avg_warehouse_cache_pct,
  ROUND((result_cache_hits / NULLIF(total_queries, 0)) * 100, 2) as result_cache_hit_rate_pct
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
GROUP BY 1;

-- View cache monitoring results
SELECT * FROM cache_monitoring
ORDER BY query_date DESC;

-- Calculate cost savings from caching
SELECT 
  query_date,
  total_queries,
  result_cache_hits,
  result_cache_hit_rate_pct,
  -- Estimate: Each cached query saves ~0.001 credits
  ROUND(result_cache_hits * 0.001, 3) as estimated_credits_saved,
  ROUND(result_cache_hits * 0.001 * 3, 2) as estimated_cost_saved_usd
FROM cache_monitoring
ORDER BY query_date DESC;


-- ============================================================================
-- Bonus: Advanced Cache Optimization
-- ============================================================================

-- Test query with different formatting (cache misses)
SELECT region,COUNT(*),SUM(amount) FROM sales_data GROUP BY region;
SELECT region, COUNT(*), SUM(amount) FROM sales_data GROUP BY region;
SELECT REGION, COUNT(*), SUM(amount) FROM sales_data GROUP BY REGION;

-- Verify all three are cache misses
SELECT 
  query_id,
  query_text,
  query_result_cache_hit
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%region%COUNT%SUM%amount%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 5;

-- Create stored procedure for consistent queries
CREATE OR REPLACE PROCEDURE get_sales_by_region(region_name VARCHAR)
RETURNS TABLE(region VARCHAR, sale_count NUMBER, total_sales NUMBER)
LANGUAGE SQL
AS
$$
BEGIN
  LET result RESULTSET := (
    SELECT 
      region,
      COUNT(*) as sale_count,
      SUM(amount) as total_sales
    FROM sales_data
    WHERE region = :region_name
    GROUP BY region
  );
  RETURN TABLE(result);
END;
$$;

-- Call procedure multiple times
CALL get_sales_by_region('NORTH');
CALL get_sales_by_region('SOUTH');
CALL get_sales_by_region('EAST');

-- Best practices summary
SELECT 
  'Cache Optimization Best Practices' as category,
  'Use consistent query formatting' as practice,
  'Exact match required for result cache' as reason
UNION ALL
SELECT 'Cache Optimization', 'Avoid CURRENT_DATE(), CURRENT_TIMESTAMP()', 'Non-deterministic functions prevent caching'
UNION ALL
SELECT 'Cache Optimization', 'Use views for common queries', 'Ensures consistent query text'
UNION ALL
SELECT 'Cache Optimization', 'Keep warehouses running longer', 'Preserves warehouse cache'
UNION ALL
SELECT 'Cache Optimization', 'Batch table updates', 'Minimizes cache invalidation'
UNION ALL
SELECT 'Cache Optimization', 'Use COUNT(*) without WHERE', 'Enables metadata-only queries'
UNION ALL
SELECT 'Cache Optimization', 'Monitor cache hit rates', 'Identify optimization opportunities'
UNION ALL
SELECT 'Cache Optimization', 'Standardize date formats', 'Improves cache reuse';


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
