# Day 10: Materialized Views

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand materialized views and their benefits
- Know when to use materialized views vs. regular views
- Create and manage materialized views
- Understand automatic maintenance and refresh
- Compare materialized views with dynamic tables
- Monitor maintenance costs and performance
- Apply best practices for query optimization
- Optimize aggregation and reporting queries

---

## Theory

### What are Materialized Views?

A **materialized view** is a pre-computed result set stored as a table-like object. Unlike regular views (which are just stored queries), materialized views physically store data and are automatically maintained by Snowflake.

#### Regular View vs. Materialized View

```sql
-- Regular View (Virtual)
CREATE VIEW sales_summary AS
SELECT 
  region,
  DATE_TRUNC('month', sale_date) as month,
  SUM(amount) as total_sales
FROM sales
GROUP BY region, month;

-- Query executes every time:
SELECT * FROM sales_summary;
→ Scans sales table
→ Computes aggregation
→ Returns results

-- Materialized View (Physical)
CREATE MATERIALIZED VIEW sales_summary_mv AS
SELECT 
  region,
  DATE_TRUNC('month', sale_date) as month,
  SUM(amount) as total_sales
FROM sales
GROUP BY region, month;

-- Query reads pre-computed results:
SELECT * FROM sales_summary_mv;
→ Reads materialized data
→ No computation needed
→ Much faster!
```

### Key Characteristics

**Benefits**:
- ✅ Pre-computed results (faster queries)
- ✅ Automatic maintenance by Snowflake
- ✅ Transparent to applications (query like a table)
- ✅ Supports clustering for large result sets
- ✅ Ideal for expensive aggregations

**Limitations**:
- ❌ Storage cost for materialized data
- ❌ Maintenance cost for updates
- ❌ Limited query patterns supported
- ❌ Cannot use non-deterministic functions
- ❌ No DML operations (INSERT, UPDATE, DELETE)

### When to Use Materialized Views

✅ **Use materialized views when**:
- Queries are expensive (complex aggregations, joins)
- Same query runs frequently
- Base tables change infrequently
- Query results are relatively small
- Acceptable for results to be slightly stale

❌ **Don't use materialized views when**:
- Base tables change constantly
- Query patterns vary widely
- Results need to be real-time
- Query is already fast
- Result set is very large

### Materialized Views vs. Dynamic Tables

| Feature | Materialized Views | Dynamic Tables |
|---------|-------------------|----------------|
| **Refresh Control** | Automatic (Snowflake-managed) | TARGET_LAG (user-controlled) |
| **Query Support** | Limited patterns | Any SELECT query |
| **Maintenance** | Automatic, transparent | Automatic with lag control |
| **Use Case** | Simple aggregations | Complex transformations |
| **Flexibility** | Less flexible | More flexible |
| **Cost Control** | Limited | Better (via TARGET_LAG) |

**Rule of Thumb**:
- Simple aggregations → Materialized Views
- Complex transformations → Dynamic Tables
- Need lag control → Dynamic Tables
- Want automatic optimization → Materialized Views

### Creating Materialized Views

#### Basic Syntax

```sql
CREATE MATERIALIZED VIEW view_name AS
SELECT ...
FROM base_table
WHERE ...
GROUP BY ...;
```

#### Supported Query Patterns

**✅ Supported**:
```sql
-- Simple aggregations
CREATE MATERIALIZED VIEW sales_by_region AS
SELECT 
  region,
  SUM(amount) as total_sales,
  COUNT(*) as order_count,
  AVG(amount) as avg_sale
FROM sales
GROUP BY region;

-- Joins with aggregations
CREATE MATERIALIZED VIEW customer_sales AS
SELECT 
  c.customer_id,
  c.customer_name,
  COUNT(o.order_id) as order_count,
  SUM(o.amount) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Date-based aggregations
CREATE MATERIALIZED VIEW daily_sales AS
SELECT 
  DATE(order_timestamp) as order_date,
  SUM(amount) as daily_total,
  COUNT(*) as order_count
FROM orders
GROUP BY order_date;

-- Multiple tables with filters
CREATE MATERIALIZED VIEW active_customer_metrics AS
SELECT 
  c.customer_tier,
  COUNT(DISTINCT c.customer_id) as customer_count,
  SUM(o.amount) as total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.is_active = TRUE
  AND o.order_date >= DATEADD(year, -1, CURRENT_DATE())
GROUP BY c.customer_tier;
```

**❌ Not Supported**:
```sql
-- Non-deterministic functions
CREATE MATERIALIZED VIEW bad_mv AS
SELECT 
  customer_id,
  CURRENT_TIMESTAMP() as query_time  -- ❌ Non-deterministic
FROM customers;

-- Window functions
CREATE MATERIALIZED VIEW bad_mv AS
SELECT 
  customer_id,
  ROW_NUMBER() OVER (ORDER BY amount) as rank  -- ❌ Window function
FROM orders;

-- HAVING without GROUP BY
CREATE MATERIALIZED VIEW bad_mv AS
SELECT SUM(amount)
FROM orders
HAVING SUM(amount) > 1000;  -- ❌ HAVING without GROUP BY

-- Subqueries in SELECT
CREATE MATERIALIZED VIEW bad_mv AS
SELECT 
  customer_id,
  (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id) as order_count  -- ❌ Subquery
FROM customers c;
```

### Automatic Maintenance

Snowflake automatically maintains materialized views when base tables change.

#### How Maintenance Works

```
Base Table Changes (INSERT/UPDATE/DELETE)
    ↓
Snowflake detects changes
    ↓
Background maintenance service
    ↓
Incrementally updates materialized view
    ↓
View stays synchronized
```

#### Maintenance Modes

**Incremental Maintenance** (Preferred):
- Only processes changed data
- More efficient
- Lower cost
- Faster updates

**Full Refresh** (Fallback):
- Recomputes entire view
- Used when incremental not possible
- Higher cost
- Slower updates

#### Checking Maintenance Status

```sql
-- View materialized view status
SHOW MATERIALIZED VIEWS;

-- Check if view is up-to-date
SELECT 
  name,
  is_secure,
  is_materialized,
  behind_by
FROM INFORMATION_SCHEMA.VIEWS
WHERE table_schema = 'PUBLIC'
  AND table_name = 'SALES_SUMMARY_MV';

-- Behind_by indicates staleness:
-- - '0 seconds' = up-to-date
-- - '5 minutes' = 5 minutes behind
```

### Clustering Materialized Views

Large materialized views can benefit from clustering:

```sql
-- Create materialized view with clustering
CREATE MATERIALIZED VIEW sales_by_date_region
CLUSTER BY (sale_date)
AS
SELECT 
  sale_date,
  region,
  SUM(amount) as total_sales,
  COUNT(*) as order_count
FROM sales
GROUP BY sale_date, region;

-- Add clustering to existing materialized view
ALTER MATERIALIZED VIEW sales_summary_mv
CLUSTER BY (region);
```

### Monitoring and Maintenance

#### Maintenance History

```sql
-- View maintenance history
SELECT 
  materialized_view_name,
  refresh_start_time,
  refresh_end_time,
  credits_used,
  bytes_scanned,
  rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
WHERE materialized_view_name = 'SALES_SUMMARY_MV'
  AND refresh_start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY refresh_start_time DESC;
```

#### Cost Analysis

```sql
-- Calculate daily maintenance costs
SELECT 
  DATE(refresh_start_time) as date,
  materialized_view_name,
  COUNT(*) as refresh_count,
  SUM(credits_used) as total_credits,
  ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd,
  AVG(DATEDIFF(second, refresh_start_time, refresh_end_time)) as avg_refresh_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
WHERE refresh_start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 4 DESC;
```

#### Storage Cost

```sql
-- Check storage used by materialized views
SELECT 
  table_name,
  table_type,
  row_count,
  bytes / 1024 / 1024 / 1024 as size_gb,
  ROUND(bytes / 1024 / 1024 / 1024 * 23, 2) as monthly_storage_cost_usd
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'PUBLIC'
  AND table_type = 'MATERIALIZED VIEW'
ORDER BY bytes DESC;
```

### Query Rewrite Optimization

Snowflake can automatically rewrite queries to use materialized views:

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW sales_by_region AS
SELECT 
  region,
  SUM(amount) as total_sales
FROM sales
GROUP BY region;

-- Original query
SELECT region, SUM(amount)
FROM sales
GROUP BY region;

-- Snowflake may automatically rewrite to:
SELECT region, total_sales
FROM sales_by_region;

-- Check query profile to see if rewrite occurred
```

### Suspending and Resuming

```sql
-- Suspend maintenance (stops automatic updates)
ALTER MATERIALIZED VIEW sales_summary_mv SUSPEND;

-- Resume maintenance
ALTER MATERIALIZED VIEW sales_summary_mv RESUME;

-- Manually refresh
ALTER MATERIALIZED VIEW sales_summary_mv REFRESH;
```

### Best Practices

**1. Query Pattern Selection**
- Use for frequently-run aggregations
- Ensure query pattern is supported
- Test with EXPLAIN to verify benefit
- Consider result set size

**2. Base Table Considerations**
- Best when base tables change infrequently
- Monitor maintenance frequency
- Consider data volume changes
- Evaluate incremental vs. full refresh

**3. Cost Optimization**
- Monitor maintenance costs
- Suspend during bulk loads
- Drop unused materialized views
- Consider dynamic tables for complex queries

**4. Performance Optimization**
- Add clustering for large result sets
- Keep result sets reasonably sized
- Use appropriate aggregation levels
- Test query performance improvement

**5. Maintenance Strategy**
- Monitor behind_by metric
- Check maintenance history regularly
- Suspend during maintenance windows
- Plan for full refresh scenarios

**6. Design Patterns**
- Create hierarchy of materialized views
- Start with coarse aggregations
- Add finer-grained views as needed
- Document dependencies

### Common Use Cases

#### Use Case 1: Sales Reporting

```sql
-- Daily sales summary
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
  DATE(order_timestamp) as order_date,
  region,
  product_category,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(order_id) as order_count,
  SUM(amount) as total_sales,
  AVG(amount) as avg_order_value
FROM orders
GROUP BY order_date, region, product_category;

-- Fast dashboard queries
SELECT * FROM daily_sales_summary
WHERE order_date >= DATEADD(day, -30, CURRENT_DATE());
```

#### Use Case 2: Customer Analytics

```sql
-- Customer lifetime value
CREATE MATERIALIZED VIEW customer_ltv AS
SELECT 
  c.customer_id,
  c.customer_tier,
  c.registration_date,
  COUNT(o.order_id) as total_orders,
  SUM(o.amount) as lifetime_value,
  AVG(o.amount) as avg_order_value,
  MAX(o.order_date) as last_order_date,
  DATEDIFF(day, MAX(o.order_date), CURRENT_DATE()) as days_since_last_order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_tier, c.registration_date;

-- Fast customer lookups
SELECT * FROM customer_ltv
WHERE customer_id = 12345;
```

#### Use Case 3: Inventory Management

```sql
-- Product inventory summary
CREATE MATERIALIZED VIEW product_inventory_summary AS
SELECT 
  p.product_id,
  p.product_name,
  p.category,
  SUM(i.quantity_on_hand) as total_inventory,
  SUM(i.quantity_reserved) as total_reserved,
  SUM(i.quantity_on_hand - i.quantity_reserved) as available_inventory,
  COUNT(DISTINCT i.warehouse_id) as warehouse_count
FROM products p
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- Fast inventory checks
SELECT * FROM product_inventory_summary
WHERE available_inventory < 100;
```

#### Use Case 4: Time-Series Aggregations

```sql
-- Hourly metrics
CREATE MATERIALIZED VIEW hourly_metrics AS
SELECT 
  DATE_TRUNC('hour', event_timestamp) as hour,
  event_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT session_id) as unique_sessions
FROM events
GROUP BY hour, event_type;

-- Fast time-series queries
SELECT * FROM hourly_metrics
WHERE hour >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY hour DESC;
```

### Limitations and Considerations

**Query Limitations**:
- No window functions
- No non-deterministic functions (CURRENT_TIMESTAMP, RANDOM, etc.)
- No FLATTEN or table functions
- Limited subquery support
- No QUALIFY clause

**Operational Limitations**:
- Cannot INSERT, UPDATE, or DELETE
- Cannot be used as base for another materialized view
- Cannot reference external tables
- Cannot reference secure views

**Performance Considerations**:
- Maintenance cost increases with base table changes
- Large result sets consume storage
- Full refresh can be expensive
- May not always be faster than base query

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Basic Materialized Views
Create materialized views for common aggregations.

### Exercise 2: Compare Performance
Measure query performance with and without materialized views.

### Exercise 3: Monitor Maintenance
Track maintenance history and costs.

### Exercise 4: Clustering Materialized Views
Add clustering to large materialized views.

### Exercise 5: Materialized Views vs. Dynamic Tables
Compare both approaches for the same use case.

### Exercise 6: Cost Analysis
Analyze storage and maintenance costs.

### Exercise 7: Best Practices
Implement materialized view hierarchy and optimization strategies.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Materialized views store pre-computed query results
- Automatically maintained by Snowflake
- Best for expensive aggregations run frequently
- Support limited query patterns (no window functions, non-deterministic functions)
- Incremental maintenance is more efficient than full refresh
- Can be clustered for large result sets
- Have storage and maintenance costs
- Dynamic tables offer more flexibility with TARGET_LAG control
- Monitor behind_by metric for staleness
- Suspend during bulk loads to save costs
- Use for reporting, dashboards, and analytics

---

## 📚 Additional Resources

- [Snowflake Docs: Materialized Views](https://docs.snowflake.com/en/user-guide/views-materialized)
- [Best Practices: Materialized Views](https://docs.snowflake.com/en/user-guide/views-materialized-best-practices)
- [Materialized Views vs. Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-comparison)

---

## 🔜 Tomorrow: Day 11 - Query Performance Tuning

We'll learn how to analyze and optimize slow queries using query profiles and optimization techniques.
