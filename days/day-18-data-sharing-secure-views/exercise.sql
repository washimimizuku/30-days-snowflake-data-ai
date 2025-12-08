/*
Day 18: Data Sharing & Secure Views - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY18_SHARING;
USE SCHEMA DAY18_SHARING;

-- Create sample tables for sharing
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
-- Exercise 1: Create Shares (10 min)
-- ============================================================================

-- TODO: Create a share for customer analytics
-- CREATE SHARE customer_analytics_share
--   COMMENT = 'Share customer analytics data with partners';

-- TODO: Create a share for sales data
-- CREATE SHARE sales_data_share
--   COMMENT = 'Share sales data with external analysts';

-- TODO: Create a share for product catalog
-- CREATE SHARE product_catalog_share
--   COMMENT = 'Share product catalog with distributors';

-- TODO: View created shares
-- SHOW SHARES;

-- TODO: Describe a share
-- DESC SHARE customer_analytics_share;


-- ============================================================================
-- Exercise 2: Create Secure Views (10 min)
-- ============================================================================

-- TODO: Create secure view for customer summary (hide sensitive data)
-- CREATE SECURE VIEW customer_summary AS
-- SELECT 
--   customer_id,
--   customer_name,
--   CONCAT('***@', SPLIT_PART(email, '@', 2)) as email,  -- Mask email
--   region,
--   total_orders,
--   total_revenue
-- FROM customers;

-- TODO: Create secure view for sales analytics (aggregate data)
-- CREATE SECURE VIEW sales_analytics AS
-- SELECT 
--   DATE_TRUNC('month', sale_date) as month,
--   region,
--   category,
--   COUNT(*) as sale_count,
--   SUM(amount) as total_revenue,
--   AVG(amount) as avg_sale_amount
-- FROM sales
-- GROUP BY month, region, category;

-- TODO: Create secure view for partner-specific sales
-- CREATE SECURE VIEW partner_sales AS
-- SELECT 
--   sale_id,
--   product_name,
--   category,
--   amount,
--   sale_date,
--   region
-- FROM sales
-- WHERE partner_id = 'P1';  -- Filter for specific partner

-- TODO: Create secure view for product catalog (hide costs)
-- CREATE SECURE VIEW product_catalog AS
-- SELECT 
--   product_id,
--   product_name,
--   category,
--   price
--   -- cost and supplier excluded
-- FROM products;

-- TODO: View created secure views
-- SHOW VIEWS;


-- ============================================================================
-- Exercise 3: Grant Access to Shares (10 min)
-- ============================================================================

-- TODO: Grant database and schema access to customer_analytics_share
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO SHARE customer_analytics_share;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY18_SHARING TO SHARE customer_analytics_share;

-- TODO: Grant select on secure views to customer_analytics_share
-- GRANT SELECT ON VIEW customer_summary TO SHARE customer_analytics_share;
-- GRANT SELECT ON VIEW sales_analytics TO SHARE customer_analytics_share;

-- TODO: Grant access to sales_data_share
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO SHARE sales_data_share;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY18_SHARING TO SHARE sales_data_share;
-- GRANT SELECT ON VIEW partner_sales TO SHARE sales_data_share;

-- TODO: Grant access to product_catalog_share
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO SHARE product_catalog_share;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY18_SHARING TO SHARE product_catalog_share;
-- GRANT SELECT ON VIEW product_catalog TO SHARE product_catalog_share;

-- TODO: View grants to shares
-- SHOW GRANTS TO SHARE customer_analytics_share;
-- SHOW GRANTS TO SHARE sales_data_share;
-- SHOW GRANTS TO SHARE product_catalog_share;


-- ============================================================================
-- Exercise 4: Add Consumer Accounts (5 min)
-- ============================================================================

-- TODO: Add consumer accounts to shares
-- Note: Replace with actual account identifiers
-- ALTER SHARE customer_analytics_share ADD ACCOUNTS = xy12345;
-- ALTER SHARE sales_data_share ADD ACCOUNTS = ab67890;
-- ALTER SHARE product_catalog_share ADD ACCOUNTS = cd11111;

-- TODO: View share details with consumers
-- DESC SHARE customer_analytics_share;

-- TODO: Modify share comment
-- ALTER SHARE customer_analytics_share SET COMMENT = 'Updated: Customer analytics for Q1 2024';


-- ============================================================================
-- Exercise 5: Create Reader Account (Optional - 5 min)
-- ============================================================================

-- TODO: Create a reader account
-- Note: Reader accounts are for external users without Snowflake
-- CREATE MANAGED ACCOUNT partner_reader
--   ADMIN_NAME = 'partner_admin'
--   ADMIN_PASSWORD = 'SecurePass123!'
--   TYPE = READER
--   COMMENT = 'Reader account for Partner ABC';

-- TODO: Add reader account to share
-- ALTER SHARE customer_analytics_share ADD ACCOUNTS = partner_reader;

-- TODO: View managed accounts
-- SHOW MANAGED ACCOUNTS;


-- ============================================================================
-- Exercise 6: Monitor Share Usage (5 min)
-- ============================================================================

-- TODO: View all shares
-- SHOW SHARES;

-- TODO: Check data transfer history
-- SELECT 
--   share_name,
--   target_account_name,
--   bytes_transferred / 1024 / 1024 as mb_transferred,
--   transfer_date
-- FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY
-- WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
--   AND share_name IS NOT NULL
-- ORDER BY bytes_transferred DESC;

-- TODO: View grants to shares
-- SELECT 
--   share_name,
--   granted_on,
--   name as object_name,
--   privilege,
--   granted_by
-- FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES
-- WHERE deleted_on IS NULL
-- ORDER BY share_name, granted_on;

-- TODO: Create monitoring view
-- CREATE OR REPLACE VIEW share_monitoring AS
-- SELECT 
--   s.name as share_name,
--   s.kind,
--   s.owner,
--   s.comment,
--   s.created_on,
--   COUNT(DISTINCT g.name) as shared_objects
-- FROM SNOWFLAKE.ACCOUNT_USAGE.SHARES s
-- LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES g 
--   ON s.name = g.share_name AND g.deleted_on IS NULL
-- WHERE s.deleted_on IS NULL
-- GROUP BY s.name, s.kind, s.owner, s.comment, s.created_on;

-- TODO: Query monitoring view
-- SELECT * FROM share_monitoring;


-- ============================================================================
-- Exercise 7: Advanced Secure View Patterns (5 min)
-- ============================================================================

-- TODO: Create secure view with row-level filtering
-- CREATE SECURE VIEW regional_sales AS
-- SELECT 
--   sale_id,
--   customer_id,
--   product_name,
--   amount,
--   sale_date
-- FROM sales
-- WHERE region IN ('NORTH', 'SOUTH')  -- Only specific regions
--   AND sale_date >= DATEADD(month, -6, CURRENT_DATE());  -- Last 6 months

-- TODO: Create secure view with aggregation and masking
-- CREATE SECURE VIEW customer_metrics AS
-- SELECT 
--   customer_id,
--   customer_name,
--   region,
--   total_orders,
--   ROUND(total_revenue, -2) as total_revenue_rounded,  -- Round to nearest 100
--   CASE 
--     WHEN total_revenue > 100000 THEN 'High Value'
--     WHEN total_revenue > 50000 THEN 'Medium Value'
--     ELSE 'Standard'
--   END as customer_tier
-- FROM customers;

-- TODO: Create secure view with joins
-- CREATE SECURE VIEW sales_with_products AS
-- SELECT 
--   s.sale_id,
--   s.sale_date,
--   s.region,
--   p.product_name,
--   p.category,
--   s.amount
-- FROM sales s
-- JOIN products p ON s.product_name = p.product_name
-- WHERE s.sale_date >= DATEADD(year, -1, CURRENT_DATE());

-- TODO: Test secure views
-- SELECT * FROM regional_sales LIMIT 5;
-- SELECT * FROM customer_metrics LIMIT 5;
-- SELECT * FROM sales_with_products LIMIT 5;


-- ============================================================================
-- Bonus: Simulate Consumer Access (Optional)
-- ============================================================================

-- TODO: As a consumer, you would create a database from the share
-- Note: This requires actual share from another account
-- CREATE DATABASE shared_customer_data
--   FROM SHARE provider_account.customer_analytics_share;

-- TODO: Query shared data
-- USE DATABASE shared_customer_data;
-- SELECT * FROM DAY18_SHARING.customer_summary LIMIT 10;

-- TODO: Drop shared database
-- DROP DATABASE shared_customer_data;


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
-- DROP VIEW IF EXISTS share_monitoring;

-- Drop tables
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS products;
