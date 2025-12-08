# Day 9: Search Optimization Service

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Search Optimization Service (SOS) and its use cases
- Know when to use Search Optimization vs. Clustering
- Enable and configure Search Optimization
- Measure query performance improvements
- Monitor Search Optimization costs
- Apply best practices for point lookup queries
- Optimize tables for selective queries

---

## Theory

### What is Search Optimization Service?

**Search Optimization Service (SOS)** is a Snowflake feature that dramatically improves performance of **point lookup queries** and **selective filters** by creating and maintaining a search access path.

#### Key Characteristics

```
Traditional Query:
SELECT * FROM customers WHERE email = 'user@example.com';
→ Scans all micro-partitions
→ Slow for large tables

With Search Optimization:
SELECT * FROM customers WHERE email = 'user@example.com';
→ Uses search access path
→ Directly locates relevant micro-partitions
→ 10-100x faster!
```

**Benefits**:
- Dramatically faster point lookups
- Improved performance for selective filters
- Automatic maintenance
- No query changes required
- Works with various data types

### Search Optimization vs. Clustering

| Feature | Search Optimization | Clustering |
|---------|-------------------|------------|
| **Best For** | Point lookups, selective filters | Range scans, aggregations |
| **Query Type** | Equality predicates (=, IN) | Range predicates (BETWEEN, >, <) |
| **Cardinality** | High cardinality columns | Any cardinality |
| **Table Size** | Any size (especially < 1 TB) | Large tables (> 1 TB) |
| **Maintenance** | Automatic | Automatic (if enabled) |
| **Cost** | Storage + maintenance | Re-clustering compute |
| **Use Case** | Customer lookup, ID search | Time-series, date ranges |

#### When to Use Each

**Use Search Optimization when**:
✅ Point lookup queries (WHERE id = 123)  
✅ Selective filters (WHERE email = 'user@example.com')  
✅ High-cardinality columns (customer_id, email, phone)  
✅ Queries with equality predicates  
✅ Tables of any size  

**Use Clustering when**:
✅ Range queries (WHERE date BETWEEN '2024-01-01' AND '2024-12-31')  
✅ Large tables (> 1 TB)  
✅ Aggregations over date ranges  
✅ Time-series data  
✅ Multi-dimensional analytics  

**Use Both when**:
✅ Large tables with both point lookups AND range queries  
✅ Example: Cluster on date, search optimize on customer_id  

### How Search Optimization Works

#### Architecture

```
Table Data
    ↓
Search Optimization Service analyzes
    ↓
Creates search access path:
- Bloom filters
- Min/max indexes
- Pruning indexes
    ↓
Stores in separate structure
    ↓
Query optimizer uses automatically
```

#### Search Access Path

The search access path includes:

1. **Bloom Filters**: Probabilistic data structure for membership testing
2. **Min/Max Indexes**: Range information for pruning
3. **Pruning Indexes**: Additional metadata for partition elimination

**Example**:
```sql
-- Without Search Optimization
SELECT * FROM users WHERE email = 'alice@example.com';
-- Scans: 1000 micro-partitions
-- Time: 5 seconds

-- With Search Optimization
SELECT * FROM users WHERE email = 'alice@example.com';
-- Scans: 1 micro-partition (99.9% reduction!)
-- Time: 0.05 seconds (100x faster!)
```

### Enabling Search Optimization

#### Syntax

```sql
-- Enable on entire table
ALTER TABLE customers 
ADD SEARCH OPTIMIZATION;

-- Enable on specific columns
ALTER TABLE customers 
ADD SEARCH OPTIMIZATION ON EQUALITY(email, phone);

-- Enable on substring searches
ALTER TABLE logs 
ADD SEARCH OPTIMIZATION ON SUBSTRING(log_message);

-- Enable on geospatial columns
ALTER TABLE locations 
ADD SEARCH OPTIMIZATION ON GEO(coordinates);

-- Disable search optimization
ALTER TABLE customers 
DROP SEARCH OPTIMIZATION;
```

#### Column-Specific Optimization

```sql
-- Optimize specific columns for equality
ALTER TABLE orders 
ADD SEARCH OPTIMIZATION ON EQUALITY(order_id, customer_id);

-- Optimize for substring searches (LIKE, CONTAINS)
ALTER TABLE documents 
ADD SEARCH OPTIMIZATION ON SUBSTRING(content);

-- Optimize VARIANT columns
ALTER TABLE events 
ADD SEARCH OPTIMIZATION ON EQUALITY(event_data:user_id);

-- Multiple optimization types
ALTER TABLE products 
ADD SEARCH OPTIMIZATION 
  ON EQUALITY(product_id, sku)
  ON SUBSTRING(product_name, description);
```

### Supported Query Patterns

#### Equality Predicates

```sql
-- Single equality
SELECT * FROM customers WHERE customer_id = 12345;

-- Multiple equalities (OR)
SELECT * FROM customers WHERE customer_id IN (123, 456, 789);

-- Equality with AND
SELECT * FROM orders 
WHERE customer_id = 123 AND order_status = 'SHIPPED';
```

#### Substring Searches

```sql
-- LIKE with wildcards
SELECT * FROM products WHERE product_name LIKE '%laptop%';

-- CONTAINS
SELECT * FROM documents WHERE CONTAINS(content, 'snowflake');

-- STARTSWITH
SELECT * FROM customers WHERE STARTSWITH(email, 'admin');
```

#### VARIANT Column Searches

```sql
-- Search in JSON
SELECT * FROM events 
WHERE event_data:user_id = 12345;

-- Nested JSON paths
SELECT * FROM orders 
WHERE order_details:shipping:country = 'USA';
```

#### Geospatial Searches

```sql
-- Point in polygon
SELECT * FROM locations 
WHERE ST_WITHIN(coordinates, polygon_boundary);

-- Distance queries
SELECT * FROM stores 
WHERE ST_DISTANCE(location, user_location) < 5000;
```

### Monitoring Search Optimization

#### Check Optimization Status

```sql
-- View search optimization status
SHOW TABLES LIKE 'customers';
-- Look at SEARCH_OPTIMIZATION column

-- Detailed information
SELECT 
  table_name,
  search_optimization,
  search_optimization_progress,
  search_optimization_bytes
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'PUBLIC'
  AND table_name = 'CUSTOMERS';
```

#### Build Progress

```sql
-- Check build progress
SELECT SYSTEM$GET_SEARCH_OPTIMIZATION_PROGRESS('customers');

-- Returns JSON with:
-- - status: BUILDING, COMPLETE, FAILED
-- - progress: percentage complete
-- - estimated_completion_time
```

#### Maintenance History

```sql
-- View maintenance history
SELECT 
  table_name,
  start_time,
  end_time,
  credits_used,
  bytes_added,
  bytes_removed
FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
WHERE table_name = 'CUSTOMERS'
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

### Cost Analysis

Search Optimization has two cost components:

1. **Storage Cost**: For search access path
2. **Maintenance Cost**: For building and updating

#### Storage Cost

```sql
-- Check storage used by search optimization
SELECT 
  table_name,
  active_bytes / 1024 / 1024 / 1024 as table_size_gb,
  search_optimization_bytes / 1024 / 1024 / 1024 as search_opt_size_gb,
  ROUND(
    (search_optimization_bytes::FLOAT / NULLIF(active_bytes, 0)) * 100, 
    2
  ) as search_opt_overhead_pct
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'PUBLIC'
  AND search_optimization = 'ON'
ORDER BY search_optimization_bytes DESC;
```

#### Maintenance Cost

```sql
-- Calculate daily maintenance costs
SELECT 
  DATE(start_time) as date,
  table_name,
  SUM(credits_used) as total_credits,
  ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd,
  COUNT(*) as maintenance_operations
FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;
```

#### Cost vs. Benefit Analysis

```sql
-- Compare query performance improvement vs. cost
WITH query_perf AS (
  SELECT 
    query_id,
    query_text,
    execution_time,
    partitions_scanned,
    partitions_total
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
  WHERE query_text ILIKE '%customers%'
    AND query_text ILIKE '%WHERE%customer_id%'
    AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
),
search_costs AS (
  SELECT 
    SUM(credits_used) as weekly_credits
  FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
  WHERE table_name = 'CUSTOMERS'
    AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
)
SELECT 
  COUNT(qp.query_id) as total_queries,
  AVG(qp.execution_time) as avg_execution_time_ms,
  AVG(qp.partitions_scanned::FLOAT / NULLIF(qp.partitions_total, 0) * 100) as avg_scan_pct,
  sc.weekly_credits,
  ROUND(sc.weekly_credits * 3, 2) as weekly_cost_usd
FROM query_perf qp
CROSS JOIN search_costs sc;
```

### Performance Measurement

#### Before Search Optimization

```sql
-- Baseline query
SELECT * FROM customers WHERE email = 'user@example.com';

-- Check query profile:
-- - Execution time: 5000 ms
-- - Partitions scanned: 1000
-- - Partitions total: 1000
-- - Bytes scanned: 10 GB
```

#### After Search Optimization

```sql
-- Same query with search optimization
SELECT * FROM customers WHERE email = 'user@example.com';

-- Check query profile:
-- - Execution time: 50 ms (100x faster!)
-- - Partitions scanned: 1
-- - Partitions total: 1000
-- - Bytes scanned: 10 MB (99.9% reduction!)
```

### Best Practices

**1. Column Selection**
- Enable on high-cardinality columns (IDs, emails, phone numbers)
- Enable on columns used in equality predicates
- Don't enable on all columns (increases cost)
- Focus on columns in WHERE clauses

**2. Query Patterns**
- Best for point lookups (WHERE id = value)
- Good for selective filters (< 1% of rows)
- Less effective for broad filters (> 10% of rows)
- Combine with clustering for range queries

**3. Table Size**
- Effective on tables of any size
- Especially valuable for tables < 1 TB (where clustering may not help)
- Consider for frequently queried dimension tables
- Monitor cost vs. benefit for very large tables

**4. Maintenance**
- Search optimization is maintained automatically
- No manual intervention required
- Monitor maintenance costs
- Consider disabling if not beneficial

**5. Cost Optimization**
- Start with specific columns, not entire table
- Monitor storage overhead (typically 10-30%)
- Track maintenance credits
- Disable if queries don't benefit

**6. Combined Strategies**
- Use clustering for date ranges
- Use search optimization for ID lookups
- Example: Cluster on date, search optimize on customer_id
- Provides best of both worlds

### Common Use Cases

#### Use Case 1: Customer Lookup

```sql
-- Enable search optimization
ALTER TABLE customers 
ADD SEARCH OPTIMIZATION ON EQUALITY(customer_id, email, phone);

-- Fast customer lookups
SELECT * FROM customers WHERE email = 'user@example.com';
SELECT * FROM customers WHERE customer_id = 12345;
SELECT * FROM customers WHERE phone = '+1-555-0123';
```

#### Use Case 2: Order Tracking

```sql
-- Enable on order identifiers
ALTER TABLE orders 
ADD SEARCH OPTIMIZATION ON EQUALITY(order_id, tracking_number);

-- Fast order lookups
SELECT * FROM orders WHERE order_id = 'ORD-123456';
SELECT * FROM orders WHERE tracking_number = 'TRACK-789';
```

#### Use Case 3: Log Analysis

```sql
-- Enable substring search on logs
ALTER TABLE application_logs 
ADD SEARCH OPTIMIZATION ON SUBSTRING(log_message);

-- Fast log searches
SELECT * FROM application_logs 
WHERE log_message LIKE '%ERROR%';

SELECT * FROM application_logs 
WHERE CONTAINS(log_message, 'timeout');
```

#### Use Case 4: Product Search

```sql
-- Enable on product identifiers and names
ALTER TABLE products 
ADD SEARCH OPTIMIZATION 
  ON EQUALITY(product_id, sku)
  ON SUBSTRING(product_name);

-- Fast product searches
SELECT * FROM products WHERE sku = 'SKU-12345';
SELECT * FROM products WHERE product_name LIKE '%laptop%';
```

### Limitations

❌ **Not supported for**:
- Temporary tables
- Transient tables
- External tables
- Views (only base tables)

❌ **Less effective for**:
- Range queries (use clustering instead)
- Aggregations without filters
- Full table scans
- Low-cardinality columns

❌ **Query patterns not optimized**:
- BETWEEN predicates
- Greater than / less than (>, <, >=, <=)
- IS NULL / IS NOT NULL
- Complex expressions in WHERE clause

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Enable Search Optimization
Enable search optimization on tables and monitor build progress.

### Exercise 2: Point Lookup Performance
Measure performance improvements for point lookup queries.

### Exercise 3: Substring Search Optimization
Optimize and test substring searches.

### Exercise 4: VARIANT Column Optimization
Optimize searches on JSON/VARIANT columns.

### Exercise 5: Cost Analysis
Analyze storage and maintenance costs.

### Exercise 6: Combined Strategy
Use both clustering and search optimization together.

### Exercise 7: Performance Comparison
Compare search optimization vs. clustering for different query patterns.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Search Optimization Service dramatically improves point lookup queries
- Best for equality predicates (=, IN) on high-cardinality columns
- Works on tables of any size (especially valuable for < 1 TB)
- Automatically maintained by Snowflake
- Has storage cost (10-30% overhead) and maintenance cost
- Complements clustering (not a replacement)
- Use clustering for ranges, search optimization for point lookups
- Enable on specific columns to control costs
- Supports equality, substring, VARIANT, and geospatial searches
- Monitor cost vs. benefit for optimization decisions

---

## 📚 Additional Resources

- [Snowflake Docs: Search Optimization Service](https://docs.snowflake.com/en/user-guide/search-optimization-service)
- [Best Practices: Search Optimization](https://docs.snowflake.com/en/user-guide/search-optimization-best-practices)
- [Cost Considerations](https://docs.snowflake.com/en/user-guide/search-optimization-service#cost-considerations)

---

## 🔜 Tomorrow: Day 10 - Materialized Views

We'll learn about materialized views for pre-computing and caching query results to improve performance.
