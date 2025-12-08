# Day 21: Week 3 Review & Governance Lab

## 📖 Overview (15 min)

Welcome to Week 3 Review! Today we'll consolidate everything you've learned about data governance, security, and data protection in Snowflake.

**Week 3 Topics Covered:**
- Day 15: RBAC & Access Control
- Day 16: Data Masking & Privacy
- Day 17: Row Access Policies
- Day 18: Data Sharing & Secure Views
- Day 19: Time Travel & Fail-Safe
- Day 20: Cloning & Zero-Copy Cloning

**Today's Goals:**
- Review all Week 3 concepts
- Complete comprehensive governance lab
- Take 50-question review quiz
- Identify areas needing more study
- Build end-to-end security implementation

---

## Week 3 Concept Review

### Day 15: RBAC & Access Control

**Key Concepts:**
- Role hierarchy and inheritance
- System roles (ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, PUBLIC)
- USAGE privilege on databases and schemas
- Future grants for automatic privilege assignment
- Role best practices and least privilege principle

**Critical Commands:**
```sql
-- Create role hierarchy
CREATE ROLE data_engineer;
GRANT ROLE data_engineer TO ROLE sysadmin;

-- Grant privileges
GRANT USAGE ON DATABASE mydb TO ROLE data_engineer;
GRANT SELECT ON ALL TABLES IN SCHEMA mydb.public TO ROLE data_engineer;

-- Future grants
GRANT SELECT ON FUTURE TABLES IN SCHEMA mydb.public TO ROLE data_engineer;
```

### Day 16: Data Masking & Privacy

**Key Concepts:**
- Dynamic data masking
- Masking policies (conditional masking)
- PII protection strategies
- Compliance requirements (GDPR, PCI-DSS, HIPAA)
- Masking functions (MASK, SHA2, etc.)

**Critical Commands:**
```sql
-- Create masking policy
CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE REGEXP_REPLACE(val, '.+@', '***@')
  END;

-- Apply to column
ALTER TABLE customers MODIFY COLUMN email 
SET MASKING POLICY email_mask;
```

### Day 17: Row Access Policies

**Key Concepts:**
- Row-level security (RLS)
- Mapping tables for access control
- Multi-tenant data isolation
- Combining row access with masking policies
- Performance considerations

**Critical Commands:**
```sql
-- Create row access policy
CREATE ROW ACCESS POLICY region_policy AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() = 'ADMIN' THEN TRUE
    WHEN CURRENT_ROLE() = 'NORTH_ANALYST' AND region = 'NORTH' THEN TRUE
    ELSE FALSE
  END;

-- Apply to table
ALTER TABLE sales ADD ROW ACCESS POLICY region_policy ON (region);
```

### Day 18: Data Sharing & Secure Views

**Key Concepts:**
- Zero-copy data sharing
- Secure views for data protection
- Reader accounts for external consumers
- Cross-region and cross-cloud sharing
- Sharing with row-level security

**Critical Commands:**
```sql
-- Create share
CREATE SHARE customer_share;
GRANT USAGE ON DATABASE mydb TO SHARE customer_share;
GRANT SELECT ON TABLE mydb.public.customers TO SHARE customer_share;

-- Add account to share
ALTER SHARE customer_share ADD ACCOUNTS = xy12345;

-- Create secure view
CREATE SECURE VIEW customer_summary AS
SELECT customer_id, total_purchases
FROM customers
WHERE region = CURRENT_ROLE();
```

### Day 19: Time Travel & Fail-Safe

**Key Concepts:**
- Time Travel (1-90 days retention)
- Fail-Safe (7 days, Snowflake Support only)
- AT and BEFORE clauses
- UNDROP command
- Storage costs and optimization
- Transient vs. permanent tables

**Critical Commands:**
```sql
-- Query historical data
SELECT * FROM orders AT(OFFSET => -86400);
SELECT * FROM orders AT(TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);

-- Recover dropped table
UNDROP TABLE important_data;

-- Clone from history
CREATE TABLE orders_backup CLONE orders
BEFORE(STATEMENT => '<query_id>');
```

### Day 20: Cloning & Zero-Copy Cloning

**Key Concepts:**
- Zero-copy cloning (instant, no data duplication)
- Copy-on-write behavior
- Cloning tables, schemas, and databases
- Combining cloning with Time Travel
- Storage implications and monitoring
- Use cases (dev/test, backup, recovery)

**Critical Commands:**
```sql
-- Clone table
CREATE TABLE orders_clone CLONE orders;

-- Clone with Time Travel
CREATE TABLE orders_yesterday CLONE orders
AT(OFFSET => -86400);

-- Clone database
CREATE DATABASE dev_db CLONE prod_db;
```

---

## Key Facts to Memorize

### RBAC & Access Control
- **System Roles**: ACCOUNTADMIN > SECURITYADMIN, SYSADMIN > PUBLIC
- **USAGE**: Required on database and schema to access objects
- **Future Grants**: Automatically apply to new objects
- **Best Practice**: Use custom roles, not system roles for users

### Data Masking
- **Dynamic**: Applied at query time, no data modification
- **Conditional**: Can show different data based on role
- **Performance**: Minimal impact, evaluated per row
- **Compliance**: GDPR, PCI-DSS, HIPAA requirements

### Row Access Policies
- **One per table**: Only one row access policy per table
- **Boolean return**: Policy must return TRUE/FALSE
- **Mapping tables**: Use for complex access rules
- **Performance**: Can impact query performance

### Data Sharing
- **Zero-copy**: No data duplication
- **Live data**: Consumers see real-time updates
- **Secure views**: Protect sensitive data in shares
- **Reader accounts**: For consumers without Snowflake

### Time Travel & Fail-Safe
- **Time Travel**: 1 day (Standard), up to 90 days (Enterprise)
- **Fail-Safe**: 7 days, non-configurable, Snowflake Support only
- **Transient**: Max 1 day Time Travel, no Fail-Safe
- **Temporary**: No Time Travel or Fail-Safe

### Cloning
- **Zero-copy**: Instant, shares micro-partitions
- **Copy-on-write**: Storage increases only for changes
- **Not cloned**: Streams, tasks, pipes, grants
- **Independence**: Clones don't affect source

---

## 💻 Comprehensive Governance Lab (40 min)

Complete the lab in `exercise.sql`.

### Lab Overview

Build a complete security and governance framework including:

1. **Role Hierarchy** (10 min)
   - Create organizational role structure
   - Implement least privilege access
   - Set up future grants

2. **Data Protection** (10 min)
   - Apply masking policies to PII
   - Implement row-level security
   - Create secure views for sharing

3. **Data Recovery** (10 min)
   - Configure Time Travel retention
   - Test data recovery scenarios
   - Create backup strategy with clones

4. **Monitoring & Auditing** (10 min)
   - Build audit queries
   - Monitor access patterns
   - Track policy effectiveness

---

## ✅ Week 3 Review Quiz (30 min)

Take the comprehensive 50-question quiz in `quiz.md`.

**Quiz Breakdown:**
- RBAC & Access Control: 8 questions
- Data Masking & Privacy: 8 questions
- Row Access Policies: 8 questions
- Data Sharing & Secure Views: 8 questions
- Time Travel & Fail-Safe: 9 questions
- Cloning & Zero-Copy: 9 questions

**Passing Score:** 35/50 (70%)

---

## 🎯 Week 3 Success Criteria

Check off each item as you complete it:

### Knowledge Mastery
- [ ] Can explain RBAC hierarchy and role inheritance
- [ ] Understand when to use masking vs. row access policies
- [ ] Know the difference between Time Travel and Fail-Safe
- [ ] Can explain zero-copy cloning and storage implications
- [ ] Understand secure data sharing architecture

### Hands-On Skills
- [ ] Created complete role hierarchy
- [ ] Applied masking policies to sensitive data
- [ ] Implemented row-level security
- [ ] Created and managed data shares
- [ ] Used Time Travel for data recovery
- [ ] Cloned databases for dev/test environments

### Quiz Performance
- [ ] Scored 70%+ on Week 3 review quiz
- [ ] Understand all incorrect answers
- [ ] Can explain concepts in your own words

### Lab Completion
- [ ] Built end-to-end governance framework
- [ ] Tested all security policies
- [ ] Created monitoring queries
- [ ] Documented security architecture

---

## Common Mistakes to Avoid

### RBAC Mistakes
❌ Granting privileges directly to users instead of roles  
✅ Always grant to roles, then assign roles to users

❌ Using ACCOUNTADMIN for daily operations  
✅ Use custom roles with least privilege

❌ Forgetting USAGE privilege on database/schema  
✅ Always grant USAGE before object privileges

### Masking Mistakes
❌ Applying masking to columns used in WHERE clauses  
✅ Consider query performance impact

❌ Not testing masking with different roles  
✅ Test as each role to verify behavior

❌ Masking primary/foreign keys  
✅ Mask display data, not join keys

### Row Access Policy Mistakes
❌ Creating overly complex policies  
✅ Use mapping tables for complex logic

❌ Not considering performance impact  
✅ Test with large datasets

❌ Forgetting to handle NULL values  
✅ Always handle NULL cases in policies

### Time Travel Mistakes
❌ Assuming Time Travel is free  
✅ Monitor storage costs

❌ Not configuring retention appropriately  
✅ Set retention based on data criticality

❌ Trying to query beyond retention period  
✅ Check retention settings first

### Cloning Mistakes
❌ Assuming clones are free forever  
✅ Storage increases as data diverges

❌ Not cleaning up old clones  
✅ Implement cleanup procedures

❌ Expecting streams/tasks to be cloned  
✅ Recreate these objects after cloning

---

## Exam Preparation Tips

### What to Focus On

**High Priority (35% of exam):**
1. RBAC hierarchy and privilege management
2. Masking policies and row access policies
3. Time Travel syntax and use cases
4. Zero-copy cloning concepts

**Medium Priority (20% of exam):**
1. Data sharing architecture
2. Secure views
3. Fail-Safe vs. Time Travel
4. Storage cost implications

**Lower Priority (10% of exam):**
1. Specific masking functions
2. Reader account details
3. Advanced cloning scenarios

### Practice Scenarios

**Scenario 1: Security Implementation**
- Given: New application with PII data
- Task: Design complete security framework
- Consider: RBAC, masking, row access, auditing

**Scenario 2: Data Recovery**
- Given: Accidental data deletion 3 hours ago
- Task: Recover data with minimal downtime
- Consider: Time Travel, cloning, validation

**Scenario 3: Dev Environment**
- Given: Need isolated dev environment
- Task: Create dev environment from production
- Consider: Cloning, permissions, cost

**Scenario 4: Data Sharing**
- Given: Share data with external partner
- Task: Share securely without exposing PII
- Consider: Secure views, masking, row access

---

## Study Resources

### Official Documentation
- [Access Control](https://docs.snowflake.com/en/user-guide/security-access-control)
- [Data Masking](https://docs.snowflake.com/en/user-guide/security-column-ddm)
- [Row Access Policies](https://docs.snowflake.com/en/user-guide/security-row)
- [Data Sharing](https://docs.snowflake.com/en/user-guide/data-sharing-intro)
- [Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel)
- [Cloning](https://docs.snowflake.com/en/user-guide/object-clone)

### Review Materials
- Re-read Days 15-20 README files
- Review all quiz questions and explanations
- Practice all exercises again
- Review solution.sql files for best practices

---

## Week 3 Reflection

Take 10 minutes to reflect on your learning:

### What I Learned Well
- [ ] Topic 1: _______________
- [ ] Topic 2: _______________
- [ ] Topic 3: _______________

### What Needs More Practice
- [ ] Topic 1: _______________
- [ ] Topic 2: _______________
- [ ] Topic 3: _______________

### Questions I Still Have
1. _______________
2. _______________
3. _______________

### Action Items
- [ ] Review weak areas identified in quiz
- [ ] Practice hands-on exercises for difficult topics
- [ ] Create flashcards for key concepts
- [ ] Schedule time to revisit challenging material

---

## 🔜 Next Week: Week 4 - Advanced Features & Exam Prep

**Week 4 Preview:**
- Day 22: External Tables & External Functions
- Day 23: Stored Procedures & UDFs
- Day 24: Snowpark for Data Engineering
- Day 25: Hands-On Project Day
- Day 26: Practice Exam 1 (65 questions)
- Day 27: Practice Exam 2 (65 questions)
- Day 28: Week 4 Review & Final Preparation
- Day 29: Final Review & Confidence Builder
- Day 30: Certification Exam Day

**Preparation for Week 4:**
- Ensure you're comfortable with all Week 1-3 topics
- Review any weak areas before starting Week 4
- Get ready for intensive exam preparation
- Plan your exam date (after Day 30)

---

## Congratulations! 🎉

You've completed Week 3 and mastered data governance and security in Snowflake!

**Week 3 Achievements:**
✅ Mastered RBAC and access control  
✅ Implemented data masking and privacy  
✅ Applied row-level security  
✅ Created secure data shares  
✅ Used Time Travel for data recovery  
✅ Leveraged zero-copy cloning  

**You're now 70% through the bootcamp!**

Take a well-deserved break before starting Week 4. You're on track to pass the SnowPro Advanced: Data Engineer certification! 💪
