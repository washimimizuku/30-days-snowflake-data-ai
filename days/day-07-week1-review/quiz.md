# Day 7 Quiz: Week 1 Comprehensive Review

## Instructions
This is a comprehensive review quiz covering all Week 1 topics. Choose the best answer for each question. Answers are provided at the end.

**Time**: 30 minutes  
**Questions**: 50  
**Passing Score**: 35/50 (70%)

---

## Section 1: Snowpipe (Questions 1-10)

### 1. What is the primary advantage of Snowpipe over the COPY command?

A) Snowpipe is faster for large batch loads  
B) Snowpipe provides continuous, serverless data loading  
C) Snowpipe is cheaper for one-time loads  
D) Snowpipe supports more file formats  

**Your answer:**

---

### 2. Which AWS service is used for Snowpipe auto-ingest notifications?

A) Lambda and API Gateway  
B) SQS and SNS  
C) Kinesis and DynamoDB  
D) CloudWatch and EventBridge  

**Your answer:**

---

### 3. What is the optimal compressed file size for Snowpipe?

A) 1-10 MB  
B) 10-50 MB  
C) 100-250 MB  
D) 500-1000 MB  

**Your answer:**

---

### 4. How does Snowpipe prevent duplicate file loads?

A) By checking file checksums  
B) By tracking loaded file names  
C) By comparing file timestamps  
D) By validating file content  

**Your answer:**

---

### 5. What is the typical latency for Snowpipe auto-ingest?

A) Seconds (< 30 seconds)  
B) Minutes (1-2 minutes)  
C) Hours (1-2 hours)  
D) Real-time (< 1 second)  

**Your answer:**

---

### 6. Which function checks the status of a Snowpipe?

A) SHOW_PIPE_STATUS('pipe_name')  
B) GET_PIPE_STATUS('pipe_name')  
C) SYSTEM$PIPE_STATUS('pipe_name')  
D) CHECK_PIPE('pipe_name')  

**Your answer:**

---

### 7. Does Snowpipe require a virtual warehouse?

A) Yes, you must specify a warehouse  
B) Yes, but only for initial setup  
C) No, it uses serverless compute  
D) Only for files larger than 1 GB  

**Your answer:**

---

### 8. How is Snowpipe billed?

A) Fixed monthly fee per pipe  
B) Per file loaded  
C) Per-second of compute used  
D) Per hour like warehouses  

**Your answer:**

---

### 9. What happens if a file has errors during Snowpipe loading?

A) Snowpipe stops and waits for intervention  
B) The entire batch is rolled back  
C) Snowpipe skips the file and continues  
D) The file is automatically retried every 5 minutes  

**Your answer:**

---

### 10. How can you pause a Snowpipe?

A) DROP the pipe and recreate it  
B) ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE  
C) SUSPEND PIPE pipe_name  
D) Pipes cannot be paused  

**Your answer:**

---

## Section 2: Streams (Questions 11-20)

### 11. What is the primary purpose of Streams in Snowflake?

A) To improve query performance  
B) To track changes (CDC) on tables  
C) To partition large tables  
D) To compress data  

**Your answer:**

---

### 12. Which stream type tracks INSERT, UPDATE, and DELETE operations?

A) Append-Only stream  
B) Insert-Only stream  
C) Standard stream  
D) Change stream  

**Your answer:**

---

### 13. What does METADATA$ACTION column contain?

A) The SQL statement that caused the change  
B) INSERT or DELETE  
C) The user who made the change  
D) The timestamp of the change  

**Your answer:**

---

### 14. When does METADATA$ISUPDATE equal TRUE?

A) For all UPDATE operations  
B) For INSERT operations only  
C) For both INSERT and DELETE rows of an UPDATE  
D) For DELETE operations only  

**Your answer:**

---

### 15. What happens when you query a stream?

A) The stream is automatically consumed  
B) The stream data is deleted  
C) The stream shows changes without consuming  
D) The stream offset is reset  

**Your answer:**

---

### 16. How do you consume a stream?

A) By querying it with SELECT  
B) By using DML (INSERT, UPDATE, DELETE) in a transaction  
C) By calling CONSUME_STREAM()  
D) Streams are automatically consumed  

**Your answer:**

---

### 17. What is stream offset?

A) The time delay in stream processing  
B) The position tracking what changes have been consumed  
C) The number of rows in the stream  
D) The storage location of stream data  

**Your answer:**

---

### 18. How long is stream data retained?

A) 24 hours  
B) 7 days  
C) Based on the table's Time Travel retention  
D) Forever until consumed  

**Your answer:**

---

### 19. Can you create a stream on a view?

A) Yes, on any view  
B) Yes, but only on materialized views  
C) Yes, but only on secure views  
D) No, streams only work on tables  

**Your answer:**

---

### 20. What happens if you don't consume a stream before Time Travel expires?

A) The stream is automatically deleted  
B) The stream becomes stale and must be recreated  
C) The stream continues to work normally  
D) The stream data is archived  

**Your answer:**

---

## Section 3: Tasks (Questions 21-30)

### 21. What are the two types of task compute?

A) Fast and Slow  
B) Serverless and User-managed  
C) Automatic and Manual  
D) Scheduled and Event-driven  

**Your answer:**

---

### 22. What is the maximum number of tasks allowed per account?

A) 100  
B) 500  
C) 1000  
D) Unlimited  

**Your answer:**

---

### 23. How do you schedule a task to run every 5 minutes?

A) SCHEDULE = '5 MINUTE'  
B) SCHEDULE = 'EVERY 5 MINUTES'  
C) SCHEDULE = '5 MINUTES'  
D) SCHEDULE = 'INTERVAL 5 MINUTES'  

**Your answer:**

---

### 24. What does the AFTER clause do in task creation?

A) Specifies when the task should start  
B) Creates a predecessor dependency  
C) Sets the task timeout  
D) Defines the task priority  

**Your answer:**

---

### 25. What is the maximum number of child tasks per parent?

A) 10  
B) 50  
C) 100  
D) 1000  

**Your answer:**

---

### 26. How do you make a task run only when a stream has data?

A) Use WHEN STREAM_HAS_DATA('stream_name')  
B) Use WHEN SYSTEM$STREAM_HAS_DATA('stream_name')  
C) Use IF STREAM_NOT_EMPTY('stream_name')  
D) Use WHEN COUNT(stream_name) > 0  

**Your answer:**

---

### 27. What state must a task be in to execute?

A) ACTIVE  
B) RUNNING  
C) RESUMED  
D) ENABLED  

**Your answer:**

---

### 28. Can a suspended task execute?

A) Yes, if manually triggered  
B) Yes, if a predecessor completes  
C) No, it must be resumed first  
D) Only if it's a serverless task  

**Your answer:**

---

### 29. What happens if a task fails?

A) All dependent tasks are cancelled  
B) The task is automatically retried  
C) The task is suspended  
D) The failure is logged but execution continues  

**Your answer:**

---

### 30. How do you view task execution history?

A) SELECT * FROM TASK_HISTORY  
B) SHOW TASK HISTORY  
C) TABLE(INFORMATION_SCHEMA.TASK_HISTORY())  
D) GET_TASK_HISTORY()  

**Your answer:**

---

## Section 4: Streams + Tasks Integration (Questions 31-35)

### 31. What is the benefit of using SYSTEM$STREAM_HAS_DATA() with tasks?

A) Faster task execution  
B) Prevents unnecessary task runs when stream is empty  
C) Automatically consumes the stream  
D) Improves stream performance  

**Your answer:**

---

### 32. In SCD Type 2, what indicates the current record?

A) end_date IS NULL or end_date = '9999-12-31'  
B) is_current = TRUE  
C) version_number = MAX(version_number)  
D) Both A and B  

**Your answer:**

---

### 33. How do you implement SCD Type 2 with streams?

A) Use MERGE statement only  
B) UPDATE old records, then INSERT new records  
C) Use REPLACE statement  
D) Use UPSERT statement  

**Your answer:**

---

### 34. What happens to a stream after it's consumed in a transaction?

A) The stream is deleted  
B) The stream offset advances  
C) The stream is reset  
D) The stream is suspended  

**Your answer:**

---

### 35. Can multiple tasks consume the same stream?

A) No, only one task per stream  
B) Yes, but they must be in the same transaction  
C) Yes, each task sees the same changes  
D) Only if using serverless tasks  

**Your answer:**

---

## Section 5: Dynamic Tables (Questions 36-45)

### 36. What does TARGET_LAG specify in a dynamic table?

A) The maximum refresh interval  
B) The minimum refresh interval  
C) The average refresh time  
D) The delay before first refresh  

**Your answer:**

---

### 37. How does Snowflake determine when to refresh a dynamic table?

A) Based on TARGET_LAG and data changes  
B) Every hour automatically  
C) Only when manually refreshed  
D) Based on warehouse size  

**Your answer:**

---

### 38. Can dynamic tables perform incremental refresh?

A) No, always full refresh  
B) Yes, when possible based on query structure  
C) Only for simple SELECT statements  
D) Only with clustering keys  

**Your answer:**

---

### 39. What happens if you set TARGET_LAG = 'DOWNSTREAM'?

A) The table never refreshes  
B) The table refreshes based on downstream dependencies  
C) The table refreshes immediately  
D) Invalid syntax  

**Your answer:**

---

### 40. Can you query a dynamic table while it's refreshing?

A) No, queries are blocked  
B) Yes, you see the previous version  
C) Only with special permissions  
D) Only if using a large warehouse  

**Your answer:**

---

### 41. How do you manually refresh a dynamic table?

A) REFRESH DYNAMIC TABLE table_name  
B) ALTER DYNAMIC TABLE table_name REFRESH  
C) CALL REFRESH_TABLE('table_name')  
D) Dynamic tables cannot be manually refreshed  

**Your answer:**

---

### 42. What is the main difference between dynamic tables and materialized views?

A) Dynamic tables are faster  
B) Dynamic tables offer more control over refresh timing  
C) Materialized views support more queries  
D) No significant difference  

**Your answer:**

---

### 43. Can you create indexes on dynamic tables?

A) Yes, any type of index  
B) Yes, but only clustering keys  
C) No, indexes are not supported  
D) Only on primary keys  

**Your answer:**

---

### 44. How are dynamic table refreshes billed?

A) Fixed monthly fee  
B) Based on warehouse compute used  
C) Per refresh operation  
D) No additional cost  

**Your answer:**

---

### 45. Can dynamic tables reference other dynamic tables?

A) No, not allowed  
B) Yes, Snowflake manages dependencies  
C) Only in the same schema  
D) Only with same TARGET_LAG  

**Your answer:**

---

## Section 6: Advanced SQL & Integration (Questions 46-50)

### 46. What does the QUALIFY clause filter?

A) Rows before aggregation  
B) Rows after aggregation  
C) Rows based on window function results  
D) Columns in SELECT  

**Your answer:**

---

### 47. What's the difference between RANK() and DENSE_RANK()?

A) RANK() is faster  
B) RANK() leaves gaps after ties, DENSE_RANK() doesn't  
C) DENSE_RANK() requires ORDER BY  
D) No difference  

**Your answer:**

---

### 48. What does the FLATTEN function do?

A) Removes duplicates  
B) Converts nested arrays/objects into rows  
C) Compresses data  
D) Normalizes numeric values  

**Your answer:**

---

### 49. How do you extract a JSON field in Snowflake?

A) json_data['field']  
B) json_data.field  
C) json_data:field::TYPE  
D) GET_JSON(json_data, 'field')  

**Your answer:**

---

### 50. What is a LATERAL join used for?

A) Joining large tables efficiently  
B) Allowing subqueries to reference preceding tables  
C) Creating cross joins  
D) Optimizing query performance  

**Your answer:**

---

## Answer Key

### Section 1: Snowpipe (1-10)
1. **B** - Snowpipe provides continuous, serverless data loading
2. **B** - SQS and SNS
3. **C** - 100-250 MB
4. **B** - By tracking loaded file names
5. **B** - Minutes (1-2 minutes)
6. **C** - SYSTEM$PIPE_STATUS('pipe_name')
7. **C** - No, it uses serverless compute
8. **C** - Per-second of compute used
9. **C** - Snowpipe skips the file and continues
10. **B** - ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE

### Section 2: Streams (11-20)
11. **B** - To track changes (CDC) on tables
12. **C** - Standard stream
13. **B** - INSERT or DELETE
14. **C** - For both INSERT and DELETE rows of an UPDATE
15. **C** - The stream shows changes without consuming
16. **B** - By using DML in a transaction
17. **B** - The position tracking what changes have been consumed
18. **C** - Based on the table's Time Travel retention
19. **B** - Yes, but only on materialized views
20. **B** - The stream becomes stale and must be recreated

### Section 3: Tasks (21-30)
21. **B** - Serverless and User-managed
22. **C** - 1000
23. **C** - SCHEDULE = '5 MINUTES'
24. **B** - Creates a predecessor dependency
25. **C** - 100
26. **B** - Use WHEN SYSTEM$STREAM_HAS_DATA('stream_name')
27. **C** - RESUMED
28. **C** - No, it must be resumed first
29. **D** - The failure is logged but execution continues
30. **C** - TABLE(INFORMATION_SCHEMA.TASK_HISTORY())

### Section 4: Streams + Tasks (31-35)
31. **B** - Prevents unnecessary task runs when stream is empty
32. **D** - Both A and B
33. **B** - UPDATE old records, then INSERT new records
34. **B** - The stream offset advances
35. **C** - Yes, each task sees the same changes

### Section 5: Dynamic Tables (36-45)
36. **B** - The minimum refresh interval
37. **A** - Based on TARGET_LAG and data changes
38. **B** - Yes, when possible based on query structure
39. **B** - The table refreshes based on downstream dependencies
40. **B** - Yes, you see the previous version
41. **B** - ALTER DYNAMIC TABLE table_name REFRESH
42. **B** - Dynamic tables offer more control over refresh timing
43. **B** - Yes, but only clustering keys
44. **B** - Based on warehouse compute used
45. **B** - Yes, Snowflake manages dependencies

### Section 6: Advanced SQL (46-50)
46. **C** - Rows based on window function results
47. **B** - RANK() leaves gaps after ties, DENSE_RANK() doesn't
48. **B** - Converts nested arrays/objects into rows
49. **C** - json_data:field::TYPE
50. **B** - Allowing subqueries to reference preceding tables

---

## Score Yourself

**Calculate your score**: _____ / 50

### Performance Levels

- **45-50 (90-100%)**: Excellent! You've mastered Week 1 concepts
- **40-44 (80-89%)**: Very Good! Minor review needed
- **35-39 (70-79%)**: Good! Review missed topics before Week 2
- **30-34 (60-69%)**: Fair - Spend extra time reviewing Week 1
- **< 30 (< 60%)**: Review all Week 1 materials before continuing

---

## Topic Breakdown

Review your performance by topic:

**Snowpipe** (Questions 1-10): _____ / 10  
**Streams** (Questions 11-20): _____ / 10  
**Tasks** (Questions 21-30): _____ / 10  
**Streams + Tasks** (Questions 31-35): _____ / 5  
**Dynamic Tables** (Questions 36-45): _____ / 10  
**Advanced SQL** (Questions 46-50): _____ / 5  

### Areas Needing Review

If you scored < 70% in any topic area, review that day's materials:

- Snowpipe < 7: Review Day 1
- Streams < 7: Review Day 2
- Tasks < 7: Review Day 3
- Streams + Tasks < 3: Review Day 4
- Dynamic Tables < 7: Review Day 5
- Advanced SQL < 3: Review Day 6

---

## Key Concepts Summary

### Must Remember for Exam

**Snowpipe**:
- Serverless, continuous loading
- 1-2 minute latency
- Optimal file size: 100-250 MB
- Idempotent (prevents duplicates)
- Billed per-second of compute

**Streams**:
- Standard: INSERT, UPDATE, DELETE
- Append-Only: INSERT only
- METADATA$ACTION: INSERT or DELETE
- METADATA$ISUPDATE: TRUE for UPDATE
- Consumed via DML in transaction

**Tasks**:
- Serverless or user-managed
- Max 1000 per account
- Max 100 children per parent
- SYSTEM$STREAM_HAS_DATA() for conditional execution
- Must be RESUMED to execute

**Dynamic Tables**:
- TARGET_LAG: minimum refresh interval
- Incremental refresh when possible
- Automatic dependency management
- Billed for warehouse compute

**Integration Patterns**:
- Snowpipe → Stream → Task = CDC pipeline
- SCD Type 2: UPDATE old + INSERT new
- Dynamic Tables: declarative transformations
- QUALIFY: filter window function results

---

## Exam Preparation Tips

### Common Question Patterns

1. **When to use X vs Y?**
   - Snowpipe vs COPY
   - Standard vs Append-Only streams
   - Serverless vs User-managed tasks
   - Dynamic Tables vs Materialized Views

2. **How does X work?**
   - Stream consumption
   - Task dependencies
   - SCD Type 2 implementation
   - Dynamic table refresh

3. **What happens when...?**
   - Stream not consumed before Time Travel expires
   - Task fails in a DAG
   - File has errors in Snowpipe
   - Dynamic table is queried during refresh

4. **Best practices for...?**
   - File sizes for Snowpipe
   - Task scheduling frequency
   - TARGET_LAG settings
   - Stream consumption patterns

### Study Recommendations

**If you scored 45-50**: 
- You're ready for Week 2!
- Quick review of any missed questions
- Move forward with confidence

**If you scored 40-44**:
- Review specific topics you missed
- Re-read relevant README sections
- Try the exercises again
- Ready for Week 2 after review

**If you scored 35-39**:
- Spend 1-2 hours reviewing Week 1
- Focus on topics < 70%
- Redo hands-on exercises
- Retake quiz before Week 2

**If you scored < 35**:
- Take an extra day for Week 1 review
- Re-read all README files
- Complete all exercises again
- Understand concepts, don't memorize
- Retake quiz until scoring 40+

---

## Next Steps

### Before Starting Week 2

- [ ] Scored 35+ on this quiz (70%)
- [ ] Understand all missed questions
- [ ] Can explain key concepts in your own words
- [ ] Completed end-to-end pipeline project
- [ ] Reviewed weak topic areas

### Week 2 Preview

**Focus**: Performance Optimization

**Topics**:
- Clustering & Micro-Partitions
- Search Optimization
- Query Performance Tuning
- Warehouse Sizing
- Result Caching

**Goal**: Make pipelines fast and cost-effective

---

## Congratulations! 🎉

You've completed Week 1 of the SnowPro Advanced Data Engineer bootcamp!

**What you've accomplished**:
- ✅ Mastered 6 core data engineering concepts
- ✅ Built multiple hands-on projects
- ✅ Completed comprehensive 50-question review
- ✅ Ready for performance optimization

**Keep up the excellent work!** See you in Week 2! 🚀
