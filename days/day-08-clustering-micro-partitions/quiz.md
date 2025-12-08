# Day 8 Quiz: Clustering & Micro-Partitions

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the typical size of a Snowflake micro-partition when compressed?

A) 1-4 MB  
B) 16 MB  
C) 50-500 MB  
D) 1 GB  

**Your answer:**

---

### 2. What is partition pruning?

A) Deleting old partitions automatically  
B) Skipping irrelevant micro-partitions based on metadata  
C) Compressing partitions to save storage  
D) Merging small partitions into larger ones  

**Your answer:**

---

### 3. When should you use clustering keys?

A) On all tables regardless of size  
B) Only on tables larger than 1 TB with consistent query patterns  
C) Only on tables with less than 1 million rows  
D) On temporary tables for better performance  

**Your answer:**

---

### 4. What is the maximum recommended number of clustering key columns?

A) 1  
B) 2  
C) 4  
D) 10  

**Your answer:**

---

### 5. What does clustering depth measure?

A) The number of micro-partitions in a table  
B) How well data is clustered (lower is better)  
C) The storage size of clustered data  
D) The number of clustering keys  

**Your answer:**

---

### 6. Which clustering depth indicates excellent clustering?

A) Depth 1-2  
B) Depth 5-10  
C) Depth 10-20  
D) Depth > 20  

**Your answer:**

---

### 7. What does automatic clustering do?

A) Automatically creates clustering keys  
B) Automatically re-clusters tables to maintain optimal organization  
C) Automatically deletes old data  
D) Automatically creates indexes  

**Your answer:**

---

### 8. How do you check the clustering depth of a table?

A) SHOW CLUSTERING DEPTH table_name  
B) SELECT CLUSTERING_DEPTH(table_name)  
C) SYSTEM$CLUSTERING_DEPTH('table_name', '(column)')  
D) GET_CLUSTERING_INFO('table_name')  

**Your answer:**

---

### 9. Which column makes a poor clustering key candidate?

A) High-cardinality date column used in WHERE clauses  
B) Customer ID used frequently in JOINs  
C) Boolean flag with only TRUE/FALSE values  
D) Timestamp column for time-series data  

**Your answer:**

---

### 10. What happens when you suspend automatic clustering?

A) The table is dropped  
B) Existing clustering is removed  
C) Re-clustering stops but clustering keys remain  
D) All queries on the table fail  

**Your answer:**

---

## Answer Key

1. **B** - 16 MB (typical compressed size, 50-500 MB uncompressed)
2. **B** - Skipping irrelevant micro-partitions based on metadata
3. **B** - Only on tables larger than 1 TB with consistent query patterns
4. **C** - 4 (maximum recommended)
5. **B** - How well data is clustered (lower is better)
6. **A** - Depth 1-2 (excellent clustering)
7. **B** - Automatically re-clusters tables to maintain optimal organization
8. **C** - SYSTEM$CLUSTERING_DEPTH('table_name', '(column)')
9. **C** - Boolean flag with only TRUE/FALSE values (low cardinality)
10. **C** - Re-clustering stops but clustering keys remain

---

## Score Yourself

- 9-10/10: Excellent! You understand clustering thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Micro-Partitions**: 50-500 MB uncompressed, 16 MB compressed (typical)  
✅ **Partition Pruning**: Skips irrelevant partitions using metadata  
✅ **Clustering Keys**: Organize data for optimal query performance  
✅ **Table Size Threshold**: Only cluster tables > 1 TB  
✅ **Max Clustering Keys**: 4 columns recommended  
✅ **Clustering Depth**: Lower is better (target < 5)  
✅ **Automatic Clustering**: Maintains optimal organization automatically  
✅ **Good Candidates**: High-cardinality, frequently filtered columns  
✅ **Poor Candidates**: Low-cardinality, rarely queried columns  
✅ **Cost Monitoring**: Track re-clustering credits vs. performance gains  

## Exam Tips

**Common exam question patterns:**
- When to use clustering vs. when not to use it
- Clustering depth interpretation (what's good vs. poor)
- Clustering key selection criteria
- Automatic clustering behavior
- Cost implications of re-clustering
- Micro-partition size and characteristics

**Remember for the exam:**
- Micro-partitions: 50-500 MB uncompressed, immutable
- Clustering threshold: > 1 TB tables
- Max clustering keys: 4 recommended
- Clustering depth: < 5 is good, < 2 is excellent
- Automatic clustering: Can be suspended/resumed
- Re-clustering consumes credits
- Partition pruning uses min/max metadata
- Clustering keys can be expressions

## Next Steps

- If you scored 8-10: Move to Day 9 (Search Optimization)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. When would you choose clustering over search optimization?
2. How do you determine if clustering is cost-effective?
3. What clustering strategy for a table with date and region filters?
4. How do you monitor clustering health in production?
5. When should you suspend automatic clustering?
6. How does clustering affect INSERT performance?
7. What's the impact of clustering on storage costs?
8. How do you choose between single vs. multi-column clustering?

## Real-World Applications

**Time-Series Data:**
- Cluster on timestamp/date columns
- Optimize queries with date range filters
- Common in logs, events, IoT data

**Multi-Dimensional Analytics:**
- Cluster on date + dimension (region, category)
- Optimize OLAP-style queries
- Common in sales, financial data

**Customer Analytics:**
- Cluster on customer_id for customer-centric queries
- Optimize JOIN operations
- Common in CRM, user behavior analysis

**Cost Optimization:**
- Monitor re-clustering costs
- Balance performance vs. cost
- Suspend during bulk loads
- Critical for large-scale deployments

