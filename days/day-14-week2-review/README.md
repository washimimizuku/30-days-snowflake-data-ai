# Day 14: Week 2 Review & Performance Optimization Lab

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Review and consolidate all Week 2 performance concepts
- Integrate clustering, search optimization, and caching strategies
- Build a complete performance-optimized data warehouse
- Apply best practices for query optimization
- Assess your understanding with comprehensive quiz
- Identify areas needing additional review

---

## Week 2 Recap

### What We've Learned

**Day 8: Clustering & Micro-Partitions**
- Automatic micro-partitioning (50-500 MB compressed)
- Clustering keys for partition pruning
- Automatic clustering vs. manual reclustering
- Clustering depth and monitoring
- When to cluster and when not to

**Day 9: Search Optimization Service**
- Point lookup optimization (equality predicates)
- Search access paths vs. clustering
- Substring and variant searches
- Cost-benefit analysis
- Monitoring search optimization effectiveness

**Day 10: Materialized Views**
- Pre-computed query results
- Automatic maintenance and refresh
- Incremental vs. full refresh
- Materialized views vs. dynamic tables
- Cost optimization strategies

**Day 11: Query Performance Tuning**
- Query profile analysis
- Partition pruning optimization
- JOIN optimization strategies
- Data spilling prevention
- Predicate pushdown
- Query rewriting techniques

**Day 12: Warehouse Sizing & Scaling**
- Warehouse sizes (X-Small to 4X-Large)
- Scale up vs. scale out
- Multi-cluster warehouses
- Standard vs. Economy scaling policies
- Auto-suspend and auto-resume
- Resource monitors

**Day 13: Result Caching**
- Three-layer caching (Result, Metadata, Warehouse)
- 24-hour result cache (FREE)
- Metadata-only queries
- Cache hit requirements
- Cache invalidation rules
- Maximizing cache effectiveness

---

## Theory: Performance Optimization Framework

### The Performance Optimization Hierarchy

```
Level 1: Data Organization
├─ Micro-partitions (automatic)
├─ Clustering keys (selective)
└─ Table design (data types, structure)

Level 2: Query Optimization
├─ Partition pruning
├─ JOIN optimization
├─ Predicate pushdown
└─ Query rewriting

Level 3: Caching
├─ Result cache (24 hours, FREE)
├─ Metadata cache (instant)
└─ Warehouse cache (while running)

Level 4: Compute Resources
├─ Warehouse sizing
├─ Multi-cluster scaling
└─ Auto-suspend/resume

Level 5: Specialized Features
├─ Search Optimization Service
├─ Materialized Views
└─ Dynamic Tables
```

### Decision Framework

#### When to Use Clustering

✅ **Use clustering when**:
- Table > 1 TB
- Queries filter on specific columns consistently
- High cardinality columns (dates, IDs)
- Partition pruning is poor (< 50%)
- Query patterns are predictable

❌ **Don't cluster when**:
- Table < 100 GB
- Queries filter on many different columns
- Very high cardinality (unique IDs)
- Very low cardinality (boolean, status)
- Data changes frequently

#### When to Use Search Optimization

✅ **Use search optimization when**:
- Point lookups (WHERE id = 123)
- Equality predicates on selective columns
- Substring searches (LIKE '%pattern%')
- VARIANT column searches
- Clustering doesn't help (too many columns)

❌ **Don't use when**:
- Range queries (already clustered)
- Full table scans needed
- Low query frequency
- Cost exceeds benefit

#### When to Use Materialized Views

✅ **Use materialized views when**:
- Expensive aggregations queried frequently
- Query patterns are consistent
- Base tables change infrequently
- Sub-second response time needed
- Cost of maintenance < cost of recomputing

❌ **Don't use when**:
- Base tables change constantly
- Query patterns vary widely
- Simple queries (already fast)
- Maintenance cost too high

### Performance Optimization Workflow

```
1. IDENTIFY
   ├─ Slow queries (Query History)
   ├─ High-cost queries (credit consumption)
   └─ User complaints

2. ANALYZE
   ├─ Query Profile (execution plan)
   ├─ Partition pruning statistics
   ├─ Data spilling indicators
   └─ Cache hit rates

3. OPTIMIZE
   ├─ Add clustering keys
   ├─ Enable search optimization
   ├─ Create materialized views
   ├─ Rewrite queries
   ├─ Adjust warehouse size
   └─ Optimize for caching

4. MONITOR
   ├─ Query performance trends
   ├─ Cost vs. benefit analysis
   ├─ Cache effectiveness
   └─ Warehouse utilization

5. ITERATE
   └─ Continuous improvement
```

### Best Practices

**1. Data Organization**
- Let Snowflake handle micro-partitioning automatically
- Add clustering keys only when needed (large tables, predictable queries)
- Use appropriate data types (smaller = faster)
- Normalize when necessary, denormalize for performance
- Consider table design for query patterns

**2. Query Optimization**
- Always check Query Profile first
- Optimize for partition pruning (> 90% pruned is ideal)
- Use selective filters early in queries
- Avoid SELECT * (specify columns)
- Use appropriate JOIN types and order
- Leverage CTEs for readability and optimization
- Push predicates down to subqueries

**3. Caching Strategy**
- Use consistent query formatting for result cache
- Avoid non-deterministic functions (CURRENT_DATE())
- Keep warehouses running for frequently-accessed data
- Leverage metadata cache (COUNT(*), MIN, MAX)
- Monitor cache hit rates (target > 50%)
- Batch table updates to minimize cache invalidation

**4. Warehouse Management**
- Start small, scale up if needed
- Use multi-cluster for concurrency, not speed
- Set aggressive auto-suspend (60-120 seconds)
- Separate workloads by warehouse
- Monitor queuing and adjust
- Use resource monitors to control costs

**5. Specialized Features**
- Enable search optimization for point lookups
- Create materialized views for expensive aggregations
- Use dynamic tables for incremental transformations
- Monitor costs vs. benefits
- Disable features that don't provide value

**6. Cost Optimization**
- Result cache = FREE (maximize usage)
- Right-size warehouses (don't over-provision)
- Use clustering selectively (maintenance costs credits)
- Monitor search optimization costs
- Balance performance vs. cost
- Set up cost alerts and budgets

### Common Performance Patterns

#### Pattern 1: Time-Series Data

**Challenge**: Large tables with date-based queries

**Solution**:
```sql
-- Cluster on date column
ALTER TABLE events CLUSTER BY (event_date);

-- Queries benefit from partition pruning
SELECT * FROM events
WHERE event_date >= '2024-01-01'
  AND event_date < '2024-02-01';
-- 90%+ partitions pruned
```

#### Pattern 2: High-Cardinality Lookups

**Challenge**: Point lookups on ID columns

**Solution**:
```sql
-- Enable search optimization
ALTER TABLE customers ADD SEARCH OPTIMIZATION;

-- Fast point lookups
SELECT * FROM customers WHERE customer_id = 12345;
-- Uses search access path
```

#### Pattern 3: Expensive Aggregations

**Challenge**: Complex aggregations queried frequently

**Solution**:
```sql
-- Create materialized view
CREATE MATERIALIZED VIEW daily_sales AS
SELECT 
  DATE(order_date) as date,
  SUM(amount) as total_sales,
  COUNT(*) as order_count
FROM orders
GROUP BY 1;

-- Fast queries
SELECT * FROM daily_sales WHERE date = '2024-12-08';
```

#### Pattern 4: Dashboard Queries

**Challenge**: Same queries run repeatedly

**Solution**:
```sql
-- Use consistent formatting for result cache
CREATE VIEW dashboard_metrics AS
SELECT 
  region,
  COUNT(*) as customer_count,
  SUM(revenue) as total_revenue
FROM customers
WHERE signup_date >= '2024-01-01'
GROUP BY region;

-- First query: computes
-- Subsequent queries: cached (FREE)
SELECT * FROM dashboard_metrics;
```

#### Pattern 5: Complex JOINs

**Challenge**: Multi-table JOINs are slow

**Solution**:
```sql
-- Optimize JOIN order (small to large)
-- Use appropriate JOIN types
-- Add clustering on JOIN keys

SELECT o.*, c.customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2024-01-01'
  AND c.region = 'NORTH';

-- Cluster both tables on join key
ALTER TABLE orders CLUSTER BY (customer_id);
ALTER TABLE customers CLUSTER BY (customer_id);
```

### Troubleshooting Guide

#### Issue 1: Slow Queries

**Symptoms**: Queries take minutes instead of seconds

**Diagnosis**:
1. Check Query Profile
2. Look for partition pruning percentage
3. Check for data spilling
4. Analyze JOIN operations

**Solutions**:
- Add clustering keys for better pruning
- Increase warehouse size if spilling
- Optimize JOIN order
- Rewrite query for efficiency

#### Issue 2: High Costs

**Symptoms**: Credit consumption exceeds budget

**Diagnosis**:
1. Check warehouse metering history
2. Identify expensive queries
3. Analyze cache hit rates
4. Review clustering maintenance costs

**Solutions**:
- Right-size warehouses
- Maximize result cache usage
- Optimize expensive queries
- Set resource monitors
- Review clustering necessity

#### Issue 3: Poor Cache Hit Rates

**Symptoms**: < 20% result cache hits

**Diagnosis**:
1. Check query formatting consistency
2. Look for non-deterministic functions
3. Analyze table update frequency
4. Review query patterns

**Solutions**:
- Standardize query formatting
- Replace CURRENT_DATE() with specific dates
- Batch table updates
- Use views for common queries

#### Issue 4: Query Queuing

**Symptoms**: Queries wait in queue

**Diagnosis**:
1. Check warehouse load history
2. Analyze concurrent query count
3. Review warehouse size

**Solutions**:
- Scale out (multi-cluster)
- Separate workloads
- Optimize slow queries
- Increase warehouse size if needed

---

## 💻 Project: Performance Optimization Lab (90 min)

Today's project applies all Week 2 concepts to optimize a real-world data warehouse.

### Project Overview

**Scenario**: You're optimizing a retail analytics data warehouse with performance and cost issues.

**Current Problems**:
1. Slow dashboard queries (30+ seconds)
2. High credit consumption ($5000/month)
3. Poor cache hit rates (15%)
4. Frequent query queuing
5. Customer complaints about slow reports

**Your Mission**:
Optimize the warehouse for performance and cost using Week 2 techniques.

**Architecture**:
```
Raw Data (1 TB)
├─ orders (500 GB, 100M rows)
├─ customers (50 GB, 10M rows)
├─ products (5 GB, 100K rows)
└─ order_items (450 GB, 500M rows)

Analytics Queries
├─ Daily sales dashboard (run 100x/day)
├─ Customer lookup (run 1000x/day)
├─ Product performance report (run 50x/day)
└─ Regional analysis (run 200x/day)
```

### Implementation Steps

Complete the project in `exercise.sql`. The exercise includes:

1. **Baseline Analysis** (15 min)
   - Analyze current query performance
   - Identify slow queries
   - Calculate current costs
   - Measure cache hit rates

2. **Clustering Optimization** (20 min)
   - Analyze query patterns
   - Add clustering keys to large tables
   - Monitor clustering depth
   - Measure improvement

3. **Search Optimization** (15 min)
   - Identify point lookup queries
   - Enable search optimization
   - Test performance improvement
   - Analyze cost vs. benefit

4. **Materialized Views** (15 min)
   - Identify expensive aggregations
   - Create materialized views
   - Test query performance
   - Monitor maintenance costs

5. **Caching Strategy** (10 min)
   - Standardize query formatting
   - Remove non-deterministic functions
   - Create views for common queries
   - Measure cache hit improvement

6. **Warehouse Optimization** (10 min)
   - Right-size warehouses
   - Configure auto-suspend
   - Set up resource monitors
   - Separate workloads

7. **Results & ROI** (5 min)
   - Measure performance improvements
   - Calculate cost savings
   - Document optimizations
   - Create monitoring dashboard

**Expected Results**:
- Query performance: 10-50x faster
- Cost reduction: 30-50%
- Cache hit rate: 50-80%
- User satisfaction: High

---

## ✅ Quiz (30 min)

Complete the comprehensive 50-question quiz in `quiz.md` to assess your Week 2 knowledge.

**Topics Covered**:
- Clustering & Micro-Partitions (10 questions)
- Search Optimization Service (8 questions)
- Materialized Views (8 questions)
- Query Performance Tuning (8 questions)
- Warehouse Sizing & Scaling (8 questions)
- Result Caching (8 questions)

**Scoring**:
- 45-50: Excellent! Ready for Week 3
- 40-44: Good! Review missed topics
- 35-39: Fair - Review Week 2 materials
- < 35: Review all Week 2 days before continuing

---

## 🎯 Key Takeaways

### Core Concepts Mastered

**Data Organization**:
- Micro-partitions are automatic (50-500 MB)
- Clustering keys improve partition pruning
- Automatic clustering maintains organization
- Clustering depth indicates effectiveness
- Selective clustering saves costs

**Query Optimization**:
- Query Profile reveals bottlenecks
- Partition pruning is critical (target > 90%)
- JOIN order matters (small to large)
- Data spilling indicates undersized warehouse
- Predicate pushdown improves performance

**Caching**:
- Result cache: 24 hours, FREE, exact match
- Metadata cache: instant COUNT(*), MIN, MAX
- Warehouse cache: persists while running
- Cache hits = 0 credits
- Consistent formatting maximizes hits

**Compute Resources**:
- Scale up for speed (complex queries)
- Scale out for concurrency (many users)
- Auto-suspend saves costs
- Multi-cluster handles variable load
- Resource monitors prevent overruns

**Specialized Features**:
- Search optimization: point lookups, equality
- Materialized views: expensive aggregations
- Dynamic tables: incremental transformations
- Cost-benefit analysis is critical
- Monitor effectiveness continuously

### Real-World Applications

**E-commerce Analytics**:
- Cluster orders by date
- Search optimization on customer_id
- Materialized views for daily sales
- Cache dashboard queries
- Multi-cluster for peak traffic

**Financial Reporting**:
- Cluster transactions by date
- Materialized views for regulatory reports
- Result cache for repeated queries
- Large warehouses for month-end processing
- Resource monitors for budget control

**Customer 360**:
- Search optimization on customer lookups
- Materialized views for customer metrics
- Clustering on customer_id
- Cache for dashboard queries
- Separate warehouses by department

**IoT Analytics**:
- Cluster sensor data by timestamp
- Materialized views for aggregations
- Dynamic tables for real-time metrics
- Warehouse cache for recent data
- Auto-suspend for cost control

---

## 📚 Week 2 Study Guide

### Must-Know Facts

**Clustering**:
- Micro-partitions: 50-500 MB compressed
- Clustering keys: 3-4 columns maximum
- Automatic clustering: Enterprise Edition
- Clustering depth: 0-1 is ideal
- Maintenance costs credits

**Search Optimization**:
- Best for equality predicates
- Supports VARIANT columns
- Maintenance cost: ~10% of table size
- Not for range queries
- Monitor with SEARCH_OPTIMIZATION_HISTORY

**Materialized Views**:
- Automatic maintenance
- Incremental refresh when possible
- Limited query support (no window functions)
- Cost: maintenance + storage
- Alternative: Dynamic Tables

**Query Performance**:
- Partition pruning: > 90% is ideal
- Data spilling: increase warehouse size
- JOIN order: small to large tables
- Predicate pushdown: filter early
- Query Profile: primary diagnostic tool

**Warehouses**:
- Sizes: X-Small (1) to 4X-Large (128 credits/hour)
- Billing: 60-second minimum, per-second after
- Multi-cluster: 1-10 clusters max
- Standard policy: minimize queuing
- Economy policy: minimize cost

**Caching**:
- Result cache: 24 hours, FREE
- Metadata cache: COUNT(*), MIN, MAX
- Warehouse cache: cleared on suspend
- Cache hit requirements: exact match
- DML invalidates result cache

### Common Exam Questions

1. **When to add clustering keys?**
   - Large tables (> 1 TB)
   - Predictable query patterns
   - Poor partition pruning
   - High cardinality columns

2. **Search optimization vs. clustering?**
   - Search: point lookups, many columns
   - Clustering: range queries, few columns
   - Can use both together

3. **When to scale up vs. scale out?**
   - Scale up: slow queries, large data
   - Scale out: concurrency, queuing

4. **What invalidates result cache?**
   - DML operations (INSERT, UPDATE, DELETE)
   - 24-hour expiration
   - Different query text
   - Table modifications

5. **Materialized views vs. dynamic tables?**
   - MV: Limited queries, automatic
   - DT: More flexible, TARGET_LAG control

### Review Checklist

Before moving to Week 3, ensure you can:

- [ ] Explain micro-partitioning and clustering
- [ ] Decide when to add clustering keys
- [ ] Enable and monitor search optimization
- [ ] Create and maintain materialized views
- [ ] Analyze Query Profile for bottlenecks
- [ ] Optimize partition pruning
- [ ] Prevent data spilling
- [ ] Size and scale warehouses appropriately
- [ ] Maximize cache hit rates
- [ ] Calculate cost vs. benefit for optimizations
- [ ] Build comprehensive monitoring dashboards
- [ ] Troubleshoot performance issues

---

## 🔜 Next Week: Data Governance & Security

**Week 3 Preview**:
- Day 15: Role-Based Access Control (RBAC)
- Day 16: Data Masking & Privacy
- Day 17: Row Access Policies
- Day 18: Data Sharing & Secure Views
- Day 19: Time Travel & Fail-Safe
- Day 20: Cloning & Zero-Copy Cloning
- Day 21: Week 3 Review & Governance Lab

**Focus**: Securing and governing data in Snowflake

**Skills**: Access control, data privacy, compliance, data protection

---

## 📖 Additional Resources

### Snowflake Documentation
- [Clustering Keys](https://docs.snowflake.com/en/user-guide/tables-clustering-keys)
- [Search Optimization](https://docs.snowflake.com/en/user-guide/search-optimization-service)
- [Materialized Views](https://docs.snowflake.com/en/user-guide/views-materialized)
- [Query Performance](https://docs.snowflake.com/en/user-guide/ui-query-profile)
- [Warehouse Sizing](https://docs.snowflake.com/en/user-guide/warehouses-considerations)
- [Caching](https://docs.snowflake.com/en/user-guide/querying-persisted-results)

### Performance Guides
- [Performance Optimization Guide](https://docs.snowflake.com/en/user-guide/performance-query)
- [Cost Optimization Best Practices](https://www.snowflake.com/blog/cost-optimization/)

### Community Resources
- [Snowflake Community](https://community.snowflake.com/)
- [Performance Tuning Tips](https://community.snowflake.com/s/topic/0TO0Z000000Unu8WAC/performance)

---

## Self-Assessment

### Before Week 3

Rate your confidence (1-5) in each area:

**Clustering & Micro-Partitions**: ___/5  
**Search Optimization**: ___/5  
**Materialized Views**: ___/5  
**Query Performance Tuning**: ___/5  
**Warehouse Sizing & Scaling**: ___/5  
**Result Caching**: ___/5  

**Overall Week 2**: ___/5

**Areas needing review**:
1. _______________
2. _______________
3. _______________

**Action plan**:
- If any area < 3: Review that day's materials
- If overall < 3.5: Spend extra day on Week 2
- If overall >= 4: Ready for Week 3!

---

## Performance Optimization Checklist

Use this checklist for any Snowflake performance project:

### Analysis Phase
- [ ] Identify slow queries (Query History)
- [ ] Analyze Query Profiles
- [ ] Check partition pruning percentages
- [ ] Review cache hit rates
- [ ] Calculate current costs
- [ ] Document baseline metrics

### Optimization Phase
- [ ] Add clustering keys (if needed)
- [ ] Enable search optimization (if beneficial)
- [ ] Create materialized views (for aggregations)
- [ ] Optimize query SQL
- [ ] Standardize query formatting
- [ ] Right-size warehouses
- [ ] Configure auto-suspend
- [ ] Set up resource monitors

### Monitoring Phase
- [ ] Track query performance trends
- [ ] Monitor cache effectiveness
- [ ] Review warehouse utilization
- [ ] Calculate cost savings
- [ ] Measure user satisfaction
- [ ] Document optimizations

### Maintenance Phase
- [ ] Review clustering depth regularly
- [ ] Monitor search optimization costs
- [ ] Check materialized view freshness
- [ ] Adjust warehouse sizes as needed
- [ ] Update resource monitor limits
- [ ] Iterate on optimizations

---

## Congratulations! 🎉

You've completed Week 2 of the SnowPro Advanced Data Engineer bootcamp!

**What you've accomplished**:
- ✅ Mastered 6 performance optimization techniques
- ✅ Built comprehensive optimization projects
- ✅ Created a complete performance-optimized warehouse
- ✅ Completed comprehensive review quiz

**You're now ready to**:
- Optimize any Snowflake workload
- Reduce costs by 30-50%
- Improve query performance 10-100x
- Make data-driven optimization decisions

**Performance Gains Achieved**:
- Query speed: 10-100x faster
- Cost reduction: 30-50%
- Cache hit rates: 50-80%
- User satisfaction: Significantly improved

**Keep up the momentum!** Week 3 focuses on data governance and security.

See you tomorrow for Day 15: Role-Based Access Control! 🚀
