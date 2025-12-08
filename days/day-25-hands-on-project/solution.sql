/*******************************************************************************
 * Day 25: Hands-On Project - E-Commerce Analytics Platform - SOLUTION
 * 
 * Complete implementation of the end-to-end data engineering solution
 * 
 *******************************************************************************/

/*******************************************************************************
 * PHASE 1: Setup & Infrastructure - SOLUTION
 *******************************************************************************/

-- Solution 1.1: Create database structure
USE ROLE SYSADMIN;

CREATE OR REPLACE DATABASE ecommerce_raw
  COMMENT = 'Raw data landing zone';
CREATE OR REPLACE DATABASE ecommerce_curated
  COMMENT = 'Cleaned and enriched data';
CREATE OR REPLACE DATABASE ecommerce_analytics
  COMMENT = 'Analytics and reporting layer';
CREATE OR REPLACE DATABASE ecommerce_governance
  COMMENT = 'Audit and monitoring';

-- Create schemas
CREATE SCHEMA ecommerce_raw.landing
  COMMENT = 'Landing zone for incoming data';
CREATE SCHEMA ecommerce_curated.core
  COMMENT = 'Core business entities';
CREATE SCHEMA ecommerce_analytics.reporting
  COMMENT = 'Reporting views and aggregations';
CREATE SCHEMA ecommerce_governance.audit
  COMMENT = 'Audit logs and monitoring';

-- Solution 1.2: Create warehouses
CREATE OR REPLACE WAREHOUSE ingestion_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse for data ingestion';

CREATE OR REPLACE WAREHOUSE processing_wh
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse for ETL processing';

CREATE OR REPLACE WAREHOUSE analytics_wh
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 600
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse for analytics queries';

-- Solution 1.3: Create role hierarchy
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS ecommerce_admin
  COMMENT = 'Admin role for e-commerce platform';
CREATE ROLE IF NOT EXISTS data_engineer
  COMMENT = 'Data engineering role';
CREATE ROLE IF NOT EXISTS data_analyst
  COMMENT = 'Data analyst role';
CREATE ROLE IF NOT EXISTS regional_manager_north
  COMMENT = 'Regional manager for NORTH region';
CREATE ROLE IF NOT EXISTS regional_manager_south
  COMMENT = 'Regional manager for SOUTH region';

-- Grant hierarchy
GRANT ROLE data_engineer TO ROLE ecommerce_admin;
GRANT ROLE data_analyst TO ROLE ecommerce_admin;
GRANT ROLE regional_manager_north TO ROLE data_analyst;
GRANT ROLE regional_manager_south TO ROLE data_analyst;

-- Grant to SYSADMIN
GRANT ROLE ecommerce_admin TO ROLE SYSADMIN;

/*******************************************************************************
 * PHASE 2: Data Ingestion - SOLUTION
 *******************************************************************************/

USE ROLE SYSADMIN;
USE DATABASE ecommerce_raw;
USE SCHEMA landing;
USE WAREHOUSE ingestion_wh;

-- Solution 2.1: Create stage and file formats
CREATE OR REPLACE STAGE internal_stage
  COMMENT = 'Internal stage for data files';

CREATE OR REPLACE FILE FORMAT json_format
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE
  COMMENT = 'JSON file format';

CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  COMMENT = 'CSV file format';

-- Solution 2.2: Create landing tables
CREATE OR REPLACE TABLE raw_orders (
  order_id INT,
  customer_id INT,
  product_id INT,
  order_date TIMESTAMP,
  quantity INT,
  amount DECIMAL(10,2),
  region STRING,
  status STRING,
  loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw orders from source systems';

CREATE OR REPLACE TABLE raw_customers (
  customer_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  region STRING,
  tier STRING,
  signup_date DATE,
  loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw customer data';

CREATE OR REPLACE TABLE raw_products (
  product_id INT,
  product_name STRING,
  category STRING,
  price DECIMAL(10,2),
  cost DECIMAL(10,2),
  loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw product catalog';

-- Solution 2.3: Create sample data
INSERT INTO raw_orders VALUES
  (1001, 101, 1, '2024-01-15 10:30:00', 2, 1999.98, 'NORTH', 'COMPLETED', CURRENT_TIMESTAMP()),
  (1002, 102, 2, '2024-01-15 11:45:00', 1, 29.99, 'SOUTH', 'COMPLETED', CURRENT_TIMESTAMP()),
  (1003, 103, 3, '2024-01-15 14:20:00', 1, 299.99, 'EAST', 'PENDING', CURRENT_TIMESTAMP()),
  (1004, 101, 4, '2024-01-16 09:15:00', 2, 399.98, 'NORTH', 'COMPLETED', CURRENT_TIMESTAMP()),
  (1005, 104, 5, '2024-01-16 16:30:00', 1, 399.99, 'WEST', 'SHIPPED', CURRENT_TIMESTAMP()),
  (1006, 102, 1, '2024-01-17 10:00:00', 1, 999.99, 'SOUTH', 'COMPLETED', CURRENT_TIMESTAMP()),
  (1007, 105, 2, '2024-01-17 13:45:00', 3, 89.97, 'NORTH', 'COMPLETED', CURRENT_TIMESTAMP()),
  (1008, 103, 3, '2024-01-18 11:20:00', 1, 299.99, 'EAST', 'COMPLETED', CURRENT_TIMESTAMP()),
  (1009, 106, 4, '2024-01-18 15:30:00', 1, 199.99, 'WEST', 'PENDING', CURRENT_TIMESTAMP()),
  (1010, 101, 5, '2024-01-19 09:45:00', 1, 399.99, 'NORTH', 'COMPLETED', CURRENT_TIMESTAMP());

INSERT INTO raw_customers VALUES
  (101, 'John', 'Doe', 'john.doe@email.com', '555-0101', 'NORTH', 'GOLD', '2023-01-15', CURRENT_TIMESTAMP()),
  (102, 'Jane', 'Smith', 'jane.smith@email.com', '555-0102', 'SOUTH', 'PLATINUM', '2023-02-20', CURRENT_TIMESTAMP()),
  (103, 'Bob', 'Johnson', 'bob.j@email.com', '555-0103', 'EAST', 'SILVER', '2023-03-10', CURRENT_TIMESTAMP()),
  (104, 'Alice', 'Williams', 'alice.w@email.com', '555-0104', 'WEST', 'GOLD', '2023-04-05', CURRENT_TIMESTAMP()),
  (105, 'Charlie', 'Brown', 'charlie.b@email.com', '555-0105', 'NORTH', 'BRONZE', '2023-05-12', CURRENT_TIMESTAMP()),
  (106, 'Diana', 'Davis', 'diana.d@email.com', '555-0106', 'WEST', 'SILVER', '2023-06-18', CURRENT_TIMESTAMP());

INSERT INTO raw_products VALUES
  (1, 'Laptop Pro', 'Electronics', 999.99, 600.00, CURRENT_TIMESTAMP()),
  (2, 'Wireless Mouse', 'Electronics', 29.99, 15.00, CURRENT_TIMESTAMP()),
  (3, 'Standing Desk', 'Furniture', 299.99, 180.00, CURRENT_TIMESTAMP()),
  (4, 'Ergonomic Chair', 'Furniture', 199.99, 120.00, CURRENT_TIMESTAMP()),
  (5, '4K Monitor', 'Electronics', 399.99, 250.00, CURRENT_TIMESTAMP());

-- Verify data loaded
SELECT 'Orders' as table_name, COUNT(*) as row_count FROM raw_orders
UNION ALL
SELECT 'Customers', COUNT(*) FROM raw_customers
UNION ALL
SELECT 'Products', COUNT(*) FROM raw_products;

/*******************************************************************************
 * PHASE 3: Change Tracking - SOLUTION
 *******************************************************************************/

-- Solution 3.1: Create streams
CREATE OR REPLACE STREAM orders_stream
  ON TABLE raw_orders
  COMMENT = 'Stream to track changes in raw_orders';

CREATE OR REPLACE STREAM customers_stream
  ON TABLE raw_customers
  COMMENT = 'Stream to track changes in raw_customers';

-- Solution 3.2: Verify streams
SHOW STREAMS;

SELECT SYSTEM$STREAM_HAS_DATA('orders_stream');
SELECT SYSTEM$STREAM_HAS_DATA('customers_stream');

/*******************************************************************************
 * PHASE 4: Data Processing - SOLUTION
 *******************************************************************************/

USE DATABASE ecommerce_curated;
USE SCHEMA core;
USE WAREHOUSE processing_wh;

-- Solution 4.1: Create curated tables with clustering
CREATE OR REPLACE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  order_date DATE,
  order_timestamp TIMESTAMP,
  quantity INT,
  amount DECIMAL(10,2),
  region STRING,
  status STRING,
  profit DECIMAL(10,2),
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY (order_date, region)
  DATA_RETENTION_TIME_IN_DAYS = 30
  COMMENT = 'Curated orders table with clustering';

CREATE OR REPLACE TABLE customers (
  customer_id INT PRIMARY KEY,
  first_name STRING,
  last_name STRING,
  full_name STRING,
  email STRING,
  phone STRING,
  region STRING,
  tier STRING,
  signup_date DATE,
  total_orders INT DEFAULT 0,
  total_spent DECIMAL(12,2) DEFAULT 0,
  avg_order_value DECIMAL(10,2) DEFAULT 0,
  last_order_date DATE,
  customer_lifetime_days INT,
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) DATA_RETENTION_TIME_IN_DAYS = 30
  COMMENT = 'Curated customers table with metrics';

CREATE OR REPLACE TABLE products (
  product_id INT PRIMARY KEY,
  product_name STRING,
  category STRING,
  price DECIMAL(10,2),
  cost DECIMAL(10,2),
  margin_pct DECIMAL(5,2),
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Curated products table';

-- Solution 4.2: Create stored procedure for ETL
CREATE OR REPLACE PROCEDURE process_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  orders_processed INT DEFAULT 0;
  customers_processed INT DEFAULT 0;
  result STRING;
BEGIN
  -- Process orders from stream
  MERGE INTO orders o
  USING (
    SELECT 
      s.order_id,
      s.customer_id,
      s.product_id,
      s.order_date::DATE as order_date,
      s.order_date as order_timestamp,
      s.quantity,
      s.amount,
      s.region,
      s.status,
      s.amount - (p.cost * s.quantity) as profit
    FROM ecommerce_raw.landing.orders_stream s
    LEFT JOIN products p ON s.product_id = p.product_id
    WHERE s.METADATA$ACTION = 'INSERT'
  ) src
  ON o.order_id = src.order_id
  WHEN MATCHED THEN
    UPDATE SET
      status = src.status,
      processed_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, product_id, order_date, order_timestamp,
            quantity, amount, region, status, profit, processed_at)
    VALUES (src.order_id, src.customer_id, src.product_id, src.order_date,
            src.order_timestamp, src.quantity, src.amount, src.region,
            src.status, src.profit, CURRENT_TIMESTAMP());
  
  orders_processed := SQLROWCOUNT;
  
  -- Update customer metrics
  MERGE INTO customers c
  USING (
    SELECT 
      o.customer_id,
      COUNT(*) as order_count,
      SUM(o.amount) as total_amount,
      AVG(o.amount) as avg_amount,
      MAX(o.order_date) as last_order
    FROM orders o
    GROUP BY o.customer_id
  ) metrics
  ON c.customer_id = metrics.customer_id
  WHEN MATCHED THEN
    UPDATE SET
      total_orders = metrics.order_count,
      total_spent = metrics.total_amount,
      avg_order_value = metrics.avg_amount,
      last_order_date = metrics.last_order,
      processed_at = CURRENT_TIMESTAMP();
  
  customers_processed := SQLROWCOUNT;
  
  -- Process new customers
  MERGE INTO customers c
  USING (
    SELECT 
      customer_id,
      first_name,
      last_name,
      first_name || ' ' || last_name as full_name,
      email,
      phone,
      region,
      tier,
      signup_date,
      DATEDIFF(day, signup_date, CURRENT_DATE()) as lifetime_days
    FROM ecommerce_raw.landing.customers_stream
    WHERE METADATA$ACTION = 'INSERT'
  ) src
  ON c.customer_id = src.customer_id
  WHEN NOT MATCHED THEN
    INSERT (customer_id, first_name, last_name, full_name, email, phone,
            region, tier, signup_date, customer_lifetime_days, processed_at)
    VALUES (src.customer_id, src.first_name, src.last_name, src.full_name,
            src.email, src.phone, src.region, src.tier, src.signup_date,
            src.lifetime_days, CURRENT_TIMESTAMP());
  
  -- Process products
  MERGE INTO products p
  USING (
    SELECT 
      product_id,
      product_name,
      category,
      price,
      cost,
      ROUND(((price - cost) / NULLIF(price, 0)) * 100, 2) as margin_pct
    FROM ecommerce_raw.landing.raw_products
  ) src
  ON p.product_id = src.product_id
  WHEN MATCHED THEN
    UPDATE SET
      price = src.price,
      cost = src.cost,
      margin_pct = src.margin_pct,
      processed_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN
    INSERT VALUES (src.product_id, src.product_name, src.category,
                   src.price, src.cost, src.margin_pct, CURRENT_TIMESTAMP());
  
  result := 'ETL completed: ' || orders_processed || ' orders, ' ||
            customers_processed || ' customers updated';
  RETURN result;
END;
$$;

-- Test the procedure
CALL process_orders();

-- Verify data
SELECT 'Orders' as table_name, COUNT(*) as row_count FROM orders
UNION ALL
SELECT 'Customers', COUNT(*) FROM customers
UNION ALL
SELECT 'Products', COUNT(*) FROM products;

-- Solution 4.3: Create UDFs for business logic
CREATE OR REPLACE FUNCTION calculate_tier(total_spent DECIMAL(12,2))
RETURNS STRING
AS
$$
  CASE
    WHEN total_spent >= 5000 THEN 'PLATINUM'
    WHEN total_spent >= 2000 THEN 'GOLD'
    WHEN total_spent >= 500 THEN 'SILVER'
    ELSE 'BRONZE'
  END
$$;

CREATE OR REPLACE FUNCTION calculate_discount(tier STRING)
RETURNS DECIMAL(3,2)
AS
$$
  CASE tier
    WHEN 'PLATINUM' THEN 0.20
    WHEN 'GOLD' THEN 0.15
    WHEN 'SILVER' THEN 0.10
    WHEN 'BRONZE' THEN 0.05
    ELSE 0.00
  END
$$;

-- Test UDFs
SELECT 
  customer_id,
  full_name,
  total_spent,
  tier as current_tier,
  calculate_tier(total_spent) as calculated_tier,
  calculate_discount(tier) as discount_rate
FROM customers
LIMIT 5;

-- Solution 4.4: Create automated task
CREATE OR REPLACE TASK process_orders_task
  WAREHOUSE = processing_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('ecommerce_raw.landing.orders_stream')
AS
  CALL process_orders();

-- Resume task
ALTER TASK process_orders_task RESUME;

-- Check task status
SHOW TASKS;

/*******************************************************************************
 * PHASE 5: Security Implementation - SOLUTION
 *******************************************************************************/

-- Solution 5.1: Grant privileges to roles
USE ROLE SECURITYADMIN;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE ingestion_wh TO ROLE data_engineer;
GRANT USAGE ON WAREHOUSE processing_wh TO ROLE data_engineer;
GRANT USAGE ON WAREHOUSE analytics_wh TO ROLE data_analyst;
GRANT USAGE ON WAREHOUSE analytics_wh TO ROLE regional_manager_north;
GRANT USAGE ON WAREHOUSE analytics_wh TO ROLE regional_manager_south;

-- Grant database and schema access
GRANT USAGE ON DATABASE ecommerce_curated TO ROLE data_engineer;
GRANT USAGE ON DATABASE ecommerce_curated TO ROLE data_analyst;
GRANT USAGE ON DATABASE ecommerce_analytics TO ROLE data_analyst;

GRANT USAGE ON SCHEMA ecommerce_curated.core TO ROLE data_engineer;
GRANT USAGE ON SCHEMA ecommerce_curated.core TO ROLE data_analyst;
GRANT USAGE ON SCHEMA ecommerce_analytics.reporting TO ROLE data_analyst;

-- Grant table privileges
GRANT ALL ON ALL TABLES IN SCHEMA ecommerce_curated.core TO ROLE data_engineer;
GRANT SELECT ON ALL TABLES IN SCHEMA ecommerce_curated.core TO ROLE data_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA ecommerce_analytics.reporting TO ROLE data_analyst;

-- Grant to regional managers
GRANT SELECT ON ALL TABLES IN SCHEMA ecommerce_curated.core TO ROLE regional_manager_north;
GRANT SELECT ON ALL TABLES IN SCHEMA ecommerce_curated.core TO ROLE regional_manager_south;

-- Future grants
GRANT SELECT ON FUTURE TABLES IN SCHEMA ecommerce_curated.core TO ROLE data_analyst;
GRANT SELECT ON FUTURE TABLES IN SCHEMA ecommerce_analytics.reporting TO ROLE data_analyst;

-- Solution 5.2: Create masking policies
USE ROLE SYSADMIN;
USE DATABASE ecommerce_curated;
USE SCHEMA core;

CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ECOMMERCE_ADMIN', 'DATA_ENGINEER') THEN val
    ELSE REGEXP_REPLACE(val, '^[^@]+', '***')
  END
  COMMENT = 'Mask email addresses for non-admin users';

CREATE OR REPLACE MASKING POLICY phone_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ECOMMERCE_ADMIN', 'DATA_ENGINEER') THEN val
    ELSE REGEXP_REPLACE(val, '\\d{4}$', 'XXXX')
  END
  COMMENT = 'Mask phone numbers for non-admin users';

-- Apply masking policies
ALTER TABLE customers MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE customers MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- Solution 5.3: Create row access policies
CREATE OR REPLACE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ECOMMERCE_ADMIN', 'DATA_ENGINEER', 'DATA_ANALYST') THEN TRUE
    WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_NORTH' AND region = 'NORTH' THEN TRUE
    WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_SOUTH' AND region = 'SOUTH' THEN TRUE
    WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_EAST' AND region = 'EAST' THEN TRUE
    WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_WEST' AND region = 'WEST' THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Restrict data access by region';

-- Apply row access policies
ALTER TABLE orders ADD ROW ACCESS POLICY regional_access ON (region);
ALTER TABLE customers ADD ROW ACCESS POLICY regional_access ON (region);

-- Solution 5.4: Configure Time Travel retention
ALTER TABLE orders SET DATA_RETENTION_TIME_IN_DAYS = 30;
ALTER TABLE customers SET DATA_RETENTION_TIME_IN_DAYS = 30;
ALTER TABLE products SET DATA_RETENTION_TIME_IN_DAYS = 7;

/*******************************************************************************
 * PHASE 6: Analytics Layer - SOLUTION
 *******************************************************************************/

USE DATABASE ecommerce_analytics;
USE SCHEMA reporting;
USE WAREHOUSE analytics_wh;

-- Solution 6.1: Create materialized views
CREATE OR REPLACE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
  order_date,
  region,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(*) as order_count,
  SUM(amount) as total_revenue,
  SUM(profit) as total_profit,
  AVG(amount) as avg_order_value,
  SUM(quantity) as total_units_sold
FROM ecommerce_curated.core.orders
GROUP BY order_date, region;

CREATE OR REPLACE MATERIALIZED VIEW customer_ltv AS
SELECT 
  c.customer_id,
  c.full_name,
  c.region,
  c.tier,
  c.signup_date,
  c.total_orders,
  c.total_spent as lifetime_value,
  c.avg_order_value,
  c.last_order_date,
  c.customer_lifetime_days,
  DATEDIFF(day, c.last_order_date, CURRENT_DATE()) as days_since_last_order,
  CASE 
    WHEN DATEDIFF(day, c.last_order_date, CURRENT_DATE()) > 90 THEN 'AT_RISK'
    WHEN DATEDIFF(day, c.last_order_date, CURRENT_DATE()) > 30 THEN 'INACTIVE'
    ELSE 'ACTIVE'
  END as customer_status
FROM ecommerce_curated.core.customers c
WHERE c.total_orders > 0;

CREATE OR REPLACE MATERIALIZED VIEW product_performance AS
SELECT 
  p.product_id,
  p.product_name,
  p.category,
  p.price,
  p.cost,
  p.margin_pct,
  COUNT(o.order_id) as times_ordered,
  SUM(o.quantity) as total_units_sold,
  SUM(o.amount) as total_revenue,
  SUM(o.profit) as total_profit,
  AVG(o.amount) as avg_order_value
FROM ecommerce_curated.core.products p
LEFT JOIN ecommerce_curated.core.orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price, p.cost, p.margin_pct;

-- Solution 6.2: Create secure views for analysts
CREATE OR REPLACE SECURE VIEW analyst_sales_view AS
SELECT 
  o.order_id,
  o.order_date,
  o.region,
  c.full_name as customer_name,
  c.tier as customer_tier,
  p.product_name,
  p.category,
  o.quantity,
  o.amount,
  o.status
FROM ecommerce_curated.core.orders o
JOIN ecommerce_curated.core.customers c ON o.customer_id = c.customer_id
JOIN ecommerce_curated.core.products p ON o.product_id = p.product_id;

CREATE OR REPLACE SECURE VIEW analyst_customer_view AS
SELECT 
  customer_id,
  full_name,
  region,
  tier,
  signup_date,
  total_orders,
  total_spent,
  avg_order_value,
  last_order_date,
  customer_lifetime_days
FROM ecommerce_curated.core.customers;

-- Grant access to secure views
GRANT SELECT ON VIEW analyst_sales_view TO ROLE data_analyst;
GRANT SELECT ON VIEW analyst_customer_view TO ROLE data_analyst;

-- Solution 6.3: Create dynamic table (optional)
CREATE OR REPLACE DYNAMIC TABLE regional_performance
  TARGET_LAG = '5 minutes'
  WAREHOUSE = analytics_wh
AS
SELECT 
  region,
  COUNT(DISTINCT customer_id) as total_customers,
  COUNT(*) as total_orders,
  SUM(amount) as total_revenue,
  SUM(profit) as total_profit,
  AVG(amount) as avg_order_value,
  CURRENT_TIMESTAMP() as last_updated
FROM ecommerce_curated.core.orders
GROUP BY region;

/*******************************************************************************
 * PHASE 7: Monitoring & Governance - SOLUTION
 *******************************************************************************/

USE DATABASE ecommerce_governance;
USE SCHEMA audit;

-- Solution 7.1: Create audit tables
CREATE OR REPLACE TABLE data_access_log (
  log_id INT AUTOINCREMENT,
  access_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  user_name STRING,
  role_name STRING,
  database_name STRING,
  schema_name STRING,
  table_name STRING,
  query_text STRING,
  rows_accessed INT
);

CREATE OR REPLACE TABLE etl_execution_log (
  execution_id INT AUTOINCREMENT,
  execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  procedure_name STRING,
  status STRING,
  rows_processed INT,
  execution_duration_seconds INT,
  error_message STRING
);

-- Solution 7.2: Create monitoring views
CREATE OR REPLACE VIEW query_performance AS
SELECT 
  query_id,
  user_name,
  role_name,
  warehouse_name,
  database_name,
  query_text,
  start_time,
  end_time,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned,
  rows_produced,
  execution_status
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name LIKE 'ECOMMERCE%'
  AND start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

CREATE OR REPLACE VIEW warehouse_usage AS
SELECT 
  warehouse_name,
  DATE(start_time) as usage_date,
  SUM(credits_used) as total_credits,
  COUNT(*) as query_count,
  AVG(total_elapsed_time) / 1000 as avg_query_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name IN ('INGESTION_WH', 'PROCESSING_WH', 'ANALYTICS_WH')
  AND start_time > DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY warehouse_name, DATE(start_time)
ORDER BY usage_date DESC, warehouse_name;

CREATE OR REPLACE VIEW task_execution_history AS
SELECT 
  name as task_name,
  database_name,
  schema_name,
  state,
  scheduled_time,
  completed_time,
  DATEDIFF(second, scheduled_time, completed_time) as duration_seconds,
  error_code,
  error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE database_name LIKE 'ECOMMERCE%'
  AND scheduled_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY scheduled_time DESC;

-- Solution 7.3: Create data quality checks
CREATE OR REPLACE VIEW data_quality_checks AS
SELECT 
  'Orders - Null Check' as check_name,
  COUNT(*) as issue_count,
  'FAIL' as status
FROM ecommerce_curated.core.orders
WHERE order_id IS NULL OR customer_id IS NULL OR amount IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
  'Orders - Negative Amount' as check_name,
  COUNT(*) as issue_count,
  'FAIL' as status
FROM ecommerce_curated.core.orders
WHERE amount < 0
HAVING COUNT(*) > 0

UNION ALL

SELECT 
  'Customers - Duplicate Check' as check_name,
  COUNT(*) - COUNT(DISTINCT customer_id) as issue_count,
  'FAIL' as status
FROM ecommerce_curated.core.customers
HAVING COUNT(*) - COUNT(DISTINCT customer_id) > 0

UNION ALL

SELECT 
  'Orders - Future Dates' as check_name,
  COUNT(*) as issue_count,
  'FAIL' as status
FROM ecommerce_curated.core.orders
WHERE order_date > CURRENT_DATE()
HAVING COUNT(*) > 0;

-- If no issues, show success
SELECT 
  CASE 
    WHEN (SELECT COUNT(*) FROM data_quality_checks) = 0 
    THEN 'All data quality checks passed'
    ELSE 'Data quality issues found'
  END as overall_status;

/*******************************************************************************
 * PHASE 8: Testing & Validation - SOLUTION
 *******************************************************************************/

-- Solution 8.1: Test data ingestion
USE DATABASE ecommerce_raw;
USE SCHEMA landing;

SELECT 'Raw Orders' as table_name, COUNT(*) as row_count FROM raw_orders
UNION ALL
SELECT 'Raw Customers', COUNT(*) FROM raw_customers
UNION ALL
SELECT 'Raw Products', COUNT(*) FROM raw_products;

-- Solution 8.2: Test stream processing
SELECT SYSTEM$STREAM_HAS_DATA('orders_stream') as orders_stream_has_data;
SELECT SYSTEM$STREAM_HAS_DATA('customers_stream') as customers_stream_has_data;

-- View stream contents
SELECT * FROM orders_stream LIMIT 5;

-- Solution 8.3: Test task execution
SHOW TASKS;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name = 'PROCESS_ORDERS_TASK'
ORDER BY scheduled_time DESC
LIMIT 5;

-- Manually execute task for testing
EXECUTE TASK ecommerce_curated.core.process_orders_task;

-- Solution 8.4: Test security policies
-- Test as data_analyst (should see all regions, masked PII)
USE ROLE data_analyst;
USE DATABASE ecommerce_curated;
USE SCHEMA core;

SELECT COUNT(*) as total_orders FROM orders;
SELECT email, phone FROM customers LIMIT 3;  -- Should be masked

-- Test as regional_manager_north (should only see NORTH region)
USE ROLE regional_manager_north;
SELECT DISTINCT region FROM orders;  -- Should only show NORTH
SELECT COUNT(*) as my_region_orders FROM orders;

-- Switch back to admin
USE ROLE SYSADMIN;

-- Solution 8.5: Test performance
USE DATABASE ecommerce_curated;
USE SCHEMA core;
USE WAREHOUSE analytics_wh;

-- Test clustering effectiveness
SELECT SYSTEM$CLUSTERING_INFORMATION('orders');

-- Test query performance on clustered table
SELECT 
  order_date,
  region,
  COUNT(*) as order_count,
  SUM(amount) as total_sales
FROM orders
WHERE order_date >= DATEADD(day, -7, CURRENT_DATE())
  AND region = 'NORTH'
GROUP BY order_date, region
ORDER BY order_date;

-- Check query profile
SELECT 
  query_id,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 as mb_scanned
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%order_date%'
  AND query_text ILIKE '%region%'
ORDER BY start_time DESC
LIMIT 1;

-- Solution 8.6: Test UDFs
SELECT 
  1000 as amount,
  calculate_tier(1000) as tier,
  calculate_discount(calculate_tier(1000)) as discount
UNION ALL
SELECT 
  3000 as amount,
  calculate_tier(3000) as tier,
  calculate_discount(calculate_tier(3000)) as discount
UNION ALL
SELECT 
  6000 as amount,
  calculate_tier(6000) as tier,
  calculate_discount(calculate_tier(6000)) as discount;

-- Test materialized views
USE DATABASE ecommerce_analytics;
USE SCHEMA reporting;

SELECT * FROM daily_sales_summary ORDER BY order_date DESC LIMIT 5;
SELECT * FROM customer_ltv ORDER BY lifetime_value DESC LIMIT 5;
SELECT * FROM product_performance ORDER BY total_revenue DESC LIMIT 5;

/*******************************************************************************
 * PHASE 9: Documentation - SOLUTION
 *******************************************************************************/

-- Solution 9.1: Architecture Documentation
/*
ARCHITECTURE OVERVIEW
=====================

Databases:
- ecommerce_raw: Landing zone for incoming data from source systems
- ecommerce_curated: Cleaned, enriched, and business-ready data
- ecommerce_analytics: Aggregated data for reporting and analytics
- ecommerce_governance: Audit logs and monitoring metadata

Warehouses:
- ingestion_wh (XSMALL): For data ingestion, auto-suspend 60s
- processing_wh (SMALL): For ETL processing, auto-suspend 300s
- analytics_wh (MEDIUM): For analytics queries, auto-suspend 600s

Security:
- Role hierarchy: ecommerce_admin > data_engineer, data_analyst > regional_managers
- Masking policies: email and phone masked for non-admin users
- Row access policies: Regional managers see only their region's data
- Time Travel: 30 days for critical tables, 7 days for reference data

Performance:
- Clustering: orders table clustered by (order_date, region)
- Materialized views: Pre-aggregated data for fast dashboard queries
- Dynamic tables: Real-time regional performance metrics
- Warehouse sizing: Appropriate sizing for each workload type
*/

-- Solution 9.2: Data Flow Documentation
/*
DATA FLOW
=========

1. INGESTION (Raw Layer)
   - Source: S3 buckets with JSON/CSV files
   - Method: Snowpipe with auto-ingest
   - Destination: raw_orders, raw_customers, raw_products
   - Frequency: Continuous (as files arrive)

2. CHANGE TRACKING
   - Streams: orders_stream, customers_stream
   - Captures: INSERT, UPDATE, DELETE operations
   - Purpose: Enable incremental processing

3. TRANSFORMATION (Curated Layer)
   - Trigger: Task runs every 5 minutes when stream has data
   - Process: process_orders() stored procedure
   - Operations:
     * Clean and validate data
     * Enrich with calculated fields
     * Update customer metrics
     * Apply business rules
   - Destination: orders, customers, products tables

4. AGGREGATION (Analytics Layer)
   - Materialized Views: Pre-computed aggregations
     * daily_sales_summary: Daily metrics by region
     * customer_ltv: Customer lifetime value analysis
     * product_performance: Product sales metrics
   - Dynamic Tables: Real-time regional performance
   - Refresh: Automatic based on source data changes

5. PRESENTATION
   - Secure Views: analyst_sales_view, analyst_customer_view
   - Access: Role-based with masking and row-level security
   - Consumption: BI tools, APIs, ad-hoc queries
*/

-- Solution 9.3: Runbook
/*
OPERATIONS RUNBOOK
==================

1. REFRESH DATA MANUALLY
   - Check stream status: SELECT SYSTEM$STREAM_HAS_DATA('orders_stream');
   - Execute task: EXECUTE TASK process_orders_task;
   - Verify: SELECT * FROM etl_execution_log ORDER BY execution_time DESC LIMIT 1;

2. ADD NEW USER
   - Determine appropriate role (data_analyst, regional_manager_north, etc.)
   - USE ROLE SECURITYADMIN;
   - CREATE USER new_user PASSWORD='...' DEFAULT_ROLE=data_analyst;
   - GRANT ROLE data_analyst TO USER new_user;

3. TROUBLESHOOT FAILED TASKS
   - Check task history:
     SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
     WHERE name = 'PROCESS_ORDERS_TASK' AND state = 'FAILED'
     ORDER BY scheduled_time DESC LIMIT 5;
   - Review error message in error_message column
   - Check stream data: SELECT * FROM orders_stream LIMIT 10;
   - Manually test procedure: CALL process_orders();
   - Fix issue and resume task: ALTER TASK process_orders_task RESUME;

4. RECOVER FROM DATA LOSS
   - Identify when data was lost
   - Use Time Travel to query historical data:
     SELECT * FROM orders AT(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);
   - Restore data:
     INSERT INTO orders SELECT * FROM orders 
     BEFORE(STATEMENT => '<delete_query_id>') WHERE ...;
   - Verify recovery: Compare row counts and data integrity

5. MONITOR PERFORMANCE
   - Check warehouse usage:
     SELECT * FROM ecommerce_governance.audit.warehouse_usage;
   - Review slow queries:
     SELECT * FROM ecommerce_governance.audit.query_performance
     WHERE elapsed_seconds > 10 ORDER BY elapsed_seconds DESC;
   - Check clustering:
     SELECT SYSTEM$CLUSTERING_INFORMATION('orders');

6. SCALE WAREHOUSE
   - Identify bottleneck warehouse
   - ALTER WAREHOUSE processing_wh SET WAREHOUSE_SIZE = 'MEDIUM';
   - Monitor impact on performance and cost
   - Adjust as needed
*/

-- Solution 9.4: Key Monitoring Queries
/*
MONITORING QUERIES
==================

1. Pipeline Health
*/
SELECT 
  'Orders Stream' as component,
  SYSTEM$STREAM_HAS_DATA('ecommerce_raw.landing.orders_stream') as has_data,
  (SELECT COUNT(*) FROM ecommerce_raw.landing.orders_stream) as pending_records
UNION ALL
SELECT 
  'Process Orders Task' as component,
  (SELECT state FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
   WHERE name = 'PROCESS_ORDERS_TASK' ORDER BY scheduled_time DESC LIMIT 1) as has_data,
  NULL as pending_records;

/*
2. Performance Metrics
*/
SELECT 
  DATE(start_time) as query_date,
  warehouse_name,
  COUNT(*) as query_count,
  AVG(total_elapsed_time) / 1000 as avg_seconds,
  SUM(bytes_scanned) / 1024 / 1024 / 1024 as total_gb_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name LIKE 'ECOMMERCE%'
  AND start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY DATE(start_time), warehouse_name
ORDER BY query_date DESC, warehouse_name;

/*
3. Cost Tracking
*/
SELECT 
  warehouse_name,
  DATE(start_time) as usage_date,
  SUM(credits_used) as daily_credits,
  SUM(credits_used) * 3.00 as estimated_cost_usd  -- Adjust rate as needed
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name IN ('INGESTION_WH', 'PROCESSING_WH', 'ANALYTICS_WH')
  AND start_time > DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY warehouse_name, DATE(start_time)
ORDER BY usage_date DESC, warehouse_name;

/*
4. Data Quality
*/
SELECT * FROM ecommerce_governance.audit.data_quality_checks;

/*******************************************************************************
 * PROJECT SUMMARY
 *******************************************************************************/

-- Generate project summary report
SELECT '=== E-COMMERCE ANALYTICS PLATFORM - PROJECT SUMMARY ===' as report;

SELECT 'Database Objects' as category, 'Databases' as object_type, COUNT(*) as count
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE 'ECOMMERCE%' AND deleted IS NULL
UNION ALL
SELECT 'Database Objects', 'Tables', COUNT(*)
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE table_catalog LIKE 'ECOMMERCE%' AND deleted IS NULL
UNION ALL
SELECT 'Database Objects', 'Views', COUNT(*)
FROM SNOWFLAKE.ACCOUNT_USAGE.VIEWS
WHERE table_catalog LIKE 'ECOMMERCE%' AND deleted IS NULL
UNION ALL
SELECT 'Database Objects', 'Materialized Views', COUNT(*)
FROM SNOWFLAKE.ACCOUNT_USAGE.VIEWS
WHERE table_catalog LIKE 'ECOMMERCE%' AND is_materialized = 'YES' AND deleted IS NULL
UNION ALL
SELECT 'Security', 'Masking Policies', COUNT(DISTINCT policy_name)
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'MASKING_POLICY' AND ref_database_name LIKE 'ECOMMERCE%'
UNION ALL
SELECT 'Security', 'Row Access Policies', COUNT(DISTINCT policy_name)
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'ROW_ACCESS_POLICY' AND ref_database_name LIKE 'ECOMMERCE%'
UNION ALL
SELECT 'Automation', 'Active Tasks', COUNT(*)
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE database_name LIKE 'ECOMMERCE%' AND state = 'SCHEDULED'
UNION ALL
SELECT 'Automation', 'Streams', COUNT(*)
FROM SNOWFLAKE.ACCOUNT_USAGE.STREAMS
WHERE table_catalog LIKE 'ECOMMERCE%' AND deleted IS NULL;

-- Data summary
SELECT 'Data Summary' as category, 'Orders' as table_name, COUNT(*) as row_count
FROM ecommerce_curated.core.orders
UNION ALL
SELECT 'Data Summary', 'Customers', COUNT(*)
FROM ecommerce_curated.core.customers
UNION ALL
SELECT 'Data Summary', 'Products', COUNT(*)
FROM ecommerce_curated.core.products;

/*******************************************************************************
 * CONGRATULATIONS!
 * 
 * You've successfully built a complete end-to-end data engineering solution
 * incorporating concepts from all 4 weeks of the bootcamp:
 * 
 * ✅ Week 1: Data Movement & Transformation
 *    - Snowpipe for continuous loading
 *    - Streams for change data capture
 *    - Tasks for automated processing
 *    - Stored procedures for ETL logic
 * 
 * ✅ Week 2: Performance Optimization
 *    - Clustering on frequently queried columns
 *    - Materialized views for fast queries
 *    - Warehouse sizing and optimization
 *    - Query performance monitoring
 * 
 * ✅ Week 3: Security & Governance
 *    - RBAC with role hierarchy
 *    - Data masking for PII protection
 *    - Row-level security for regional isolation
 *    - Time Travel for data recovery
 *    - Audit logging and monitoring
 * 
 * ✅ Week 4: Advanced Features
 *    - Stored procedures for complex logic
 *    - UDFs for business calculations
 *    - Dynamic tables for real-time metrics
 *    - Comprehensive error handling
 * 
 * This project demonstrates production-ready data engineering practices
 * and prepares you for real-world Snowflake implementations.
 * 
 * Next: Practice Exams to test your certification readiness!
 * 
 *******************************************************************************/
