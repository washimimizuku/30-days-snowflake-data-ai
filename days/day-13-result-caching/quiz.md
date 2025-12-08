# Day 13 Quiz: Result Caching & Persisted Results

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. How long does Snowflake's result cache persist?

A) 1 hour  
B) 12 hours  
C) 24 hours  
D) 7 days  

**Your answer:**

---

### 2. What is the cost of executing a query that hits the result cache?

A) Same as original query  
B) 50% of original query  
C) 10% of original query  
D) FREE (0 credits)  

**Your answer:**

---

### 3. Which of the following will cause a result cache MISS?

A) Exact same query within 24 hours  
B) Table was modified after cache creation  
C) Query run by same user  
D) Query run on same warehouse  

**Your answer:**

---

### 4. What happens to warehouse cache when a warehouse is suspended?

A) Cache persists indefinitely  
B) Cache is cleared  
C) Cache moves to result cache  
D) Cache moves to metadata cache  

**Your answer:**

---

### 5. Which query can be answered using only metadata cache?

A) SELECT * FROM orders;  
B) SELECT COUNT(*) FROM orders;  
C) SELECT order_id FROM orders WHERE status = 'SHIPPED';  
D) SELECT AVG(amount) FROM orders;  

**Your answer:**

---

### 6. What prevents a query from being cached in the result cache?

A) Using CURRENT_TIMESTAMP() in WHERE clause  
B) Using deterministic functions  
C) Running on a large warehouse  
D) Querying multiple tables  

**Your answer:**

---

### 7. Which two queries will result in a cache HIT?

A) `SELECT * FROM customers;` and `SELECT * from customers;`  
B) `SELECT * FROM customers;` and `SELECT * FROM customers;`  
C) `SELECT * FROM customers;` and `SELECT  *  FROM  customers;`  
D) `SELECT * FROM customers;` and `SELECT * FROM CUSTOMERS;`  

**Your answer:**

---

### 8. Where is the result cache stored?

A) In each warehouse's local storage  
B) In the cloud services layer (shared)  
C) In remote storage (S3/Azure/GCS)  
D) In the user's browser  

**Your answer:**

---

### 9. What is the benefit of warehouse cache?

A) Persists for 24 hours  
B) Helps different queries on same table  
C) Works across all warehouses  
D) Answers COUNT(*) queries instantly  

**Your answer:**

---

### 10. Which operation invalidates the result cache for a table?

A) SELECT query on the table  
B) GRANT permissions on the table  
C) INSERT into the table  
D) DESCRIBE the table  

**Your answer:**

---

## Answer Key

1. **C** - 24 hours
2. **D** - FREE (0 credits)
3. **B** - Table was modified after cache creation
4. **B** - Cache is cleared
5. **B** - SELECT COUNT(*) FROM orders
6. **A** - Using CURRENT_TIMESTAMP() in WHERE clause
7. **B** - Exact match required (same case, spacing, everything)
8. **B** - In the cloud services layer (shared)
9. **B** - Helps different queries on same table
10. **C** - INSERT into the table

---

## Score Yourself

- 9-10/10: Excellent! You understand Snowflake caching thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Three-Layer Caching**: Result cache, Metadata cache, Warehouse cache  
✅ **Result Cache**: 24-hour TTL, FREE, exact query match required  
✅ **Metadata Cache**: Instant COUNT(*), MIN, MAX queries  
✅ **Warehouse Cache**: Persists while running, cleared on suspend  
✅ **Cache Hit Requirements**: Exact query text, no table changes, within 24 hours  
✅ **Cache Invalidation**: DML operations (INSERT, UPDATE, DELETE, TRUNCATE)  
✅ **Non-Deterministic Functions**: CURRENT_DATE(), CURRENT_TIMESTAMP() prevent caching  
✅ **Consistent Formatting**: Required for result cache hits  
✅ **Cost Savings**: Result cache = 0 credits = FREE execution  
✅ **Monitoring**: Track cache hit rates for optimization  

## Exam Tips

**Common exam question patterns:**
- Result cache duration and cost
- Cache hit vs. cache miss scenarios
- Metadata-only query identification
- Warehouse cache behavior
- Cache invalidation triggers
- Non-deterministic function impact
- Query formatting requirements
- Cache storage locations
- Cost savings from caching
- Monitoring cache effectiveness

**Remember for the exam:**
- Result cache: 24 hours, FREE, exact match
- Metadata cache: COUNT(*), MIN, MAX without WHERE
- Warehouse cache: Cleared on suspend
- DML invalidates result cache
- CURRENT_DATE() prevents caching
- Exact query text match required (case, spacing, everything)
- Result cache in cloud services layer (shared)
- Warehouse cache in local SSD (per warehouse)
- Cache hit = 0 credits
- Monitor with QUERY_HISTORY view

## Next Steps

- If you scored 8-10: Move to Day 14 (Week 2 Review)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Why would a query not hit the result cache?
2. How do you maximize result cache hits?
3. When is metadata cache used?
4. What clears warehouse cache?
5. How do you monitor cache effectiveness?
6. What's the cost of a cached query?
7. How long does result cache persist?
8. What invalidates result cache?

## Real-World Applications

**Dashboard Queries:**
- First load: Computes (costs credits)
- Refreshes within 24 hours: Cached (FREE)
- 288 refreshes/day (5 min intervals): 287 FREE!
- Potential savings: 99.7% of compute costs

**Report Generation:**
- Monthly report runs multiple times
- First run: Computes
- Subsequent runs: Cached
- Users can re-run reports instantly

**Data Exploration:**
- Analyst queries large table
- First query: Loads to warehouse cache
- Similar queries: Use warehouse cache
- 50-80% faster execution

**Metadata Queries:**
- COUNT(*) without WHERE: Instant
- MIN/MAX on clustered columns: Instant
- No data scan required
- Always FREE

**Cost Optimization Strategies:**
1. **Consistent Query Formatting**
   - Use query templates
   - Standardize SQL style
   - Implement query builders
   - Use views for common queries

2. **Avoid Non-Deterministic Functions**
   - Replace CURRENT_DATE() with specific dates
   - Use deterministic values in WHERE clauses
   - Parameterize at application level
   - Cache-friendly query design

3. **Minimize Table Changes**
   - Batch DML operations
   - Schedule updates during off-hours
   - Use separate staging tables
   - Minimize cache invalidation

4. **Keep Warehouses Running**
   - Longer auto-suspend for cached workloads
   - Balance cost vs. cache benefits
   - Monitor warehouse cache usage
   - Optimize suspend timing

5. **Monitor Cache Effectiveness**
   - Track result cache hit rates
   - Identify metadata-only queries
   - Monitor warehouse cache usage
   - Calculate cost savings

**Cache Hit Rate Targets:**
- Development: 20-40% (exploratory queries)
- BI Dashboards: 60-80% (repeated queries)
- Reports: 70-90% (scheduled reports)
- APIs: 80-95% (consistent queries)

**Monitoring Checklist:**
- [ ] Result cache hit rate
- [ ] Metadata-only query count
- [ ] Warehouse cache percentage
- [ ] Cache invalidation frequency
- [ ] Cost savings from caching
- [ ] Query formatting consistency
- [ ] Non-deterministic function usage
- [ ] Table update patterns

**Common Mistakes to Avoid:**
1. ❌ Using CURRENT_DATE() in cached queries
2. ❌ Inconsistent query formatting
3. ❌ Frequent table updates during business hours
4. ❌ Suspending warehouses too aggressively
5. ❌ Not monitoring cache hit rates
6. ❌ Ignoring metadata cache opportunities
7. ❌ Different query text for same logic
8. ❌ Not using views for common queries

**Best Practices:**
1. ✅ Use deterministic values in queries
2. ✅ Standardize query formatting
3. ✅ Batch table updates
4. ✅ Keep warehouses running for cached workloads
5. ✅ Monitor cache effectiveness
6. ✅ Use COUNT(*) without WHERE when possible
7. ✅ Create views for common queries
8. ✅ Track cost savings from caching

**Cache Optimization Workflow:**
1. Identify frequently-run queries
2. Standardize query formatting
3. Remove non-deterministic functions
4. Create views for common patterns
5. Monitor cache hit rates
6. Adjust warehouse auto-suspend
7. Minimize table update frequency
8. Calculate cost savings
9. Iterate and optimize

**Expected Results:**
- Result cache hit rate: 50-80%
- Cost savings: 30-60% of compute costs
- Query performance: 10-100x faster for cached queries
- User experience: Instant dashboard refreshes
- Warehouse efficiency: Higher query throughput
