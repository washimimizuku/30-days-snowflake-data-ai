# Day 13: Result Caching & Persisted Results

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake's three-layer caching architecture
- Leverage result caching for zero-cost query execution
- Understand metadata cache and its benefits
- Optimize for warehouse cache (local disk cache)
- Maximize cache hit rates
- Monitor cache effectiveness
- Apply caching strategies for performance and cost optimization
- Understand cache invalidation rules

---

## Theory

### Snowflake's Three-Layer Caching Architecture

Snowflake uses three types of caching to improve performance and reduce costs:

```
Query Execution Flow:

1. Result Cache (Query-level)
   ↓ (if miss)
2. Metadata Cache (Micro-partition metadata)
   ↓ (if miss)
3. Warehouse Cache (Local SSD)
   ↓ (if miss)
4. Remote Storage (S3/Azure/GCS)
```

### Layer 1: Result Cache

**What**: Stores complete query results  
**Where**: Cloud services layer (shared across all warehouses)  
**Duration**: 24 hours  
**Cost**: FREE (0 credits)  

#### How Result Cache Works

```sql
-- First execution: Computes and caches result
SELECT region, SUM(amount) as total_sales
FROM sales
WHERE sale_date >= '2024-01-01'
GROUP BY region;
-- Execution time: 5 seconds
-- Credits used: 0.001

-- Second execution (within 24 hours): Returns cached result
SELECT region, SUM(amount) as total_sales
FROM sales
WHERE sale_date >= '2024-01-01'
GROUP BY region;
-- Execution time: 0.1 seconds
-- Credits used: 0 (FREE!)
```

#### Cache Hit Requirements

✅ **Cache HIT when**:
- Exact same query text (including whitespace, case)
- No table changes since cache creation
- Within 24 hours
- Same role and context
- Query is deterministic

❌ **Cache MISS when**:
- Query text differs (even whitespace)
- Tables modified (INSERT, UPDATE, DELETE, TRUNCATE)
- > 24 hours old
- Different role
- Non-deterministic functions (CURRENT_TIMESTAMP, RANDOM)

#### Examples

```sql
-- These are DIFFERENT queries (cache miss):
SELECT * FROM customers WHERE region = 'NORTH';
SELECT * FROM customers WHERE region='NORTH';  -- No space
SELECT * FROM CUSTOMERS WHERE region = 'NORTH';  -- Different case

-- These are the SAME (cache hit):
SELECT * FROM customers WHERE region = 'NORTH';
SELECT * FROM customers WHERE region = 'NORTH';  -- Exact match

-- Cache invalidated by table changes:
SELECT COUNT(*) FROM orders;  -- Cached
INSERT INTO orders VALUES (...);  -- Invalidates cache
SELECT COUNT(*) FROM orders;  -- Cache miss, recomputes
```

### Layer 2: Metadata Cache

**What**: Stores micro-partition metadata (min/max values, row counts)  
**Where**: Cloud services layer  
**Duration**: Indefinite (until table changes)  
**Cost**: FREE (0 credits)  

#### Metadata-Only Queries

Certain queries can be answered using only metadata:

```sql
-- Metadata-only queries (FREE):
SELECT COUNT(*) FROM large_table;
SELECT MIN(order_date) FROM orders;
SELECT MAX(order_date) FROM orders;

-- Query profile shows:
-- - "Metadata-based result"
-- - 0 bytes scanned
-- - Instant execution
```

#### How It Works

```
Micro-partition metadata:
- Row count: 500,000 rows
- Column: order_date
  - Min: 2024-01-01
  - Max: 2024-12-31
  - Distinct count: 365

Query: SELECT COUNT(*) FROM orders;
→ Sum row counts from metadata
→ No data scan needed!
```

### Layer 3: Warehouse Cache

**What**: Stores raw table data on warehouse local SSD  
**Where**: Each warehouse's local storage  
**Duration**: While warehouse is running  
**Cost**: Included in warehouse cost  

#### How Warehouse Cache Works

```sql
-- First query: Reads from remote storage
SELECT * FROM large_table WHERE region = 'NORTH';
-- Execution time: 10 seconds
-- Data cached to warehouse local SSD

-- Second query (same warehouse): Reads from cache
SELECT * FROM large_table WHERE region = 'SOUTH';
-- Execution time: 2 seconds (80% faster!)
-- Uses cached data from same table
```

#### Cache Characteristics

**Persists**:
- While warehouse is running
- Across different queries
- For all users of the warehouse

**Cleared**:
- When warehouse is suspended
- When warehouse is resized
- When cache is full (LRU eviction)

#### Monitoring Cache Usage

```sql
-- Check percentage scanned from cache
SELECT 
  query_id,
  query_text,
  execution_time,
  bytes_scanned,
  percentage_scanned_from_cache
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 10;
```

### Maximizing Cache Hit Rates

#### Strategy 1: Consistent Query Formatting

```sql
-- Bad: Different formatting (cache miss)
SELECT * FROM customers WHERE region = 'NORTH';
SELECT * FROM customers WHERE region='NORTH';
SELECT * FROM CUSTOMERS WHERE region = 'NORTH';

-- Good: Consistent formatting (cache hit)
SELECT * FROM customers WHERE region = 'NORTH';
SELECT * FROM customers WHERE region = 'NORTH';
SELECT * FROM customers WHERE region = 'NORTH';
```

#### Strategy 2: Use Query Tags

```sql
-- Group similar queries with tags
ALTER SESSION SET QUERY_TAG = 'daily_report';

SELECT * FROM sales WHERE sale_date = CURRENT_DATE();

-- Queries with same tag can share patterns
```

#### Strategy 3: Parameterize Queries

```sql
-- Bad: Different queries for each date (no cache reuse)
SELECT * FROM sales WHERE sale_date = '2024-01-01';
SELECT * FROM sales WHERE sale_date = '2024-01-02';
SELECT * FROM sales WHERE sale_date = '2024-01-03';

-- Better: Use application-level parameterization
-- Let application substitute date value
-- But query text must still match exactly
```

#### Strategy 4: Avoid Non-Deterministic Functions

```sql
-- Bad: Non-deterministic (never cached)
SELECT * FROM orders WHERE order_date = CURRENT_DATE();
SELECT * FROM logs WHERE log_time > CURRENT_TIMESTAMP();

-- Good: Use deterministic values
SELECT * FROM orders WHERE order_date = '2024-12-08';
SELECT * FROM logs WHERE log_time > '2024-12-08 00:00:00';
```

#### Strategy 5: Keep Warehouses Running

```sql
-- Warehouse cache persists while running
-- For frequently-accessed data, consider:
ALTER WAREHOUSE analytics_wh SET AUTO_SUSPEND = 600;  -- 10 minutes

-- Or for 24/7 workloads:
ALTER WAREHOUSE always_on_wh SET AUTO_SUSPEND = NULL;
```

### Cache Invalidation

#### What Invalidates Result Cache

```sql
-- DML operations invalidate cache
INSERT INTO orders VALUES (...);
UPDATE orders SET status = 'SHIPPED' WHERE ...;
DELETE FROM orders WHERE ...;
TRUNCATE TABLE orders;

-- DDL operations invalidate cache
ALTER TABLE orders ADD COLUMN new_col VARCHAR(100);
DROP TABLE orders;

-- Time-based invalidation
-- After 24 hours, cache expires automatically
```

#### What Doesn't Invalidate Cache

```sql
-- These don't affect result cache:
CREATE INDEX ...  -- Snowflake doesn't use indexes
ANALYZE TABLE ...  -- No manual statistics
GRANT SELECT ...  -- Permission changes
```

### Monitoring Cache Effectiveness

#### Result Cache Hit Rate

```sql
-- Calculate result cache hit rate
SELECT 
  DATE(start_time) as date,
  COUNT(*) as total_queries,
  SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as cache_hits,
  ROUND((cache_hits / NULLIF(total_queries, 0)) * 100, 2) as cache_hit_rate_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
GROUP BY 1
ORDER BY 1 DESC;
```

#### Warehouse Cache Effectiveness

```sql
-- Queries with high cache usage
SELECT 
  query_id,
  LEFT(query_text, 100) as query_preview,
  execution_time,
  bytes_scanned / 1024 / 1024 / 1024 as gb_scanned,
  percentage_scanned_from_cache,
  ROUND(bytes_scanned * percentage_scanned_from_cache / 100 / 1024 / 1024 / 1024, 2) as gb_from_cache
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND bytes_scanned > 0
ORDER BY percentage_scanned_from_cache DESC
LIMIT 10;
```

#### Metadata-Only Queries

```sql
-- Identify metadata-only queries
SELECT 
  query_id,
  query_text,
  execution_time,
  bytes_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND bytes_scanned = 0
  AND execution_status = 'SUCCESS'
  AND query_text NOT ILIKE '%SHOW%'
  AND query_text NOT ILIKE '%DESCRIBE%'
ORDER BY start_time DESC
LIMIT 10;
```

### Cost Savings from Caching

```sql
-- Calculate savings from result cache
WITH cache_stats AS (
  SELECT 
    COUNT(*) as total_queries,
    SUM(CASE WHEN query_result_cache_hit = TRUE THEN 1 ELSE 0 END) as cache_hits,
    AVG(CASE WHEN query_result_cache_hit = FALSE THEN execution_time ELSE 0 END) as avg_compute_time_ms,
    AVG(CASE WHEN query_result_cache_hit = FALSE THEN credits_used_cloud_services ELSE 0 END) as avg_credits_per_query
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
  WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
    AND execution_status = 'SUCCESS'
)
SELECT 
  total_queries,
  cache_hits,
  ROUND((cache_hits::FLOAT / total_queries) * 100, 2) as cache_hit_rate_pct,
  ROUND(cache_hits * avg_credits_per_query, 2) as estimated_credits_saved,
  ROUND(cache_hits * avg_credits_per_query * 3, 2) as estimated_cost_saved_usd
FROM cache_stats;
```

### Best Practices

**1. Query Consistency**
- Use consistent formatting and casing
- Standardize query patterns
- Use query templates
- Implement query builders

**2. Cache-Friendly Queries**
- Avoid CURRENT_TIMESTAMP() in WHERE clauses
- Use deterministic functions
- Parameterize at application level
- Use consistent date formats

**3. Warehouse Management**
- Keep warehouses running for frequently-accessed data
- Use longer auto-suspend for cached workloads
- Separate warehouses by workload type
- Monitor cache hit rates

**4. Table Design**
- Minimize table changes during business hours
- Batch DML operations
- Use transient tables for temporary data
- Consider materialized views for frequently-queried aggregations

**5. Monitoring**
- Track result cache hit rates
- Monitor warehouse cache effectiveness
- Identify metadata-only queries
- Calculate cost savings

### Common Patterns

#### Pattern 1: Dashboard Queries

```sql
-- Dashboard refreshes every 5 minutes
-- First load: Computes (costs credits)
-- Next 287 loads (24 hours): Cached (FREE!)

SELECT 
  region,
  COUNT(*) as order_count,
  SUM(amount) as total_sales
FROM orders
WHERE order_date = CURRENT_DATE() - 1  -- Yesterday (deterministic)
GROUP BY region;
```

#### Pattern 2: Report Generation

```sql
-- Monthly report runs multiple times
-- First run: Computes
-- Subsequent runs: Cached

SELECT 
  DATE_TRUNC('month', order_date) as month,
  product_category,
  SUM(amount) as total_sales
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2024-02-01'
GROUP BY month, product_category;
```

#### Pattern 3: Data Exploration

```sql
-- Analyst runs similar queries
-- Warehouse cache helps even with different queries

SELECT * FROM large_table WHERE region = 'NORTH';  -- Loads to cache
SELECT * FROM large_table WHERE region = 'SOUTH';  -- Uses cache
SELECT * FROM large_table WHERE region = 'EAST';   -- Uses cache
```

### Troubleshooting Cache Issues

#### Issue 1: Low Cache Hit Rate

**Symptoms**: < 20% cache hit rate

**Causes**:
- Inconsistent query formatting
- Frequent table updates
- Non-deterministic functions
- Different users/roles

**Solutions**:
- Standardize query formatting
- Batch table updates
- Use deterministic values
- Use shared service accounts

#### Issue 2: Cache Not Persisting

**Symptoms**: Expected cache hit, but miss

**Causes**:
- Warehouse suspended (warehouse cache)
- Table modified (result cache)
- > 24 hours (result cache)
- Query text differs

**Solutions**:
- Keep warehouse running longer
- Minimize table changes
- Run queries more frequently
- Ensure exact query match

#### Issue 3: Metadata Cache Not Used

**Symptoms**: COUNT(*) scans data

**Causes**:
- WHERE clause prevents metadata use
- Table recently modified
- Clustering key queries

**Solutions**:
- Use COUNT(*) without WHERE
- Wait for metadata refresh
- Understand metadata limitations

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Test Result Cache
Observe result cache behavior and hit rates.

### Exercise 2: Metadata-Only Queries
Identify and leverage metadata cache.

### Exercise 3: Warehouse Cache
Test warehouse cache persistence and effectiveness.

### Exercise 4: Cache Invalidation
Understand what invalidates caches.

### Exercise 5: Optimize for Caching
Apply strategies to maximize cache hits.

### Exercise 6: Monitor Cache Effectiveness
Track cache hit rates and cost savings.

### Exercise 7: Real-World Caching Strategy
Implement comprehensive caching optimization.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Three-layer caching: Result cache, Metadata cache, Warehouse cache
- Result cache: 24-hour TTL, FREE, requires exact query match
- Metadata cache: Instant COUNT(*), MIN, MAX queries
- Warehouse cache: Persists while warehouse runs, cleared on suspend
- Cache hit = 0 credits = FREE query execution
- Consistent query formatting maximizes cache hits
- Avoid non-deterministic functions in cached queries
- Table changes invalidate result cache
- Warehouse cache helps even with different queries
- Monitor cache hit rates for optimization opportunities
- Result caching can save 50%+ of compute costs

---

## 📚 Additional Resources

- [Snowflake Docs: Caching](https://docs.snowflake.com/en/user-guide/querying-persisted-results)
- [Query Result Reuse](https://docs.snowflake.com/en/user-guide/querying-persisted-results#query-result-reuse)
- [Metadata Cache](https://docs.snowflake.com/en/user-guide/querying-persisted-results#metadata-cache)

---

## 🔜 Tomorrow: Day 14 - Week 2 Review & Performance Lab

We'll review all Week 2 concepts and complete a comprehensive performance optimization project.
