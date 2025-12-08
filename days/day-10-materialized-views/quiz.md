# Day 10 Quiz: Materialized Views

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the main difference between a regular view and a materialized view?

A) Regular views are faster  
B) Materialized views store pre-computed results physically  
C) Regular views can be updated with DML  
D) Materialized views don't require storage  

**Your answer:**

---

### 2. When should you use a materialized view?

A) When base tables change constantly  
B) When queries are expensive and run frequently  
C) When you need real-time results  
D) When the query is already fast  

**Your answer:**

---

### 3. Which query pattern is NOT supported in materialized views?

A) Simple aggregations with GROUP BY  
B) Joins with aggregations  
C) Window functions (ROW_NUMBER, RANK)  
D) Date-based aggregations  

**Your answer:**

---

### 4. How are materialized views maintained in Snowflake?

A) Manually by running REFRESH command  
B) Automatically by Snowflake  
C) By scheduled tasks  
D) They are never updated  

**Your answer:**

---

### 5. What does the "behind_by" metric indicate?

A) The size of the materialized view  
B) How stale the materialized view is  
C) The number of refreshes  
D) The maintenance cost  

**Your answer:**

---

### 6. Can you perform INSERT, UPDATE, or DELETE on a materialized view?

A) Yes, all DML operations are supported  
B) Only INSERT is supported  
C) Only SELECT is supported  
D) Only UPDATE is supported  

**Your answer:**

---

### 7. What is the main advantage of incremental maintenance over full refresh?

A) It's more accurate  
B) It's more efficient and lower cost  
C) It's faster to set up  
D) It supports more query patterns  

**Your answer:**

---

### 8. When comparing materialized views to dynamic tables, which statement is TRUE?

A) Materialized views offer more refresh control  
B) Dynamic tables support more query patterns  
C) Materialized views are always faster  
D) Dynamic tables cannot be clustered  

**Your answer:**

---

### 9. How do you manually refresh a materialized view?

A) REFRESH MATERIALIZED VIEW view_name  
B) ALTER MATERIALIZED VIEW view_name REFRESH  
C) UPDATE MATERIALIZED VIEW view_name  
D) REBUILD MATERIALIZED VIEW view_name  

**Your answer:**

---

### 10. Can you add clustering keys to materialized views?

A) No, clustering is not supported  
B) Yes, using ALTER MATERIALIZED VIEW ... CLUSTER BY  
C) Only during creation  
D) Only for views smaller than 1 TB  

**Your answer:**

---

## Answer Key

1. **B** - Materialized views store pre-computed results physically
2. **B** - When queries are expensive and run frequently
3. **C** - Window functions (ROW_NUMBER, RANK) are not supported
4. **B** - Automatically by Snowflake
5. **B** - How stale the materialized view is
6. **C** - Only SELECT is supported (no DML operations)
7. **B** - It's more efficient and lower cost
8. **B** - Dynamic tables support more query patterns
9. **B** - ALTER MATERIALIZED VIEW view_name REFRESH
10. **B** - Yes, using ALTER MATERIALIZED VIEW ... CLUSTER BY

---

## Score Yourself

- 9-10/10: Excellent! You understand materialized views thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Physical Storage**: Materialized views store pre-computed results  
✅ **Automatic Maintenance**: Snowflake maintains them automatically  
✅ **Best For**: Expensive aggregations run frequently  
✅ **Query Limitations**: No window functions, non-deterministic functions  
✅ **Read-Only**: Only SELECT operations (no INSERT/UPDATE/DELETE)  
✅ **Incremental Maintenance**: More efficient than full refresh  
✅ **Behind_by Metric**: Indicates staleness  
✅ **Clustering**: Can be added for large result sets  
✅ **vs. Dynamic Tables**: Less flexible but automatic optimization  
✅ **Cost**: Storage + maintenance credits  

## Exam Tips

**Common exam question patterns:**
- When to use materialized views vs. regular views
- Supported vs. unsupported query patterns
- Automatic maintenance behavior
- Materialized views vs. dynamic tables comparison
- Cost implications (storage + maintenance)
- Clustering on materialized views
- Refresh and staleness concepts

**Remember for the exam:**
- Materialized views: Pre-computed, automatic maintenance
- Regular views: Virtual, computed on query
- Supported: Aggregations, joins, GROUP BY
- NOT supported: Window functions, non-deterministic functions, FLATTEN
- Read-only: No DML operations
- Automatic maintenance: Incremental when possible
- Behind_by: Staleness indicator
- Can be clustered: For large result sets
- Dynamic tables: More flexible, TARGET_LAG control
- Suspend/Resume: Control maintenance during bulk loads

## Next Steps

- If you scored 8-10: Move to Day 11 (Query Performance Tuning)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. When would you choose a materialized view over a dynamic table?
2. How do you determine if a materialized view is cost-effective?
3. What happens when base table schema changes?
4. How do you monitor materialized view maintenance costs?
5. When should you suspend materialized view maintenance?
6. How does clustering improve materialized view performance?
7. What's the impact of frequent base table updates?
8. How do you create a hierarchy of aggregations?

## Real-World Applications

**Reporting Dashboards:**
- Pre-compute daily/monthly metrics
- Fast dashboard load times
- Automatic updates
- Common in BI tools

**Analytics Queries:**
- Customer lifetime value
- Product performance metrics
- Regional sales summaries
- Time-series aggregations

**Data Marts:**
- Pre-aggregated fact tables
- Dimension summaries
- Star schema optimizations
- OLAP cube alternatives

**Performance Optimization:**
- Replace expensive queries
- Reduce compute costs
- Improve user experience
- Enable self-service analytics

**Cost Considerations:**
- Storage cost for materialized data
- Maintenance cost for updates
- Balance against query savings
- Monitor cost vs. benefit
- Suspend during bulk loads

