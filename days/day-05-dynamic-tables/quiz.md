# Day 5 Quiz: Dynamic Tables

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What does TARGET_LAG specify in a Dynamic Table?

A) The time it takes to create the table  
B) The maximum acceptable data freshness (how old data can be)  
C) The minimum time between refreshes  
D) The warehouse size to use  

**Your answer:**

---

### 2. When does Snowflake use incremental refresh for Dynamic Tables?

A) Always, for all queries  
B) Never, always uses full refresh  
C) For simple aggregations, filters, and joins without complex operations  
D) Only when TARGET_LAG is less than 5 minutes  

**Your answer:**

---

### 3. What's the main difference between Dynamic Tables and Materialized Views?

A) Dynamic Tables are faster  
B) Dynamic Tables allow TARGET_LAG control and can handle complex queries  
C) Materialized Views are more expensive  
D) There is no difference  

**Your answer:**

---

### 4. Can you chain Dynamic Tables together to create multi-layer pipelines?

A) No, each Dynamic Table must query base tables directly  
B) Yes, using TARGET_LAG = DOWNSTREAM for dependent tables  
C) Only if they're in the same schema  
D) Yes, but only up to 2 layers  

**Your answer:**

---

### 5. What does TARGET_LAG = DOWNSTREAM mean?

A) The table will never refresh  
B) The table inherits the lag from its upstream dependencies  
C) The table refreshes every hour  
D) The table uses a different warehouse  

**Your answer:**

---

### 6. How do you manually refresh a Dynamic Table?

A) DROP and recreate the table  
B) ALTER DYNAMIC TABLE table_name REFRESH;  
C) UPDATE DYNAMIC TABLE table_name;  
D) REFRESH TABLE table_name;  

**Your answer:**

---

### 7. Which operations typically prevent incremental refresh and require full refresh?

A) Simple GROUP BY and SUM  
B) WHERE clauses and filters  
C) Window functions, DISTINCT, and complex joins  
D) All aggregations  

**Your answer:**

---

### 8. How do you monitor Dynamic Table costs?

A) Dynamic Tables don't have costs  
B) Query DYNAMIC_TABLE_REFRESH_HISTORY for credits_used  
C) Only through Snowflake support  
D) Costs are hidden and cannot be monitored  

**Your answer:**

---

### 9. Can you suspend a Dynamic Table to stop automatic refreshes?

A) No, Dynamic Tables cannot be suspended  
B) Yes, using ALTER DYNAMIC TABLE table_name SUSPEND;  
C) Only if TARGET_LAG is greater than 1 hour  
D) Yes, but only for 24 hours  

**Your answer:**

---

### 10. When should you use Dynamic Tables instead of Streams + Tasks?

A) Never, Streams + Tasks are always better  
B) For standard transformations where declarative approach is simpler  
C) Only for small datasets  
D) When you need complex error handling  

**Your answer:**

---

## Answer Key

1. **B** - The maximum acceptable data freshness (how old data can be)
2. **C** - For simple aggregations, filters, and joins without complex operations
3. **B** - Dynamic Tables allow TARGET_LAG control and can handle complex queries
4. **B** - Yes, using TARGET_LAG = DOWNSTREAM for dependent tables
5. **B** - The table inherits the lag from its upstream dependencies
6. **B** - ALTER DYNAMIC TABLE table_name REFRESH;
7. **C** - Window functions, DISTINCT, and complex joins
8. **B** - Query DYNAMIC_TABLE_REFRESH_HISTORY for credits_used
9. **B** - Yes, using ALTER DYNAMIC TABLE table_name SUSPEND;
10. **B** - For standard transformations where declarative approach is simpler

---

## Score Yourself

- 9-10/10: Excellent! You understand Dynamic Tables thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Declarative**: Define WHAT you want, not HOW  
✅ **TARGET_LAG**: Controls refresh frequency and data freshness  
✅ **Incremental refresh**: Automatic for simple operations (most efficient)  
✅ **Full refresh**: Required for complex operations (window functions, DISTINCT)  
✅ **DOWNSTREAM**: Inherit lag from upstream dependencies  
✅ **Multi-layer**: Chain Dynamic Tables for complex pipelines  
✅ **Monitoring**: Use DYNAMIC_TABLE_REFRESH_HISTORY for costs and performance  
✅ **Management**: Can suspend, resume, and manually refresh  
✅ **vs. Materialized Views**: More control, handles complex queries  
✅ **vs. Streams + Tasks**: Simpler for standard transformations  

## Exam Tips

**Common exam question patterns:**
- When to use Dynamic Tables vs. Streams + Tasks vs. Materialized Views
- TARGET_LAG configuration and meaning
- Incremental vs. full refresh scenarios
- DOWNSTREAM usage in multi-layer pipelines
- How to monitor and optimize costs
- Management operations (suspend, resume, refresh)

**Remember for the exam:**
- TARGET_LAG = maximum acceptable data freshness
- Incremental refresh for simple aggregations (efficient)
- Full refresh for window functions, DISTINCT (less efficient)
- DOWNSTREAM inherits lag from upstream tables
- Can chain Dynamic Tables for multi-layer pipelines
- Monitor costs with DYNAMIC_TABLE_REFRESH_HISTORY
- Simpler than Streams + Tasks for standard transformations
- More flexible than Materialized Views

**Scenario questions:**
- "Need real-time dashboard updates?" → Dynamic Table with TARGET_LAG = '1 minute'
- "Complex multi-stage pipeline?" → Chain Dynamic Tables with DOWNSTREAM
- "Reduce refresh costs?" → Increase TARGET_LAG, optimize for incremental refresh
- "Window functions needed?" → Expect full refresh, plan accordingly
- "Simple vs. complex transformations?" → Dynamic Tables vs. Streams + Tasks

## Common Mistakes to Avoid

❌ **Mistake**: Setting TARGET_LAG too aggressively (1 minute for everything)  
✅ **Correct**: Balance freshness needs with costs (5 min - 1 hour typical)

❌ **Mistake**: Using window functions when simple aggregation would work  
✅ **Correct**: Design for incremental refresh when possible

❌ **Mistake**: Not using DOWNSTREAM for dependent tables  
✅ **Correct**: Use DOWNSTREAM to inherit lag from upstream

❌ **Mistake**: Forgetting to monitor credit usage  
✅ **Correct**: Regularly check DYNAMIC_TABLE_REFRESH_HISTORY

❌ **Mistake**: Using Dynamic Tables for everything  
✅ **Correct**: Use Streams + Tasks when you need custom control

## Real-World Scenarios

**Scenario 1: Real-Time Sales Dashboard**
- Dynamic Table with TARGET_LAG = '5 minutes'
- Simple aggregations (incremental refresh)
- Low cost, near real-time updates
- Benefit: Simple to maintain, automatic refresh

**Scenario 2: Multi-Layer Data Warehouse**
- Layer 1: Clean data (TARGET_LAG = '10 minutes')
- Layer 2: Enrich with dimensions (DOWNSTREAM)
- Layer 3: Aggregations (DOWNSTREAM)
- Benefit: Declarative pipeline, automatic propagation

**Scenario 3: Daily Reporting**
- Dynamic Table with TARGET_LAG = '1 day'
- Complex transformations with window functions
- Full refresh acceptable (once per day)
- Benefit: Cost-effective, meets business needs

**Scenario 4: Incremental Processing**
- Simple aggregations only
- TARGET_LAG = '15 minutes'
- Incremental refresh keeps costs low
- Benefit: Efficient, scalable

## Comparison Table

| Feature | Dynamic Tables | Streams + Tasks | Materialized Views |
|---------|---------------|-----------------|-------------------|
| Approach | Declarative | Imperative | Declarative |
| Complexity | Low | High | Low |
| Refresh Control | TARGET_LAG | Full control | None |
| Incremental | Automatic | Manual | Always |
| Complex Queries | Yes | Yes | Limited |
| Chaining | Yes (DOWNSTREAM) | Yes (task trees) | No |
| Cost Visibility | Clear | Clear | Hidden |
| Best For | Standard pipelines | Custom logic | Simple aggregations |

## Best Practices Checklist

✅ Start with longer TARGET_LAG (1 hour), optimize later  
✅ Use DOWNSTREAM for dependent Dynamic Tables  
✅ Design queries for incremental refresh when possible  
✅ Monitor credit usage regularly  
✅ Avoid window functions unless necessary  
✅ Use appropriate warehouse sizes  
✅ Document pipeline architecture  
✅ Test refresh behavior before production  
✅ Suspend tables during maintenance  
✅ Compare costs: Dynamic Tables vs. alternatives  

## Next Steps

- If you scored 8-10: Move to Day 6 (Advanced SQL Transformations)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Practice Questions

Try answering these without looking:

1. What command changes the TARGET_LAG of a Dynamic Table?
2. How do you check if a Dynamic Table is using incremental or full refresh?
3. What's the benefit of using DOWNSTREAM?
4. Which operations force full refresh?
5. How do you stop a Dynamic Table from refreshing?

**Answers:**
1. ALTER DYNAMIC TABLE table_name SET TARGET_LAG = 'new_value';
2. Query DYNAMIC_TABLE_REFRESH_HISTORY and check refresh_action column
3. Automatically inherits lag from upstream dependencies, simplifies configuration
4. Window functions, DISTINCT, complex joins, subqueries, set operations
5. ALTER DYNAMIC TABLE table_name SUSPEND;

## Key Takeaway

Dynamic Tables simplify data pipeline creation by providing a declarative approach to transformations. They're ideal for standard ETL/ELT workflows where you want automatic refresh management without the complexity of Streams and Tasks. Choose TARGET_LAG based on business needs, design for incremental refresh when possible, and monitor costs regularly.
