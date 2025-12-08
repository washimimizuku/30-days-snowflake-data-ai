/*******************************************************************************
 * Day 22: External Tables & External Functions - SOLUTIONS
 * 
 * Complete solutions for all exercises
 * 
 *******************************************************************************/

-- Setup
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE external_data_lab;
USE DATABASE external_data_lab;
USE SCHEMA public;

CREATE OR REPLACE WAREHOUSE external_wh 
  WAREHOUSE_SIZE = 'XSMALL' 
  AUTO_SUSPEND = 60 
  AUTO_RESUME = TRUE;

USE WAREHOUSE external_wh;

/*******************************************************************************
 * Exercise 1: Create External Tables - SOLUTIONS
 *******************************************************************************/

-- Solution 1.1: Create an internal stage (simulating S3)
CREATE OR REPLACE STAGE my_external_stage
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- In production, you would use:
-- CREATE OR REPLACE STAGE my_s3_stage
--   URL = 's3://my-bucket/data/'
--   CREDENTIALS = (AWS_KEY_ID = 'xxx' AWS_SECRET_KEY = 'yyy');

-- Solution 1.2: Create a file format for CSV
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE;

-- Solution 1.3: Create sample sales data
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

-- Solution 1.4: Export data to stage
COPY INTO @my_external_stage/sales/sales_2024_01.csv
FROM sales_source
FILE_FORMAT = csv_format
HEADER = TRUE
OVERWRITE = TRUE;

-- Verify files in stage
LIST @my_external_stage/sales/;

-- Solution 1.5: Create external table (simulated)
-- Note: In production, you would use CREATE EXTERNAL TABLE
-- For this lab, we simulate with a regular table

CREATE OR REPLACE TABLE sales_external (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING,
  -- Simulate metadata columns
  metadata_filename STRING DEFAULT 'sales_2024_01.csv',
  metadata_file_row_number INT
);

INSERT INTO sales_external 
SELECT 
  *,
  'sales_2024_01.csv' as metadata_filename,
  ROW_NUMBER() OVER (ORDER BY sale_id) as metadata_file_row_number
FROM sales_source;

-- Solution 1.6: Query the external table
SELECT * FROM sales_external;

SELECT COUNT(*) as total_records FROM sales_external;

-- Solution 1.7: Production external table syntax (for reference)
/*
CREATE OR REPLACE EXTERNAL TABLE sales_external_prod (
  sale_id INT AS (value:c1::INT),
  product_id INT AS (value:c2::INT),
  customer_id INT AS (value:c3::INT),
  sale_date DATE AS (value:c4::DATE),
  amount DECIMAL(10,2) AS (value:c5::DECIMAL(10,2)),
  region STRING AS (value:c6::STRING)
)
WITH LOCATION = @my_s3_stage/sales/
FILE_FORMAT = csv_format
AUTO_REFRESH = TRUE;
*/

/*******************************************************************************
 * Exercise 2: Query External Tables - SOLUTIONS
 *******************************************************************************/

-- Solution 2.1: Simple SELECT query
SELECT * FROM sales_external
ORDER BY sale_date, sale_id
LIMIT 10;

-- Solution 2.2: Aggregation query
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale_amount,
  MIN(amount) as min_sale,
  MAX(amount) as max_sale
FROM sales_external
GROUP BY region
ORDER BY total_sales DESC;

-- Solution 2.3: Join with regular table
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

-- Join external table with products
SELECT 
  s.sale_id,
  s.sale_date,
  p.product_name,
  p.category,
  s.amount,
  s.region
FROM sales_external s
JOIN products p ON s.product_id = p.product_id
ORDER BY s.sale_date, s.sale_id;

-- Solution 2.4: Filter and aggregate by category
SELECT 
  p.category,
  COUNT(s.sale_id) as sale_count,
  SUM(s.amount) as total_sales,
  AVG(s.amount) as avg_sale_amount
FROM sales_external s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

/*******************************************************************************
 * Exercise 3: Partitioned External Tables - SOLUTIONS
 *******************************************************************************/

-- Solution 3.1: Create partitioned external table
CREATE OR REPLACE TABLE sales_partitioned (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING,
  partition_date DATE
);

-- Solution 3.2: Populate partitioned table
INSERT INTO sales_partitioned
SELECT 
  *,
  sale_date as partition_date
FROM sales_source;

-- Add more data for different partitions
INSERT INTO sales_partitioned VALUES
  (11, 101, 1011, '2024-02-01', 150.00, 'NORTH', '2024-02-01'),
  (12, 102, 1012, '2024-02-01', 200.00, 'SOUTH', '2024-02-01'),
  (13, 103, 1013, '2024-02-02', 175.00, 'EAST', '2024-02-02'),
  (14, 104, 1014, '2024-02-02', 300.00, 'WEST', '2024-02-02'),
  (15, 105, 1015, '2024-03-01', 400.00, 'NORTH', '2024-03-01');

-- Solution 3.3: Query with partition pruning
-- Query specific date (would use partition pruning in real external table)
SELECT * FROM sales_partitioned
WHERE partition_date = '2024-01-01';

-- Query date range
SELECT * FROM sales_partitioned
WHERE partition_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Solution 3.4: Compare performance
-- With partition filter (efficient)
SELECT 
  COUNT(*) as record_count,
  SUM(amount) as total_sales
FROM sales_partitioned
WHERE partition_date = '2024-01-01';

-- Without partition filter (scans all data)
SELECT 
  COUNT(*) as record_count,
  SUM(amount) as total_sales
FROM sales_partitioned
WHERE amount > 100;

-- Solution 3.5: Create multi-level partitioning
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

-- Populate with partition columns
INSERT INTO sales_multi_partition
SELECT 
  *,
  YEAR(sale_date) as partition_year,
  MONTH(sale_date) as partition_month
FROM sales_source;

INSERT INTO sales_multi_partition VALUES
  (11, 101, 1011, '2024-02-01', 150.00, 'NORTH', 2024, 2),
  (12, 102, 1012, '2024-02-15', 200.00, 'SOUTH', 2024, 2),
  (13, 103, 1013, '2024-03-01', 175.00, 'EAST', 2024, 3),
  (14, 104, 1014, '2024-03-15', 300.00, 'WEST', 2024, 3);

-- Solution 3.6: Query multi-level partitions
-- Query specific year and month
SELECT * FROM sales_multi_partition
WHERE partition_year = 2024 AND partition_month = 1;

-- Aggregate by partition
SELECT 
  partition_year,
  partition_month,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales
FROM sales_multi_partition
GROUP BY partition_year, partition_month
ORDER BY partition_year, partition_month;

/*******************************************************************************
 * Exercise 4: Materialized Views on External Tables - SOLUTIONS
 *******************************************************************************/

-- Solution 4.1: Create materialized view for daily aggregations
CREATE OR REPLACE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
  sale_date,
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale_amount,
  MIN(amount) as min_sale,
  MAX(amount) as max_sale
FROM sales_external
GROUP BY sale_date, region;

-- Solution 4.2: Query the materialized view
SELECT * FROM daily_sales_summary
ORDER BY sale_date, region;

-- Query specific date
SELECT * FROM daily_sales_summary
WHERE sale_date = '2024-01-01';

-- Solution 4.3: Create materialized view for product performance
CREATE OR REPLACE MATERIALIZED VIEW product_performance AS
SELECT 
  p.product_id,
  p.product_name,
  p.category,
  COUNT(s.sale_id) as sale_count,
  SUM(s.amount) as total_sales,
  AVG(s.amount) as avg_sale_amount
FROM sales_external s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category;

SELECT * FROM product_performance
ORDER BY total_sales DESC;

-- Solution 4.4: Compare query performance
-- Query external table (slower)
SELECT 
  sale_date,
  SUM(amount) as total_sales
FROM sales_external
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-05'
GROUP BY sale_date;

-- Query materialized view (faster)
SELECT 
  sale_date,
  SUM(total_sales) as total_sales
FROM daily_sales_summary
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-05'
GROUP BY sale_date;

-- Check query history for performance comparison
SELECT 
  query_text,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 as mb_scanned
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales%'
  AND start_time > DATEADD(minute, -10, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 10;

/*******************************************************************************
 * Exercise 5: External Table Metadata - SOLUTIONS
 *******************************************************************************/

-- Solution 5.1: Query metadata columns
SELECT 
  sale_id,
  sale_date,
  amount,
  metadata_filename,
  metadata_file_row_number
FROM sales_external
ORDER BY metadata_file_row_number
LIMIT 10;

-- Solution 5.2: Count records by source file
SELECT 
  metadata_filename,
  COUNT(*) as record_count,
  SUM(amount) as total_sales,
  MIN(sale_date) as earliest_date,
  MAX(sale_date) as latest_date
FROM sales_external
GROUP BY metadata_filename;

-- Solution 5.3: Find data quality issues using metadata
-- Identify potential duplicate records
SELECT 
  sale_id,
  COUNT(*) as occurrence_count,
  LISTAGG(DISTINCT metadata_filename, ', ') as source_files
FROM sales_external
GROUP BY sale_id
HAVING COUNT(*) > 1;

-- Find records with unusual values
SELECT 
  metadata_filename,
  metadata_file_row_number,
  sale_id,
  amount,
  CASE 
    WHEN amount < 0 THEN 'Negative amount'
    WHEN amount > 10000 THEN 'Unusually high amount'
    WHEN amount = 0 THEN 'Zero amount'
    ELSE 'OK'
  END as data_quality_flag
FROM sales_external
WHERE amount < 0 OR amount > 10000 OR amount = 0;

-- Solution 5.4: Track data lineage
-- Show which files contributed to aggregated results
SELECT 
  region,
  metadata_filename,
  COUNT(*) as record_count,
  SUM(amount) as total_sales
FROM sales_external
GROUP BY region, metadata_filename
ORDER BY region, metadata_filename;

-- Detailed lineage for specific aggregation
SELECT 
  'Total Sales by Region' as metric,
  region,
  SUM(amount) as total_sales,
  LISTAGG(DISTINCT metadata_filename, ', ') as source_files,
  COUNT(DISTINCT metadata_filename) as file_count
FROM sales_external
GROUP BY region;

/*******************************************************************************
 * Exercise 6: External Functions - SOLUTIONS
 *******************************************************************************/

-- Solution 6.1: External function architecture (conceptual)
/*
Architecture:
1. Snowflake Query → 2. API Integration → 3. API Gateway → 4. Lambda/Function → 5. Return Results

Components:
- API Integration: Connects Snowflake to external API
- API Gateway: Routes requests to appropriate function
- Lambda/Azure Function/Cloud Function: Executes custom logic
- Response: Returns results back to Snowflake

Example Flow:
SELECT analyze_sentiment(comment_text) FROM comments
  ↓
API Integration authenticates and routes request
  ↓
API Gateway receives batch of comments
  ↓
Lambda function processes each comment
  ↓
Returns sentiment scores
  ↓
Snowflake receives results and continues query
*/

-- Solution 6.2: Use cases for external functions
/*
1. Machine Learning Model Inference
   - Call trained ML models for predictions
   - Example: Churn prediction, fraud detection, recommendation

2. External API Integration
   - Enrich data with external services
   - Example: Geocoding, weather data, stock prices

3. Custom Data Transformations
   - Complex logic not possible in SQL
   - Example: Natural language processing, image analysis

4. Real-time Data Enrichment
   - Call external databases or services
   - Example: Customer profile lookup, product catalog

5. Compliance and Validation
   - External validation services
   - Example: Address validation, tax calculation
*/

-- Solution 6.3: Simulate external function with UDF
CREATE OR REPLACE FUNCTION simulate_sentiment(text STRING)
RETURNS STRING
AS
$$
  CASE 
    WHEN text ILIKE '%excellent%' OR text ILIKE '%great%' OR text ILIKE '%amazing%' THEN 'POSITIVE'
    WHEN text ILIKE '%terrible%' OR text ILIKE '%bad%' OR text ILIKE '%awful%' THEN 'NEGATIVE'
    ELSE 'NEUTRAL'
  END
$$;

-- Create sample comments table
CREATE OR REPLACE TABLE customer_comments (
  comment_id INT,
  customer_id INT,
  comment_text STRING,
  comment_date DATE
);

INSERT INTO customer_comments VALUES
  (1, 1001, 'This product is excellent! Highly recommend.', '2024-01-01'),
  (2, 1002, 'Terrible experience, very disappointed.', '2024-01-02'),
  (3, 1003, 'It was okay, nothing special.', '2024-01-03'),
  (4, 1004, 'Amazing quality and great customer service!', '2024-01-04'),
  (5, 1005, 'Bad quality, would not buy again.', '2024-01-05');

-- Use the simulated function
SELECT 
  comment_id,
  comment_text,
  simulate_sentiment(comment_text) as sentiment
FROM customer_comments;

-- Aggregate sentiment analysis
SELECT 
  sentiment,
  COUNT(*) as comment_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM (
  SELECT simulate_sentiment(comment_text) as sentiment
  FROM customer_comments
)
GROUP BY sentiment
ORDER BY comment_count DESC;

/*******************************************************************************
 * Exercise 7: Performance Comparison - SOLUTIONS
 *******************************************************************************/

-- Solution 7.1: Create equivalent regular table
CREATE OR REPLACE TABLE sales_regular AS
SELECT 
  sale_id,
  product_id,
  customer_id,
  sale_date,
  amount,
  region
FROM sales_external;

-- Solution 7.2: Compare query performance
-- Query 1: External table (simulated)
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales_external
GROUP BY region
ORDER BY total_sales DESC;

-- Query 2: Regular table
SELECT 
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale
FROM sales_regular
GROUP BY region
ORDER BY total_sales DESC;

-- Solution 7.3: Check query history for performance metrics
SELECT 
  query_text,
  warehouse_name,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 as mb_scanned,
  rows_produced,
  compilation_time / 1000 as compile_seconds,
  execution_time / 1000 as execute_seconds
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales_%'
  AND query_text ILIKE '%GROUP BY region%'
  AND start_time > DATEADD(minute, -10, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 5;

-- Solution 7.4: Analysis of when to use each approach
/*
External Table - Best for:
- Infrequently accessed data (monthly reports, historical archives)
- Exploratory data analysis on data lakes
- Data shared across multiple systems
- Cost optimization (avoid duplicate storage)
- Data that changes frequently in source system
- Large datasets where only small portions are queried

Regular Table - Best for:
- Frequently queried data (daily operations)
- Performance-critical queries
- Data requiring updates (DML operations)
- Data needing Time Travel
- Data requiring clustering optimization
- Workloads with consistent access patterns

Hybrid Approach - Best for:
- Recent data in regular tables (hot data)
- Historical data in external tables (cold data)
- Use views to union both for seamless access
*/

/*******************************************************************************
 * Bonus Challenges - SOLUTIONS
 *******************************************************************************/

-- BONUS 1: Create a hybrid approach
-- Recent data in regular table (last 30 days)
CREATE OR REPLACE TABLE sales_recent AS
SELECT * FROM sales_source
WHERE sale_date >= DATEADD(day, -30, CURRENT_DATE());

-- Historical data remains in external table
-- Create unified view
CREATE OR REPLACE VIEW sales_unified AS
SELECT * FROM sales_recent
UNION ALL
SELECT 
  sale_id,
  product_id,
  customer_id,
  sale_date,
  amount,
  region
FROM sales_external
WHERE sale_date < DATEADD(day, -30, CURRENT_DATE());

-- Query unified view
SELECT 
  CASE 
    WHEN sale_date >= DATEADD(day, -30, CURRENT_DATE()) THEN 'Recent'
    ELSE 'Historical'
  END as data_tier,
  COUNT(*) as record_count,
  SUM(amount) as total_sales
FROM sales_unified
GROUP BY data_tier;

-- BONUS 2: Implement incremental loading from external table
-- Track last loaded date
CREATE OR REPLACE TABLE load_metadata (
  table_name STRING,
  last_load_date TIMESTAMP,
  records_loaded INT
);

-- Incremental load procedure
CREATE OR REPLACE PROCEDURE load_incremental_sales()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  last_load TIMESTAMP;
  records_loaded INT;
BEGIN
  -- Get last load date
  SELECT COALESCE(MAX(last_load_date), '1900-01-01'::TIMESTAMP)
  INTO last_load
  FROM load_metadata
  WHERE table_name = 'sales_regular';
  
  -- Load new records
  INSERT INTO sales_regular
  SELECT 
    sale_id,
    product_id,
    customer_id,
    sale_date,
    amount,
    region
  FROM sales_external
  WHERE sale_date > last_load;
  
  records_loaded := SQLROWCOUNT;
  
  -- Update metadata
  INSERT INTO load_metadata VALUES (
    'sales_regular',
    CURRENT_TIMESTAMP(),
    records_loaded
  );
  
  RETURN 'Loaded ' || records_loaded || ' new records';
END;
$$;

-- Test incremental load
CALL load_incremental_sales();

-- View load history
SELECT * FROM load_metadata ORDER BY last_load_date DESC;

-- BONUS 3: Create monitoring for external table queries
CREATE OR REPLACE VIEW external_table_monitoring AS
SELECT 
  DATE(start_time) as query_date,
  user_name,
  warehouse_name,
  COUNT(*) as query_count,
  AVG(total_elapsed_time) / 1000 as avg_elapsed_seconds,
  SUM(bytes_scanned) / 1024 / 1024 / 1024 as total_gb_scanned,
  SUM(bytes_scanned) / 1024 / 1024 / 1024 * 0.02 as estimated_cost_usd
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales_external%'
  AND execution_status = 'SUCCESS'
  AND start_time > DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY DATE(start_time), user_name, warehouse_name
ORDER BY query_date DESC, query_count DESC;

-- View monitoring dashboard
SELECT * FROM external_table_monitoring;

-- Alert for expensive queries
SELECT 
  query_id,
  user_name,
  query_text,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%sales_external%'
  AND bytes_scanned > 1024 * 1024 * 1024  -- > 1 GB
  AND start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY bytes_scanned DESC;

-- BONUS 4: Design a data lake architecture
-- Layer 1: Raw data (external tables)
CREATE OR REPLACE TABLE raw_sales_external (
  sale_id INT,
  product_id INT,
  customer_id INT,
  sale_date DATE,
  amount DECIMAL(10,2),
  region STRING,
  metadata_filename STRING,
  metadata_file_row_number INT
) AS SELECT * FROM sales_external;

-- Layer 2: Curated data (regular tables with transformations)
CREATE OR REPLACE TABLE curated_sales AS
SELECT 
  s.sale_id,
  s.product_id,
  p.product_name,
  p.category,
  s.customer_id,
  s.sale_date,
  s.amount,
  s.region,
  YEAR(s.sale_date) as sale_year,
  MONTH(s.sale_date) as sale_month,
  DAYOFWEEK(s.sale_date) as sale_day_of_week,
  CURRENT_TIMESTAMP() as curated_at
FROM raw_sales_external s
LEFT JOIN products p ON s.product_id = p.product_id;

-- Layer 3: Aggregated data (materialized views)
CREATE OR REPLACE MATERIALIZED VIEW aggregated_sales_monthly AS
SELECT 
  sale_year,
  sale_month,
  category,
  region,
  COUNT(*) as sale_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_sale_amount,
  COUNT(DISTINCT customer_id) as unique_customers
FROM curated_sales
GROUP BY sale_year, sale_month, category, region;

-- Query the data lake
-- Raw layer (exploratory)
SELECT * FROM raw_sales_external LIMIT 100;

-- Curated layer (analytics)
SELECT 
  category,
  region,
  COUNT(*) as sales,
  SUM(amount) as revenue
FROM curated_sales
WHERE sale_date >= '2024-01-01'
GROUP BY category, region;

-- Aggregated layer (reporting)
SELECT * FROM aggregated_sales_monthly
WHERE sale_year = 2024 AND sale_month = 1
ORDER BY total_sales DESC;

/*******************************************************************************
 * Summary and Best Practices
 *******************************************************************************/

-- Create summary view of all approaches
CREATE OR REPLACE VIEW data_architecture_summary AS
SELECT 
  'External Table' as approach,
  'Raw data in S3/Azure/GCS' as description,
  'Infrequent access, exploratory' as use_case,
  'Low (external storage)' as storage_cost,
  'High (slower queries)' as compute_cost,
  'Slower' as performance
UNION ALL
SELECT 
  'Regular Table' as approach,
  'Data loaded into Snowflake' as description,
  'Frequent access, operations' as use_case,
  'Medium (Snowflake storage)' as storage_cost,
  'Low (faster queries)' as compute_cost,
  'Faster' as performance
UNION ALL
SELECT 
  'Materialized View' as approach,
  'Pre-aggregated results' as description,
  'Frequent aggregations' as use_case,
  'Medium (stored results)' as storage_cost,
  'Very Low (pre-computed)' as compute_cost,
  'Fastest' as performance
UNION ALL
SELECT 
  'Hybrid Approach' as approach,
  'Recent in tables, historical external' as description,
  'Balance cost and performance' as use_case,
  'Optimized' as storage_cost,
  'Optimized' as compute_cost,
  'Balanced' as performance;

SELECT * FROM data_architecture_summary;

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
 * Key Learnings
 * 
 * 1. External Tables
 *    - Query data in external storage without loading
 *    - Read-only, no DML operations
 *    - Slower than regular tables but saves storage costs
 *    - Use partitioning for better performance
 *    - Metadata columns provide file-level information
 * 
 * 2. Materialized Views on External Tables
 *    - Pre-compute frequently accessed aggregations
 *    - Significantly improve query performance
 *    - Balance between external tables and regular tables
 * 
 * 3. External Functions
 *    - Integrate with AWS Lambda, Azure Functions, GCP
 *    - Enable custom logic and external API calls
 *    - Batch requests for better performance
 *    - Monitor costs carefully
 * 
 * 4. Architecture Patterns
 *    - Data lake: External tables for raw data
 *    - Curated layer: Regular tables with transformations
 *    - Aggregated layer: Materialized views for reporting
 *    - Hybrid: Recent data in tables, historical external
 * 
 * 5. Best Practices
 *    - Use external tables for infrequent access
 *    - Implement partitioning for large datasets
 *    - Create materialized views for frequent queries
 *    - Monitor query performance and costs
 *    - Consider hybrid approaches for optimal balance
 * 
 *******************************************************************************/
