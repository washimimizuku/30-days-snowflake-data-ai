# Day 2: Streams for Change Data Capture

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake Streams and how they track changes
- Know the different stream types (Standard, Append-Only, Insert-Only)
- Create and query streams to capture data changes
- Use stream metadata columns for CDC operations
- Build a basic CDC pipeline with streams
- Understand stream offset and consumption patterns

---

## Theory

### What are Streams?

Streams are Snowflake objects that record Data Manipulation Language (DML) changes made to tables. They enable Change Data Capture (CDC) by tracking INSERT, UPDATE, and DELETE operations.

**Key Characteristics:**
- **Change tracking**: Records all DML changes to a table
- **Metadata columns**: Provides information about the type of change
- **Offset-based**: Tracks position in change history
- **Consumable**: Changes are "consumed" when queried in a DML statement
- **Low overhead**: Minimal performance impact on source table

### When to Use Streams

✅ **Use Streams for:**
- Change Data Capture (CDC) pipelines
- Incremental data processing
- Audit trails and change history
- Real-time data synchronization
- Event-driven architectures
- Slowly Changing Dimensions (SCD Type 2)

❌ **Don't use Streams for:**
- Full table refreshes (use regular queries)
- One-time data loads
- Historical analysis (use Time Travel)
- When you need to replay changes multiple times

### Stream Types

#### 1. Standard Stream (Default)
Tracks all DML changes: INSERT, UPDATE, DELETE

```sql
CREATE STREAM my_stream ON TABLE my_table;
```

**Use cases:**
- Full CDC pipelines
- Maintaining synchronized copies
- Audit logging
- SCD Type 2 implementations

#### 2. Append-Only Stream
Tracks only INSERT operations (ignores UPDATE and DELETE)

```sql
CREATE STREAM my_stream ON TABLE my_table APPEND_ONLY = TRUE;
```

**Use cases:**
- Append-only tables (logs, events)
- When you only care about new records
- Simplified processing logic
- Performance optimization

#### 3. Insert-Only Stream
For external tables - tracks only new files

```sql
CREATE STREAM my_stream ON EXTERNAL TABLE my_ext_table INSERT_ONLY = TRUE;
```

**Use cases:**
- Processing files from cloud storage
- External table CDC
- File-based data ingestion

### Stream Metadata Columns

Streams add special metadata columns to track changes:

| Column | Type | Description |
|--------|------|-------------|
| METADATA$ACTION | VARCHAR | INSERT, DELETE |
| METADATA$ISUPDATE | BOOLEAN | TRUE if part of UPDATE |
| METADATA$ROW_ID | VARCHAR | Unique row identifier |

**Understanding UPDATE operations:**
- UPDATE = DELETE (old row) + INSERT (new row)
- Both have METADATA$ISUPDATE = TRUE
- Use METADATA$ACTION to distinguish

### How Streams Work

```
Table Changes → Stream Records Changes → Query Stream → Process Changes → Offset Advances
```

**Example flow:**
1. INSERT 3 rows into table → Stream records 3 INSERTs
2. UPDATE 1 row → Stream records 1 DELETE + 1 INSERT
3. DELETE 1 row → Stream records 1 DELETE
4. Query stream → See all 6 change records
5. Process changes in DML → Stream offset advances
6. Query stream again → Empty (changes consumed)

### Stream Offset and Consumption

**Offset:**
- Tracks the position in the table's change history
- Advances when stream data is consumed in a DML statement
- Does NOT advance on SELECT queries

**Consumption:**
Streams are consumed when used in:
- INSERT INTO ... SELECT FROM stream
- MERGE INTO ... USING stream
- CREATE TABLE AS SELECT FROM stream
- UPDATE ... FROM stream
- DELETE ... USING stream

**Not consumed by:**
- SELECT queries (for testing/viewing)
- SHOW STREAMS
- Queries in transactions that are rolled back

### Checking Stream Status

```sql
-- Check if stream has data
SELECT SYSTEM$STREAM_HAS_DATA('my_stream');

-- View stream metadata
SHOW STREAMS;

-- Describe stream
DESC STREAM my_stream;

-- Query stream without consuming
SELECT * FROM my_stream;
```

### Stream Retention and Staleness

**Data Retention:**
- Streams depend on table's Time Travel retention
- If retention period expires, stream becomes stale
- Stale streams cannot be queried

**Avoiding staleness:**
- Process streams regularly (within retention period)
- Set appropriate DATA_RETENTION_TIME_IN_DAYS
- Monitor stream lag

```sql
-- Check stream staleness
SHOW STREAMS;
-- Look for STALE column = TRUE

-- Set table retention
ALTER TABLE my_table SET DATA_RETENTION_TIME_IN_DAYS = 7;
```

### Best Practices

**1. Regular Consumption**
- Process streams frequently (hourly or daily)
- Don't let streams become stale
- Use tasks for automated processing

**2. Idempotent Processing**
- Design logic to handle duplicate processing
- Use MERGE for upsert operations
- Include unique identifiers

**3. Error Handling**
- Wrap stream processing in transactions
- Handle failures gracefully
- Log errors for troubleshooting

**4. Performance**
- Use APPEND_ONLY when possible (simpler, faster)
- Process in batches
- Consider warehouse size for large volumes

**5. Monitoring**
- Check SYSTEM$STREAM_HAS_DATA() before processing
- Monitor stream lag
- Alert on stale streams

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Standard Stream
Set up a stream to track all changes on a customer table.

### Exercise 2: Test INSERT Operations
Insert data and observe how streams capture new records.

### Exercise 3: Test UPDATE Operations
Update records and understand how streams represent updates.

### Exercise 4: Test DELETE Operations
Delete records and see how streams track deletions.

### Exercise 5: Stream Metadata
Query and interpret stream metadata columns.

### Exercise 6: Consume Stream
Process stream data and observe offset advancement.

### Exercise 7: Append-Only Stream
Create and use an append-only stream for event data.

### Exercise 8: Build CDC Pipeline
Create a complete CDC pipeline with MERGE statement.

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:

1. What are the three types of streams in Snowflake?
2. What metadata columns do streams provide?
3. How does a stream represent an UPDATE operation?
4. When is a stream consumed (offset advanced)?
5. What happens if a stream becomes stale?
6. What does SYSTEM$STREAM_HAS_DATA() return?
7. Can you query a stream multiple times without consuming it?
8. What's the difference between Standard and Append-Only streams?
9. How do streams relate to Time Travel retention?
10. What DML operations consume a stream?

---

## 🎯 Key Takeaways

- Streams enable Change Data Capture (CDC) in Snowflake
- Three types: Standard (all changes), Append-Only (inserts), Insert-Only (external tables)
- Metadata columns track change type: METADATA$ACTION, METADATA$ISUPDATE
- UPDATEs appear as DELETE + INSERT with METADATA$ISUPDATE = TRUE
- Streams are consumed when used in DML statements (not SELECT)
- Use SYSTEM$STREAM_HAS_DATA() to check before processing
- Streams depend on table's Time Travel retention period
- Process streams regularly to avoid staleness
- Ideal for incremental processing and CDC pipelines
- Combine with Tasks for automated CDC workflows

---

## 📚 Additional Resources

- [Snowflake Docs: Streams](https://docs.snowflake.com/en/user-guide/streams)
- [Snowflake Docs: Stream Types](https://docs.snowflake.com/en/user-guide/streams-intro)
- [CDC with Streams](https://docs.snowflake.com/en/user-guide/streams-intro#change-data-capture)
- [Stream Best Practices](https://docs.snowflake.com/en/user-guide/streams-manage)

---

## 🔜 Tomorrow: Day 3 - Tasks & Task Orchestration

We'll learn how to automate stream processing using Tasks and build complete automated CDC pipelines.
