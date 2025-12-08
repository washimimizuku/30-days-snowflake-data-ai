# Day 11: Query Performance Tuning

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Read and interpret query profiles
- Identify performance bottlenecks
- Optimize JOIN operations
- Fix data spilling issues
- Improve partition pruning
- Optimize aggregations and window functions
- Apply query optimization best practices
- Use EXPLAIN to analyze query plans
- Troubleshoot slow queries systematically

---

## Theory

### Query Profile: Your Performance Diagnostic Tool

The **Query Profile** is Snowflake's visual representation of query execution. It shows exactly how Snowflake executed your query and where time was spent.

#### Accessing Query Profile

```
1. Run your query
2. Go to Query History (Activity → Query History)
3. Click on your query
4. Click "Query Profile" tab
```

#### Key Metrics to Analyze

**Execution Time**:
- Total execution time
- Time per operator
- Percentage of total time

**Data Volume**:
- Rows produced/scanned
- Bytes scanned
- Partitions scanned vs. total

**Resource Usage**:
- Percentage scanned from cache
- Spilling to local/remote storage
- Network communication

### Understanding Query Profile Operators

#### Common Operators

**TableScan**:
```
What: Reads data from table
Look for:
- Partitions scanned vs. total
- Bytes scanned
- Pruning effectiveness
```

**Filter**:
```
What: Applies WHERE conditions
Look for:
- Rows in vs. rows out
- Filter selectivity
- Pushed-down predicates
```

**Aggregate**:
```
What: GROUP BY operations
Look for:
- Rows grouped
- Spilling to disk
- Memory usage
```

**Join**:
```
What: Combines tables
Look for:
- Join type (hash, merge, nested loop)
- Rows from each side
- Spilling to disk
```

**Sort**:
```
What: ORDER BY operations
Look for:
- Rows sorted
- Spilling to disk
- Memory pressure
```

**WindowFunction**:
```
What: Window function calculations
Look for:
- Partition size
- Spilling
- Memory usage
```

### Partition Pruning Optimization

**Goal**: Minimize partitions scanned

#### Before Optimization

```sql
-- Poor: Scans all partitions
SELECT * FROM large_table
WHERE YEAR(order_date) = 2024;

-- Query Profile shows:
-- Partitions scanned: 1000
-- Partitions total: 1000
-- Pruning: 0%
```

#### After Optimization

```sql
-- Good: Enables partition pruning
SELECT * FROM large_table
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

-- Query Profile shows:
-- Partitions scanned: 100
-- Partitions total: 1000
-- Pruning: 90%
```

#### Best Practices for Pruning

✅ **Do**:
```sql
-- Use direct column comparisons
WHERE date_column >= '2024-01-01'

-- Use BETWEEN for ranges
WHERE date_column BETWEEN '2024-01-01' AND '2024-12-31'

-- Use IN for multiple values
WHERE region IN ('NORTH', 'SOUTH')
```

❌ **Don't**:
```sql
-- Avoid functions on filtered columns
WHERE YEAR(date_column) = 2024  -- Prevents pruning

-- Avoid complex expressions
WHERE date_column + INTERVAL '1 day' > CURRENT_DATE()

-- Avoid OR with different columns
WHERE date_column = '2024-01-01' OR region = 'NORTH'
```

### JOIN Optimization

#### Join Types

**Hash Join** (Most Common):
- Best for: Large tables, equality joins
- Memory intensive
- Can spill to disk

**Merge Join**:
- Best for: Sorted data, range joins
- Less memory intensive
- Requires sorted inputs

**Nested Loop Join**:
- Best for: Small tables, non-equality joins
- Slowest for large tables
- Used as last resort

#### Join Order Matters

```sql
-- Poor: Large table first
SELECT *
FROM large_table l  -- 10M rows
JOIN small_table s  -- 1K rows
  ON l.id = s.id;

-- Better: Small table first (Snowflake optimizes this)
SELECT *
FROM small_table s  -- 1K rows
JOIN large_table l  -- 10M rows
  ON s.id = l.id;
```

#### Join Optimization Techniques

**1. Filter Before Joining**:
```sql
-- Poor: Filter after join
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2024-01-01';

-- Better: Filter before join
SELECT *
FROM (
  SELECT * FROM orders 
  WHERE order_date >= '2024-01-01'
) o
JOIN customers c ON o.customer_id = c.customer_id;

-- Best: Use CTE for clarity
WITH recent_orders AS (
  SELECT * FROM orders 
  WHERE order_date >= '2024-01-01'
)
SELECT *
FROM recent_orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

**2. Use Appropriate Join Types**:
```sql
-- Use INNER JOIN when possible (faster than LEFT JOIN)
SELECT *
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- Use EXISTS instead of IN for large subqueries
SELECT *
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o 
  WHERE o.customer_id = c.customer_id
);

-- Better than:
SELECT *
FROM customers c
WHERE customer_id IN (
  SELECT customer_id FROM orders
);
```

**3. Avoid Cartesian Products**:
```sql
-- Dangerous: Missing join condition
SELECT *
FROM table1, table2;  -- Creates cartesian product!

-- Correct: Always specify join condition
SELECT *
FROM table1 t1
JOIN table2 t2 ON t1.id = t2.id;
```

### Data Spilling

**Spilling** occurs when operations exceed available memory and write to disk.

#### Types of Spilling

**Local Disk Spilling**:
- Writes to warehouse local SSD
- Moderate performance impact
- Shows as "Bytes spilled to local storage"

**Remote Disk Spilling**:
- Writes to remote storage
- Severe performance impact
- Shows as "Bytes spilled to remote storage"

#### Identifying Spilling

```sql
-- Check query profile for:
-- - "Bytes spilled to local storage"
-- - "Bytes spilled to remote storage"
-- - Red warning indicators
```

#### Fixing Spilling Issues

**Solution 1: Increase Warehouse Size**:
```sql
-- Larger warehouse = more memory
ALTER WAREHOUSE my_wh SET WAREHOUSE_SIZE = 'LARGE';
```

**Solution 2: Reduce Data Volume**:
```sql
-- Filter earlier in query
WITH filtered_data AS (
  SELECT * FROM large_table
  WHERE date_column >= '2024-01-01'  -- Reduce data early
)
SELECT ...
FROM filtered_data;
```

**Solution 3: Optimize Aggregations**:
```sql
-- Poor: Aggregates too much data
SELECT 
  customer_id,
  product_id,
  date,
  SUM(amount)
FROM sales
GROUP BY customer_id, product_id, date;

-- Better: Aggregate at appropriate level
SELECT 
  customer_id,
  DATE_TRUNC('month', date) as month,
  SUM(amount)
FROM sales
GROUP BY customer_id, month;
```

**Solution 4: Break Complex Queries**:
```sql
-- Instead of one massive query, use CTEs or temp tables
CREATE TEMP TABLE stage1 AS
SELECT ... FROM large_table WHERE ...;

CREATE TEMP TABLE stage2 AS
SELECT ... FROM stage1 JOIN ...;

SELECT ... FROM stage2;
```

### Aggregation Optimization

#### Efficient Aggregations

```sql
-- Poor: Multiple passes over data
SELECT 
  (SELECT COUNT(*) FROM orders WHERE status = 'PENDING') as pending,
  (SELECT COUNT(*) FROM orders WHERE status = 'SHIPPED') as shipped,
  (SELECT COUNT(*) FROM orders WHERE status = 'DELIVERED') as delivered;

-- Better: Single pass with CASE
SELECT 
  COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending,
  COUNT(CASE WHEN status = 'SHIPPED' THEN 1 END) as shipped,
  COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END) as delivered
FROM orders;
```

#### DISTINCT Optimization

```sql
-- Poor: DISTINCT on large result set
SELECT DISTINCT customer_id, order_date, product_id
FROM orders;

-- Better: Use GROUP BY (often faster)
SELECT customer_id, order_date, product_id
FROM orders
GROUP BY customer_id, order_date, product_id;

-- Best: Avoid DISTINCT if possible
SELECT customer_id
FROM orders
GROUP BY customer_id;
```

### Window Function Optimization

```sql
-- Poor: Multiple window functions with different partitions
SELECT 
  customer_id,
  order_date,
  amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as rn1,
  SUM(amount) OVER (PARTITION BY region ORDER BY order_date) as running_total
FROM orders;

-- Better: Consistent partitioning
SELECT 
  customer_id,
  order_date,
  amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as rn,
  SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders;
```

### Using EXPLAIN

```sql
-- View query execution plan
EXPLAIN
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2024-01-01';

-- Shows:
-- - Join strategy
-- - Filter pushdown
-- - Estimated rows
-- - Partition pruning
```

### Result Caching

Snowflake caches query results for 24 hours.

#### Cache Hit Conditions

✅ **Cache hit when**:
- Exact same query
- No table changes
- Within 24 hours
- Same role/context

❌ **Cache miss when**:
- Query text differs (even whitespace)
- Tables modified
- > 24 hours old
- Different role

#### Optimizing for Cache

```sql
-- Use consistent query formatting
-- Good: Consistent
SELECT customer_id, order_date FROM orders WHERE region = 'NORTH';

-- Bad: Different formatting (cache miss)
SELECT customer_id,order_date FROM orders WHERE region='NORTH';

-- Use query tags for similar queries
ALTER SESSION SET QUERY_TAG = 'daily_report';
```

### Query Optimization Checklist

**1. Partition Pruning**:
- [ ] Use direct column comparisons in WHERE
- [ ] Avoid functions on filtered columns
- [ ] Check partitions scanned vs. total

**2. JOIN Optimization**:
- [ ] Filter before joining
- [ ] Use appropriate join types
- [ ] Check for cartesian products
- [ ] Verify join order

**3. Data Spilling**:
- [ ] Check for spilling in query profile
- [ ] Increase warehouse size if needed
- [ ] Reduce data volume early
- [ ] Break complex queries

**4. Aggregations**:
- [ ] Use single-pass aggregations
- [ ] Avoid unnecessary DISTINCT
- [ ] Aggregate at appropriate level
- [ ] Use QUALIFY instead of subqueries

**5. Result Caching**:
- [ ] Use consistent query formatting
- [ ] Leverage cached results
- [ ] Check cache hit rate

### Common Performance Anti-Patterns

❌ **Anti-Pattern 1: SELECT ***
```sql
-- Bad
SELECT * FROM large_table;

-- Good
SELECT customer_id, order_date, amount FROM large_table;
```

❌ **Anti-Pattern 2: Functions in WHERE**
```sql
-- Bad
WHERE YEAR(order_date) = 2024

-- Good
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
```

❌ **Anti-Pattern 3: Correlated Subqueries**
```sql
-- Bad
SELECT *
FROM customers c
WHERE (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id) > 5;

-- Good
SELECT c.*
FROM customers c
JOIN (
  SELECT customer_id, COUNT(*) as order_count
  FROM orders
  GROUP BY customer_id
  HAVING COUNT(*) > 5
) o ON c.customer_id = o.customer_id;
```

❌ **Anti-Pattern 4: Multiple CTEs Scanning Same Table**
```sql
-- Bad
WITH cte1 AS (SELECT * FROM large_table WHERE ...),
     cte2 AS (SELECT * FROM large_table WHERE ...)
SELECT ...;

-- Good
WITH base AS (SELECT * FROM large_table WHERE ...),
     cte1 AS (SELECT * FROM base WHERE ...),
     cte2 AS (SELECT * FROM base WHERE ...)
SELECT ...;
```

### Troubleshooting Workflow

```
1. Identify slow query
   ↓
2. Open Query Profile
   ↓
3. Check key metrics:
   - Execution time breakdown
   - Partitions scanned
   - Data spilling
   - Join operations
   ↓
4. Identify bottleneck
   ↓
5. Apply optimization:
   - Improve pruning
   - Optimize joins
   - Fix spilling
   - Refactor query
   ↓
6. Test and measure
   ↓
7. Repeat if needed
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Analyze Query Profiles
Learn to read and interpret query profiles.

### Exercise 2: Optimize Partition Pruning
Improve queries to maximize partition pruning.

### Exercise 3: Optimize JOIN Operations
Fix slow joins and reduce data volume.

### Exercise 4: Fix Data Spilling
Identify and resolve spilling issues.

### Exercise 5: Optimize Aggregations
Improve aggregation query performance.

### Exercise 6: Window Function Optimization
Optimize window function queries.

### Exercise 7: Real-World Query Tuning
Apply all techniques to optimize complex queries.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Query Profile is essential for performance diagnosis
- Partition pruning can reduce data scanned by 90%+
- Avoid functions on filtered columns
- Filter before joining to reduce data volume
- Data spilling severely impacts performance
- Increase warehouse size to fix spilling
- Use single-pass aggregations when possible
- Consistent window function partitioning improves performance
- Result caching provides free performance (24-hour TTL)
- EXPLAIN shows query execution plan
- Always measure before and after optimization
- Focus on biggest bottlenecks first

---

## 📚 Additional Resources

- [Snowflake Docs: Query Profile](https://docs.snowflake.com/en/user-guide/ui-query-profile)
- [Query Optimization Tips](https://docs.snowflake.com/en/user-guide/query-optimization)
- [Understanding Query Plans](https://docs.snowflake.com/en/user-guide/ui-query-profile-details)

---

## 🔜 Tomorrow: Day 12 - Warehouse Sizing & Scaling

We'll learn how to right-size warehouses and configure multi-cluster warehouses for optimal performance and cost.
