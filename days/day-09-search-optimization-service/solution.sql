/*
Day 9: Search Optimization Service - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY09_SEARCH_OPT;
USE SCHEMA DAY09_SEARCH_OPT;
USE WAREHOUSE BOOTCAMP_WH;

-- Create customers table
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  email VARCHAR(200),
  phone VARCHAR(50),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  address VARCHAR(500),
  city VARCHAR(100),
  state VARCHAR(50),
  country VARCHAR(50),
  postal_code VARCHAR(20),
  registration_date DATE,
  customer_tier VARCHAR(20)
);

-- Insert sample data
INSERT INTO customers
SELECT 
  SEQ4() as customer_id,
  'user' || SEQ4() || '@example.com' as email,
  '+1-555-' || LPAD(UNIFORM(1000, 9999, RANDOM())::STRING, 4, '0') as phone,
  'FirstName' || SEQ4() as first_name,
  'LastName' || SEQ4() as last_name,
  UNIFORM(1, 9999, RANDOM()) || ' Main St' as address,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'New York'
    WHEN 2 THEN 'Los Angeles'
    WHEN 3 THEN 'Chicago'
    WHEN 4 THEN 'Houston'
    ELSE 'Phoenix'
  END as city,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'NY'
    WHEN 2 THEN 'CA'
    WHEN 3 THEN 'IL'
    WHEN 4 THEN 'TX'
    ELSE 'AZ'
  END as state,
  'USA' as country,
  LPAD(UNIFORM(10000, 99999, RANDOM())::STRING, 5, '0') as postal_code,
  DATEADD(day, UNIFORM(0, 1000, RANDOM()), '2022-01-01'::DATE) as registration_date,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'bronze'
    WHEN 2 THEN 'silver'
    WHEN 3 THEN 'gold'
    ELSE 'platinum'
  END as customer_tier
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Create orders table
CREATE OR REPLACE TABLE orders (
  order_id VARCHAR(50),
  customer_id INT,
  order_date DATE,
  tracking_number VARCHAR(100),
  order_status VARCHAR(50),
  total_amount DECIMAL(10,2)
);

-- Insert sample orders
INSERT INTO orders
SELECT 
  'ORD-' || LPAD(SEQ4()::STRING, 8, '0') as order_id,
  UNIFORM(1, 100000, RANDOM()) as customer_id,
  DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as order_date,
  'TRACK-' || LPAD(UNIFORM(10000000, 99999999, RANDOM())::STRING, 8, '0') as tracking_number,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'PENDING'
    WHEN 2 THEN 'PROCESSING'
    WHEN 3 THEN 'SHIPPED'
    WHEN 4 THEN 'DELIVERED'
    ELSE 'CANCELLED'
  END as order_status,
  UNIFORM(10, 1000, RANDOM()) as total_amount
FROM TABLE(GENERATOR(ROWCOUNT => 200000));

-- Create products table
CREATE OR REPLACE TABLE products (
  product_id INT,
  sku VARCHAR(50),
  product_name VARCHAR(200),
  description VARCHAR(1000),
  category VARCHAR(100),
  price DECIMAL(10,2)
);

-- Insert sample products
INSERT INTO products
SELECT 
  SEQ4() as product_id,
  'SKU-' || LPAD(SEQ4()::STRING, 6, '0') as sku,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'Laptop'
    WHEN 2 THEN 'Phone'
    WHEN 3 THEN 'Tablet'
    WHEN 4 THEN 'Monitor'
    ELSE 'Keyboard'
  END || ' Model ' || SEQ4() as product_name,
  'High quality product with excellent features and warranty' as description,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'Electronics'
    WHEN 2 THEN 'Computers'
    WHEN 3 THEN 'Accessories'
    WHEN 4 THEN 'Mobile'
    ELSE 'Office'
  END as category,
  UNIFORM(50, 2000, RANDOM()) as price
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- Create application logs table
CREATE OR REPLACE TABLE application_logs (
  log_id INT,
  log_timestamp TIMESTAMP_NTZ,
  log_level VARCHAR(20),
  log_message VARCHAR(1000),
  user_id INT,
  session_id VARCHAR(100)
);

-- Insert sample logs
INSERT INTO application_logs
SELECT 
  SEQ4() as log_id,
  DATEADD(second, UNIFORM(0, 2592000, RANDOM()), '2024-12-01'::TIMESTAMP_NTZ) as log_timestamp,
  CASE UNIFORM(1, 4, RANDOM())
    WHEN 1 THEN 'INFO'
    WHEN 2 THEN 'WARNING'
    WHEN 3 THEN 'ERROR'
    ELSE 'DEBUG'
  END as log_level,
  CASE UNIFORM(1, 5, RANDOM())
    WHEN 1 THEN 'User login successful'
    WHEN 2 THEN 'Database connection timeout'
    WHEN 3 THEN 'Payment processing ERROR occurred'
    WHEN 4 THEN 'API request completed'
    ELSE 'Cache miss for key'
  END as log_message,
  UNIFORM(1, 10000, RANDOM()) as user_id,
  'SESSION-' || UNIFORM(1, 50000, RANDOM()) as session_id
FROM TABLE(GENERATOR(ROWCOUNT => 500000));


-- ============================================================================
-- Exercise 1: Enable Search Optimization
-- ============================================================================

-- Check current status
SHOW TABLES LIKE 'customers';

-- Enable search optimization on entire customers table
ALTER TABLE customers ADD SEARCH OPTIMIZATION;

-- Check build progress
SELECT SYSTEM$GET_SEARCH_OPTIMIZATION_PROGRESS('customers');

-- View detailed table information
SELECT 
  table_name,
  search_optimization,
  search_optimization_progress,
  search_optimization_bytes
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'DAY09_SEARCH_OPT'
  AND table_name = 'CUSTOMERS';

-- Enable on specific columns for orders
ALTER TABLE orders 
ADD SEARCH OPTIMIZATION ON EQUALITY(order_id, tracking_number);

-- Enable on products with multiple types
ALTER TABLE products 
ADD SEARCH OPTIMIZATION 
  ON EQUALITY(product_id, sku)
  ON SUBSTRING(product_name);

-- Check status of all tables
SELECT 
  table_name,
  search_optimization,
  ROUND(search_optimization_bytes / 1024 / 1024, 2) as search_opt_mb
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'DAY09_SEARCH_OPT'
  AND search_optimization = 'ON'
ORDER BY search_optimization_bytes DESC;


-- ============================================================================
-- Exercise 2: Point Lookup Performance
-- ============================================================================

-- Baseline query performance
SELECT * FROM customers WHERE customer_id = 50000;

-- Test email lookup
SELECT * FROM customers WHERE email = 'user50000@example.com';

-- Test phone lookup
SELECT * FROM customers WHERE phone = '+1-555-5000';

-- Test multiple IDs
SELECT * FROM customers 
WHERE customer_id IN (1000, 2000, 3000, 4000, 5000);

-- Compare with non-optimized column
SELECT * FROM customers WHERE city = 'New York';

-- Performance comparison query
SELECT 
  'Point Lookup' as query_type,
  COUNT(*) as result_count
FROM customers 
WHERE customer_id = 50000
UNION ALL
SELECT 
  'Email Lookup' as query_type,
  COUNT(*) as result_count
FROM customers 
WHERE email = 'user50000@example.com'
UNION ALL
SELECT 
  'Multiple IDs' as query_type,
  COUNT(*) as result_count
FROM customers 
WHERE customer_id IN (1000, 2000, 3000, 4000, 5000);


-- ============================================================================
-- Exercise 3: Substring Search Optimization
-- ============================================================================

-- Enable substring search on logs
ALTER TABLE application_logs 
ADD SEARCH OPTIMIZATION ON SUBSTRING(log_message);

-- Test LIKE queries
SELECT * FROM application_logs 
WHERE log_message LIKE '%ERROR%'
LIMIT 100;

-- Test CONTAINS
SELECT * FROM application_logs 
WHERE CONTAINS(log_message, 'timeout')
LIMIT 100;

-- Test STARTSWITH
SELECT * FROM application_logs 
WHERE STARTSWITH(log_message, 'User')
LIMIT 100;

-- Test product name search
SELECT * FROM products 
WHERE product_name LIKE '%Laptop%';

-- Count results for different patterns
SELECT 
  'ERROR logs' as search_type,
  COUNT(*) as result_count
FROM application_logs 
WHERE log_message LIKE '%ERROR%'
UNION ALL
SELECT 
  'Timeout logs' as search_type,
  COUNT(*) as result_count
FROM application_logs 
WHERE CONTAINS(log_message, 'timeout')
UNION ALL
SELECT 
  'User logs' as search_type,
  COUNT(*) as result_count
FROM application_logs 
WHERE STARTSWITH(log_message, 'User');


-- ============================================================================
-- Exercise 4: Combined Queries
-- ============================================================================

-- Combined equality and substring
SELECT * FROM products 
WHERE category = 'Electronics' 
  AND product_name LIKE '%Laptop%';

-- Order lookup with JOIN
SELECT o.*, c.email, c.first_name, c.last_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_id = 'ORD-00050000';

-- Complex query with aggregation
SELECT 
  c.customer_id,
  c.email,
  COUNT(o.order_id) as order_count,
  SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.email = 'user50000@example.com'
GROUP BY c.customer_id, c.email;

-- Multi-table query
SELECT 
  c.customer_id,
  c.email,
  o.order_id,
  o.tracking_number,
  o.order_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = 50000
  AND o.order_status = 'SHIPPED';


-- ============================================================================
-- Exercise 5: Cost Analysis
-- ============================================================================

-- Check storage overhead
SELECT 
  table_name,
  row_count,
  bytes / 1024 / 1024 / 1024 as table_size_gb,
  search_optimization_bytes / 1024 / 1024 / 1024 as search_opt_size_gb,
  ROUND(
    (search_optimization_bytes::FLOAT / NULLIF(bytes, 0)) * 100, 
    2
  ) as overhead_pct
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'DAY09_SEARCH_OPT'
  AND search_optimization = 'ON'
ORDER BY search_optimization_bytes DESC;

-- View maintenance history
SELECT 
  table_name,
  start_time,
  end_time,
  credits_used,
  bytes_added,
  bytes_removed
FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
WHERE table_name IN ('CUSTOMERS', 'ORDERS', 'PRODUCTS', 'APPLICATION_LOGS')
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- Calculate daily maintenance costs
SELECT 
  DATE(start_time) as date,
  table_name,
  SUM(credits_used) as total_credits,
  ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd,
  COUNT(*) as maintenance_operations
FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;

-- Create cost monitoring view
CREATE OR REPLACE VIEW search_opt_costs AS
SELECT 
  table_name,
  DATE(start_time) as date,
  SUM(credits_used) as daily_credits,
  ROUND(SUM(credits_used) * 3, 2) as daily_cost_usd,
  SUM(bytes_added) / 1024 / 1024 / 1024 as gb_added,
  COUNT(*) as operations
FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY table_name, DATE(start_time);

-- Query cost view
SELECT * FROM search_opt_costs ORDER BY date DESC, table_name;

-- Total cost summary
SELECT 
  table_name,
  SUM(daily_credits) as total_credits_30d,
  SUM(daily_cost_usd) as total_cost_usd_30d,
  AVG(daily_credits) as avg_daily_credits
FROM search_opt_costs
GROUP BY table_name
ORDER BY total_credits_30d DESC;


-- ============================================================================
-- Exercise 6: Combined Strategy
-- ============================================================================

-- Create table with both clustering and search optimization
CREATE OR REPLACE TABLE sales_optimized (
  sale_id INT,
  sale_date DATE,
  customer_id INT,
  product_id INT,
  amount DECIMAL(10,2)
)
CLUSTER BY (sale_date);

-- Insert sample data
INSERT INTO sales_optimized
SELECT 
  SEQ4() as sale_id,
  DATEADD(day, UNIFORM(0, 365, RANDOM()), '2024-01-01'::DATE) as sale_date,
  UNIFORM(1, 100000, RANDOM()) as customer_id,
  UNIFORM(1, 10000, RANDOM()) as product_id,
  UNIFORM(10, 1000, RANDOM()) as amount
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Add search optimization on customer_id
ALTER TABLE sales_optimized 
ADD SEARCH OPTIMIZATION ON EQUALITY(customer_id);

-- Test range query (benefits from clustering)
SELECT * FROM sales_optimized 
WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30';

-- Test point lookup (benefits from search optimization)
SELECT * FROM sales_optimized 
WHERE customer_id = 50000;

-- Test combined query (benefits from both!)
SELECT * FROM sales_optimized 
WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30'
  AND customer_id = 50000;

-- Performance analysis
SELECT 
  'Range Query' as query_type,
  COUNT(*) as result_count,
  SUM(amount) as total_amount
FROM sales_optimized 
WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30'
UNION ALL
SELECT 
  'Point Lookup' as query_type,
  COUNT(*) as result_count,
  SUM(amount) as total_amount
FROM sales_optimized 
WHERE customer_id = 50000
UNION ALL
SELECT 
  'Combined' as query_type,
  COUNT(*) as result_count,
  SUM(amount) as total_amount
FROM sales_optimized 
WHERE sale_date BETWEEN '2024-06-01' AND '2024-06-30'
  AND customer_id = 50000;


-- ============================================================================
-- Bonus: Performance Benchmarking
-- ============================================================================

-- Create comparison table without search optimization
CREATE OR REPLACE TABLE customers_no_opt AS
SELECT * FROM customers;

-- Benchmark queries
-- Query 1: Single customer lookup
SELECT * FROM customers WHERE customer_id = 50000;
SELECT * FROM customers_no_opt WHERE customer_id = 50000;

-- Query 2: Email lookup
SELECT * FROM customers WHERE email = 'user50000@example.com';
SELECT * FROM customers_no_opt WHERE email = 'user50000@example.com';

-- Query 3: Multiple ID lookup
SELECT * FROM customers WHERE customer_id IN (1000, 2000, 3000, 4000, 5000);
SELECT * FROM customers_no_opt WHERE customer_id IN (1000, 2000, 3000, 4000, 5000);

-- Performance comparison summary
SELECT 
  'Optimized Table' as table_type,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(*) as total_rows
FROM customers
WHERE customer_id IN (1000, 2000, 3000, 4000, 5000)
UNION ALL
SELECT 
  'Non-Optimized Table' as table_type,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(*) as total_rows
FROM customers_no_opt
WHERE customer_id IN (1000, 2000, 3000, 4000, 5000);


-- ============================================================================
-- Monitoring and Reporting
-- ============================================================================

-- Comprehensive search optimization report
CREATE OR REPLACE VIEW search_opt_report AS
SELECT 
  t.table_name,
  t.row_count,
  ROUND(t.bytes / 1024 / 1024 / 1024, 2) as table_size_gb,
  t.search_optimization,
  t.search_optimization_progress,
  ROUND(t.search_optimization_bytes / 1024 / 1024 / 1024, 2) as search_opt_size_gb,
  ROUND(
    (t.search_optimization_bytes::FLOAT / NULLIF(t.bytes, 0)) * 100, 
    2
  ) as overhead_pct,
  CASE 
    WHEN t.search_optimization_progress = 100 THEN 'Complete'
    WHEN t.search_optimization_progress > 0 THEN 'Building'
    ELSE 'Not Started'
  END as build_status
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.table_schema = 'DAY09_SEARCH_OPT'
  AND t.table_type = 'BASE TABLE'
ORDER BY t.search_optimization_bytes DESC;

-- Query the report
SELECT * FROM search_opt_report;

-- Query performance analysis
SELECT 
  query_type,
  execution_time,
  partitions_scanned,
  partitions_total,
  ROUND((partitions_scanned::FLOAT / NULLIF(partitions_total, 0)) * 100, 2) as scan_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%customers%'
  AND query_text ILIKE '%WHERE%customer_id%'
  AND start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
ORDER BY start_time DESC
LIMIT 10;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Disable search optimization
-- ALTER TABLE customers DROP SEARCH OPTIMIZATION;
-- ALTER TABLE orders DROP SEARCH OPTIMIZATION;
-- ALTER TABLE products DROP SEARCH OPTIMIZATION;
-- ALTER TABLE application_logs DROP SEARCH OPTIMIZATION;
-- ALTER TABLE sales_optimized DROP SEARCH OPTIMIZATION;

-- Drop tables
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS customers_no_opt;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS application_logs;
-- DROP TABLE IF EXISTS sales_optimized;
-- DROP VIEW IF EXISTS search_opt_costs;
-- DROP VIEW IF EXISTS search_opt_report;
