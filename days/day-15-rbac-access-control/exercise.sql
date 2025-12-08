/*
Day 15: Role-Based Access Control (RBAC) - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

-- Use ACCOUNTADMIN to set up (only for this exercise)
USE ROLE ACCOUNTADMIN;

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY15_RBAC;
USE SCHEMA DAY15_RBAC;

-- Create sample tables for access control
CREATE OR REPLACE TABLE sales_data (
  sale_id INT,
  customer_id INT,
  product_name VARCHAR(100),
  sale_amount DECIMAL(10,2),
  sale_date DATE,
  region VARCHAR(50)
);

CREATE OR REPLACE TABLE customer_data (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20),
  credit_card VARCHAR(20)
);

CREATE OR REPLACE TABLE public_data (
  id INT,
  description VARCHAR(200),
  category VARCHAR(50)
);

-- Insert sample data
INSERT INTO sales_data VALUES
  (1, 101, 'Laptop', 1200.00, '2024-01-15', 'NORTH'),
  (2, 102, 'Mouse', 25.00, '2024-01-16', 'SOUTH'),
  (3, 103, 'Keyboard', 75.00, '2024-01-17', 'EAST');

INSERT INTO customer_data VALUES
  (101, 'John Doe', 'john@example.com', '555-0101', '4111-1111-1111-1111'),
  (102, 'Jane Smith', 'jane@example.com', '555-0102', '4222-2222-2222-2222'),
  (103, 'Bob Johnson', 'bob@example.com', '555-0103', '4333-3333-3333-3333');

INSERT INTO public_data VALUES
  (1, 'Public information', 'General'),
  (2, 'Company news', 'News'),
  (3, 'Product catalog', 'Products');


-- ============================================================================
-- Exercise 1: Create Role Hierarchy (10 min)
-- ============================================================================

-- TODO: Create a three-tier role hierarchy
-- Tier 1: Read-only viewer
-- CREATE ROLE data_viewer;

-- Tier 2: Analyst (can read and analyze)
-- CREATE ROLE data_analyst;

-- Tier 3: Engineer (can read, write, and manage)
-- CREATE ROLE data_engineer;

-- TODO: Build role hierarchy
-- GRANT ROLE data_viewer TO ROLE data_analyst;
-- GRANT ROLE data_analyst TO ROLE data_engineer;
-- GRANT ROLE data_engineer TO ROLE SYSADMIN;

-- TODO: Create department-specific roles
-- CREATE ROLE sales_team;
-- CREATE ROLE finance_team;
-- CREATE ROLE executive_team;

-- TODO: View created roles
-- SHOW ROLES;


-- ============================================================================
-- Exercise 2: Grant Database and Schema Access (10 min)
-- ============================================================================

-- TODO: Grant USAGE on database to data_viewer
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE data_viewer;

-- TODO: Grant USAGE on schema to data_viewer
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_viewer;

-- TODO: Grant SELECT on all tables to data_viewer
-- GRANT SELECT ON ALL TABLES IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_viewer;

-- TODO: Grant future SELECT privileges
-- GRANT SELECT ON FUTURE TABLES IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_viewer;

-- TODO: Grant additional privileges to data_analyst
-- (inherits data_viewer privileges, add more)
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE data_analyst;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_analyst;

-- TODO: Grant write privileges to data_engineer
-- GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_engineer;
-- GRANT CREATE TABLE ON SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_engineer;

-- TODO: View grants for each role
-- SHOW GRANTS TO ROLE data_viewer;
-- SHOW GRANTS TO ROLE data_analyst;
-- SHOW GRANTS TO ROLE data_engineer;


-- ============================================================================
-- Exercise 3: Table-Level Privileges (5 min)
-- ============================================================================

-- TODO: Grant sales_team access to sales_data only
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE sales_team;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE sales_team;
-- GRANT SELECT ON TABLE BOOTCAMP_DB.DAY15_RBAC.sales_data TO ROLE sales_team;

-- TODO: Grant finance_team access to customer_data only
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE finance_team;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE finance_team;
-- GRANT SELECT ON TABLE BOOTCAMP_DB.DAY15_RBAC.customer_data TO ROLE finance_team;

-- TODO: Grant executive_team access to all tables
-- GRANT ROLE sales_team TO ROLE executive_team;
-- GRANT ROLE finance_team TO ROLE executive_team;

-- TODO: Grant PUBLIC access to public_data
-- GRANT SELECT ON TABLE BOOTCAMP_DB.DAY15_RBAC.public_data TO ROLE PUBLIC;

-- TODO: View grants on specific tables
-- SHOW GRANTS ON TABLE sales_data;
-- SHOW GRANTS ON TABLE customer_data;
-- SHOW GRANTS ON TABLE public_data;


-- ============================================================================
-- Exercise 4: Future Grants (5 min)
-- ============================================================================

-- TODO: Set up future grants for data_viewer
-- GRANT SELECT ON FUTURE TABLES IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_viewer;
-- GRANT SELECT ON FUTURE VIEWS IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_viewer;

-- TODO: Set up future grants for data_engineer
-- GRANT INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE data_engineer;

-- TODO: Create a new table to test future grants
-- USE ROLE SYSADMIN;
-- CREATE TABLE test_future_grants (
--   id INT,
--   description VARCHAR(100)
-- );

-- TODO: Verify data_viewer can select from new table
-- USE ROLE data_viewer;
-- SELECT * FROM test_future_grants;

-- TODO: View future grants
-- USE ROLE ACCOUNTADMIN;
-- SHOW FUTURE GRANTS IN SCHEMA BOOTCAMP_DB.DAY15_RBAC;


-- ============================================================================
-- Exercise 5: Warehouse Access (5 min)
-- ============================================================================

-- TODO: Create warehouses for different roles
-- USE ROLE SYSADMIN;
-- CREATE WAREHOUSE IF NOT EXISTS analyst_wh WITH
--   WAREHOUSE_SIZE = 'XSMALL'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE;

-- CREATE WAREHOUSE IF NOT EXISTS engineer_wh WITH
--   WAREHOUSE_SIZE = 'SMALL'
--   AUTO_SUSPEND = 120
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE;

-- TODO: Grant warehouse usage to roles
-- GRANT USAGE ON WAREHOUSE analyst_wh TO ROLE data_analyst;
-- GRANT USAGE ON WAREHOUSE engineer_wh TO ROLE data_engineer;
-- GRANT OPERATE ON WAREHOUSE engineer_wh TO ROLE data_engineer;

-- TODO: View warehouse grants
-- SHOW GRANTS ON WAREHOUSE analyst_wh;
-- SHOW GRANTS ON WAREHOUSE engineer_wh;


-- ============================================================================
-- Exercise 6: Role Switching and Testing (5 min)
-- ============================================================================

-- TODO: Test data_viewer role
-- USE ROLE data_viewer;
-- SELECT CURRENT_ROLE();
-- SELECT * FROM sales_data;  -- Should work
-- INSERT INTO sales_data VALUES (4, 104, 'Test', 100, CURRENT_DATE(), 'WEST');  -- Should fail

-- TODO: Test data_analyst role
-- USE ROLE data_analyst;
-- SELECT CURRENT_ROLE();
-- SELECT * FROM sales_data;  -- Should work (inherits from data_viewer)
-- INSERT INTO sales_data VALUES (4, 104, 'Test', 100, CURRENT_DATE(), 'WEST');  -- Should fail

-- TODO: Test data_engineer role
-- USE ROLE data_engineer;
-- SELECT CURRENT_ROLE();
-- SELECT * FROM sales_data;  -- Should work
-- INSERT INTO sales_data VALUES (4, 104, 'Test', 100, CURRENT_DATE(), 'WEST');  -- Should work
-- DELETE FROM sales_data WHERE sale_id = 4;  -- Should work

-- TODO: Test sales_team role
-- USE ROLE sales_team;
-- SELECT * FROM sales_data;  -- Should work
-- SELECT * FROM customer_data;  -- Should fail (no access)

-- TODO: Test PUBLIC role
-- USE ROLE PUBLIC;
-- SELECT * FROM public_data;  -- Should work
-- SELECT * FROM sales_data;  -- Should fail


-- ============================================================================
-- Exercise 7: Audit and Monitor (5 min)
-- ============================================================================

-- TODO: View all roles in account
-- USE ROLE ACCOUNTADMIN;
-- SHOW ROLES;

-- TODO: View role hierarchy
-- SELECT 
--   grantee_name,
--   role,
--   granted_by,
--   granted_on
-- FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
-- WHERE deleted_on IS NULL
--   AND granted_on = 'ROLE'
--   AND grantee_name IN ('DATA_VIEWER', 'DATA_ANALYST', 'DATA_ENGINEER')
-- ORDER BY grantee_name;

-- TODO: View all privileges for data_engineer
-- SHOW GRANTS TO ROLE data_engineer;

-- TODO: View who has access to sales_data
-- SHOW GRANTS ON TABLE sales_data;

-- TODO: Create audit view
-- CREATE OR REPLACE VIEW role_privilege_audit AS
-- SELECT 
--   grantee_name as role_name,
--   privilege,
--   granted_on,
--   name as object_name,
--   granted_by,
--   created_on
-- FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
-- WHERE deleted_on IS NULL
--   AND grantee_name IN ('DATA_VIEWER', 'DATA_ANALYST', 'DATA_ENGINEER', 'SALES_TEAM', 'FINANCE_TEAM')
-- ORDER BY grantee_name, granted_on, name;

-- TODO: Query audit view
-- SELECT * FROM role_privilege_audit;

-- TODO: Find roles with access to sensitive data
-- SELECT DISTINCT grantee_name
-- FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
-- WHERE deleted_on IS NULL
--   AND name = 'CUSTOMER_DATA'
--   AND privilege = 'SELECT';


-- ============================================================================
-- Bonus: Advanced RBAC Patterns (Optional)
-- ============================================================================

-- TODO: Create service account role for ETL
-- CREATE ROLE etl_service_role;
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE etl_service_role;
-- GRANT USAGE ON SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE etl_service_role;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA BOOTCAMP_DB.DAY15_RBAC TO ROLE etl_service_role;
-- GRANT USAGE ON WAREHOUSE engineer_wh TO ROLE etl_service_role;

-- TODO: Create read-only role for BI tools
-- CREATE ROLE bi_readonly_role;
-- GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE bi_readonly_role;
-- GRANT USAGE ON ALL SCHEMAS IN DATABASE BOOTCAMP_DB TO ROLE bi_readonly_role;
-- GRANT SELECT ON ALL TABLES IN DATABASE BOOTCAMP_DB TO ROLE bi_readonly_role;
-- GRANT SELECT ON FUTURE TABLES IN DATABASE BOOTCAMP_DB TO ROLE bi_readonly_role;

-- TODO: Transfer ownership
-- GRANT OWNERSHIP ON TABLE sales_data TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- TODO: Revoke privileges
-- REVOKE SELECT ON TABLE customer_data FROM ROLE finance_team;

-- TODO: Create user and assign roles
-- CREATE USER analyst_user PASSWORD='SecurePass123!' DEFAULT_ROLE=data_analyst;
-- GRANT ROLE data_analyst TO USER analyst_user;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Switch back to ACCOUNTADMIN
-- USE ROLE ACCOUNTADMIN;

-- Drop roles (careful!)
-- DROP ROLE IF EXISTS data_viewer;
-- DROP ROLE IF EXISTS data_analyst;
-- DROP ROLE IF EXISTS data_engineer;
-- DROP ROLE IF EXISTS sales_team;
-- DROP ROLE IF EXISTS finance_team;
-- DROP ROLE IF EXISTS executive_team;
-- DROP ROLE IF EXISTS etl_service_role;
-- DROP ROLE IF EXISTS bi_readonly_role;

-- Drop warehouses
-- DROP WAREHOUSE IF EXISTS analyst_wh;
-- DROP WAREHOUSE IF EXISTS engineer_wh;

-- Drop tables
-- DROP TABLE IF EXISTS sales_data;
-- DROP TABLE IF EXISTS customer_data;
-- DROP TABLE IF EXISTS public_data;
-- DROP TABLE IF EXISTS test_future_grants;

-- Drop views
-- DROP VIEW IF EXISTS role_privilege_audit;
