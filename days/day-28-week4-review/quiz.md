# Day 28: Comprehensive Review Quiz

## Quiz Instructions

**Time Limit: 30 minutes**  
**Questions: 50**  
**Passing Score: 70% (35/50 correct)**  
**Format: Multiple choice (A, B, C, D)**

This comprehensive review covers all major topics from the bootcamp. Focus on understanding concepts rather than speed.

---

## Questions

### Data Movement (Questions 1-12)

**Question 1**  
What is the primary advantage of Snowpipe over scheduled COPY commands?

A) Snowpipe is cheaper  
B) Snowpipe loads data continuously as files arrive  
C) Snowpipe can transform data during load  
D) Snowpipe uses larger warehouses

**Question 2**  
A stream shows METADATA$ACTION = 'INSERT' and METADATA$ISUPDATE = TRUE. What does this represent?

A) A new row insertion  
B) The new state of an updated row  
C) A deleted row  
D) An error

**Question 3**  
What is the minimum schedule interval for a Snowflake task?

A) 30 seconds  
B) 1 minute  
C) 5 minutes  
D) 15 minutes

**Question 4**  
Which statement about streams is TRUE?

A) Streams physically store change data  
B) Streams track changes using hidden metadata columns  
C) Streams can only track INSERT operations  
D) Streams require a separate warehouse

**Question 5**  
A task is configured with `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')`. What is the benefit?

A) The task runs faster  
B) The task only runs when the stream contains data, saving costs  
C) The task automatically creates the stream  
D) The task processes data in parallel

**Question 6**  
What happens to stream data after it's consumed in a DML transaction?

A) The stream is dropped  
B) The stream offset advances and consumed data is no longer visible  
C) The stream data remains unchanged  
D) The stream is locked

**Question 7**  
Which file format is NOT supported by Snowflake?

A) JSON  
B) Parquet  
C) Avro  
D) PDF

**Question 8**  
What is the retention period for Snowpipe load history?

A) 7 days  
B) 14 days  
C) 30 days  
D) 90 days

**Question 9**  
A task DAG has Task A (root) and Task B (after A). Task A fails. What happens to Task B?

A) Task B runs anyway  
B) Task B is skipped  
C) Task B retries automatically  
D) Both tasks restart

**Question 10**  
What does SHOW_INITIAL_ROWS = TRUE do when creating a stream?

A) Shows only the first 1000 rows  
B) Shows all existing table rows as INSERT operations initially  
C) Limits stream size  
D) Enables row numbering

**Question 11**  
Which compute resource does Snowpipe use?

A) User-specified warehouse  
B) Snowflake-managed serverless compute  
C) The largest available warehouse  
D) No compute resources

**Question 12**  
What is the difference between Standard and Append-Only streams?

A) Standard tracks all DML, Append-Only only tracks INSERTs  
B) Append-Only is faster  
C) Standard is more expensive  
D) There is no difference

---

### Performance Optimization (Questions 13-22)

**Question 13**  
What is the maximum number of columns in a clustering key?

A) 1  
B) 2  
C) 4  
D) 8

**Question 14**  
A clustering depth of 15 indicates:

A) The table is well-clustered  
B) The table may benefit from reclustering  
C) The table has 15 partitions  
D) Clustering is disabled

**Question 15**  
When should you use Search Optimization Service?

A) For full table scans  
B) For point lookups on high-cardinality columns  
C) For aggregation queries  
D) For small tables

**Question 16**  
What is the primary difference between materialized views and regular views?

A) Materialized views store results physically, regular views execute on demand  
B) Regular views are faster  
C) Materialized views cannot be queried  
D) There is no difference

**Question 17**  
Query result caching is invalidated when:

A) 24 hours pass  
B) Underlying data changes  
C) A different user runs the query  
D) Both A and B

**Question 18**  
What does "Bytes spilled to local disk" in a query profile indicate?

A) Good performance  
B) Warehouse may be undersized  
C) Data is being cached  
D) Query is optimized

**Question 19**  
What is the maximum number of clusters in a multi-cluster warehouse?

A) 5  
B) 10  
C) 20  
D) Unlimited

**Question 20**  
Which scaling policy prioritizes cost savings?

A) Standard  
B) Economy  
C) Performance  
D) Balanced

**Question 21**  
What is partition pruning?

A) Deleting old partitions  
B) Snowflake skipping irrelevant micro-partitions during query execution  
C) Compressing partitions  
D) Reorganizing partitions

**Question 22**  
A warehouse is set to auto-suspend after 60 seconds. When does the timer start?

A) When the warehouse is created  
B) When the last query completes  
C) When the first query starts  
D) At midnight

---

### Security & Governance (Questions 23-34)

**Question 23**  
What is the difference between masking policies and row access policies?

A) Masking hides column values, row access filters rows  
B) Masking filters rows, row access hides columns  
C) They are the same  
D) Masking is for tables, row access is for views

**Question 24**  
What is the maximum Time Travel retention for Enterprise Edition?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days

**Question 25**  
Which statement about Fail-safe is TRUE?

A) Users can recover data using Time Travel  
B) Fail-safe provides 7 days of recovery by Snowflake Support only  
C) Fail-safe is free  
D) Fail-safe can be disabled

**Question 26**  
What does EXECUTE AS CALLER mean for a stored procedure?

A) The procedure runs with the caller's privileges  
B) The procedure runs with the owner's privileges  
C) The procedure runs with SYSADMIN privileges  
D) The procedure runs without privilege checks

**Question 27**  
A table was dropped 5 days ago. Time Travel retention is 7 days. How can it be recovered?

A) UNDROP TABLE  
B) Contact Snowflake Support  
C) Restore from backup  
D) Cannot be recovered

**Question 28**  
What encryption does Snowflake use for data at rest?

A) AES-128  
B) AES-256  
C) RSA-2048  
D) Triple DES

**Question 29**  
In a role hierarchy ROLE_A > ROLE_B > ROLE_C, if ROLE_C has SELECT privilege, which roles can query?

A) Only ROLE_C  
B) ROLE_C and ROLE_B  
C) All three roles  
D) Only ROLE_A

**Question 30**  
What is the purpose of a secure view?

A) To encrypt view data  
B) To hide the view definition from unauthorized users  
C) To improve performance  
D) To enable Time Travel

**Question 31**  
What is Tri-Secret Secure?

A) Three-factor authentication  
B) Customer-managed encryption keys combined with Snowflake's encryption  
C) Three-copy backup strategy  
D) Three-role security model

**Question 32**  
A row access policy returns FALSE for all conditions. What happens?

A) All users see all rows  
B) No users can see any rows  
C) The policy is ignored  
D) The query fails

**Question 33**  
What is the purpose of future grants?

A) To grant privileges on objects that will be created in the future  
B) To schedule grants for a future date  
C) To grant privileges that expire  
D) To grant to future users

**Question 34**  
Which view provides detailed access history for compliance?

A) INFORMATION_SCHEMA.ACCESS_HISTORY  
B) ACCOUNT_USAGE.ACCESS_HISTORY  
C) SNOWFLAKE.ACCESS_LOG  
D) INFORMATION_SCHEMA.QUERY_HISTORY

---

### Monitoring & Troubleshooting (Questions 35-42)

**Question 35**  
What is the primary difference between ACCOUNT_USAGE and INFORMATION_SCHEMA?

A) ACCOUNT_USAGE has latency, INFORMATION_SCHEMA is real-time  
B) INFORMATION_SCHEMA has latency, ACCOUNT_USAGE is real-time  
C) They contain different data  
D) No difference

**Question 36**  
What is the latency for ACCOUNT_USAGE views?

A) Real-time  
B) 5-15 minutes  
C) 45 minutes to 3 hours  
D) 24 hours

**Question 37**  
A query is slow. Which tool should you use first?

A) Query Profile  
B) EXPLAIN plan  
C) ACCOUNT_USAGE.QUERY_HISTORY  
D) Warehouse metrics

**Question 38**  
What does "Partition pruning: 95%" mean?

A) 95% of partitions were scanned  
B) 95% of partitions were skipped (good!)  
C) The query failed  
D) 95% of data was deleted

**Question 39**  
What is the retention period for query history in INFORMATION_SCHEMA?

A) 7 days  
B) 14 days  
C) 30 days  
D) 365 days

**Question 40**  
Which view shows warehouse credit consumption?

A) ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY  
B) INFORMATION_SCHEMA.WAREHOUSE_USAGE  
C) SNOWFLAKE.WAREHOUSE_METRICS  
D) ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY

**Question 41**  
What is the purpose of a resource monitor?

A) To monitor query performance  
B) To set credit limits and trigger actions when thresholds are reached  
C) To monitor warehouse availability  
D) To track user activity

**Question 42**  
A task fails. Where should you look for error details?

A) SHOW TASKS  
B) INFORMATION_SCHEMA.TASK_HISTORY()  
C) ACCOUNT_USAGE.TASK_HISTORY  
D) Query history

---

### Advanced Features (Questions 43-50)

**Question 43**  
What is the primary difference between stored procedures and UDFs?

A) Stored procedures can contain DML, UDFs cannot  
B) UDFs can contain DML, stored procedures cannot  
C) They are the same  
D) Stored procedures are faster

**Question 44**  
What does the MEMOIZABLE keyword do for a UDF?

A) Caches UDF results for identical inputs  
B) Uses less memory  
C) Runs faster  
D) Allows DML operations

**Question 45**  
Which language is NOT supported for Snowflake stored procedures?

A) JavaScript  
B) SQL  
C) Python  
D) R

**Question 46**  
What is a UDTF?

A) A function that returns a single value  
B) A function that returns a table (multiple rows/columns)  
C) A function that creates tables  
D) A function that updates tables

**Question 47**  
In Snowpark, what is lazy evaluation?

A) Operations execute immediately  
B) Operations are queued and executed only when results are needed  
C) Operations execute slowly  
D) Operations are skipped

**Question 48**  
What triggers execution in Snowpark?

A) Calling .collect() or .show()  
B) Creating a DataFrame  
C) Calling .filter()  
D) Operations execute immediately

**Question 49**  
Which statement about external tables is TRUE?

A) External tables store data in Snowflake  
B) External tables are read-only and query data in cloud storage  
C) External tables support DML operations  
D) External tables are faster than regular tables

**Question 50**  
What is the primary benefit of Snowpark over SQL?

A) Snowpark is faster  
B) Snowpark allows complex transformations using Python/Scala with DataFrame API  
C) Snowpark is cheaper  
D) Snowpark doesn't require a warehouse

---

## Answer Key

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 1  | B      | 14 | B      | 27 | A      | 40 | A      |
| 2  | B      | 15 | B      | 28 | B      | 41 | B      |
| 3  | B      | 16 | A      | 29 | C      | 42 | B      |
| 4  | B      | 17 | D      | 30 | B      | 43 | A      |
| 5  | B      | 18 | B      | 31 | B      | 44 | A      |
| 6  | B      | 19 | B      | 32 | B      | 45 | D      |
| 7  | D      | 20 | B      | 33 | A      | 46 | B      |
| 8  | B      | 21 | B      | 34 | B      | 47 | B      |
| 9  | B      | 22 | B      | 35 | A      | 48 | A      |
| 10 | B      | 23 | A      | 36 | C      | 49 | B      |
| 11 | B      | 24 | D      | 37 | A      | 50 | B      |
| 12 | A      | 25 | B      | 38 | B      |    |        |
| 13 | C      | 26 | A      | 39 | A      |    |        |

---

## Scoring

**Calculate your score:**

Total Correct: _____ / 50  
Percentage: _____ %  
Result: _____ (Pass = 70%+)

---

## Performance by Topic

| Topic | Questions | Your Score | % |
|-------|-----------|------------|---|
| Data Movement | 1-12 (12) | ___ | ___ |
| Performance | 13-22 (10) | ___ | ___ |
| Security | 23-34 (12) | ___ | ___ |
| Monitoring | 35-42 (8) | ___ | ___ |
| Advanced | 43-50 (8) | ___ | ___ |

---

## Review Recommendations

### If you scored 90-100% (45-50 correct)
- ✅ Excellent! You're very well prepared
- Light review tomorrow
- Stay confident

### If you scored 80-89% (40-44 correct)
- ✅ Very good! Minor review needed
- Review questions you missed
- Focus on weak topics tomorrow

### If you scored 70-79% (35-39 correct)
- 🟡 Good! Some review needed
- Review all incorrect answers
- Spend extra time on weak topics

### If you scored below 70% (<35 correct)
- 🔴 More review needed
- Systematic review of all topics
- Consider extending preparation time

---

## Key Takeaways

### Most Important Concepts
1. **Streams + Tasks**: Core data engineering pattern
2. **Clustering**: Performance optimization strategy
3. **Security Policies**: Masking vs. Row Access
4. **Time Travel vs. Fail-safe**: Data recovery options
5. **Monitoring**: ACCOUNT_USAGE vs. INFORMATION_SCHEMA

### Critical Numbers to Remember
- Time Travel: 0-90 days (Enterprise)
- Fail-safe: 7 days
- Clustering keys: Max 4
- Task schedule: Min 1 minute
- Result cache: 24-hour TTL
- Snowpipe history: 14 days
- Multi-cluster max: 10
- ACCOUNT_USAGE latency: 45 min to 3 hours

---

## Tomorrow's Plan

### Day 29: Final Review & Confidence Builder
- Light review of cheat sheet (1 hour)
- 20 rapid-fire questions
- Relax and stay positive
- Get good sleep

### Day 30: Exam Day
- You're ready!
- Trust your preparation
- Stay calm and confident
- Pass the exam! 🎉

---

**Great job completing the comprehensive review!**

You've covered all major topics and are well-prepared for the certification exam.

**One more day of light review, then exam day!** 💪

