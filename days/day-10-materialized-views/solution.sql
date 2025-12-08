/*
Day 10: Materialized Views - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY10_MAT_VIEWS;
USE SCHEMA DAY10_MAT_VIEWS;
USE WAREHOUSE BOOTCAMP_WH;

-- Create base tables
CREATE OR REPLACE TABLE orders (
  order_id INT,
  customer_id INT,
  product_id INT,
  order_date DATE,
  order_timestamp TIMESTAMP_NTZ,
  region VARCHAR(50),
  product_category VARCHAR(100),
  amount DECIMAL(10,2),
  quantity INT,
  order_status VARCHAR(50)
);

-- Insert sample data
INSERT INTO orders
SELECT 
  SEQ4() as order_id,
  UNIFORM(1, 10000, RANDOM()) as customer_id,
  UNIFORM(1, 1000, RANDOM()) as product_id,
  DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as order_date,
  DATEADD(second, UNIFORM(0, 86400, RANDOM()), order_date) as order_timestamp,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'NORTH'
    WHEN 2 THEN 'SOUTH'
    WHEN 3 THEN 'EAST'
    ELSE 'WEST'
  END as region,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'Electronics'
    WHEN 2 THEN 'Clothing'
    WHEN 3 THEN 'Food'
    WHEN 4 THEN 'Home'
    ELSE 'Sports'
  END as product_category,
  UNIFORM(10, 1000, RANDOM()) as amount,
  UNIFORM(1, 10, RANDOM()) as quantity,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'PENDING'
    WHEN 2 THEN 'PROCESSING'
    WHEN 3 THEN 'SHIPPED'
    WHEN 4 THEN 'DELIVERED'
    ELSE 'CANCELLED'
  END as order_status
FROM TABLE(GENERATOR(ROWCOUNT => 200000));

-- Create customers table
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(200),
  email VARCHAR(200),
  customer_tier VARCHAR(20),
  registration_date DATE,
  is_active BOOLEAN
);

-- Insert sample customers
INSERT INTO customers
SELECT 
  SEQ4() as customer_id,
  'Customer ' || SEQ4() as customer_name,
  'customer' || SEQ4() || '@example.com' as email,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'bronze'
    WHEN 2 THEN 'silver'
    WHEN 3 THEN 'gold'
    ELSE 'platinum'
  END as customer_tier,
  DATEADD(day, UNIFORM(0, 1000, RANDOM()), '2022-01-01'::DATE) as registration_date,
  UNIFORM(0, 1, RANDOM()) = 1 as is_active
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- Create products table
CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name VARCHAR(200),
  category VARCHAR(100),
  price DECIMAL(10,2)
);

-- Insert sample products
INSERT INTO products
SELECT 
  SEQ4() as product_id,
  'Product ' || SEQ4() as product_name,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'Electronics'
    WHEN 2 THEN 'Clothing'
    WHEN 3 THEN 'Food'
    WHEN 4 THEN 'Home'
    ELSE 'Sports'
  END as category,
  UNIFORM(10, 1000, RANDOM()) as price
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


-- ============================================================================
-- Exercise 1: Create Basic Materialized Views
-- ============================================================================

-- Daily sales summary
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
  order_date,
  region,
  product_category,
  COUNT(order_id) as order_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_order_value,
  COUNT(DISTINCT customer_id) as unique_customers
FROM orders
GROUP BY order_date, region, product_category;

-- Regional sales
CREATE MATERIALIZED VIEW regional_sales AS
SELECT 
  region,
  product_category,
  COUNT(order_id) as total_orders,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale,
  MIN(amount) as min_sale,
  MAX(amount) as max_sale
FROM orders
GROUP BY region, product_category;

-- Customer order summary with JOIN
CREATE MATERIALIZED VIEW customer_order_summary AS
SELECT 
  c.customer_id,
  c.customer_name,
  c.customer_tier,
  COUNT(o.order_id) as total_orders,
  SUM(o.amount) as total_spent,
  AVG(o.amount) as avg_order_value,
  MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_tier;

-- Monthly sales metrics
CREATE MATERIALIZED VIEW monthly_sales_metrics AS
SELECT 
  DATE_TRUNC('month', order_date) as month,
  region,
  COUNT(order_id) as order_count,
  SUM(amount) as total_sales,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(DISTINCT product_id) as unique_products
FROM orders
GROUP BY month, region;

-- Check status
SHOW MATERIALIZED VIEWS;

-- Query materialized views
SELECT * FROM daily_sales_summary LIMIT 10;
SELECT * FROM regional_sales ORDER BY total_sales DESC;
SELECT * FROM customer_order_summary WHERE total_orders > 5 LIMIT 10;


-- ============================================================================
-- Exercise 2: Compare Performance
-- ============================================================================

-- Baseline query (without materialized view)
SELECT 
  region,
  product_category,
  COUNT(order_id) as total_orders,
  SUM(amount) as total_sales
FROM orders
GROUP BY region, product_category
ORDER BY total_sales DESC;

-- Query using materialized view
SELECT 
  region,
  product_category,
  total_orders,
  total_sales
FROM regional_sales
ORDER BY total_sales DESC;

-- Complex aggregation without materialized view
SELECT 
  DATE_TRUNC('month', order_date) as month,
  region,
  COUNT(order_id) as order_count,
  SUM(amount) as total_sales,
  COUNT(DISTINCT customer_id) as unique_customers
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY month, region
ORDER BY month DESC, total_sales DESC;

-- Same query using materialized view
SELECT 
  month,
  region,
  order_count,
  total_sales,
  unique_customers
FROM monthly_sales_metrics
WHERE month >= '2024-01-01'
ORDER BY month DESC, total_sales DESC;

-- Performance comparison
SELECT 
  'Direct Query' as query_type,
  COUNT(*) as result_count
FROM (
  SELECT region, product_category
  FROM orders
  GROUP BY region, product_category
)
UNION ALL
SELECT 
  'Materialized View' as query_type,
  COUNT(*) as result_count
FROM regional_sales;


-- ============================================================================
-- Exercise 3: Monitor Maintenance
-- ============================================================================

-- Check staleness
SELECT 
  table_name,
  is_materialized,
  behind_by
FROM INFORMATION_SCHEMA.VIEWS
WHERE table_schema = 'DAY10_MAT_VIEWS'
  AND is_materialized = 'YES';

-- View maintenance history
SELECT 
  materialized_view_name,
  refresh_start_time,
  refresh_end_time,
  credits_used,
  bytes_scanned,
  rows_produced,
  DATEDIFF(second, refresh_start_time, refresh_end_time) as refresh_duration_sec
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
WHERE materialized_view_name IN ('DAILY_SALES_SUMMARY', 'REGIONAL_SALES', 'CUSTOMER_ORDER_SUMMARY')
  AND refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY refresh_start_time DESC;

-- Insert new data to trigger maintenance
INSERT INTO orders
SELECT 
  SEQ4() + 200000 as order_id,
  UNIFORM(1, 10000, RANDOM()) as customer_id,
  UNIFORM(1, 1000, RANDOM()) as product_id,
  CURRENT_DATE() as order_date,
  CURRENT_TIMESTAMP() as order_timestamp,
  'NORTH' as region,
  'Electronics' as product_category,
  UNIFORM(100, 500, RANDOM()) as amount,
  UNIFORM(1, 5, RANDOM()) as quantity,
  'PENDING' as order_status
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- Check staleness after insert
SELECT 
  table_name,
  behind_by
FROM INFORMATION_SCHEMA.VIEWS
WHERE table_schema = 'DAY10_MAT_VIEWS'
  AND is_materialized = 'YES';

-- Manually refresh
ALTER MATERIALIZED VIEW daily_sales_summary REFRESH;

-- Verify refresh
SELECT * FROM daily_sales_summary 
WHERE order_date = CURRENT_DATE();


-- ============================================================================
-- Exercise 4: Clustering Materialized Views
-- ============================================================================

-- Create large materialized view
CREATE MATERIALIZED VIEW large_sales_summary AS
SELECT 
  order_date,
  region,
  product_category,
  customer_id,
  COUNT(order_id) as order_count,
  SUM(amount) as total_amount
FROM orders
GROUP BY order_date, region, product_category, customer_id;

-- Add clustering key
ALTER MATERIALIZED VIEW large_sales_summary
CLUSTER BY (order_date);

-- Check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('large_sales_summary', '(order_date)');

-- Query with date filter
SELECT * FROM large_sales_summary
WHERE order_date BETWEEN '2024-06-01' AND '2024-06-30'
LIMIT 100;

-- Check clustering depth
SELECT SYSTEM$CLUSTERING_DEPTH('large_sales_summary', '(order_date)');


-- ============================================================================
-- Exercise 5: Materialized Views vs. Dynamic Tables
-- ============================================================================

-- Materialized view
CREATE MATERIALIZED VIEW sales_mv AS
SELECT 
  region,
  product_category,
  COUNT(order_id) as order_count,
  SUM(amount) as total_sales
FROM orders
GROUP BY region, product_category;

-- Equivalent dynamic table
CREATE OR REPLACE DYNAMIC TABLE sales_dt
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
SELECT 
  region,
  product_category,
  COUNT(order_id) as order_count,
  SUM(amount) as total_sales
FROM orders
GROUP BY region, product_category;

-- Compare query performance
SELECT * FROM sales_mv ORDER BY total_sales DESC;
SELECT * FROM sales_dt ORDER BY total_sales DESC;

-- Compare storage
SELECT 
  table_name,
  table_type,
  row_count,
  bytes / 1024 / 1024 as size_mb
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'DAY10_MAT_VIEWS'
  AND table_name IN ('SALES_MV', 'SALES_DT');

-- Comparison summary
SELECT 
  'Materialized View' as type,
  'Automatic' as refresh_control,
  'Limited' as query_flexibility,
  'Transparent' as maintenance
UNION ALL
SELECT 
  'Dynamic Table' as type,
  'TARGET_LAG' as refresh_control,
  'Full' as query_flexibility,
  'Visible' as maintenance;


-- ============================================================================
-- Exercise 6: Cost Analysis
-- ============================================================================

-- Storage costs
SELECT 
  table_name,
  table_type,
  row_count,
  bytes / 1024 / 1024 / 1024 as size_gb,
  ROUND(bytes / 1024 / 1024 / 1024 * 23, 2) as monthly_storage_cost_usd
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'DAY10_MAT_VIEWS'
  AND table_type = 'MATERIALIZED VIEW'
ORDER BY bytes DESC;

-- Maintenance costs
SELECT 
  DATE(refresh_start_time) as date,
  materialized_view_name,
  COUNT(*) as refresh_count,
  SUM(credits_used) as total_credits,
  ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd,
  AVG(DATEDIFF(second, refresh_start_time, refresh_end_time)) as avg_refresh_sec
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
WHERE refresh_start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 4 DESC;

-- Cost monitoring view
CREATE OR REPLACE VIEW mv_cost_summary AS
SELECT 
  t.table_name,
  t.row_count,
  ROUND(t.bytes / 1024 / 1024 / 1024, 2) as size_gb,
  ROUND(t.bytes / 1024 / 1024 / 1024 * 23, 2) as monthly_storage_cost_usd,
  COALESCE(h.total_credits_7d, 0) as maintenance_credits_7d,
  ROUND(COALESCE(h.total_credits_7d, 0) * 3, 2) as maintenance_cost_7d_usd
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN (
  SELECT 
    materialized_view_name,
    SUM(credits_used) as total_credits_7d
  FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
  WHERE refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  GROUP BY materialized_view_name
) h ON t.table_name = h.materialized_view_name
WHERE t.table_schema = 'DAY10_MAT_VIEWS'
  AND t.table_type = 'MATERIALIZED VIEW';

-- Query cost summary
SELECT * FROM mv_cost_summary ORDER BY monthly_storage_cost_usd DESC;

-- Total cost analysis
SELECT 
  SUM(size_gb) as total_size_gb,
  SUM(monthly_storage_cost_usd) as total_storage_cost_usd,
  SUM(maintenance_credits_7d) as total_maintenance_credits_7d,
  SUM(maintenance_cost_7d_usd) as total_maintenance_cost_7d_usd
FROM mv_cost_summary;


-- ============================================================================
-- Bonus: Materialized View Hierarchy
-- ============================================================================

-- Base materialized view (daily)
CREATE MATERIALIZED VIEW daily_sales_base AS
SELECT 
  order_date,
  region,
  product_category,
  SUM(amount) as daily_sales,
  COUNT(order_id) as daily_orders
FROM orders
GROUP BY order_date, region, product_category;

-- Higher-level aggregation (monthly from daily)
CREATE VIEW monthly_sales_from_daily AS
SELECT 
  DATE_TRUNC('month', order_date) as month,
  region,
  SUM(daily_sales) as monthly_sales,
  SUM(daily_orders) as monthly_orders
FROM daily_sales_base
GROUP BY month, region;

-- Query the hierarchy
SELECT * FROM monthly_sales_from_daily
WHERE month >= '2024-01-01'
ORDER BY month DESC, monthly_sales DESC;


-- ============================================================================
-- Suspend and Resume
-- ============================================================================

-- Suspend maintenance
ALTER MATERIALIZED VIEW daily_sales_summary SUSPEND;

-- Check status
SHOW MATERIALIZED VIEWS LIKE 'daily_sales_summary';

-- Resume maintenance
ALTER MATERIALIZED VIEW daily_sales_summary RESUME;

-- Manually refresh
ALTER MATERIALIZED VIEW daily_sales_summary REFRESH;


-- ============================================================================
-- Additional Monitoring Queries
-- ============================================================================

-- Comprehensive status report
SELECT 
  v.table_name,
  v.is_materialized,
  v.behind_by,
  t.row_count,
  ROUND(t.bytes / 1024 / 1024, 2) as size_mb,
  t.last_altered
FROM INFORMATION_SCHEMA.VIEWS v
JOIN INFORMATION_SCHEMA.TABLES t ON v.table_name = t.table_name
WHERE v.table_schema = 'DAY10_MAT_VIEWS'
  AND v.is_materialized = 'YES'
ORDER BY t.bytes DESC;

-- Refresh frequency analysis
SELECT 
  materialized_view_name,
  COUNT(*) as refresh_count_7d,
  AVG(DATEDIFF(second, refresh_start_time, refresh_end_time)) as avg_refresh_sec,
  MIN(refresh_start_time) as first_refresh,
  MAX(refresh_start_time) as last_refresh
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
WHERE refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY materialized_view_name
ORDER BY refresh_count_7d DESC;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- DROP MATERIALIZED VIEW IF EXISTS daily_sales_summary;
-- DROP MATERIALIZED VIEW IF EXISTS regional_sales;
-- DROP MATERIALIZED VIEW IF EXISTS customer_order_summary;
-- DROP MATERIALIZED VIEW IF EXISTS monthly_sales_metrics;
-- DROP MATERIALIZED VIEW IF EXISTS large_sales_summary;
-- DROP MATERIALIZED VIEW IF EXISTS sales_mv;
-- DROP MATERIALIZED VIEW IF EXISTS daily_sales_base;
-- DROP DYNAMIC TABLE IF EXISTS sales_dt;
-- DROP VIEW IF EXISTS monthly_sales_from_daily;
-- DROP VIEW IF EXISTS mv_cost_summary;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS products;
