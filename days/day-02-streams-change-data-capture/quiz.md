# Day 2 Quiz: Streams for Change Data Capture

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What are the three types of streams in Snowflake?

A) Standard, Premium, and Enterprise  
B) Standard, Append-Only, and Insert-Only  
C) Basic, Advanced, and External  
D) Transactional, Analytical, and Hybrid  

**Your answer:**

---

### 2. What metadata columns do streams provide?

A) CHANGE_TYPE, CHANGE_DATE, CHANGE_USER  
B) ACTION, TIMESTAMP, ROW_NUMBER  
C) METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID  
D) OPERATION, IS_MODIFIED, RECORD_ID  

**Your answer:**

---

### 3. How does a stream represent an UPDATE operation?

A) As a single UPDATE record with old and new values  
B) As two records: DELETE (old) and INSERT (new), both with METADATA$ISUPDATE = TRUE  
C) As a MODIFY record with a diff of changes  
D) As an INSERT record with a special flag  

**Your answer:**

---

### 4. When is a stream consumed (offset advanced)?

A) Immediately when any query is run against it  
B) Only when used in a SELECT statement  
C) When used in DML statements (INSERT, MERGE, UPDATE, DELETE, CREATE TABLE AS)  
D) After 24 hours automatically  

**Your answer:**

---

### 5. What happens if a stream becomes stale?

A) It automatically refreshes from the source table  
B) It enters read-only mode  
C) It cannot be queried and must be recreated  
D) It continues to work but with degraded performance  

**Your answer:**

---

### 6. What does SYSTEM$STREAM_HAS_DATA() return?

A) The number of rows in the stream  
B) TRUE if stream has data, FALSE if empty  
C) A JSON object with stream statistics  
D) The timestamp of the last change  

**Your answer:**

---

### 7. Can you query a stream multiple times without consuming it?

A) No, each query consumes the stream  
B) Yes, SELECT queries don't consume streams  
C) Only if you use a special PEEK command  
D) Yes, but only within the same transaction  

**Your answer:**

---

### 8. What's the difference between Standard and Append-Only streams?

A) Standard is faster, Append-Only is more reliable  
B) Standard requires a warehouse, Append-Only doesn't  
C) Standard tracks all DML changes, Append-Only tracks only INSERTs  
D) Standard is for tables, Append-Only is for views  

**Your answer:**

---

### 9. How do streams relate to Time Travel retention?

A) Streams have their own independent retention period  
B) Streams depend on the table's Time Travel retention and become stale if it expires  
C) Streams automatically extend Time Travel retention  
D) Streams don't use Time Travel  

**Your answer:**

---

### 10. Which operation does NOT consume a stream?

A) INSERT INTO target SELECT * FROM stream  
B) MERGE INTO target USING stream  
C) SELECT * FROM stream  
D) CREATE TABLE AS SELECT * FROM stream  

**Your answer:**

---

## Answer Key

1. **B** - Standard, Append-Only, and Insert-Only
2. **C** - METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID
3. **B** - As two records: DELETE (old) and INSERT (new), both with METADATA$ISUPDATE = TRUE
4. **C** - When used in DML statements (INSERT, MERGE, UPDATE, DELETE, CREATE TABLE AS)
5. **C** - It cannot be queried and must be recreated
6. **B** - TRUE if stream has data, FALSE if empty
7. **B** - Yes, SELECT queries don't consume streams
8. **C** - Standard tracks all DML changes, Append-Only tracks only INSERTs
9. **B** - Streams depend on the table's Time Travel retention and become stale if it expires
10. **C** - SELECT * FROM stream (SELECT queries don't consume streams)

---

## Score Yourself

- 9-10/10: Excellent! You understand Streams thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Three types**: Standard, Append-Only, Insert-Only  
✅ **Metadata columns**: ACTION, ISUPDATE, ROW_ID  
✅ **UPDATE = DELETE + INSERT**: Both with ISUPDATE = TRUE  
✅ **Consumption**: DML operations consume, SELECT does not  
✅ **Staleness**: Depends on Time Travel retention  
✅ **Check before processing**: SYSTEM$STREAM_HAS_DATA()  
✅ **CDC pattern**: Stream → Process → MERGE/INSERT → Consume  
✅ **Best practice**: Process regularly to avoid staleness  

## Exam Tips

**Common exam question patterns:**
- When to use Standard vs Append-Only streams
- How UPDATEs are represented in streams
- What operations consume a stream
- How to prevent stream staleness
- Stream metadata column usage
- CDC pipeline design with streams

**Remember for the exam:**
- Streams are NOT tables (they're change tracking objects)
- SELECT queries don't consume streams
- UPDATEs appear as DELETE + INSERT
- Streams depend on Time Travel retention
- Use SYSTEM$STREAM_HAS_DATA() to check before processing
- Append-Only is more efficient for insert-only tables
- Streams are ideal for incremental processing

**Scenario questions:**
- "How would you sync two tables incrementally?" → Use streams with MERGE
- "How to track all changes for audit?" → Standard stream
- "How to process only new log entries?" → Append-Only stream
- "Stream shows no data after SELECT query" → SELECT doesn't consume
- "Stream became stale" → Retention period expired, recreate stream

## Common Mistakes to Avoid

❌ **Mistake**: Expecting SELECT to consume the stream  
✅ **Correct**: Only DML operations consume streams

❌ **Mistake**: Not checking SYSTEM$STREAM_HAS_DATA() before processing  
✅ **Correct**: Always check to avoid unnecessary processing

❌ **Mistake**: Using Standard stream for append-only tables  
✅ **Correct**: Use Append-Only stream for better performance

❌ **Mistake**: Not processing streams regularly  
✅ **Correct**: Process within Time Travel retention period

❌ **Mistake**: Forgetting METADATA$ISUPDATE when handling UPDATEs  
✅ **Correct**: Check ISUPDATE to distinguish UPDATE from standalone INSERT/DELETE

## Real-World Scenarios

**Scenario 1: Incremental Data Warehouse Load**
- Source: Transactional database table
- Solution: Standard stream + scheduled task + MERGE
- Benefit: Only process changed records, not full table

**Scenario 2: Event Log Processing**
- Source: Append-only event log table
- Solution: Append-Only stream + task
- Benefit: Simpler logic, better performance

**Scenario 3: SCD Type 2 Dimension**
- Source: Customer master table
- Solution: Standard stream + SCD Type 2 logic
- Benefit: Maintain full history of changes

**Scenario 4: Real-time Replication**
- Source: OLTP table
- Solution: Standard stream + MERGE to replica
- Benefit: Near real-time sync between tables

## Next Steps

- If you scored 8-10: Move to Day 3 (Tasks)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Practice Questions

Try answering these without looking:

1. What happens to a stream when you run: `SELECT * FROM my_stream;`?
2. How would you identify which records in a stream are from an UPDATE?
3. What's the best stream type for a table that only has INSERTs?
4. How do you check if a stream has data before processing?
5. What causes a stream to become stale?

**Answers:**
1. Nothing - SELECT doesn't consume the stream
2. Check METADATA$ISUPDATE = TRUE
3. Append-Only stream
4. SELECT SYSTEM$STREAM_HAS_DATA('stream_name')
5. Table's Time Travel retention period expires before stream is consumed
