# Day 20 Quiz: Cloning & Zero-Copy Cloning

## Instructions
- 10 multiple choice questions
- Choose the best answer for each question
- Answers and explanations at the end
- Passing score: 7/10 (70%)

---

## Questions

### Question 1
What happens when you create a clone of a 1 TB table in Snowflake?

A) The entire 1 TB of data is physically copied, taking several hours  
B) A new table is created instantly with pointers to the same micro-partitions  
C) Only the table structure is cloned, without any data  
D) The data is compressed and copied, reducing storage by 50%

### Question 2
After cloning a table, you insert 100 GB of new data into the clone. How much additional storage is consumed?

A) 0 GB (zero-copy means no storage cost)  
B) 50 GB (data is automatically compressed)  
C) 100 GB (only the new data consumes storage)  
D) 1.1 TB (original table size plus new data)

### Question 3
Which of the following can be cloned in Snowflake?

A) Tables only  
B) Tables and schemas only  
C) Tables, schemas, and databases  
D) Tables, schemas, databases, and external stages

### Question 4
You want to clone a table as it existed yesterday. Which syntax is correct?

A) `CREATE TABLE t_clone CLONE t AT(YESTERDAY);`  
B) `CREATE TABLE t_clone CLONE t AT(OFFSET => -86400);`  
C) `CREATE TABLE t_clone CLONE t BEFORE(OFFSET => 86400);`  
D) `CREATE TABLE t_clone CLONE t TIME_TRAVEL(-1 DAY);`

### Question 5
What happens to streams and tasks when you clone a database?

A) They are cloned and continue running automatically  
B) They are cloned but must be manually resumed  
C) They are not cloned and must be recreated  
D) They are cloned but point to the original tables

### Question 6
You clone a production table to test a schema change. After testing, you want to apply the change to production. What's the best approach?

A) Rename the clone to replace the production table  
B) Drop production and rename the clone  
C) Apply the same schema change to production after validating on the clone  
D) Use ALTER TABLE...SWAP to exchange the tables

### Question 7
Which statement about clone storage costs is TRUE?

A) Clones never consume storage because they're zero-copy  
B) Clones consume storage only for data that diverges from the source  
C) Clones consume 50% of the source table's storage immediately  
D) Clones consume the same storage as the source table immediately

### Question 8
You accidentally deleted data from a table 2 hours ago. Which approach can recover the data using cloning?

A) `CREATE TABLE t_recovered CLONE t AT(OFFSET => -7200);`  
B) `CREATE TABLE t_recovered CLONE t BEFORE(STATEMENT => '<delete_query_id>');`  
C) Both A and B are valid approaches  
D) Neither A nor B will work; use UNDROP instead

### Question 9
What is NOT cloned when you clone a table?

A) Table structure (columns and data types)  
B) Clustering keys  
C) Grants and privileges  
D) Data (via micro-partition pointers)

### Question 10
You create a clone of a database for development. Developers make extensive changes. What happens to the production database?

A) Production is locked until the clone is dropped  
B) Production is unaffected; clones are independent  
C) Production reflects 50% of the changes made to the clone  
D) Production is automatically backed up when the clone is created

---

## Answer Key

### Question 1: B
**Correct Answer: B) A new table is created instantly with pointers to the same micro-partitions**

Explanation: Zero-copy cloning creates a new table instantly by copying only metadata and creating pointers to the same micro-partitions as the source table. No data is physically copied at creation time, which is why cloning is instant regardless of table size.

### Question 2: C
**Correct Answer: C) 100 GB (only the new data consumes storage)**

Explanation: When you insert new data into a clone, only that new data consumes additional storage. The clone initially shares micro-partitions with the source (zero storage), and storage increases only for data that diverges (inserts, updates, deletes). This is the "copy-on-write" behavior.

### Question 3: C
**Correct Answer: C) Tables, schemas, and databases**

Explanation: Snowflake supports cloning at three levels: tables, schemas, and databases. However, external stages, pipes, streams, and tasks are not cloned. When you clone a database or schema, the contained tables are cloned, but associated objects like streams and tasks must be recreated.

### Question 4: B
**Correct Answer: B) `CREATE TABLE t_clone CLONE t AT(OFFSET => -86400);`**

Explanation: The correct syntax uses `AT(OFFSET => -86400)` where 86400 is the number of seconds in 24 hours (1 day). The offset is negative to go back in time. Alternative syntax includes `AT(TIMESTAMP => '<timestamp>')` for specific points in time.

### Question 5: C
**Correct Answer: C) They are not cloned and must be recreated**

Explanation: Streams, tasks, pipes, and external stages are not cloned when you clone a database or schema. Only the table structures and data (via micro-partition pointers) are cloned. You must recreate these objects if needed in the cloned environment.

### Question 6: C
**Correct Answer: C) Apply the same schema change to production after validating on the clone**

Explanation: The best practice is to test schema changes on a clone, validate they work correctly, then apply the same changes to production. Simply swapping or renaming tables can cause issues with dependent objects (views, streams, grants). Apply changes methodically to production after validation.

### Question 7: B
**Correct Answer: B) Clones consume storage only for data that diverges from the source**

Explanation: At creation, clones consume zero additional storage because they share micro-partitions with the source. Storage costs increase only when data diverges through inserts, updates, or deletes (copy-on-write). Time Travel and Fail-Safe also apply to clones, adding to storage costs.

### Question 8: C
**Correct Answer: C) Both A and B are valid approaches**

Explanation: Both approaches work for data recovery:
- `AT(OFFSET => -7200)` clones the table as it was 7200 seconds (2 hours) ago
- `BEFORE(STATEMENT => '<query_id>')` clones the table from before a specific statement executed

Both leverage Time Travel combined with cloning for point-in-time recovery.

### Question 9: C
**Correct Answer: C) Grants and privileges**

Explanation: When cloning a table, the structure, data (via pointers), clustering keys, comments, and constraints are cloned. However, grants and privileges are NOT cloned. You must re-grant permissions on the cloned object. This is a security feature to prevent unintended privilege escalation.

### Question 10: B
**Correct Answer: B) Production is unaffected; clones are independent**

Explanation: Clones are completely independent of their source. Changes to a clone do not affect the source table, and changes to the source do not affect the clone (after creation). This independence makes clones perfect for development and testing without risk to production.

---

## Scoring Guide

- **9-10 correct**: Excellent! You understand zero-copy cloning thoroughly.
- **7-8 correct**: Good job! Review the questions you missed.
- **5-6 correct**: Fair. Review the README.md and retry the exercises.
- **Below 5**: Review the material and complete the hands-on exercises again.

---

## Key Concepts to Remember

1. **Zero-Copy Cloning**
   - Instant creation regardless of size
   - No data duplication at creation time
   - Shares micro-partitions with source initially

2. **Storage Costs**
   - Zero storage at creation
   - Storage increases only for diverged data (copy-on-write)
   - Time Travel and Fail-Safe apply to clones

3. **What Gets Cloned**
   - Table structure and data (via pointers)
   - Clustering keys and comments
   - Constraints (NOT NULL, etc.)

4. **What Doesn't Get Cloned**
   - Grants and privileges
   - Streams, tasks, and pipes
   - External stages
   - Internal stage data files

5. **Cloning with Time Travel**
   - `AT(OFFSET => -seconds)` for relative time
   - `AT(TIMESTAMP => '<timestamp>')` for specific time
   - `BEFORE(STATEMENT => '<query_id>')` for before a statement

6. **Use Cases**
   - Development and testing environments
   - Data backup and recovery
   - Schema migration testing
   - Data analysis and experimentation
   - A/B testing

7. **Independence**
   - Clones are completely independent
   - Changes to clone don't affect source
   - Changes to source don't affect clone (after creation)

8. **Best Practices**
   - Use clones for non-production environments
   - Clean up unused clones regularly
   - Document clone purpose with comments
   - Monitor storage divergence
   - Automate backup and cleanup procedures

---

## Exam Tips

1. **Remember the zero-copy concept**: Clones don't duplicate data initially; they share micro-partitions.

2. **Understand copy-on-write**: Storage increases only when data diverges through modifications.

3. **Know what's not cloned**: Streams, tasks, pipes, grants, and external stages are not cloned.

4. **Time Travel syntax**: Practice the different Time Travel clauses (AT, BEFORE, OFFSET, TIMESTAMP).

5. **Independence**: Clones are completely independent of their source after creation.

6. **Use cases**: Be able to identify appropriate scenarios for cloning (dev/test, backup, recovery).

7. **Storage implications**: Understand how clone storage costs accumulate over time.

8. **Cloning levels**: Remember you can clone tables, schemas, and databases.

---

## Additional Practice

Try these scenarios:

1. **Scenario**: You need to test a major schema change on a 5 TB production table. What's the fastest and safest approach?
   - **Answer**: Clone the table (instant), test changes on clone, apply to production after validation.

2. **Scenario**: A developer accidentally deleted 1 million rows 3 hours ago. How do you recover?
   - **Answer**: Clone the table using `AT(OFFSET => -10800)` or `BEFORE(STATEMENT => '<delete_query_id>')`, then insert the deleted rows back.

3. **Scenario**: You need weekly backups of your production database. How do you automate this?
   - **Answer**: Create a stored procedure that clones the database with a date suffix, schedule it with a task to run weekly.

4. **Scenario**: Your dev environment is 2 weeks old and needs refreshing from production. What's the process?
   - **Answer**: Drop the old dev database, clone production to create a new dev database, re-grant permissions to developers.

---

## Next Steps

- If you scored 8-10: Move to Day 21 (Week 3 Review & Governance Lab)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

---

## Resources for Further Study

- [Snowflake Docs: Cloning](https://docs.snowflake.com/en/user-guide/tables-storage-considerations#label-cloning-tables)
- [Zero-Copy Cloning](https://docs.snowflake.com/en/user-guide/object-clone)
- [Storage Costs](https://docs.snowflake.com/en/user-guide/tables-storage-considerations)
- [Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel)

---

**Congratulations on completing Day 20!** 🎉

Tomorrow, we'll review all Week 3 concepts and build a comprehensive security and governance implementation.
