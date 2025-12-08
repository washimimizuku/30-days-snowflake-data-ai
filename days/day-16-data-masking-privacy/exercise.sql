/*
Day 16: Data Masking & Privacy - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Setup (5 min)
-- ============================================================================

USE ROLE ACCOUNTADMIN;

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY16_MASKING;
USE SCHEMA DAY16_MASKING;

-- Create sample tables with sensitive data
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(20),
  ssn VARCHAR(11),
  credit_card VARCHAR(19),
  date_of_birth DATE,
  address VARCHAR(200)
);

CREATE OR REPLACE TABLE employees (
  employee_id INT,
  name VARCHAR(100),
  email VARCHAR(100),
  ssn VARCHAR(11),
  salary NUMBER(10,2),
  hire_date DATE,
  department VARCHAR(50)
);

CREATE OR REPLACE TABLE transactions (
  transaction_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  card_number VARCHAR(19),
  transaction_date DATE
);

-- Insert sample data
INSERT INTO customers VALUES
  (1, 'John', 'Doe', 'john.doe@example.com', '555-123-4567', '123-45-6789', '4111-1111-1111-1111', '1985-03-15', '123 Main St, City, ST 12345'),
  (2, 'Jane', 'Smith', 'jane.smith@example.com', '555-234-5678', '234-56-7890', '4222-2222-2222-2222', '1990-07-22', '456 Oak Ave, Town, ST 23456'),
  (3, 'Bob', 'Johnson', 'bob.johnson@example.com', '555-345-6789', '345-67-8901', '4333-3333-3333-3333', '1978-11-30', '789 Pine Rd, Village, ST 34567');

INSERT INTO employees VALUES
  (101, 'Alice Williams', 'alice@company.com', '111-22-3333', 75000.00, '2020-01-15', 'Engineering'),
  (102, 'Bob Brown', 'bob@company.com', '222-33-4444', 85000.00, '2019-06-01', 'Sales'),
  (103, 'Carol Davis', 'carol@company.com', '333-44-5555', 95000.00, '2018-03-20', 'Management');

INSERT INTO transactions VALUES
  (1001, 1, 150.00, '4111-1111-1111-1111', '2024-01-15'),
  (1002, 2, 275.50, '4222-2222-2222-2222', '2024-01-16'),
  (1003, 1, 89.99, '4111-1111-1111-1111', '2024-01-17');

-- Create roles for testing
CREATE ROLE IF NOT EXISTS data_admin;
CREATE ROLE IF NOT EXISTS data_analyst;
CREATE ROLE IF NOT EXISTS data_viewer;
CREATE ROLE IF NOT EXISTS hr_admin;
CREATE ROLE IF NOT EXISTS finance_admin;

-- Grant basic access
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE data_admin;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE data_analyst;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE data_viewer;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE hr_admin;
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE finance_admin;

GRANT USAGE ON SCHEMA DAY16_MASKING TO ROLE data_admin;
GRANT USAGE ON SCHEMA DAY16_MASKING TO ROLE data_analyst;
GRANT USAGE ON SCHEMA DAY16_MASKING TO ROLE data_viewer;
GRANT USAGE ON SCHEMA DAY16_MASKING TO ROLE hr_admin;
GRANT USAGE ON SCHEMA DAY16_MASKING TO ROLE finance_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA DAY16_MASKING TO ROLE data_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY16_MASKING TO ROLE data_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY16_MASKING TO ROLE data_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY16_MASKING TO ROLE hr_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA DAY16_MASKING TO ROLE finance_admin;


-- ============================================================================
-- Exercise 1: Create Basic Masking Policies (10 min)
-- ============================================================================

-- TODO: Create email masking policy
-- CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN') THEN val
--     ELSE '***@*****.com'
--   END;

-- TODO: Create SSN masking policy (show last 4 digits)
-- CREATE MASKING POLICY ssn_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN') THEN val
--     ELSE CONCAT('***-**-', RIGHT(val, 4))
--   END;

-- TODO: Create credit card masking policy (show last 4 digits)
-- CREATE MASKING POLICY cc_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'FINANCE_ADMIN') THEN val
--     ELSE CONCAT('****-****-****-', RIGHT(val, 4))
--   END;

-- TODO: Create phone number masking policy
-- CREATE MASKING POLICY phone_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN') THEN val
--     ELSE CONCAT('***-***-', RIGHT(val, 4))
--   END;

-- TODO: Create salary masking policy
-- CREATE MASKING POLICY salary_mask AS (val NUMBER) RETURNS NUMBER ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN', 'FINANCE_ADMIN') THEN val
--     ELSE NULL
--   END;

-- TODO: View created policies
-- SHOW MASKING POLICIES;


-- ============================================================================
-- Exercise 2: Apply Masking to Tables (5 min)
-- ============================================================================

-- TODO: Apply email masking to customers table
-- ALTER TABLE customers MODIFY COLUMN email SET MASKING POLICY email_mask;

-- TODO: Apply SSN masking to customers table
-- ALTER TABLE customers MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;

-- TODO: Apply credit card masking to customers table
-- ALTER TABLE customers MODIFY COLUMN credit_card SET MASKING POLICY cc_mask;

-- TODO: Apply phone masking to customers table
-- ALTER TABLE customers MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- TODO: Apply masking to employees table
-- ALTER TABLE employees MODIFY COLUMN email SET MASKING POLICY email_mask;
-- ALTER TABLE employees MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;
-- ALTER TABLE employees MODIFY COLUMN salary SET MASKING POLICY salary_mask;

-- TODO: Apply masking to transactions table
-- ALTER TABLE transactions MODIFY COLUMN card_number SET MASKING POLICY cc_mask;

-- TODO: View policy references
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
--   POLICY_NAME => 'EMAIL_MASK'
-- ));


-- ============================================================================
-- Exercise 3: Partial Masking (10 min)
-- ============================================================================

-- TODO: Create partial email masking (show domain)
-- CREATE MASKING POLICY email_partial_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
--     ELSE CONCAT('***@', SPLIT_PART(val, '@', 2))
--   END;

-- TODO: Create date masking (show year only)
-- CREATE MASKING POLICY date_year_mask AS (val DATE) RETURNS DATE ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN') THEN val
--     ELSE DATE_FROM_PARTS(YEAR(val), 1, 1)
--   END;

-- TODO: Create address masking (show city/state only)
-- CREATE MASKING POLICY address_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
--     ELSE REGEXP_REPLACE(val, '^[^,]+,', '***,')
--   END;

-- TODO: Apply partial masking policies
-- ALTER TABLE customers MODIFY COLUMN date_of_birth SET MASKING POLICY date_year_mask;
-- ALTER TABLE customers MODIFY COLUMN address SET MASKING POLICY address_mask;


-- ============================================================================
-- Exercise 4: Conditional Masking (5 min)
-- ============================================================================

-- TODO: Create tiered salary masking
-- CREATE MASKING POLICY salary_tiered_mask AS (val NUMBER) RETURNS NUMBER ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN') THEN val
--     WHEN CURRENT_ROLE() IN ('FINANCE_ADMIN') THEN ROUND(val, -3)  -- Round to nearest 1000
--     WHEN CURRENT_ROLE() IN ('DATA_ANALYST') THEN ROUND(val, -4)   -- Round to nearest 10000
--     ELSE NULL
--   END;

-- TODO: Create hash-based masking
-- CREATE MASKING POLICY hash_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
--     ELSE SHA2(val)
--   END;

-- TODO: Create null masking for highly sensitive data
-- CREATE MASKING POLICY full_null_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
--     ELSE NULL
--   END;


-- ============================================================================
-- Exercise 5: Test Masking with Different Roles (5 min)
-- ============================================================================

-- TODO: Test as DATA_ADMIN (should see all data)
-- USE ROLE data_admin;
-- SELECT * FROM customers LIMIT 3;
-- SELECT * FROM employees LIMIT 3;

-- TODO: Test as DATA_ANALYST (should see masked data)
-- USE ROLE data_analyst;
-- SELECT * FROM customers LIMIT 3;
-- SELECT * FROM employees LIMIT 3;

-- TODO: Test as DATA_VIEWER (should see masked data)
-- USE ROLE data_viewer;
-- SELECT * FROM customers LIMIT 3;

-- TODO: Test as HR_ADMIN (should see employee data, masked customer data)
-- USE ROLE hr_admin;
-- SELECT * FROM employees LIMIT 3;
-- SELECT * FROM customers LIMIT 3;

-- TODO: Test as FINANCE_ADMIN (should see financial data)
-- USE ROLE finance_admin;
-- SELECT * FROM transactions LIMIT 3;
-- SELECT * FROM employees LIMIT 3;


-- ============================================================================
-- Exercise 6: Manage Masking Policies (5 min)
-- ============================================================================

-- TODO: Modify existing policy
-- USE ROLE ACCOUNTADMIN;
-- ALTER MASKING POLICY email_mask SET BODY ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'HR_ADMIN', 'FINANCE_ADMIN') THEN val
--     ELSE '***@*****.com'
--   END;

-- TODO: View policy details
-- DESCRIBE MASKING POLICY email_mask;

-- TODO: Create view with inherited masking
-- CREATE VIEW customer_summary AS
--   SELECT 
--     customer_id,
--     first_name,
--     last_name,
--     email,
--     phone
--   FROM customers;

-- TODO: Query view (masking should still apply)
-- USE ROLE data_viewer;
-- SELECT * FROM customer_summary LIMIT 3;

-- TODO: Unset masking policy from a column
-- USE ROLE ACCOUNTADMIN;
-- ALTER TABLE customers MODIFY COLUMN address UNSET MASKING POLICY;

-- TODO: Verify policy removed
-- USE ROLE data_viewer;
-- SELECT address FROM customers LIMIT 3;


-- ============================================================================
-- Exercise 7: Audit and Monitor Masking (5 min)
-- ============================================================================

-- TODO: View all masking policies
-- USE ROLE ACCOUNTADMIN;
-- SHOW MASKING POLICIES;

-- TODO: View policy references for all tables
-- SELECT 
--   policy_name,
--   ref_entity_name as table_name,
--   ref_column_name as column_name,
--   policy_status
-- FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
--   REF_ENTITY_DOMAIN => 'TABLE'
-- ))
-- WHERE ref_entity_name IN ('CUSTOMERS', 'EMPLOYEES', 'TRANSACTIONS')
-- ORDER BY ref_entity_name, ref_column_name;

-- TODO: Create audit view
-- CREATE OR REPLACE VIEW masking_audit AS
-- SELECT 
--   p.policy_name,
--   p.policy_owner,
--   p.created as policy_created,
--   p.last_altered as policy_modified,
--   r.ref_entity_name as table_name,
--   r.ref_column_name as column_name
-- FROM SNOWFLAKE.ACCOUNT_USAGE.MASKING_POLICIES p
-- LEFT JOIN TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
--   REF_ENTITY_DOMAIN => 'TABLE'
-- )) r ON p.policy_name = r.policy_name
-- WHERE p.deleted IS NULL
-- ORDER BY p.policy_name, r.ref_entity_name;

-- TODO: Query audit view
-- SELECT * FROM masking_audit;

-- TODO: Check query history for masked queries
-- SELECT 
--   query_id,
--   user_name,
--   role_name,
--   LEFT(query_text, 100) as query_preview,
--   execution_time
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE query_text ILIKE '%customers%'
--   AND start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ORDER BY start_time DESC
-- LIMIT 10;


-- ============================================================================
-- Bonus: Advanced Masking Patterns (Optional)
-- ============================================================================

-- TODO: Create tokenization masking
-- CREATE MASKING POLICY token_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
--     ELSE CONCAT('TOKEN_', ABS(HASH(val)))
--   END;

-- TODO: Create format-preserving masking
-- CREATE MASKING POLICY format_preserve_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
--     ELSE CONCAT(
--       REPEAT('X', LENGTH(SPLIT_PART(val, '-', 1))), '-',
--       REPEAT('X', LENGTH(SPLIT_PART(val, '-', 2))), '-',
--       SPLIT_PART(val, '-', 3)
--     )
--   END;

-- TODO: Create conditional masking based on data value
-- CREATE MASKING POLICY amount_threshold_mask AS (val NUMBER) RETURNS NUMBER ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('DATA_ADMIN', 'FINANCE_ADMIN') THEN val
--     WHEN val < 1000 THEN val  -- Show small amounts
--     ELSE NULL  -- Hide large amounts
--   END;


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Unset all masking policies
-- USE ROLE ACCOUNTADMIN;
-- ALTER TABLE customers MODIFY COLUMN email UNSET MASKING POLICY;
-- ALTER TABLE customers MODIFY COLUMN ssn UNSET MASKING POLICY;
-- ALTER TABLE customers MODIFY COLUMN credit_card UNSET MASKING POLICY;
-- ALTER TABLE customers MODIFY COLUMN phone UNSET MASKING POLICY;
-- ALTER TABLE customers MODIFY COLUMN date_of_birth UNSET MASKING POLICY;
-- ALTER TABLE employees MODIFY COLUMN email UNSET MASKING POLICY;
-- ALTER TABLE employees MODIFY COLUMN ssn UNSET MASKING POLICY;
-- ALTER TABLE employees MODIFY COLUMN salary UNSET MASKING POLICY;
-- ALTER TABLE transactions MODIFY COLUMN card_number UNSET MASKING POLICY;

-- Drop masking policies
-- DROP MASKING POLICY IF EXISTS email_mask;
-- DROP MASKING POLICY IF EXISTS ssn_mask;
-- DROP MASKING POLICY IF EXISTS cc_mask;
-- DROP MASKING POLICY IF EXISTS phone_mask;
-- DROP MASKING POLICY IF EXISTS salary_mask;
-- DROP MASKING POLICY IF EXISTS email_partial_mask;
-- DROP MASKING POLICY IF EXISTS date_year_mask;
-- DROP MASKING POLICY IF EXISTS address_mask;
-- DROP MASKING POLICY IF EXISTS salary_tiered_mask;
-- DROP MASKING POLICY IF EXISTS hash_mask;
-- DROP MASKING POLICY IF EXISTS full_null_mask;
-- DROP MASKING POLICY IF EXISTS token_mask;
-- DROP MASKING POLICY IF EXISTS format_preserve_mask;
-- DROP MASKING POLICY IF EXISTS amount_threshold_mask;

-- Drop tables
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS employees;
-- DROP TABLE IF EXISTS transactions;

-- Drop views
-- DROP VIEW IF EXISTS customer_summary;
-- DROP VIEW IF EXISTS masking_audit;

-- Drop roles
-- DROP ROLE IF EXISTS data_admin;
-- DROP ROLE IF EXISTS data_analyst;
-- DROP ROLE IF EXISTS data_viewer;
-- DROP ROLE IF EXISTS hr_admin;
-- DROP ROLE IF EXISTS finance_admin;
