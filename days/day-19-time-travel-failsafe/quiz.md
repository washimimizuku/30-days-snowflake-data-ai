# Day 19 Quiz: Time Travel & Fail-Safe

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the maximum Time Travel retention period in Enterprise Edition?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days  

**Your answer:**

---

### 2. What is the default Time Travel retention period?

A) 0 days  
B) 1 day  
C) 7 days  
D) 90 days  

**Your answer:**

---

### 3. How long is the Fail-Safe period?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days  

**Your answer:**

---

### 4. Who can access data in Fail-Safe?

A) Any user  
B) ACCOUNTADMIN only  
C) Snowflake Support only  
D) No one, it's automatic  

**Your answer:**

---

### 5. Which command recovers a dropped table?

A) RESTORE TABLE  
B) UNDROP TABLE  
C) RECOVER TABLE  
D) UNDELETE TABLE  

**Your answer:**

---

### 6. What does AT(OFFSET => -3600) mean?

A) 3600 minutes ago  
B) 3600 seconds ago (1 hour)  
C) 3600 hours ago  
D) 3600 days ago  

**Your answer:**

---

### 7. What type of table has NO Fail-Safe?

A) Permanent table  
B) Transient table  
C) External table  
D) Both B and C  

**Your answer:**

---

### 8. What type of table has NO Time Travel or Fail-Safe?

A) Permanent table  
B) Transient table  
C) Temporary table  
D) External table  

**Your answer:**

---

### 9. Can you query a view using Time Travel?

A) Yes, directly  
B) No, query underlying tables instead  
C) Only secure views  
D) Only materialized views  

**Your answer:**

---

### 10. What incurs storage costs?

A) Time Travel only  
B) Fail-Safe only  
C) Both Time Travel and Fail-Safe  
D) Neither, they're free  

**Your answer:**

---

## Answer Key

1. **D** - 90 days
2. **B** - 1 day
3. **B** - 7 days
4. **C** - Snowflake Support only
5. **B** - UNDROP TABLE
6. **B** - 3600 seconds ago (1 hour)
7. **D** - Both transient and external tables
8. **C** - Temporary table
9. **B** - No, query underlying tables instead
10. **C** - Both Time Travel and Fail-Safe

---

## Score Yourself

- 9-10/10: Excellent! You understand Time Travel thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Time Travel**: 1-90 days (configurable)  
✅ **Fail-Safe**: 7 days (non-configurable)  
✅ **Default Retention**: 1 day  
✅ **Fail-Safe Access**: Snowflake Support only  
✅ **UNDROP**: Recovers dropped objects  
✅ **AT/BEFORE**: Query historical data  
✅ **Transient Tables**: No Fail-Safe  
✅ **Temporary Tables**: No Time Travel or Fail-Safe  
✅ **Storage Costs**: Apply to both Time Travel and Fail-Safe  
✅ **Views**: Cannot query directly with Time Travel  

## Exam Tips

**Common exam question patterns:**
- Maximum retention periods
- Default retention
- Fail-Safe duration and access
- UNDROP command
- AT vs. BEFORE clauses
- Transient vs. temporary tables
- Storage cost implications
- Time Travel limitations
- Query syntax
- Recovery procedures

**Remember for the exam:**
- Standard: 1 day max
- Enterprise: 90 days max
- Default: 1 day
- Fail-Safe: 7 days (Snowflake Support only)
- UNDROP recovers dropped objects
- AT(OFFSET => -seconds)
- Transient: No Fail-Safe
- Temporary: No Time Travel or Fail-Safe
- Storage costs for both
- Cannot query views directly

## Next Steps

- If you scored 8-10: Move to Day 20 (Cloning & Zero-Copy Cloning)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Query data from 1 hour ago
2. Recover deleted records
3. Undrop a table
4. Clone historical data
5. Audit data changes
6. Set retention periods
7. Monitor storage costs
8. Compare current vs. historical

## Real-World Applications

**Accidental Deletion Recovery:**
```sql
-- Recover deleted data
INSERT INTO customers
SELECT * FROM customers
BEFORE(STATEMENT => '<query_id>')
WHERE customer_id IN (1, 2, 3);
```

**Point-in-Time Reporting:**
```sql
-- Month-end report
SELECT * FROM sales
AT(TIMESTAMP => '2024-01-31 23:59:59'::TIMESTAMP);
```

**Audit Trail:**
```sql
-- Find what changed
SELECT * FROM customers
MINUS
SELECT * FROM customers
AT(OFFSET => -86400);
```

**Testing and Development:**
```sql
-- Clone production data safely
CREATE TABLE customers_test CLONE customers
AT(TIMESTAMP => '2024-01-01 00:00:00'::TIMESTAMP);
```

**Time Travel Patterns:**

**By Timestamp:**
```sql
AT(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP)
```

**By Offset:**
```sql
AT(OFFSET => -3600)  -- 1 hour ago
AT(OFFSET => -86400)  -- 1 day ago
```

**By Statement:**
```sql
BEFORE(STATEMENT => '<query_id>')
```

**Best Practices Checklist:**
- [ ] Set appropriate retention periods
- [ ] Use transient for staging tables
- [ ] Use temporary for session data
- [ ] Document important query IDs
- [ ] Test recovery procedures
- [ ] Monitor storage overhead
- [ ] Clone for testing
- [ ] Regular audits
- [ ] Cost optimization
- [ ] Compliance tracking

**Common Mistakes to Avoid:**
1. ❌ Setting retention too high (costs)
2. ❌ Setting retention too low (can't recover)
3. ❌ Not documenting query IDs
4. ❌ Not testing recovery
5. ❌ Using permanent tables for staging
6. ❌ Not monitoring storage
7. ❌ Querying views with Time Travel
8. ❌ Forgetting about Fail-Safe costs

**Troubleshooting:**

**Issue**: Cannot query historical data
- **Check**: Within retention period?
- **Check**: Correct syntax?
- **Fix**: Verify retention settings

**Issue**: UNDROP fails
- **Cause**: Name conflict or expired
- **Fix**: Drop current or use different name

**Issue**: High storage costs
- **Cause**: Long retention or frequent changes
- **Fix**: Reduce retention, use transient tables

**Issue**: Cannot recover data
- **Cause**: Beyond retention + Fail-Safe
- **Fix**: Contact Snowflake Support (if in Fail-Safe)

**Storage Optimization:**

**Permanent Tables:**
- Time Travel: Yes (1-90 days)
- Fail-Safe: Yes (7 days)
- Use for: Critical data

**Transient Tables:**
- Time Travel: Yes (max 1 day)
- Fail-Safe: No
- Use for: Staging, ETL

**Temporary Tables:**
- Time Travel: No
- Fail-Safe: No
- Use for: Session data

**Cost Comparison:**
```
Permanent: Highest cost (Time Travel + Fail-Safe)
Transient: Medium cost (Time Travel only)
Temporary: Lowest cost (neither)
```

**Retention Guidelines:**

**Critical Data:**
- Retention: 30-90 days
- Type: Permanent
- Example: Financial records

**Important Data:**
- Retention: 7-30 days
- Type: Permanent
- Example: Customer data

**Staging Data:**
- Retention: 1 day
- Type: Transient
- Example: ETL staging

**Session Data:**
- Retention: None
- Type: Temporary
- Example: Temp calculations

**Monitoring Queries:**

```sql
-- Storage by table
SELECT 
  table_name,
  active_bytes / 1024 / 1024 / 1024 as active_gb,
  time_travel_bytes / 1024 / 1024 / 1024 as tt_gb,
  failsafe_bytes / 1024 / 1024 / 1024 as fs_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE deleted IS NULL;

-- Retention settings
SELECT table_name, retention_time
FROM INFORMATION_SCHEMA.TABLES;

-- Query history
SELECT query_id, query_text, start_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
ORDER BY start_time DESC;
```

**Recovery Procedures:**

**1. Identify Issue:**
- What was deleted/changed?
- When did it happen?
- What needs recovery?

**2. Find Query ID:**
```sql
SELECT query_id, query_text
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%DELETE%'
ORDER BY start_time DESC;
```

**3. Recover Data:**
```sql
-- Option 1: Insert deleted rows
INSERT INTO table_name
SELECT * FROM table_name
BEFORE(STATEMENT => '<query_id>');

-- Option 2: Replace entire table
CREATE OR REPLACE TABLE table_name AS
SELECT * FROM table_name
BEFORE(STATEMENT => '<query_id>');

-- Option 3: Undrop
UNDROP TABLE table_name;
```

**4. Verify:**
```sql
SELECT COUNT(*) FROM table_name;
SELECT * FROM table_name LIMIT 10;
```

**Compliance Use Cases:**

**Audit Requirements:**
- Track all changes
- Point-in-time queries
- Change history

**Data Recovery:**
- Accidental deletions
- Incorrect updates
- System failures

**Testing:**
- Clone production data
- Safe testing environment
- No impact on production

**Reporting:**
- Historical reports
- Trend analysis
- Comparative analysis

**Next Steps:**
Tomorrow we'll learn about Cloning & Zero-Copy Cloning for creating instant copies of databases, schemas, and tables without duplicating data.
