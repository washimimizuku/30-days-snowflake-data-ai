/*******************************************************************************
 * Day 20: Cloning & Zero-Copy Cloning - SOLUTIONS
 * 
 * Complete solutions for all exercises
 * 
 *******************************************************************************/

-- Setup: Create sample database and tables
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE clone_lab;
USE DATABASE clone_lab;
USE SCHEMA public;

-- Create sample tables
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name STRING,
  email STRING,
  region STRING,
  signup_date DATE,
  total_purchases DECIMAL(10,2)
);

CREATE OR REPLACE TABLE orders (
  order_id INT,
  customer_id INT,
  order_date DATE,
  amount DECIMAL(10,2),
  status STRING
);

CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name STRING,
  category STRING,
  price DECIMAL(10,2),
  stock_quantity INT
);

-- Insert sample data
INSERT INTO customers VALUES
  (1, 'Alice Johnson', 'alice@email.com', 'NORTH', '2023-01-15', 5000.00),
  (2, 'Bob Smith', 'bob@email.com', 'SOUTH', '2023-02-20', 3500.00),
  (3, 'Carol White', 'carol@email.com', 'EAST', '2023-03-10', 7200.00),
  (4, 'David Brown', 'david@email.com', 'WEST', '2023-04-05', 2100.00),
  (5, 'Eve Davis', 'eve@email.com', 'NORTH', '2023-05-12', 4800.00);

INSERT INTO orders VALUES
  (101, 1, '2024-01-10', 500.00, 'COMPLETED'),
  (102, 2, '2024-01-11', 750.00, 'COMPLETED'),
  (103, 3, '2024-01-12', 1200.00, 'PENDING'),
  (104, 1, '2024-01-13', 300.00, 'COMPLETED'),
  (105, 4, '2024-01-14', 450.00, 'SHIPPED');

INSERT INTO products VALUES
  (1001, 'Laptop', 'Electronics', 999.99, 50),
  (1002, 'Mouse', 'Electronics', 29.99, 200),
  (1003, 'Desk', 'Furniture', 299.99, 30),
  (1004, 'Chair', 'Furniture', 199.99, 45),
  (1005, 'Monitor', 'Electronics', 399.99, 75);

/*******************************************************************************
 * Exercise 1: Basic Cloning - SOLUTIONS
 *******************************************************************************/

-- Solution 1.1: Clone the customers table
CREATE TABLE customers_clone CLONE customers;

-- Solution 1.2: Verify the clone was created
SHOW TABLES LIKE '%customers%';

SELECT COUNT(*) as row_count FROM customers;
SELECT COUNT(*) as row_count FROM customers_clone;

-- Solution 1.3: Modify the clone
INSERT INTO customers_clone VALUES
  (6, 'Frank Miller', 'frank@email.com', 'SOUTH', '2024-01-15', 0);

-- Solution 1.4: Verify source table is unchanged
SELECT 'Source' as table_type, COUNT(*) as row_count FROM customers
UNION ALL
SELECT 'Clone' as table_type, COUNT(*) as row_count FROM customers_clone;

-- Verify Frank only exists in clone
SELECT * FROM customers WHERE customer_id = 6;  -- Returns 0 rows
SELECT * FROM customers_clone WHERE customer_id = 6;  -- Returns 1 row

-- Solution 1.5: Clone the entire schema
CREATE SCHEMA public_backup CLONE public;

-- Solution 1.6: Verify schema clone
SHOW TABLES IN SCHEMA public_backup;

SELECT COUNT(*) as table_count 
FROM clone_lab.information_schema.tables
WHERE table_schema = 'PUBLIC_BACKUP';

/*******************************************************************************
 * Exercise 2: Clone with Time Travel - SOLUTIONS
 *******************************************************************************/

-- Setup: Make some changes to track
UPDATE customers SET total_purchases = total_purchases + 1000 WHERE customer_id = 1;
DELETE FROM orders WHERE order_id = 105;

-- Wait a moment
SELECT SYSTEM$WAIT(5);

-- Solution 2.1: Get the query ID of the DELETE statement
SELECT 
  query_id,
  query_text,
  start_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%DELETE FROM orders%'
  AND query_text NOT ILIKE '%QUERY_HISTORY%'
ORDER BY start_time DESC
LIMIT 1;

-- Save the query_id for next step
SET delete_query_id = (
  SELECT query_id
  FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
  WHERE query_text ILIKE '%DELETE FROM orders WHERE order_id = 105%'
  ORDER BY start_time DESC
  LIMIT 1
);

-- Solution 2.2: Clone orders table from before the DELETE
CREATE TABLE orders_before_delete CLONE orders
BEFORE(STATEMENT => $delete_query_id);

-- Solution 2.3: Verify the deleted row exists in the clone
SELECT * FROM orders WHERE order_id = 105;  -- Returns 0 rows
SELECT * FROM orders_before_delete WHERE order_id = 105;  -- Returns 1 row

-- Solution 2.4: Clone customers table from 1 minute ago
CREATE TABLE customers_1min_ago CLONE customers
AT(OFFSET => -60);  -- 60 seconds ago

-- Solution 2.5: Compare current vs. 1 minute ago
SELECT 
  'Current' as version,
  customer_id,
  customer_name,
  total_purchases
FROM customers
WHERE customer_id = 1
UNION ALL
SELECT 
  '1 Min Ago' as version,
  customer_id,
  customer_name,
  total_purchases
FROM customers_1min_ago
WHERE customer_id = 1;

-- Show the difference
SELECT 
  c.customer_id,
  c.customer_name,
  c.total_purchases as current_purchases,
  h.total_purchases as historical_purchases,
  c.total_purchases - h.total_purchases as difference
FROM customers c
JOIN customers_1min_ago h ON c.customer_id = h.customer_id
WHERE c.customer_id = 1;

/*******************************************************************************
 * Exercise 3: Development Environment - SOLUTIONS
 *******************************************************************************/

-- Solution 3.1: Clone the entire database for development
CREATE DATABASE clone_lab_dev CLONE clone_lab;

-- Solution 3.2: Verify all tables were cloned
USE DATABASE clone_lab_dev;
SHOW TABLES;

SELECT 
  table_catalog,
  table_schema,
  table_name,
  row_count
FROM clone_lab_dev.information_schema.tables
WHERE table_schema = 'PUBLIC'
  AND table_type = 'BASE TABLE';

-- Solution 3.3: Grant access to a developer role
USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS developer;

GRANT USAGE ON DATABASE clone_lab_dev TO ROLE developer;
GRANT USAGE ON ALL SCHEMAS IN DATABASE clone_lab_dev TO ROLE developer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA clone_lab_dev.public TO ROLE developer;
GRANT SELECT ON ALL VIEWS IN SCHEMA clone_lab_dev.public TO ROLE developer;

-- Grant role to a user (example)
-- GRANT ROLE developer TO USER dev_user;

-- Solution 3.4: Test modifications in dev environment
USE ROLE SYSADMIN;
USE DATABASE clone_lab_dev;
USE SCHEMA public;

-- Add new column
ALTER TABLE customers ADD COLUMN loyalty_tier STRING DEFAULT 'BRONZE';

-- Insert test data
INSERT INTO customers VALUES
  (100, 'Test User', 'test@email.com', 'TEST', '2024-01-15', 0, 'GOLD');

-- Verify changes
SELECT * FROM customers WHERE customer_id = 100;

-- Solution 3.5: Verify production is unchanged
USE DATABASE clone_lab;
USE SCHEMA public;

-- Check if new column exists (it shouldn't)
DESC TABLE customers;

-- Check if test user exists (it shouldn't)
SELECT * FROM customers WHERE customer_id = 100;  -- Returns 0 rows

-- Solution 3.6: Document the dev environment
COMMENT ON DATABASE clone_lab_dev IS 
  'Development environment cloned from clone_lab production. 
   Created: 2024-01-15. 
   Purpose: Testing and development. 
   Owner: Data Engineering Team.
   Refresh: Weekly on Mondays.';

SHOW DATABASES LIKE 'clone_lab_dev';

/*******************************************************************************
 * Exercise 4: Schema Migration Testing - SOLUTIONS
 *******************************************************************************/

USE DATABASE clone_lab;
USE SCHEMA public;

-- Solution 4.1: Clone products table for testing
CREATE TABLE products_test CLONE products;

-- Solution 4.2: Add new columns to the test table
ALTER TABLE products_test ADD COLUMN last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP();
ALTER TABLE products_test ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- Solution 4.3: Populate new columns with default values
UPDATE products_test 
SET last_updated = CURRENT_TIMESTAMP(),
    is_active = TRUE;

-- Solution 4.4: Test queries with new schema
SELECT * FROM products_test;

-- Test filtering by new column
SELECT * FROM products_test WHERE is_active = TRUE;

-- Test ordering by new column
SELECT * FROM products_test ORDER BY last_updated DESC;

-- Solution 4.5: Apply changes to production (after testing)
ALTER TABLE products ADD COLUMN last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP();
ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

UPDATE products 
SET last_updated = CURRENT_TIMESTAMP(),
    is_active = TRUE;

-- Verify production table
DESC TABLE products;
SELECT * FROM products;

-- Solution 4.6: Clean up test table
DROP TABLE products_test;

/*******************************************************************************
 * Exercise 5: Data Recovery - SOLUTIONS
 *******************************************************************************/

-- Setup: Simulate accidental data loss
CREATE OR REPLACE TABLE critical_data AS
SELECT * FROM customers;

-- Accidentally delete important data
DELETE FROM critical_data WHERE region = 'NORTH';

-- Solution 5.1: Verify data was deleted
SELECT COUNT(*) as remaining_rows FROM critical_data;
SELECT COUNT(*) as deleted_rows FROM customers WHERE region = 'NORTH';

-- Solution 5.2: Get the query ID of the DELETE
SET critical_delete_query_id = (
  SELECT query_id
  FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
  WHERE query_text ILIKE '%DELETE FROM critical_data WHERE region%'
  ORDER BY start_time DESC
  LIMIT 1
);

SELECT $critical_delete_query_id as delete_query_id;

-- Solution 5.3: Clone the table from before the delete
CREATE TABLE critical_data_recovered CLONE critical_data
BEFORE(STATEMENT => $critical_delete_query_id);

-- Solution 5.4: Verify recovered data
SELECT COUNT(*) as recovered_north_rows 
FROM critical_data_recovered 
WHERE region = 'NORTH';

SELECT * FROM critical_data_recovered WHERE region = 'NORTH';

-- Solution 5.5: Restore the data to the original table
INSERT INTO critical_data
SELECT * FROM critical_data_recovered
WHERE region = 'NORTH';

-- Solution 5.6: Verify restoration
SELECT COUNT(*) as total_rows FROM critical_data;
SELECT COUNT(*) as north_rows FROM critical_data WHERE region = 'NORTH';

-- Compare with original
SELECT 
  'Original' as source,
  COUNT(*) as row_count
FROM customers
UNION ALL
SELECT 
  'After Recovery' as source,
  COUNT(*) as row_count
FROM critical_data;

-- Cleanup
DROP TABLE critical_data_recovered;

/*******************************************************************************
 * Exercise 6: Storage Analysis - SOLUTIONS
 *******************************************************************************/

-- Solution 6.1: View storage metrics for all tables
SELECT 
  table_catalog,
  table_schema,
  table_name,
  active_bytes / 1024 / 1024 as active_mb,
  time_travel_bytes / 1024 / 1024 as time_travel_mb,
  failsafe_bytes / 1024 / 1024 as failsafe_mb,
  clone_group_id,
  is_clone
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'CLONE_LAB'
  AND deleted IS NULL
ORDER BY active_bytes DESC;

-- Solution 6.2: Calculate storage by clone vs. source tables
SELECT 
  CASE 
    WHEN is_clone = 'YES' THEN 'Clones'
    ELSE 'Source Tables'
  END as table_type,
  COUNT(*) as table_count,
  SUM(active_bytes) / 1024 / 1024 / 1024 as total_gb,
  AVG(active_bytes) / 1024 / 1024 as avg_mb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'CLONE_LAB'
  AND deleted IS NULL
GROUP BY is_clone;

-- Solution 6.3: Find tables with clone relationships
SELECT 
  clone_group_id,
  table_name,
  is_clone,
  active_bytes / 1024 / 1024 as active_mb,
  created
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'CLONE_LAB'
  AND clone_group_id IS NOT NULL
  AND deleted IS NULL
ORDER BY clone_group_id, is_clone;

-- Solution 6.4: Identify clones with high storage divergence
WITH source_sizes AS (
  SELECT 
    clone_group_id,
    MAX(CASE WHEN is_clone = 'NO' THEN active_bytes END) as source_bytes
  FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
  WHERE table_catalog = 'CLONE_LAB'
    AND deleted IS NULL
  GROUP BY clone_group_id
)
SELECT 
  t.table_name,
  t.active_bytes / 1024 / 1024 as clone_mb,
  s.source_bytes / 1024 / 1024 as source_mb,
  ROUND((t.active_bytes::FLOAT / NULLIF(s.source_bytes, 0)) * 100, 2) as divergence_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS t
JOIN source_sizes s ON t.clone_group_id = s.clone_group_id
WHERE t.is_clone = 'YES'
  AND t.deleted IS NULL
  AND (t.active_bytes::FLOAT / NULLIF(s.source_bytes, 0)) > 0.5
ORDER BY divergence_pct DESC;

-- Solution 6.5: List all clones with their creation date
SELECT 
  table_catalog,
  table_schema,
  table_name,
  created,
  last_altered,
  bytes / 1024 / 1024 as size_mb,
  row_count,
  DATEDIFF(day, created, CURRENT_TIMESTAMP()) as age_days
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE is_clone = 'YES'
  AND deleted IS NULL
ORDER BY created DESC;

/*******************************************************************************
 * Exercise 7: Automated Backup - SOLUTIONS
 *******************************************************************************/

-- Solution 7.1: Create a stored procedure for daily backups
CREATE OR REPLACE PROCEDURE create_database_backup(db_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  backup_name STRING;
  result STRING;
BEGIN
  -- Generate backup name with date
  backup_name := db_name || '_BACKUP_' || TO_CHAR(CURRENT_DATE(), 'YYYYMMDD');
  
  -- Drop if exists (for testing)
  EXECUTE IMMEDIATE 'DROP DATABASE IF EXISTS ' || backup_name;
  
  -- Create clone
  EXECUTE IMMEDIATE 'CREATE DATABASE ' || backup_name || ' CLONE ' || db_name;
  
  -- Add comment
  EXECUTE IMMEDIATE 'COMMENT ON DATABASE ' || backup_name || 
    ' IS ''Automated backup created on ' || CURRENT_TIMESTAMP()::STRING || '''';
  
  result := 'Backup created successfully: ' || backup_name;
  RETURN result;
END;
$$;

-- Solution 7.2: Test the backup procedure
CALL create_database_backup('CLONE_LAB');

-- Solution 7.3: Verify backup was created
SHOW DATABASES LIKE '%BACKUP%';

SELECT 
  database_name,
  created,
  comment
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE '%BACKUP%'
  AND deleted IS NULL
ORDER BY created DESC;

-- Solution 7.4: Create a procedure to list all backups
CREATE OR REPLACE PROCEDURE list_database_backups()
RETURNS TABLE(backup_name STRING, created_date TIMESTAMP_LTZ, size_gb FLOAT, age_days INT)
LANGUAGE SQL
AS
$$
DECLARE
  res RESULTSET;
BEGIN
  res := (
    SELECT 
      database_name as backup_name,
      created as created_date,
      (SELECT SUM(bytes) / 1024 / 1024 / 1024 
       FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS 
       WHERE table_catalog = database_name) as size_gb,
      DATEDIFF(day, created, CURRENT_TIMESTAMP()) as age_days
    FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
    WHERE database_name LIKE '%_BACKUP_%'
      AND deleted IS NULL
    ORDER BY created DESC
  );
  RETURN TABLE(res);
END;
$$;

-- Test the list procedure
CALL list_database_backups();

-- Solution 7.5: Create a cleanup procedure
CREATE OR REPLACE PROCEDURE cleanup_old_backups(days_to_keep INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  backup_name STRING;
  dropped_count INT DEFAULT 0;
  result STRING;
  cur CURSOR FOR 
    SELECT database_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
    WHERE database_name LIKE '%_BACKUP_%'
      AND deleted IS NULL
      AND DATEDIFF(day, created, CURRENT_TIMESTAMP()) > days_to_keep;
BEGIN
  OPEN cur;
  FOR record IN cur DO
    backup_name := record.database_name;
    EXECUTE IMMEDIATE 'DROP DATABASE IF EXISTS ' || backup_name;
    dropped_count := dropped_count + 1;
  END FOR;
  CLOSE cur;
  
  result := 'Dropped ' || dropped_count || ' backup(s) older than ' || days_to_keep || ' days';
  RETURN result;
END;
$$;

-- Solution 7.6: Test the cleanup procedure
-- First, let's not actually drop our test backup
-- CALL cleanup_old_backups(7);

-- Instead, let's see what would be dropped
SELECT 
  database_name,
  created,
  DATEDIFF(day, created, CURRENT_TIMESTAMP()) as age_days,
  CASE 
    WHEN DATEDIFF(day, created, CURRENT_TIMESTAMP()) > 7 
    THEN 'Would be dropped'
    ELSE 'Would be kept'
  END as status
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE '%_BACKUP_%'
  AND deleted IS NULL
ORDER BY created DESC;

/*******************************************************************************
 * Bonus Challenges - SOLUTIONS
 *******************************************************************************/

-- BONUS 1: Create a clone comparison function
CREATE OR REPLACE PROCEDURE compare_tables(
  table1_name STRING,
  table2_name STRING
)
RETURNS TABLE(change_type STRING, record_count INT)
LANGUAGE SQL
AS
$$
DECLARE
  res RESULTSET;
  query STRING;
BEGIN
  -- Build dynamic query to compare tables
  query := '
    WITH added AS (
      SELECT * FROM ' || table1_name || '
      EXCEPT
      SELECT * FROM ' || table2_name || '
    ),
    removed AS (
      SELECT * FROM ' || table2_name || '
      EXCEPT
      SELECT * FROM ' || table1_name || '
    )
    SELECT ''Added'' as change_type, COUNT(*) as record_count FROM added
    UNION ALL
    SELECT ''Removed'' as change_type, COUNT(*) as record_count FROM removed
  ';
  
  res := (EXECUTE IMMEDIATE :query);
  RETURN TABLE(res);
END;
$$;

-- Test the comparison
CALL compare_tables('customers', 'customers_clone');

-- BONUS 2: Implement A/B testing with clones
CREATE TABLE customers_test_a CLONE customers;
CREATE TABLE customers_test_b CLONE customers;

-- Apply different discount strategies
-- Strategy A: 10% discount for all
ALTER TABLE customers_test_a ADD COLUMN discount_rate FLOAT DEFAULT 0.10;

-- Strategy B: Tiered discounts
ALTER TABLE customers_test_b ADD COLUMN discount_rate FLOAT;
UPDATE customers_test_b 
SET discount_rate = CASE 
  WHEN total_purchases > 5000 THEN 0.15
  WHEN total_purchases > 3000 THEN 0.10
  ELSE 0.05
END;

-- Compare projected revenue
SELECT 
  'Strategy A (Flat 10%)' as strategy,
  SUM(total_purchases * (1 - discount_rate)) as projected_revenue
FROM customers_test_a
UNION ALL
SELECT 
  'Strategy B (Tiered)' as strategy,
  SUM(total_purchases * (1 - discount_rate)) as projected_revenue
FROM customers_test_b;

-- Cleanup
DROP TABLE customers_test_a;
DROP TABLE customers_test_b;

-- BONUS 3: Create a clone lifecycle manager
CREATE OR REPLACE TABLE clone_metadata (
  clone_name STRING,
  created_date TIMESTAMP,
  expiration_date TIMESTAMP,
  owner STRING,
  purpose STRING
);

CREATE OR REPLACE PROCEDURE create_expiring_clone(
  source_table STRING,
  clone_name STRING,
  days_until_expiration INT,
  owner STRING,
  purpose STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  result STRING;
BEGIN
  -- Create clone
  EXECUTE IMMEDIATE 'CREATE TABLE ' || clone_name || ' CLONE ' || source_table;
  
  -- Record metadata
  INSERT INTO clone_metadata VALUES (
    clone_name,
    CURRENT_TIMESTAMP(),
    DATEADD(day, days_until_expiration, CURRENT_TIMESTAMP()),
    owner,
    purpose
  );
  
  result := 'Clone created: ' || clone_name || ' (expires in ' || days_until_expiration || ' days)';
  RETURN result;
END;
$$;

CREATE OR REPLACE PROCEDURE cleanup_expired_clones()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  clone_name STRING;
  dropped_count INT DEFAULT 0;
  result STRING;
  cur CURSOR FOR 
    SELECT clone_name
    FROM clone_metadata
    WHERE expiration_date < CURRENT_TIMESTAMP();
BEGIN
  OPEN cur;
  FOR record IN cur DO
    clone_name := record.clone_name;
    EXECUTE IMMEDIATE 'DROP TABLE IF EXISTS ' || clone_name;
    DELETE FROM clone_metadata WHERE clone_name = clone_name;
    dropped_count := dropped_count + 1;
  END FOR;
  CLOSE cur;
  
  result := 'Dropped ' || dropped_count || ' expired clone(s)';
  RETURN result;
END;
$$;

-- Test lifecycle manager
CALL create_expiring_clone('customers', 'customers_temp_analysis', 7, 'analyst_team', 'Q1 analysis');
SELECT * FROM clone_metadata;

-- BONUS 4: Build a dev environment refresh procedure
CREATE OR REPLACE PROCEDURE refresh_dev_environment(
  prod_db STRING,
  dev_db STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  result STRING;
BEGIN
  -- Drop existing dev database
  EXECUTE IMMEDIATE 'DROP DATABASE IF EXISTS ' || dev_db;
  
  -- Clone production to dev
  EXECUTE IMMEDIATE 'CREATE DATABASE ' || dev_db || ' CLONE ' || prod_db;
  
  -- Add comment
  EXECUTE IMMEDIATE 'COMMENT ON DATABASE ' || dev_db || 
    ' IS ''Dev environment refreshed from ' || prod_db || ' on ' || 
    CURRENT_TIMESTAMP()::STRING || '''';
  
  -- Grant permissions to developer role
  EXECUTE IMMEDIATE 'GRANT USAGE ON DATABASE ' || dev_db || ' TO ROLE developer';
  EXECUTE IMMEDIATE 'GRANT USAGE ON ALL SCHEMAS IN DATABASE ' || dev_db || ' TO ROLE developer';
  EXECUTE IMMEDIATE 'GRANT ALL ON ALL TABLES IN SCHEMA ' || dev_db || '.public TO ROLE developer';
  
  result := 'Dev environment refreshed: ' || dev_db || ' from ' || prod_db;
  RETURN result;
END;
$$;

-- Test dev refresh
CALL refresh_dev_environment('CLONE_LAB', 'CLONE_LAB_DEV');

/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up all objects
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS clone_lab CASCADE;
DROP DATABASE IF EXISTS clone_lab_dev CASCADE;
DROP DATABASE IF EXISTS clone_lab_backup_20240115 CASCADE;

USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS developer;
*/

/*******************************************************************************
 * Summary
 * 
 * In this lab, you learned:
 * 
 * 1. Zero-copy cloning basics
 *    - Clone tables, schemas, and databases instantly
 *    - No data duplication at creation time
 *    - Independent copies that don't affect source
 * 
 * 2. Cloning with Time Travel
 *    - Create point-in-time clones
 *    - Clone from before specific statements
 *    - Use for data recovery and auditing
 * 
 * 3. Development environments
 *    - Clone production for safe testing
 *    - Grant appropriate permissions
 *    - Verify production remains unchanged
 * 
 * 4. Schema migration testing
 *    - Test changes on clones first
 *    - Apply to production after validation
 *    - Minimize risk of breaking changes
 * 
 * 5. Data recovery
 *    - Use clones to recover deleted data
 *    - Combine with Time Travel for point-in-time recovery
 *    - Restore specific tables or entire databases
 * 
 * 6. Storage monitoring
 *    - Track clone storage usage
 *    - Identify storage divergence
 *    - Manage costs by cleaning up unused clones
 * 
 * 7. Automated backups
 *    - Create backup procedures
 *    - Implement retention policies
 *    - Automate cleanup of old backups
 * 
 * Key Benefits:
 * - Instant cloning regardless of size
 * - Cost-effective (only pay for diverged data)
 * - Perfect for dev/test/staging environments
 * - Enables safe experimentation
 * - Simplifies backup and recovery
 * 
 *******************************************************************************/
