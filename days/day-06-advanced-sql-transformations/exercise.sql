/*
Day 6: Advanced SQL Transformations - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY06_ADVANCED_SQL;
USE SCHEMA DAY06_ADVANCED_SQL;
USE WAREHOUSE BOOTCAMP_WH;

-- Create sample tables
CREATE OR REPLACE TABLE sales (
  sale_id INT,
  customer_id INT,
  product_id INT,
  category VARCHAR(50),
  amount DECIMAL(10,2),
  quantity INT,
  sale_date DATE
);

CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  signup_date DATE,
  customer_tier VARCHAR(20)
);

CREATE OR REPLACE TABLE events (
  event_id INT,
  event_type VARCHAR(50),
  event_timestamp TIMESTAMP_NTZ,
  event_data VARIANT
);

-- Insert sample data
INSERT INTO sales VALUES
  (1, 101, 1001, 'Electronics', 999.99, 1, '2025-12-01'),
  (2, 102, 1002, 'Electronics', 299.99, 2, '2025-12-01'),
  (3, 101, 1003, 'Clothing', 79.99, 3, '2025-12-02'),
  (4, 103, 1001, 'Electronics', 1299.99, 1, '2025-12-02'),
  (5, 102, 1004, 'Food', 49.99, 5, '2025-12-03'),
  (6, 104, 1002, 'Electronics', 399.99, 1, '2025-12-03'),
  (7, 101, 1005, 'Clothing', 129.99, 2, '2025-12-04'),
  (8, 105, 1003, 'Clothing', 89.99, 1, '2025-12-04'),
  (9, 103, 1006, 'Food', 29.99, 3, '2025-12-05'),
  (10, 104, 1001, 'Electronics', 899.99, 1, '2025-12-05');

INSERT INTO customers VALUES
  (101, 'Alice Johnson', 'alice@example.com', '2024-01-15', 'gold'),
  (102, 'Bob Smith', 'bob@example.com', '2024-03-20', 'silver'),
  (103, 'Carol White', 'carol@example.com', '2024-06-10', 'platinum'),
  (104, 'David Brown', 'david@example.com', '2024-08-05', 'gold'),
  (105, 'Eve Davis', 'eve@example.com', '2024-10-12', 'bronze');

INSERT INTO events 
SELECT 
  1, 'page_view', '2025-12-01 10:00:00'::TIMESTAMP_NTZ,
  PARSE_JSON('{"user_id": 101, "page": "/home", "duration": 45}')
UNION ALL SELECT 
  2, 'purchase', '2025-12-01 10:05:00'::TIMESTAMP_NTZ,
  PARSE_JSON('{"user_id": 101, "order_id": "ORD001", "amount": 999.99, "items": [{"product_id": 1001, "quantity": 1}]}')
UNION ALL SELECT 
  3, 'page_view', '2025-12-01 11:00:00'::TIMESTAMP_NTZ,
  PARSE_JSON('{"user_id": 102, "page": "/products", "duration": 120}');


-- ============================================================================
-- Exercise 1: Window Functions (10 min)
-- ============================================================================

-- TODO: Rank customers by total spending
-- SELECT 
--   customer_id,
--   SUM(amount) as total_spent,
--   RANK() OVER (ORDER BY SUM(amount) DESC) as spending_rank,
--   DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) as dense_rank
-- FROM sales
-- GROUP BY customer_id
-- ORDER BY spending_rank;

-- TODO: Calculate running total of sales by date
-- SELECT 
--   sale_date,
--   SUM(amount) as daily_sales,
--   SUM(SUM(amount)) OVER (ORDER BY sale_date) as running_total
-- FROM sales
-- GROUP BY sale_date
-- ORDER BY sale_date;

-- TODO: Calculate 3-day moving average
-- SELECT 
--   sale_date,
--   SUM(amount) as daily_sales,
--   AVG(SUM(amount)) OVER (
--     ORDER BY sale_date 
--     ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--   ) as moving_avg_3day
-- FROM sales
-- GROUP BY sale_date
-- ORDER BY sale_date;

-- TODO: Find day-over-day change
-- SELECT 
--   sale_date,
--   SUM(amount) as daily_sales,
--   LAG(SUM(amount)) OVER (ORDER BY sale_date) as previous_day_sales,
--   SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY sale_date) as day_over_day_change
-- FROM sales
-- GROUP BY sale_date
-- ORDER BY sale_date;

-- TODO: Assign customers to quartiles based on spending
-- SELECT 
--   customer_id,
--   SUM(amount) as total_spent,
--   NTILE(4) OVER (ORDER BY SUM(amount)) as spending_quartile
-- FROM sales
-- GROUP BY customer_id
-- ORDER BY total_spent DESC;


-- ============================================================================
-- Exercise 2: QUALIFY Clause (5 min)
-- ============================================================================

-- TODO: Get top 2 products per category by sales
-- SELECT 
--   category,
--   product_id,
--   SUM(amount) as total_sales,
--   RANK() OVER (PARTITION BY category ORDER BY SUM(amount) DESC) as rank
-- FROM sales
-- GROUP BY category, product_id
-- QUALIFY rank <= 2
-- ORDER BY category, rank;

-- TODO: Find customers with above-average spending
-- SELECT 
--   customer_id,
--   SUM(amount) as total_spent,
--   AVG(SUM(amount)) OVER () as avg_spent
-- FROM sales
-- GROUP BY customer_id
-- QUALIFY SUM(amount) > AVG(SUM(amount)) OVER ()
-- ORDER BY total_spent DESC;

-- TODO: Deduplicate - keep most recent sale per customer
-- SELECT 
--   customer_id,
--   sale_id,
--   sale_date,
--   amount,
--   ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) as rn
-- FROM sales
-- QUALIFY rn = 1;


-- ============================================================================
-- Exercise 3: Lateral Joins (5 min)
-- ============================================================================

-- TODO: Get top 3 sales for each customer
-- SELECT 
--   c.customer_id,
--   c.customer_name,
--   s.sale_id,
--   s.amount,
--   s.sale_date
-- FROM customers c,
-- LATERAL (
--   SELECT sale_id, amount, sale_date
--   FROM sales
--   WHERE customer_id = c.customer_id
--   ORDER BY amount DESC
--   LIMIT 3
-- ) s
-- ORDER BY c.customer_id, s.amount DESC;

-- TODO: Calculate customer statistics with LATERAL
-- SELECT 
--   c.customer_id,
--   c.customer_name,
--   stats.total_purchases,
--   stats.total_spent,
--   stats.avg_purchase
-- FROM customers c,
-- LATERAL (
--   SELECT 
--     COUNT(*) as total_purchases,
--     SUM(amount) as total_spent,
--     AVG(amount) as avg_purchase
--   FROM sales
--   WHERE customer_id = c.customer_id
-- ) stats
-- ORDER BY stats.total_spent DESC;


-- ============================================================================
-- Exercise 4: JSON Processing (10 min)
-- ============================================================================

-- TODO: Extract JSON fields
-- SELECT 
--   event_id,
--   event_type,
--   event_data:user_id::INT as user_id,
--   event_data:page::STRING as page,
--   event_data:duration::INT as duration,
--   event_data:order_id::STRING as order_id,
--   event_data:amount::DECIMAL(10,2) as amount
-- FROM events;

-- TODO: Flatten nested JSON array
-- SELECT 
--   event_id,
--   event_data:user_id::INT as user_id,
--   f.value:product_id::INT as product_id,
--   f.value:quantity::INT as quantity
-- FROM events,
-- LATERAL FLATTEN(input => event_data:items) f
-- WHERE event_type = 'purchase';

-- TODO: Create JSON objects
-- SELECT 
--   customer_id,
--   OBJECT_CONSTRUCT(
--     'name', customer_name,
--     'email', email,
--     'tier', customer_tier,
--     'signup_date', signup_date
--   ) as customer_json
-- FROM customers;

-- TODO: Aggregate into JSON array
-- SELECT 
--   customer_id,
--   ARRAY_AGG(
--     OBJECT_CONSTRUCT(
--       'sale_id', sale_id,
--       'amount', amount,
--       'date', sale_date
--     )
--   ) WITHIN GROUP (ORDER BY sale_date) as sales_history
-- FROM sales
-- GROUP BY customer_id;


-- ============================================================================
-- Exercise 5: Table Functions (5 min)
-- ============================================================================

-- TODO: Generate date series for December 2025
-- SELECT 
--   ROW_NUMBER() OVER (ORDER BY SEQ4()) as day_num,
--   DATEADD(day, SEQ4(), '2025-12-01'::DATE) as date
-- FROM TABLE(GENERATOR(ROWCOUNT => 31))
-- ORDER BY date;

-- TODO: Split comma-separated values
-- CREATE OR REPLACE TABLE customer_tags (
--   customer_id INT,
--   tags VARCHAR(200)
-- );
-- 
-- INSERT INTO customer_tags VALUES
--   (101, 'vip,frequent,electronics'),
--   (102, 'new,occasional'),
--   (103, 'vip,platinum,high-value');
-- 
-- SELECT 
--   customer_id,
--   TRIM(value) as tag
-- FROM customer_tags,
-- TABLE(SPLIT_TO_TABLE(tags, ','))
-- ORDER BY customer_id;


-- ============================================================================
-- Exercise 6: Advanced Aggregations (5 min)
-- ============================================================================

-- TODO: Use GROUPING SETS for multiple aggregation levels
-- SELECT 
--   category,
--   customer_tier,
--   SUM(amount) as total_sales,
--   COUNT(*) as transaction_count
-- FROM sales s
-- JOIN customers c ON s.customer_id = c.customer_id
-- GROUP BY GROUPING SETS (
--   (category, customer_tier),
--   (category),
--   (customer_tier),
--   ()
-- )
-- ORDER BY category NULLS LAST, customer_tier NULLS LAST;

-- TODO: Use ROLLUP for hierarchical aggregation
-- SELECT 
--   category,
--   product_id,
--   SUM(amount) as total_sales,
--   COUNT(*) as sale_count
-- FROM sales
-- GROUP BY ROLLUP (category, product_id)
-- ORDER BY category NULLS LAST, product_id NULLS LAST;


-- ============================================================================
-- Exercise 7: Recursive CTEs (5 min)
-- ============================================================================

-- TODO: Create organizational hierarchy
-- CREATE OR REPLACE TABLE employees (
--   employee_id INT,
--   employee_name VARCHAR(100),
--   manager_id INT,
--   title VARCHAR(100)
-- );
-- 
-- INSERT INTO employees VALUES
--   (1, 'CEO Alice', NULL, 'Chief Executive Officer'),
--   (2, 'VP Bob', 1, 'VP Engineering'),
--   (3, 'VP Carol', 1, 'VP Sales'),
--   (4, 'Manager David', 2, 'Engineering Manager'),
--   (5, 'Manager Eve', 2, 'Engineering Manager'),
--   (6, 'Manager Frank', 3, 'Sales Manager'),
--   (7, 'Engineer Grace', 4, 'Senior Engineer'),
--   (8, 'Engineer Henry', 4, 'Engineer'),
--   (9, 'Engineer Iris', 5, 'Engineer'),
--   (10, 'Sales Jack', 6, 'Sales Rep');

-- TODO: Query organizational hierarchy
-- WITH RECURSIVE org_hierarchy AS (
--   -- Anchor: Top level (CEO)
--   SELECT 
--     employee_id,
--     employee_name,
--     manager_id,
--     title,
--     1 as level,
--     employee_name as path
--   FROM employees
--   WHERE manager_id IS NULL
--   
--   UNION ALL
--   
--   -- Recursive: Next level
--   SELECT 
--     e.employee_id,
--     e.employee_name,
--     e.manager_id,
--     e.title,
--     oh.level + 1,
--     oh.path || ' > ' || e.employee_name
--   FROM employees e
--   JOIN org_hierarchy oh ON e.manager_id = oh.employee_id
-- )
-- SELECT 
--   REPEAT('  ', level - 1) || employee_name as org_chart,
--   title,
--   level,
--   path
-- FROM org_hierarchy
-- ORDER BY path;


-- ============================================================================
-- Bonus Challenge: Real-World Pattern (10 min)
-- ============================================================================

-- TODO: Implement a complete customer analytics query combining multiple techniques

-- Requirements:
-- 1. Rank customers by total spending
-- 2. Calculate running total of their purchases
-- 3. Identify their most purchased category
-- 4. Calculate days since last purchase
-- 5. Assign customer segments (High/Medium/Low value)
-- 6. Include customer tier information

-- SELECT 
--   c.customer_id,
--   c.customer_name,
--   c.customer_tier,
--   COUNT(s.sale_id) as total_purchases,
--   SUM(s.amount) as total_spent,
--   AVG(s.amount) as avg_purchase,
--   MAX(s.sale_date) as last_purchase_date,
--   DATEDIFF(day, MAX(s.sale_date), CURRENT_DATE()) as days_since_last_purchase,
--   RANK() OVER (ORDER BY SUM(s.amount) DESC) as spending_rank,
--   -- Most purchased category
--   FIRST_VALUE(s.category) OVER (
--     PARTITION BY c.customer_id 
--     ORDER BY COUNT(*) DESC
--   ) as favorite_category,
--   -- Customer segment
--   CASE 
--     WHEN NTILE(3) OVER (ORDER BY SUM(s.amount) DESC) = 1 THEN 'High Value'
--     WHEN NTILE(3) OVER (ORDER BY SUM(s.amount) DESC) = 2 THEN 'Medium Value'
--     ELSE 'Low Value'
--   END as customer_segment
-- FROM customers c
-- LEFT JOIN sales s ON c.customer_id = s.customer_id
-- GROUP BY c.customer_id, c.customer_name, c.customer_tier, s.category
-- QUALIFY ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY COUNT(*) DESC) = 1
-- ORDER BY total_spent DESC;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS events;
-- DROP TABLE IF EXISTS customer_tags;
-- DROP TABLE IF EXISTS employees;
