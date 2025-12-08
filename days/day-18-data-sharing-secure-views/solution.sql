/*
Day 18: Data Sharing & Secure Views - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
-- ============================================================================

USE ROLE ACCOUNTADMIN;

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY18_SHARING;
USE SCHEMA DAY18_SHARING;

-- Create sample tables
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20),
  region VARCHAR(50),
  total_orders INT,
  total_revenue DECIMAL(10,2),
  created_date DATE
);

CREATE OR REPLACE TABLE sales (
  sale_id INT,
  customer_id INT,
  product_name VARCHAR(100),
  category VARCHAR(50),
  amount DECIMAL(10,2),
  sale_date DATE,
  region VARCHAR(50),
  partner_id VARCHAR(10)
);

CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name VARCHAR(100),
  category VARCHAR(50),
  price DECIMAL(10,2),
  cost DECIMAL(10,2),
  supplier VARCHAR(100)
);

-- Insert sample data
INSERT INTO customers VALUES
  (1, 'Acme Corp', 'acme@example.com', '555-0101', 'NORTH', 25, 125000.00, '2023-01-15'),
  (2, 'Beta Inc', 'beta@example.com', '555-0102', 'SOUTH', 18, 89000.00, '2023-03-20'),
  (3, 'Gamma LLC', 'gamma@example.com', '555-0103', 'EAST', 32, 156000.00, '2023-02-10'),
  (4, 'Delta Co', 'delta@example.com', '555-0104', 'WEST', 15, 72000.00, '2023-04-05'),
  (5, 'Epsilon Ltd', 'epsilon@example.com', '555-0105', 'NORTH', 28, 142000.00, '2023-01-25');

INSERT INTO sales VALUES
  (101, 1, 'Widget A', 'Electronics', 1500.00, '2024-01-15', 'NORTH', 'P1'),
  (102, 2, 'Widget B', 'Electronics', 2500.00, '2024-01-16', 'SOUTH', 'P2'),
  (103, 3, 'Widget C', 'Home', 1800.00, '2024-01-17', 'EAST', 'P1'),
  (104, 4, 'Widget D', 'Sports', 3200.00, '2024-01-18', 'WEST', 'P3'),
  (105, 5, 'Widget E', 'Electronics', 2100.00, '2024-01-19', 'NORTH', 'P2');

INSERT INTO products VALUES
  (1, 'Widget A', 'Electronics', 1500.00, 800.00, 'Supplier X'),
  (2, 'Widget B', 'Electronics', 2500.00, 1200.00, 'Supplier Y'),
  (3, 'Widget C', 'Home', 1800.00, 900.00, 'Supplier X'),
  (4, 'Widget D', 'Sports', 3200.00, 1600.00, 'Supplier Z'),
  (5, 'Widget E', 'Electronics', 2100.00, 1000.00, 'Supplier Y');


-- ============================================================================
-- Exercise 1: Create Shares
-- ============================================================================

-- Create share for customer analytics
CREATE SHARE customer_analytics_share
  COMMENT = 'Share customer analytics data with partners';

-- Create share for sales data
CREATE SHARE sales_data_share
  COMMENT = 'Share sales data with external analysts';

-- Create share for product catalog
CREATE SHARE product_catalog_share
  COMMENT = 'Share product catalog with distributors';

-- View created shares
SHOW SHARES;

-- Describe a share
DESC SHARE customer_analytics_share;


-- ============================================================================
-- Exercise 2: Create Secure Views
-- ============================================================================

-- Secure view for customer summary (hide sensitive data)
CREATE SECURE VIEW customer_summary AS
SELECT 
  customer_id,
  customer_name,
  CONCAT('***@', SPLIT_PART(email, '@', 2)) as email,  -- Mask email
  CONCAT('***-', RIGHT(phone, 4)) as phone,  -- Mask phone
  region,
  total_orders,
  total_revenue,
  created_date
FROM customers
COMMENT = 'Customer summary with masked PII';

-- Secure view for sales analytics (aggregate data)
CREATE SECURE VIEW sales_analytics AS
SELECT 
  DATE_TRUNC('month', sale_date) as month,
  region,
  category,
  COUNT(*) as sale_count,
  SUM(amount) as total_revenue,
  AVG(amount) as avg_sale_amount,
  MIN(amount) as min_sale,
  MAX(amount) as max_sale
FROM sales
GROUP BY month, region, category
COMMENT = 'Aggregated sales analytics by month, region, and category';

-- Secure view for partner-specific sales
CREATE SECURE VIEW partner_sales AS
SELECT 
  sale_id,
  product_name,
  category,
  amount,
  sale_date,
  region
FROM sales
WHERE partner_id = 'P1'  -- Filter for specific partner
COMMENT = 'Sales data filtered for Partner P1';

-- Secure view for product catalog (hide costs and supplier)
CREATE SECURE VIEW product_catalog AS
SELECT 
  product_id,
  product_name,
  category,
  price
  -- cost and supplier excluded for security
FROM products
COMMENT = 'Public product catalog without cost information';

-- View created secure views
SHOW VIEWS;

-- Test secure views
SELECT * FROM customer_summary LIMIT 5;
SELECT * FROM sales_analytics LIMIT 5;
SELECT * FROM partner_sales LIMIT 5;
SELECT * FROM product_catalog LIMIT 5;


-- ============================================================================
-- Exercise 3: Grant Access to Shares
-- ============================================================================

-- Grant database and schema access to customer_analytics_share
GRANT USAGE ON DATABASE BOOTCAMP_DB TO SHARE customer_analytics_share;
GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY18_SHARING TO SHARE customer_analytics_share;

-- Grant select on secure views to customer_analytics_share
GRANT SELECT ON VIEW customer_summary TO SHARE customer_analytics_share;
GRANT SELECT ON VIEW sales_analytics TO SHARE customer_analytics_share;

-- Grant access to sales_data_share
GRANT USAGE ON DATABASE BOOTCAMP_DB TO SHARE sales_data_share;
GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY18_SHARING TO SHARE sales_data_share;
GRANT SELECT ON VIEW partner_sales TO SHARE sales_data_share;

-- Grant access to product_catalog_share
GRANT USAGE ON DATABASE BOOTCAMP_DB TO SHARE product_catalog_share;
GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY18_SHARING TO SHARE product_catalog_share;
GRANT SELECT ON VIEW product_catalog TO SHARE product_catalog_share;

-- View grants to shares
SHOW GRANTS TO SHARE customer_analytics_share;
SHOW GRANTS TO SHARE sales_data_share;
SHOW GRANTS TO SHARE product_catalog_share;


-- ============================================================================
-- Exercise 4: Add Consumer Accounts
-- ============================================================================

-- Add consumer accounts to shares
-- Note: Replace with actual account identifiers in production
-- ALTER SHARE customer_analytics_share ADD ACCOUNTS = xy12345;
-- ALTER SHARE sales_data_share ADD ACCOUNTS = ab67890;
-- ALTER SHARE product_catalog_share ADD ACCOUNTS = cd11111;

-- View share details with consumers
DESC SHARE customer_analytics_share;
DESC SHARE sales_data_share;
DESC SHARE product_catalog_share;

-- Modify share comment
ALTER SHARE customer_analytics_share SET COMMENT = 'Updated: Customer analytics for Q1 2024 - includes summary and sales analytics';


-- ============================================================================
-- Exercise 5: Create Reader Account (Optional)
-- ============================================================================

-- Create a reader account
-- Note: Reader accounts are for external users without Snowflake
-- CREATE MANAGED ACCOUNT partner_reader
--   ADMIN_NAME = 'partner_admin'
--   ADMIN_PASSWORD = 'SecurePass123!'
--   TYPE = READER
--   COMMENT = 'Reader account for Partner ABC';

-- Add reader account to share
-- ALTER SHARE customer_analytics_share ADD ACCOUNTS = partner_reader;

-- View managed accounts
-- SHOW MANAGED ACCOUNTS;


-- ============================================================================
-- Exercise 6: Monitor Share Usage
-- ============================================================================

-- View all shares
SHOW SHARES;

-- Check data transfer history
SELECT 
  share_name,
  target_account_name,
  bytes_transferred / 1024 / 1024 as mb_transferred,
  transfer_date,
  transfer_type
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
  AND share_name IS NOT NULL
ORDER BY bytes_transferred DESC;

-- View grants to shares
SELECT 
  share_name,
  granted_on,
  name as object_name,
  privilege,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES
WHERE deleted_on IS NULL
ORDER BY share_name, granted_on, name;

-- Create comprehensive monitoring view
CREATE OR REPLACE VIEW share_monitoring AS
SELECT 
  s.name as share_name,
  s.kind,
  s.owner,
  s.comment,
  s.created_on,
  COUNT(DISTINCT g.name) as shared_objects,
  LISTAGG(DISTINCT g.granted_on, ', ') as object_types
FROM SNOWFLAKE.ACCOUNT_USAGE.SHARES s
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES g 
  ON s.name = g.share_name AND g.deleted_on IS NULL
WHERE s.deleted_on IS NULL
GROUP BY s.name, s.kind, s.owner, s.comment, s.created_on;

-- Query monitoring view
SELECT * FROM share_monitoring;

-- Detailed share audit
SELECT 
  share_name,
  granted_on as object_type,
  name as object_name,
  privilege,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES
WHERE deleted_on IS NULL
  AND share_name IN ('CUSTOMER_ANALYTICS_SHARE', 'SALES_DATA_SHARE', 'PRODUCT_CATALOG_SHARE')
ORDER BY share_name, granted_on, name;


-- ============================================================================
-- Exercise 7: Advanced Secure View Patterns
-- ============================================================================

-- Secure view with row-level filtering
CREATE SECURE VIEW regional_sales AS
SELECT 
  sale_id,
  customer_id,
  product_name,
  category,
  amount,
  sale_date,
  region
FROM sales
WHERE region IN ('NORTH', 'SOUTH')  -- Only specific regions
  AND sale_date >= DATEADD(month, -6, CURRENT_DATE())  -- Last 6 months
COMMENT = 'Sales data filtered by region and date';

-- Secure view with aggregation and masking
CREATE SECURE VIEW customer_metrics AS
SELECT 
  customer_id,
  customer_name,
  region,
  total_orders,
  ROUND(total_revenue, -2) as total_revenue_rounded,  -- Round to nearest 100
  CASE 
    WHEN total_revenue > 100000 THEN 'High Value'
    WHEN total_revenue > 50000 THEN 'Medium Value'
    ELSE 'Standard'
  END as customer_tier,
  CASE 
    WHEN total_orders > 25 THEN 'Frequent'
    WHEN total_orders > 15 THEN 'Regular'
    ELSE 'Occasional'
  END as order_frequency
FROM customers
COMMENT = 'Customer metrics with tiered classification';

-- Secure view with joins
CREATE SECURE VIEW sales_with_products AS
SELECT 
  s.sale_id,
  s.sale_date,
  s.region,
  s.category,
  p.product_name,
  p.price as list_price,
  s.amount as sale_amount,
  ROUND((s.amount / p.price) * 100, 2) as discount_percent
FROM sales s
JOIN products p ON s.product_name = p.product_name
WHERE s.sale_date >= DATEADD(year, -1, CURRENT_DATE())
COMMENT = 'Sales with product details and discount calculation';

-- Secure view with time-based filtering
CREATE SECURE VIEW recent_high_value_sales AS
SELECT 
  sale_id,
  product_name,
  category,
  amount,
  sale_date,
  region,
  DATEDIFF(day, sale_date, CURRENT_DATE()) as days_ago
FROM sales
WHERE amount > 2000
  AND sale_date >= DATEADD(month, -3, CURRENT_DATE())
ORDER BY sale_date DESC
COMMENT = 'High-value sales from last 3 months';

-- Test secure views
SELECT * FROM regional_sales LIMIT 5;
SELECT * FROM customer_metrics ORDER BY total_revenue_rounded DESC LIMIT 5;
SELECT * FROM sales_with_products LIMIT 5;
SELECT * FROM recent_high_value_sales LIMIT 5;


-- ============================================================================
-- Bonus: Best Practices Summary
-- ============================================================================

-- Create comprehensive share documentation view
CREATE OR REPLACE VIEW share_documentation AS
SELECT 
  'customer_analytics_share' as share_name,
  'Customer analytics and metrics' as description,
  'customer_summary, sales_analytics' as included_views,
  'Partners and analysts' as intended_audience,
  'PII masked, aggregated data' as security_measures
UNION ALL
SELECT 
  'sales_data_share',
  'Partner-specific sales data',
  'partner_sales',
  'Partner P1',
  'Filtered by partner_id'
UNION ALL
SELECT 
  'product_catalog_share',
  'Public product catalog',
  'product_catalog',
  'Distributors and resellers',
  'Cost and supplier information excluded';

SELECT * FROM share_documentation;

-- Best practices checklist
SELECT 
  'Data Sharing Best Practices' as category,
  'Always use secure views' as practice,
  'Protects query logic and sensitive data' as benefit
UNION ALL
SELECT 'Data Sharing', 'Mask PII in shared views', 'Compliance with privacy regulations'
UNION ALL
SELECT 'Data Sharing', 'Filter data appropriately', 'Share only necessary data'
UNION ALL
SELECT 'Data Sharing', 'Document shares clearly', 'Clear understanding for consumers'
UNION ALL
SELECT 'Data Sharing', 'Monitor share usage', 'Track access and data transfer'
UNION ALL
SELECT 'Data Sharing', 'Regular access reviews', 'Ensure appropriate access'
UNION ALL
SELECT 'Data Sharing', 'Use aggregated data when possible', 'Reduce sensitivity'
UNION ALL
SELECT 'Data Sharing', 'Test shares before distribution', 'Verify data and access';


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Remove consumer accounts from shares
-- ALTER SHARE customer_analytics_share REMOVE ACCOUNTS = xy12345;
-- ALTER SHARE sales_data_share REMOVE ACCOUNTS = ab67890;
-- ALTER SHARE product_catalog_share REMOVE ACCOUNTS = cd11111;

-- Drop reader account
-- DROP MANAGED ACCOUNT IF EXISTS partner_reader;

-- Drop shares
-- DROP SHARE IF EXISTS customer_analytics_share;
-- DROP SHARE IF EXISTS sales_data_share;
-- DROP SHARE IF EXISTS product_catalog_share;

-- Drop secure views
-- DROP VIEW IF EXISTS customer_summary;
-- DROP VIEW IF EXISTS sales_analytics;
-- DROP VIEW IF EXISTS partner_sales;
-- DROP VIEW IF EXISTS product_catalog;
-- DROP VIEW IF EXISTS regional_sales;
-- DROP VIEW IF EXISTS customer_metrics;
-- DROP VIEW IF EXISTS sales_with_products;
-- DROP VIEW IF EXISTS recent_high_value_sales;
-- DROP VIEW IF EXISTS share_monitoring;
-- DROP VIEW IF EXISTS share_documentation;

-- Drop tables
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS products;
