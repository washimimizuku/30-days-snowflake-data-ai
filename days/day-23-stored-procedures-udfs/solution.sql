/*******************************************************************************
 * Day 23: Stored Procedures & User-Defined Functions - SOLUTIONS
 * 
 * Complete solutions for all exercises
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
  performance_score INT,
  bonus DECIMAL(10,2) DEFAULT 0
);

INSERT INTO employees VALUES
  (1001, 'John', 'Doe', 'Sales', 60000, '2020-01-15', 85, 0),
  (1002, 'Jane', 'Smith', 'Engineering', 80000, '2019-03-20', 92, 0),
  (1003, 'Bob', 'Johnson', 'Sales', 55000, '2021-06-10', 78, 0),
  (1004, 'Alice', 'Williams', 'Engineering', 85000, '2018-11-05', 95, 0),
  (1005, 'Charlie', 'Brown', 'Marketing', 50000, '2022-02-14', 88, 0);

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
 * Exercise 1: JavaScript Stored Procedures - SOLUTIONS
 *******************************************************************************/

-- Solution 1.1: Calculate employee bonuses
CREATE OR REPLACE PROCEDURE calculate_employee_bonuses()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
  var result_summary = {
    total_employees: 0,
    total_bonus: 0,
    high_performers: 0
  };
  
  // Query all employees
  var query = "SELECT employee_id, salary, performance_score FROM employees";
  var stmt = snowflake.createStatement({sqlText: query});
  var resultSet = stmt.execute();
  
  // Process each employee
  while (resultSet.next()) {
    var emp_id = resultSet.getColumnValue(1);
    var salary = resultSet.getColumnValue(2);
    var score = resultSet.getColumnValue(3);
    
    // Calculate bonus based on performance
    var bonus_rate = 0.05;  // Default 5%
    if (score >= 90) {
      bonus_rate = 0.15;
      result_summary.high_performers++;
    } else if (score >= 80) {
      bonus_rate = 0.10;
    }
    
    var bonus = salary * bonus_rate;
    result_summary.total_bonus += bonus;
    result_summary.total_employees++;
    
    // Update employee bonus
    var update_sql = `UPDATE employees SET bonus = ${bonus} WHERE employee_id = ${emp_id}`;
    snowflake.createStatement({sqlText: update_sql}).execute();
  }
  
  return `Processed ${result_summary.total_employees} employees. ` +
         `Total bonuses: $${result_summary.total_bonus.toFixed(2)}. ` +
         `High performers: ${result_summary.high_performers}`;
$$;

-- Test
CALL calculate_employee_bonuses();
SELECT employee_id, first_name, salary, performance_score, bonus FROM employees;

-- Solution 1.2: Generate sales report
CREATE OR REPLACE PROCEDURE generate_sales_report(emp_id INT)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
  // Get employee info
  var emp_query = `SELECT first_name, last_name, department FROM employees WHERE employee_id = ${EMP_ID}`;
  var emp_stmt = snowflake.createStatement({sqlText: emp_query});
  var emp_result = emp_stmt.execute();
  
  if (!emp_result.next()) {
    return "Employee not found";
  }
  
  var first_name = emp_result.getColumnValue(1);
  var last_name = emp_result.getColumnValue(2);
  var department = emp_result.getColumnValue(3);
  
  // Get sales data
  var sales_query = `
    SELECT COUNT(*) as sale_count, SUM(amount) as total_sales, AVG(amount) as avg_sale
    FROM sales WHERE employee_id = ${EMP_ID}
  `;
  var sales_stmt = snowflake.createStatement({sqlText: sales_query});
  var sales_result = sales_stmt.execute();
  sales_result.next();
  
  var sale_count = sales_result.getColumnValue(1);
  var total_sales = sales_result.getColumnValue(2) || 0;
  var avg_sale = sales_result.getColumnValue(3) || 0;
  
  // Format report
  var report = `
=== SALES REPORT ===
Employee: ${first_name} ${last_name} (ID: ${EMP_ID})
Department: ${department}
Total Sales: $${total_sales.toFixed(2)}
Number of Sales: ${sale_count}
Average Sale: $${avg_sale.toFixed(2)}
==================
  `;
  
  return report;
$$;

-- Test
CALL generate_sales_report(1001);
CALL generate_sales_report(1002);

-- Solution 1.3: Batch processing with loops
CREATE OR REPLACE PROCEDURE process_employees_batch()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
  var batch_size = 2;
  var total_processed = 0;
  var offset = 0;
  
  while (true) {
    // Get batch of employees
    var query = `
      SELECT employee_id, salary 
      FROM employees 
      ORDER BY employee_id 
      LIMIT ${batch_size} OFFSET ${offset}
    `;
    
    var stmt = snowflake.createStatement({sqlText: query});
    var result = stmt.execute();
    
    var batch_count = 0;
    while (result.next()) {
      var emp_id = result.getColumnValue(1);
      var salary = result.getColumnValue(2);
      
      // Process employee (example: add status column)
      var update_sql = `
        UPDATE employees 
        SET bonus = bonus + 100 
        WHERE employee_id = ${emp_id}
      `;
      snowflake.createStatement({sqlText: update_sql}).execute();
      
      batch_count++;
      total_processed++;
    }
    
    // Exit if no more records
    if (batch_count == 0) {
      break;
    }
    
    offset += batch_size;
  }
  
  return `Processed ${total_processed} employees in batches of ${batch_size}`;
$$;

-- Test
CALL process_employees_batch();

/*******************************************************************************
 * Exercise 2: SQL Stored Procedures - SOLUTIONS
 *******************************************************************************/

-- Solution 2.1: Simple SQL procedure
CREATE OR REPLACE PROCEDURE update_senior_departments()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  UPDATE employees
  SET department = 'Senior ' || department
  WHERE salary > 75000
    AND department NOT LIKE 'Senior%';
  
  RETURN 'Updated ' || SQLROWCOUNT || ' employees to senior departments';
END;
$$;

-- Test
CALL update_senior_departments();
SELECT employee_id, first_name, department, salary FROM employees;

-- Reset for next tests
UPDATE employees SET department = REPLACE(department, 'Senior ', '');

-- Solution 2.2: ETL procedure with transactions
CREATE OR REPLACE PROCEDURE run_employee_etl()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  rows_loaded INT;
  rows_validated INT;
  error_msg STRING;
BEGIN
  -- Step 1: Create staging table
  CREATE OR REPLACE TEMPORARY TABLE staging_employees (
    employee_id INT,
    first_name STRING,
    last_name STRING,
    department STRING,
    salary DECIMAL(10,2),
    hire_date DATE,
    performance_score INT
  );
  
  -- Step 2: Load data (simulated)
  INSERT INTO staging_employees
  SELECT employee_id, first_name, last_name, department, salary, hire_date, performance_score
  FROM employees;
  
  rows_loaded := SQLROWCOUNT;
  
  -- Step 3: Data validation
  DELETE FROM staging_employees
  WHERE salary < 0 OR performance_score < 0 OR performance_score > 100;
  
  rows_validated := rows_loaded - SQLROWCOUNT;
  
  -- Step 4: Merge to production
  MERGE INTO employees e
  USING staging_employees s
  ON e.employee_id = s.employee_id
  WHEN MATCHED THEN
    UPDATE SET 
      first_name = s.first_name,
      last_name = s.last_name,
      department = s.department,
      salary = s.salary,
      performance_score = s.performance_score
  WHEN NOT MATCHED THEN
    INSERT VALUES (
      s.employee_id, s.first_name, s.last_name, s.department,
      s.salary, s.hire_date, s.performance_score, 0
    );
  
  RETURN 'ETL completed. Loaded: ' || rows_loaded || ', Validated: ' || rows_validated;
  
EXCEPTION
  WHEN OTHER THEN
    error_msg := SQLERRM;
    RETURN 'ETL failed: ' || error_msg;
END;
$$;

-- Test
CALL run_employee_etl();

-- Solution 2.3: Procedure with conditional logic
CREATE OR REPLACE PROCEDURE categorize_employees_by_tenure()
RETURNS TABLE(employee_id INT, name STRING, tenure_category STRING, years_of_service FLOAT)
LANGUAGE SQL
AS
$$
DECLARE
  res RESULTSET;
BEGIN
  res := (
    SELECT 
      employee_id,
      first_name || ' ' || last_name as name,
      CASE 
        WHEN DATEDIFF(year, hire_date, CURRENT_DATE()) < 1 THEN 'New'
        WHEN DATEDIFF(year, hire_date, CURRENT_DATE()) BETWEEN 1 AND 3 THEN 'Intermediate'
        ELSE 'Senior'
      END as tenure_category,
      DATEDIFF(day, hire_date, CURRENT_DATE()) / 365.25 as years_of_service
    FROM employees
    ORDER BY years_of_service DESC
  );
  RETURN TABLE(res);
END;
$$;

-- Test
CALL categorize_employees_by_tenure();

/*******************************************************************************
 * Exercise 3: Scalar UDFs - SOLUTIONS
 *******************************************************************************/

-- Solution 3.1: SQL UDF for full name
CREATE OR REPLACE FUNCTION full_name(first STRING, last STRING)
RETURNS STRING
AS
$$
  INITCAP(first) || ' ' || INITCAP(last)
$$;

-- Test
SELECT employee_id, full_name(first_name, last_name) as name FROM employees;

-- Solution 3.2: JavaScript UDF for tax calculation
CREATE OR REPLACE FUNCTION calculate_tax(salary FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
AS
$$
  if (SALARY <= 50000) {
    return SALARY * 0.10;
  } else if (SALARY <= 80000) {
    return 50000 * 0.10 + (SALARY - 50000) * 0.15;
  } else {
    return 50000 * 0.10 + 30000 * 0.15 + (SALARY - 80000) * 0.20;
  }
$$;

-- Test
SELECT 
  employee_id,
  full_name(first_name, last_name) as name,
  salary,
  calculate_tax(salary) as tax,
  salary - calculate_tax(salary) as net_salary
FROM employees;

-- Solution 3.3: UDF for years of service
CREATE OR REPLACE FUNCTION years_of_service(hire_date DATE)
RETURNS FLOAT
AS
$$
  DATEDIFF(day, hire_date, CURRENT_DATE()) / 365.25
$$;

-- Test
SELECT 
  employee_id,
  full_name(first_name, last_name) as name,
  hire_date,
  ROUND(years_of_service(hire_date), 2) as years_service
FROM employees;

-- Solution 3.4: UDF for email generation
CREATE OR REPLACE FUNCTION generate_email(first_name STRING, last_name STRING)
RETURNS STRING
AS
$$
  LOWER(first_name) || '.' || LOWER(last_name) || '@company.com'
$$;

-- Test
SELECT 
  employee_id,
  full_name(first_name, last_name) as name,
  generate_email(first_name, last_name) as email
FROM employees;

/*******************************************************************************
 * Exercise 4: Table Functions (UDTFs) - SOLUTIONS
 *******************************************************************************/

-- Solution 4.1: UDTF to split comma-separated values
CREATE OR REPLACE FUNCTION split_csv(input STRING)
RETURNS TABLE(value STRING)
LANGUAGE JAVASCRIPT
AS
$$
{
  processRow: function(row, rowWriter, context) {
    var parts = row.INPUT.split(',');
    for (var i = 0; i < parts.length; i++) {
      rowWriter.writeRow({VALUE: parts[i].trim()});
    }
  }
}
$$;

-- Test
SELECT * FROM TABLE(split_csv('apple,banana,orange'));
SELECT * FROM TABLE(split_csv('Sales,Engineering,Marketing'));

-- Solution 4.2: UDTF to generate date range
CREATE OR REPLACE FUNCTION date_range(start_date DATE, end_date DATE)
RETURNS TABLE(date_value DATE)
LANGUAGE JAVASCRIPT
AS
$$
{
  processRow: function(row, rowWriter, context) {
    var start = new Date(row.START_DATE);
    var end = new Date(row.END_DATE);
    
    var current = new Date(start);
    while (current <= end) {
      rowWriter.writeRow({DATE_VALUE: current.toISOString().split('T')[0]});
      current.setDate(current.getDate() + 1);
    }
  }
}
$$;

-- Test
SELECT * FROM TABLE(date_range('2024-01-01'::DATE, '2024-01-10'::DATE));

-- Solution 4.3: UDTF to explode array
CREATE OR REPLACE FUNCTION explode_array(arr ARRAY)
RETURNS TABLE(element VARIANT)
LANGUAGE JAVASCRIPT
AS
$$
{
  processRow: function(row, rowWriter, context) {
    var array = row.ARR;
    for (var i = 0; i < array.length; i++) {
      rowWriter.writeRow({ELEMENT: array[i]});
    }
  }
}
$$;

-- Test
SELECT * FROM TABLE(explode_array(ARRAY_CONSTRUCT('A', 'B', 'C')));
SELECT * FROM TABLE(explode_array(ARRAY_CONSTRUCT(1, 2, 3, 4, 5)));

/*******************************************************************************
 * Exercise 5: Python UDFs - SOLUTIONS
 *******************************************************************************/

-- Solution 5.1: Python UDF for text analysis
CREATE OR REPLACE FUNCTION word_count(text STRING)
RETURNS INT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'count_words'
AS
$$
def count_words(text):
    if text is None:
        return 0
    return len(text.split())
$$;

-- Test
SELECT 
  'Hello world this is a test' as text,
  word_count('Hello world this is a test') as words;

SELECT 
  department,
  word_count(department) as word_count
FROM employees;

-- Solution 5.2: Python UDF for email validation
CREATE OR REPLACE FUNCTION is_valid_email(email STRING)
RETURNS BOOLEAN
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'validate_email'
AS
$$
def validate_email(email):
    if email is None:
        return False
    return '@' in email and '.' in email.split('@')[-1]
$$;

-- Test
SELECT 
  'test@example.com' as email,
  is_valid_email('test@example.com') as is_valid
UNION ALL
SELECT 
  'invalid.email' as email,
  is_valid_email('invalid.email') as is_valid
UNION ALL
SELECT 
  'another@test' as email,
  is_valid_email('another@test') as is_valid;

-- Solution 5.3: Python UDF for standard deviation
CREATE OR REPLACE FUNCTION std_dev(values ARRAY)
RETURNS FLOAT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'calculate_std_dev'
AS
$$
def calculate_std_dev(values):
    if not values or len(values) == 0:
        return None
    
    n = len(values)
    mean = sum(values) / n
    variance = sum((x - mean) ** 2 for x in values) / n
    return variance ** 0.5
$$;

-- Test
SELECT std_dev(ARRAY_CONSTRUCT(1, 2, 3, 4, 5)) as std_deviation;
SELECT std_dev(ARRAY_CONSTRUCT(10, 20, 30, 40, 50)) as std_deviation;

-- Test with employee salaries
SELECT 
  department,
  ARRAY_AGG(salary) as salaries,
  std_dev(ARRAY_AGG(salary)) as salary_std_dev
FROM employees
GROUP BY department;

/*******************************************************************************
 * Exercise 6: Secure Functions - SOLUTIONS
 *******************************************************************************/

-- Solution 6.1: Secure UDF for commission calculation
CREATE OR REPLACE SECURE FUNCTION calculate_commission(sales_amount FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
COMMENT = 'Calculates commission based on proprietary formula'
AS
$$
  // Proprietary commission logic (hidden from users)
  if (SALES_AMOUNT < 5000) {
    return SALES_AMOUNT * 0.05;
  } else if (SALES_AMOUNT < 10000) {
    return 250 + (SALES_AMOUNT - 5000) * 0.08;
  } else if (SALES_AMOUNT < 20000) {
    return 650 + (SALES_AMOUNT - 10000) * 0.10;
  } else {
    return 1650 + (SALES_AMOUNT - 20000) * 0.12;
  }
$$;

-- Test (users can call but can't see the formula)
SELECT 
  employee_id,
  SUM(amount) as total_sales,
  calculate_commission(SUM(amount)) as commission
FROM sales
GROUP BY employee_id;

-- Solution 6.2: Secure UDF for pricing algorithm
CREATE OR REPLACE SECURE FUNCTION calculate_price(
  base_price FLOAT,
  customer_tier STRING,
  quantity INT
)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
COMMENT = 'Proprietary pricing algorithm'
AS
$$
  // Base price adjustments (proprietary logic)
  var tier_discount = 0;
  if (CUSTOMER_TIER === 'PLATINUM') tier_discount = 0.20;
  else if (CUSTOMER_TIER === 'GOLD') tier_discount = 0.15;
  else if (CUSTOMER_TIER === 'SILVER') tier_discount = 0.10;
  else tier_discount = 0.05;
  
  // Volume discount
  var volume_discount = 0;
  if (QUANTITY >= 100) volume_discount = 0.10;
  else if (QUANTITY >= 50) volume_discount = 0.05;
  
  // Calculate final price
  var price_after_tier = BASE_PRICE * (1 - tier_discount);
  var final_price = price_after_tier * (1 - volume_discount);
  
  return final_price * QUANTITY;
$$;

-- Test
SELECT 
  calculate_price(100, 'PLATINUM', 10) as platinum_price,
  calculate_price(100, 'GOLD', 10) as gold_price,
  calculate_price(100, 'SILVER', 10) as silver_price,
  calculate_price(100, 'BRONZE', 10) as bronze_price;

/*******************************************************************************
 * Exercise 7: Error Handling - SOLUTIONS
 *******************************************************************************/

-- Solution 7.1: Procedure with exception handling
CREATE OR REPLACE PROCEDURE safe_divide(numerator FLOAT, denominator FLOAT)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  result FLOAT;
  error_msg STRING;
BEGIN
  IF (denominator = 0) THEN
    RETURN 'Error: Division by zero';
  END IF;
  
  result := numerator / denominator;
  RETURN 'Result: ' || result::STRING;
  
EXCEPTION
  WHEN OTHER THEN
    error_msg := SQLERRM;
    RETURN 'Error occurred: ' || error_msg;
END;
$$;

-- Test
CALL safe_divide(10, 2);   -- Success
CALL safe_divide(10, 0);   -- Handled error

-- Solution 7.2: Procedure that logs errors
CREATE OR REPLACE TABLE error_log (
  error_time TIMESTAMP,
  procedure_name STRING,
  error_message STRING,
  error_details STRING
);

CREATE OR REPLACE PROCEDURE process_with_logging(table_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  error_msg STRING;
  rows_affected INT;
BEGIN
  -- Attempt to process table
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || table_name;
  rows_affected := SQLROWCOUNT;
  
  RETURN 'Successfully processed ' || table_name || '. Rows: ' || rows_affected;
  
EXCEPTION
  WHEN STATEMENT_ERROR THEN
    error_msg := SQLERRM;
    
    -- Log the error
    INSERT INTO error_log VALUES (
      CURRENT_TIMESTAMP(),
      'process_with_logging',
      'Statement error',
      error_msg
    );
    
    RETURN 'Error logged: ' || error_msg;
    
  WHEN OTHER THEN
    error_msg := SQLERRM;
    
    -- Log the error
    INSERT INTO error_log VALUES (
      CURRENT_TIMESTAMP(),
      'process_with_logging',
      'Unknown error',
      error_msg
    );
    
    RETURN 'Unknown error logged: ' || error_msg;
END;
$$;

-- Test
CALL process_with_logging('employees');           -- Success
CALL process_with_logging('non_existent_table');  -- Error logged

-- View error log
SELECT * FROM error_log;

/*******************************************************************************
 * Bonus Challenges - SOLUTIONS
 *******************************************************************************/

-- BONUS 1: Recursive procedure for factorial
CREATE OR REPLACE FUNCTION factorial(n INT)
RETURNS INT
LANGUAGE JAVASCRIPT
AS
$$
  if (N <= 1) return 1;
  return N * factorial(N - 1);
$$;

-- Test
SELECT factorial(5) as result;  -- 120
SELECT factorial(10) as result; -- 3628800

-- BONUS 2: Memoizable Fibonacci UDF
CREATE OR REPLACE FUNCTION fibonacci(n INT)
RETURNS INT
LANGUAGE JAVASCRIPT
MEMOIZABLE
AS
$$
  if (N <= 1) return N;
  return fibonacci(N - 1) + fibonacci(N - 2);
$$;

-- Test
SELECT fibonacci(10) as result;  -- 55
SELECT fibonacci(20) as result;  -- 6765

-- BONUS 3: Orchestration procedure
CREATE OR REPLACE PROCEDURE run_daily_maintenance()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  result STRING;
  total_message STRING DEFAULT '';
BEGIN
  -- Step 1: Calculate bonuses
  CALL calculate_employee_bonuses();
  total_message := total_message || 'Bonuses calculated. ';
  
  -- Step 2: Update departments
  CALL update_senior_departments();
  total_message := total_message || 'Departments updated. ';
  
  -- Step 3: Run ETL
  CALL run_employee_etl();
  total_message := total_message || 'ETL completed. ';
  
  RETURN 'Daily maintenance completed: ' || total_message;
  
EXCEPTION
  WHEN OTHER THEN
    RETURN 'Maintenance failed: ' || SQLERRM;
END;
$$;

-- Test
CALL run_daily_maintenance();

-- BONUS 4: UDF with external packages
CREATE OR REPLACE FUNCTION calculate_statistics(values ARRAY)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('numpy', 'scipy')
HANDLER = 'calc_stats'
AS
$$
import numpy as np
from scipy import stats

def calc_stats(values):
    if not values:
        return None
    
    arr = np.array(values)
    
    return {
        'mean': float(np.mean(arr)),
        'median': float(np.median(arr)),
        'std_dev': float(np.std(arr)),
        'min': float(np.min(arr)),
        'max': float(np.max(arr)),
        'skewness': float(stats.skew(arr)),
        'kurtosis': float(stats.kurtosis(arr))
    }
$$;

-- Test
SELECT calculate_statistics(ARRAY_CONSTRUCT(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)) as stats;

-- Test with employee salaries
SELECT 
  department,
  calculate_statistics(ARRAY_AGG(salary)) as salary_stats
FROM employees
GROUP BY department;

/*******************************************************************************
 * Comprehensive Testing
 *******************************************************************************/

-- Test all UDFs together
SELECT 
  employee_id,
  full_name(first_name, last_name) as name,
  generate_email(first_name, last_name) as email,
  department,
  salary,
  calculate_tax(salary) as tax,
  ROUND(years_of_service(hire_date), 2) as years_service,
  performance_score,
  bonus
FROM employees;

-- Test with sales data
SELECT 
  e.employee_id,
  full_name(e.first_name, e.last_name) as name,
  SUM(s.amount) as total_sales,
  calculate_commission(SUM(s.amount)) as commission
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name;

-- Test UDTFs
SELECT 
  d.value as department_name,
  COUNT(e.employee_id) as employee_count
FROM TABLE(split_csv('Sales,Engineering,Marketing')) d
LEFT JOIN employees e ON e.department = d.value
GROUP BY d.value;

/*******************************************************************************
 * Performance Comparison
 *******************************************************************************/

-- Compare SQL UDF vs inline calculation
-- SQL UDF
SELECT 
  employee_id,
  full_name(first_name, last_name) as name
FROM employees;

-- Inline
SELECT 
  employee_id,
  first_name || ' ' || last_name as name
FROM employees;

-- Check query history for performance
SELECT 
  query_text,
  total_elapsed_time / 1000 as elapsed_seconds
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%full_name%'
  OR query_text ILIKE '%first_name || %'
ORDER BY start_time DESC
LIMIT 5;

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
 * Summary
 * 
 * In this lab, you learned:
 * 
 * 1. JavaScript Stored Procedures
 *    - Complex logic with loops and conditionals
 *    - DML operations
 *    - Dynamic SQL execution
 * 
 * 2. SQL Stored Procedures
 *    - Simpler syntax for SQL-only logic
 *    - Transaction management
 *    - Exception handling
 * 
 * 3. Scalar UDFs
 *    - SQL UDFs for simple calculations
 *    - JavaScript UDFs for complex logic
 *    - Python UDFs for advanced processing
 * 
 * 4. Table Functions (UDTFs)
 *    - Return multiple rows
 *    - Useful for data transformation
 *    - Can be used in FROM clause
 * 
 * 5. Secure Functions
 *    - Hide proprietary logic
 *    - Protect intellectual property
 *    - Users can call but can't see implementation
 * 
 * 6. Error Handling
 *    - Exception handling in procedures
 *    - Error logging
 *    - Graceful failure
 * 
 * 7. Best Practices
 *    - Choose the right tool for the job
 *    - Minimize SQL calls in procedures
 *    - Use batch operations
 *    - Implement error handling
 *    - Document your code
 *    - Test thoroughly
 * 
 *******************************************************************************/
