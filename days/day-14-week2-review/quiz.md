# Day 14 Quiz: Week 2 Review - Performance Optimization

## Instructions
Choose the best answer for each question. This comprehensive quiz covers all Week 2 topics. Answers are provided at the end.

---

## Clustering & Micro-Partitions (Questions 1-10)

### 1. What is the typical size range of a Snowflake micro-partition?

A) 5-50 MB compressed  
B) 50-500 MB compressed  
C) 500-5000 MB compressed  
D) 1-10 GB compressed  

**Your answer:**

---

### 2. When should you add a clustering key to a table?

A) For all tables regardless of size  
B) For tables > 1 TB with predictable query patterns  
C) Only for tables with low cardinality columns  
D) Never, Snowflake handles it automatically  

**Your answer:**

---

### 3. What is the ideal clustering depth?

A) 0-1  
B) 5-10  
C) 10-20  
D) > 20  

**Your answer:**

---

### 4. How many clustering keys should you typically use?

A) 1 only  
B) 1-2  
C) 3-4 maximum  
D) As many as needed  

**Your answer:**

---

### 5. What does partition pruning mean?

A) Deleting old partitions  
B) Skipping micro-partitions that don't contain relevant data  
C) Compressing partitions  
D) Merging small partitions  

**Your answer:**

---

### 6. Which column type is BEST for clustering?

A) Boolean (TRUE/FALSE)  
B) Status codes (5-10 values)  
C) Dates or timestamps  
D) Completely unique IDs  

**Your answer:**

---

### 7. What is automatic clustering?

A) Free feature in all editions  
B) Enterprise Edition feature that maintains clustering  
C) Clustering that happens during data load  
D) Manual reclustering command  

**Your answer:**

---

### 8. What percentage of partition pruning is considered good?

A) > 50%  
B) > 70%  
C) > 90%  
D) 100% only  

**Your answer:**

---

### 9. Which statement about clustering is TRUE?

A) Clustering is free and has no maintenance cost  
B) Clustering maintenance consumes credits  
C) Clustering only works on Enterprise Edition  
D) You must manually recluster tables  

**Your answer:**

---

### 10. When should you NOT use clustering?

A) Table < 100 GB  
B) Queries filter on many different columns  
C) Very high cardinality columns (unique IDs)  
D) All of the above  

**Your answer:**

---

## Search Optimization Service (Questions 11-18)

### 11. What type of queries benefit MOST from search optimization?

A) Range queries (WHERE date BETWEEN...)  
B) Point lookups (WHERE id = 123)  
C) Full table scans  
D) Aggregation queries  

**Your answer:**

---

### 12. How much does search optimization typically cost?

A) Free  
B) ~1% of table size  
C) ~10% of table size  
D) ~50% of table size  

**Your answer:**

---

### 13. Which predicate type works with search optimization?

A) Equality (=)  
B) Range (BETWEEN)  
C) NOT EQUAL (<>)  
D) All of the above  

**Your answer:**

---

### 14. Can search optimization and clustering be used together?

A) No, they conflict  
B) Yes, they complement each other  
C) Only on Enterprise Edition  
D) Only for small tables  

**Your answer:**

---

### 15. What column types support search optimization?

A) VARCHAR only  
B) VARCHAR and NUMBER  
C) VARCHAR, NUMBER, and VARIANT  
D) All data types  

**Your answer:**

---

### 16. How do you enable search optimization?

A) It's automatic  
B) ALTER TABLE table_name ADD SEARCH OPTIMIZATION  
C) CREATE SEARCH INDEX ON table_name  
D) SET SEARCH_OPTIMIZATION = TRUE  

**Your answer:**

---

### 17. When should you use search optimization instead of clustering?

A) For range queries  
B) For point lookups on many different columns  
C) For small tables  
D) Never, always use clustering  

**Your answer:**

---

### 18. How do you monitor search optimization effectiveness?

A) SHOW SEARCH OPTIMIZATION  
B) SEARCH_OPTIMIZATION_HISTORY view  
C) Query Profile  
D) Both B and C  

**Your answer:**

---

## Materialized Views (Questions 19-26)

### 19. What is a materialized view?

A) A virtual view with no storage  
B) A pre-computed query result stored as a table  
C) A temporary table  
D) A cached query result  

**Your answer:**

---

### 20. How are materialized views maintained?

A) Manually by running REFRESH command  
B) Automatically by Snowflake  
C) Never updated  
D) Only during data load  

**Your answer:**

---

### 21. What type of refresh do materialized views use when possible?

A) Full refresh only  
B) Incremental refresh  
C) No refresh  
D) Manual refresh  

**Your answer:**

---

### 22. Which query type is NOT supported in materialized views?

A) Aggregations (SUM, COUNT)  
B) JOINs  
C) Window functions  
D) GROUP BY  

**Your answer:**

---

### 23. What is the main cost of materialized views?

A) Query execution  
B) Maintenance and storage  
C) No cost, they're free  
D) Only storage  

**Your answer:**

---

### 24. When should you use a materialized view?

A) For all queries  
B) For expensive aggregations queried frequently  
C) For simple SELECT * queries  
D) For one-time queries  

**Your answer:**

---

### 25. What's the difference between materialized views and dynamic tables?

A) No difference  
B) Dynamic tables offer more flexibility and TARGET_LAG control  
C) Materialized views are faster  
D) Dynamic tables don't support aggregations  

**Your answer:**

---

### 26. How do you create a materialized view?

A) CREATE VIEW ... MATERIALIZED  
B) CREATE MATERIALIZED VIEW ... AS SELECT  
C) ALTER VIEW ... SET MATERIALIZED  
D) CREATE TABLE ... AS SELECT  

**Your answer:**

---

## Query Performance Tuning (Questions 27-34)

### 27. What is the primary tool for diagnosing query performance?

A) Query History  
B) Query Profile  
C) EXPLAIN command  
D) Warehouse metrics  

**Your answer:**

---

### 28. What does data spilling indicate?

A) Query is too complex  
B) Warehouse is undersized for the operation  
C) Table needs clustering  
D) Cache is full  

**Your answer:**

---

### 29. What is the recommended JOIN order?

A) Large tables first  
B) Small tables first  
C) Doesn't matter  
D) Alphabetical order  

**Your answer:**

---

### 30. What is predicate pushdown?

A) Moving WHERE clauses to subqueries  
B) Applying filters as early as possible in execution  
C) Pushing data to remote storage  
D) Compressing predicates  

**Your answer:**

---

### 31. Which is faster for filtering?

A) WHERE clause  
B) HAVING clause  
C) Both are the same  
D) Depends on the query  

**Your answer:**

---

### 32. What should you avoid in SELECT statements?

A) WHERE clauses  
B) SELECT *  
C) JOINs  
D) Aggregations  

**Your answer:**

---

### 33. What indicates poor partition pruning?

A) < 10% partitions scanned  
B) 50% partitions scanned  
C) > 90% partitions scanned  
D) 100% partitions scanned  

**Your answer:**

---

### 34. How do you fix data spilling?

A) Add clustering key  
B) Increase warehouse size  
C) Reduce data volume  
D) Use caching  

**Your answer:**

---

## Warehouse Sizing & Scaling (Questions 35-42)

### 35. How many credits per hour does a Medium warehouse consume?

A) 1  
B) 2  
C) 4  
D) 8  

**Your answer:**

---

### 36. When should you scale UP?

A) High concurrency  
B) Slow queries processing large data  
C) To save costs  
D) For simple queries  

**Your answer:**

---

### 37. When should you scale OUT?

A) Slow queries  
B) High concurrency and queuing  
C) Large data volumes  
D) To reduce costs  

**Your answer:**

---

### 38. What does the STANDARD scaling policy do?

A) Waits 6 minutes before adding clusters  
B) Starts clusters quickly to minimize queuing  
C) Never adds clusters  
D) Always runs maximum clusters  

**Your answer:**

---

### 39. What is the recommended AUTO_SUSPEND for development?

A) NULL (never suspend)  
B) 60-120 seconds  
C) 600 seconds  
D) 3600 seconds  

**Your answer:**

---

### 40. What is the maximum number of clusters in a multi-cluster warehouse?

A) 3  
B) 5  
C) 10  
D) Unlimited  

**Your answer:**

---

### 41. What is the minimum billing increment?

A) 1 second  
B) 10 seconds  
C) 60 seconds  
D) 5 minutes  

**Your answer:**

---

### 42. What do Resource Monitors do?

A) Improve performance  
B) Set credit limits and trigger actions  
C) Automatically resize warehouses  
D) Cache queries  

**Your answer:**

---

## Result Caching (Questions 43-50)

### 43. How long does the result cache persist?

A) 1 hour  
B) 12 hours  
C) 24 hours  
D) 7 days  

**Your answer:**

---

### 44. What is the cost of a result cache hit?

A) Same as original  
B) 50% of original  
C) 10% of original  
D) FREE (0 credits)  

**Your answer:**

---

### 45. What invalidates the result cache?

A) SELECT queries  
B) INSERT, UPDATE, DELETE operations  
C) Different user running query  
D) Different warehouse  

**Your answer:**

---

### 46. What is required for a result cache HIT?

A) Similar query  
B) Exact query text match  
C) Same table  
D) Same warehouse  

**Your answer:**

---

### 47. Which query uses metadata cache?

A) SELECT * FROM table  
B) SELECT COUNT(*) FROM table  
C) SELECT col1, col2 FROM table  
D) SELECT AVG(amount) FROM table  

**Your answer:**

---

### 48. What happens to warehouse cache when suspended?

A) Persists indefinitely  
B) Cleared  
C) Moves to result cache  
D) Moves to metadata cache  

**Your answer:**

---

### 49. What prevents result caching?

A) Using CURRENT_DATE() in WHERE clause  
B) Using deterministic functions  
C) Large warehouses  
D) Multiple tables  

**Your answer:**

---

### 50. Where is the result cache stored?

A) Each warehouse  
B) Cloud services layer (shared)  
C) Remote storage  
D) User's session  

**Your answer:**

---

## Answer Key

### Clustering & Micro-Partitions (1-10)
1. **B** - 50-500 MB compressed
2. **B** - For tables > 1 TB with predictable query patterns
3. **A** - 0-1
4. **C** - 3-4 maximum
5. **B** - Skipping micro-partitions that don't contain relevant data
6. **C** - Dates or timestamps
7. **B** - Enterprise Edition feature that maintains clustering
8. **C** - > 90%
9. **B** - Clustering maintenance consumes credits
10. **D** - All of the above

### Search Optimization Service (11-18)
11. **B** - Point lookups (WHERE id = 123)
12. **C** - ~10% of table size
13. **A** - Equality (=)
14. **B** - Yes, they complement each other
15. **C** - VARCHAR, NUMBER, and VARIANT
16. **B** - ALTER TABLE table_name ADD SEARCH OPTIMIZATION
17. **B** - For point lookups on many different columns
18. **D** - Both B and C

### Materialized Views (19-26)
19. **B** - A pre-computed query result stored as a table
20. **B** - Automatically by Snowflake
21. **B** - Incremental refresh
22. **C** - Window functions
23. **B** - Maintenance and storage
24. **B** - For expensive aggregations queried frequently
25. **B** - Dynamic tables offer more flexibility and TARGET_LAG control
26. **B** - CREATE MATERIALIZED VIEW ... AS SELECT

### Query Performance Tuning (27-34)
27. **B** - Query Profile
28. **B** - Warehouse is undersized for the operation
29. **B** - Small tables first
30. **B** - Applying filters as early as possible in execution
31. **A** - WHERE clause
32. **B** - SELECT *
33. **C** - > 90% partitions scanned
34. **B** - Increase warehouse size

### Warehouse Sizing & Scaling (35-42)
35. **C** - 4
36. **B** - Slow queries processing large data
37. **B** - High concurrency and queuing
38. **B** - Starts clusters quickly to minimize queuing
39. **B** - 60-120 seconds
40. **C** - 10
41. **C** - 60 seconds
42. **B** - Set credit limits and trigger actions

### Result Caching (43-50)
43. **C** - 24 hours
44. **D** - FREE (0 credits)
45. **B** - INSERT, UPDATE, DELETE operations
46. **B** - Exact query text match
47. **B** - SELECT COUNT(*) FROM table
48. **B** - Cleared
49. **A** - Using CURRENT_DATE() in WHERE clause
50. **B** - Cloud services layer (shared)

---

## Score Yourself

- 45-50/50: Excellent! You've mastered Week 2 - Ready for Week 3
- 40-44/50: Good! Review the topics you missed
- 35-39/50: Fair - Review Week 2 materials before continuing
- 30-34/50: Review all Week 2 days
- < 30/50: Spend extra time on Week 2 before moving forward

---

## Topic Breakdown

**By Topic:**
- Clustering: ___/10
- Search Optimization: ___/8
- Materialized Views: ___/8
- Query Tuning: ___/8
- Warehouses: ___/8
- Caching: ___/8

**Identify weak areas and review those specific days.**

---

## Key Concepts Summary

### Clustering & Micro-Partitions
✅ Micro-partitions: 50-500 MB compressed  
✅ Clustering keys: 3-4 max, high cardinality  
✅ Clustering depth: 0-1 is ideal  
✅ Partition pruning: > 90% is good  
✅ Automatic clustering: Enterprise Edition  
✅ Maintenance costs credits  

### Search Optimization
✅ Best for: Point lookups, equality predicates  
✅ Cost: ~10% of table size  
✅ Supports: VARCHAR, NUMBER, VARIANT  
✅ Complements clustering  
✅ Enable: ALTER TABLE ADD SEARCH OPTIMIZATION  

### Materialized Views
✅ Pre-computed results  
✅ Automatic maintenance  
✅ Incremental refresh when possible  
✅ No window functions  
✅ Cost: Maintenance + storage  
✅ Alternative: Dynamic tables  

### Query Performance
✅ Query Profile: Primary diagnostic tool  
✅ Data spilling: Increase warehouse size  
✅ JOIN order: Small to large  
✅ Predicate pushdown: Filter early  
✅ Avoid: SELECT *  
✅ Partition pruning: > 90% ideal  

### Warehouses
✅ Sizes: X-Small (1) to 4X-Large (128)  
✅ Scale up: Speed (complex queries)  
✅ Scale out: Concurrency (many users)  
✅ Standard: Minimize queuing  
✅ Economy: Minimize cost  
✅ Billing: 60-second minimum  

### Caching
✅ Result cache: 24 hours, FREE  
✅ Metadata cache: COUNT(*), MIN, MAX  
✅ Warehouse cache: Cleared on suspend  
✅ Cache hit: Exact query match  
✅ Invalidation: DML operations  
✅ Non-deterministic functions prevent caching  

---

## Exam Preparation Tips

**High-Priority Topics:**
1. Clustering key selection criteria
2. When to use search optimization vs. clustering
3. Materialized view limitations
4. Query Profile interpretation
5. Scale up vs. scale out decisions
6. Result cache requirements
7. Warehouse sizing calculations
8. Cost optimization strategies

**Common Exam Scenarios:**
- Given a query pattern, choose optimization technique
- Calculate warehouse costs
- Identify cache hit/miss scenarios
- Determine clustering key candidates
- Troubleshoot slow queries
- Choose between MV and dynamic tables
- Optimize for cost vs. performance

**Practice Questions:**
1. Table is 2 TB, queries filter on date - Add clustering?
2. 1000 point lookups per second - Use search optimization?
3. Expensive aggregation run 100x/day - Create MV?
4. Query scans 95% of partitions - What's wrong?
5. 50 concurrent users, queries queuing - Scale up or out?
6. Same query runs 10x/day - How to optimize?
7. Data spilling in Query Profile - What to do?
8. Monthly cost $10K, how to reduce by 30%?

---

## Next Steps

### If you scored 45-50:
✅ Excellent work! You're ready for Week 3  
✅ Move to Day 15: Role-Based Access Control  
✅ Continue building on your strong foundation  

### If you scored 40-44:
⚠️ Good understanding, minor gaps  
⚠️ Review the specific topics you missed  
⚠️ Retry those day's exercises  
⚠️ Then proceed to Week 3  

### If you scored 35-39:
⚠️ Fair understanding, needs review  
⚠️ Re-read README.md for weak topics  
⚠️ Complete exercises again  
⚠️ Retake quiz before Week 3  

### If you scored < 35:
❌ Significant gaps in understanding  
❌ Review all Week 2 materials  
❌ Complete all exercises thoroughly  
❌ Spend extra day on Week 2  
❌ Retake quiz until scoring 40+  

---

## Week 2 Accomplishments

**Congratulations on completing Week 2!**

You've learned:
- ✅ How Snowflake organizes data (micro-partitions)
- ✅ When and how to add clustering keys
- ✅ Point lookup optimization with search optimization
- ✅ Pre-computing results with materialized views
- ✅ Diagnosing and fixing slow queries
- ✅ Sizing and scaling warehouses appropriately
- ✅ Maximizing cache effectiveness
- ✅ Balancing performance vs. cost

**Real-world impact:**
- 10-100x faster queries
- 30-50% cost reduction
- 50-80% cache hit rates
- Improved user satisfaction

**You're now equipped to:**
- Optimize any Snowflake workload
- Reduce costs significantly
- Improve query performance dramatically
- Make data-driven optimization decisions

---

## Week 3 Preview

**Coming up: Data Governance & Security**

- Day 15: Role-Based Access Control (RBAC)
- Day 16: Data Masking & Privacy
- Day 17: Row Access Policies
- Day 18: Data Sharing & Secure Views
- Day 19: Time Travel & Fail-Safe
- Day 20: Cloning & Zero-Copy Cloning
- Day 21: Week 3 Review & Governance Lab

**Focus:** Securing and governing data in Snowflake

**Skills:** Access control, data privacy, compliance, data protection

---

## Final Checklist

Before moving to Week 3, ensure you can:

- [ ] Explain micro-partitioning and clustering
- [ ] Decide when to add clustering keys
- [ ] Enable and monitor search optimization
- [ ] Create and maintain materialized views
- [ ] Analyze Query Profile for bottlenecks
- [ ] Optimize partition pruning (> 90%)
- [ ] Prevent and fix data spilling
- [ ] Size warehouses appropriately
- [ ] Choose scale up vs. scale out
- [ ] Maximize cache hit rates (> 50%)
- [ ] Calculate cost vs. benefit
- [ ] Build monitoring dashboards
- [ ] Troubleshoot performance issues
- [ ] Apply all Week 2 techniques together

**Ready for Week 3? Let's go! 🚀**
