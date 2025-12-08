/*******************************************************************************
 * Day 23: Stored Procedures & User-Defined Functions (UDFs)
 * 
 * Time: 40 minutes
 * 
 * Exercises:
 * 1. JavaScript Stored Procedures (8 min)
 * 2. SQL Stored Procedures (6 min)
 * 3. Scalar UDFs (6 min)
 * 4. Table Functions (UDTFs) (6 min)
 * 5. Python UDFs (6 min)
 * 6. Secure Functions (4 min)
 * 7. Error Handling (4 min)
 * 
 *******************************************************************************/

-- Setup
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE udf_lab;
USE DATABASE udf_lab;
USE SCHEMA public;

CREATE OR REPLACE WAREHOUSE udf_wh 
  WAREHOUSE_SIZE = 'XSMALL' 
  AUTO_SUSPEND = 60 
  AUTO_RESUME = TRUE;

USE WAREHOUSE udf_wh;

-- Create sample data
CREATE OR REPLACE TABLE employees (
  employee_id INT,
  first_name STRING,
  last_name STRING,
  department STRING,
  salary DECIMAL(10,2),
  hire_date DATE,
  performance_score INT
);

INSERT INTO employees VALUES
  (1001, 'John', 'Doe', 'Sales', 60000, '2020-01-15', 85),
  (1002, 'Jane', 'Smith', 'Engineering', 80000, '2019-03-20', 92),
  (1003, 'Bob', 'Johnson', 'Sales', 55000, '2021-06-10', 78),
  (1004, 'Alice', 'Williams', 'Engineering', 85000, '2018-11-05', 95),
  (1005, 'Charlie', 'Brown', 'Marketing', 50000, '2022-02-14', 88);

CREATE OR REPLACE TABLE sales (
  sale_id INT,
  employee_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING
);

INSERT INTO sales VALUES
  (1, 1001, '2024-01-10', 5000, 'NORTH'),
  (2, 1001, '2024-01-15', 7500, 'NORTH'),
  (3, 1003, '2024-01-12', 3000, 'SOUTH'),
  (4, 1003, '2024-01-18', 4500, 'SOUTH'),
  (5, 1001, '2024-01-20', 6000, 'NORTH');

/*******************************************************************************
 * Exercise 1: JavaScript Stored Procedures (8 min)
 * 
 * Create procedures with complex logic using JavaScript.
 *******************************************************************************/

-- TODO 1.1: Create a procedure to calculate employee bonuses
-- Bonus rules:
-- - Performance score >= 90: 15% of salary
-- - Performance score >= 80: 10% of salary
-- - Performance score < 80: 5% of salary
-- The procedure should update a bonus column and return summary


-- TODO 1.2: Create a procedure to generate a sales report
-- The procedure should:
-- - Accept employee_id as parameter
-- - Calculate total sales for the employee
-- - Return formatted report string


-- TODO 1.3: Create a procedure with loops
-- Create a procedure that processes records in batches
-- Use a loop to iterate through employees and update their status


/*******************************************************************************
 * Exercise 2: SQL Stored Procedures (6 min)
 * 
 * Build ETL orchestration procedures using SQL.
 *******************************************************************************/

-- TODO 2.1: Create a simple SQL procedure
-- Create a procedure that updates employee departments based on salary
-- High earners (>75000) go to 'Senior' + department


-- TODO 2.2: Create an ETL procedure with transactions
-- Create a procedure that:
-- - Creates a staging table
-- - Loads data
-- - Validates data
-- - Merges to production
-- - Handles errors


-- TODO 2.3: Create a procedure with conditional logic
-- Create a procedure that categorizes employees by tenure
-- < 1 year: 'New', 1-3 years: 'Intermediate', > 3 years: 'Senior'


/*******************************************************************************
 * Exercise 3: Scalar UDFs (6 min)
 * 
 * Create custom functions for calculations.
 *******************************************************************************/

-- TODO 3.1: Create a SQL UDF for full name
-- Combine first_name and last_name with proper formatting


-- TODO 3.2: Create a JavaScript UDF for tax calculation
-- Calculate tax based on salary brackets:
-- 0-50000: 10%, 50001-80000: 15%, >80000: 20%


-- TODO 3.3: Create a UDF to calculate years of service
-- Calculate years between hire_date and current date


-- TODO 3.4: Create a UDF for email generation
-- Generate email: firstname.lastname@company.com (lowercase)


/*******************************************************************************
 * Exercise 4: Table Functions (UDTFs) (6 min)
 * 
 * Build functions that return multiple rows.
 *******************************************************************************/

-- TODO 4.1: Create a UDTF to split comma-separated values
-- Input: 'apple,banana,orange'
-- Output: Three rows with each fruit


-- TODO 4.2: Create a UDTF to generate date range
-- Input: start_date, end_date
-- Output: All dates in the range


-- TODO 4.3: Create a UDTF to explode array
-- Input: ARRAY['A', 'B', 'C']
-- Output: Three rows with each element


/*******************************************************************************
 * Exercise 5: Python UDFs (6 min)
 * 
 * Implement complex data processing with Python.
 *******************************************************************************/

-- TODO 5.1: Create a Python UDF for text analysis
-- Count words in a string


-- TODO 5.2: Create a Python UDF for data validation
-- Validate email format (simple check)


-- TODO 5.3: Create a Python UDF for statistical calculation
-- Calculate standard deviation of an array


/*******************************************************************************
 * Exercise 6: Secure Functions (4 min)
 * 
 * Protect proprietary logic with secure functions.
 *******************************************************************************/

-- TODO 6.1: Create a secure UDF for commission calculation
-- Hide the commission formula from users


-- TODO 6.2: Create a secure UDF for pricing algorithm
-- Implement proprietary pricing logic


/*******************************************************************************
 * Exercise 7: Error Handling (4 min)
 * 
 * Implement robust error handling.
 *******************************************************************************/

-- TODO 7.1: Create a procedure with exception handling
-- Handle division by zero and other errors


-- TODO 7.2: Create a procedure that logs errors
-- Create error_log table and log all errors


/*******************************************************************************
 * Testing
 *******************************************************************************/

-- Test your procedures and functions here

-- Test bonus calculation
-- CALL calculate_employee_bonuses();

-- Test UDFs
-- SELECT employee_id, full_name(first_name, last_name) FROM employees;

-- Test UDTF
-- SELECT * FROM TABLE(split_csv('apple,banana,orange'));

/*******************************************************************************
 * Bonus Challenges (Optional)
 *******************************************************************************/

-- BONUS 1: Create a recursive procedure
-- Calculate factorial using recursion


-- BONUS 2: Create a memoizable UDF
-- Implement Fibonacci with memoization


-- BONUS 3: Create a procedure that calls other procedures
-- Build an orchestration procedure


-- BONUS 4: Create a UDF with external packages
-- Use Python packages for advanced calculations


/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS udf_lab CASCADE;
DROP WAREHOUSE IF EXISTS udf_wh;
*/

/*******************************************************************************
 * Key Takeaways
 * 
 * 1. Stored procedures can perform DML operations
 * 2. UDFs return values and cannot perform DML
 * 3. JavaScript provides most flexibility
 * 4. SQL procedures are simpler for SQL-only logic
 * 5. Python UDFs enable complex data processing
 * 6. Secure UDFs hide implementation details
 * 7. Always implement error handling
 * 8. Choose the right tool for the job
 * 9. Test thoroughly before production use
 * 10. Document your procedures and functions
 * 
 *******************************************************************************/
