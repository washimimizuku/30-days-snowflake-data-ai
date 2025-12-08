# Day 17 Quiz: Row Access Policies

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What do row access policies control?

A) Which columns users can see  
B) Which rows users can see  
C) Which tables users can access  
D) Which databases users can query  

**Your answer:**

---

### 2. What must a row access policy return?

A) STRING  
B) NUMBER  
C) BOOLEAN  
D) DATE  

**Your answer:**

---

### 3. What does TRUE mean in a row access policy?

A) Hide the row  
B) Show the row  
C) Mask the row  
D) Delete the row  

**Your answer:**

---

### 4. How do you apply a row access policy to a table?

A) CREATE POLICY ON table  
B) ALTER TABLE ... ADD ROW ACCESS POLICY ... ON (column)  
C) GRANT ROW ACCESS POLICY TO table  
D) SET ROW ACCESS POLICY = policy_name  

**Your answer:**

---

### 5. Can a row access policy reference multiple columns?

A) No, only one column  
B) Yes, multiple columns allowed  
C) Only two columns maximum  
D) Only if columns are same type  

**Your answer:**

---

### 6. What is a common use case for row access policies?

A) Encrypting data  
B) Multi-tenant data isolation  
C) Compressing data  
D) Backing up data  

**Your answer:**

---

### 7. Can row access and masking policies be used together?

A) No, they conflict  
B) Yes, they complement each other  
C) Only on views  
D) Only with ACCOUNTADMIN  

**Your answer:**

---

### 8. What is required before dropping a row access policy?

A) Nothing, can drop anytime  
B) Must remove from all tables first  
C) Must delete all data first  
D) Must recreate the table  

**Your answer:**

---

### 9. Which function is commonly used in row access policies?

A) CURRENT_USER()  
B) CURRENT_ROLE()  
C) CURRENT_SESSION_PARAMETER()  
D) All of the above  

**Your answer:**

---

### 10. What is the benefit of using mapping tables with row access policies?

A) Faster queries  
B) Flexible access control without changing policies  
C) Reduced storage  
D) Automatic backups  

**Your answer:**

---

## Answer Key

1. **B** - Which rows users can see
2. **C** - BOOLEAN
3. **B** - Show the row
4. **B** - ALTER TABLE ... ADD ROW ACCESS POLICY ... ON (column)
5. **B** - Yes, multiple columns allowed
6. **B** - Multi-tenant data isolation
7. **B** - Yes, they complement each other
8. **B** - Must remove from all tables first
9. **D** - All of the above
10. **B** - Flexible access control without changing policies

---

## Score Yourself

- 9-10/10: Excellent! You understand row access policies thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Row Access Policies**: Control which rows users can see  
✅ **Return Type**: Must return BOOLEAN (TRUE = show, FALSE = hide)  
✅ **Application**: ALTER TABLE ADD ROW ACCESS POLICY ON (column)  
✅ **Multi-Column**: Can reference multiple columns  
✅ **Use Cases**: Multi-tenant isolation, regional access, department filtering  
✅ **Combination**: Works with masking policies  
✅ **Functions**: CURRENT_ROLE(), CURRENT_USER(), CURRENT_SESSION_PARAMETER()  
✅ **Mapping Tables**: Provide flexible access control  
✅ **Removal**: Must drop from tables before dropping policy  
✅ **Transparency**: Transparent to applications  

## Exam Tips

**Common exam question patterns:**
- Row access vs. masking policies
- Return type (BOOLEAN)
- How to apply/remove policies
- Multi-column policy syntax
- Use cases (multi-tenant, regional)
- Combining with masking policies
- Mapping table benefits
- Performance considerations
- Policy testing approaches
- Audit and monitoring

**Remember for the exam:**
- Row access = row filtering
- Masking = column value hiding
- Return BOOLEAN (TRUE/FALSE)
- Apply with ALTER TABLE ADD ROW ACCESS POLICY
- Can use multiple columns
- Perfect for multi-tenant SaaS
- Combine with masking for complete security
- Use mapping tables for flexibility
- Must remove from tables before dropping
- Transparent to applications

## Next Steps

- If you scored 8-10: Move to Day 18 (Data Sharing & Secure Views)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Create regional access policy
2. Apply policy to table
3. Test with different roles
4. Create multi-column policy
5. Use mapping table for access
6. Combine with masking policy
7. Audit policy usage
8. Implement tenant isolation

## Real-World Applications

**Multi-Tenant SaaS:**
```sql
-- Isolate customer data
CREATE ROW ACCESS POLICY tenant_isolation AS (tenant_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('PLATFORM_ADMIN') THEN TRUE
    WHEN tenant_id = CURRENT_SESSION_PARAMETER('TENANT_ID') THEN TRUE
    ELSE FALSE
  END;
```

**Regional Data Access:**
```sql
-- Users see only their region
CREATE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'NA_ROLE' AND region = 'NORTH_AMERICA' THEN TRUE
    WHEN CURRENT_ROLE() = 'EU_ROLE' AND region = 'EUROPE' THEN TRUE
    ELSE FALSE
  END;
```

**Department-Based Access:**
```sql
-- Department isolation
CREATE ROW ACCESS POLICY dept_access AS (dept STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_ROLE' AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'HR_ROLE' AND dept = 'HR' THEN TRUE
    ELSE FALSE
  END;
```

**Hierarchical Access:**
```sql
-- Managers see their team
CREATE ROW ACCESS POLICY manager_access AS (manager_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN manager_id = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END;
```

**Access Patterns:**

**Role-Based:**
- Filter by CURRENT_ROLE()
- Different roles see different data
- Simple and effective

**User-Based:**
- Filter by CURRENT_USER()
- Users see only their own data
- Personal data isolation

**Mapping Table:**
- Flexible access rules
- Easy to update without changing policy
- Supports complex scenarios

**Multi-Column:**
- Filter by multiple conditions
- More precise control
- Region AND department

**Time-Based:**
- Filter by date ranges
- Recent data only
- Compliance requirements

**Best Practices Checklist:**
- [ ] Use mapping tables for flexibility
- [ ] Test with all roles
- [ ] Document policy logic
- [ ] Monitor performance
- [ ] Combine with masking when needed
- [ ] Regular audits
- [ ] Centralize policy management
- [ ] Use appropriate columns for filtering
- [ ] Consider query performance
- [ ] Plan for scalability

**Common Mistakes to Avoid:**
1. ❌ Wrong return type (must be BOOLEAN)
2. ❌ Not testing with all roles
3. ❌ Complex logic (performance impact)
4. ❌ Not using mapping tables
5. ❌ Forgetting to remove before dropping
6. ❌ Not documenting policy logic
7. ❌ Not auditing access
8. ❌ Over-filtering (hiding too much data)

**Troubleshooting:**

**Issue**: No rows returned
- **Check**: Current role authorized?
- **Check**: Policy logic correct?
- **Fix**: Review policy conditions

**Issue**: Cannot drop policy
- **Cause**: Still applied to tables
- **Fix**: Remove from all tables first

**Issue**: Performance degradation
- **Cause**: Complex policy logic
- **Fix**: Simplify conditions, use mapping tables

**Issue**: Wrong rows visible
- **Cause**: Policy logic error
- **Fix**: Test policy thoroughly, review conditions

**Audit Queries:**

```sql
-- View all row access policies
SHOW ROW ACCESS POLICIES;

-- View policy references
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'REGIONAL_ACCESS'
));

-- View policy details
DESCRIBE ROW ACCESS POLICY regional_access;

-- Track policy changes
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.ROW_ACCESS_POLICIES
WHERE deleted IS NULL;
```

**Comparison: Row Access vs. Masking:**

| Aspect | Row Access | Masking |
|--------|-----------|---------|
| **Controls** | Rows | Column values |
| **Returns** | BOOLEAN | Same as input type |
| **Effect** | Hide rows | Hide values |
| **Use Case** | Data isolation | Sensitive data |
| **Example** | Multi-tenant | Credit cards |

**Combined Security:**
```sql
-- Row access: Filter by region
ALTER TABLE customers ADD ROW ACCESS POLICY regional_filter ON (region);

-- Masking: Hide sensitive data
ALTER TABLE customers MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;

-- Result: Users see only their region's rows with SSN masked
```

**Performance Tips:**
- Keep policy logic simple
- Avoid complex subqueries
- Use indexed columns when possible
- Test with production data volumes
- Monitor query performance
- Consider caching mapping tables

**Compliance Use Cases:**

**GDPR (EU):**
- Regional data isolation
- Right to be forgotten
- Data minimization

**Data Sovereignty:**
- Keep data in specific regions
- Comply with local laws
- Regional access control

**Multi-Tenant:**
- Customer data isolation
- Prevent data leakage
- SaaS applications

**Hierarchical:**
- Manager-employee relationships
- Organizational structure
- Need-to-know basis

**Next Steps:**
Tomorrow we'll learn about Data Sharing & Secure Views to securely share data with external parties while maintaining control and security.
