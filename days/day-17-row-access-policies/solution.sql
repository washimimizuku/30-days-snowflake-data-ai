/*
Day 17: Row Access Policies - Solution
Complete working solution for all exercises
*/

-- ============================================================================
-- Setup
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

-- Create roles
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
-- Exercise 1: Create Basic Row Access Policies
-- ============================================================================

-- Regional access policy
CREATE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN TRUE
    WHEN CURRENT_ROLE() = 'NORTH_SALES' AND region = 'NORTH' THEN TRUE
    WHEN CURRENT_ROLE() = 'SOUTH_SALES' AND region = 'SOUTH' THEN TRUE
    WHEN CURRENT_ROLE() = 'EAST_SALES' AND region = 'EAST' THEN TRUE
    WHEN CURRENT_ROLE() = 'WEST_SALES' AND region = 'WEST' THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Filters rows by region based on user role';

-- Department access policy
CREATE ROW ACCESS POLICY department_access AS (dept STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_MANAGER' AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'ENGINEER_ROLE' AND dept = 'ENGINEERING' THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Filters rows by department based on user role';

-- User-based access policy
CREATE ROW ACCESS POLICY user_access AS (owner STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN TRUE
    WHEN owner = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Users see only their own records';

-- View created policies
SHOW ROW ACCESS POLICIES;


-- ============================================================================
-- Exercise 2: Apply Policies to Tables
-- ============================================================================

-- Apply regional access to customers table
ALTER TABLE customers ADD ROW ACCESS POLICY regional_access ON (region);

-- Apply regional access to sales table
ALTER TABLE sales ADD ROW ACCESS POLICY regional_access ON (region);

-- Apply department access to employees table
ALTER TABLE employees ADD ROW ACCESS POLICY department_access ON (department);

-- View policy references
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'REGIONAL_ACCESS'
));

SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'DEPARTMENT_ACCESS'
));


-- ============================================================================
-- Exercise 3: Test Role-Based Row Filtering
-- ============================================================================

-- Test as GLOBAL_ADMIN (should see all rows)
USE ROLE global_admin;
SELECT 'GLOBAL_ADMIN View' as test;
SELECT COUNT(*) as total_customers FROM customers;  -- Should see 5
SELECT COUNT(*) as total_sales FROM sales;  -- Should see 5
SELECT COUNT(*) as total_employees FROM employees;  -- Should see 5

SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM sales ORDER BY sale_id;
SELECT * FROM employees ORDER BY employee_id;

-- Test as NORTH_SALES (should see only NORTH region)
USE ROLE north_sales;
SELECT 'NORTH_SALES View' as test;
SELECT COUNT(*) as north_customers FROM customers;  -- Should see 2
SELECT COUNT(*) as north_sales FROM sales;  -- Should see 2

SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM sales ORDER BY sale_id;

-- Test as SOUTH_SALES (should see only SOUTH region)
USE ROLE south_sales;
SELECT 'SOUTH_SALES View' as test;
SELECT COUNT(*) as south_customers FROM customers;  -- Should see 1
SELECT COUNT(*) as south_sales FROM sales;  -- Should see 1

SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM sales ORDER BY sale_id;

-- Test as EAST_SALES (should see only EAST region)
USE ROLE east_sales;
SELECT 'EAST_SALES View' as test;
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM sales ORDER BY sale_id;

-- Test as SALES_MANAGER (should see all sales data)
USE ROLE sales_manager;
SELECT 'SALES_MANAGER View' as test;
SELECT COUNT(*) as all_customers FROM customers;  -- Should see 5
SELECT COUNT(*) as all_sales FROM sales;  -- Should see 5
SELECT COUNT(*) as sales_employees FROM employees;  -- Should see 3

SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM employees WHERE department = 'SALES' ORDER BY employee_id;

-- Test as ENGINEER_ROLE (should see only engineering employees)
USE ROLE engineer_role;
SELECT 'ENGINEER_ROLE View' as test;
SELECT COUNT(*) as eng_employees FROM employees;  -- Should see 2

SELECT * FROM employees ORDER BY employee_id;


-- ============================================================================
-- Exercise 4: Mapping Table Access
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create user-region mapping table
CREATE TABLE user_region_mapping (
  username STRING,
  region STRING
);

-- Insert mappings (users can access multiple regions)
INSERT INTO user_region_mapping VALUES
  ('alice', 'NORTH'),
  ('alice', 'EAST'),
  ('bob', 'SOUTH'),
  ('bob', 'NORTH'),
  ('carol', 'WEST');

-- Grant access to mapping table
GRANT SELECT ON TABLE user_region_mapping TO ROLE north_sales;
GRANT SELECT ON TABLE user_region_mapping TO ROLE south_sales;
GRANT SELECT ON TABLE user_region_mapping TO ROLE east_sales;
GRANT SELECT ON TABLE user_region_mapping TO ROLE west_sales;

-- Create policy using mapping table
CREATE ROW ACCESS POLICY mapped_regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN TRUE
    WHEN region IN (
      SELECT region FROM user_region_mapping WHERE username = CURRENT_USER()
    ) THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Uses mapping table for flexible regional access';

-- Replace policy on sales table
ALTER TABLE sales DROP ROW ACCESS POLICY;
ALTER TABLE sales ADD ROW ACCESS POLICY mapped_regional_access ON (region);

-- Test: Users would see regions based on mapping table
USE ROLE global_admin;
SELECT 'Testing mapped access' as test;
SELECT * FROM sales ORDER BY sale_id;


-- ============================================================================
-- Exercise 5: Multi-Column Policies
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create multi-column access policy
CREATE ROW ACCESS POLICY multi_column_access AS (
  region STRING,
  dept STRING
) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_MANAGER' AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'NORTH_SALES' 
      AND region = 'NORTH' 
      AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'SOUTH_SALES' 
      AND region = 'SOUTH' 
      AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'EAST_SALES' 
      AND region = 'EAST' 
      AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'WEST_SALES' 
      AND region = 'WEST' 
      AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'ENGINEER_ROLE' AND dept = 'ENGINEERING' THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Filters by both region and department';

-- Apply multi-column policy
ALTER TABLE employees DROP ROW ACCESS POLICY;
ALTER TABLE employees ADD ROW ACCESS POLICY multi_column_access ON (region, department);

-- Test multi-column filtering
USE ROLE north_sales;
SELECT 'NORTH_SALES with multi-column policy' as test;
SELECT * FROM employees ORDER BY employee_id;  -- Should see only NORTH SALES

USE ROLE engineer_role;
SELECT 'ENGINEER_ROLE with multi-column policy' as test;
SELECT * FROM employees ORDER BY employee_id;  -- Should see all ENGINEERING

USE ROLE global_admin;
SELECT 'GLOBAL_ADMIN with multi-column policy' as test;
SELECT * FROM employees ORDER BY employee_id;  -- Should see all


-- ============================================================================
-- Exercise 6: Combine with Masking Policies
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create masking policy for salary
CREATE MASKING POLICY salary_mask AS (val NUMBER) RETURNS NUMBER ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN', 'SALES_MANAGER') THEN val
    ELSE NULL
  END
  COMMENT = 'Masks salary for unauthorized roles';

-- Apply masking policy to salary column
ALTER TABLE employees MODIFY COLUMN salary SET MASKING POLICY salary_mask;

-- Test combined policies
USE ROLE north_sales;
SELECT 'NORTH_SALES with row access + masking' as test;
SELECT * FROM employees ORDER BY employee_id;
-- Should see only NORTH SALES employees with salary masked (NULL)

USE ROLE sales_manager;
SELECT 'SALES_MANAGER with row access + masking' as test;
SELECT * FROM employees WHERE department = 'SALES' ORDER BY employee_id;
-- Should see all SALES employees with salary visible

USE ROLE engineer_role;
SELECT 'ENGINEER_ROLE with row access + masking' as test;
SELECT * FROM employees ORDER BY employee_id;
-- Should see all ENGINEERING employees with salary masked (NULL)

USE ROLE global_admin;
SELECT 'GLOBAL_ADMIN with row access + masking' as test;
SELECT * FROM employees ORDER BY employee_id;
-- Should see all employees with salary visible


-- ============================================================================
-- Exercise 7: Audit and Monitor
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- View all row access policies
SHOW ROW ACCESS POLICIES;

-- View policy references for all tables
SELECT 
  policy_name,
  ref_entity_name as table_name,
  ref_column_names,
  policy_status
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_DOMAIN => 'TABLE'
))
WHERE ref_entity_name IN ('CUSTOMERS', 'SALES', 'EMPLOYEES')
ORDER BY ref_entity_name;

-- Create comprehensive audit view
CREATE OR REPLACE VIEW row_access_audit AS
SELECT 
  p.policy_name,
  p.policy_owner,
  p.created as policy_created,
  p.last_altered as policy_modified,
  r.ref_entity_name as table_name,
  r.ref_column_names as columns,
  r.policy_status
FROM SNOWFLAKE.ACCOUNT_USAGE.ROW_ACCESS_POLICIES p
LEFT JOIN TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_DOMAIN => 'TABLE'
)) r ON p.policy_name = r.policy_name
WHERE p.deleted IS NULL
ORDER BY p.policy_name, r.ref_entity_name;

-- Query audit view
SELECT * FROM row_access_audit;

-- Check query history with row filtering
SELECT 
  query_id,
  user_name,
  role_name,
  LEFT(query_text, 100) as query_preview,
  rows_produced,
  execution_time,
  start_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%customers%'
  AND start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 10;

-- Summary of row access policies by table
SELECT 
  ref_entity_name as table_name,
  policy_name,
  ref_column_names as filtered_columns,
  policy_status
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_DOMAIN => 'TABLE'
))
WHERE ref_entity_name IN ('CUSTOMERS', 'SALES', 'EMPLOYEES')
ORDER BY ref_entity_name;


-- ============================================================================
-- Bonus: Advanced Patterns
-- ============================================================================

-- Time-based access policy
CREATE ROW ACCESS POLICY time_based_access AS (
  sale_date DATE
) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_MANAGER' 
      AND sale_date >= DATEADD(day, -90, CURRENT_DATE()) THEN TRUE
    WHEN CURRENT_ROLE() IN ('NORTH_SALES', 'SOUTH_SALES', 'EAST_SALES', 'WEST_SALES')
      AND sale_date >= DATEADD(day, -30, CURRENT_DATE()) THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Limits access to recent data based on role';

-- Hierarchical access policy (managers see their team)
CREATE ROW ACCESS POLICY manager_hierarchy AS (
  manager_id INT
) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN manager_id IN (
      SELECT employee_id FROM employees WHERE name = CURRENT_USER()
    ) THEN TRUE
    WHEN CURRENT_USER() IN (
      SELECT name FROM employees WHERE employee_id = manager_id
    ) THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Managers see their direct reports';

-- Tenant isolation policy (for SaaS applications)
CREATE ROW ACCESS POLICY tenant_isolation AS (
  tenant_id STRING
) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('PLATFORM_ADMIN') THEN TRUE
    WHEN tenant_id = CURRENT_SESSION_PARAMETER('TENANT_ID') THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Isolates tenant data in multi-tenant applications';

-- Best practices summary
SELECT 
  'Row Access Policy Best Practices' as category,
  'Use mapping tables for flexibility' as practice,
  'Easier to manage access without changing policies' as benefit
UNION ALL
SELECT 'Row Access', 'Test with all roles', 'Verify filtering works correctly'
UNION ALL
SELECT 'Row Access', 'Combine with masking policies', 'Complete data protection'
UNION ALL
SELECT 'Row Access', 'Monitor performance', 'Ensure policies don''t slow queries'
UNION ALL
SELECT 'Row Access', 'Document policy logic', 'Clear understanding of access rules'
UNION ALL
SELECT 'Row Access', 'Regular audits', 'Ensure compliance and proper access'
UNION ALL
SELECT 'Row Access', 'Use multi-column policies when needed', 'More precise access control'
UNION ALL
SELECT 'Row Access', 'Centralize policy management', 'Consistent security across tables';


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
