# Day 11 Quiz: Query Performance Tuning

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the primary tool for diagnosing query performance issues in Snowflake?

A) EXPLAIN command  
B) Query Profile  
C) SHOW QUERIES  
D) Performance Monitor  

**Your answer:**

---

### 2. Which query enables better partition pruning?

A) WHERE YEAR(order_date) = 2024  
B) WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'  
C) WHERE DATE_TRUNC('year', order_date) = '2024-01-01'  
D) WHERE EXTRACT(YEAR FROM order_date) = 2024  

**Your answer:**

---

### 3. What does "data spilling" indicate?

A) Data is being cached  
B) Operations exceed available memory and write to disk  
C) Data is being compressed  
D) Partitions are being pruned  

**Your answer:**

---

### 4. Which is the most efficient way to count rows by category?

A) Multiple SELECT COUNT(*) subqueries  
B) Single query with COUNT(CASE WHEN ...) for each category  
C) Separate queries with UNION ALL  
D) Using window functions  

**Your answer:**

---

### 5. When should you filter data in a JOIN query?

A) After the JOIN in the WHERE clause  
B) Before the JOIN using CTEs or subqueries  
C) It doesn't matter  
D) Never filter in JOIN queries  

**Your answer:**

---

### 6. What is the best alternative to a correlated subquery?

A) Use more correlated subqueries  
B) Use JOIN with aggregation  
C) Use UNION ALL  
D) Use nested loops  

**Your answer:**

---

### 7. How long are query results cached in Snowflake?

A) 1 hour  
B) 12 hours  
C) 24 hours  
D) 7 days  

**Your answer:**

---

### 8. Which is better for removing duplicates?

A) SELECT DISTINCT  
B) GROUP BY (often faster)  
C) ROW_NUMBER() with QUALIFY  
D) Both B and C depending on use case  

**Your answer:**

---

### 9. What causes a query cache miss?

A) Exact same query within 24 hours  
B) Different whitespace in query text  
C) Same role and context  
D) No table changes  

**Your answer:**

---

### 10. How do you fix remote disk spilling?

A) Decrease warehouse size  
B) Increase warehouse size or reduce data volume  
C) Add more clustering keys  
D) Use more window functions  

**Your answer:**

---

## Answer Key

1. **B** - Query Profile (visual representation of query execution)
2. **B** - WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01' (direct comparison)
3. **B** - Operations exceed available memory and write to disk
4. **B** - Single query with COUNT(CASE WHEN ...) for each category (single pass)
5. **B** - Before the JOIN using CTEs or subqueries (reduces data volume)
6. **B** - Use JOIN with aggregation (more efficient)
7. **C** - 24 hours
8. **D** - Both B and C depending on use case
9. **B** - Different whitespace in query text (must be exact match)
10. **B** - Increase warehouse size or reduce data volume

---

## Score Yourself

- 9-10/10: Excellent! You understand query performance tuning thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Query Profile**: Essential diagnostic tool for performance  
✅ **Partition Pruning**: Use direct column comparisons (not functions)  
✅ **Data Spilling**: Memory overflow to disk (local or remote)  
✅ **JOIN Optimization**: Filter before joining  
✅ **Single-Pass Aggregations**: Use CASE instead of multiple subqueries  
✅ **Correlated Subqueries**: Replace with JOINs  
✅ **Result Caching**: 24-hour TTL, exact query match required  
✅ **DISTINCT vs GROUP BY**: GROUP BY often faster  
✅ **Window Functions**: Consistent partitioning improves performance  
✅ **QUALIFY**: Better than subquery for window function filtering  

## Exam Tips

**Common exam question patterns:**
- How to read Query Profile metrics
- Partition pruning best practices
- Identifying and fixing data spilling
- JOIN optimization techniques
- Aggregation optimization patterns
- Result caching behavior
- When to use EXPLAIN
- Query optimization anti-patterns

**Remember for the exam:**
- Query Profile: Shows execution details, partitions scanned, spilling
- Partition pruning: Avoid functions on filtered columns
- Data spilling: Local (moderate impact), Remote (severe impact)
- Fix spilling: Increase warehouse size or reduce data volume
- Filter before JOIN: Reduces rows processed
- Single-pass aggregations: COUNT(CASE WHEN ...)
- Result cache: 24 hours, exact query match, no table changes
- QUALIFY: Filters window function results efficiently
- EXISTS vs IN: EXISTS often better for large subqueries
- Consistent window partitioning: Improves performance

## Next Steps

- If you scored 8-10: Move to Day 12 (Warehouse Sizing & Scaling)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. How do you identify the slowest part of a query?
2. What metrics indicate poor partition pruning?
3. How do you fix a query with remote disk spilling?
4. When should you break a complex query into stages?
5. How do you optimize a query with multiple JOINs?
6. What's the impact of using functions in WHERE clauses?
7. How do you maximize result cache hits?
8. When should you use QUALIFY vs. subqueries?

## Real-World Applications

**Dashboard Optimization:**
- Analyze slow dashboard queries
- Optimize aggregations
- Leverage result caching
- Reduce data scanned

**ETL Performance:**
- Optimize large JOINs
- Fix spilling in transformations
- Improve partition pruning
- Break complex queries into stages

**Reporting Queries:**
- Single-pass aggregations
- Efficient window functions
- Materialized views for common queries
- Result cache for repeated queries

**Troubleshooting Workflow:**
1. Identify slow query
2. Open Query Profile
3. Check key metrics (time, partitions, spilling)
4. Identify bottleneck
5. Apply optimization
6. Test and measure
7. Repeat if needed

**Cost Optimization:**
- Reduce data scanned (partition pruning)
- Fix spilling (avoid larger warehouses)
- Leverage caching (reduce compute)
- Optimize JOINs (less processing time)

