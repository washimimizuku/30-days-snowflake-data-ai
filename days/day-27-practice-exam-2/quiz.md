# Practice Exam 2: SnowPro Advanced Data Engineer

## Exam Instructions

**Time Limit: 115 minutes**  
**Questions: 65**  
**Passing Score: 70% (46/65 correct)**  
**Format: Multiple choice (A, B, C, D)**

**This is your second practice exam. Apply lessons learned from Practice Exam 1!**

**Good luck!** 🍀

---

## Questions

### Domain 1: Data Movement (Questions 1-20)

**Question 1**  
A Snowpipe has loaded 1000 files successfully, but 50 files failed. How can you identify which files failed and why?

A) Query INFORMATION_SCHEMA.LOAD_HISTORY  
B) Use COPY INTO with VALIDATION_MODE = RETURN_ERRORS  
C) Query TABLE(VALIDATE_PIPE_LOAD()) function  
D) Check ACCOUNT_USAGE.COPY_HISTORY

**Question 2**  
What is the difference between a Standard stream and an Append-Only stream?

A) Standard streams are faster than Append-Only streams  
B) Standard streams track all DML, Append-Only streams only track INSERTs  
C) Append-Only streams are cheaper than Standard streams  
D) There is no difference

**Question 3**  
A task DAG has Task A (root), Task B (after A), and Task C (after B). Task B fails. What happens to Task C?

A) Task C runs anyway  
B) Task C is skipped  
C) Task C retries automatically  
D) The entire DAG restarts

**Question 4**  
Which statement about Snowpipe REST API is TRUE?

A) It requires S3 event notifications  
B) It allows manual triggering of Snowpipe from external applications  
C) It is slower than auto-ingest  
D) It does not support error handling

**Question 5**  
A stream on a table shows no data even though the table has been updated. What could be the reason?

A) The stream was not created with SHOW_INITIAL_ROWS = TRUE  
B) The stream data was already consumed in a previous transaction  
C) The table is too large for streams  
D) Streams don't work on updated data

**Question 6**  
What is the purpose of the SYSTEM$STREAM_GET_TABLE_TIMESTAMP function?

A) To get the current timestamp  
B) To get the timestamp of the stream's current offset  
C) To set the stream's timestamp  
D) To delete old stream data

**Question 7**  
A task is configured with ALLOW_OVERLAPPING_EXECUTION = TRUE. What does this mean?

A) Multiple instances of the task can run concurrently  
B) The task can overlap with other tasks  
C) The task schedule can be changed while running  
D) The task can run on multiple warehouses

**Question 8**  
Which file format supports schema evolution (adding/removing columns) without redefining the table?

A) CSV  
B) JSON  
C) Parquet  
D) All of the above

**Question 9**  
A stream is created with AT/BEFORE clause. What does this accomplish?

A) The stream starts tracking changes from a specific point in time  
B) The stream only tracks changes before a certain time  
C) The stream is read-only  
D) The stream has a time limit

**Question 10**  
What happens when a Snowpipe encounters a file that was already loaded?

A) The file is loaded again, creating duplicates  
B) Snowpipe skips the file automatically  
C) Snowpipe fails with an error  
D) The file is loaded into a separate table

**Question 11**  
Which task parameter specifies the warehouse to use for serverless tasks?

A) WAREHOUSE = 'warehouse_name'  
B) USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE  
C) Serverless tasks don't need a warehouse parameter  
D) COMPUTE_POOL

**Question 12**  
A stream shows METADATA$ACTION = 'DELETE' and METADATA$ISUPDATE = TRUE. What does this represent?

A) A row was deleted  
B) The old state of an updated row  
C) A duplicate row  
D) An error in the stream

**Question 13**  
What is the maximum size of a single file that can be loaded using COPY INTO?

A) 100 MB  
B) 1 GB  
C) 5 GB  
D) There is no hard limit, but 100-250 MB is recommended

**Question 14**  
A task tree has 10 tasks. How can you execute the entire tree manually for testing?

A) EXECUTE TASK root_task (executes entire tree)  
B) Execute each task individually  
C) Use SYSTEM$EXECUTE_TASK_TREE()  
D) Tasks cannot be executed manually

**Question 15**  
What is the retention period for stream data?

A) 7 days  
B) 14 days  
C) Same as the table's Time Travel retention  
D) Unlimited

**Question 16**  
Which integration is required to use Snowpipe with auto-ingest from AWS S3?

A) STORAGE INTEGRATION only  
B) NOTIFICATION INTEGRATION only  
C) Both STORAGE and NOTIFICATION integrations  
D) No integration is required

**Question 17**  
A stream is created on a view. What limitation applies?

A) Streams cannot be created on views  
B) The view must be a materialized view  
C) The stream will only track INSERT operations  
D) The stream requires SHOW_INITIAL_ROWS = TRUE

**Question 18**  
What is the minimum schedule interval for a task?

A) 30 seconds  
B) 1 minute  
C) 5 minutes  
D) 15 minutes

**Question 19**  
Which COPY option prevents loading duplicate data based on file name?

A) ON_ERROR = 'SKIP_FILE'  
B) FORCE = FALSE  
C) PURGE = TRUE  
D) LOAD_UNCERTAIN_FILES = FALSE

**Question 20**  
A task fails with "Insufficient privileges" error. What should you check?

A) The task owner's role privileges  
B) The warehouse size  
C) The task schedule  
D) The stream data

---

### Domain 2: Performance Optimization (Questions 21-36)

**Question 21**  
A table has columns: id (low cardinality), timestamp (high cardinality), category (medium cardinality). Which clustering key is most effective?

A) CLUSTER BY (id)  
B) CLUSTER BY (timestamp)  
C) CLUSTER BY (category, timestamp)  
D) CLUSTER BY (id, category, timestamp)

**Question 22**  
What does SYSTEM$CLUSTERING_DEPTH return?

A) The number of micro-partitions  
B) The average depth of overlapping micro-partitions for clustered columns  
C) The size of the table in GB  
D) The number of clustering keys

**Question 23**  
When should you use Search Optimization Service instead of clustering?

A) For large tables with full table scans  
B) For point lookups on high-cardinality columns (WHERE id = 123)  
C) For aggregation queries  
D) For small tables

**Question 24**  
A materialized view is not refreshing. Which command forces a manual refresh?

A) REFRESH MATERIALIZED VIEW view_name  
B) ALTER MATERIALIZED VIEW view_name REFRESH  
C) Materialized views cannot be manually refreshed  
D) DROP and recreate the view

**Question 25**  
What is the cost trade-off of using materialized views?

A) Storage cost for storing results vs. compute cost for repeated queries  
B) Materialized views are always cheaper  
C) Materialized views are always more expensive  
D) There is no cost difference

**Question 26**  
A query profile shows "Bytes spilled to local disk: 10 GB". What action should you take?

A) Increase warehouse size  
B) Add clustering keys  
C) Use a materialized view  
D) Reduce the result set

**Question 27**  
What is the purpose of a multi-cluster warehouse's MIN_CLUSTER_COUNT parameter?

A) The minimum number of clusters that must always be running  
B) The minimum size of each cluster  
C) The minimum number of queries before scaling  
D) The minimum number of users

**Question 28**  
Query result caching requires:

A) Exact query text match and no underlying data changes  
B) Same user running the query  
C) Same warehouse  
D) Query executed within 1 hour

**Question 29**  
What is the maximum number of clusters in a multi-cluster warehouse?

A) 5  
B) 10  
C) 20  
D) Unlimited

**Question 30**  
A table has 10 billion rows. Queries filter on date_column. What optimization provides the best performance improvement?

A) Create a clustering key on date_column  
B) Partition the table by date  
C) Create an index on date_column  
D) Use a larger warehouse

**Question 31**  
What does "Partition pruning: 5%" mean in a query profile?

A) 5% of partitions were scanned (good!)  
B) 95% of partitions were scanned (bad!)  
C) The query failed 5% of the time  
D) 5% of data was pruned

**Question 32**  
Which scaling policy keeps clusters running longer to reduce startup time?

A) Standard  
B) Economy  
C) Performance  
D) Balanced

**Question 33**  
A warehouse is set to auto-suspend after 300 seconds. When does the timer start?

A) When the warehouse is created  
B) When the last query completes  
C) When the first query starts  
D) At midnight each day

**Question 34**  
What is the recommended approach for optimizing a query that scans 1 TB but returns 10 rows?

A) Increase warehouse size  
B) Add clustering or filtering to reduce scanned data  
C) Use result caching  
D) Use a smaller warehouse

**Question 35**  
Which statement about automatic clustering is FALSE?

A) It consumes credits  
B) It runs automatically when clustering depth degrades  
C) It can be disabled  
D) It requires manual triggering

**Question 36**  
A materialized view depends on 3 base tables. One table is updated. What happens?

A) The materialized view is automatically refreshed  
B) The materialized view becomes stale until manually refreshed  
C) The materialized view is dropped  
D) The update fails

---

### Domain 3: Security & Governance (Questions 37-49)

**Question 37**  
A masking policy is applied to a column. A user with ACCOUNTADMIN role queries the table. What happens?

A) The data is always masked  
B) The data is visible based on the policy logic  
C) The query fails  
D) ACCOUNTADMIN always sees unmasked data

**Question 38**  
What is the difference between EXECUTE AS CALLER and EXECUTE AS OWNER for stored procedures?

A) CALLER uses the caller's privileges, OWNER uses the owner's privileges  
B) CALLER is faster than OWNER  
C) OWNER is more secure than CALLER  
D) There is no difference

**Question 39**  
A table has Time Travel retention set to 30 days. After 35 days, can the data be recovered?

A) Yes, using Time Travel  
B) Yes, using Fail-safe (contact Snowflake Support)  
C) No, the data is permanently deleted  
D) Yes, using UNDROP

**Question 40**  
Which view provides the most detailed information about user queries for security auditing?

A) INFORMATION_SCHEMA.QUERY_HISTORY  
B) ACCOUNT_USAGE.QUERY_HISTORY  
C) ACCOUNT_USAGE.ACCESS_HISTORY  
D) INFORMATION_SCHEMA.ACCESS_LOG

**Question 41**  
A row access policy returns FALSE for all conditions. What happens?

A) All users see all rows  
B) No users can see any rows  
C) The policy is ignored  
D) The query fails

**Question 42**  
What is the purpose of a secure UDF?

A) To encrypt the UDF code  
B) To hide the UDF definition from unauthorized users  
C) To make the UDF run faster  
D) To allow the UDF to access secure data

**Question 43**  
A role hierarchy is: ROLE_A > ROLE_B > ROLE_C. ROLE_C has SELECT on a table. Which roles can query the table?

A) Only ROLE_C  
B) ROLE_C and ROLE_B  
C) All three roles  
D) Only ROLE_A

**Question 44**  
What is the maximum Fail-safe period?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days

**Question 45**  
Which command shows all masking policies applied to tables in a schema?

A) SHOW MASKING POLICIES  
B) DESCRIBE SCHEMA  
C) SELECT * FROM INFORMATION_SCHEMA.POLICY_REFERENCES  
D) Both A and C

**Question 46**  
A secure view is created. What is hidden from users without ownership?

A) The view data  
B) The view definition (SQL code)  
C) The view name  
D) Nothing is hidden

**Question 47**  
What is the purpose of future grants?

A) To grant privileges on objects that will be created in the future  
B) To schedule privilege grants for a future date  
C) To grant privileges that expire in the future  
D) To grant privileges to future users

**Question 48**  
Which encryption key management option provides the highest level of customer control?

A) Snowflake-managed keys  
B) Tri-Secret Secure  
C) Customer-managed keys in AWS KMS  
D) Both B and C

**Question 49**  
A table was dropped 10 days ago. Time Travel retention is 7 days. Can it be recovered?

A) Yes, using UNDROP  
B) Yes, using Time Travel  
C) Yes, using Fail-safe (contact Support)  
D) No, it's permanently deleted

---

### Domain 4: Monitoring & Troubleshooting (Questions 50-59)

**Question 50**  
What is the latency for data in ACCOUNT_USAGE views?

A) Real-time  
B) 5-15 minutes  
C) 45 minutes to 3 hours  
D) 24 hours

**Question 51**  
A query is slow. The query profile shows "Bytes spilled to remote storage: 50 GB". What is the primary issue?

A) Network latency  
B) Warehouse is significantly undersized  
C) Table needs clustering  
D) Too many joins

**Question 52**  
Which view shows credit consumption by warehouse over time?

A) ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY  
B) INFORMATION_SCHEMA.WAREHOUSE_USAGE  
C) ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY  
D) INFORMATION_SCHEMA.WAREHOUSE_METRICS

**Question 53**  
A task is in SUSPENDED state. What command resumes it?

A) RESUME TASK task_name  
B) ALTER TASK task_name RESUME  
C) START TASK task_name  
D) EXECUTE TASK task_name

**Question 54**  
What is the retention period for query history in ACCOUNT_USAGE?

A) 7 days  
B) 30 days  
C) 90 days  
D) 365 days

**Question 55**  
A query shows "Partition pruning: 0%". What does this indicate?

A) Excellent performance  
B) All micro-partitions were scanned (poor performance)  
C) The query failed  
D) Clustering is working well

**Question 56**  
Which function returns the query ID of the last query executed in the session?

A) LAST_QUERY_ID()  
B) CURRENT_QUERY_ID()  
C) GET_QUERY_ID()  
D) SYSTEM$LAST_QUERY_ID()

**Question 57**  
A resource monitor is set to SUSPEND at 100% of quota. What happens when the threshold is reached?

A) All warehouses are immediately suspended  
B) Running queries complete, then warehouses are suspended  
C) A notification is sent but warehouses continue running  
D) New queries are queued

**Question 58**  
How can you identify queries that are not using result cache?

A) Query QUERY_HISTORY where RESULT_CACHE_HIT = FALSE  
B) Check the query profile  
C) Use EXPLAIN plan  
D) Both A and B

**Question 59**  
A Snowpipe is not loading files. Which system function provides the most detailed status?

A) SYSTEM$PIPE_STATUS('pipe_name')  
B) SHOW PIPES  
C) GET_PIPE_STATUS('pipe_name')  
D) DESCRIBE PIPE pipe_name

---

### Domain 5: Advanced Features (Questions 60-65)

**Question 60**  
What is the primary limitation of UDFs compared to stored procedures?

A) UDFs cannot return values  
B) UDFs cannot contain DML statements (INSERT, UPDATE, DELETE)  
C) UDFs are slower  
D) UDFs cannot accept parameters

**Question 61**  
A UDF is created with MEMOIZABLE. When is the cached result used?

A) For identical input values within the same query  
B) For all queries in the session  
C) For all users  
D) For 24 hours

**Question 62**  
Which language is supported for Snowflake UDFs but NOT for stored procedures?

A) JavaScript  
B) Java  
C) Python  
D) All languages support both

**Question 63**  
What is the return type of a UDTF (User-Defined Table Function)?

A) A single scalar value  
B) A table (multiple rows and columns)  
C) A JSON object  
D) An array

**Question 64**  
In Snowpark, what triggers actual execution of queued operations?

A) Calling .collect() or .show()  
B) Creating a DataFrame  
C) Calling .filter() or .select()  
D) Operations execute immediately

**Question 65**  
What is the primary advantage of using Snowpark stored procedures over SQL stored procedures?

A) Snowpark is faster  
B) Snowpark allows complex logic using Python/Scala with full programming capabilities  
C) Snowpark is cheaper  
D) Snowpark doesn't require a warehouse

---

## Answer Key

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 1  | C      | 18 | B      | 35 | D      | 52 | A      |
| 2  | B      | 19 | B      | 36 | A      | 53 | B      |
| 3  | B      | 20 | A      | 37 | B      | 54 | D      |
| 4  | B      | 21 | C      | 38 | A      | 55 | B      |
| 5  | B      | 22 | B      | 39 | B      | 56 | A      |
| 6  | B      | 23 | B      | 40 | C      | 57 | B      |
| 7  | A      | 24 | C      | 41 | B      | 58 | D      |
| 8  | B      | 25 | A      | 42 | B      | 59 | A      |
| 9  | A      | 26 | A      | 43 | C      | 60 | B      |
| 10 | B      | 27 | A      | 44 | B      | 61 | A      |
| 11 | C      | 28 | A      | 45 | D      | 62 | B      |
| 12 | B      | 29 | B      | 46 | B      | 63 | B      |
| 13 | D      | 30 | A      | 47 | A      | 64 | A      |
| 14 | A      | 31 | A      | 48 | D      | 65 | B      |
| 15 | C      | 32 | A      | 49 | C      |    |        |
| 16 | A      | 33 | B      | 50 | C      |    |        |
| 17 | B      | 34 | B      | 51 | B      |    |        |

---

## Scoring

**Calculate your score:**

Total Correct: _____ / 65  
Percentage: _____ %  
Result: _____ (Pass = 70%+, Fail = <70%)

**Compare to Practice Exam 1:**

Practice Exam 1 Score: _____ %  
Practice Exam 2 Score: _____ %  
Improvement: _____ %

---

## Performance Analysis

### By Domain

| Domain | Exam 1 | Exam 2 | Change | Status |
|--------|--------|--------|--------|--------|
| Data Movement (20) | ___ | ___ | ___ | ___ |
| Performance (16) | ___ | ___ | ___ | ___ |
| Security (13) | ___ | ___ | ___ | ___ |
| Monitoring (10) | ___ | ___ | ___ | ___ |
| Advanced (6) | ___ | ___ | ___ | ___ |

### Overall Assessment

**Strengths (80%+ in domain):**
- _____________________
- _____________________

**Areas for improvement (<70% in domain):**
- _____________________
- _____________________

---

## Readiness Assessment

### Scoring Interpretation

**85-100% (55-65 correct):**
- ✅ **Excellent!** You're very well prepared
- Schedule your exam with confidence
- Do light review tomorrow
- You're ready to pass!

**70-84% (46-54 correct):**
- ✅ **Good!** You're ready to pass
- Review weak areas tomorrow
- Stay confident
- You can do this!

**60-69% (39-45 correct):**
- 🟡 **Almost there!** More review needed
- Focus on weak domains tomorrow
- Consider 1 more week of study
- You're close to passing

**Below 60% (<39 correct):**
- 🔴 **More preparation needed**
- Systematic review of all topics
- Extend study time by 1-2 weeks
- Focus on hands-on practice
- Retake practice exams

---

## Final Preparation Checklist

### Tomorrow (Day 28): Comprehensive Review
- [ ] Review all weak areas identified
- [ ] Take 50-question review quiz
- [ ] Create final cheat sheet
- [ ] Review key concepts and limitations

### Day 29: Final Review
- [ ] Light review of cheat sheet
- [ ] Stay relaxed and confident
- [ ] Get good sleep
- [ ] Prepare exam environment

### Day 30: Exam Day
- [ ] Arrive 15 minutes early
- [ ] Stay calm
- [ ] Trust your preparation
- [ ] Pass the exam!

---

## Key Concepts to Remember

### Critical Facts
- **Time Travel**: 0-90 days (Enterprise), 0-1 day (Standard)
- **Fail-safe**: 7 days, Snowflake Support only
- **Clustering Keys**: Maximum 4 columns
- **Task Frequency**: Minimum 1 minute
- **Result Cache**: 24-hour TTL
- **Snowpipe History**: 14 days
- **Multi-cluster**: Maximum 10 clusters

### Common Confusions
- **Streams vs. Dynamic Tables**: Streams = CDC, Dynamic Tables = Materialized
- **Masking vs. Row Access**: Masking = columns, Row Access = rows
- **CALLER vs. OWNER**: CALLER = caller's privileges, OWNER = owner's privileges
- **Standard vs. Economy**: Standard = faster scaling, Economy = cost savings
- **ACCOUNT_USAGE vs. INFORMATION_SCHEMA**: ACCOUNT_USAGE = latency + history, INFORMATION_SCHEMA = real-time

---

**Congratulations on completing Practice Exam 2!**

You've now taken 2 full practice exams and have a clear picture of your readiness. Use the next 2 days to fine-tune your preparation and build confidence.

**You're ready for this!** 💪

