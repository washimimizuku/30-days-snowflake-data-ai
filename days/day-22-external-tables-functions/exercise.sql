/*******************************************************************************
 * Day 22: External Tables & External Functions
 * 
 * Time: 40 minutes
 * 
 * Exercises:
 * 1. Create External Tables (10 min)
 * 2. Query External Tables (5 min)
 * 3. Partitioned External Tables (10 min)
 * 4. Materialized Views on External Tables (5 min)
 * 5. External Table Metadata (5 min)
 * 6. External Functions (Conceptual) (3 min)
 * 7. Performance Comparison (2 min)
 * 
 * Note: These exercises use simulated external data. In production, you would
 * configure actual S3/Azure/GCS buckets with real data.
 * 
 *******************************************************************************/

-- Setup: Create database and sample data
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE external_data_lab;
USE DATABASE external_data_lab;
USE SCHEMA public;

-- Create warehouse for exercises
CREATE OR REPLACE WAREHOUSE external_wh 
  WAREHOUSE_SIZE = 'XSMALL' 
  AUTO_SUSPEND = 60 
  AUTO_RESUME = TRUE;

USE WAREHOUSE external_wh;

/*******************************************************************************
 * Exercise 1: Create External Tables (10 min)
 * 
 * Learn to create external tables pointing to cloud storage.
 * 
 * Note: In this lab, we'll simulate external tables using internal stages.
 * In production, you would use actual S3/Azure/GCS URLs.
 *******************************************************************************/

-- TODO 1.1: Create an internal stage (simulating S3)
-- In production: URL = 's3://my-bucket/data/'
-- For lab: We'll use internal stage


-- TODO 1.2: Create sample CSV data and upload to stage
-- Create a file format for CSV


-- TODO 1.3: Create sample data files
-- In production, these would be files in S3/Azure/GCS
-- For lab, we'll create regular tables first, then export


-- Create sample sales data
CREATE OR REPLACE TABLE sales_source (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING
);

INSERT INTO sales_source VALUES
  (1, 101, 1001, '2024-01-01', 150.00, 'NORTH'),
  (2, 102, 1002, '2024-01-01', 200.00, 'SOUTH'),
  (3, 103, 1003, '2024-01-02', 175.00, 'EAST'),
  (4, 101, 1004, '2024-01-02', 150.00, 'WEST'),
  (5, 104, 1005, '2024-01-03', 300.00, 'NORTH'),
  (6, 102, 1006, '2024-01-03', 225.00, 'SOUTH'),
  (7, 105, 1007, '2024-01-04', 400.00, 'EAST'),
  (8, 103, 1008, '2024-01-04', 175.00, 'WEST'),
  (9, 101, 1009, '2024-01-05', 150.00, 'NORTH'),
  (10, 104, 1010, '2024-01-05', 300.00, 'SOUTH');

-- TODO 1.4: Export data to stage (simulating external files)
-- COPY INTO @my_external_stage/sales/ FROM sales_source;


-- TODO 1.5: Create external table
-- Note: For this lab, we'll create a regular table to simulate external table behavior
-- In production, you would use CREATE EXTERNAL TABLE syntax

CREATE OR REPLACE TABLE sales_external (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING,
  -- Simulate metadata columns
  filename STRING DEFAULT 'sales_2024_01.csv',
  file_row_number INT
);

-- Populate with sample data
INSERT INTO sales_external 
SELECT *, 'sales_2024_01.csv', ROW_NUMBER() OVER (ORDER BY sale_id)
FROM sales_source;

-- TODO 1.6: Query the external table


-- TODO 1.7: Create external table with explicit schema
-- Define column mappings


/*******************************************************************************
 * Exercise 2: Query External Tables (5 min)
 * 
 * Practice querying external tables with various SQL operations.
 *******************************************************************************/

-- TODO 2.1: Simple SELECT query


-- TODO 2.2: Aggregation query
-- Calculate total sales by region


-- TODO 2.3: Join with regular table
-- Create a products dimension table
CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name STRING,
  category STRING,
  price DECIMAL(10,2)
);

INSERT INTO products VALUES
  (101, 'Laptop', 'Electronics', 999.99),
  (102, 'Mouse', 'Electronics', 29.99),
  (103, 'Desk', 'Furniture', 299.99),
  (104, 'Chair', 'Furniture', 199.99),
  (105, 'Monitor', 'Electronics', 399.99);

-- TODO: Join external table with products table


-- TODO 2.4: Filter and aggregate
-- Find total sales by product category


/*******************************************************************************
 * Exercise 3: Partitioned External Tables (10 min)
 * 
 * Implement partitioning for better query performance.
 *******************************************************************************/

-- TODO 3.1: Create partitioned external table
-- Partition by sale_date for time-series data

CREATE OR REPLACE TABLE sales_partitioned (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING,
  -- Partition column
  partition_date DATE
);

-- TODO 3.2: Populate partitioned table
-- Insert data with partition column


-- TODO 3.3: Query with partition pruning
-- Query specific date range (would use partition pruning in real external table)


-- TODO 3.4: Compare performance
-- Query with partition filter vs. without


-- TODO 3.5: Create multi-level partitioning
-- Partition by year and month

CREATE OR REPLACE TABLE sales_multi_partition (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING,
  partition_year INT,
  partition_month INT
);

-- TODO: Populate with partition columns


-- TODO 3.6: Query multi-level partitions


/*******************************************************************************
 * Exercise 4: Materialized Views on External Tables (5 min)
 * 
 * Create materialized views to improve query performance.
 *******************************************************************************/

-- TODO 4.1: Create materialized view for daily aggregations


-- TODO 4.2: Query the materialized view


-- TODO 4.3: Create materialized view for product performance


-- TODO 4.4: Compare query performance
-- Query external table vs. materialized view


/*******************************************************************************
 * Exercise 5: External Table Metadata (5 min)
 * 
 * Use metadata columns for analysis and troubleshooting.
 *******************************************************************************/

-- TODO 5.1: Query metadata columns
-- Show filename and row number for each record


-- TODO 5.2: Count records by source file


-- TODO 5.3: Find data quality issues using metadata
-- Identify records with potential issues


-- TODO 5.4: Track data lineage
-- Show which files contributed to aggregated results


/*******************************************************************************
 * Exercise 6: External Functions (Conceptual) (3 min)
 * 
 * Understand external function architecture and use cases.
 * 
 * Note: Creating actual external functions requires AWS/Azure/GCP setup.
 * This exercise focuses on understanding the concepts.
 *******************************************************************************/

-- TODO 6.1: Understand external function architecture
-- Review the following conceptual external function

/*
-- Step 1: Create API Integration (requires ACCOUNTADMIN)
CREATE OR REPLACE API INTEGRATION sentiment_api
  API_PROVIDER = AWS_API_GATEWAY
  API_AWS_ROLE_ARN = 'arn:aws:iam::123456789:role/snowflake-api-role'
  API_ALLOWED_PREFIXES = ('https://abc123.execute-api.us-east-1.amazonaws.com/')
  ENABLED = TRUE;

-- Step 2: Create External Function
CREATE OR REPLACE EXTERNAL FUNCTION analyze_sentiment(text STRING)
  RETURNS VARIANT
  API_INTEGRATION = sentiment_api
  AS 'https://abc123.execute-api.us-east-1.amazonaws.com/prod/sentiment';

-- Step 3: Use External Function
SELECT 
  comment_id,
  comment_text,
  analyze_sentiment(comment_text):sentiment::STRING as sentiment,
  analyze_sentiment(comment_text):score::FLOAT as sentiment_score
FROM customer_comments;
*/

-- TODO 6.2: Identify use cases for external functions
-- List 3 scenarios where external functions would be useful:
-- 1. _______________
-- 2. _______________
-- 3. _______________


-- TODO 6.3: Simulate external function with UDF
-- Create a simple UDF to simulate external function behavior

CREATE OR REPLACE FUNCTION simulate_sentiment(text STRING)
RETURNS STRING
AS
$$
  CASE 
    WHEN text ILIKE '%excellent%' OR text ILIKE '%great%' THEN 'POSITIVE'
    WHEN text ILIKE '%terrible%' OR text ILIKE '%bad%' THEN 'NEGATIVE'
    ELSE 'NEUTRAL'
  END
$$;

-- Test the simulated function
SELECT 
  'This product is excellent!' as comment,
  simulate_sentiment('This product is excellent!') as sentiment
UNION ALL
SELECT 
  'Terrible experience' as comment,
  simulate_sentiment('Terrible experience') as sentiment
UNION ALL
SELECT 
  'It was okay' as comment,
  simulate_sentiment('It was okay') as sentiment;

/*******************************************************************************
 * Exercise 7: Performance Comparison (2 min)
 * 
 * Compare external tables vs. regular tables.
 *******************************************************************************/

-- TODO 7.1: Create equivalent regular table
CREATE OR REPLACE TABLE sales_regular AS
SELECT * FROM sales_external;

-- TODO 7.2: Compare query performance
-- Query 1: External table (simulated)
SELECT region, SUM(amount) as total_sales
FROM sales_external
GROUP BY region;

-- Query 2: Regular table
SELECT region, SUM(amount) as total_sales
FROM sales_regular
GROUP BY region;

-- TODO 7.3: Check query history for performance metrics


-- TODO 7.4: Analyze when to use each approach
-- External Table: Best for _______________
-- Regular Table: Best for _______________


/*******************************************************************************
 * Bonus Challenges (Optional)
 *******************************************************************************/

-- BONUS 1: Create a hybrid approach
-- Use external table for historical data, regular table for recent data
-- Create a view that unions both


-- BONUS 2: Implement incremental loading from external table
-- Load only new data from external table to regular table


-- BONUS 3: Create monitoring for external table queries
-- Track query performance and data scanned


-- BONUS 4: Design a data lake architecture
-- External tables for raw data
-- Regular tables for curated data
-- Materialized views for aggregated data


/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS external_data_lab CASCADE;
DROP WAREHOUSE IF EXISTS external_wh;
*/

/*******************************************************************************
 * Key Takeaways
 * 
 * 1. External tables query data in external storage without loading
 * 2. Data remains in S3/Azure/GCS, only metadata in Snowflake
 * 3. External tables are read-only (no DML operations)
 * 4. Partitioning improves performance via partition pruning
 * 5. Materialized views optimize frequently accessed external data
 * 6. External tables are slower than regular tables
 * 7. Use for infrequently accessed or exploratory data
 * 8. External functions integrate with AWS Lambda, Azure Functions, GCP
 * 9. Batch external function calls for better performance
 * 10. Monitor costs for both compute and external services
 * 
 *******************************************************************************/
