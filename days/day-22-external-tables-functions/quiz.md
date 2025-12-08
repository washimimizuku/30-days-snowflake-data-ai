# Day 22 Quiz: External Tables & External Functions

## Instructions
- 10 multiple choice questions
- Choose the best answer for each question
- Answers and explanations at the end
- Passing score: 7/10 (70%)

---

## Questions

### Question 1
Where is the data stored when you create an external table in Snowflake?

A) In Snowflake's internal storage  
B) In external cloud storage (S3, Azure Blob, GCS)  
C) In a hybrid of Snowflake and external storage  
D) In a temporary staging area

### Question 2
Which operations are supported on external tables?

A) SELECT, INSERT, UPDATE, DELETE  
B) SELECT, INSERT only  
C) SELECT only  
D) All DML operations

### Question 3
What is the primary benefit of using partitioned external tables?

A) Enables DML operations  
B) Reduces storage costs  
C) Improves query performance through partition pruning  
D) Enables Time Travel

### Question 4
Which file format typically provides the BEST query performance for external tables?

A) CSV  
B) JSON  
C) Parquet  
D) XML

### Question 5
What is a materialized view on an external table used for?

A) To enable updates on external data  
B) To pre-compute and store frequently accessed query results  
C) To partition the external data  
D) To enable Time Travel on external tables

### Question 6
Which metadata column shows the source file name in an external table?

A) METADATA$SOURCE  
B) METADATA$FILENAME  
C) METADATA$FILE_PATH  
D) METADATA$ORIGIN

### Question 7
What is an external function in Snowflake?

A) A UDF written in JavaScript  
B) A function that calls external APIs or services (AWS Lambda, Azure Functions)  
C) A function stored in external storage  
D) A system function for external tables

### Question 8
When should you use external tables instead of regular tables?

A) For frequently queried operational data  
B) For data requiring frequent updates  
C) For infrequently accessed data or exploratory analysis  
D) For performance-critical queries

### Question 9
What happens when you query an external table?

A) Data is automatically loaded into Snowflake first  
B) Snowflake queries the data directly from external storage  
C) Data is cached in Snowflake for 24 hours  
D) Data is copied to a temporary table

### Question 10
Which is TRUE about external functions?

A) They execute within Snowflake's compute  
B) They are free to use  
C) They call external services like AWS Lambda  
D) They can only process one row at a time

---

## Answer Key

### Question 1: B
**Correct Answer: B) In external cloud storage (S3, Azure Blob, GCS)**

Explanation: External tables store data in external cloud storage (S3, Azure Blob Storage, or Google Cloud Storage). Only metadata about the table structure and file locations is stored in Snowflake. This is the key characteristic that distinguishes external tables from regular tables.

### Question 2: C
**Correct Answer: C) SELECT only**

Explanation: External tables are read-only. You can only query them using SELECT statements. DML operations (INSERT, UPDATE, DELETE) are not supported because the data resides in external storage that Snowflake doesn't control. To modify data, you must update the source files in external storage.

### Question 3: C
**Correct Answer: C) Improves query performance through partition pruning**

Explanation: Partitioned external tables improve query performance by enabling partition pruning. When you filter on partition columns, Snowflake only scans the relevant partitions (files/directories) rather than all data. This significantly reduces the amount of data scanned and improves query speed.

### Question 4: C
**Correct Answer: C) Parquet**

Explanation: Parquet is a columnar file format that provides the best query performance for external tables. It's optimized for analytical queries, supports efficient compression, and allows Snowflake to read only the columns needed for a query. Other good options include ORC and Avro. CSV and JSON are slower because they're row-based formats.

### Question 5: B
**Correct Answer: B) To pre-compute and store frequently accessed query results**

Explanation: Materialized views on external tables pre-compute and store query results (typically aggregations) in Snowflake's storage. This dramatically improves performance for frequently accessed queries because the results are already computed and stored internally, avoiding repeated scans of external storage.

### Question 6: B
**Correct Answer: B) METADATA$FILENAME**

Explanation: METADATA$FILENAME is the metadata column that contains the source file name. Other metadata columns include METADATA$FILE_ROW_NUMBER (row number within the file), METADATA$FILE_CONTENT_KEY (unique file identifier), and METADATA$FILE_LAST_MODIFIED (file modification timestamp).

### Question 7: B
**Correct Answer: B) A function that calls external APIs or services (AWS Lambda, Azure Functions)**

Explanation: External functions allow Snowflake to call external APIs or cloud services like AWS Lambda, Azure Functions, or Google Cloud Functions. This enables custom logic, machine learning model inference, external data enrichment, and integration with external systems that aren't possible with standard SQL or UDFs.

### Question 8: C
**Correct Answer: C) For infrequently accessed data or exploratory analysis**

Explanation: External tables are best for infrequently accessed data, exploratory data analysis on data lakes, or data shared across multiple systems. They avoid duplicate storage costs but have slower query performance. For frequently queried or performance-critical data, regular tables are better.

### Question 9: B
**Correct Answer: B) Snowflake queries the data directly from external storage**

Explanation: When you query an external table, Snowflake reads the data directly from external storage (S3, Azure, GCS) at query time. The data is not loaded or cached in Snowflake (unless you create a materialized view). This is why external table queries are typically slower than regular table queries.

### Question 10: C
**Correct Answer: C) They call external services like AWS Lambda**

Explanation: External functions call external services like AWS Lambda, Azure Functions, or Google Cloud Functions. They execute outside Snowflake's compute environment, incur costs from the external service, and can process batches of rows (not just one at a time). The default batch size is up to 500 rows.

---

## Scoring Guide

- **9-10 correct**: Excellent! You understand external tables and functions thoroughly.
- **7-8 correct**: Good job! Review the questions you missed.
- **5-6 correct**: Fair. Review the README.md and retry the exercises.
- **Below 5**: Review the material and complete the hands-on exercises again.

---

## Key Concepts to Remember

1. **External Tables**
   - Data stays in external storage (S3/Azure/GCS)
   - Only metadata stored in Snowflake
   - Read-only (SELECT only, no DML)
   - Slower than regular tables
   - No Time Travel or clustering

2. **When to Use External Tables**
   - Infrequently accessed data
   - Exploratory data analysis
   - Data shared across systems
   - Cost optimization (avoid duplicate storage)
   - Data lake queries

3. **Partitioning**
   - Improves performance via partition pruning
   - Partition by date for time-series data
   - Partition by region for geographic data
   - Filter on partition columns for best performance

4. **File Formats**
   - Parquet: Best performance (columnar)
   - ORC: Good performance (columnar)
   - Avro: Good performance
   - JSON/CSV: Slower (row-based)

5. **Materialized Views**
   - Pre-compute frequently accessed queries
   - Store results in Snowflake
   - Much faster than querying external table
   - Balance between external and regular tables

6. **Metadata Columns**
   - METADATA$FILENAME: Source file name
   - METADATA$FILE_ROW_NUMBER: Row number in file
   - METADATA$FILE_CONTENT_KEY: Unique file ID
   - METADATA$FILE_LAST_MODIFIED: File timestamp

7. **External Functions**
   - Call AWS Lambda, Azure Functions, GCP
   - Enable custom logic and ML inference
   - Integrate with external APIs
   - Batch requests for performance
   - Monitor costs (external service charges)

8. **Cost Considerations**
   - External tables: Compute + external storage + data transfer
   - Regular tables: Compute + Snowflake storage
   - External functions: Compute + external service costs
   - Materialized views: Additional storage but faster queries

---

## Exam Tips

1. **Remember the limitations**: External tables are read-only, no Time Travel, no clustering, no DML.

2. **Understand use cases**: External tables for infrequent access, regular tables for frequent access.

3. **Partition pruning**: Filtering on partition columns dramatically improves performance.

4. **File formats matter**: Parquet > ORC > Avro > JSON > CSV for performance.

5. **Materialized views**: Best way to optimize frequently accessed external data.

6. **External functions**: Know they call external services (Lambda, etc.) and incur external costs.

7. **Metadata columns**: Useful for troubleshooting and data lineage.

8. **Hybrid approach**: Recent data in tables, historical in external tables.

---

## Additional Practice

Try these scenarios:

1. **Scenario**: You have 10 TB of historical log data in S3 that's queried once a month. What's the best approach?
   - **Answer**: Use external tables. Infrequent access doesn't justify loading into Snowflake.

2. **Scenario**: You need to query 5 years of sales data, but 90% of queries only access the last 30 days. What's optimal?
   - **Answer**: Hybrid approach - last 30 days in regular table, older data in partitioned external table.

3. **Scenario**: You're querying an external table daily for the same aggregation. How can you optimize?
   - **Answer**: Create a materialized view on the external table to pre-compute the aggregation.

4. **Scenario**: You need to enrich customer data with credit scores from an external API. What feature should you use?
   - **Answer**: External function that calls the credit score API.

---

## Next Steps

- If you scored 8-10: Move to Day 23 (Stored Procedures & UDFs)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

---

## Resources for Further Study

- [Snowflake Docs: External Tables](https://docs.snowflake.com/en/user-guide/tables-external-intro)
- [Partitioned External Tables](https://docs.snowflake.com/en/user-guide/tables-external-partitions)
- [External Functions](https://docs.snowflake.com/en/sql-reference/external-functions-introduction)
- [Materialized Views](https://docs.snowflake.com/en/user-guide/views-materialized)

---

**Congratulations on completing Day 22!** 🎉

Tomorrow, we'll dive into stored procedures and user-defined functions for custom logic in Snowflake.
