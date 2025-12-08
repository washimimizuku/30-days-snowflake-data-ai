/*
Day 11: Query Performance Tuning - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY11_QUERY_TUNING;
USE SCHEMA DAY11_QUERY_TUNING;
USE WAREHOUSE BOOTCAMP_WH;

-- Create large sales table
CREATE OR REPLACE TABLE sales (
  sale_id INT,
  sale_date DATE,
  sale_timestamp TIMESTAMP_NTZ,
  customer_id INT,
  product_id INT,
  region VARCHAR(50),
  category VARCHAR(100),
  amount DECIMAL(10,2),
  quantity INT
);

-- Insert large dataset
INSERT INTO sales
SELECT 
  SEQ4() as sale_id,
  DATEADD(day, UNIFORM(0, 730, RANDOM()), '2023-01-01'::DATE) as sale_date,
  DATEADD(second, UNIFORM(0, 86400, RANDOM()), sale_date) as sale_timestamp,
  UNIFORM(1, 50000, RANDOM()) as customer_id,
  UNIFORM(1, 5000, RANDOM()) as product_id,
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
  END as category,
  UNIFORM(10, 1000, RANDOM()) as amount,
  UNIFORM(1, 10, RANDOM()) as quantity
FROM TABLE(GENERATOR(ROWCOUNT => 500000));

-- Create customers table
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(200),
  email VARCHAR(200),
  customer_tier VARCHAR(20),
  registration_date DATE
);

-- Insert customers
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
  DATEADD(day, UNIFORM(0, 1000, RANDOM()), '2021-01-01'::DATE) as registration_date
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- Create products table
CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name VARCHAR(200),
  category VARCHAR(100),
  price DECIMAL(10,2)
);

-- Insert products
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
FROM TABLE(GENERATOR(ROWCOUNT => 5000));


-- ============================================================================
-- Exercise 1: Analyze Query Profiles
-- ============================================================================

-- Poor query (prevents partition pruning)
SELECT * FROM sales WHERE YEAR(sale_date) = 2024;

-- Optimized query (enables partition pruning)
SELECT * FROM sales 
WHERE sale_date >= '2024-01-01' 
  AND sale_date < '2025-01-01';

-- Query with multiple filters
SELECT * FROM sales
WHERE sale_date >= '2024-01-01'
  AND region = 'NORTH'
  AND category = 'Electronics';

-- Check partition pruning effectiveness
SELECT 
  COUNT(*) as total_rows,
  COUNT(DISTINCT sale_date) as unique_dates
FROM sales
WHERE sale_date >= '2024-01-01'
  AND sale_date < '2025-01-01';


-- ============================================================================
-- Exercise 2: Optimize Partition Pruning
-- ============================================================================

-- Poor pruning - function on column
SELECT 
  DATE_TRUNC('month', sale_date) as month,
  SUM(amount) as total_sales
FROM sales
WHERE YEAR(sale_date) = 2024
GROUP BY month;

-- Optimized pruning - direct comparison
SELECT 
  DATE_TRUNC('month', sale_date) as month,
  SUM(amount) as total_sales
FROM sales
WHERE sale_date >= '2024-01-01' 
  AND sale_date < '2025-01-01'
GROUP BY month
ORDER BY month;

-- Poor - OR with different columns
SELECT * FROM sales
WHERE sale_date = '2024-01-15' OR region = 'NORTH'
LIMIT 100;

-- Better - Separate queries
SELECT * FROM sales WHERE sale_date = '2024-01-15'
UNION ALL
SELECT * FROM sales WHERE region = 'NORTH' AND sale_date != '2024-01-15'
LIMIT 100;

-- Use BETWEEN for ranges
SELECT * FROM sales
WHERE sale_date BETWEEN '2024-01-01' AND '2024-12-31'
LIMIT 100;

-- Use IN for multiple values
SELECT * FROM sales
WHERE region IN ('NORTH', 'SOUTH')
LIMIT 100;


-- ============================================================================
-- Exercise 3: Optimize JOIN Operations
-- ============================================================================

-- Poor - No filtering before join
SELECT 
  s.sale_id,
  s.sale_date,
  s.amount,
  c.customer_name,
  c.customer_tier
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
WHERE s.sale_date >= '2024-01-01'
LIMIT 100;

-- Better - Filter before join using CTE
WITH recent_sales AS (
  SELECT * FROM sales 
  WHERE sale_date >= '2024-01-01'
)
SELECT 
  s.sale_id,
  s.sale_date,
  s.amount,
  c.customer_name,
  c.customer_tier
FROM recent_sales s
JOIN customers c ON s.customer_id = c.customer_id
LIMIT 100;

-- Poor - Correlated subquery
SELECT 
  c.customer_id,
  c.customer_name,
  (SELECT COUNT(*) FROM sales WHERE customer_id = c.customer_id) as order_count
FROM customers c
LIMIT 100;

-- Better - Use JOIN with aggregation
SELECT 
  c.customer_id,
  c.customer_name,
  COUNT(s.sale_id) as order_count
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
LIMIT 100;

-- Use EXISTS instead of IN
-- Poor:
SELECT * FROM customers
WHERE customer_id IN (SELECT customer_id FROM sales WHERE amount > 500)
LIMIT 100;

-- Better:
SELECT * FROM customers c
WHERE EXISTS (
  SELECT 1 FROM sales s 
  WHERE s.customer_id = c.customer_id 
    AND s.amount > 500
)
LIMIT 100;


-- ============================================================================
-- Exercise 4: Fix Data Spilling
-- ============================================================================

-- Query that might cause spilling
SELECT 
  customer_id,
  product_id,
  sale_date,
  region,
  category,
  COUNT(*) as sale_count,
  SUM(amount) as total_amount,
  AVG(amount) as avg_amount,
  MIN(amount) as min_amount,
  MAX(amount) as max_amount
FROM sales
GROUP BY customer_id, product_id, sale_date, region, category;

-- Fixed by reducing granularity
SELECT 
  customer_id,
  DATE_TRUNC('month', sale_date) as month,
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_amount,
  AVG(amount) as avg_amount
FROM sales
GROUP BY customer_id, month, region;

-- Alternative: Break into stages
CREATE TEMP TABLE stage1 AS
SELECT 
  customer_id,
  product_id,
  DATE_TRUNC('month', sale_date) as month,
  SUM(amount) as total_amount
FROM sales
GROUP BY customer_id, product_id, month;

SELECT 
  customer_id,
  month,
  SUM(total_amount) as grand_total
FROM stage1
GROUP BY customer_id, month;


-- ============================================================================
-- Exercise 5: Optimize Aggregations
-- ============================================================================

-- Poor - Multiple passes
SELECT 
  (SELECT COUNT(*) FROM sales WHERE region = 'NORTH') as north_count,
  (SELECT COUNT(*) FROM sales WHERE region = 'SOUTH') as south_count,
  (SELECT COUNT(*) FROM sales WHERE region = 'EAST') as east_count,
  (SELECT COUNT(*) FROM sales WHERE region = 'WEST') as west_count;

-- Better - Single pass with CASE
SELECT 
  COUNT(CASE WHEN region = 'NORTH' THEN 1 END) as north_count,
  COUNT(CASE WHEN region = 'SOUTH' THEN 1 END) as south_count,
  COUNT(CASE WHEN region = 'EAST' THEN 1 END) as east_count,
  COUNT(CASE WHEN region = 'WEST' THEN 1 END) as west_count
FROM sales;

-- Poor - Unnecessary DISTINCT
SELECT DISTINCT customer_id, sale_date, product_id
FROM sales
LIMIT 100;

-- Better - Use GROUP BY
SELECT customer_id, sale_date, product_id
FROM sales
GROUP BY customer_id, sale_date, product_id
LIMIT 100;

-- Use QUALIFY instead of subquery
-- Poor:
SELECT * FROM (
  SELECT 
    customer_id,
    sale_date,
    amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) as rn
  FROM sales
) WHERE rn = 1;

-- Better:
SELECT 
  customer_id,
  sale_date,
  amount
FROM sales
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) = 1;


-- ============================================================================
-- Exercise 6: Window Function Optimization
-- ============================================================================

-- Poor - Inconsistent partitioning
SELECT 
  customer_id,
  sale_date,
  amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date) as rn,
  SUM(amount) OVER (PARTITION BY region ORDER BY sale_date) as running_total
FROM sales
LIMIT 100;

-- Better - Consistent partitioning
SELECT 
  customer_id,
  sale_date,
  amount,
  region,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date) as rn,
  SUM(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) as customer_running_total
FROM sales
LIMIT 100;

-- Efficient window functions with same partition
SELECT 
  customer_id,
  sale_date,
  amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date) as row_num,
  RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) as amount_rank,
  SUM(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) as running_total,
  AVG(amount) OVER (PARTITION BY customer_id) as avg_amount
FROM sales
LIMIT 100;


-- ============================================================================
-- Exercise 7: Real-World Query Tuning
-- ============================================================================

-- Original complex query
SELECT 
  c.customer_tier,
  p.category,
  DATE_TRUNC('month', s.sale_date) as month,
  COUNT(DISTINCT s.customer_id) as unique_customers,
  COUNT(s.sale_id) as total_sales,
  SUM(s.amount) as total_revenue,
  AVG(s.amount) as avg_sale_amount
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
WHERE YEAR(s.sale_date) = 2024
  AND c.customer_tier IN ('gold', 'platinum')
GROUP BY c.customer_tier, p.category, month
ORDER BY month DESC, total_revenue DESC;

-- Optimized query
WITH filtered_sales AS (
  SELECT * FROM sales
  WHERE sale_date >= '2024-01-01' 
    AND sale_date < '2025-01-01'
),
gold_platinum_customers AS (
  SELECT customer_id, customer_tier
  FROM customers
  WHERE customer_tier IN ('gold', 'platinum')
)
SELECT 
  c.customer_tier,
  p.category,
  DATE_TRUNC('month', s.sale_date) as month,
  COUNT(DISTINCT s.customer_id) as unique_customers,
  COUNT(s.sale_id) as total_sales,
  SUM(s.amount) as total_revenue,
  AVG(s.amount) as avg_sale_amount
FROM filtered_sales s
JOIN gold_platinum_customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.customer_tier, p.category, month
ORDER BY month DESC, total_revenue DESC;


-- ============================================================================
-- Bonus: Use EXPLAIN
-- ============================================================================

-- View query execution plan
EXPLAIN
SELECT 
  region,
  category,
  SUM(amount) as total_sales
FROM sales
WHERE sale_date >= '2024-01-01'
GROUP BY region, category;

-- Complex query plan
EXPLAIN
WITH recent_sales AS (
  SELECT * FROM sales 
  WHERE sale_date >= '2024-01-01'
)
SELECT 
  c.customer_tier,
  COUNT(s.sale_id) as order_count,
  SUM(s.amount) as total_revenue
FROM recent_sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_tier;


-- ============================================================================
-- Performance Comparison Queries
-- ============================================================================

-- Compare partition pruning
SELECT 
  'With Function' as query_type,
  COUNT(*) as row_count
FROM sales
WHERE YEAR(sale_date) = 2024
UNION ALL
SELECT 
  'Direct Comparison' as query_type,
  COUNT(*) as row_count
FROM sales
WHERE sale_date >= '2024-01-01' AND sale_date < '2025-01-01';

-- Compare aggregation methods
SELECT 
  'Single Pass' as method,
  COUNT(CASE WHEN region = 'NORTH' THEN 1 END) as north_count
FROM sales
UNION ALL
SELECT 
  'Multiple Passes' as method,
  (SELECT COUNT(*) FROM sales WHERE region = 'NORTH') as north_count;

-- Compare JOIN strategies
WITH filtered_first AS (
  SELECT 
    s.customer_id,
    COUNT(*) as order_count
  FROM sales s
  WHERE s.sale_date >= '2024-01-01'
  GROUP BY s.customer_id
)
SELECT 
  c.customer_name,
  f.order_count
FROM customers c
JOIN filtered_first f ON c.customer_id = f.customer_id
LIMIT 10;


-- ============================================================================
-- Monitoring Queries
-- ============================================================================

-- Check query performance from history
SELECT 
  query_id,
  query_text,
  execution_time,
  partitions_scanned,
  partitions_total,
  ROUND((partitions_scanned::FLOAT / NULLIF(partitions_total, 0)) * 100, 2) as scan_pct,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%sales%'
  AND start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
ORDER BY execution_time DESC
LIMIT 10;

-- Identify queries with spilling
SELECT 
  query_id,
  query_text,
  execution_time,
  bytes_spilled_to_local_storage / 1024 / 1024 / 1024 as gb_spilled_local,
  bytes_spilled_to_remote_storage / 1024 / 1024 / 1024 as gb_spilled_remote
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE bytes_spilled_to_local_storage > 0
  OR bytes_spilled_to_remote_storage > 0
  AND start_time >= DATEADD(day, -1, CURRENT_TIMESTAMP())
ORDER BY execution_time DESC
LIMIT 10;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS stage1;
