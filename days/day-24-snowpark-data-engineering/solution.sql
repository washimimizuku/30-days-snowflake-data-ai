/*******************************************************************************
 * Day 24: Snowpark for Data Engineering - SOLUTIONS
 * 
 * SQL equivalents to Snowpark operations
 * 
 *******************************************************************************/

-- Setup
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE snowpark_lab;
USE DATABASE snowpark_lab;
USE SCHEMA public;

CREATE OR REPLACE WAREHOUSE snowpark_wh 
  WAREHOUSE_SIZE = 'XSMALL' 
  AUTO_SUSPEND = 60 
  AUTO_RESUME = TRUE;

USE WAREHOUSE snowpark_wh;

-- Create sample data
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  region STRING,
  signup_date DATE
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
  price DECIMAL(10,2)
);

INSERT INTO customers VALUES
  (1, 'John', 'Doe', 'john@email.com', 'NORTH', '2023-01-15'),
  (2, 'Jane', 'Smith', 'jane@email.com', 'SOUTH', '2023-02-20'),
  (3, 'Bob', 'Johnson', 'bob@email.com', 'EAST', '2023-03-10'),
  (4, 'Alice', 'Williams', 'alice@email.com', 'WEST', '2023-04-05'),
  (5, 'Charlie', 'Brown', 'charlie@email.com', 'NORTH', '2023-05-12');

INSERT INTO orders VALUES
  (101, 1, '2024-01-10', 500.00, 'COMPLETED'),
  (102, 2, '2024-01-11', 750.00, 'COMPLETED'),
  (103, 3, '2024-01-12', 1200.00, 'PENDING'),
  (104, 1, '2024-01-13', 300.00, 'COMPLETED'),
  (105, 4, '2024-01-14', 450.00, 'SHIPPED'),
  (106, 1, '2024-01-15', 600.00, 'COMPLETED'),
  (107, 2, '2024-01-16', 800.00, 'COMPLETED'),
  (108, 5, '2024-01-17', 950.00, 'COMPLETED');

INSERT INTO products VALUES
  (1, 'Laptop', 'Electronics', 999.99),
  (2, 'Mouse', 'Electronics', 29.99),
  (3, 'Desk', 'Furniture', 299.99),
  (4, 'Chair', 'Furniture', 199.99),
  (5, 'Monitor', 'Electronics', 399.99);

/*******************************************************************************
 * Exercise 1: DataFrame Basics - SOLUTIONS
 *******************************************************************************/

-- Solution 1.1: Select all customers
-- Snowpark: df = session.table("customers")
SELECT * FROM customers;

-- Solution 1.2: Show first 5 rows
-- Snowpark: df.show(5)
SELECT * FROM customers LIMIT 5;

-- Solution 1.3: Count total customers
-- Snowpark: df.count()
SELECT COUNT(*) as customer_count FROM customers;

-- Solution 1.4: Get schema information
-- Snowpark: df.schema
DESC TABLE customers;
SHOW COLUMNS IN customers;

/*******************************************************************************
 * Exercise 2: Transformations - SOLUTIONS
 *******************************************************************************/

-- Solution 2.1: Filter customers from NORTH region
-- Snowpark: df.filter(col("region") == "NORTH")
SELECT * FROM customers
WHERE region = 'NORTH';

-- Solution 2.2: Select specific columns
-- Snowpark: df.select("customer_id", "first_name", "last_name", "email")
SELECT 
  customer_id,
  first_name,
  last_name,
  email
FROM customers;

-- Solution 2.3: Add a computed column (full_name)
-- Snowpark: df.with_column("full_name", concat(col("first_name"), lit(" "), col("last_name")))
SELECT 
  *,
  first_name || ' ' || last_name as full_name
FROM customers;

-- Solution 2.4: Rename a column
-- Snowpark: df.with_column_renamed("email", "email_address")
SELECT 
  customer_id,
  first_name,
  last_name,
  email as email_address,
  region,
  signup_date
FROM customers;

-- Solution 2.5: Sort by signup_date descending
-- Snowpark: df.sort(col("signup_date").desc())
SELECT * FROM customers
ORDER BY signup_date DESC;

-- Solution 2.6: Add a tier column based on signup date
-- Snowpark: df.with_column("tier", when(col("signup_date") < "2023-03-01", "EARLY").otherwise("REGULAR"))
SELECT 
  *,
  CASE 
    WHEN signup_date < '2023-03-01' THEN 'EARLY'
    ELSE 'REGULAR'
  END as tier
FROM customers;

-- Combined transformation
SELECT 
  customer_id,
  first_name || ' ' || last_name as full_name,
  email as email_address,
  region,
  signup_date,
  CASE 
    WHEN signup_date < '2023-03-01' THEN 'EARLY'
    ELSE 'REGULAR'
  END as tier
FROM customers
WHERE region = 'NORTH'
ORDER BY signup_date DESC;

/*******************************************************************************
 * Exercise 3: Aggregations - SOLUTIONS
 *******************************************************************************/

-- Solution 3.1: Count customers by region
-- Snowpark: df.group_by("region").agg(count("*").alias("customer_count"))
SELECT 
  region,
  COUNT(*) as customer_count
FROM customers
GROUP BY region
ORDER BY customer_count DESC;

-- Solution 3.2: Calculate total and average order amount by customer
-- Snowpark: orders.group_by("customer_id").agg([sum("amount").alias("total"), avg("amount").alias("average")])
SELECT 
  customer_id,
  COUNT(*) as order_count,
  SUM(amount) as total_amount,
  AVG(amount) as average_amount,
  MIN(amount) as min_amount,
  MAX(amount) as max_amount
FROM orders
GROUP BY customer_id
ORDER BY total_amount DESC;

-- Solution 3.3: Count orders by status
-- Snowpark: orders.group_by("status").agg(count("*").alias("order_count"))
SELECT 
  status,
  COUNT(*) as order_count,
  SUM(amount) as total_amount
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- Solution 3.4: Find customers with multiple orders
-- Snowpark: orders.group_by("customer_id").agg(count("*").alias("order_count")).filter(col("order_count") > 1)
SELECT 
  customer_id,
  COUNT(*) as order_count,
  SUM(amount) as total_amount
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY order_count DESC;

/*******************************************************************************
 * Exercise 4: Joins - SOLUTIONS
 *******************************************************************************/

-- Solution 4.1: Inner join customers and orders
-- Snowpark: customers.join(orders, customers["customer_id"] == orders["customer_id"], "inner")
SELECT 
  c.*,
  o.order_id,
  o.order_date,
  o.amount,
  o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- Solution 4.2: Left join to include customers without orders
-- Snowpark: customers.join(orders, customers["customer_id"] == orders["customer_id"], "left")
SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  c.region,
  o.order_id,
  o.amount,
  o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;

-- Solution 4.3: Join and select specific columns
-- Snowpark: customers.join(orders, "customer_id").select(...)
SELECT 
  c.customer_id,
  c.first_name || ' ' || c.last_name as customer_name,
  c.region,
  o.order_id,
  o.order_date,
  o.amount,
  o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;

-- Solution 4.4: Join with aggregation
-- Snowpark: 
-- order_totals = orders.group_by("customer_id").agg(sum("amount").alias("total_purchases"))
-- customers.join(order_totals, "customer_id")

WITH order_totals AS (
  SELECT 
    customer_id,
    COUNT(*) as order_count,
    SUM(amount) as total_purchases,
    AVG(amount) as avg_order_value
  FROM orders
  GROUP BY customer_id
)
SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  c.email,
  c.region,
  c.signup_date,
  COALESCE(ot.order_count, 0) as order_count,
  COALESCE(ot.total_purchases, 0) as total_purchases,
  COALESCE(ot.avg_order_value, 0) as avg_order_value
FROM customers c
LEFT JOIN order_totals ot ON c.customer_id = ot.customer_id
ORDER BY total_purchases DESC;

/*******************************************************************************
 * Exercise 5: ETL Pipeline - SOLUTIONS
 *******************************************************************************/

-- Solution 5.1-5.4: Complete ETL Pipeline
-- This demonstrates what Snowpark would do in a single pipeline

-- Step 1: Calculate customer metrics
WITH customer_metrics AS (
  SELECT 
    customer_id,
    COUNT(*) as order_count,
    SUM(amount) as total_purchases,
    AVG(amount) as avg_order_value,
    MIN(order_date) as first_order_date,
    MAX(order_date) as last_order_date
  FROM orders
  GROUP BY customer_id
),

-- Step 2: Join with customer data
enriched_customers AS (
  SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.first_name || ' ' || c.last_name as full_name,
    c.email,
    c.region,
    c.signup_date,
    COALESCE(cm.order_count, 0) as order_count,
    COALESCE(cm.total_purchases, 0) as total_purchases,
    COALESCE(cm.avg_order_value, 0) as avg_order_value,
    cm.first_order_date,
    cm.last_order_date,
    DATEDIFF(day, c.signup_date, CURRENT_DATE()) as days_since_signup
  FROM customers c
  LEFT JOIN customer_metrics cm ON c.customer_id = cm.customer_id
),

-- Step 3: Add tier classification
final_summary AS (
  SELECT 
    *,
    CASE 
      WHEN total_purchases > 2000 THEN 'PLATINUM'
      WHEN total_purchases > 1000 THEN 'GOLD'
      WHEN total_purchases > 500 THEN 'SILVER'
      ELSE 'BRONZE'
    END as tier,
    CASE 
      WHEN order_count = 0 THEN 'INACTIVE'
      WHEN order_count >= 3 THEN 'FREQUENT'
      ELSE 'OCCASIONAL'
    END as customer_segment,
    CURRENT_TIMESTAMP() as processed_at
  FROM enriched_customers
)

-- Step 4: Create final summary table
SELECT * FROM final_summary
ORDER BY total_purchases DESC;

-- Create the summary table
CREATE OR REPLACE TABLE customer_summary AS
WITH customer_metrics AS (
  SELECT 
    customer_id,
    COUNT(*) as order_count,
    SUM(amount) as total_purchases,
    AVG(amount) as avg_order_value,
    MIN(order_date) as first_order_date,
    MAX(order_date) as last_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  c.first_name || ' ' || c.last_name as full_name,
  c.email,
  c.region,
  c.signup_date,
  COALESCE(cm.order_count, 0) as order_count,
  COALESCE(cm.total_purchases, 0) as total_purchases,
  COALESCE(cm.avg_order_value, 0) as avg_order_value,
  cm.first_order_date,
  cm.last_order_date,
  DATEDIFF(day, c.signup_date, CURRENT_DATE()) as days_since_signup,
  CASE 
    WHEN COALESCE(cm.total_purchases, 0) > 2000 THEN 'PLATINUM'
    WHEN COALESCE(cm.total_purchases, 0) > 1000 THEN 'GOLD'
    WHEN COALESCE(cm.total_purchases, 0) > 500 THEN 'SILVER'
    ELSE 'BRONZE'
  END as tier,
  CASE 
    WHEN COALESCE(cm.order_count, 0) = 0 THEN 'INACTIVE'
    WHEN COALESCE(cm.order_count, 0) >= 3 THEN 'FREQUENT'
    ELSE 'OCCASIONAL'
  END as customer_segment,
  CURRENT_TIMESTAMP() as processed_at
FROM customers c
LEFT JOIN customer_metrics cm ON c.customer_id = cm.customer_id;

-- Verify the summary table
SELECT * FROM customer_summary ORDER BY total_purchases DESC;

-- Summary statistics
SELECT 
  tier,
  customer_segment,
  COUNT(*) as customer_count,
  SUM(total_purchases) as total_revenue,
  AVG(total_purchases) as avg_revenue_per_customer
FROM customer_summary
GROUP BY tier, customer_segment
ORDER BY total_revenue DESC;

/*******************************************************************************
 * Exercise 6: Stored Procedures - SOLUTIONS
 *******************************************************************************/

-- Solution 6.1: Create a SQL stored procedure
-- This simulates what would be deployed from Snowpark Python

CREATE OR REPLACE PROCEDURE calculate_region_metrics(region_name STRING)
RETURNS TABLE(
  metric_name STRING,
  metric_value VARIANT
)
LANGUAGE SQL
AS
$$
DECLARE
  res RESULTSET;
BEGIN
  res := (
    WITH region_data AS (
      SELECT 
        c.customer_id,
        c.region,
        COALESCE(SUM(o.amount), 0) as total_purchases
      FROM customers c
      LEFT JOIN orders o ON c.customer_id = o.customer_id
      WHERE c.region = region_name
      GROUP BY c.customer_id, c.region
    )
    SELECT 
      'Customer Count' as metric_name,
      COUNT(*)::VARIANT as metric_value
    FROM region_data
    UNION ALL
    SELECT 
      'Total Revenue' as metric_name,
      SUM(total_purchases)::VARIANT as metric_value
    FROM region_data
    UNION ALL
    SELECT 
      'Average Revenue per Customer' as metric_name,
      AVG(total_purchases)::VARIANT as metric_value
    FROM region_data
    UNION ALL
    SELECT 
      'Customers with Orders' as metric_name,
      COUNT(CASE WHEN total_purchases > 0 THEN 1 END)::VARIANT as metric_value
    FROM region_data
  );
  RETURN TABLE(res);
END;
$$;

-- Solution 6.2: Call the procedure
CALL calculate_region_metrics('NORTH');
CALL calculate_region_metrics('SOUTH');

-- Create another procedure for ETL refresh
CREATE OR REPLACE PROCEDURE refresh_customer_summary()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  rows_processed INT;
BEGIN
  -- Recreate the summary table
  CREATE OR REPLACE TABLE customer_summary AS
  WITH customer_metrics AS (
    SELECT 
      customer_id,
      COUNT(*) as order_count,
      SUM(amount) as total_purchases,
      AVG(amount) as avg_order_value,
      MIN(order_date) as first_order_date,
      MAX(order_date) as last_order_date
    FROM orders
    GROUP BY customer_id
  )
  SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.first_name || ' ' || c.last_name as full_name,
    c.email,
    c.region,
    c.signup_date,
    COALESCE(cm.order_count, 0) as order_count,
    COALESCE(cm.total_purchases, 0) as total_purchases,
    COALESCE(cm.avg_order_value, 0) as avg_order_value,
    cm.first_order_date,
    cm.last_order_date,
    DATEDIFF(day, c.signup_date, CURRENT_DATE()) as days_since_signup,
    CASE 
      WHEN COALESCE(cm.total_purchases, 0) > 2000 THEN 'PLATINUM'
      WHEN COALESCE(cm.total_purchases, 0) > 1000 THEN 'GOLD'
      WHEN COALESCE(cm.total_purchases, 0) > 500 THEN 'SILVER'
      ELSE 'BRONZE'
    END as tier,
    CASE 
      WHEN COALESCE(cm.order_count, 0) = 0 THEN 'INACTIVE'
      WHEN COALESCE(cm.order_count, 0) >= 3 THEN 'FREQUENT'
      ELSE 'OCCASIONAL'
    END as customer_segment,
    CURRENT_TIMESTAMP() as processed_at
  FROM customers c
  LEFT JOIN customer_metrics cm ON c.customer_id = cm.customer_id;
  
  SELECT COUNT(*) INTO rows_processed FROM customer_summary;
  
  RETURN 'Customer summary refreshed. Processed ' || rows_processed || ' customers.';
END;
$$;

-- Test the refresh procedure
CALL refresh_customer_summary();

/*******************************************************************************
 * Exercise 7: Performance Optimization - SOLUTIONS
 *******************************************************************************/

-- Solution 7.1: Demonstrate lazy evaluation concept
-- In Snowpark, these operations would be chained and executed once

-- Bad: Multiple separate queries (not lazy)
SELECT * FROM customers WHERE region = 'NORTH';
SELECT customer_id, first_name, last_name FROM customers WHERE region = 'NORTH';
SELECT customer_id, first_name, last_name FROM customers WHERE region = 'NORTH' ORDER BY signup_date;

-- Good: Single optimized query (simulating lazy evaluation)
SELECT 
  customer_id,
  first_name,
  last_name
FROM customers
WHERE region = 'NORTH'
ORDER BY signup_date;

-- Solution 7.2: Demonstrate caching
-- In Snowpark: df.cache_result()
-- In SQL: Create a temporary table

-- Create cached result
CREATE OR REPLACE TEMPORARY TABLE cached_customer_summary AS
SELECT * FROM customer_summary;

-- Use cached result multiple times (faster)
SELECT COUNT(*) FROM cached_customer_summary;
SELECT tier, COUNT(*) FROM cached_customer_summary GROUP BY tier;
SELECT region, AVG(total_purchases) FROM cached_customer_summary GROUP BY region;

-- Performance comparison
-- Without caching (queries customer_summary each time)
SELECT COUNT(*) FROM customer_summary;
SELECT tier, COUNT(*) FROM customer_summary GROUP BY tier;

-- With caching (queries temp table)
SELECT COUNT(*) FROM cached_customer_summary;
SELECT tier, COUNT(*) FROM cached_customer_summary GROUP BY tier;

/*******************************************************************************
 * Complete Snowpark Python Example (for reference)
 *******************************************************************************/

/*
# This is how you would write the complete ETL pipeline in Snowpark Python

from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, sum, avg, count, when, lit, current_timestamp, datediff

# Create session
session = Session.builder.configs(connection_parameters).create()

# Read source tables
customers = session.table("customers")
orders = session.table("orders")

# Calculate customer metrics
customer_metrics = orders.group_by("customer_id").agg([
    count("order_id").alias("order_count"),
    sum("amount").alias("total_purchases"),
    avg("amount").alias("avg_order_value"),
    min("order_date").alias("first_order_date"),
    max("order_date").alias("last_order_date")
])

# Join with customer data
enriched = customers.join(customer_metrics, "customer_id", "left")

# Add computed columns
final = enriched.with_column("full_name",
    concat(col("first_name"), lit(" "), col("last_name"))
).with_column("tier",
    when(col("total_purchases") > 2000, lit("PLATINUM"))
    .when(col("total_purchases") > 1000, lit("GOLD"))
    .when(col("total_purchases") > 500, lit("SILVER"))
    .otherwise(lit("BRONZE"))
).with_column("customer_segment",
    when(col("order_count") == 0, lit("INACTIVE"))
    .when(col("order_count") >= 3, lit("FREQUENT"))
    .otherwise(lit("OCCASIONAL"))
).with_column("processed_at", current_timestamp())

# Write to table
final.write.mode("overwrite").save_as_table("customer_summary")

# Show results
final.show()

# Get count
count = final.count()
print(f"Processed {count} customers")

# Close session
session.close()
*/

/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS snowpark_lab CASCADE;
DROP WAREHOUSE IF EXISTS snowpark_wh;
*/

/*******************************************************************************
 * Summary
 * 
 * In this lab, you learned SQL equivalents to Snowpark operations:
 * 
 * 1. DataFrame Basics
 *    - session.table() → SELECT * FROM table
 *    - df.show() → SELECT * LIMIT n
 *    - df.count() → SELECT COUNT(*)
 * 
 * 2. Transformations
 *    - df.filter() → WHERE clause
 *    - df.select() → SELECT columns
 *    - df.with_column() → computed columns
 *    - df.sort() → ORDER BY
 * 
 * 3. Aggregations
 *    - df.group_by().agg() → GROUP BY with aggregates
 * 
 * 4. Joins
 *    - df.join() → JOIN clauses
 * 
 * 5. ETL Pipeline
 *    - Complete data transformation workflow
 *    - Multiple CTEs for complex logic
 * 
 * 6. Stored Procedures
 *    - Deploy reusable data processing logic
 *    - Parameterized queries
 * 
 * 7. Performance Optimization
 *    - Lazy evaluation concept
 *    - Caching with temporary tables
 * 
 * Key Advantages of Snowpark:
 * - Write in familiar languages (Python, Java, Scala)
 * - Leverage Snowflake's compute and optimization
 * - Integrate with ML libraries
 * - Version control and CI/CD for data pipelines
 * - Programmatic workflow orchestration
 * 
 *******************************************************************************/
