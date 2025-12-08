/*******************************************************************************
 * Day 20: Cloning & Zero-Copy Cloning
 * 
 * Time: 40 minutes
 * 
 * Exercises:
 * 1. Basic Cloning (5 min)
 * 2. Clone with Time Travel (5 min)
 * 3. Development Environment (10 min)
 * 4. Schema Migration Testing (5 min)
 * 5. Data Recovery (5 min)
 * 6. Storage Analysis (5 min)
 * 7. Automated Backup (5 min)
 * 
 * Instructions:
 * - Complete each TODO section
 * - Test your queries before moving to the next exercise
 * - Check solution.sql if you get stuck
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
 * Exercise 1: Basic Cloning (5 min)
 * 
 * Learn to clone tables, schemas, and databases.
 *******************************************************************************/

-- TODO 1.1: Clone the customers table
-- Create a clone named 'customers_clone'


-- TODO 1.2: Verify the clone was created
-- Show tables and check row count


-- TODO 1.3: Modify the clone (insert a new customer)
-- Add customer_id=6, name='Frank Miller', email='frank@email.com', 
-- region='SOUTH', signup_date='2024-01-15', total_purchases=0


-- TODO 1.4: Verify source table is unchanged
-- Select from both tables and compare


-- TODO 1.5: Clone the entire schema
-- Create a schema clone named 'public_backup'


-- TODO 1.6: Verify schema clone
-- Show tables in the cloned schema


/*******************************************************************************
 * Exercise 2: Clone with Time Travel (5 min)
 * 
 * Combine cloning with Time Travel for point-in-time copies.
 *******************************************************************************/

-- Setup: Make some changes to track
UPDATE customers SET total_purchases = total_purchases + 1000 WHERE customer_id = 1;
DELETE FROM orders WHERE order_id = 105;

-- Wait a moment for changes to be committed
SELECT SYSTEM$WAIT(5);

-- TODO 2.1: Get the query ID of the DELETE statement
-- Query the query history to find the DELETE statement


-- TODO 2.2: Clone orders table from before the DELETE
-- Create 'orders_before_delete' clone using BEFORE clause


-- TODO 2.3: Verify the deleted row exists in the clone


-- TODO 2.4: Clone customers table from 1 minute ago
-- Create 'customers_1min_ago' clone using OFFSET


-- TODO 2.5: Compare current vs. 1 minute ago
-- Show the difference in total_purchases for customer_id=1


/*******************************************************************************
 * Exercise 3: Development Environment (10 min)
 * 
 * Create a complete development environment using clones.
 *******************************************************************************/

-- TODO 3.1: Clone the entire database for development
-- Create 'clone_lab_dev' database


-- TODO 3.2: Verify all tables were cloned
-- List all tables in the dev database


-- TODO 3.3: Grant access to a developer role
-- Create a developer role and grant appropriate privileges
-- (Create role, grant usage on database, grant select on all tables)


-- TODO 3.4: Test modifications in dev environment
-- Switch to dev database and make some changes
-- (Add a new column to customers table, insert test data)


-- TODO 3.5: Verify production is unchanged
-- Switch back to production and verify no changes


-- TODO 3.6: Document the dev environment
-- Add a comment to the dev database explaining its purpose


/*******************************************************************************
 * Exercise 4: Schema Migration Testing (5 min)
 * 
 * Test schema changes safely using clones.
 *******************************************************************************/

-- TODO 4.1: Clone products table for testing
-- Create 'products_test' clone


-- TODO 4.2: Add new columns to the test table
-- Add columns: 'last_updated TIMESTAMP', 'is_active BOOLEAN'


-- TODO 4.3: Populate new columns with default values


-- TODO 4.4: Test queries with new schema
-- Select from products_test and verify new columns work


-- TODO 4.5: If successful, apply changes to production
-- Add the same columns to the original products table
-- (In real scenario, you'd do this after thorough testing)


-- TODO 4.6: Clean up test table


/*******************************************************************************
 * Exercise 5: Data Recovery (5 min)
 * 
 * Use cloning for data recovery scenarios.
 *******************************************************************************/

-- Setup: Simulate accidental data loss
CREATE OR REPLACE TABLE critical_data AS
SELECT * FROM customers;

-- Accidentally delete important data
DELETE FROM critical_data WHERE region = 'NORTH';

-- TODO 5.1: Verify data was deleted
-- Count rows in critical_data


-- TODO 5.2: Get the query ID of the DELETE


-- TODO 5.3: Clone the table from before the delete
-- Create 'critical_data_recovered' clone


-- TODO 5.4: Verify recovered data
-- Count rows where region='NORTH' in the recovered table


-- TODO 5.5: Restore the data to the original table
-- Insert the deleted rows back into critical_data


-- TODO 5.6: Verify restoration
-- Count rows in critical_data to confirm restoration


/*******************************************************************************
 * Exercise 6: Storage Analysis (5 min)
 * 
 * Monitor and analyze clone storage usage.
 *******************************************************************************/

-- TODO 6.1: View storage metrics for all tables
-- Query ACCOUNT_USAGE.TABLE_STORAGE_METRICS
-- Show table_name, active_bytes, clone_group_id, is_clone


-- TODO 6.2: Calculate storage by clone vs. source tables
-- Group by is_clone and sum active_bytes


-- TODO 6.3: Find tables with clone relationships
-- Show tables that share the same clone_group_id


-- TODO 6.4: Identify clones with high storage divergence
-- Find clones where active_bytes is > 50% of source table


-- TODO 6.5: List all clones with their creation date
-- Query ACCOUNT_USAGE.TABLES for clones
-- Show table_name, created, bytes


/*******************************************************************************
 * Exercise 7: Automated Backup (5 min)
 * 
 * Create an automated backup strategy using clones.
 *******************************************************************************/

-- TODO 7.1: Create a stored procedure for daily backups
-- Procedure should:
-- - Accept database name as parameter
-- - Create clone with date suffix (e.g., MYDB_BACKUP_20240115)
-- - Return success message


-- TODO 7.2: Test the backup procedure
-- Call the procedure with 'clone_lab' as parameter


-- TODO 7.3: Verify backup was created
-- Show databases with 'backup' in the name


-- TODO 7.4: Create a procedure to list all backups
-- Procedure should show all databases with '_BACKUP_' in name
-- Include creation date and size


-- TODO 7.5: Create a cleanup procedure
-- Procedure should drop backups older than N days
-- Accept days_to_keep as parameter


-- TODO 7.6: Test the cleanup procedure
-- Call with days_to_keep=7


/*******************************************************************************
 * Bonus Challenges (Optional)
 *******************************************************************************/

-- BONUS 1: Create a clone comparison function
-- Write a procedure that compares two tables (original and clone)
-- and returns the differences


-- BONUS 2: Implement A/B testing with clones
-- Clone customers table twice
-- Apply different discount strategies to each
-- Compare projected revenue


-- BONUS 3: Create a clone lifecycle manager
-- Build a procedure that:
-- - Creates clone with expiration metadata
-- - Automatically drops clones past expiration
-- - Sends alerts before expiration


-- BONUS 4: Build a dev environment refresh procedure
-- Procedure should:
-- - Drop existing dev database
-- - Clone production to dev
-- - Apply dev-specific configurations
-- - Grant appropriate permissions


/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up all objects created in this lab
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS clone_lab CASCADE;
DROP DATABASE IF EXISTS clone_lab_dev CASCADE;
DROP DATABASE IF EXISTS clone_lab_backup_20240115 CASCADE;
DROP ROLE IF EXISTS developer;
*/

/*******************************************************************************
 * Key Takeaways
 * 
 * 1. Zero-copy cloning is instant regardless of data size
 * 2. Clones share micro-partitions initially (no storage cost)
 * 3. Storage increases only when data diverges (copy-on-write)
 * 4. Combine cloning with Time Travel for point-in-time copies
 * 5. Perfect for dev/test environments and backups
 * 6. Clones are independent - changes don't affect source
 * 7. Monitor clone storage to manage costs
 * 8. Clean up unused clones regularly
 * 9. Use clones for safe schema migration testing
 * 10. Automate backup strategies with cloning
 * 
 *******************************************************************************/
