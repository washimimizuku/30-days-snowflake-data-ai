# Day 12: Warehouse Sizing & Scaling

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand warehouse sizes and credit consumption
- Know when to scale up vs. scale out
- Configure multi-cluster warehouses
- Implement auto-suspend and auto-resume
- Choose appropriate scaling policies
- Monitor warehouse utilization and costs
- Right-size warehouses for different workloads
- Apply cost optimization strategies

---

## Theory

### Warehouse Sizes and Credits

Snowflake warehouses come in T-shirt sizes, each consuming credits per hour.

#### Size Chart

| Size | Credits/Hour | Relative Power | Use Case |
|------|--------------|----------------|----------|
| X-Small | 1 | 1x | Development, testing, small queries |
| Small | 2 | 2x | Light production workloads |
| Medium | 4 | 4x | Standard production workloads |
| Large | 8 | 8x | Heavy analytics, large data volumes |
| X-Large | 16 | 16x | Very large datasets, complex queries |
| 2X-Large | 32 | 32x | Massive data processing |
| 3X-Large | 64 | 64x | Extreme workloads |
| 4X-Large | 128 | 128x | Maximum single-cluster power |

#### Credit Calculation

```
Cost = Credits × Credit Price × Time

Example:
- Warehouse: Large (8 credits/hour)
- Credit price: $3/credit
- Running time: 30 minutes (0.5 hours)
- Cost: 8 × $3 × 0.5 = $12
```

#### Per-Second Billing

```
Minimum: 60 seconds
After that: Per-second billing

Example:
- Query runs for 45 seconds → Billed for 60 seconds
- Query runs for 90 seconds → Billed for 90 seconds
- Query runs for 3 minutes → Billed for 180 seconds
```

### Scale Up vs. Scale Out

**Scale Up** (Vertical Scaling):
- Increase warehouse size
- More compute power per cluster
- Better for: Complex queries, large data scans

**Scale Out** (Horizontal Scaling):
- Add more clusters (multi-cluster warehouse)
- More concurrent query capacity
- Better for: High concurrency, many users

#### When to Scale Up

✅ **Scale up when**:
- Queries are slow despite optimization
- Data spilling to disk
- Processing large data volumes
- Complex aggregations or joins
- Single user needs more power

```sql
-- Scale up for complex query
ALTER WAREHOUSE analytics_wh SET WAREHOUSE_SIZE = 'LARGE';

-- Run complex query
SELECT ... FROM large_table ...;

-- Scale back down
ALTER WAREHOUSE analytics_wh SET WAREHOUSE_SIZE = 'MEDIUM';
```

#### When to Scale Out

✅ **Scale out when**:
- Many concurrent users
- Query queuing occurs
- Need to maintain SLAs
- Workload is parallelizable
- Individual queries are already fast

```sql
-- Configure multi-cluster warehouse
ALTER WAREHOUSE analytics_wh SET
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 5
  SCALING_POLICY = 'STANDARD';
```

### Multi-Cluster Warehouses

Multi-cluster warehouses automatically add/remove clusters based on query load.

#### Configuration

```sql
CREATE WAREHOUSE multi_wh WITH
  WAREHOUSE_SIZE = 'MEDIUM'
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 10
  SCALING_POLICY = 'STANDARD'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE;
```

#### Key Parameters

**MIN_CLUSTER_COUNT**:
- Minimum clusters always running
- Default: 1
- Range: 1-10

**MAX_CLUSTER_COUNT**:
- Maximum clusters that can start
- Default: 1 (single-cluster)
- Range: 1-10
- Enterprise Edition required for > 1

**SCALING_POLICY**:
- STANDARD: Favors starting clusters (prevents queuing)
- ECONOMY: Favors conserving credits (allows some queuing)

### Scaling Policies

#### Standard Policy

```
Behavior:
- Starts clusters quickly when queries queue
- Minimizes query queuing
- Higher cost, better performance

Best for:
- User-facing applications
- BI dashboards
- Interactive analytics
- SLA-sensitive workloads
```

#### Economy Policy

```
Behavior:
- Waits longer before starting clusters
- Allows some queuing to save costs
- Lower cost, acceptable performance

Best for:
- Batch processing
- ETL workloads
- Non-time-sensitive queries
- Cost-sensitive environments
```

#### Comparison

```sql
-- Standard: Starts cluster after ~6 seconds of queuing
ALTER WAREHOUSE user_wh SET SCALING_POLICY = 'STANDARD';

-- Economy: Waits ~6 minutes before starting cluster
ALTER WAREHOUSE batch_wh SET SCALING_POLICY = 'ECONOMY';
```

### Auto-Suspend and Auto-Resume

#### Auto-Suspend

Automatically suspends warehouse after period of inactivity.

```sql
-- Suspend after 5 minutes (300 seconds)
ALTER WAREHOUSE my_wh SET AUTO_SUSPEND = 300;

-- Suspend after 1 minute (aggressive)
ALTER WAREHOUSE dev_wh SET AUTO_SUSPEND = 60;

-- Suspend after 10 minutes (conservative)
ALTER WAREHOUSE prod_wh SET AUTO_SUSPEND = 600;

-- Never auto-suspend (not recommended)
ALTER WAREHOUSE always_on_wh SET AUTO_SUSPEND = NULL;
```

**Best Practices**:
- Development: 60-120 seconds
- Production: 300-600 seconds
- Batch/ETL: 60 seconds (suspend quickly)
- Interactive: 300-600 seconds (keep warm)

#### Auto-Resume

Automatically resumes suspended warehouse when query submitted.

```sql
-- Enable auto-resume (recommended)
ALTER WAREHOUSE my_wh SET AUTO_RESUME = TRUE;

-- Disable auto-resume (manual control)
ALTER WAREHOUSE my_wh SET AUTO_RESUME = FALSE;
```

**Resume Time**: ~1-2 seconds (very fast)

### Warehouse Utilization Monitoring

#### Key Metrics

```sql
-- Warehouse load over time
SELECT 
  start_time,
  warehouse_name,
  AVG(avg_running) as avg_queries_running,
  AVG(avg_queued_load) as avg_queries_queued
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  AND warehouse_name = 'ANALYTICS_WH'
GROUP BY 1, 2
ORDER BY 1;

-- Credit consumption
SELECT 
  warehouse_name,
  DATE(start_time) as date,
  SUM(credits_used) as total_credits,
  ROUND(SUM(credits_used) * 3, 2) as estimated_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1, 2 DESC;

-- Warehouse efficiency
SELECT 
  warehouse_name,
  SUM(credits_used) as total_credits,
  COUNT(DISTINCT query_id) as query_count,
  ROUND(SUM(credits_used) / NULLIF(COUNT(DISTINCT query_id), 0), 4) as credits_per_query
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 3 DESC;
```

### Right-Sizing Strategies

#### Strategy 1: Start Small, Scale Up

```sql
-- Start with X-Small
CREATE WAREHOUSE test_wh WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Monitor performance
-- If queries are slow, scale up
ALTER WAREHOUSE test_wh SET WAREHOUSE_SIZE = 'SMALL';

-- Continue monitoring and adjusting
```

#### Strategy 2: Workload-Specific Warehouses

```sql
-- ETL warehouse (large, auto-suspend quickly)
CREATE WAREHOUSE etl_wh WITH
  WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- BI warehouse (medium, multi-cluster)
CREATE WAREHOUSE bi_wh WITH
  WAREHOUSE_SIZE = 'MEDIUM'
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 5
  SCALING_POLICY = 'STANDARD'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE;

-- Dev warehouse (x-small, aggressive suspend)
CREATE WAREHOUSE dev_wh WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;
```

#### Strategy 3: Time-Based Sizing

```sql
-- Scale up during business hours
-- 8 AM: Scale up
ALTER WAREHOUSE bi_wh SET WAREHOUSE_SIZE = 'LARGE';

-- 6 PM: Scale down
ALTER WAREHOUSE bi_wh SET WAREHOUSE_SIZE = 'MEDIUM';

-- Automate with tasks or external scheduler
```

### Cost Optimization Techniques

#### 1. Aggressive Auto-Suspend

```sql
-- Suspend after 1 minute for infrequent workloads
ALTER WAREHOUSE occasional_wh SET AUTO_SUSPEND = 60;
```

#### 2. Right-Size Warehouses

```sql
-- Monitor and adjust based on actual usage
-- If warehouse is idle 80% of time, it's too large
-- If queries are queuing, it's too small or needs scale-out
```

#### 3. Separate Workloads

```sql
-- Don't mix ETL and BI on same warehouse
-- ETL: Large warehouse, short auto-suspend
-- BI: Medium warehouse, multi-cluster, longer auto-suspend
```

#### 4. Use Resource Monitors

```sql
-- Set credit limits
CREATE RESOURCE MONITOR monthly_limit WITH
  CREDIT_QUOTA = 1000
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND
    ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Assign to warehouse
ALTER WAREHOUSE analytics_wh SET RESOURCE_MONITOR = monthly_limit;
```

#### 5. Leverage Result Caching

```sql
-- Cached results = 0 credits
-- Encourage consistent query patterns
-- Use query tags for similar queries
```

### Common Sizing Scenarios

#### Scenario 1: BI Dashboard

```
Requirements:
- 50 concurrent users
- Interactive queries (< 5 seconds)
- Peak hours: 9 AM - 5 PM

Solution:
- Size: Medium
- Multi-cluster: 1-5 clusters
- Scaling: Standard
- Auto-suspend: 300 seconds
```

#### Scenario 2: Nightly ETL

```
Requirements:
- Large data volumes (TB+)
- Batch processing
- Must complete in 2-hour window

Solution:
- Size: X-Large or 2X-Large
- Single cluster
- Auto-suspend: 60 seconds
- Run during off-peak hours
```

#### Scenario 3: Ad-Hoc Analytics

```
Requirements:
- Data scientists
- Unpredictable workload
- Cost-sensitive

Solution:
- Size: Small or Medium
- Single cluster
- Auto-suspend: 120 seconds
- Scale up manually for large queries
```

#### Scenario 4: Real-Time Application

```
Requirements:
- Always available
- Low latency (< 1 second)
- Consistent performance

Solution:
- Size: Medium
- Multi-cluster: 2-4 clusters (min 2)
- Scaling: Standard
- Auto-suspend: 600 seconds or NULL
```

### Monitoring and Alerting

#### Key Metrics to Track

```sql
-- 1. Credit consumption trend
SELECT 
  DATE_TRUNC('week', start_time) as week,
  warehouse_name,
  SUM(credits_used) as weekly_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(week, -8, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;

-- 2. Query queuing
SELECT 
  warehouse_name,
  DATE(start_time) as date,
  COUNT(*) as queued_queries,
  AVG(queued_overload_time) as avg_queue_time_ms
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE queued_overload_time > 0
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 3. Warehouse idle time
SELECT 
  warehouse_name,
  SUM(credits_used) as total_credits,
  SUM(credits_used_compute) as compute_credits,
  SUM(credits_used_cloud_services) as cloud_services_credits,
  ROUND((compute_credits / NULLIF(total_credits, 0)) * 100, 2) as compute_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;
```

### Best Practices Summary

**Sizing**:
- Start small, scale up as needed
- Separate workloads by warehouse
- Monitor utilization regularly
- Right-size based on actual usage

**Scaling**:
- Use multi-cluster for concurrency
- Standard policy for interactive workloads
- Economy policy for batch workloads
- Monitor query queuing

**Auto-Suspend**:
- Development: 60-120 seconds
- Production: 300-600 seconds
- ETL: 60 seconds
- Always-on: Consider carefully (expensive)

**Cost Optimization**:
- Aggressive auto-suspend
- Right-size warehouses
- Use resource monitors
- Leverage result caching
- Separate workloads

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create and Configure Warehouses
Set up warehouses for different workloads.

### Exercise 2: Test Scaling Behavior
Observe scale up and scale out in action.

### Exercise 3: Configure Multi-Cluster Warehouses
Set up and test multi-cluster configurations.

### Exercise 4: Monitor Warehouse Utilization
Track credit consumption and efficiency.

### Exercise 5: Implement Resource Monitors
Set up credit limits and alerts.

### Exercise 6: Right-Size Warehouses
Analyze and optimize warehouse sizes.

### Exercise 7: Cost Optimization
Apply cost-saving strategies.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Warehouse sizes range from X-Small (1 credit/hour) to 4X-Large (128 credits/hour)
- Per-second billing after 60-second minimum
- Scale up for complex queries, scale out for concurrency
- Multi-cluster warehouses handle concurrent users
- Standard policy minimizes queuing, Economy saves costs
- Auto-suspend saves credits during idle periods
- Auto-resume provides instant availability
- Right-sizing requires monitoring and adjustment
- Separate workloads by warehouse type
- Resource monitors prevent cost overruns
- Start small and scale up as needed

---

## 📚 Additional Resources

- [Snowflake Docs: Warehouses](https://docs.snowflake.com/en/user-guide/warehouses)
- [Multi-Cluster Warehouses](https://docs.snowflake.com/en/user-guide/warehouses-multicluster)
- [Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors)

---

## 🔜 Tomorrow: Day 13 - Result Caching & Persisted Results

We'll learn how to leverage Snowflake's caching mechanisms to improve performance and reduce costs.
