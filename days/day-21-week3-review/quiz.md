# Day 21 Quiz: Week 3 Review - Security & Governance

## Instructions
- 50 comprehensive review questions covering Days 15-20
- Choose the best answer for each question
- Answers and explanations at the end
- Passing score: 35/50 (70%)
- Time limit: 30 minutes (practice for exam pace)

---

## Section 1: RBAC & Access Control (8 questions)

### Question 1
Which system role should be used for creating and managing other roles?

A) ACCOUNTADMIN  
B) SECURITYADMIN  
C) SYSADMIN  
D) USERADMIN

### Question 2
What privilege is required on a database before you can grant SELECT on tables within it?

A) OWNERSHIP  
B) ALL  
C) USAGE  
D) REFERENCES

### Question 3
You want new tables created in a schema to automatically grant SELECT to a role. Which feature should you use?

A) DEFAULT GRANTS  
B) FUTURE GRANTS  
C) AUTO GRANTS  
D) INHERITED GRANTS

### Question 4
In the role hierarchy, which statement is TRUE?

A) Child roles inherit privileges from parent roles  
B) Parent roles inherit privileges from child roles  
C) Roles at the same level share all privileges  
D) Role inheritance is bidirectional

### Question 5
A user has been granted ROLE_A and ROLE_B. ROLE_A has SELECT on TABLE1, ROLE_B has INSERT on TABLE1. What can the user do?

A) Only SELECT (first role granted takes precedence)  
B) Only INSERT (last role granted takes precedence)  
C) Both SELECT and INSERT (privileges are cumulative)  
D) Neither (conflicting grants cancel each other)

### Question 6
Which role should regular users NEVER be granted directly?

A) PUBLIC  
B) SYSADMIN  
C) ACCOUNTADMIN  
D) Both B and C

### Question 7
You grant USAGE on a database to a role, but users still can't query tables. What's missing?

A) SELECT privilege on tables  
B) USAGE privilege on schema  
C) Both A and B  
D) REFERENCES privilege on database

### Question 8
What is the best practice for granting privileges to users?

A) Grant privileges directly to users  
B) Grant privileges to roles, then assign roles to users  
C) Use PUBLIC role for all common privileges  
D) Grant ACCOUNTADMIN to power users

---

## Section 2: Data Masking & Privacy (8 questions)

### Question 9
When is a masking policy applied to data?

A) When data is written to the table  
B) When data is queried (at query time)  
C) When the table is created  
D) During nightly batch processing

### Question 10
Which function is commonly used to mask email addresses?

A) ENCRYPT()  
B) HASH()  
C) REGEXP_REPLACE()  
D) MASK_EMAIL()

### Question 11
A masking policy returns different values based on CURRENT_ROLE(). What type of masking is this?

A) Static masking  
B) Dynamic masking  
C) Conditional masking  
D) Role-based masking

### Question 12
Can you apply multiple masking policies to a single column?

A) Yes, they are applied in sequence  
B) Yes, but only if they don't conflict  
C) No, only one masking policy per column  
D) Yes, up to 5 policies per column

### Question 13
Which compliance regulation specifically requires protection of credit card data?

A) GDPR  
B) HIPAA  
C) PCI-DSS  
D) SOX

### Question 14
What happens to masked data in query results?

A) It's encrypted and requires a key to decrypt  
B) It's replaced with the masked value  
C) It's removed from results entirely  
D) It's flagged with a warning message

### Question 15
Which role can see unmasked data if a masking policy checks for ACCOUNTADMIN?

A) Only ACCOUNTADMIN  
B) ACCOUNTADMIN and roles it's granted to  
C) Any role with OWNERSHIP on the table  
D) Any role with SELECT privilege

### Question 16
What's the performance impact of masking policies?

A) Significant (50%+ slower queries)  
B) Moderate (10-20% slower)  
C) Minimal (evaluated per row)  
D) None (masking is pre-computed)

---

## Section 3: Row Access Policies (8 questions)

### Question 17
How many row access policies can be applied to a single table?

A) Unlimited  
B) Up to 5  
C) Up to 10  
D) Only 1

### Question 18
What must a row access policy return?

A) STRING  
B) INTEGER  
C) BOOLEAN  
D) VARIANT

### Question 19
A row access policy filters rows based on region. Users in NORTH role see only NORTH region data. What is this called?

A) Data partitioning  
B) Multi-tenant isolation  
C) Horizontal filtering  
D) Region-based sharding

### Question 20
What's the recommended approach for complex row access logic?

A) Write complex CASE statements in the policy  
B) Use multiple policies  
C) Use a mapping table  
D) Use stored procedures

### Question 21
Can you combine row access policies with masking policies on the same table?

A) No, only one type of policy per table  
B) Yes, but they must be created in specific order  
C) Yes, they work independently  
D) Yes, but only with ACCOUNTADMIN approval

### Question 22
What happens if a row access policy returns NULL?

A) The row is included  
B) The row is excluded  
C) An error is raised  
D) NULL is treated as FALSE

### Question 23
Which scenario is BEST suited for row access policies?

A) Hiding sensitive columns  
B) Restricting access to specific rows based on user attributes  
C) Encrypting data at rest  
D) Compressing large tables

### Question 24
What's a potential performance concern with row access policies?

A) They require additional storage  
B) They can impact query performance if complex  
C) They prevent partition pruning  
D) They disable result caching

---

## Section 4: Data Sharing & Secure Views (8 questions)

### Question 25
What does "zero-copy" mean in Snowflake data sharing?

A) Data is compressed before sharing  
B) Data is not physically copied to consumer account  
C) Data is cached for faster access  
D) Data is encrypted during transfer

### Question 26
What is a reader account?

A) A role with read-only access  
B) An account for consumers without Snowflake  
C) A special type of service account  
D) An account that can only read shares

### Question 27
What makes a view "secure"?

A) It requires authentication to query  
B) Its definition is hidden from unauthorized users  
C) It automatically masks sensitive data  
D) It can only be accessed via SSL

### Question 28
Can you share a table that has a row access policy applied?

A) No, policies must be removed first  
B) Yes, and the policy applies to consumers  
C) Yes, but consumers see all rows  
D) Yes, but you must create a new policy for consumers

### Question 29
What can be shared using Snowflake's data sharing feature?

A) Tables only  
B) Tables and views only  
C) Tables, views, and secure views  
D) Tables, views, secure views, and UDFs

### Question 30
How do consumers see updates to shared data?

A) They must manually refresh  
B) Updates are batched daily  
C) They see updates in real-time  
D) Updates require re-sharing

### Question 31
Which statement about data sharing costs is TRUE?

A) Provider pays for consumer's compute  
B) Consumer pays for their own compute  
C) Costs are split 50/50  
D) Sharing is free for both parties

### Question 32
What's the best practice for sharing sensitive data?

A) Share raw tables directly  
B) Create secure views that filter/mask data  
C) Encrypt data before sharing  
D) Use reader accounts only

---

## Section 5: Time Travel & Fail-Safe (9 questions)

### Question 33
What is the maximum Time Travel retention period in Enterprise Edition?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days

### Question 34
How long is the Fail-Safe period?

A) 1 day  
B) 7 days  
C) 30 days  
D) 90 days

### Question 35
Who can access data in Fail-Safe?

A) ACCOUNTADMIN only  
B) Any user with SELECT privilege  
C) Snowflake Support only  
D) SECURITYADMIN only

### Question 36
Which syntax queries data as it was 1 hour ago?

A) `SELECT * FROM table AT(OFFSET => -3600);`  
B) `SELECT * FROM table AT(HOURS => -1);`  
C) `SELECT * FROM table TIME_TRAVEL(-3600);`  
D) `SELECT * FROM table BEFORE(HOURS => 1);`

### Question 37
What is the Time Travel retention for transient tables?

A) 0 days (no Time Travel)  
B) Maximum 1 day  
C) Same as permanent tables  
D) 7 days fixed

### Question 38
Which command recovers a dropped table?

A) RESTORE TABLE  
B) UNDROP TABLE  
C) RECOVER TABLE  
D) UNDELETE TABLE

### Question 39
What happens to Time Travel data after the retention period expires?

A) It's immediately deleted  
B) It moves to Fail-Safe  
C) It's archived to cheaper storage  
D) It requires manual deletion

### Question 40
Which table type has NO Fail-Safe?

A) Permanent tables  
B) Transient tables  
C) Temporary tables  
D) Both B and C

### Question 41
What's the primary cost consideration for Time Travel?

A) Compute costs for historical queries  
B) Storage costs for retained data  
C) Network costs for data transfer  
D) Licensing costs per day of retention

---

## Section 6: Cloning & Zero-Copy (9 questions)

### Question 42
What does "zero-copy" mean for cloning?

A) Clones are read-only  
B) No data is physically copied at creation  
C) Clones don't consume any storage ever  
D) Cloning is free

### Question 43
When does a clone start consuming storage?

A) Immediately at creation  
B) After 24 hours  
C) When data diverges from source (copy-on-write)  
D) Only if explicitly configured

### Question 44
Which objects are NOT cloned when you clone a database?

A) Tables  
B) Views  
C) Streams and tasks  
D) Schemas

### Question 45
How long does it take to clone a 10 TB database?

A) Several hours  
B) About 1 hour  
C) About 10 minutes  
D) Seconds (instant)

### Question 46
Can you clone a table from a specific point in time?

A) No, only current state can be cloned  
B) Yes, using Time Travel with AT or BEFORE clause  
C) Yes, but only within last 24 hours  
D) Yes, but requires ACCOUNTADMIN

### Question 47
What happens to grants when you clone a table?

A) Grants are cloned automatically  
B) Grants must be manually re-applied  
C) Grants are inherited from source  
D) Grants are copied but disabled

### Question 48
Which is the BEST use case for cloning?

A) Backing up data for long-term retention  
B) Creating dev/test environments from production  
C) Reducing storage costs  
D) Improving query performance

### Question 49
You clone a table, then modify 20% of the rows in the clone. How much storage does the clone consume?

A) 0% (zero-copy)  
B) Approximately 20% of source table size  
C) 50% of source table size  
D) 100% of source table size

### Question 50
What's the relationship between a clone and its source after creation?

A) Clone is dependent on source  
B) Clone and source are completely independent  
C) Clone is read-only copy of source  
D) Clone automatically syncs with source changes

---

## Answer Key

### Section 1: RBAC & Access Control

**Question 1: B**  
SECURITYADMIN is the role specifically designed for creating and managing roles and grants. While ACCOUNTADMIN can also do this, SECURITYADMIN is the appropriate role for security operations.

**Question 2: C**  
USAGE privilege is required on both the database and schema before you can access objects within them. This is a fundamental concept in Snowflake's privilege model.

**Question 3: B**  
FUTURE GRANTS automatically apply privileges to objects created in the future. This is essential for maintaining consistent access control as new tables are created.

**Question 4: B**  
In Snowflake, parent roles inherit privileges from child roles. When you grant ROLE_A to ROLE_B, ROLE_B (parent) inherits all privileges of ROLE_A (child).

**Question 5: C**  
Privileges are cumulative. When a user has multiple roles, they get the union of all privileges from those roles.

**Question 6: D**  
Both SYSADMIN and ACCOUNTADMIN should never be granted directly to regular users. These are administrative roles that should be used sparingly and only by administrators.

**Question 7: C**  
Both USAGE on the schema AND SELECT on the tables are required. USAGE on database alone is not sufficient.

**Question 8: B**  
Best practice is to grant privileges to roles, then assign roles to users. This provides better management and follows the principle of role-based access control.

### Section 2: Data Masking & Privacy

**Question 9: B**  
Masking policies are applied at query time (dynamically). The underlying data is never modified; masking happens when data is retrieved.

**Question 10: C**  
REGEXP_REPLACE() is commonly used to mask email addresses by replacing parts of the string with asterisks or other characters.

**Question 11: C**  
Conditional masking returns different values based on conditions like CURRENT_ROLE(). This allows different roles to see different levels of data masking.

**Question 12: C**  
Only one masking policy can be applied per column. If you need different masking logic, you must modify the existing policy.

**Question 13: C**  
PCI-DSS (Payment Card Industry Data Security Standard) specifically requires protection of credit card data.

**Question 14: B**  
Masked data is replaced with the masked value in query results. The original data remains unchanged in storage.

**Question 15: A**  
Only ACCOUNTADMIN can see unmasked data if the policy specifically checks for ACCOUNTADMIN role. Role inheritance doesn't apply to masking policy conditions.

**Question 16: C**  
Masking policies have minimal performance impact as they're evaluated per row during query execution. The overhead is typically negligible.

### Section 3: Row Access Policies

**Question 17: D**  
Only one row access policy can be applied to a table at a time. This is a key limitation to remember.

**Question 18: C**  
Row access policies must return a BOOLEAN value (TRUE to include the row, FALSE to exclude it).

**Question 19: B**  
Multi-tenant isolation is the pattern where different users/tenants can only see their own data within a shared table.

**Question 20: C**  
Using a mapping table is the recommended approach for complex row access logic. It's more maintainable and performant than complex CASE statements.

**Question 21: C**  
Yes, row access policies and masking policies work independently and can be combined on the same table. Row access filters rows, masking hides column values.

**Question 22: D**  
NULL is treated as FALSE in row access policies, meaning the row is excluded.

**Question 23: B**  
Row access policies are best for restricting access to specific rows based on user attributes (like region, department, tenant ID).

**Question 24: B**  
Complex row access policies can impact query performance, especially if they involve subqueries or joins to mapping tables.

### Section 4: Data Sharing & Secure Views

**Question 25: B**  
Zero-copy means data is not physically copied to the consumer's account. Consumers query the provider's data directly.

**Question 26: B**  
A reader account is a special account type for consumers who don't have their own Snowflake account. The provider manages and pays for it.

**Question 27: B**  
A secure view hides its definition from unauthorized users and prevents certain optimizations that might expose the underlying data.

**Question 28: B**  
Yes, you can share tables with row access policies, and the policy applies to consumers, ensuring they only see authorized rows.

**Question 29: C**  
Tables, views, and secure views can be shared. UDFs and other objects cannot be directly shared.

**Question 30: C**  
Consumers see updates to shared data in real-time. Data sharing provides live access to the provider's data.

**Question 31: B**  
The consumer pays for their own compute costs when querying shared data. The provider pays for storage.

**Question 32: B**  
Best practice is to create secure views that filter and/or mask sensitive data before sharing, rather than sharing raw tables.

### Section 5: Time Travel & Fail-Safe

**Question 33: D**  
Enterprise Edition supports up to 90 days of Time Travel retention. Standard Edition supports up to 1 day.

**Question 34: B**  
Fail-Safe is always 7 days and is non-configurable.

**Question 35: C**  
Only Snowflake Support can access data in Fail-Safe. It's for disaster recovery only.

**Question 36: A**  
`AT(OFFSET => -3600)` queries data from 3600 seconds (1 hour) ago. The offset is in seconds and negative values go back in time.

**Question 37: B**  
Transient tables have a maximum of 1 day Time Travel retention and no Fail-Safe.

**Question 38: B**  
UNDROP TABLE recovers a dropped table within the Time Travel retention period.

**Question 39: B**  
After Time Travel retention expires, data moves to Fail-Safe for an additional 7 days before permanent deletion.

**Question 40: D**  
Both transient and temporary tables have no Fail-Safe. Only permanent tables have Fail-Safe.

**Question 41: B**  
The primary cost consideration is storage costs for retained data. Both Time Travel and Fail-Safe data consume storage.

### Section 6: Cloning & Zero-Copy

**Question 42: B**  
Zero-copy means no data is physically copied at creation time. The clone initially shares micro-partitions with the source.

**Question 43: C**  
Clones consume storage only when data diverges from the source through inserts, updates, or deletes (copy-on-write behavior).

**Question 44: C**  
Streams, tasks, pipes, and external stages are NOT cloned. Only tables, views, and schemas are cloned.

**Question 45: D**  
Cloning is instant regardless of database size. It takes only seconds because it's a metadata operation.

**Question 46: B**  
Yes, you can combine cloning with Time Travel using AT or BEFORE clauses to clone from a specific point in time.

**Question 47: B**  
Grants are NOT cloned. You must manually re-grant privileges on cloned objects.

**Question 48: B**  
Creating dev/test environments from production is the best use case. Cloning provides instant, isolated copies perfect for testing.

**Question 49: B**  
The clone consumes approximately 20% of the source table size (only the modified data). This is the copy-on-write behavior.

**Question 50: B**  
After creation, clone and source are completely independent. Changes to one don't affect the other.

---

## Scoring Guide

- **45-50 correct (90-100%)**: Outstanding! You've mastered Week 3 concepts.
- **40-44 correct (80-89%)**: Excellent! You're well-prepared for the exam.
- **35-39 correct (70-79%)**: Good! Review the questions you missed.
- **30-34 correct (60-69%)**: Fair. Review Week 3 materials and retry.
- **Below 30 (< 60%)**: Review all Week 3 days and complete exercises again.

---

## Week 3 Mastery Checklist

Based on your quiz results, check off topics you've mastered:

### RBAC & Access Control
- [ ] Role hierarchy and inheritance
- [ ] USAGE privilege requirements
- [ ] Future grants
- [ ] Best practices for privilege management

### Data Masking
- [ ] Dynamic masking at query time
- [ ] Conditional masking based on roles
- [ ] Masking policy syntax
- [ ] Compliance requirements (GDPR, PCI-DSS, HIPAA)

### Row Access Policies
- [ ] One policy per table limitation
- [ ] Boolean return requirement
- [ ] Mapping tables for complex logic
- [ ] Combining with masking policies

### Data Sharing
- [ ] Zero-copy architecture
- [ ] Reader accounts
- [ ] Secure views
- [ ] Real-time data access

### Time Travel & Fail-Safe
- [ ] Retention periods (1-90 days vs. 7 days)
- [ ] AT and BEFORE syntax
- [ ] UNDROP command
- [ ] Transient vs. permanent tables

### Cloning
- [ ] Zero-copy cloning concept
- [ ] Copy-on-write behavior
- [ ] What gets cloned vs. what doesn't
- [ ] Combining with Time Travel

---

## Study Recommendations

### If you scored 90%+
✅ You're ready for Week 4!  
✅ Consider helping others in study groups  
✅ Focus on advanced topics and practice exams

### If you scored 70-89%
📚 Review questions you missed  
📚 Re-read relevant sections in Days 15-20  
📚 Practice hands-on exercises again  
📚 Create flashcards for key concepts

### If you scored below 70%
🔄 Re-read all Week 3 README files  
🔄 Complete all hands-on exercises again  
🔄 Watch Snowflake documentation videos  
🔄 Retake quiz after review  
🔄 Consider extending study time for Week 3

---

## Next Steps

**Congratulations on completing Week 3!** 🎉

You're now 70% through the bootcamp and have mastered critical security and governance concepts.

**Week 4 Preview:**
- Day 22: External Tables & External Functions
- Day 23: Stored Procedures & UDFs
- Day 24: Snowpark for Data Engineering
- Day 25: Hands-On Project Day
- Day 26-27: Practice Exams (65 questions each)
- Day 28-30: Final Review & Exam

**Prepare for Week 4:**
- Take a day off if needed
- Review any weak areas from this quiz
- Get ready for advanced topics and intensive exam prep
- Plan your certification exam date

**You're on track to pass the SnowPro Advanced: Data Engineer certification!** 💪
