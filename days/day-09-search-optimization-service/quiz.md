# Day 9 Quiz: Search Optimization Service

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is Search Optimization Service best used for?

A) Range queries with BETWEEN predicates  
B) Point lookup queries with equality predicates  
C) Full table scans  
D) Aggregation queries without filters  

**Your answer:**

---

### 2. Which query pattern benefits MOST from Search Optimization?

A) SELECT * FROM table WHERE date BETWEEN '2024-01-01' AND '2024-12-31'  
B) SELECT * FROM table WHERE customer_id = 12345  
C) SELECT COUNT(*) FROM table  
D) SELECT * FROM table WHERE amount > 1000  

**Your answer:**

---

### 3. What is the typical storage overhead for Search Optimization?

A) 1-5%  
B) 10-30%  
C) 50-70%  
D) 100%+  

**Your answer:**

---

### 4. Can Search Optimization be used with clustering?

A) No, they are mutually exclusive  
B) Yes, they complement each other  
C) Only on tables smaller than 1 TB  
D) Only on temporary tables  

**Your answer:**

---

### 5. Which column type makes a GOOD candidate for Search Optimization?

A) Boolean flag (TRUE/FALSE)  
B) Status column with 3 values  
C) Customer email (high cardinality)  
D) Gender column (M/F)  

**Your answer:**

---

### 6. How do you enable Search Optimization on specific columns?

A) ALTER TABLE table_name ADD SEARCH OPTIMIZATION ON COLUMNS(col1, col2)  
B) ALTER TABLE table_name ADD SEARCH OPTIMIZATION ON EQUALITY(col1, col2)  
C) CREATE SEARCH INDEX ON table_name(col1, col2)  
D) ENABLE SEARCH OPTIMIZATION FOR table_name.col1  

**Your answer:**

---

### 7. Which query pattern is NOT optimized by Search Optimization?

A) WHERE customer_id = 123  
B) WHERE email IN ('a@example.com', 'b@example.com')  
C) WHERE amount > 1000  
D) WHERE product_name LIKE '%laptop%' (with SUBSTRING optimization)  

**Your answer:**

---

### 8. What happens to Search Optimization when data is inserted?

A) It must be manually rebuilt  
B) It is automatically maintained by Snowflake  
C) It is disabled until manually re-enabled  
D) The table must be recreated  

**Your answer:**

---

### 9. When should you use Search Optimization instead of clustering?

A) For large tables (> 1 TB) with range queries  
B) For time-series data with date filters  
C) For point lookups on high-cardinality columns  
D) For aggregation queries  

**Your answer:**

---

### 10. How do you check the build progress of Search Optimization?

A) SHOW SEARCH OPTIMIZATION PROGRESS  
B) SYSTEM$GET_SEARCH_OPTIMIZATION_PROGRESS('table_name')  
C) SELECT SEARCH_OPTIMIZATION_STATUS('table_name')  
D) GET_SEARCH_PROGRESS('table_name')  

**Your answer:**

---

## Answer Key

1. **B** - Point lookup queries with equality predicates
2. **B** - SELECT * FROM table WHERE customer_id = 12345
3. **B** - 10-30% (typical storage overhead)
4. **B** - Yes, they complement each other
5. **C** - Customer email (high cardinality)
6. **B** - ALTER TABLE table_name ADD SEARCH OPTIMIZATION ON EQUALITY(col1, col2)
7. **C** - WHERE amount > 1000 (range predicates not optimized)
8. **B** - It is automatically maintained by Snowflake
9. **C** - For point lookups on high-cardinality columns
10. **B** - SYSTEM$GET_SEARCH_OPTIMIZATION_PROGRESS('table_name')

---

## Score Yourself

- 9-10/10: Excellent! You understand Search Optimization thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Best For**: Point lookups with equality predicates (=, IN)  
✅ **Query Types**: Equality, substring (LIKE), VARIANT searches  
✅ **Cardinality**: Works best on high-cardinality columns  
✅ **Table Size**: Effective on any size (especially < 1 TB)  
✅ **Maintenance**: Automatic, no manual intervention  
✅ **Storage Overhead**: 10-30% typical  
✅ **Complementary**: Use with clustering for best results  
✅ **Cost**: Storage + maintenance credits  
✅ **Not For**: Range queries (>, <, BETWEEN)  
✅ **Syntax**: ADD SEARCH OPTIMIZATION ON EQUALITY(columns)  

## Exam Tips

**Common exam question patterns:**
- When to use Search Optimization vs. Clustering
- Which query patterns benefit from Search Optimization
- Storage overhead and cost implications
- How to enable on specific columns
- Automatic maintenance behavior
- Supported vs. unsupported query patterns

**Remember for the exam:**
- Search Optimization: Point lookups (=, IN)
- Clustering: Range queries (BETWEEN, >, <)
- Both can be used together
- Automatic maintenance (no manual rebuild)
- Storage overhead: 10-30%
- Best for high-cardinality columns
- Supports: Equality, Substring, VARIANT, Geospatial
- Does NOT support: Range predicates, IS NULL, complex expressions

## Next Steps

- If you scored 8-10: Move to Day 10 (Materialized Views)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. When would you use both clustering AND search optimization?
2. How do you determine if search optimization is cost-effective?
3. What's the best strategy for a customer lookup table?
4. How does search optimization affect INSERT performance?
5. When should you enable search optimization on substring searches?
6. How do you monitor search optimization costs?
7. What's the difference between search optimization and indexes?
8. How do you optimize VARIANT column searches?

## Real-World Applications

**Customer Lookup Systems:**
- Fast email/phone lookups
- Customer ID searches
- Account management systems
- CRM applications

**Order Tracking:**
- Order ID lookups
- Tracking number searches
- Invoice retrieval
- Transaction history

**Log Analysis:**
- Error message searches
- User activity tracking
- Session ID lookups
- Substring pattern matching

**Product Catalogs:**
- SKU lookups
- Product ID searches
- Product name searches
- Inventory management

**Combined Strategy (Clustering + Search Opt):**
- Cluster on date for time-series queries
- Search optimize on IDs for point lookups
- Best of both worlds
- Common in sales, orders, events tables

