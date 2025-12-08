/*
Day 17: Row Access Policies - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY17_ROW_ACCESS;
USE SCHEMA DAY17_ROW_ACCESS;

-- Create sample tables
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  region VARCHAR(50),
  account_manager VARCHAR(50)
);

CREATE OR REPLACE TABLE sales (
  sale_id INT,
  customer_id INT,
  product_name VARCHAR(100),
  amount DECIMAL(10,2),
  sale_date DATE,
  region VARCHAR(50),
  sales_rep VARCHAR(50)
);

CREATE OR REPLACE TABLE employees (
  employee_id INT,
  name VARCHAR(100),
  department VARCHAR(50),
  manager_id INT,
  salary NUMBER(10,2),
  region VARCHAR(50)
);

-- Insert sample data
INSERT INTO customers VALUES
  (1, 'Acme Corp', 'acme@example.com', 'NORTH', 'alice'),
  (2, 'Beta Inc', 'beta@example.com', 'SOUTH', 'bob'),
  (3, 'Gamma LLC', 'gamma@example.com', 'EAST', 'alice'),
  (4, 'Delta Co', 'delta@example.com', 'WEST', 'carol'),
  (5, 'Epsilon Ltd', 'epsilon@example.com', 'NORTH', 'bob');

INSERT INTO sales VALUES
  (101, 1, 'Widget A', 1500.00, '2024-01-15', 'NORTH', 'alice'),
  (102, 2, 'Widget B', 2500.00, '2024-01-16', 'SOUTH', 'bob'),
  (103, 3, 'Widget C', 1800.00, '2024-01-17', 'EAST', 'alice'),
  (104, 4, 'Widget D', 3200.00, '2024-01-18', 'WEST', 'carol'),
  (105, 5, 'Widget E', 2100.00, '2024-01-19', 'NORTH', 'bob');

INSERT INTO employees VALUES
  (1, 'Alice Johnson', 'SALES', NULL, 75000, 'NORTH'),
  (2, 'Bob Smith', 'SALES', 1, 65000, 'SOUTH'),
  (3, 'Carol Davis', 'SALES', 1, 68000, 'WEST'),
  (4, 'David Wilson', 'ENGINEERING', NULL, 95000, 'NORTH'),
  (5, 'Eve Martinez', 'ENGINEERING', 4, 85000, 'EAST');

-- Create roles for testing
CREATE ROLE IF NOT EXISTS global_admin;
CREATE ROLE IF NOT EXISTS north_sales;
CREATE ROLE IF NOT EXISTS south_sales;
CREATE ROLE IF NOT EXISTS east_sales;
CREATE ROLE IF NOT EXISTS west_sales;
CREATE ROLE IF NOT EXISTS sales_manager;
CREATE ROLE IF NOT EXISTS engineer_role;

-- Grant access
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE global_admin;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE north_sales;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE south_sales;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE east_sales;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE west_sales;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE sales_manager;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE engineer_role;

GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE global_admin;
GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE north_sales;
GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE south_sales;
GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE east_sales;
GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE west_sales;
GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE sales_manager;
GRANT USAGE ON SCHEMA DAY17_ROW_ACCESS TO ROLE engineer_role;

GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE global_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE north_sales;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE south_sales;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE east_sales;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE west_sales;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE sales_manager;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY17_ROW_ACCESS TO ROLE engineer_role;


-- ============================================================================
-- Exercise 1: Create Basic Row Access Policies (10 min)
-- ============================================================================

-- TODO: Create regional access policy
-- CREATE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN TRUE
--     WHEN CURRENT_ROLE() = 'NORTH_SALES' AND region = 'NORTH' THEN TRUE
--     WHEN CURRENT_ROLE() = 'SOUTH_SALES' AND region = 'SOUTH' THEN TRUE
--     WHEN CURRENT_ROLE() = 'EAST_SALES' AND region = 'EAST' THEN TRUE
--     WHEN CURRENT_ROLE() = 'WEST_SALES' AND region = 'WEST' THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: Create department access policy
-- CREATE ROW ACCESS POLICY department_access AS (dept STRING) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
--     WHEN CURRENT_ROLE() = 'SALES_MANAGER' AND dept = 'SALES' THEN TRUE
--     WHEN CURRENT_ROLE() = 'ENGINEER_ROLE' AND dept = 'ENGINEERING' THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: Create user-based access policy
-- CREATE ROW ACCESS POLICY user_access AS (owner STRING) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN TRUE
--     WHEN owner = CURRENT_USER() THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: View created policies
-- SHOW ROW ACCESS POLICIES;


-- ============================================================================
-- Exercise 2: Apply Policies to Tables (5 min)
-- ============================================================================

-- TODO: Apply regional access to customers table
-- ALTER TABLE customers ADD ROW ACCESS POLICY regional_access ON (region);

-- TODO: Apply regional access to sales table
-- ALTER TABLE sales ADD ROW ACCESS POLICY regional_access ON (region);

-- TODO: Apply department access to employees table
-- ALTER TABLE employees ADD ROW ACCESS POLICY department_access ON (department);

-- TODO: View policy references
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
--   POLICY_NAME => 'REGIONAL_ACCESS'
-- ));


-- ============================================================================
-- Exercise 3: Test Role-Based Row Filtering (10 min)
-- ============================================================================

-- TODO: Test as GLOBAL_ADMIN (should see all rows)
-- USE ROLE global_admin;
-- SELECT 'GLOBAL_ADMIN View' as test;
-- SELECT COUNT(*) as total_customers FROM customers;
-- SELECT COUNT(*) as total_sales FROM sales;
-- SELECT COUNT(*) as total_employees FROM employees;

-- TODO: Test as NORTH_SALES (should see only NORTH region)
-- USE ROLE north_sales;
-- SELECT 'NORTH_SALES View' as test;
-- SELECT * FROM customers;
-- SELECT * FROM sales;

-- TODO: Test as SOUTH_SALES (should see only SOUTH region)
-- USE ROLE south_sales;
-- SELECT 'SOUTH_SALES View' as test;
-- SELECT * FROM customers;
-- SELECT * FROM sales;

-- TODO: Test as SALES_MANAGER (should see all sales data)
-- USE ROLE sales_manager;
-- SELECT 'SALES_MANAGER View' as test;
-- SELECT * FROM customers;
-- SELECT * FROM employees WHERE department = 'SALES';

-- TODO: Test as ENGINEER_ROLE (should see only engineering employees)
-- USE ROLE engineer_role;
-- SELECT 'ENGINEER_ROLE View' as test;
-- SELECT * FROM employees;


-- ============================================================================
-- Exercise 4: Mapping Table Access (10 min)
-- ============================================================================

-- TODO: Create user-region mapping table
-- USE ROLE ACCOUNTADMIN;
-- CREATE TABLE user_region_mapping (
--   username STRING,
--   region STRING
-- );

-- TODO: Insert mappings
-- INSERT INTO user_region_mapping VALUES
--   ('alice', 'NORTH'),
--   ('alice', 'EAST'),
--   ('bob', 'SOUTH'),
--   ('bob', 'NORTH'),
--   ('carol', 'WEST');

-- TODO: Create policy using mapping table
-- CREATE ROW ACCESS POLICY mapped_regional_access AS (region STRING) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
--     WHEN region IN (
--       SELECT region FROM user_region_mapping WHERE username = CURRENT_USER()
--     ) THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: Replace policy on sales table
-- ALTER TABLE sales DROP ROW ACCESS POLICY;
-- ALTER TABLE sales ADD ROW ACCESS POLICY mapped_regional_access ON (region);

-- TODO: Test with different users
-- (Would need actual users to test properly)


-- ============================================================================
-- Exercise 5: Multi-Column Policies (5 min)
-- ============================================================================

-- TODO: Create multi-column access policy
-- CREATE ROW ACCESS POLICY multi_column_access AS (
--   region STRING,
--   dept STRING
-- ) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
--     WHEN CURRENT_ROLE() = 'NORTH_SALES' 
--       AND region = 'NORTH' 
--       AND dept = 'SALES' THEN TRUE
--     WHEN CURRENT_ROLE() = 'SOUTH_SALES' 
--       AND region = 'SOUTH' 
--       AND dept = 'SALES' THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: Apply multi-column policy
-- ALTER TABLE employees DROP ROW ACCESS POLICY;
-- ALTER TABLE employees ADD ROW ACCESS POLICY multi_column_access ON (region, department);

-- TODO: Test multi-column filtering
-- USE ROLE north_sales;
-- SELECT * FROM employees;


-- ============================================================================
-- Exercise 6: Combine with Masking Policies (5 min)
-- ============================================================================

-- TODO: Create masking policy for salary
-- USE ROLE ACCOUNTADMIN;
-- CREATE MASKING POLICY salary_mask AS (val NUMBER) RETURNS NUMBER ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN val
--     ELSE NULL
--   END;

-- TODO: Apply masking policy to salary column
-- ALTER TABLE employees MODIFY COLUMN salary SET MASKING POLICY salary_mask;

-- TODO: Test combined policies
-- USE ROLE north_sales;
-- SELECT * FROM employees;
-- -- Should see only NORTH SALES employees with salary masked

-- USE ROLE sales_manager;
-- SELECT * FROM employees WHERE department = 'SALES';
-- -- Should see all SALES employees with salary visible


-- ============================================================================
-- Exercise 7: Audit and Monitor (5 min)
-- ============================================================================

-- TODO: View all row access policies
-- USE ROLE ACCOUNTADMIN;
-- SHOW ROW ACCESS POLICIES;

-- TODO: View policy references for all tables
-- SELECT 
--   policy_name,
--   ref_entity_name as table_name,
--   ref_column_names,
--   policy_status
-- FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
--   REF_ENTITY_DOMAIN => 'TABLE'
-- ))
-- WHERE ref_entity_name IN ('CUSTOMERS', 'SALES', 'EMPLOYEES')
-- ORDER BY ref_entity_name;

-- TODO: Create audit view
-- CREATE OR REPLACE VIEW row_access_audit AS
-- SELECT 
--   p.policy_name,
--   p.policy_owner,
--   p.created as policy_created,
--   p.last_altered as policy_modified,
--   r.ref_entity_name as table_name,
--   r.ref_column_names as columns
-- FROM SNOWFLAKE.ACCOUNT_USAGE.ROW_ACCESS_POLICIES p
-- LEFT JOIN TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
--   REF_ENTITY_DOMAIN => 'TABLE'
-- )) r ON p.policy_name = r.policy_name
-- WHERE p.deleted IS NULL
-- ORDER BY p.policy_name;

-- TODO: Query audit view
-- SELECT * FROM row_access_audit;

-- TODO: Check query history with row filtering
-- SELECT 
--   query_id,
--   user_name,
--   role_name,
--   LEFT(query_text, 100) as query_preview,
--   rows_produced,
--   execution_time
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE query_text ILIKE '%customers%'
--   AND start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ORDER BY start_time DESC
-- LIMIT 10;


-- ============================================================================
-- Bonus: Advanced Patterns (Optional)
-- ============================================================================

-- TODO: Create time-based access policy
-- CREATE ROW ACCESS POLICY time_based_access AS (
--   sale_date DATE
-- ) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
--     WHEN CURRENT_ROLE() = 'SALES_MANAGER' 
--       AND sale_date >= DATEADD(day, -90, CURRENT_DATE()) THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: Create hierarchical access policy
-- CREATE ROW ACCESS POLICY manager_hierarchy AS (
--   manager_id INT
-- ) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
--     WHEN manager_id IN (
--       SELECT employee_id FROM employees WHERE name = CURRENT_USER()
--     ) THEN TRUE
--     ELSE FALSE
--   END;

-- TODO: Create tenant isolation policy (for SaaS)
-- CREATE ROW ACCESS POLICY tenant_isolation AS (
--   tenant_id STRING
-- ) RETURNS BOOLEAN ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('PLATFORM_ADMIN') THEN TRUE
--     WHEN tenant_id = CURRENT_SESSION_PARAMETER('TENANT_ID') THEN TRUE
--     ELSE FALSE
--   END;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Remove policies from tables
-- USE ROLE ACCOUNTADMIN;
-- ALTER TABLE customers DROP ROW ACCESS POLICY;
-- ALTER TABLE sales DROP ROW ACCESS POLICY;
-- ALTER TABLE employees DROP ROW ACCESS POLICY;
-- ALTER TABLE employees MODIFY COLUMN salary UNSET MASKING POLICY;

-- Drop row access policies
-- DROP ROW ACCESS POLICY IF EXISTS regional_access;
-- DROP ROW ACCESS POLICY IF EXISTS department_access;
-- DROP ROW ACCESS POLICY IF EXISTS user_access;
-- DROP ROW ACCESS POLICY IF EXISTS mapped_regional_access;
-- DROP ROW ACCESS POLICY IF EXISTS multi_column_access;
-- DROP ROW ACCESS POLICY IF EXISTS time_based_access;
-- DROP ROW ACCESS POLICY IF EXISTS manager_hierarchy;
-- DROP ROW ACCESS POLICY IF EXISTS tenant_isolation;

-- Drop masking policy
-- DROP MASKING POLICY IF EXISTS salary_mask;

-- Drop tables
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS employees;
-- DROP TABLE IF EXISTS user_region_mapping;

-- Drop views
-- DROP VIEW IF EXISTS row_access_audit;

-- Drop roles
-- DROP ROLE IF EXISTS global_admin;
-- DROP ROLE IF EXISTS north_sales;
-- DROP ROLE IF EXISTS south_sales;
-- DROP ROLE IF EXISTS east_sales;
-- DROP ROLE IF EXISTS west_sales;
-- DROP ROLE IF EXISTS sales_manager;
-- DROP ROLE IF EXISTS engineer_role;
