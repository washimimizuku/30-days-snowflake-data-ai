# Day 8: Clustering & Micro-Partitions

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake's micro-partition architecture
- Know when and how to use clustering keys
- Analyze clustering information and metrics
- Implement automatic clustering
- Measure query performance improvements
- Optimize clustering for cost and performance
- Apply clustering best practices for data engineering

---

## Theory

### Micro-Partitions: The Foundation

Snowflake automatically divides tables into **micro-partitions** - immutable storage units of 50-500 MB uncompressed (typically 16 MB compressed).

#### Key Characteristics

```
Table Data
    ↓
Automatically divided into micro-partitions
    ↓
Each micro-partition:
- 50-500 MB uncompressed
- 16 MB compressed (typical)
- Immutable (never modified)
- Contains metadata (min/max values, distinct counts)
- Stored in columnar format
```

**Benefits**:
- Automatic partition pruning
- Efficient data skipping
- Parallel query execution
- Optimal compression
- No manual maintenance

#### Partition Pruning

Snowflake uses micro-partition metadata to skip irrelevant partitions:

```sql
-- Query with date filter
SELECT * FROM orders WHERE order_date = '2025-01-15';

-- Snowflake process:
-- 1. Checks metadata for all micro-partitions
-- 2. Identifies partitions containing 2025-01-15
-- 3. Scans only relevant partitions (partition pruning)
-- 4. Skips all other partitions
```

**Example**:
- Table: 1 TB, 1000 micro-partitions
- Query filters on date
- Only 10 partitions contain that date
- Snowflake scans 10 partitions, skips 990
- 99% reduction in data scanned!

### Clustering Keys

**Clustering keys** define how data is organized within micro-partitions to optimize query performance.

#### When to Use Clustering Keys

✅ **Use clustering when**:
- Table is multi-terabyte (> 1 TB)
- Queries filter on specific columns frequently
- Query performance is slow despite optimization
- Data is not naturally ordered
- Partition pruning is ineffective

❌ **Don't use clustering when**:
- Table is small (< 1 TB)
- Queries don't filter on consistent columns
- Data is already well-ordered
- Cost of re-clustering exceeds benefits

#### Clustering Key Selection

**Good clustering key candidates**:
- Columns used in WHERE clauses frequently
- Columns used in JOIN conditions
- Date/timestamp columns for time-series data
- High-cardinality columns (many distinct values)
- Columns that benefit from range scans

**Poor clustering key candidates**:
- Low-cardinality columns (few distinct values)
- Columns rarely used in queries
- Columns with uniform distribution
- Too many columns (max 4 recommended)

#### Syntax

```sql
-- Create table with clustering key
CREATE TABLE orders (
  order_id INT,
  customer_id INT,
  order_date DATE,
  amount DECIMAL(10,2)
)
CLUSTER BY (order_date);

-- Add clustering key to existing table
ALTER TABLE orders CLUSTER BY (order_date);

-- Multiple column clustering
ALTER TABLE orders CLUSTER BY (order_date, customer_id);

-- Remove clustering key
ALTER TABLE orders DROP CLUSTERING KEY;
```

### Clustering Metrics

#### Clustering Information

```sql
-- View clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('orders', '(order_date)');

-- Returns JSON with:
-- - cluster_by_keys: clustering key columns
-- - total_partition_count: number of micro-partitions
-- - total_constant_partition_count: perfectly clustered partitions
-- - average_overlaps: average partition overlap
-- - average_depth: clustering depth
-- - partition_depth_histogram: distribution of depths
```

#### Clustering Depth

**Clustering depth** measures how well data is clustered:
- **Depth 1**: Perfect clustering (no overlap)
- **Depth 2-4**: Good clustering
- **Depth 5-10**: Moderate clustering
- **Depth > 10**: Poor clustering

```sql
-- Check clustering depth
SELECT SYSTEM$CLUSTERING_DEPTH('orders', '(order_date)');

-- Lower depth = better clustering
-- Depth increases as data is inserted/updated
```

#### Clustering Ratio

```sql
-- Clustering ratio (0-100%)
-- Higher is better
SELECT 
  table_name,
  clustering_key,
  ROUND(
    (total_constant_partition_count / NULLIF(total_partition_count, 0)) * 100, 
    2
  ) as clustering_ratio_pct
FROM (
  SELECT 
    'orders' as table_name,
    '(order_date)' as clustering_key,
    PARSE_JSON(SYSTEM$CLUSTERING_INFORMATION('orders', '(order_date)'))
  ) t,
  LATERAL FLATTEN(input => t.parse_json) f;
```

### Automatic Clustering

Snowflake can automatically re-cluster tables to maintain optimal clustering.

#### How It Works

```
Data Changes (INSERT/UPDATE/DELETE)
    ↓
Clustering degrades over time
    ↓
Automatic Clustering Service monitors
    ↓
Re-clusters when depth exceeds threshold
    ↓
Maintains optimal clustering
```

#### Enable Automatic Clustering

```sql
-- Enable on table creation
CREATE TABLE orders (
  order_id INT,
  order_date DATE,
  amount DECIMAL(10,2)
)
CLUSTER BY (order_date)
ENABLE_AUTOMATIC_CLUSTERING = TRUE;

-- Enable on existing table
ALTER TABLE orders 
  SUSPEND RECLUSTER;  -- Suspend first if needed

ALTER TABLE orders 
  RESUME RECLUSTER;  -- Enable automatic clustering
```

#### Suspend/Resume Clustering

```sql
-- Suspend automatic clustering (e.g., during bulk loads)
ALTER TABLE orders SUSPEND RECLUSTER;

-- Resume automatic clustering
ALTER TABLE orders RESUME RECLUSTER;

-- Check clustering status
SHOW TABLES LIKE 'orders';
-- Look at AUTOMATIC_CLUSTERING column
```

### Re-clustering Cost

Re-clustering consumes credits and should be monitored:

```sql
-- View re-clustering history
SELECT 
  start_time,
  end_time,
  table_name,
  credits_used,
  num_bytes_reclustered,
  num_rows_reclustered
FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
WHERE table_name = 'ORDERS'
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- Calculate daily re-clustering cost
SELECT 
  DATE(start_time) as date,
  SUM(credits_used) as total_credits,
  ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
WHERE table_name = 'ORDERS'
  AND start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 1 DESC;
```

### Clustering Strategies

#### Strategy 1: Single Column (Date/Timestamp)

**Best for**: Time-series data, event logs

```sql
CREATE TABLE events (
  event_id INT,
  event_timestamp TIMESTAMP_NTZ,
  event_type VARCHAR(50),
  user_id INT
)
CLUSTER BY (event_timestamp);

-- Queries benefit:
SELECT * FROM events 
WHERE event_timestamp >= '2025-01-01';
```

#### Strategy 2: Multiple Columns (Hierarchical)

**Best for**: Multi-dimensional queries

```sql
CREATE TABLE sales (
  sale_id INT,
  sale_date DATE,
  region VARCHAR(50),
  product_id INT,
  amount DECIMAL(10,2)
)
CLUSTER BY (sale_date, region);

-- Queries benefit:
SELECT * FROM sales 
WHERE sale_date = '2025-01-15' 
  AND region = 'WEST';
```

#### Strategy 3: Expression-Based Clustering

**Best for**: Derived values, date parts

```sql
CREATE TABLE orders (
  order_id INT,
  order_timestamp TIMESTAMP_NTZ,
  customer_id INT
)
CLUSTER BY (DATE(order_timestamp), customer_id);

-- Queries benefit:
SELECT * FROM orders 
WHERE DATE(order_timestamp) = '2025-01-15';
```

### Query Performance Analysis

#### Before Clustering

```sql
-- Query without clustering
SELECT * FROM large_table 
WHERE event_date = '2025-01-15';

-- Check query profile:
-- - Partitions scanned: 1000
-- - Partitions total: 1000
-- - Bytes scanned: 100 GB
-- - Query time: 30 seconds
```

#### After Clustering

```sql
-- Same query with clustering on event_date
SELECT * FROM large_table 
WHERE event_date = '2025-01-15';

-- Check query profile:
-- - Partitions scanned: 10
-- - Partitions total: 1000
-- - Bytes scanned: 1 GB (99% reduction!)
-- - Query time: 1 second (30x faster!)
```

### Best Practices

**1. Table Size Threshold**
- Only cluster tables > 1 TB
- Smaller tables don't benefit significantly
- Re-clustering cost may exceed benefits

**2. Clustering Key Selection**
- Max 4 columns recommended
- Order matters: most selective first
- Use columns in WHERE/JOIN clauses
- Prefer high-cardinality columns

**3. Monitor Clustering Health**
- Check clustering depth regularly
- Target depth < 5 for optimal performance
- Monitor re-clustering costs
- Adjust keys if depth consistently high

**4. Cost Optimization**
- Suspend clustering during bulk loads
- Resume after load completes
- Monitor credit consumption
- Balance performance vs. cost

**5. Query Patterns**
- Analyze query patterns first
- Cluster on most common filters
- Consider query frequency and importance
- Test performance before/after

**6. Maintenance**
- Review clustering effectiveness quarterly
- Adjust keys based on query patterns
- Remove clustering if not beneficial
- Document clustering decisions

### Common Pitfalls

❌ **Clustering small tables**
- Overhead exceeds benefits
- Unnecessary credit consumption

❌ **Too many clustering keys**
- Diminishing returns after 3-4 columns
- Increased re-clustering cost

❌ **Low-cardinality clustering keys**
- Boolean, status flags
- Limited partition pruning benefit

❌ **Clustering on rarely queried columns**
- No performance improvement
- Wasted re-clustering credits

❌ **Not monitoring costs**
- Re-clustering can be expensive
- May exceed query performance savings

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Analyze Micro-Partitions
Understand how Snowflake organizes data into micro-partitions.

### Exercise 2: Implement Clustering Keys
Add clustering keys to large tables and measure impact.

### Exercise 3: Analyze Clustering Metrics
Use clustering information functions to assess effectiveness.

### Exercise 4: Measure Query Performance
Compare query performance before and after clustering.

### Exercise 5: Automatic Clustering
Enable and monitor automatic clustering.

### Exercise 6: Cost Analysis
Calculate and analyze re-clustering costs.

### Exercise 7: Optimize Clustering Strategy
Refine clustering keys based on query patterns.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Micro-partitions are Snowflake's automatic storage units (50-500 MB uncompressed)
- Partition pruning skips irrelevant micro-partitions using metadata
- Clustering keys organize data for optimal query performance
- Only cluster tables > 1 TB with consistent query patterns
- Clustering depth measures effectiveness (target < 5)
- Automatic clustering maintains optimal organization
- Monitor re-clustering costs vs. performance benefits
- Max 4 clustering keys recommended
- Order matters: most selective column first
- Suspend clustering during bulk loads

---

## 📚 Additional Resources

- [Snowflake Docs: Micro-Partitions](https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions)
- [Snowflake Docs: Clustering Keys](https://docs.snowflake.com/en/user-guide/tables-clustering-keys)
- [Snowflake Docs: Automatic Clustering](https://docs.snowflake.com/en/user-guide/tables-auto-reclustering)
- [Best Practices: Clustering](https://docs.snowflake.com/en/user-guide/tables-clustering-best-practices)

---

## 🔜 Tomorrow: Day 9 - Search Optimization Service

We'll learn about Search Optimization Service for point lookup queries and how it complements clustering.
