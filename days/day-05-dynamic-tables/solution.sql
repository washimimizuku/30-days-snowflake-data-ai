/*
Day 5: Dynamic Tables - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY05_DYNAMIC_TABLES;
USE SCHEMA DAY05_DYNAMIC_TABLES;
USE WAREHOUSE BOOTCAMP_WH;

-- Create source tables
CREATE OR REPLACE TABLE sales_raw (
  sale_id INT,
  product_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  quantity INT,
  sale_date DATE,
  sale_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name VARCHAR(100),
  category VARCHAR(50),
  price DECIMAL(10,2)
);

CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  customer_tier VARCHAR(20),
  signup_date DATE
);

-- Insert sample data
INSERT INTO sales_raw (sale_id, product_id, customer_id, amount, quantity, sale_date) VALUES
  (1, 101, 1001, 199.99, 2, '2025-12-01'),
  (2, 102, 1002, 149.99, 1, '2025-12-01'),
  (3, 103, 1003, 299.99, 3, '2025-12-02'),
  (4, 101, 1004, 99.99, 1, '2025-12-02'),
  (5, 104, 1005, 399.99, 2, '2025-12-03');

INSERT INTO products (product_id, product_name, category, price) VALUES
  (101, 'Laptop', 'Electronics', 999.99),
  (102, 'Mouse', 'Electronics', 29.99),
  (103, 'Keyboard', 'Electronics', 79.99),
  (104, 'Monitor', 'Electronics', 299.99);

INSERT INTO customers (customer_id, customer_name, customer_tier, signup_date) VALUES
  (1001, 'Alice Johnson', 'gold', '2024-01-15'),
  (1002, 'Bob Smith', 'silver', '2024-03-20'),
  (1003, 'Carol White', 'bronze', '2024-06-10'),
  (1004, 'David Brown', 'gold', '2024-08-05'),
  (1005, 'Eve Davis', 'platinum', '2024-10-12');


-- ============================================================================
-- Exercise 1: Create Basic Dynamic Table
-- ============================================================================

CREATE DYNAMIC TABLE daily_sales_summary
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    sale_date,
    COUNT(*) as total_transactions,
    SUM(amount) as total_sales,
    AVG(amount) as avg_sale_amount,
    SUM(quantity) as total_quantity
  FROM sales_raw
  GROUP BY sale_date;

-- Query the Dynamic Table
SELECT * FROM daily_sales_summary ORDER BY sale_date;

-- Show Dynamic Tables
SHOW DYNAMIC TABLES;

-- Check refresh history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
  NAME => 'DAILY_SALES_SUMMARY'
))
ORDER BY REFRESH_START_TIME DESC;


-- ============================================================================
-- Exercise 2: Configure TARGET_LAG
-- ============================================================================

CREATE DYNAMIC TABLE product_sales_1min
  TARGET_LAG = '1 minute'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    product_id,
    COUNT(*) as sale_count,
    SUM(amount) as total_revenue
  FROM sales_raw
  GROUP BY product_id;

CREATE DYNAMIC TABLE product_sales_1hour
  TARGET_LAG = '1 hour'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    product_id,
    COUNT(*) as sale_count,
    SUM(amount) as total_revenue
  FROM sales_raw
  GROUP BY product_id;

-- Insert new data to trigger refresh
INSERT INTO sales_raw (sale_id, product_id, customer_id, amount, quantity, sale_date) VALUES
  (6, 102, 1001, 59.98, 2, '2025-12-04');

-- Check which table refreshes faster (wait a minute)
SELECT * FROM product_sales_1min;
SELECT * FROM product_sales_1hour;

-- Change TARGET_LAG
ALTER DYNAMIC TABLE product_sales_1min SET TARGET_LAG = '10 minutes';


-- ============================================================================
-- Exercise 3: Multi-Layer Pipeline
-- ============================================================================

-- Layer 1 - Clean and filter sales
CREATE DYNAMIC TABLE sales_clean
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    sale_id,
    product_id,
    customer_id,
    amount,
    quantity,
    sale_date
  FROM sales_raw
  WHERE amount > 0 AND quantity > 0;

-- Layer 2 - Enrich with product information
CREATE DYNAMIC TABLE sales_enriched
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    s.sale_id,
    s.product_id,
    p.product_name,
    p.category,
    s.customer_id,
    s.amount,
    s.quantity,
    s.sale_date
  FROM sales_clean s
  JOIN products p ON s.product_id = p.product_id;

-- Layer 3 - Category summary
CREATE DYNAMIC TABLE category_summary
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    category,
    COUNT(DISTINCT sale_id) as total_sales,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_sale_amount,
    COUNT(DISTINCT customer_id) as unique_customers
  FROM sales_enriched
  GROUP BY category;

-- Query the final layer
SELECT * FROM category_summary;

-- View the pipeline dependencies
SHOW DYNAMIC TABLES;


-- ============================================================================
-- Exercise 4: Incremental vs. Full Refresh
-- ============================================================================

-- Dynamic Table with incremental refresh (simple aggregation)
CREATE DYNAMIC TABLE sales_by_customer_incremental
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    customer_id,
    COUNT(*) as purchase_count,
    SUM(amount) as total_spent,
    MAX(sale_date) as last_purchase_date
  FROM sales_raw
  GROUP BY customer_id;

-- Dynamic Table with full refresh (window function)
CREATE DYNAMIC TABLE customer_rankings_full
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    customer_id,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) as spending_rank,
    NTILE(4) OVER (ORDER BY total_spent) as spending_quartile
  FROM (
    SELECT 
      customer_id,
      SUM(amount) as total_spent
    FROM sales_raw
    GROUP BY customer_id
  );

-- Check refresh mode in history
SELECT 
  dynamic_table_name,
  refresh_action,
  refresh_start_time,
  refresh_end_time,
  DATEDIFF(second, refresh_start_time, refresh_end_time) as duration_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLE_REFRESH_HISTORY
WHERE dynamic_table_name IN ('SALES_BY_CUSTOMER_INCREMENTAL', 'CUSTOMER_RANKINGS_FULL')
ORDER BY refresh_start_time DESC;


-- ============================================================================
-- Exercise 5: Monitor Refresh History
-- ============================================================================

-- View all Dynamic Table refreshes
SELECT 
  dynamic_table_name,
  refresh_action,
  state,
  refresh_start_time,
  refresh_end_time,
  DATEDIFF(second, refresh_start_time, refresh_end_time) as duration_seconds
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY())
WHERE refresh_start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY refresh_start_time DESC;

-- Check current lag for all Dynamic Tables
SELECT 
  name as table_name,
  target_lag,
  data_timestamp,
  DATEDIFF(second, data_timestamp, CURRENT_TIMESTAMP()) as current_lag_seconds,
  scheduling_state,
  last_refresh_time
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLES())
ORDER BY name;

-- Identify tables that are behind schedule
SELECT 
  name,
  target_lag,
  DATEDIFF(second, data_timestamp, CURRENT_TIMESTAMP()) as current_lag_seconds,
  CASE 
    WHEN current_lag_seconds > EXTRACT(EPOCH FROM target_lag::INTERVAL) THEN 'Behind'
    ELSE 'On Track'
  END as status
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLES());


-- ============================================================================
-- Exercise 6: Cost Analysis
-- ============================================================================

-- Calculate credit usage by Dynamic Table
SELECT 
  dynamic_table_name,
  COUNT(*) as refresh_count,
  SUM(credits_used) as total_credits,
  AVG(credits_used) as avg_credits_per_refresh,
  MIN(credits_used) as min_credits,
  MAX(credits_used) as max_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLE_REFRESH_HISTORY
WHERE refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY dynamic_table_name
ORDER BY total_credits DESC;

-- Daily credit usage trend
SELECT 
  DATE_TRUNC('day', refresh_start_time) as day,
  dynamic_table_name,
  COUNT(*) as refresh_count,
  SUM(credits_used) as daily_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLE_REFRESH_HISTORY
WHERE refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 4 DESC;

-- Compare incremental vs full refresh costs
SELECT 
  dynamic_table_name,
  refresh_action,
  COUNT(*) as refresh_count,
  AVG(credits_used) as avg_credits,
  AVG(DATEDIFF(second, refresh_start_time, refresh_end_time)) as avg_duration_sec
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLE_REFRESH_HISTORY
WHERE refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1, 2;


-- ============================================================================
-- Exercise 7: Dynamic Tables vs. Materialized Views
-- ============================================================================

-- Create Materialized View for comparison
CREATE MATERIALIZED VIEW sales_summary_mv AS
  SELECT 
    product_id,
    COUNT(*) as sale_count,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_revenue
  FROM sales_raw
  GROUP BY product_id;

-- Create equivalent Dynamic Table
CREATE DYNAMIC TABLE sales_summary_dt
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    product_id,
    COUNT(*) as sale_count,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_revenue
  FROM sales_raw
  GROUP BY product_id;

-- Compare results
SELECT 'Materialized View' as source, * FROM sales_summary_mv
UNION ALL
SELECT 'Dynamic Table' as source, * FROM sales_summary_dt
ORDER BY source, product_id;

-- Insert new data and observe refresh behavior
INSERT INTO sales_raw (sale_id, product_id, customer_id, amount, quantity, sale_date) VALUES
  (7, 103, 1002, 159.98, 2, '2025-12-04');


-- ============================================================================
-- Bonus: Production Pipeline
-- ============================================================================

-- Layer 1: Data quality and filtering
CREATE DYNAMIC TABLE sales_validated
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    sale_id,
    product_id,
    customer_id,
    amount,
    quantity,
    sale_date,
    sale_timestamp
  FROM sales_raw
  WHERE amount > 0 
    AND quantity > 0
    AND sale_date >= DATEADD(year, -1, CURRENT_DATE());

-- Layer 2: Enrichment with dimensions
CREATE DYNAMIC TABLE sales_fact
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    s.sale_id,
    s.sale_date,
    s.product_id,
    p.product_name,
    p.category,
    s.customer_id,
    c.customer_name,
    c.customer_tier,
    s.amount,
    s.quantity,
    s.amount * s.quantity as total_value
  FROM sales_validated s
  JOIN products p ON s.product_id = p.product_id
  JOIN customers c ON s.customer_id = c.customer_id;

-- Layer 3: Daily aggregations
CREATE DYNAMIC TABLE daily_metrics
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = BOOTCAMP_WH
AS
  SELECT 
    sale_date,
    category,
    customer_tier,
    COUNT(DISTINCT sale_id) as transaction_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_transaction_value,
    SUM(quantity) as total_units_sold
  FROM sales_fact
  GROUP BY sale_date, category, customer_tier;

-- Query the final metrics
SELECT * FROM daily_metrics ORDER BY sale_date DESC, total_revenue DESC;


-- ============================================================================
-- Additional Examples
-- ============================================================================

-- Manual refresh
ALTER DYNAMIC TABLE daily_sales_summary REFRESH;

-- Suspend and resume
ALTER DYNAMIC TABLE daily_sales_summary SUSPEND;
ALTER DYNAMIC TABLE daily_sales_summary RESUME;

-- Change warehouse
ALTER DYNAMIC TABLE daily_sales_summary SET WAREHOUSE = BOOTCAMP_WH;


-- ============================================================================
-- Cleanup
-- ============================================================================

-- Suspend Dynamic Tables
ALTER DYNAMIC TABLE daily_sales_summary SUSPEND;
ALTER DYNAMIC TABLE product_sales_1min SUSPEND;
ALTER DYNAMIC TABLE product_sales_1hour SUSPEND;
ALTER DYNAMIC TABLE sales_clean SUSPEND;
ALTER DYNAMIC TABLE sales_enriched SUSPEND;
ALTER DYNAMIC TABLE category_summary SUSPEND;
ALTER DYNAMIC TABLE sales_by_customer_incremental SUSPEND;
ALTER DYNAMIC TABLE customer_rankings_full SUSPEND;
ALTER DYNAMIC TABLE sales_summary_dt SUSPEND;
ALTER DYNAMIC TABLE sales_validated SUSPEND;
ALTER DYNAMIC TABLE sales_fact SUSPEND;
ALTER DYNAMIC TABLE daily_metrics SUSPEND;

-- Drop Dynamic Tables
DROP DYNAMIC TABLE IF EXISTS daily_sales_summary;
DROP DYNAMIC TABLE IF EXISTS product_sales_1min;
DROP DYNAMIC TABLE IF EXISTS product_sales_1hour;
DROP DYNAMIC TABLE IF EXISTS sales_clean;
DROP DYNAMIC TABLE IF EXISTS sales_enriched;
DROP DYNAMIC TABLE IF EXISTS category_summary;
DROP DYNAMIC TABLE IF EXISTS sales_by_customer_incremental;
DROP DYNAMIC TABLE IF EXISTS customer_rankings_full;
DROP DYNAMIC TABLE IF EXISTS sales_summary_dt;
DROP DYNAMIC TABLE IF EXISTS sales_validated;
DROP DYNAMIC TABLE IF EXISTS sales_fact;
DROP DYNAMIC TABLE IF EXISTS daily_metrics;

-- Drop Materialized View
DROP MATERIALIZED VIEW IF EXISTS sales_summary_mv;

-- Drop tables
DROP TABLE IF EXISTS sales_raw;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
