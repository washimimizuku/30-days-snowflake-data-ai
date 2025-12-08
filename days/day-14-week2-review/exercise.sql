/*
Day 14: Week 2 Review & Performance Optimization Lab - Exercises
Complete performance optimization project
Time: 90 minutes
*/

-- ============================================================================
-- Setup: Create Sample Data Warehouse (10 min)
-- ============================================================================

USE DATABASE BOOTCAMP_DB;
CREATE SCHEMA IF NOT EXISTS DAY14_PERFORMANCE_LAB;
USE SCHEMA DAY14_PERFORMANCE_LAB;

-- Create large tables simulating retail data warehouse
CREATE OR REPLACE TABLE orders (
  order_id INT,
  customer_id INT,
  order_date DATE,
  order_timestamp TIMESTAMP,
  total_amount DECIMAL(10,2),
  status VARCHAR(20),
  region VARCHAR(50),
  payment_method VARCHAR(20)
);

CREATE OR REPLACE TABLE customers (
  customer_id INT,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20),
  signup_date DATE,
  region VARCHAR(50),
  customer_segment VARCHAR(20),
  lifetime_value DECIMAL(10,2)
);

CREATE OR REPLACE TABLE products (
  product_id INT,
  product_name VARCHAR(200),
  category VARCHAR(50),
  subcategory VARCHAR(50),
  price DECIMAL(10,2),
  cost DECIMAL(10,2)
);

CREATE OR REPLACE TABLE order_items (
  order_item_id INT,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  discount_percent DECIMAL(5,2)
);

-- Insert sample data (simulating large tables)

-- TODO: Insert sample orders (1M rows)
-- INSERT INTO orders
-- SELECT 
--   SEQ4() as order_id,
--   UNIFORM(1, 100000, RANDOM()) as customer_id,
--   DATEADD(day, UNIFORM(0, 730, RANDOM()), '2023-01-01'::DATE) as order_date,
--   DATEADD(second, UNIFORM(0, 86400, RANDOM()), order_date::TIMESTAMP) as order_timestamp,
--   ROUND(UNIFORM(10, 1000, RANDOM()), 2) as total_amount,
--   CASE UNIFORM(1, 5, RANDOM())
--     WHEN 1 THEN 'PENDING'
--     WHEN 2 THEN 'PROCESSING'
--     WHEN 3 THEN 'SHIPPED'
--     WHEN 4 THEN 'DELIVERED'
--     ELSE 'CANCELLED'
--   END as status,
--   CASE UNIFORM(1, 4, RANDOM())
--     WHEN 1 THEN 'NORTH'
--     WHEN 2 THEN 'SOUTH'
--     WHEN 3 THEN 'EAST'
--     ELSE 'WEST'
--   END as region,
--   CASE UNIFORM(1, 3, RANDOM())
--     WHEN 1 THEN 'CREDIT_CARD'
--     WHEN 2 THEN 'DEBIT_CARD'
--     ELSE 'PAYPAL'
--   END as payment_method
-- FROM TABLE(GENERATOR(ROWCOUNT => 1000000));

-- TODO: Insert sample customers (100K rows)
-- INSERT INTO customers
-- SELECT 
--   SEQ4() as customer_id,
--   'Customer_' || SEQ4() as customer_name,
--   'customer' || SEQ4() || '@example.com' as email,
--   '+1-555-' || LPAD(UNIFORM(1000000, 9999999, RANDOM())::VARCHAR, 7, '0') as phone,
--   DATEADD(day, UNIFORM(0, 1095, RANDOM()), '2021-01-01'::DATE) as signup_date,
--   CASE UNIFORM(1, 4, RANDOM())
--     WHEN 1 THEN 'NORTH'
--     WHEN 2 THEN 'SOUTH'
--     WHEN 3 THEN 'EAST'
--     ELSE 'WEST'
--   END as region,
--   CASE UNIFORM(1, 3, RANDOM())
--     WHEN 1 THEN 'PREMIUM'
--     WHEN 2 THEN 'STANDARD'
--     ELSE 'BASIC'
--   END as customer_segment,
--   ROUND(UNIFORM(100, 50000, RANDOM()), 2) as lifetime_value
-- FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- TODO: Insert sample products (10K rows)
-- INSERT INTO products
-- SELECT 
--   SEQ4() as product_id,
--   'Product_' || SEQ4() as product_name,
--   CASE UNIFORM(1, 5, RANDOM())
--     WHEN 1 THEN 'Electronics'
--     WHEN 2 THEN 'Clothing'
--     WHEN 3 THEN 'Home'
--     WHEN 4 THEN 'Sports'
--     ELSE 'Books'
--   END as category,
--   'Subcategory_' || UNIFORM(1, 20, RANDOM()) as subcategory,
--   ROUND(UNIFORM(10, 500, RANDOM()), 2) as price,
--   ROUND(UNIFORM(5, 250, RANDOM()), 2) as cost
-- FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- TODO: Insert sample order_items (5M rows)
-- INSERT INTO order_items
-- SELECT 
--   SEQ4() as order_item_id,
--   UNIFORM(1, 1000000, RANDOM()) as order_id,
--   UNIFORM(1, 10000, RANDOM()) as product_id,
--   UNIFORM(1, 5, RANDOM()) as quantity,
--   ROUND(UNIFORM(10, 500, RANDOM()), 2) as unit_price,
--   ROUND(UNIFORM(0, 20, RANDOM()), 2) as discount_percent
-- FROM TABLE(GENERATOR(ROWCOUNT => 5000000));


-- ============================================================================
-- Exercise 1: Baseline Analysis (15 min)
-- ============================================================================

-- TODO: Analyze current query performance
-- Test Query 1: Daily sales dashboard (run frequently)
-- SELECT 
--   order_date,
--   region,
--   COUNT(*) as order_count,
--   SUM(total_amount) as total_sales,
--   AVG(total_amount) as avg_order_value
-- FROM orders
-- WHERE order_date >= '2024-01-01'
-- GROUP BY order_date, region
-- ORDER BY order_date DESC, total_sales DESC;

-- TODO: Note execution time and check Query Profile

-- Test Query 2: Customer lookup (point lookup)
-- SELECT * FROM customers WHERE customer_id = 12345;

-- Test Query 3: Product performance report
-- SELECT 
--   p.category,
--   p.subcategory,
--   COUNT(DISTINCT oi.order_id) as order_count,
--   SUM(oi.quantity * oi.unit_price) as revenue
-- FROM order_items oi
-- JOIN products p ON oi.product_id = p.product_id
-- GROUP BY p.category, p.subcategory
-- ORDER BY revenue DESC;

-- Test Query 4: Regional analysis
-- SELECT 
--   c.region,
--   c.customer_segment,
--   COUNT(DISTINCT o.order_id) as order_count,
--   SUM(o.total_amount) as total_revenue
-- FROM orders o
-- JOIN customers c ON o.customer_id = c.customer_id
-- WHERE o.order_date >= '2024-01-01'
-- GROUP BY c.region, c.customer_segment;

-- TODO: Check partition pruning
-- SELECT 
--   query_id,
--   query_text,
--   execution_time,
--   partitions_scanned,
--   partitions_total,
--   ROUND((partitions_scanned::FLOAT / NULLIF(partitions_total, 0)) * 100, 2) as scan_pct
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%orders%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;

-- TODO: Calculate current costs
-- SELECT 
--   warehouse_name,
--   SUM(credits_used) as total_credits,
--   ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
-- GROUP BY warehouse_name
-- ORDER BY total_credits DESC;

-- TODO: Measure cache hit rates
-- SELECT 
--   COUNT(*) as total_queries,
--   SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as cache_hits,
--   ROUND((cache_hits / NULLIF(total_queries, 0)) * 100, 2) as cache_hit_rate_pct
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND execution_status = 'SUCCESS';


-- ============================================================================
-- Exercise 2: Clustering Optimization (20 min)
-- ============================================================================

-- TODO: Analyze query patterns to determine clustering keys
-- Orders table: Most queries filter by order_date
-- Customers table: Lookups by customer_id, filters by region

-- TODO: Add clustering key to orders table
-- ALTER TABLE orders CLUSTER BY (order_date);

-- TODO: Add clustering key to customers table
-- ALTER TABLE customers CLUSTER BY (customer_id);

-- TODO: Check clustering information
-- SELECT SYSTEM$CLUSTERING_INFORMATION('orders', '(order_date)');
-- SELECT SYSTEM$CLUSTERING_INFORMATION('customers', '(customer_id)');

-- TODO: Monitor clustering depth
-- SELECT 
--   table_name,
--   clustering_key,
--   AVG(average_depth) as avg_clustering_depth,
--   AVG(average_overlaps) as avg_overlaps
-- FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND table_name IN ('ORDERS', 'CUSTOMERS')
-- GROUP BY table_name, clustering_key;

-- TODO: Re-run test queries and compare performance
-- SELECT 
--   order_date,
--   region,
--   COUNT(*) as order_count,
--   SUM(total_amount) as total_sales
-- FROM orders
-- WHERE order_date >= '2024-01-01'
-- GROUP BY order_date, region;

-- TODO: Check partition pruning improvement
-- Should see higher percentage of partitions pruned


-- ============================================================================
-- Exercise 3: Search Optimization (15 min)
-- ============================================================================

-- TODO: Enable search optimization on customers table
-- ALTER TABLE customers ADD SEARCH OPTIMIZATION;

-- TODO: Check search optimization status
-- SHOW TABLES LIKE 'customers';

-- TODO: Test point lookup performance
-- SELECT * FROM customers WHERE customer_id = 12345;
-- SELECT * FROM customers WHERE customer_id = 67890;
-- SELECT * FROM customers WHERE email = 'customer12345@example.com';

-- TODO: Check if search optimization was used
-- SELECT 
--   query_id,
--   query_text,
--   execution_time,
--   bytes_scanned
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%customers%'
--   AND query_text ILIKE '%customer_id%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;

-- TODO: Monitor search optimization costs
-- SELECT 
--   table_name,
--   SUM(credits_used) as total_credits,
--   ROUND(SUM(credits_used) * 3, 2) as cost_usd
-- FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
-- WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
--   AND table_name = 'CUSTOMERS'
-- GROUP BY table_name;


-- ============================================================================
-- Exercise 4: Materialized Views (15 min)
-- ============================================================================

-- TODO: Create materialized view for daily sales dashboard
-- CREATE MATERIALIZED VIEW mv_daily_sales AS
-- SELECT 
--   order_date,
--   region,
--   status,
--   COUNT(*) as order_count,
--   SUM(total_amount) as total_sales,
--   AVG(total_amount) as avg_order_value,
--   MIN(total_amount) as min_order,
--   MAX(total_amount) as max_order
-- FROM orders
-- GROUP BY order_date, region, status;

-- TODO: Create materialized view for product performance
-- CREATE MATERIALIZED VIEW mv_product_performance AS
-- SELECT 
--   p.product_id,
--   p.product_name,
--   p.category,
--   p.subcategory,
--   COUNT(DISTINCT oi.order_id) as order_count,
--   SUM(oi.quantity) as total_quantity,
--   SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent/100)) as total_revenue
-- FROM order_items oi
-- JOIN products p ON oi.product_id = p.product_id
-- GROUP BY p.product_id, p.product_name, p.category, p.subcategory;

-- TODO: Query materialized views (should be instant)
-- SELECT * FROM mv_daily_sales
-- WHERE order_date >= '2024-01-01'
-- ORDER BY order_date DESC, total_sales DESC;

-- SELECT * FROM mv_product_performance
-- WHERE category = 'Electronics'
-- ORDER BY total_revenue DESC
-- LIMIT 10;

-- TODO: Monitor materialized view maintenance
-- SELECT 
--   name,
--   is_secure,
--   is_materialized,
--   created_on,
--   last_altered
-- FROM SNOWFLAKE.ACCOUNT_USAGE.VIEWS
-- WHERE name LIKE 'MV_%'
--   AND deleted IS NULL;


-- ============================================================================
-- Exercise 5: Caching Strategy (10 min)
-- ============================================================================

-- TODO: Create views with consistent formatting
-- CREATE OR REPLACE VIEW v_regional_sales AS
-- SELECT 
--   region,
--   COUNT(*) as order_count,
--   SUM(total_amount) as total_sales,
--   AVG(total_amount) as avg_order_value
-- FROM orders
-- WHERE order_date >= '2024-01-01'
-- GROUP BY region;

-- TODO: Query view multiple times (test result cache)
-- SELECT * FROM v_regional_sales ORDER BY total_sales DESC;
-- SELECT * FROM v_regional_sales ORDER BY total_sales DESC;
-- SELECT * FROM v_regional_sales ORDER BY total_sales DESC;

-- TODO: Check cache hits
-- SELECT 
--   query_id,
--   LEFT(query_text, 60) as query_preview,
--   execution_time,
--   query_result_cache_hit
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE query_text ILIKE '%v_regional_sales%'
--   AND query_text NOT ILIKE '%QUERY_HISTORY%'
-- ORDER BY start_time DESC
-- LIMIT 5;

-- TODO: Test metadata-only queries
-- SELECT COUNT(*) FROM orders;
-- SELECT MIN(order_date), MAX(order_date) FROM orders;

-- TODO: Measure improved cache hit rate
-- SELECT 
--   COUNT(*) as total_queries,
--   SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as cache_hits,
--   ROUND((cache_hits / NULLIF(total_queries, 0)) * 100, 2) as cache_hit_rate_pct
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND execution_status = 'SUCCESS';


-- ============================================================================
-- Exercise 6: Warehouse Optimization (10 min)
-- ============================================================================

-- TODO: Create separate warehouses for different workloads
-- CREATE WAREHOUSE IF NOT EXISTS analytics_wh WITH
--   WAREHOUSE_SIZE = 'MEDIUM'
--   AUTO_SUSPEND = 120
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Analytics and reporting queries';

-- CREATE WAREHOUSE IF NOT EXISTS dashboard_wh WITH
--   WAREHOUSE_SIZE = 'SMALL'
--   MIN_CLUSTER_COUNT = 1
--   MAX_CLUSTER_COUNT = 3
--   SCALING_POLICY = 'STANDARD'
--   AUTO_SUSPEND = 300
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Dashboard queries with caching';

-- TODO: Set up resource monitor
-- CREATE RESOURCE MONITOR IF NOT EXISTS performance_lab_monitor WITH
--   CREDIT_QUOTA = 100
--   FREQUENCY = MONTHLY
--   START_TIMESTAMP = IMMEDIATELY
--   TRIGGERS
--     ON 75 PERCENT DO NOTIFY
--     ON 90 PERCENT DO NOTIFY
--     ON 100 PERCENT DO SUSPEND;

-- TODO: Assign resource monitor
-- ALTER WAREHOUSE analytics_wh SET RESOURCE_MONITOR = performance_lab_monitor;
-- ALTER WAREHOUSE dashboard_wh SET RESOURCE_MONITOR = performance_lab_monitor;

-- TODO: Test warehouse performance
-- USE WAREHOUSE analytics_wh;
-- SELECT 
--   p.category,
--   COUNT(DISTINCT oi.order_id) as order_count,
--   SUM(oi.quantity * oi.unit_price) as revenue
-- FROM order_items oi
-- JOIN products p ON oi.product_id = p.product_id
-- GROUP BY p.category
-- ORDER BY revenue DESC;


-- ============================================================================
-- Exercise 7: Results & ROI Analysis (5 min)
-- ============================================================================

-- TODO: Create comprehensive monitoring dashboard
-- CREATE OR REPLACE VIEW performance_metrics AS
-- SELECT 
--   'Query Performance' as metric_category,
--   'Average Execution Time' as metric_name,
--   AVG(execution_time) / 1000 as value,
--   'seconds' as unit
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND execution_status = 'SUCCESS'
-- UNION ALL
-- SELECT 
--   'Caching',
--   'Result Cache Hit Rate',
--   ROUND((SUM(CASE WHEN query_result_cache_hit THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) * 100, 2),
--   'percent'
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
--   AND execution_status = 'SUCCESS'
-- UNION ALL
-- SELECT 
--   'Cost',
--   'Credits Used (Last Hour)',
--   SUM(credits_used),
--   'credits'
-- FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP());

-- TODO: Query performance metrics
-- SELECT * FROM performance_metrics;

-- TODO: Calculate cost savings
-- Compare baseline costs vs. optimized costs
-- Estimate: 30-50% reduction in credits

-- TODO: Document optimizations applied
-- 1. Clustering on orders (order_date) and customers (customer_id)
-- 2. Search optimization on customers table
-- 3. Materialized views for daily sales and product performance
-- 4. Views for consistent query formatting (result cache)
-- 5. Separate warehouses for different workloads
-- 6. Resource monitors for cost control


-- ============================================================================
-- Bonus: Advanced Optimizations (Optional)
-- ============================================================================

-- TODO: Create dynamic table for real-time metrics
-- CREATE DYNAMIC TABLE dt_hourly_sales
-- TARGET_LAG = '1 hour'
-- WAREHOUSE = analytics_wh
-- AS
-- SELECT 
--   DATE_TRUNC('hour', order_timestamp) as hour,
--   region,
--   COUNT(*) as order_count,
--   SUM(total_amount) as total_sales
-- FROM orders
-- GROUP BY hour, region;

-- TODO: Implement query result caching strategy
-- CREATE OR REPLACE PROCEDURE cache_common_queries()
-- RETURNS VARCHAR
-- LANGUAGE SQL
-- AS
-- $$
-- BEGIN
--   -- Run common queries to populate cache
--   SELECT * FROM v_regional_sales;
--   SELECT * FROM mv_daily_sales WHERE order_date >= CURRENT_DATE() - 7;
--   RETURN 'Cache warmed successfully';
-- END;
-- $$;

-- TODO: Schedule cache warming
-- CREATE TASK IF NOT EXISTS warm_cache_task
--   WAREHOUSE = dashboard_wh
--   SCHEDULE = 'USING CRON 0 6 * * * America/Los_Angeles'
-- AS
--   CALL cache_common_queries();


-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================

-- Drop warehouses
-- DROP WAREHOUSE IF EXISTS analytics_wh;
-- DROP WAREHOUSE IF EXISTS dashboard_wh;

-- Drop resource monitor
-- DROP RESOURCE MONITOR IF EXISTS performance_lab_monitor;

-- Drop materialized views
-- DROP MATERIALIZED VIEW IF EXISTS mv_daily_sales;
-- DROP MATERIALIZED VIEW IF EXISTS mv_product_performance;

-- Drop views
-- DROP VIEW IF EXISTS v_regional_sales;
-- DROP VIEW IF EXISTS performance_metrics;

-- Drop dynamic table
-- DROP DYNAMIC TABLE IF EXISTS dt_hourly_sales;

-- Drop tables
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS order_items;
