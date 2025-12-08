# Day 6 Quiz: Advanced SQL Transformations

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the main difference between RANK() and DENSE_RANK()?

A) RANK() is faster than DENSE_RANK()  
B) RANK() leaves gaps in ranking after ties, DENSE_RANK() does not  
C) RANK() can only be used with numeric columns  
D) DENSE_RANK() requires an ORDER BY clause, RANK() does not  

**Your answer:**

---

### 2. What does the QUALIFY clause do?

A) Filters rows before aggregation like WHERE  
B) Filters rows after aggregation like HAVING  
C) Filters rows based on window function results  
D) Qualifies columns for indexing  

**Your answer:**

---

### 3. When would you use a LATERAL join?

A) When you need to join tables on multiple columns  
B) When a subquery needs to reference columns from preceding tables  
C) When you want to perform a cross join  
D) When you need better performance than regular joins  

**Your answer:**

---

### 4. How do you extract a field from JSON in Snowflake?

A) json_data['field_name']  
B) json_data.field_name  
C) json_data:field_name::TYPE  
D) GET_JSON_FIELD(json_data, 'field_name')  

**Your answer:**

---

### 5. What does the FLATTEN function do?

A) Removes duplicates from a table  
B) Converts nested arrays/objects into separate rows  
C) Compresses data to save storage  
D) Normalizes numeric values  

**Your answer:**

---

### 6. What's the difference between ROLLUP and CUBE?

A) ROLLUP is faster than CUBE  
B) ROLLUP creates hierarchical subtotals, CUBE creates all possible combinations  
C) CUBE only works with 2 columns, ROLLUP works with any number  
D) ROLLUP requires an ORDER BY, CUBE does not  

**Your answer:**

---

### 7. How do you create a recursive CTE?

A) Use WITH RECURSIVE and include UNION ALL between anchor and recursive parts  
B) Use CREATE RECURSIVE CTE statement  
C) Use LOOP keyword in the CTE definition  
D) Recursive CTEs are not supported in Snowflake  

**Your answer:**

---

### 8. What's the purpose of PARTITION BY in window functions?

A) To physically partition the table for better performance  
B) To divide the result set into groups for separate window calculations  
C) To create table partitions for clustering  
D) To split data across multiple warehouses  

**Your answer:**

---

### 9. How do you deduplicate data using window functions?

A) Use DISTINCT keyword with window functions  
B) Use ROW_NUMBER() with PARTITION BY and filter for rn = 1  
C) Use DEDUPLICATE() window function  
D) Use GROUP BY with window functions  

**Your answer:**

---

### 10. What's the difference between ROWS and RANGE in window frames?

A) ROWS is faster than RANGE  
B) ROWS counts physical rows, RANGE considers logical ranges based on values  
C) RANGE only works with dates, ROWS works with any data type  
D) ROWS requires ORDER BY, RANGE does not  

**Your answer:**

---

## Answer Key

1. **B** - RANK() leaves gaps in ranking after ties, DENSE_RANK() does not
2. **C** - Filters rows based on window function results
3. **B** - When a subquery needs to reference columns from preceding tables
4. **C** - json_data:field_name::TYPE
5. **B** - Converts nested arrays/objects into separate rows
6. **B** - ROLLUP creates hierarchical subtotals, CUBE creates all possible combinations
7. **A** - Use WITH RECURSIVE and include UNION ALL between anchor and recursive parts
8. **B** - To divide the result set into groups for separate window calculations
9. **B** - Use ROW_NUMBER() with PARTITION BY and filter for rn = 1
10. **B** - ROWS counts physical rows, RANGE considers logical ranges based on values

---

## Score Yourself

- 9-10/10: Excellent! You've mastered advanced SQL transformations
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Window Functions**: Perform calculations across rows without collapsing results  
✅ **QUALIFY**: Filter window function results (like HAVING for windows)  
✅ **LATERAL**: Subqueries can reference preceding tables  
✅ **JSON**: Use colon notation (data:field::TYPE) to extract fields  
✅ **FLATTEN**: Explodes arrays/objects into rows  
✅ **GROUPING SETS**: Multiple aggregation levels in one query  
✅ **ROLLUP**: Hierarchical subtotals (category → product → total)  
✅ **CUBE**: All possible combinations of grouping columns  
✅ **Recursive CTEs**: Handle hierarchical data (org charts, date series)  
✅ **PARTITION BY**: Divides data into groups for window calculations  

## Exam Tips

**Common exam question patterns:**
- Choosing the right window function (RANK vs DENSE_RANK vs ROW_NUMBER)
- When to use QUALIFY vs WHERE vs HAVING
- JSON extraction syntax (colon notation)
- FLATTEN for nested data structures
- Difference between ROLLUP, CUBE, and GROUPING SETS
- Recursive CTE structure (anchor + recursive parts)
- Window frame specifications (ROWS vs RANGE)

**Remember for the exam:**
- QUALIFY filters after window functions are calculated
- LATERAL allows correlated subqueries in FROM clause
- JSON fields: data:field::TYPE (colon, not dot notation)
- FLATTEN creates one row per array element
- ROLLUP: hierarchical (A,B,C → A,B → A → total)
- CUBE: all combinations (A,B,C → A,B → A,C → B,C → A → B → C → total)
- Recursive CTE needs: WITH RECURSIVE, anchor, UNION ALL, recursive part
- PARTITION BY resets window for each partition
- ROW_NUMBER() always unique, RANK() and DENSE_RANK() can have ties

## Next Steps

- If you scored 8-10: Move to Day 7 (Week 1 Review)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. How would you find the top 3 products per category per month?
2. How do you calculate a 7-day moving average with window functions?
3. How would you parse deeply nested JSON (3+ levels)?
4. When would you use LATERAL instead of a regular JOIN?
5. How do you generate a date series for the last 90 days?
6. How would you detect gaps in sequential data?
7. How do you calculate running totals with resets per group?
8. When would you choose ROLLUP over GROUPING SETS?

## Real-World Applications

**Window Functions:**
- Customer ranking and segmentation
- Running totals and moving averages
- Time-series analysis
- Deduplication strategies

**JSON Processing:**
- Event tracking data
- API response parsing
- Semi-structured log analysis
- Flexible schema handling

**Advanced Aggregations:**
- Multi-dimensional reporting
- Hierarchical summaries
- OLAP-style analytics
- Subtotal calculations

**Recursive CTEs:**
- Organizational hierarchies
- Bill of materials (BOM)
- Graph traversal
- Date/number series generation

