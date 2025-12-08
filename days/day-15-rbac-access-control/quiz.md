# Day 15 Quiz: Role-Based Access Control (RBAC)

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the highest privilege role in Snowflake?

A) SYSADMIN  
B) SECURITYADMIN  
C) ACCOUNTADMIN  
D) USERADMIN  

**Your answer:**

---

### 2. Which role should be used for day-to-day object creation?

A) ACCOUNTADMIN  
B) SECURITYADMIN  
C) SYSADMIN  
D) PUBLIC  

**Your answer:**

---

### 3. What privilege is required to access a database or schema?

A) SELECT  
B) USAGE  
C) READ  
D) ACCESS  

**Your answer:**

---

### 4. Which role is automatically granted to all users?

A) SYSADMIN  
B) USERADMIN  
C) PUBLIC  
D) DEFAULT  

**Your answer:**

---

### 5. What does a future grant do?

A) Grants privileges on objects that will be created later  
B) Schedules grants for a future date  
C) Grants privileges for a limited time  
D) Predicts what grants are needed  

**Your answer:**

---

### 6. How many owners can an object have?

A) None  
B) Exactly one (a role)  
C) Multiple roles  
D) One user  

**Your answer:**

---

### 7. Which command shows privileges granted TO a role?

A) SHOW GRANTS OF ROLE role_name  
B) SHOW GRANTS TO ROLE role_name  
C) SHOW ROLE GRANTS role_name  
D) DESCRIBE ROLE role_name  

**Your answer:**

---

### 8. What happens when you grant a child role to a parent role?

A) Parent inherits child's privileges  
B) Child inherits parent's privileges  
C) No inheritance occurs  
D) Both roles merge  

**Your answer:**

---

### 9. Which role manages users and roles but cannot grant object privileges?

A) ACCOUNTADMIN  
B) SECURITYADMIN  
C) USERADMIN  
D) SYSADMIN  

**Your answer:**

---

### 10. What is the best practice for granting privileges?

A) Grant everything to everyone  
B) Grant only to users, not roles  
C) Use least privilege principle  
D) Always use ACCOUNTADMIN  

**Your answer:**

---

## Answer Key

1. **C** - ACCOUNTADMIN
2. **C** - SYSADMIN
3. **B** - USAGE
4. **C** - PUBLIC
5. **A** - Grants privileges on objects that will be created later
6. **B** - Exactly one (a role)
7. **B** - SHOW GRANTS TO ROLE role_name
8. **A** - Parent inherits child's privileges
9. **C** - USERADMIN
10. **C** - Use least privilege principle

---

## Score Yourself

- 9-10/10: Excellent! You understand RBAC thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **System Roles**: ACCOUNTADMIN > SECURITYADMIN > USERADMIN, SYSADMIN > Custom Roles > PUBLIC  
✅ **USAGE Privilege**: Required for database/schema access  
✅ **Role Hierarchy**: Parent roles inherit child role privileges  
✅ **Future Grants**: Automate privilege assignment for new objects  
✅ **Ownership**: Every object has exactly one owner (a role)  
✅ **Least Privilege**: Grant only what's needed  
✅ **ACCOUNTADMIN**: Use sparingly, only for account-level tasks  
✅ **SYSADMIN**: Use for object creation and management  
✅ **PUBLIC**: Granted to all users, use carefully  
✅ **Auditing**: Use SHOW GRANTS and ACCOUNT_USAGE views  

## Exam Tips

**Common exam question patterns:**
- System role hierarchy and purposes
- USAGE privilege requirements
- Future grants syntax and behavior
- Role inheritance direction
- Ownership rules
- Best practices for role management
- Difference between SHOW GRANTS TO vs. OF
- When to use each system role
- PUBLIC role implications
- Privilege escalation scenarios

**Remember for the exam:**
- ACCOUNTADMIN: Highest privilege, use sparingly
- SECURITYADMIN: Manages users/roles, grants privileges
- USERADMIN: Creates users/roles only
- SYSADMIN: Creates objects, day-to-day admin
- PUBLIC: All users, be careful with grants
- USAGE: Required for database/schema access
- Future grants: ON FUTURE TABLES IN SCHEMA...
- Role hierarchy: Child → Parent (parent inherits)
- Ownership: Exactly one role per object
- SHOW GRANTS TO: What role has
- SHOW GRANTS OF: Child roles of role

## Next Steps

- If you scored 8-10: Move to Day 16 (Data Masking & Privacy)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Create a three-tier role hierarchy
2. Grant database access with USAGE
3. Set up future grants for new tables
4. Transfer object ownership
5. Audit who has access to a table
6. Create department-specific roles
7. Grant warehouse access to roles
8. Test role switching and privileges

## Real-World Applications

**Enterprise Role Structure:**
```
ACCOUNTADMIN (2 users)
    ↓
SECURITYADMIN (Security team)
    ↓
USERADMIN (HR team)

SYSADMIN (Admin team)
    ↓
data_engineer (Engineering team)
    ↓
data_analyst (Analytics team)
    ↓
data_viewer (Business users)
    ↓
PUBLIC (Everyone)
```

**Department-Based Access:**
- Sales team: Access to sales_db only
- Finance team: Access to finance_db only
- Executive team: Access to all databases
- Use role hierarchy for inheritance

**Service Account Roles:**
- etl_service_role: Read/write for ETL processes
- bi_service_role: Read-only for BI tools
- api_service_role: Specific API access
- Grant only necessary privileges

**Development Workflow:**
- dev_role: Full access to dev_db
- test_role: Full access to test_db
- prod_readonly_role: Read-only access to prod_db
- prod_admin_role: Full access to prod_db (limited users)

**Best Practices Checklist:**
- [ ] Use SYSADMIN for object creation
- [ ] Limit ACCOUNTADMIN to 1-2 users
- [ ] Create role hierarchies for inheritance
- [ ] Grant USAGE on database/schema
- [ ] Use future grants for automation
- [ ] Apply least privilege principle
- [ ] Regular access audits
- [ ] Document role purposes
- [ ] Grant to roles, not users
- [ ] Transfer ownership to SYSADMIN

**Common Mistakes to Avoid:**
1. ❌ Using ACCOUNTADMIN for daily tasks
2. ❌ Granting privileges to PUBLIC carelessly
3. ❌ Forgetting USAGE privilege on database/schema
4. ❌ Granting directly to users instead of roles
5. ❌ Not using future grants
6. ❌ Over-privileging roles
7. ❌ Not auditing access regularly
8. ❌ Creating objects as ACCOUNTADMIN

**Troubleshooting Access Issues:**

**Issue**: "Object does not exist"
- **Cause**: Missing USAGE on database or schema
- **Fix**: GRANT USAGE ON DATABASE/SCHEMA

**Issue**: "Insufficient privileges"
- **Cause**: Missing required privilege
- **Fix**: GRANT appropriate privilege

**Issue**: "Cannot perform operation"
- **Cause**: Using wrong role
- **Fix**: USE ROLE appropriate_role

**Issue**: "Access denied"
- **Cause**: Role not granted to user
- **Fix**: GRANT ROLE TO USER

**Audit Queries:**

```sql
-- View role hierarchy
SELECT grantee_name, role, granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE granted_on = 'ROLE' AND deleted_on IS NULL;

-- View object privileges
SELECT grantee_name, privilege, name
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE granted_on = 'TABLE' AND deleted_on IS NULL;

-- View user roles
SHOW GRANTS TO USER username;

-- View role privileges
SHOW GRANTS TO ROLE rolename;

-- View object access
SHOW GRANTS ON TABLE tablename;
```

**Security Recommendations:**
1. Assign ACCOUNTADMIN to 1-2 trusted users
2. Use MFA for ACCOUNTADMIN users
3. Create custom roles for specific functions
4. Use role hierarchies for efficiency
5. Grant privileges to roles, not users
6. Use future grants for automation
7. Regular access reviews (quarterly)
8. Document role purposes and owners
9. Implement approval process for privilege grants
10. Monitor privilege usage with ACCOUNT_USAGE

**Role Naming Conventions:**
- Functional: `etl_role`, `bi_role`, `api_role`
- Department: `sales_team`, `finance_team`, `hr_team`
- Access level: `viewer_role`, `editor_role`, `admin_role`
- Environment: `dev_role`, `test_role`, `prod_role`
- Service: `service_etl`, `service_bi`, `service_api`

**Privilege Grant Patterns:**

**Read-Only Access:**
```sql
GRANT USAGE ON DATABASE db TO ROLE reader;
GRANT USAGE ON SCHEMA db.schema TO ROLE reader;
GRANT SELECT ON ALL TABLES IN SCHEMA db.schema TO ROLE reader;
GRANT SELECT ON FUTURE TABLES IN SCHEMA db.schema TO ROLE reader;
```

**Read-Write Access:**
```sql
GRANT ROLE reader TO ROLE writer;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA db.schema TO ROLE writer;
GRANT INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA db.schema TO ROLE writer;
```

**Admin Access:**
```sql
GRANT ROLE writer TO ROLE admin;
GRANT ALL ON SCHEMA db.schema TO ROLE admin;
GRANT CREATE TABLE ON SCHEMA db.schema TO ROLE admin;
```

**Compliance Considerations:**
- SOX: Separate duties, audit access
- GDPR: Control access to personal data
- HIPAA: Restrict access to PHI
- PCI-DSS: Limit access to cardholder data
- Regular access reviews required
- Document access justifications
- Implement least privilege
- Monitor and log access

**Next Steps:**
Tomorrow we'll learn about Data Masking & Privacy to protect sensitive data while maintaining access for authorized users.
