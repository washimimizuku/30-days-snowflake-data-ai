# Day 22: External Tables & External Functions

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand external tables and their use cases
- Query data in external cloud storage (S3, Azure, GCS)
- Create and manage external tables
- Understand partitioned external tables
- Learn about external functions
- Integrate Snowflake with AWS Lambda, Azure Functions, or GCP Cloud Functions
- Optimize external table performance
- Understand cost implications and best practices

---

## Theory

### What are External Tables?

**External Tables** allow you to query data stored in external cloud storage (S3, Azure Blob, GCS) without loading it into Snowflake.

**Key Characteristics:**
- Data remains in external storage
- Metadata stored in Snowflake
- Query using standard SQL
- No data loading required
- Pay for compute, not storage in Snowflake

```
External Storage (S3/Azure/GCS)
         ↓
   External Table (metadata only)
         ↓
   Query with SQL
```

### External Tables vs. Regular Tables

| Feature | Regular Tables | External Tables |
|---------|---------------|-----------------|
| **Data Location** | Snowflake storage | External cloud storage |
| **Data Loading** | Required (COPY INTO) | Not required |
| **Query Performance** | Faster | Slower |
| **Storage Cost** | Snowflake storage pricing | External storage pricing |
| **Time Travel** | Yes | No |
| **Clustering** | Yes | Partition pruning only |
| **Updates** | Full DML support | Read-only |

### When to Use External Tables

**Good Use Cases:**
- Data lake queries (exploratory analysis)
- Infrequently accessed data
- Data shared across multiple systems
- Cost optimization (avoid duplicate storage)
- Real-time data access without loading

**Not Recommended For:**
- Frequently queried data (use regular tables)
- Data requiring updates (external tables are read-only)
- Performance-critical queries
- Data requiring Time Travel

### Creating External Tables

#### Basic External Table

```sql
-- Create external stage pointing to S3
CREATE OR REPLACE STAGE my_s3_stage
  URL = 's3://my-bucket/data/'
  CREDENTIALS = (AWS_KEY_ID = 'xxx' AWS_SECRET_KEY = 'yyy');

-- Create external table
CREATE OR REPLACE EXTERNAL TABLE my_external_table
  WITH LOCATION = @my_s3_stage
  FILE_FORMAT = (TYPE = 'PARQUET');

-- Query external table
SELECT * FROM my_external_table LIMIT 10;
```

#### External Table with Schema

```sql
-- Define schema explicitly
CREATE OR REPLACE EXTERNAL TABLE orders_external (
  order_id INT AS (value:c1::INT),
  customer_id INT AS (value:c2::INT),
  order_date DATE AS (value:c3::DATE),
  amount DECIMAL(10,2) AS (value:c4::DECIMAL(10,2))
)
WITH LOCATION = @my_s3_stage/orders/
FILE_FORMAT = (TYPE = 'CSV');
```

#### Partitioned External Tables

Partition pruning improves query performance:

```sql
-- Create partitioned external table
CREATE OR REPLACE EXTERNAL TABLE sales_external (
  sale_id INT AS (value:c1::INT),
  product_id INT AS (value:c2::INT),
  amount DECIMAL(10,2) AS (value:c3::DECIMAL(10,2)),
  sale_date DATE AS (value:c4::DATE)
)
PARTITION BY (sale_date)
WITH LOCATION = @my_s3_stage/sales/
PARTITION_TYPE = USER_SPECIFIED
FILE_FORMAT = (TYPE = 'PARQUET');

-- Refresh partitions
ALTER EXTERNAL TABLE sales_external REFRESH;

-- Query with partition pruning
SELECT * FROM sales_external
WHERE sale_date = '2024-01-15';  -- Only scans relevant partition
```

### External Table Metadata

External tables include metadata columns:

```sql
SELECT 
  value,                    -- Actual data
  metadata$filename,        -- Source file name
  metadata$file_row_number, -- Row number in file
  metadata$file_content_key,-- Unique file identifier
  metadata$file_last_modified -- File modification time
FROM my_external_table;
```

### Refreshing External Tables

External tables need to be refreshed to detect new files:

```sql
-- Manual refresh
ALTER EXTERNAL TABLE my_external_table REFRESH;

-- Automatic refresh with event notification
ALTER EXTERNAL TABLE my_external_table 
  REFRESH ON = TRUE
  AUTO_REFRESH = TRUE;
```

### Materialized Views on External Tables

Improve query performance by materializing frequently accessed data:

```sql
-- Create materialized view on external table
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
  DATE_TRUNC('month', sale_date) as month,
  product_id,
  SUM(amount) as total_sales,
  COUNT(*) as sale_count
FROM sales_external
GROUP BY month, product_id;

-- Query materialized view (much faster)
SELECT * FROM sales_summary
WHERE month = '2024-01-01';
```

### External Functions

**External Functions** allow Snowflake to call external APIs or services (AWS Lambda, Azure Functions, GCP Cloud Functions).

**Use Cases:**
- Custom data transformations
- Machine learning model inference
- External API integration
- Complex calculations not possible in SQL
- Enrichment from external services

### Creating External Functions

#### Architecture

```
Snowflake Query
      ↓
API Integration (AWS API Gateway)
      ↓
External Function (AWS Lambda)
      ↓
Return Results to Snowflake
```

#### Step 1: Create API Integration

```sql
-- Create API integration (ACCOUNTADMIN required)
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE API INTEGRATION my_api_integration
  API_PROVIDER = AWS_API_GATEWAY
  API_AWS_ROLE_ARN = 'arn:aws:iam::123456789:role/snowflake-api-role'
  API_ALLOWED_PREFIXES = ('https://abc123.execute-api.us-east-1.amazonaws.com/prod/')
  ENABLED = TRUE;

-- Get API_AWS_IAM_USER_ARN and API_AWS_EXTERNAL_ID for AWS setup
DESC INTEGRATION my_api_integration;
```

#### Step 2: Create External Function

```sql
-- Create external function
CREATE OR REPLACE EXTERNAL FUNCTION sentiment_analysis(text STRING)
  RETURNS VARIANT
  API_INTEGRATION = my_api_integration
  AS 'https://abc123.execute-api.us-east-1.amazonaws.com/prod/sentiment';

-- Use external function in query
SELECT 
  comment_id,
  comment_text,
  sentiment_analysis(comment_text) as sentiment
FROM customer_comments;
```

### External Function Examples

#### Example 1: Data Enrichment

```sql
-- External function to get weather data
CREATE OR REPLACE EXTERNAL FUNCTION get_weather(
  latitude FLOAT,
  longitude FLOAT,
  date DATE
)
RETURNS VARIANT
API_INTEGRATION = weather_api_integration
AS 'https://api.weather.com/snowflake/weather';

-- Use in query
SELECT 
  store_id,
  sales_date,
  daily_sales,
  get_weather(latitude, longitude, sales_date) as weather_data
FROM store_sales;
```

#### Example 2: Machine Learning Inference

```sql
-- External function for ML model prediction
CREATE OR REPLACE EXTERNAL FUNCTION predict_churn(
  customer_data VARIANT
)
RETURNS FLOAT
API_INTEGRATION = ml_api_integration
AS 'https://ml-api.example.com/predict/churn';

-- Use in query
SELECT 
  customer_id,
  predict_churn(OBJECT_CONSTRUCT(
    'age', age,
    'tenure', tenure_months,
    'monthly_charges', monthly_charges
  )) as churn_probability
FROM customers
WHERE churn_probability > 0.7;
```

### Performance Optimization

#### External Tables

**1. Use Partitioning**
```sql
-- Partition by date for time-series data
CREATE EXTERNAL TABLE logs_external (
  log_id INT AS (value:id::INT),
  message STRING AS (value:message::STRING),
  log_date DATE AS (value:date::DATE)
)
PARTITION BY (log_date)
WITH LOCATION = @logs_stage/
FILE_FORMAT = (TYPE = 'JSON');
```

**2. Use Appropriate File Formats**
```sql
-- Parquet is faster than CSV/JSON
FILE_FORMAT = (TYPE = 'PARQUET')  -- Best performance
FILE_FORMAT = (TYPE = 'ORC')      -- Good performance
FILE_FORMAT = (TYPE = 'AVRO')     -- Good performance
FILE_FORMAT = (TYPE = 'JSON')     -- Slower
FILE_FORMAT = (TYPE = 'CSV')      -- Slower
```

**3. Create Materialized Views**
```sql
-- Materialize frequently accessed aggregations
CREATE MATERIALIZED VIEW daily_summary AS
SELECT 
  DATE(log_date) as date,
  COUNT(*) as log_count,
  COUNT(DISTINCT user_id) as unique_users
FROM logs_external
GROUP BY date;
```

**4. Filter on Partitions**
```sql
-- Good: Uses partition pruning
SELECT * FROM sales_external
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Bad: Scans all partitions
SELECT * FROM sales_external
WHERE amount > 1000;
```

#### External Functions

**1. Batch Requests**
```sql
-- Good: Process in batches
SELECT 
  customer_id,
  enrich_data(ARRAY_AGG(OBJECT_CONSTRUCT(*))) as enriched
FROM customers
GROUP BY customer_id;

-- Bad: One call per row
SELECT 
  customer_id,
  enrich_data(customer_id) as enriched
FROM customers;
```

**2. Cache Results**
```sql
-- Create table to cache external function results
CREATE TABLE enriched_customers AS
SELECT 
  customer_id,
  enrich_data(customer_data) as enriched_data,
  CURRENT_TIMESTAMP() as cached_at
FROM customers;

-- Query cached results
SELECT * FROM enriched_customers
WHERE cached_at > DATEADD(day, -1, CURRENT_TIMESTAMP());
```

### Cost Considerations

#### External Tables

**Costs:**
- Compute costs for queries (warehouse usage)
- External storage costs (S3/Azure/GCS)
- Data transfer costs (egress from cloud storage)

**Optimization:**
- Use partitioning to reduce data scanned
- Create materialized views for frequent queries
- Consider loading frequently accessed data into Snowflake

#### External Functions

**Costs:**
- Compute costs for queries
- External service costs (Lambda invocations, API calls)
- Data transfer costs

**Optimization:**
- Batch function calls when possible
- Cache results in tables
- Use external functions only when necessary

### Best Practices

#### External Tables

**1. Use for Appropriate Scenarios**
```sql
-- Good: Infrequently accessed historical data
CREATE EXTERNAL TABLE archive_logs
  WITH LOCATION = @archive_stage/logs/
  FILE_FORMAT = (TYPE = 'PARQUET');

-- Bad: Frequently queried operational data
-- (Load into regular table instead)
```

**2. Implement Partitioning**
```sql
-- Partition by date for time-series data
PARTITION BY (event_date)

-- Partition by region for geographic data
PARTITION BY (region)
```

**3. Monitor Performance**
```sql
-- Check query performance
SELECT 
  query_id,
  query_text,
  total_elapsed_time,
  bytes_scanned
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%external_table%'
ORDER BY start_time DESC;
```

**4. Regular Refresh**
```sql
-- Set up automatic refresh
ALTER EXTERNAL TABLE my_external_table 
  AUTO_REFRESH = TRUE;

-- Or schedule manual refresh
CREATE TASK refresh_external_tables
  WAREHOUSE = compute_wh
  SCHEDULE = 'USING CRON 0 * * * * UTC'  -- Hourly
AS
  ALTER EXTERNAL TABLE my_external_table REFRESH;
```

#### External Functions

**1. Error Handling**
```sql
-- Handle external function errors
SELECT 
  customer_id,
  TRY_CAST(external_function(data) AS VARIANT) as result,
  CASE 
    WHEN result IS NULL THEN 'ERROR'
    ELSE 'SUCCESS'
  END as status
FROM customers;
```

**2. Timeout Configuration**
```sql
-- Set appropriate timeout
CREATE EXTERNAL FUNCTION my_function(input STRING)
  RETURNS VARIANT
  API_INTEGRATION = my_integration
  MAX_BATCH_ROWS = 100
  REQUEST_TRANSLATOR = my_translator
  RESPONSE_TRANSLATOR = my_translator
  AS 'https://api.example.com/function';
```

**3. Security**
```sql
-- Use secure API integration
CREATE API INTEGRATION secure_api
  API_PROVIDER = AWS_API_GATEWAY
  API_AWS_ROLE_ARN = 'arn:aws:iam::123:role/secure-role'
  API_ALLOWED_PREFIXES = ('https://secure-api.example.com/')
  ENABLED = TRUE;
```

### Limitations

#### External Tables

**Cannot:**
- Perform DML operations (INSERT, UPDATE, DELETE)
- Use Time Travel
- Use clustering keys
- Use constraints (primary key, foreign key)
- Be cloned

**Performance:**
- Slower than regular tables
- Network latency to external storage
- Limited optimization options

#### External Functions

**Cannot:**
- Return more than 5 MB per batch
- Process more than 500 rows per batch (default)
- Guarantee sub-second response times

**Considerations:**
- Network latency
- External service availability
- Cost per invocation

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create External Tables
Set up external tables on S3/Azure/GCS data.

### Exercise 2: Query External Tables
Query and analyze external data.

### Exercise 3: Partitioned External Tables
Implement partition pruning for performance.

### Exercise 4: Materialized Views on External Tables
Create materialized views for optimization.

### Exercise 5: External Table Metadata
Use metadata columns for analysis.

### Exercise 6: External Functions (Conceptual)
Understand external function architecture.

### Exercise 7: Performance Comparison
Compare external vs. regular tables.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- External tables query data in external storage without loading
- Data remains in S3/Azure/GCS, only metadata in Snowflake
- External tables are read-only (no DML operations)
- Partitioning improves query performance via partition pruning
- Materialized views can optimize frequently accessed external data
- External tables are slower than regular tables
- Use for infrequently accessed or exploratory data
- External functions integrate with AWS Lambda, Azure Functions, GCP
- External functions enable custom logic and external API calls
- Batch external function calls for better performance
- Monitor costs for both external tables and functions

---

## 📚 Additional Resources

- [Snowflake Docs: External Tables](https://docs.snowflake.com/en/user-guide/tables-external-intro)
- [Partitioned External Tables](https://docs.snowflake.com/en/user-guide/tables-external-partitions)
- [External Functions](https://docs.snowflake.com/en/sql-reference/external-functions-introduction)
- [AWS Lambda Integration](https://docs.snowflake.com/en/sql-reference/external-functions-creating-aws)

---

## 🔜 Tomorrow: Day 23 - Stored Procedures & UDFs

We'll learn about stored procedures and user-defined functions for custom logic in Snowflake.
