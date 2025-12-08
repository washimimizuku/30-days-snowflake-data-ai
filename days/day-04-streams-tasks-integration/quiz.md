# Day 4 Quiz: Streams + Tasks Integration

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What does SYSTEM$STREAM_HAS_DATA() return when used in a task's WHEN clause?

A) The number of rows in the stream  
B) TRUE if stream has data, FALSE if empty  
C) A JSON object with stream metadata  
D) The timestamp of the last change  

**Your answer:**

---

### 2. When should you use APPEND_ONLY streams with tasks?

A) For all CDC pipelines  
B) When you need to track UPDATEs and DELETEs  
C) For tables that only have INSERTs (logs, events)  
D) Only with serverless tasks  

**Your answer:**

---

### 3. How do you handle UPDATEs in a MERGE statement when processing streams?

A) Use only the INSERT records  
B) Check for METADATA$ACTION = 'UPDATE'  
C) Match on METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE  
D) UPDATEs cannot be handled in MERGE statements  

**Your answer:**

---

### 4. What happens if a task fails while processing a stream?

A) The stream is automatically consumed anyway  
B) The stream offset does NOT advance, changes remain for retry  
C) The stream is deleted  
D) All changes are lost  

**Your answer:**

---

### 5. Why use WHEN SYSTEM$STREAM_HAS_DATA() in a task?

A) To make the task run faster  
B) To skip execution when no changes exist, saving costs  
C) To enable serverless compute  
D) It's required for all tasks  

**Your answer:**

---

### 6. Can multiple tasks consume the same stream?

A) Yes, streams can be consumed by multiple tasks simultaneously  
B) No, only one task can consume a stream  
C) Yes, but only if they're in different schemas  
D) Yes, but the stream must be recreated after each consumption  

**Your answer:**

---

### 7. What's the recommended schedule interval for CDC tasks?

A) Every second for real-time processing  
B) Balance between latency and cost (typically 1-10 minutes)  
C) Once per day  
D) Every hour  

**Your answer:**

---

### 8. How do you implement SCD Type 2 with streams and tasks?

A) Just insert all changes as new records  
B) Close old records (set valid_to, is_current=FALSE), then insert new versions  
C) Delete old records and insert new ones  
D) Use MERGE with UPSERT logic only  

**Your answer:**

---

### 9. What's the best way to handle errors in stream processing tasks?

A) Let the task fail and manually fix issues  
B) Use error tables or dead letter queues to log invalid records  
C) Ignore errors and continue processing  
D) Disable error checking  

**Your answer:**

---

### 10. How do you monitor stream-task pipeline performance?

A) Only check if tasks are running  
B) Monitor stream lag, task success rate, processing time, and error rate  
C) Just look at the task history once a week  
D) Monitoring is not necessary for automated pipelines  

**Your answer:**

---

## Answer Key

1. **B** - TRUE if stream has data, FALSE if empty
2. **C** - For tables that only have INSERTs (logs, events) - simpler and more efficient
3. **C** - Match on METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE
4. **B** - The stream offset does NOT advance, changes remain for retry
5. **B** - To skip execution when no changes exist, saving costs
6. **B** - No, only one task can consume a stream (consumption advances offset)
7. **B** - Balance between latency and cost (typically 1-10 minutes)
8. **B** - Close old records (set valid_to, is_current=FALSE), then insert new versions
9. **B** - Use error tables or dead letter queues to log invalid records
10. **B** - Monitor stream lag, task success rate, processing time, and error rate

---

## Score Yourself

- 9-10/10: Excellent! You understand Streams + Tasks integration thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Pattern**: Stream tracks changes → Task processes → MERGE applies changes  
✅ **Conditional**: Use WHEN SYSTEM$STREAM_HAS_DATA() to skip empty runs  
✅ **MERGE logic**: Handle INSERT, UPDATE (ISUPDATE=TRUE), DELETE  
✅ **Consumption**: Stream offset advances only on successful DML  
✅ **Failure**: Failed task = stream not consumed = changes retained  
✅ **SCD Type 2**: Close old + Insert new versions  
✅ **Error handling**: Use error tables or DLQ for invalid records  
✅ **Monitoring**: Track lag, success rate, duration, errors  
✅ **Optimization**: Batch processing, appropriate schedules, right warehouse size  
✅ **Multi-stage**: Use task trees with AFTER clause  

## Exam Tips

**Common exam question patterns:**
- When to use streams + tasks vs. other methods
- How to handle different DML operations in MERGE
- WHEN clause usage with SYSTEM$STREAM_HAS_DATA()
- What happens when tasks fail
- SCD Type 2 implementation steps
- Error handling strategies
- Performance optimization techniques

**Remember for the exam:**
- SYSTEM$STREAM_HAS_DATA() prevents unnecessary task runs
- Stream offset advances only when DML succeeds
- UPDATEs appear as DELETE + INSERT with ISUPDATE = TRUE
- Failed task = stream not consumed = can retry
- MERGE handles all DML operations in one statement
- SCD Type 2 requires two steps: close old, insert new
- Monitor stream lag to ensure timely processing
- Use error tables for invalid records

**Scenario questions:**
- "How to automate CDC pipeline?" → Stream + Task with WHEN clause
- "Task failed, what happens to stream?" → Stream not consumed, changes retained
- "How to handle UPDATEs in MERGE?" → Check METADATA$ISUPDATE = TRUE
- "Reduce CDC costs?" → Use WHEN SYSTEM$STREAM_HAS_DATA()
- "Track historical changes?" → Implement SCD Type 2 with streams + tasks

## Common Mistakes to Avoid

❌ **Mistake**: Not using WHEN SYSTEM$STREAM_HAS_DATA()  
✅ **Correct**: Always use WHEN clause to skip empty runs

❌ **Mistake**: Forgetting to handle METADATA$ISUPDATE for UPDATEs  
✅ **Correct**: Check ISUPDATE = TRUE to identify UPDATE operations

❌ **Mistake**: Assuming stream is consumed on task failure  
✅ **Correct**: Stream only consumed on successful DML execution

❌ **Mistake**: Not implementing error handling  
✅ **Correct**: Use error tables or DLQ for invalid records

❌ **Mistake**: Using same stream for multiple tasks  
✅ **Correct**: Each task needs its own stream (consumption advances offset)

## Real-World Scenarios

**Scenario 1: Real-Time Order Processing**
- Stream on orders table
- Task runs every 1 minute with WHEN clause
- MERGE updates order status in real-time
- Benefit: Near real-time sync, cost-efficient

**Scenario 2: Customer Dimension Maintenance**
- Stream on customer master table
- Task implements SCD Type 2 logic
- Maintains full history of customer changes
- Benefit: Historical analysis, audit trail

**Scenario 3: Multi-Source Data Integration**
- Multiple streams on different source tables
- Task tree processes each source sequentially
- Final task merges all data
- Benefit: Orchestrated, reliable pipeline

**Scenario 4: High-Volume Event Processing**
- Append-only stream on event log
- Task with larger warehouse for batch processing
- Runs every 10 minutes to batch events
- Benefit: Cost-effective, handles high volume

## Best Practices Checklist

✅ Use WHEN SYSTEM$STREAM_HAS_DATA() in all CDC tasks  
✅ Implement comprehensive MERGE logic (INSERT, UPDATE, DELETE)  
✅ Handle METADATA$ISUPDATE correctly for UPDATEs  
✅ Add error handling with error tables or DLQ  
✅ Monitor stream lag and task success rate  
✅ Use appropriate schedule intervals (balance latency vs. cost)  
✅ Test failure scenarios before production  
✅ Document pipeline architecture  
✅ Set up alerts for task failures  
✅ Use serverless tasks for variable workloads  

## Next Steps

- If you scored 8-10: Move to Day 5 (Dynamic Tables)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Practice Questions

Try answering these without looking:

1. What SQL function checks if a stream has data?
2. How does a task know when to skip execution?
3. What happens to a stream when a task fails?
4. How do you identify UPDATE operations in a stream?
5. What are the two steps for SCD Type 2 processing?

**Answers:**
1. SYSTEM$STREAM_HAS_DATA('stream_name')
2. WHEN clause with SYSTEM$STREAM_HAS_DATA() returns FALSE
3. Stream offset doesn't advance, changes remain for retry
4. Check METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = TRUE
5. Close old records (set valid_to, is_current=FALSE), insert new versions

## Integration Patterns Summary

| Pattern | Use Case | Key Components |
|---------|----------|----------------|
| Simple Append | Logs, events | Append-only stream + INSERT task |
| Upsert | Master data | Standard stream + MERGE task |
| SCD Type 2 | Dimensions | Standard stream + 2-step task |
| Multi-stage | Complex ETL | Multiple streams + task tree |
| Error Handling | Production | Stream + task + error table + DLQ |
