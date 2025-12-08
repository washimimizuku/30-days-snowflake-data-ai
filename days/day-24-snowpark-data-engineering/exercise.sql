/*******************************************************************************
 * Day 24: Snowpark for Data Engineering
 * 
 * Time: 40 minutes
 * 
 * Note: Snowpark is primarily a Python framework. These exercises are
 * conceptual and show SQL equivalents to help understand Snowpark operations.
 * 
 * In production, you would write these in Python using the Snowpark API.
 * 
 * Exercises:
 * 1. DataFrame Basics (5 min)
 * 2. Transformations (8 min)
 * 3. Aggregations (7 min)
 * 4. Joins (7 min)
 * 5. ETL Pipeline (8 min)
 * 6. Stored Procedures (3 min)
 * 7. Performance Optimization (2 min)
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

-- Insert sample data
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
 * Exercise 1: DataFrame Basics (5 min)
 * 
 * Understand how Snowpark DataFrames work.
 * 
 * Snowpark Python equivalent:
 * df = session.table("customers")
 * df.show()
 *******************************************************************************/

-- TODO 1.1: Select all customers (equivalent to session.table("customers"))


-- TODO 1.2: Show first 5 rows (equivalent to df.show(5))


-- TODO 1.3: Count total customers (equivalent to df.count())


-- TODO 1.4: Get schema information (equivalent to df.schema)


/*******************************************************************************
 * Exercise 2: Transformations (8 min)
 * 
 * Practice filtering, selecting, and adding columns.
 * 
 * Snowpark Python equivalent:
 * df = df.filter(col("region") == "NORTH")
 * df = df.select("customer_id", "first_name", "last_name")
 *******************************************************************************/

-- TODO 2.1: Filter customers from NORTH region
-- Snowpark: df.filter(col("region") == "NORTH")


-- TODO 2.2: Select specific columns
-- Snowpark: df.select("customer_id", "first_name", "last_name", "email")


-- TODO 2.3: Add a computed column (full_name)
-- Snowpark: df.with_column("full_name", concat(col("first_name"), lit(" "), col("last_name")))


-- TODO 2.4: Rename a column
-- Snowpark: df.with_column_renamed("email", "email_address")


-- TODO 2.5: Sort by signup_date descending
-- Snowpark: df.sort(col("signup_date").desc())


-- TODO 2.6: Add a tier column based on signup date
-- Snowpark: df.with_column("tier", when(col("signup_date") < "2023-03-01", "EARLY").otherwise("REGULAR"))


/*******************************************************************************
 * Exercise 3: Aggregations (7 min)
 * 
 * Group by and aggregate data.
 * 
 * Snowpark Python equivalent:
 * df.group_by("region").agg(count("*").alias("customer_count"))
 *******************************************************************************/

-- TODO 3.1: Count customers by region
-- Snowpark: df.group_by("region").agg(count("*").alias("customer_count"))


-- TODO 3.2: Calculate total and average order amount by customer
-- Snowpark: orders.group_by("customer_id").agg([sum("amount").alias("total"), avg("amount").alias("average")])


-- TODO 3.3: Count orders by status
-- Snowpark: orders.group_by("status").agg(count("*").alias("order_count"))


-- TODO 3.4: Find customers with multiple orders
-- Snowpark: orders.group_by("customer_id").agg(count("*").alias("order_count")).filter(col("order_count") > 1)


/*******************************************************************************
 * Exercise 4: Joins (7 min)
 * 
 * Combine multiple DataFrames.
 * 
 * Snowpark Python equivalent:
 * customers.join(orders, customers["customer_id"] == orders["customer_id"], "inner")
 *******************************************************************************/

-- TODO 4.1: Inner join customers and orders
-- Snowpark: customers.join(orders, customers["customer_id"] == orders["customer_id"], "inner")


-- TODO 4.2: Left join to include customers without orders
-- Snowpark: customers.join(orders, customers["customer_id"] == orders["customer_id"], "left")


-- TODO 4.3: Join and select specific columns
-- Snowpark: customers.join(orders, "customer_id").select(
--   customers["customer_id"], customers["first_name"], orders["order_id"], orders["amount"]
-- )


-- TODO 4.4: Join with aggregation
-- Calculate total purchases per customer
-- Snowpark: 
-- order_totals = orders.group_by("customer_id").agg(sum("amount").alias("total_purchases"))
-- customers.join(order_totals, "customer_id")


/*******************************************************************************
 * Exercise 5: ETL Pipeline (8 min)
 * 
 * Build a complete data pipeline.
 * 
 * Create a customer summary table with:
 * - Customer information
 * - Total purchases
 * - Order count
 * - Customer tier (based on total purchases)
 *******************************************************************************/

-- TODO 5.1: Create the ETL pipeline
-- Step 1: Calculate customer metrics from orders


-- Step 2: Join with customer data


-- Step 3: Add tier classification
-- PLATINUM: > 2000, GOLD: > 1000, SILVER: > 500, BRONZE: <= 500


-- Step 4: Create final summary table


/*******************************************************************************
 * Exercise 6: Stored Procedures (3 min)
 * 
 * Understand how to deploy Snowpark code as stored procedures.
 * 
 * In Python, you would:
 * 1. Define a function
 * 2. Register it with session.sproc.register()
 * 3. Call it with session.call()
 *******************************************************************************/

-- TODO 6.1: Create a SQL stored procedure (simulating Snowpark deployment)
-- This procedure would be created from Python using session.sproc.register()


-- TODO 6.2: Call the procedure


/*******************************************************************************
 * Exercise 7: Performance Optimization (2 min)
 * 
 * Understand Snowpark optimization concepts.
 *******************************************************************************/

-- TODO 7.1: Demonstrate lazy evaluation concept
-- In Snowpark, operations are not executed until .collect(), .show(), or .count()
-- Write queries that would benefit from lazy evaluation


-- TODO 7.2: Demonstrate caching
-- In Snowpark: df.cache_result()
-- Create a temp table to simulate caching


/*******************************************************************************
 * Snowpark Python Code Examples
 * 
 * Below are Python code examples showing how you would actually use Snowpark.
 * These cannot be executed in SQL but are provided for reference.
 *******************************************************************************/

/*
# Example 1: Basic DataFrame Operations
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, sum, avg, when, lit

# Create session
session = Session.builder.configs(connection_parameters).create()

# Read table
df = session.table("customers")

# Filter and select
df = df.filter(col("region") == "NORTH") \
       .select("customer_id", "first_name", "last_name", "email")

# Show results
df.show()

# Example 2: Aggregations
orders = session.table("orders")
summary = orders.group_by("customer_id").agg([
    sum("amount").alias("total_purchases"),
    count("order_id").alias("order_count"),
    avg("amount").alias("avg_order_value")
])

# Example 3: Joins
customers = session.table("customers")
result = customers.join(summary, "customer_id", "left")

# Example 4: Add computed column
result = result.with_column("tier",
    when(col("total_purchases") > 2000, lit("PLATINUM"))
    .when(col("total_purchases") > 1000, lit("GOLD"))
    .when(col("total_purchases") > 500, lit("SILVER"))
    .otherwise(lit("BRONZE"))
)

# Example 5: Write to table
result.write.mode("overwrite").save_as_table("customer_summary")

# Example 6: Stored Procedure
def calculate_metrics(session: Session, region: str) -> str:
    df = session.table("customers").filter(col("region") == region)
    count = df.count()
    return f"Customers in {region}: {count}"

# Register as stored procedure
session.sproc.register(
    func=calculate_metrics,
    name="calculate_metrics",
    packages=["snowflake-snowpark-python"],
    is_permanent=True,
    replace=True
)

# Call procedure
result = session.call("calculate_metrics", "NORTH")

# Example 7: UDF
def calculate_discount(tier: str) -> float:
    discounts = {"PLATINUM": 0.20, "GOLD": 0.15, "SILVER": 0.10, "BRONZE": 0.05}
    return discounts.get(tier, 0.0)

# Register UDF
discount_udf = session.udf.register(
    func=calculate_discount,
    name="calculate_discount",
    is_permanent=True,
    replace=True
)

# Use UDF
df = session.table("customer_summary")
df = df.with_column("discount", discount_udf(col("tier")))
df.show()
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
 * Key Takeaways
 * 
 * 1. Snowpark brings Python/Java/Scala to Snowflake
 * 2. DataFrame API provides intuitive data manipulation
 * 3. Lazy evaluation optimizes query execution
 * 4. Operations execute in Snowflake, not client
 * 5. Deploy as stored procedures or UDFs
 * 6. Minimize data movement
 * 7. Use caching for frequently accessed data
 * 8. Combine with SQL for optimal results
 * 9. Integrate with Python libraries
 * 10. Best for complex transformations and programmatic workflows
 * 
 *******************************************************************************/
