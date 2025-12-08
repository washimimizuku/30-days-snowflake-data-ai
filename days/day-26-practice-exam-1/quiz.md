# Practice Exam 1: SnowPro Advanced Data Engineer

## Exam Instructions

**Time Limit: 115 minutes**  
**Questions: 65**  
**Passing Score: 70% (46/65 correct)**  
**Format: Multiple choice (A, B, C, D)**

**Rules:**
- Set a timer for 115 minutes
- No documentation or references during exam
- Answer all questions (no penalty for wrong answers)
- Flag difficult questions and return to them
- Treat this like the real certification exam

**Good luck!** 🍀

---

## Questions

### Domain 1: Data Movement (Questions 1-20)

**Question 1**  
A data engineer needs to continuously load JSON files from an S3 bucket into Snowflake as soon as they arrive. Which solution is most appropriate?

A) Create a task that runs every minute to check for new files  
B) Use Snowpipe with auto-ingest enabled and S3 event notifications  
C) Schedule a stored procedure to run hourly using CRON  
D) Use external tables to query the S3 data directly

**Question 2**  
What is the purpose of the METADATA$ACTION column in a Snowflake stream?

A) It stores the timestamp when the change occurred  
B) It indicates whether the row was INSERT or DELETE  
C) It contains the user who made the change  
D) It shows the query ID that caused the change

**Question 3**  
A task is configured with `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')`. What does this accomplish?

A) The task will fail if the stream is empty  
B) The task will only run when the stream contains data, saving compute costs  
C) The task will automatically create the stream if it doesn't exist  
D) The task will delete the stream after processing

**Question 4**  
Which statement about Snowpipe is TRUE?

A) Snowpipe uses user-managed virtual warehouses for loading  
B) Snowpipe can transform data during the load process  
C) Snowpipe uses serverless compute resources managed by Snowflake  
D) Snowpipe requires manual triggering for each file

**Question 5**  
A stream is created on a table with `APPEND_ONLY = TRUE`. What changes will this stream capture?

A) Only INSERT operations  
B) INSERT and UPDATE operations  
C) INSERT and DELETE operations  
D) All DML operations (INSERT, UPDATE, DELETE)

**Question 6**  
What happens to a stream after its data is consumed in a DML transaction?

A) The stream is automatically dropped  
B) The stream offset advances and consumed records are no longer visible  
C) The stream is locked and cannot be queried  
D) The stream data remains unchanged until manually reset

**Question 7**  
A data engineer needs to create a task DAG where Task B and Task C run after Task A completes. How should this be configured?

A) Set Task A as the root task, add Task B and Task C as predecessors  
B) Set Task A as the root task, add Task B and Task C with AFTER Task A  
C) Create three independent tasks with the same schedule  
D) Use a stored procedure to manually execute tasks in order

**Question 8**  
What is the maximum frequency for a scheduled task in Snowflake?

A) Every 30 seconds  
B) Every 1 minute  
C) Every 5 minutes  
D) Every 15 minutes

**Question 9**  
Which metadata column in a stream indicates whether a row represents an UPDATE operation?

A) METADATA$ACTION  
B) METADATA$ISUPDATE  
C) METADATA$ROW_ID  
D) METADATA$UPDATE_TYPE

**Question 10**  
A Snowpipe is failing to load files. Which system function can be used to check the pipe status?

A) SYSTEM$PIPE_STATUS('pipe_name')  
B) SHOW PIPE STATUS  
C) GET_PIPE_STATUS('pipe_name')  
D) DESCRIBE PIPE pipe_name

**Question 11**  
What is the difference between serverless tasks and user-managed tasks?

A) Serverless tasks use Snowflake-managed compute, user-managed tasks require a warehouse  
B) Serverless tasks are free, user-managed tasks incur costs  
C) Serverless tasks can only run SQL, user-managed tasks can run stored procedures  
D) There is no difference, they are the same

**Question 12**  
A stream shows METADATA$ACTION = 'INSERT' and METADATA$ISUPDATE = TRUE. What does this represent?

A) A new row was inserted  
B) The new state of an updated row  
C) A row was deleted  
D) A duplicate row was detected

**Question 13**  
Which file format is NOT natively supported by Snowflake for data loading?

A) JSON  
B) Parquet  
C) XML  
D) PDF

**Question 14**  
A task tree has 5 tasks. Task A is the root, Tasks B and C depend on A, and Tasks D and E depend on C. If Task C fails, what happens?

A) All tasks fail  
B) Tasks D and E are skipped, but Task B completes  
C) The entire task tree is suspended  
D) Tasks D and E retry automatically

**Question 15**  
What is the retention period for Snowpipe load history?

A) 7 days  
B) 14 days  
C) 30 days  
D) 64 days

**Question 16**  
A data engineer needs to load data from Azure Blob Storage. Which integration object is required?

A) STORAGE INTEGRATION  
B) EXTERNAL STAGE  
C) FILE FORMAT  
D) All of the above

**Question 17**  
Which statement about streams is FALSE?

A) Streams can be created on views  
B) Streams can be created on external tables  
C) Streams can be created on materialized views  
D) Streams track changes using hidden columns

**Question 18**  
A task is scheduled to run every 5 minutes but takes 8 minutes to complete. What happens?

A) The next run is skipped to avoid overlap  
B) Multiple instances run concurrently  
C) The task fails with an error  
D) The schedule automatically adjusts to 10 minutes

**Question 19**  
What is the purpose of the COPY command's ON_ERROR parameter?

A) To specify error logging location  
B) To define behavior when errors occur during loading (CONTINUE, SKIP_FILE, ABORT_STATEMENT)  
C) To automatically fix data quality issues  
D) To send email notifications on errors

**Question 20**  
A stream is created with `SHOW_INITIAL_ROWS = TRUE`. What does this mean?

A) The stream will show all existing rows in the table as INSERT operations  
B) The stream will only show the first 1000 rows  
C) The stream will display row numbers  
D) The stream will include historical changes

---

### Domain 2: Performance Optimization (Questions 21-36)

**Question 21**  
A table has 1 billion rows and queries frequently filter on `order_date` and `region`. What is the best optimization strategy?

A) Create a clustering key on (order_date, region)  
B) Create separate tables for each region  
C) Use a materialized view for each region  
D) Increase warehouse size to 6XL

**Question 22**  
What does a clustering depth of 15 indicate?

A) The table is well-clustered  
B) The table may benefit from reclustering  
C) The table has 15 micro-partitions  
D) The table is partitioned into 15 regions

**Question 23**  
Which scenario is BEST suited for Search Optimization Service?

A) Large table with frequent point lookups on high-cardinality columns  
B) Small table with full table scans  
C) Table with frequent aggregations  
D) Table with sequential scans

**Question 24**  
What is the maximum number of columns that can be included in a clustering key?

A) 1  
B) 4  
C) 8  
D) 16

**Question 25**  
A materialized view is not refreshing automatically. What could be the reason?

A) The base table has not changed  
B) The materialized view is suspended  
C) The query is too complex for automatic refresh  
D) All of the above

**Question 26**  
What is the primary difference between a materialized view and a regular view?

A) Materialized views store query results physically, regular views execute queries on demand  
B) Materialized views are faster to create  
C) Regular views cannot be queried  
D) Materialized views do not support joins

**Question 27**  
A query is spilling to local disk. What does this indicate?

A) The warehouse is too small for the query's memory requirements  
B) The table needs clustering  
C) The query result is too large  
D) The warehouse is out of disk space

**Question 28**  
What is the benefit of using a multi-cluster warehouse?

A) Reduces query execution time  
B) Handles high concurrency by adding clusters automatically  
C) Reduces storage costs  
D) Improves clustering effectiveness

**Question 29**  
Query result caching is invalidated when:

A) 24 hours have passed since the query was executed  
B) The underlying table data has changed  
C) A different user runs the same query  
D) Both A and B

**Question 30**  
What is the purpose of the CLUSTER BY clause when creating a table?

A) To partition the table across multiple databases  
B) To organize micro-partitions for better query performance  
C) To create a multi-cluster warehouse  
D) To enable automatic clustering

**Question 31**  
A warehouse is set to auto-suspend after 60 seconds. What happens to running queries when auto-suspend triggers?

A) Queries are immediately terminated  
B) Queries continue running; warehouse suspends after they complete  
C) Queries are paused and resumed when warehouse restarts  
D) Queries fail with a timeout error

**Question 32**  
Which warehouse scaling policy prioritizes cost savings over performance?

A) Standard  
B) Economy  
C) Performance  
D) Balanced

**Question 33**  
What is partition pruning?

A) Deleting old partitions from a table  
B) Snowflake skipping irrelevant micro-partitions during query execution  
C) Compressing micro-partitions to save space  
D) Reorganizing partitions for better performance

**Question 34**  
A query profile shows "Bytes spilled to remote storage". What does this indicate?

A) Minor performance impact, warehouse size is adequate  
B) Significant performance impact, warehouse is too small  
C) Data is being backed up to cloud storage  
D) Query results are being cached

**Question 35**  
What is the recommended maximum number of clustering keys for optimal performance?

A) 1-2  
B) 3-4  
C) 5-6  
D) 7-8

**Question 36**  
Which statement about automatic clustering is TRUE?

A) It is free and does not consume credits  
B) It runs automatically when clustering depth exceeds thresholds  
C) It must be manually triggered  
D) It only works on tables smaller than 1TB

---

### Domain 3: Security & Governance (Questions 37-49)

**Question 37**  
What is the difference between a masking policy and a row access policy?

A) Masking policies hide column values, row access policies filter rows  
B) Masking policies filter rows, row access policies hide columns  
C) They are the same, just different names  
D) Masking policies are for tables, row access policies are for views

**Question 38**  
A masking policy is applied to the `email` column. What happens when a user with the DATA_ANALYST role queries the table?

A) The query fails with a permission error  
B) The email column is excluded from results  
C) The email values are masked according to the policy logic  
D) The email values are encrypted

**Question 39**  
What is the maximum Time Travel retention period for Snowflake Enterprise Edition?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days

**Question 40**  
Which statement about Fail-safe is TRUE?

A) Fail-safe data can be recovered by users using Time Travel  
B) Fail-safe provides 7 days of data recovery by Snowflake Support only  
C) Fail-safe is free and does not incur storage costs  
D) Fail-safe can be disabled to save costs

**Question 41**  
A role hierarchy is: SYSADMIN > DATA_ENGINEER > DATA_ANALYST. If DATA_ENGINEER has SELECT privilege on a table, which roles can query the table?

A) Only DATA_ENGINEER  
B) DATA_ENGINEER and DATA_ANALYST  
C) SYSADMIN and DATA_ENGINEER  
D) All three roles

**Question 42**  
What is the purpose of the EXECUTE AS CALLER option in a stored procedure?

A) The procedure runs with the caller's privileges  
B) The procedure runs with the owner's privileges  
C) The procedure runs with SYSADMIN privileges  
D) The procedure runs without any privilege checks

**Question 43**  
A table was accidentally dropped 5 days ago. How can it be recovered?

A) Use UNDROP TABLE command  
B) Contact Snowflake Support for Fail-safe recovery  
C) Restore from a backup  
D) It cannot be recovered

**Question 44**  
Which view provides information about data access history for compliance auditing?

A) INFORMATION_SCHEMA.ACCESS_HISTORY  
B) ACCOUNT_USAGE.ACCESS_HISTORY  
C) SNOWFLAKE.ACCESS_LOG  
D) INFORMATION_SCHEMA.QUERY_HISTORY

**Question 45**  
What is the purpose of a secure view?

A) To encrypt view data  
B) To hide the view definition from unauthorized users  
C) To improve query performance  
D) To enable Time Travel on views

**Question 46**  
A row access policy is applied to a table. What happens if a user's role is not explicitly handled in the policy?

A) The user can see all rows  
B) The user cannot see any rows  
C) The query fails with an error  
D) The policy is ignored

**Question 47**  
What is the difference between OWNERSHIP and USAGE privileges?

A) OWNERSHIP allows full control including dropping objects, USAGE allows using objects  
B) They are the same privilege  
C) OWNERSHIP is for databases, USAGE is for schemas  
D) USAGE is more powerful than OWNERSHIP

**Question 48**  
Which encryption method does Snowflake use for data at rest?

A) AES-128  
B) AES-256  
C) RSA-2048  
D) Triple DES

**Question 49**  
What is Tri-Secret Secure?

A) A three-factor authentication method  
B) Customer-managed encryption keys combined with Snowflake's encryption  
C) A security policy requiring three approvals  
D) A backup strategy using three copies

---

### Domain 4: Monitoring & Troubleshooting (Questions 50-59)

**Question 50**  
What is the primary difference between ACCOUNT_USAGE and INFORMATION_SCHEMA views?

A) ACCOUNT_USAGE has latency (45 min to 3 hours), INFORMATION_SCHEMA is real-time  
B) INFORMATION_SCHEMA has latency, ACCOUNT_USAGE is real-time  
C) They contain different data  
D) ACCOUNT_USAGE is only for ACCOUNTADMIN role

**Question 51**  
A query is running slowly. Which tool should be used first to identify the bottleneck?

A) Query Profile  
B) EXPLAIN plan  
C) ACCOUNT_USAGE.QUERY_HISTORY  
D) Warehouse metrics

**Question 52**  
What does "Partition pruning: 95%" in a query profile indicate?

A) 95% of micro-partitions were scanned  
B) 95% of micro-partitions were skipped, only 5% were scanned  
C) The query failed 95% of the time  
D) 95% of the data was compressed

**Question 53**  
A task is failing with "SQL execution error". Where should you look first for details?

A) SHOW TASKS  
B) INFORMATION_SCHEMA.TASK_HISTORY()  
C) ACCOUNT_USAGE.TASK_HISTORY  
D) Query history

**Question 54**  
What is the retention period for query history in INFORMATION_SCHEMA?

A) 7 days  
B) 14 days  
C) 30 days  
D) 365 days

**Question 55**  
A warehouse is consuming more credits than expected. Which view should be queried to analyze usage?

A) ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY  
B) INFORMATION_SCHEMA.WAREHOUSE_USAGE  
C) SNOWFLAKE.WAREHOUSE_METRICS  
D) ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY

**Question 56**  
What does a "Bytes spilled to local disk" warning in a query profile suggest?

A) The query is performing well  
B) The warehouse may be undersized, causing memory overflow  
C) Data is being cached for future queries  
D) The table needs clustering

**Question 57**  
How can you identify which queries are not benefiting from result caching?

A) Check QUERY_HISTORY for RESULT_CACHE_HIT = FALSE  
B) Use the Query Profile  
C) Check ACCOUNT_USAGE.CACHE_METRICS  
D) Both A and B

**Question 58**  
A Snowpipe is not loading files. Which command provides detailed error information?

A) SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(...))  
B) SHOW PIPE STATUS  
C) SYSTEM$PIPE_STATUS('pipe_name')  
D) COPY INTO ... VALIDATION_MODE = RETURN_ERRORS

**Question 59**  
What is the purpose of a resource monitor?

A) To monitor query performance  
B) To set credit limits and trigger actions when thresholds are reached  
C) To monitor warehouse availability  
D) To track user activity

---

### Domain 5: Advanced Features (Questions 60-65)

**Question 60**  
What is the primary difference between a stored procedure and a UDF?

A) Stored procedures can contain DML, UDFs cannot  
B) UDFs can contain DML, stored procedures cannot  
C) They are the same  
D) Stored procedures are faster

**Question 61**  
A UDF is created with the MEMOIZABLE keyword. What does this do?

A) The UDF results are cached for identical inputs  
B) The UDF uses less memory  
C) The UDF runs faster  
D) The UDF can be called from stored procedures

**Question 62**  
Which language is NOT supported for Snowflake stored procedures?

A) JavaScript  
B) SQL  
C) Python  
D) R

**Question 63**  
What is a UDTF (User-Defined Table Function)?

A) A function that returns a single scalar value  
B) A function that returns a table (multiple rows and columns)  
C) A function that creates tables  
D) A function that updates tables

**Question 64**  
In Snowpark, what is lazy evaluation?

A) Operations are executed immediately  
B) Operations are queued and executed only when results are needed  
C) Operations are executed slowly  
D) Operations are skipped if not needed

**Question 65**  
What is the primary benefit of using Snowpark over SQL for data engineering?

A) Snowpark is faster than SQL  
B) Snowpark allows complex transformations using Python/Scala with DataFrame API  
C) Snowpark is cheaper than SQL  
D) Snowpark does not require a warehouse

---

## Answer Key

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 1  | B      | 18 | A      | 35 | B      | 52 | B      |
| 2  | B      | 19 | B      | 36 | B      | 53 | B      |
| 3  | B      | 20 | A      | 37 | A      | 54 | A      |
| 4  | C      | 21 | A      | 38 | C      | 55 | A      |
| 5  | A      | 22 | B      | 39 | D      | 56 | B      |
| 6  | B      | 23 | A      | 40 | B      | 57 | D      |
| 7  | B      | 24 | B      | 41 | C      | 58 | A      |
| 8  | B      | 25 | D      | 42 | A      | 59 | B      |
| 9  | B      | 26 | A      | 43 | A      | 60 | A      |
| 10 | A      | 27 | A      | 44 | B      | 61 | A      |
| 11 | A      | 28 | B      | 45 | B      | 62 | D      |
| 12 | B      | 29 | D      | 46 | B      | 63 | B      |
| 13 | D      | 30 | B      | 47 | A      | 64 | B      |
| 14 | B      | 31 | B      | 48 | B      | 65 | B      |
| 15 | B      | 32 | B      | 49 | B      |    |        |
| 16 | D      | 33 | B      | 50 | A      |    |        |
| 17 | B      | 34 | B      | 51 | A      |    |        |

---

## Detailed Explanations

### Domain 1: Data Movement

**Q1: B** - Snowpipe with auto-ingest is designed for continuous, automated loading from cloud storage with event notifications.

**Q2: B** - METADATA$ACTION indicates INSERT or DELETE. For UPDATEs, you see both DELETE (old) and INSERT (new) rows.

**Q3: B** - This condition prevents the task from running (and consuming credits) when the stream is empty.

**Q4: C** - Snowpipe uses Snowflake-managed serverless compute, not user warehouses.

**Q5: A** - APPEND_ONLY streams only capture INSERT operations, useful for append-only tables.

**Q6: B** - After consumption in a DML transaction, the stream offset advances and those records are no longer visible.

**Q7: B** - Task B and C should specify `AFTER task_a` to create dependencies.

**Q8: B** - Minimum task frequency is 1 minute.

**Q9: B** - METADATA$ISUPDATE = TRUE indicates the row is part of an UPDATE operation.

**Q10: A** - SYSTEM$PIPE_STATUS returns the current status of a Snowpipe.

**Q11: A** - Serverless tasks use Snowflake-managed compute; user-managed tasks require specifying a warehouse.

**Q12: B** - This represents the new state of an updated row (INSERT with ISUPDATE=TRUE).

**Q13: D** - PDF is not a supported file format for data loading.

**Q14: B** - Downstream tasks (D, E) are skipped, but parallel tasks (B) continue.

**Q15: B** - Snowpipe load history is retained for 14 days.

**Q16: D** - All three are required: storage integration for authentication, external stage for location, file format for parsing.

**Q17: B** - Streams cannot be created on external tables (they're read-only and external).

**Q18: A** - Snowflake prevents overlapping task executions; the next run is skipped.

**Q19: B** - ON_ERROR defines behavior: CONTINUE (skip errors), SKIP_FILE (skip entire file), ABORT_STATEMENT (stop on error).

**Q20: A** - SHOW_INITIAL_ROWS = TRUE makes the stream show all existing rows as INSERTs initially.

### Domain 2: Performance Optimization

**Q21: A** - Clustering on frequently filtered columns (order_date, region) optimizes query performance.

**Q22: B** - High clustering depth (>10) suggests the table may benefit from reclustering.

**Q23: A** - Search Optimization is ideal for point lookups (WHERE id = 123) on high-cardinality columns.

**Q24: B** - Maximum 4 columns in a clustering key.

**Q25: D** - All reasons can prevent automatic refresh.

**Q26: A** - Materialized views physically store results; regular views execute queries on demand.

**Q27: A** - Spilling to disk indicates the warehouse doesn't have enough memory for the query.

**Q28: B** - Multi-cluster warehouses automatically add clusters to handle high concurrency.

**Q29: D** - Result cache is invalidated after 24 hours OR when underlying data changes.

**Q30: B** - CLUSTER BY organizes micro-partitions to improve query performance on those columns.

**Q31: B** - Running queries complete before the warehouse suspends.

**Q32: B** - Economy mode prioritizes cost savings by keeping clusters running longer before scaling down.

**Q33: B** - Partition pruning is when Snowflake skips scanning irrelevant micro-partitions.

**Q34: B** - Spilling to remote storage indicates significant performance impact; warehouse is too small.

**Q35: B** - Recommended maximum is 3-4 clustering keys for optimal performance.

**Q36: B** - Automatic clustering runs when clustering depth exceeds thresholds.

### Domain 3: Security & Governance

**Q37: A** - Masking policies hide/transform column values; row access policies filter which rows are visible.

**Q38: C** - The email values are masked according to the policy's logic for that role.

**Q39: D** - Enterprise Edition supports up to 90 days of Time Travel.

**Q40: B** - Fail-safe provides 7 days of recovery by Snowflake Support only (not user-accessible).

**Q41: C** - In role hierarchy, parent roles inherit privileges from child roles (SYSADMIN inherits from DATA_ENGINEER).

**Q42: A** - EXECUTE AS CALLER runs the procedure with the caller's privileges (not the owner's).

**Q43: A** - Within Time Travel period (up to 90 days for Enterprise), use UNDROP TABLE.

**Q44: B** - ACCOUNT_USAGE.ACCESS_HISTORY provides detailed access history for compliance.

**Q45: B** - Secure views hide the view definition from unauthorized users.

**Q46: B** - If a role is not handled in the policy, the user sees no rows (secure by default).

**Q47: A** - OWNERSHIP allows full control (including DROP); USAGE allows using the object.

**Q48: B** - Snowflake uses AES-256 encryption for data at rest.

**Q49: B** - Tri-Secret Secure combines customer-managed keys with Snowflake's encryption.

### Domain 4: Monitoring & Troubleshooting

**Q50: A** - ACCOUNT_USAGE has latency (45 min to 3 hours) but longer retention; INFORMATION_SCHEMA is real-time.

**Q51: A** - Query Profile provides detailed execution breakdown to identify bottlenecks.

**Q52: B** - 95% pruning means 95% of partitions were skipped (good!), only 5% scanned.

**Q53: B** - INFORMATION_SCHEMA.TASK_HISTORY() provides detailed error messages for task failures.

**Q54: A** - INFORMATION_SCHEMA retains query history for 7 days.

**Q55: A** - WAREHOUSE_METERING_HISTORY shows credit consumption by warehouse.

**Q56: B** - Spilling to local disk suggests the warehouse is undersized for the query's memory needs.

**Q57: D** - Both QUERY_HISTORY and Query Profile show cache hit information.

**Q58: A** - VALIDATE_PIPE_LOAD provides detailed error information for Snowpipe loads.

**Q59: B** - Resource monitors set credit limits and trigger actions (notify, suspend) when thresholds are reached.

### Domain 5: Advanced Features

**Q60: A** - Stored procedures can contain DML (INSERT, UPDATE, DELETE); UDFs cannot.

**Q61: A** - MEMOIZABLE caches UDF results for identical inputs, improving performance.

**Q62: D** - R is not supported; JavaScript, SQL, and Python are supported.

**Q63: B** - UDTFs return tables (multiple rows/columns) instead of scalar values.

**Q64: B** - Lazy evaluation queues operations and executes only when results are needed (e.g., .collect()).

**Q65: B** - Snowpark enables complex transformations using familiar programming languages (Python/Scala) with DataFrame API.

---

## Scoring

**Calculate your score:**

Total Correct: _____ / 65  
Percentage: _____ %  
Result: _____ (Pass = 70%+, Fail = <70%)

---

## Performance Analysis

### By Domain

| Domain | Questions | Your Score | % | Status |
|--------|-----------|------------|---|--------|
| Data Movement | 1-20 (20) | ___ | ___ | ___ |
| Performance | 21-36 (16) | ___ | ___ | ___ |
| Security | 37-49 (13) | ___ | ___ | ___ |
| Monitoring | 50-59 (10) | ___ | ___ | ___ |
| Advanced | 60-65 (6) | ___ | ___ | ___ |

### Weak Areas

List question numbers you got wrong:
_________________________________

### Topics to Review

Based on wrong answers, which topics need more study?
1. _________________________________
2. _________________________________
3. _________________________________

---

## Next Steps

### If You Passed (70%+)
- ✅ Great job! You're on track
- Review incorrect answers to understand why
- Focus on weak domains before Practice Exam 2
- Maintain confidence and momentum

### If You Scored 60-69%
- 🟡 You're close! More review needed
- Spend extra time on weak domains
- Redo hands-on exercises for those topics
- Review Days 1-25 systematically
- Take Practice Exam 2 after review

### If You Scored Below 60%
- 🔴 More preparation needed
- Don't be discouraged - this is a learning opportunity
- Review all Days 1-25 thoroughly
- Focus on hands-on practice
- Consider extending study time by 1-2 weeks
- Join study groups or watch tutorial videos

---

## Study Plan Template

Based on your results, create a focused study plan:

**Weak Area #1:** _________________  
**Review:** Day ___ materials  
**Practice:** Exercises from Day ___  
**Time:** ___ hours  

**Weak Area #2:** _________________  
**Review:** Day ___ materials  
**Practice:** Exercises from Day ___  
**Time:** ___ hours  

**Weak Area #3:** _________________  
**Review:** Day ___ materials  
**Practice:** Exercises from Day ___  
**Time:** ___ hours  

---

## Confidence Check

Rate your confidence (1-5) after this exam:

- Data Movement: ___/5
- Performance Optimization: ___/5
- Security & Governance: ___/5
- Monitoring & Troubleshooting: ___/5
- Advanced Features: ___/5

**Overall Confidence:** ___/5

---

**Congratulations on completing Practice Exam 1!**

Use this as a learning tool to identify and strengthen weak areas. You have 3 more days to prepare before the real exam.

**You've got this!** 💪

