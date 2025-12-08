/*
Day 11: Query Performance Tuning - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
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
-- Exercise 1: Analyze Query Profiles (10 min)
-- ============================================================================

-- TODO: Run this poorly optimized query
-- SELECT * FROM sales WHERE YEAR(sale_date) = 2024;

-- TODO: Go to Query History and open Query Profile
-- Analyze:
-- - Execution time
-- - Partitions scanned vs. total
-- - Bytes scanned
-- - Any warnings or issues

-- TODO: Run optimized version
-- SELECT * FROM sales 
-- WHERE sale_date >= '2024-01-01' 
--   AND sale_date < '2025-01-01';

-- TODO: Compare Query Profiles
-- Document differences:
-- - Execution time improvement
-- - Partitions scanned reduction
-- - Bytes scanned reduction

-- TODO: Run query with multiple filters
-- SELECT * FROM sales
-- WHERE sale_date >= '2024-01-01'
--   AND region = 'NORTH'
--   AND category = 'Electronics';

-- TODO: Analyze partition pruning effectiveness
-- Check Query Profile for:
-- - Partitions scanned
-- - Filter pushdown
-- - Pruning percentage


-- ============================================================================
-- Exercise 2: Optimize Partition Pruning (10 min)
-- ============================================================================

-- TODO: Poor pruning - function on column
-- SELECT 
--   DATE_TRUNC('month', sale_date) as month,
--   SUM(amount) as total_sales
-- FROM sales
-- WHERE YEAR(sale_date) = 2024
-- GROUP BY month;

-- TODO: Optimized pruning - direct comparison
-- SELECT 
--   DATE_TRUNC('month', sale_date) as month,
--   SUM(amount) as total_sales
-- FROM sales
-- WHERE sale_date >= '2024-01-01' 
--   AND sale_date < '2025-01-01'
-- GROUP BY month;

-- TODO: Compare partitions scanned in Query Profile

-- TODO: Poor - OR with different columns
-- SELECT * FROM sales
-- WHERE sale_date = '2024-01-15' OR region = 'NORTH';

-- TODO: Better - Separate queries or restructure
-- SELECT * FROM sales WHERE sale_date = '2024-01-15'
-- UNION ALL
-- SELECT * FROM sales WHERE region = 'NORTH' AND sale_date != '2024-01-15';

-- TODO: Use BETWEEN for ranges
-- SELECT * FROM sales
-- WHERE sale_date BETWEEN '2024-01-01' AND '2024-12-31';

-- TODO: Use IN for multiple values
-- SELECT * FROM sales
-- WHERE region IN ('NORTH', 'SOUTH');


-- ============================================================================
-- Exercise 3: Optimize JOIN Operations (10 min)
-- ============================================================================

-- TODO: Poor - No filtering before join
-- SELECT 
--   s.sale_id,
--   s.sale_date,
--   s.amount,
--   c.customer_name,
--   c.customer_tier
-- FROM sales s
-- JOIN customers c ON s.customer_id = c.customer_id
-- WHERE s.sale_date >= '2024-01-01';

-- TODO: Better - Filter before join using CTE
-- WITH recent_sales AS (
--   SELECT * FROM sales 
--   WHERE sale_date >= '2024-01-01'
-- )
-- SELECT 
--   s.sale_id,
--   s.sale_date,
--   s.amount,
--   c.customer_name,
--   c.customer_tier
-- FROM recent_sales s
-- JOIN customers c ON s.customer_id = c.customer_id;

-- TODO: Compare Query Profiles
-- Check:
-- - Rows processed in join
-- - Join execution time
-- - Memory usage

-- TODO: Poor - Correlated subquery
-- SELECT 
--   c.customer_id,
--   c.customer_name,
--   (SELECT COUNT(*) FROM sales WHERE customer_id = c.customer_id) as order_count
-- FROM customers c;

-- TODO: Better - Use JOIN with aggregation
-- SELECT 
--   c.customer_id,
--   c.customer_name,
--   COUNT(s.sale_id) as order_count
-- FROM customers c
-- LEFT JOIN sales s ON c.customer_id = s.customer_id
-- GROUP BY c.customer_id, c.customer_name;

-- TODO: Use EXISTS instead of IN for large subqueries
-- Poor:
-- SELECT * FROM customers
-- WHERE customer_id IN (SELECT customer_id FROM sales WHERE amount > 500);

-- Better:
-- SELECT * FROM customers c
-- WHERE EXISTS (
--   SELECT 1 FROM sales s 
--   WHERE s.customer_id = c.customer_id 
--     AND s.amount > 500
-- );


-- ============================================================================
-- Exercise 4: Fix Data Spilling (5 min)
-- ============================================================================

-- TODO: Create query that might cause spilling
-- SELECT 
--   customer_id,
--   product_id,
--   sale_date,
--   region,
--   category,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_amount,
--   AVG(amount) as avg_amount,
--   MIN(amount) as min_amount,
--   MAX(amount) as max_amount
-- FROM sales
-- GROUP BY customer_id, product_id, sale_date, region, category;

-- TODO: Check Query Profile for spilling
-- Look for:
-- - "Bytes spilled to local storage"
-- - "Bytes spilled to remote storage"
-- - Red warning indicators

-- TODO: Fix by reducing granularity
-- SELECT 
--   customer_id,
--   DATE_TRUNC('month', sale_date) as month,
--   region,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_amount
-- FROM sales
-- GROUP BY customer_id, month, region;

-- TODO: Alternative fix - increase warehouse size
-- ALTER WAREHOUSE BOOTCAMP_WH SET WAREHOUSE_SIZE = 'MEDIUM';
-- -- Run query again
-- ALTER WAREHOUSE BOOTCAMP_WH SET WAREHOUSE_SIZE = 'XSMALL';


-- ============================================================================
-- Exercise 5: Optimize Aggregations (5 min)
-- ============================================================================

-- TODO: Poor - Multiple passes over data
-- SELECT 
--   (SELECT COUNT(*) FROM sales WHERE region = 'NORTH') as north_count,
--   (SELECT COUNT(*) FROM sales WHERE region = 'SOUTH') as south_count,
--   (SELECT COUNT(*) FROM sales WHERE region = 'EAST') as east_count,
--   (SELECT COUNT(*) FROM sales WHERE region = 'WEST') as west_count;

-- TODO: Better - Single pass with CASE
-- SELECT 
--   COUNT(CASE WHEN region = 'NORTH' THEN 1 END) as north_count,
--   COUNT(CASE WHEN region = 'SOUTH' THEN 1 END) as south_count,
--   COUNT(CASE WHEN region = 'EAST' THEN 1 END) as east_count,
--   COUNT(CASE WHEN region = 'WEST' THEN 1 END) as west_count
-- FROM sales;

-- TODO: Compare execution times

-- TODO: Poor - Unnecessary DISTINCT
-- SELECT DISTINCT customer_id, sale_date, product_id
-- FROM sales;

-- TODO: Better - Use GROUP BY
-- SELECT customer_id, sale_date, product_id
-- FROM sales
-- GROUP BY customer_id, sale_date, product_id;

-- TODO: Use QUALIFY instead of subquery
-- Poor:
-- SELECT * FROM (
--   SELECT 
--     customer_id,
--     sale_date,
--     amount,
--     ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) as rn
--   FROM sales
-- ) WHERE rn = 1;

-- Better:
-- SELECT 
--   customer_id,
--   sale_date,
--   amount
-- FROM sales
-- QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) = 1;


-- ============================================================================
-- Exercise 6: Window Function Optimization (5 min)
-- ============================================================================

-- TODO: Poor - Inconsistent partitioning
-- SELECT 
--   customer_id,
--   sale_date,
--   amount,
--   ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date) as rn,
--   SUM(amount) OVER (PARTITION BY region ORDER BY sale_date) as running_total
-- FROM sales;

-- TODO: Better - Consistent partitioning
-- SELECT 
--   customer_id,
--   sale_date,
--   amount,
--   region,
--   ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date) as rn,
--   SUM(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) as customer_running_total
-- FROM sales;

-- TODO: Use window functions efficiently
-- SELECT 
--   customer_id,
--   sale_date,
--   amount,
--   -- Multiple window functions with same partition
--   ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date) as row_num,
--   RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) as amount_rank,
--   SUM(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) as running_total
-- FROM sales;


-- ============================================================================
-- Exercise 7: Real-World Query Tuning (5 min)
-- ============================================================================

-- TODO: Analyze this complex query
-- SELECT 
--   c.customer_tier,
--   p.category,
--   DATE_TRUNC('month', s.sale_date) as month,
--   COUNT(DISTINCT s.customer_id) as unique_customers,
--   COUNT(s.sale_id) as total_sales,
--   SUM(s.amount) as total_revenue,
--   AVG(s.amount) as avg_sale_amount
-- FROM sales s
-- JOIN customers c ON s.customer_id = c.customer_id
-- JOIN products p ON s.product_id = p.product_id
-- WHERE YEAR(s.sale_date) = 2024
--   AND c.customer_tier IN ('gold', 'platinum')
-- GROUP BY c.customer_tier, p.category, month
-- ORDER BY month DESC, total_revenue DESC;

-- TODO: Optimize the query
-- WITH filtered_sales AS (
--   SELECT * FROM sales
--   WHERE sale_date >= '2024-01-01' 
--     AND sale_date < '2025-01-01'
-- ),
-- gold_platinum_customers AS (
--   SELECT customer_id, customer_tier
--   FROM customers
--   WHERE customer_tier IN ('gold', 'platinum')
-- )
-- SELECT 
--   c.customer_tier,
--   p.category,
--   DATE_TRUNC('month', s.sale_date) as month,
--   COUNT(DISTINCT s.customer_id) as unique_customers,
--   COUNT(s.sale_id) as total_sales,
--   SUM(s.amount) as total_revenue,
--   AVG(s.amount) as avg_sale_amount
-- FROM filtered_sales s
-- JOIN gold_platinum_customers c ON s.customer_id = c.customer_id
-- JOIN products p ON s.product_id = p.product_id
-- GROUP BY c.customer_tier, p.category, month
-- ORDER BY month DESC, total_revenue DESC;

-- TODO: Compare Query Profiles
-- Document improvements:
-- - Execution time
-- - Partitions scanned
-- - Rows processed
-- - Memory usage


-- ============================================================================
-- Bonus: Use EXPLAIN (Optional)
-- ============================================================================

-- TODO: View query execution plan
-- EXPLAIN
-- SELECT 
--   region,
--   category,
--   SUM(amount) as total_sales
-- FROM sales
-- WHERE sale_date >= '2024-01-01'
-- GROUP BY region, category;

-- TODO: Analyze the plan
-- Look for:
-- - Join strategies
-- - Filter pushdown
-- - Partition pruning
-- - Estimated rows


-- ============================================================================
-- Performance Comparison Summary
-- ============================================================================

-- TODO: Create a summary of optimizations
-- Document for each optimization:
-- 1. Original query execution time
-- 2. Optimized query execution time
-- 3. Performance improvement %
-- 4. Key optimization technique used
-- 5. Partitions scanned before/after


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS products;
