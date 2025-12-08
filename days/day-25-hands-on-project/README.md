# Day 25: Hands-On Project Day

## 📖 Project Overview (15 min)

Today you'll build a **complete end-to-end data engineering solution** that integrates concepts from all 4 weeks of the bootcamp.

**Project: Real-Time E-Commerce Analytics Platform**

Build a production-ready data pipeline that:
- Ingests streaming order data from S3 (Snowpipe)
- Tracks changes with Streams
- Processes data incrementally with Tasks
- Optimizes performance with clustering and materialized views
- Implements security with RBAC, masking, and row-level security
- Provides data recovery with Time Travel
- Creates reusable components with stored procedures and UDFs
- Monitors and audits all operations

**Time Allocation:**
- Planning & Setup: 10 minutes
- Implementation: 80 minutes
- Testing & Validation: 10 minutes
- Documentation: 20 minutes

**Total Time: 2 hours**

---

## Project Requirements

### Business Context

You're building an analytics platform for an e-commerce company with:
- **Multiple regions**: NORTH, SOUTH, EAST, WEST
- **Customer tiers**: PLATINUM, GOLD, SILVER, BRONZE
- **Real-time requirements**: Orders must be processed within minutes
- **Security requirements**: Regional managers can only see their region's data
- **Compliance**: PII must be masked for analysts
- **Performance**: Dashboards must load in < 2 seconds

### Technical Requirements

**Week 1: Data Movement & Transformation**
- ✅ Snowpipe for continuous data loading
- ✅ Streams for change data capture
- ✅ Tasks for automated processing
- ✅ Dynamic tables or materialized views for aggregations

**Week 2: Performance Optimization**
- ✅ Clustering on frequently queried columns
- ✅ Materialized views for dashboard queries
- ✅ Optimized warehouse sizing
- ✅ Query performance monitoring

**Week 3: Security & Governance**
- ✅ RBAC with role hierarchy
- ✅ Data masking for PII
- ✅ Row-level security for regional isolation
- ✅ Time Travel configuration
- ✅ Audit logging

**Week 4: Advanced Features**
- ✅ Stored procedures for ETL orchestration
- ✅ UDFs for business logic
- ✅ Error handling and monitoring

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                              │
│  S3 Bucket: orders/*.json, customers/*.csv, products/*.csv      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INGESTION LAYER                               │
│  • Snowpipe (auto-ingest from S3)                               │
│  • External Stage                                                │
│  • File Format (JSON, CSV)                                      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     RAW LAYER                                    │
│  • raw_orders (landing table)                                   │
│  • raw_customers                                                 │
│  • raw_products                                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  CHANGE TRACKING                                 │
│  • orders_stream (CDC on raw_orders)                            │
│  • customers_stream                                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                 PROCESSING LAYER                                 │
│  • Task: process_orders_task (every 5 min)                      │
│  • Task: update_customer_metrics_task                           │
│  • Stored Procedure: run_etl_pipeline()                         │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   CURATED LAYER                                  │
│  • orders (cleaned, enriched)                                   │
│  • customers (with metrics)                                      │
│  • products                                                      │
│  • Clustering: order_date, region                               │
│  • Masking: email, phone                                        │
│  • Row Access: region-based                                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                 AGGREGATION LAYER                                │
│  • daily_sales_summary (materialized view)                      │
│  • customer_lifetime_value (materialized view)                  │
│  • product_performance (dynamic table)                          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                             │
│  • Secure views for analysts                                    │
│  • Dashboards (BI tools)                                        │
│  • APIs (external access)                                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                  GOVERNANCE & MONITORING                         │
│  • Audit logs                                                    │
│  • Performance monitoring                                        │
│  • Cost tracking                                                 │
│  • Data quality checks                                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Guide

### Phase 1: Setup & Infrastructure (10 min)

**1.1 Create Database Structure**
```sql
-- Create databases
CREATE DATABASE ecommerce_raw;
CREATE DATABASE ecommerce_curated;
CREATE DATABASE ecommerce_analytics;
CREATE DATABASE ecommerce_governance;

-- Create schemas
CREATE SCHEMA ecommerce_raw.landing;
CREATE SCHEMA ecommerce_curated.core;
CREATE SCHEMA ecommerce_analytics.reporting;
CREATE SCHEMA ecommerce_governance.audit;
```

**1.2 Create Warehouses**
```sql
-- Ingestion warehouse (small, auto-suspend quickly)
CREATE WAREHOUSE ingestion_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Processing warehouse (medium, for ETL)
CREATE WAREHOUSE processing_wh
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE;

-- Analytics warehouse (large, for queries)
CREATE WAREHOUSE analytics_wh
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 600
  AUTO_RESUME = TRUE;
```

**1.3 Create Roles**
```sql
-- Role hierarchy
CREATE ROLE ecommerce_admin;
CREATE ROLE data_engineer;
CREATE ROLE data_analyst;
CREATE ROLE regional_manager_north;
CREATE ROLE regional_manager_south;

-- Grant hierarchy
GRANT ROLE data_engineer TO ROLE ecommerce_admin;
GRANT ROLE data_analyst TO ROLE ecommerce_admin;
GRANT ROLE regional_manager_north TO ROLE data_analyst;
GRANT ROLE regional_manager_south TO ROLE data_analyst;
```

### Phase 2: Data Ingestion (15 min)

**2.1 Create External Stage**
```sql
-- Create stage pointing to S3
CREATE OR REPLACE STAGE ecommerce_raw.landing.s3_stage
  URL = 's3://your-bucket/ecommerce/'
  CREDENTIALS = (AWS_KEY_ID = 'xxx' AWS_SECRET_KEY = 'yyy');

-- Create file formats
CREATE FILE FORMAT ecommerce_raw.landing.json_format
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

CREATE FILE FORMAT ecommerce_raw.landing.csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1;
```

**2.2 Create Landing Tables**
```sql
-- Raw orders table
CREATE TABLE ecommerce_raw.landing.raw_orders (
  order_id INT,
  customer_id INT,
  product_id INT,
  order_date TIMESTAMP,
  quantity INT,
  amount DECIMAL(10,2),
  region STRING,
  status STRING,
  loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Raw customers table
CREATE TABLE ecommerce_raw.landing.raw_customers (
  customer_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  region STRING,
  tier STRING,
  signup_date DATE,
  loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

**2.3 Create Snowpipe**
```sql
-- Snowpipe for orders
CREATE PIPE ecommerce_raw.landing.orders_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO ecommerce_raw.landing.raw_orders
  FROM @ecommerce_raw.landing.s3_stage/orders/
  FILE_FORMAT = ecommerce_raw.landing.json_format;

-- Show pipe status
SHOW PIPES;
```

### Phase 3: Change Tracking (10 min)

**3.1 Create Streams**
```sql
-- Stream on raw_orders
CREATE STREAM ecommerce_raw.landing.orders_stream
  ON TABLE ecommerce_raw.landing.raw_orders;

-- Stream on raw_customers
CREATE STREAM ecommerce_raw.landing.customers_stream
  ON TABLE ecommerce_raw.landing.raw_customers;
```

### Phase 4: Data Processing (20 min)

**4.1 Create Curated Tables**
```sql
-- Orders table with clustering
CREATE TABLE ecommerce_curated.core.orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  order_date DATE,
  order_timestamp TIMESTAMP,
  quantity INT,
  amount DECIMAL(10,2),
  region STRING,
  status STRING,
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) CLUSTER BY (order_date, region);

-- Customers table
CREATE TABLE ecommerce_curated.core.customers (
  customer_id INT PRIMARY KEY,
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  region STRING,
  tier STRING,
  signup_date DATE,
  total_orders INT DEFAULT 0,
  total_spent DECIMAL(12,2) DEFAULT 0,
  last_order_date DATE,
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

**4.2 Create Processing Stored Procedure**
```sql
CREATE OR REPLACE PROCEDURE ecommerce_curated.core.process_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  rows_processed INT;
BEGIN
  -- Process new orders from stream
  MERGE INTO ecommerce_curated.core.orders o
  USING ecommerce_raw.landing.orders_stream s
  ON o.order_id = s.order_id
  WHEN MATCHED AND s.METADATA$ACTION = 'DELETE' THEN
    DELETE
  WHEN MATCHED AND s.METADATA$ACTION = 'INSERT' THEN
    UPDATE SET
      quantity = s.quantity,
      amount = s.amount,
      status = s.status,
      processed_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED AND s.METADATA$ACTION = 'INSERT' THEN
    INSERT VALUES (
      s.order_id, s.customer_id, s.product_id,
      s.order_date::DATE, s.order_date,
      s.quantity, s.amount, s.region, s.status,
      CURRENT_TIMESTAMP()
    );
  
  rows_processed := SQLROWCOUNT;
  
  -- Update customer metrics
  MERGE INTO ecommerce_curated.core.customers c
  USING (
    SELECT 
      customer_id,
      COUNT(*) as order_count,
      SUM(amount) as total_amount,
      MAX(order_date) as last_order
    FROM ecommerce_curated.core.orders
    GROUP BY customer_id
  ) o
  ON c.customer_id = o.customer_id
  WHEN MATCHED THEN
    UPDATE SET
      total_orders = o.order_count,
      total_spent = o.total_amount,
      last_order_date = o.last_order,
      processed_at = CURRENT_TIMESTAMP();
  
  RETURN 'Processed ' || rows_processed || ' orders';
END;
$$;
```

**4.3 Create Automated Task**
```sql
-- Task to process orders every 5 minutes
CREATE TASK ecommerce_curated.core.process_orders_task
  WAREHOUSE = processing_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('ecommerce_raw.landing.orders_stream')
AS
  CALL ecommerce_curated.core.process_orders();

-- Resume task
ALTER TASK ecommerce_curated.core.process_orders_task RESUME;
```

### Phase 5: Security Implementation (15 min)

**5.1 Create Masking Policies**
```sql
-- Email masking
CREATE MASKING POLICY ecommerce_curated.core.email_mask AS (val STRING)
RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ECOMMERCE_ADMIN', 'DATA_ENGINEER') THEN val
    ELSE REGEXP_REPLACE(val, '^[^@]+', '***')
  END;

-- Apply masking
ALTER TABLE ecommerce_curated.core.customers
  MODIFY COLUMN email SET MASKING POLICY ecommerce_curated.core.email_mask;
```

**5.2 Create Row Access Policy**
```sql
-- Regional access policy
CREATE ROW ACCESS POLICY ecommerce_curated.core.regional_access
  AS (region STRING) RETURNS BOOLEAN ->
    CASE
      WHEN CURRENT_ROLE() IN ('ECOMMERCE_ADMIN', 'DATA_ENGINEER', 'DATA_ANALYST') THEN TRUE
      WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_NORTH' AND region = 'NORTH' THEN TRUE
      WHEN CURRENT_ROLE() = 'REGIONAL_MANAGER_SOUTH' AND region = 'SOUTH' THEN TRUE
      ELSE FALSE
    END;

-- Apply to tables
ALTER TABLE ecommerce_curated.core.orders
  ADD ROW ACCESS POLICY ecommerce_curated.core.regional_access ON (region);

ALTER TABLE ecommerce_curated.core.customers
  ADD ROW ACCESS POLICY ecommerce_curated.core.regional_access ON (region);
```

### Phase 6: Analytics Layer (10 min)

**6.1 Create Materialized Views**
```sql
-- Daily sales summary
CREATE MATERIALIZED VIEW ecommerce_analytics.reporting.daily_sales_summary AS
SELECT 
  order_date,
  region,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(*) as order_count,
  SUM(amount) as total_revenue,
  AVG(amount) as avg_order_value
FROM ecommerce_curated.core.orders
GROUP BY order_date, region;

-- Customer lifetime value
CREATE MATERIALIZED VIEW ecommerce_analytics.reporting.customer_ltv AS
SELECT 
  c.customer_id,
  c.first_name || ' ' || c.last_name as customer_name,
  c.region,
  c.tier,
  c.total_orders,
  c.total_spent as lifetime_value,
  c.total_spent / NULLIF(c.total_orders, 0) as avg_order_value,
  DATEDIFF(day, c.signup_date, CURRENT_DATE()) as customer_age_days
FROM ecommerce_curated.core.customers c
WHERE c.total_orders > 0;
```

### Phase 7: Monitoring & Governance (10 min)

**7.1 Create Audit Tables**
```sql
-- Audit log
CREATE TABLE ecommerce_governance.audit.data_access_log (
  access_time TIMESTAMP,
  user_name STRING,
  role_name STRING,
  query_text STRING,
  rows_accessed INT
);

-- Performance monitoring
CREATE VIEW ecommerce_governance.audit.query_performance AS
SELECT 
  query_id,
  user_name,
  role_name,
  warehouse_name,
  query_text,
  total_elapsed_time / 1000 as elapsed_seconds,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned,
  rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name LIKE 'ECOMMERCE%'
  AND start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

---

## Testing & Validation

### Test 1: Data Ingestion
```sql
-- Verify Snowpipe is working
SELECT SYSTEM$PIPE_STATUS('ecommerce_raw.landing.orders_pipe');

-- Check raw data
SELECT COUNT(*) FROM ecommerce_raw.landing.raw_orders;
```

### Test 2: Stream Processing
```sql
-- Check stream has data
SELECT SYSTEM$STREAM_HAS_DATA('ecommerce_raw.landing.orders_stream');

-- View stream contents
SELECT * FROM ecommerce_raw.landing.orders_stream LIMIT 10;
```

### Test 3: Task Execution
```sql
-- Check task status
SHOW TASKS;

-- View task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name = 'PROCESS_ORDERS_TASK'
ORDER BY scheduled_time DESC
LIMIT 10;
```

### Test 4: Security
```sql
-- Test as regional manager
USE ROLE regional_manager_north;
SELECT COUNT(*) FROM ecommerce_curated.core.orders;  -- Should only see NORTH

-- Test masking
SELECT email FROM ecommerce_curated.core.customers LIMIT 5;  -- Should be masked
```

### Test 5: Performance
```sql
-- Test clustering effectiveness
SELECT SYSTEM$CLUSTERING_INFORMATION('ecommerce_curated.core.orders');

-- Test query performance
SELECT 
  order_date,
  region,
  SUM(amount) as total_sales
FROM ecommerce_curated.core.orders
WHERE order_date >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY order_date, region;
```

---

## Documentation Checklist

- [ ] Architecture diagram
- [ ] Data flow documentation
- [ ] Security policies documented
- [ ] Monitoring queries saved
- [ ] Runbook for common operations
- [ ] Disaster recovery procedures
- [ ] Performance baseline metrics

---

## 💻 Complete Implementation (80 min)

Complete the full project in `exercise.sql`.

---

## 🎯 Success Criteria

Your project is complete when:
- ✅ Data flows from S3 to analytics layer
- ✅ Streams capture all changes
- ✅ Tasks run automatically
- ✅ Security policies are enforced
- ✅ Queries perform well (< 2 seconds)
- ✅ Monitoring is in place
- ✅ All tests pass

---

## 📚 Additional Resources

- Review Days 1-24 for specific concepts
- Snowflake Best Practices Guide
- Your notes from previous days

---

## 🔜 Tomorrow: Day 26 - Practice Exam 1

Tomorrow you'll take your first full-length practice exam (65 questions, 115 minutes) to assess your readiness for the certification.
