# Day 25 Quiz: Hands-On Project Assessment

## Project Reflection & Knowledge Check

**Time: 10 minutes**  
**Questions: 10**  
**Passing Score: 70% (7/10)**

This quiz assesses your understanding of the complete end-to-end data engineering solution you just built.

---

### Question 1
In the e-commerce analytics platform, what is the primary purpose of using Streams on the raw_orders table?

A) To improve query performance on the raw data  
B) To track changes (INSERT, UPDATE, DELETE) for incremental processing  
C) To automatically partition the data by region  
D) To enforce data quality rules on incoming data

**Correct Answer: B**

**Explanation:** Streams capture change data (CDC) from the raw_orders table, allowing the ETL process to identify and process only new or changed records incrementally, rather than reprocessing the entire table.

---

### Question 2
Why is the orders table clustered by (order_date, region)?

A) To reduce storage costs  
B) To enable Time Travel functionality  
C) To improve query performance for date and region-based filters  
D) To automatically partition data across warehouses

**Correct Answer: C**

**Explanation:** Clustering by order_date and region organizes micro-partitions to optimize queries that filter on these columns, which are common in analytics queries (e.g., "sales by region for last 30 days").

---

### Question 3
What happens when the process_orders_task executes?

A) It loads data from S3 into raw tables  
B) It reads from the orders_stream and merges changes into the curated orders table  
C) It creates a backup of all tables  
D) It generates reports for business users

**Correct Answer: B**

**Explanation:** The task calls the process_orders() stored procedure, which reads from the orders_stream (capturing changes from raw_orders) and uses MERGE to update the curated orders table incrementally.

---

### Question 4
In the security implementation, what does the email_mask masking policy do?

A) Deletes all email addresses from the database  
B) Shows full emails to ECOMMERCE_ADMIN and DATA_ENGINEER roles, masks for others  
C) Encrypts email addresses using AES-256  
D) Prevents users from querying the email column

**Correct Answer: B**

**Explanation:** The masking policy uses CASE logic to show full email addresses to admin and engineer roles, while masking the username portion (before @) with *** for other roles like analysts.

---

### Question 5
What is the purpose of the regional_access row access policy?

A) To improve query performance by filtering data  
B) To restrict regional managers to see only their region's data  
C) To automatically route queries to regional warehouses  
D) To encrypt data based on region

**Correct Answer: B**

**Explanation:** The row access policy enforces row-level security, ensuring regional managers (e.g., REGIONAL_MANAGER_NORTH) can only query data where region = 'NORTH', while admin roles can see all regions.

---

### Question 6
Why are materialized views used in the analytics layer instead of regular views?

A) Materialized views are cheaper to maintain  
B) Materialized views automatically mask sensitive data  
C) Materialized views pre-compute and store results for faster query performance  
D) Materialized views support Time Travel for longer periods

**Correct Answer: C**

**Explanation:** Materialized views physically store pre-computed aggregations (like daily_sales_summary), making dashboard queries much faster since they don't need to re-aggregate data on every query.

---

### Question 7
What is the benefit of setting different warehouse sizes for different workloads?

A) All warehouses must be the same size for consistency  
B) Smaller warehouses for simple tasks save costs, larger for complex queries improve performance  
C) Warehouse size determines data retention period  
D) Larger warehouses automatically enable clustering

**Correct Answer: B**

**Explanation:** Right-sizing warehouses optimizes cost vs. performance: ingestion_wh (XSMALL) for simple loads, processing_wh (SMALL) for ETL, analytics_wh (MEDIUM) for complex analytical queries.

---

### Question 8
What does the WHEN SYSTEM$STREAM_HAS_DATA() clause in the task definition accomplish?

A) It prevents the task from running when the stream is empty, saving compute costs  
B) It automatically scales the warehouse based on data volume  
C) It creates a backup of stream data before processing  
D) It validates data quality before processing

**Correct Answer: A**

**Explanation:** This condition ensures the task only runs when the stream contains new data, avoiding unnecessary warehouse usage and costs when there are no changes to process.

---

### Question 9
In the project, why is Time Travel retention set to 30 days for orders and customers tables?

A) To comply with data privacy regulations  
B) To enable data recovery and historical queries for critical business data  
C) To improve query performance  
D) To reduce storage costs

**Correct Answer: B**

**Explanation:** Setting DATA_RETENTION_TIME_IN_DAYS = 30 for critical tables allows recovery from accidental deletes/updates and enables historical analysis using Time Travel queries for up to 30 days.

---

### Question 10
What is the primary advantage of using stored procedures (like process_orders()) instead of simple SQL in tasks?

A) Stored procedures run faster than SQL  
B) Stored procedures enable complex logic, error handling, and multiple operations in a single transaction  
C) Stored procedures automatically optimize queries  
D) Stored procedures are required for tasks to work

**Correct Answer: B**

**Explanation:** Stored procedures allow complex ETL logic with variables, conditional logic, error handling, and multiple SQL statements, making them ideal for orchestrating multi-step data processing workflows.

---

## Answer Key

| Question | Answer | Topic |
|----------|--------|-------|
| 1 | B | Streams & CDC |
| 2 | C | Clustering & Performance |
| 3 | B | Tasks & Automation |
| 4 | B | Data Masking |
| 5 | B | Row Access Policies |
| 6 | C | Materialized Views |
| 7 | B | Warehouse Sizing |
| 8 | A | Task Optimization |
| 9 | B | Time Travel |
| 10 | B | Stored Procedures |

---

## Scoring Guide

- **10/10 (100%)**: Excellent! You have a strong understanding of all project components
- **8-9/10 (80-90%)**: Very Good! Minor review needed on 1-2 concepts
- **7/10 (70%)**: Good! Review the topics you missed before practice exams
- **Below 7/10**: Review the project implementation and related day lessons

---

## Project Completion Checklist

Use this checklist to verify your project is complete:

### Infrastructure
- [ ] Created 4 databases (raw, curated, analytics, governance)
- [ ] Created 3 warehouses with appropriate sizing
- [ ] Created role hierarchy with 5 roles
- [ ] Granted appropriate privileges to each role

### Data Ingestion
- [ ] Created external stage and file formats
- [ ] Created landing tables (raw_orders, raw_customers, raw_products)
- [ ] Loaded sample data successfully
- [ ] Verified data in raw tables

### Change Tracking
- [ ] Created streams on raw tables
- [ ] Verified streams capture changes
- [ ] Tested SYSTEM$STREAM_HAS_DATA() function

### Data Processing
- [ ] Created curated tables with clustering
- [ ] Implemented process_orders() stored procedure
- [ ] Created UDFs for business logic
- [ ] Created automated task with conditional execution
- [ ] Verified task runs successfully

### Security
- [ ] Created and applied masking policies (email, phone)
- [ ] Created and applied row access policy (regional_access)
- [ ] Configured Time Travel retention
- [ ] Tested security as different roles

### Analytics
- [ ] Created 3 materialized views
- [ ] Created secure views for analysts
- [ ] Created dynamic table (optional)
- [ ] Verified query performance

### Monitoring
- [ ] Created audit tables
- [ ] Created monitoring views (query_performance, warehouse_usage, task_execution_history)
- [ ] Created data quality checks
- [ ] Tested monitoring queries

### Testing
- [ ] Tested data ingestion
- [ ] Tested stream processing
- [ ] Tested task execution
- [ ] Tested security policies
- [ ] Tested query performance
- [ ] Tested UDFs and stored procedures

### Documentation
- [ ] Documented architecture
- [ ] Documented data flow
- [ ] Created operations runbook
- [ ] Documented key monitoring queries

---

## Self-Assessment Questions

Reflect on your project implementation:

### Architecture & Design
1. **Can you explain the data flow from S3 to analytics layer?**
   - Expected: S3 → Snowpipe → Raw tables → Streams → Tasks/Procedures → Curated tables → Materialized Views → Analytics

2. **Why did we use 3 separate warehouses instead of 1?**
   - Expected: Cost optimization and workload isolation - different workloads have different compute needs

3. **What would happen if we didn't use streams?**
   - Expected: Would need to process entire raw table each time, inefficient and expensive

### Performance
4. **How does clustering improve query performance?**
   - Expected: Organizes data in micro-partitions to minimize scanning when filtering on clustered columns

5. **When should you use materialized views vs. regular views?**
   - Expected: Materialized views for frequently-queried aggregations, regular views for simple transformations or security

### Security
6. **What's the difference between masking policies and row access policies?**
   - Expected: Masking hides column values, row access filters which rows users can see

7. **Why is role hierarchy important?**
   - Expected: Simplifies privilege management, enables inheritance, follows principle of least privilege

### Automation
8. **What triggers the process_orders_task to run?**
   - Expected: Schedule (every 5 minutes) AND stream has data (SYSTEM$STREAM_HAS_DATA)

9. **What happens if the task fails?**
   - Expected: Error logged in task history, task stops, needs investigation and manual resume

### Monitoring
10. **How would you identify a performance problem in production?**
    - Expected: Check query_performance view for slow queries, warehouse_usage for high costs, clustering_information for optimization opportunities

---

## Real-World Scenarios

Consider how you would handle these production scenarios:

### Scenario 1: Data Quality Issue
**Problem:** You discover 100 orders with negative amounts in the orders table.

**Your approach:**
1. Query to identify bad data: `SELECT * FROM orders WHERE amount < 0`
2. Use Time Travel to check when it was inserted
3. Add validation in process_orders() procedure to reject negative amounts
4. Create data quality check in monitoring
5. Fix existing data or delete if invalid

### Scenario 2: Performance Degradation
**Problem:** Dashboard queries that used to take 2 seconds now take 30 seconds.

**Your approach:**
1. Check query_performance view for slow queries
2. Check SYSTEM$CLUSTERING_INFORMATION for clustering depth
3. Consider re-clustering if needed
4. Check if materialized views need manual refresh
5. Consider warehouse size increase if consistent load increase

### Scenario 3: Security Breach
**Problem:** A regional manager reports seeing data from other regions.

**Your approach:**
1. Verify row access policy is applied: `SHOW ROW ACCESS POLICIES`
2. Check user's current role: `SELECT CURRENT_ROLE()`
3. Verify policy logic is correct
4. Check if user has multiple roles that bypass policy
5. Review access history for audit trail

### Scenario 4: Cost Spike
**Problem:** Snowflake costs doubled this month.

**Your approach:**
1. Check warehouse_usage view for credit consumption
2. Identify which warehouse/queries consuming most
3. Check for runaway queries or tasks
4. Review warehouse auto-suspend settings
5. Consider warehouse sizing adjustments
6. Implement resource monitors for alerts

---

## Key Takeaways

After completing this project, you should understand:

1. **End-to-End Data Engineering**: How to build complete pipelines from ingestion to analytics
2. **Automation**: Using Snowpipe, Streams, and Tasks for automated data processing
3. **Performance**: Clustering, materialized views, and warehouse sizing for optimization
4. **Security**: RBAC, masking, row-level security for data protection
5. **Monitoring**: Tracking performance, costs, and data quality
6. **Production Readiness**: Error handling, documentation, and operational procedures

---

## Exam Preparation Tips

This project integrates concepts that frequently appear on the SnowPro Advanced: Data Engineer exam:

**High-Frequency Topics:**
- Streams and CDC patterns (15-20% of exam)
- Task orchestration and scheduling (10-15% of exam)
- Performance optimization (clustering, materialized views) (15-20% of exam)
- Security policies (masking, row access) (10-15% of exam)
- Monitoring and troubleshooting (10% of exam)

**Exam Question Types You'll See:**
- Scenario-based: "Given this requirement, which approach is best?"
- Troubleshooting: "A task is failing, what should you check?"
- Performance: "How would you optimize this query?"
- Security: "Which policy type should you use for this requirement?"

**Practice Exam Strategy:**
- Tomorrow (Day 26) you'll take your first full practice exam
- Use this project as a reference for complex scenarios
- Focus on understanding WHY, not just WHAT
- Time management: 1.75 minutes per question

---

## Additional Practice

If you have extra time, try these enhancements:

### Enhancement 1: Add More Regions
- Create regional_manager_east and regional_manager_west roles
- Test row access policy with all 4 regions

### Enhancement 2: Implement SCD Type 2
- Modify customers table to track historical changes
- Add effective_date, end_date, is_current columns
- Update process_orders() to maintain history

### Enhancement 3: Add Data Quality Framework
- Create data_quality_rules table
- Build generic data quality check procedure
- Schedule automated quality checks

### Enhancement 4: Cost Optimization
- Create resource monitors with credit limits
- Implement query result caching strategy
- Add warehouse auto-scaling

### Enhancement 5: Advanced Monitoring
- Create alerting mechanism for failures
- Build executive dashboard with key metrics
- Implement anomaly detection for data volumes

---

## Tomorrow: Day 26 - Practice Exam 1

Tomorrow you'll take your first full-length practice exam:
- **65 questions** (same as real exam)
- **115 minutes** (1 hour 55 minutes)
- **70% passing score** (46/65 correct)
- **All topics** from Weeks 1-4

**Preparation:**
- Review your notes from Days 1-25
- Get good sleep tonight
- Set aside uninterrupted time
- Treat it like the real exam

**Good luck! You've built an impressive project and are well-prepared!** 🚀

