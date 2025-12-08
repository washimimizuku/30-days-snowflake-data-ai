# Day 16 Quiz: Data Masking & Privacy

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is dynamic data masking?

A) Permanently encrypting data in storage  
B) Masking data at query time based on user's role  
C) Deleting sensitive data  
D) Compressing data  

**Your answer:**

---

### 2. When is data masked in Snowflake?

A) When data is inserted  
B) When data is stored  
C) At query time  
D) During backup  

**Your answer:**

---

### 3. What is a masking policy?

A) A table-level object  
B) A schema-level object  
C) A database-level object  
D) An account-level object  

**Your answer:**

---

### 4. What must a masking policy return?

A) Any data type  
B) Always STRING  
C) Same data type as input  
D) Always NULL  

**Your answer:**

---

### 5. How do you apply a masking policy to a column?

A) CREATE MASK ON column  
B) ALTER TABLE ... MODIFY COLUMN ... SET MASKING POLICY  
C) GRANT MASKING POLICY TO column  
D) SET MASKING POLICY = policy_name  

**Your answer:**

---

### 6. What happens to masking when querying a view?

A) Masking is removed  
B) Masking is inherited  
C) View must redefine masking  
D) Masking doesn't work in views  

**Your answer:**

---

### 7. Which function is commonly used in masking policies?

A) CURRENT_USER()  
B) CURRENT_ROLE()  
C) CURRENT_SESSION()  
D) CURRENT_POLICY()  

**Your answer:**

---

### 8. Can one masking policy be applied to multiple columns?

A) No, one policy per column only  
B) Yes, same policy can be applied to multiple columns  
C) Only if columns are in same table  
D) Only if columns have same name  

**Your answer:**

---

### 9. What is required before dropping a masking policy?

A) Nothing, can drop anytime  
B) Must unset from all columns first  
C) Must delete all data first  
D) Must recreate the table  

**Your answer:**

---

### 10. Which compliance regulation requires data masking?

A) GDPR  
B) PCI-DSS  
C) HIPAA  
D) All of the above  

**Your answer:**

---

## Answer Key

1. **B** - Masking data at query time based on user's role
2. **C** - At query time
3. **B** - A schema-level object
4. **C** - Same data type as input
5. **B** - ALTER TABLE ... MODIFY COLUMN ... SET MASKING POLICY
6. **B** - Masking is inherited
7. **B** - CURRENT_ROLE()
8. **B** - Yes, same policy can be applied to multiple columns
9. **B** - Must unset from all columns first
10. **D** - All of the above

---

## Score Yourself

- 9-10/10: Excellent! You understand data masking thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Dynamic Masking**: Data masked at query time, not in storage  
✅ **Masking Policy**: Schema-level object with conditional logic  
✅ **Role-Based**: Different roles see different data  
✅ **Return Type**: Must match input data type  
✅ **Application**: ALTER TABLE MODIFY COLUMN SET MASKING POLICY  
✅ **Inheritance**: Masking inherited through views  
✅ **CURRENT_ROLE()**: Common function in policies  
✅ **Reusability**: One policy can apply to multiple columns  
✅ **Removal**: Must unset before dropping policy  
✅ **Compliance**: GDPR, PCI-DSS, HIPAA, CCPA  

## Exam Tips

**Common exam question patterns:**
- When data is masked (query time vs. storage)
- Masking policy object level (schema-level)
- Return type requirements
- How to apply/remove policies
- Masking inheritance in views
- CURRENT_ROLE() usage
- Policy reusability
- Compliance requirements
- Partial vs. full masking
- Conditional masking logic

**Remember for the exam:**
- Masking happens at query time
- Policies are schema-level objects
- Return type must match input type
- Use ALTER TABLE MODIFY COLUMN to apply
- Masking inherits through views
- CURRENT_ROLE() determines what user sees
- One policy can apply to many columns
- Must unset before dropping policy
- Original data never changes
- No performance impact on writes

## Next Steps

- If you scored 8-10: Move to Day 17 (Row Access Policies)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Create email masking policy
2. Apply policy to multiple columns
3. Test with different roles
4. Create partial masking (show last 4 digits)
5. Implement tiered masking
6. Create hash-based masking
7. Audit policy usage
8. Modify existing policy

## Real-World Applications

**PII Protection (GDPR Compliance):**
```sql
-- Mask email, phone, SSN
CREATE MASKING POLICY pii_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('PRIVACY_OFFICER', 'ADMIN') THEN val
    ELSE '***MASKED***'
  END;
```

**Financial Data (PCI-DSS Compliance):**
```sql
-- Mask credit card numbers
CREATE MASKING POLICY cc_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('FINANCE_ADMIN') THEN val
    ELSE CONCAT('****-****-****-', RIGHT(val, 4))
  END;
```

**Healthcare Data (HIPAA Compliance):**
```sql
-- Mask PHI (Protected Health Information)
CREATE MASKING POLICY phi_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DOCTOR', 'NURSE', 'ADMIN') THEN val
    ELSE '***PHI_PROTECTED***'
  END;
```

**HR Data:**
```sql
-- Tiered salary masking
CREATE MASKING POLICY salary_mask AS (val NUMBER) RETURNS NUMBER ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN', 'EXECUTIVE') THEN val
    WHEN CURRENT_ROLE() IN ('MANAGER') THEN ROUND(val, -4)
    ELSE NULL
  END;
```

**Masking Patterns:**

**Full Masking:**
- Replace entire value: `'********'`
- Use for: Highly sensitive data

**Partial Masking:**
- Show last 4 digits: `'****-****-****-1234'`
- Use for: Credit cards, SSN, phone numbers

**Hash Masking:**
- Replace with hash: `SHA2(val)`
- Use for: Consistent anonymization

**Null Masking:**
- Replace with NULL
- Use for: Complete data hiding

**Tokenization:**
- Replace with token: `'TOKEN_12345'`
- Use for: Referential integrity

**Best Practices Checklist:**
- [ ] Use role-based conditional masking
- [ ] Apply consistent masking patterns
- [ ] Test with all roles
- [ ] Document policy purposes
- [ ] Centralize policy management
- [ ] Regular audits
- [ ] Monitor policy changes
- [ ] Use partial masking when appropriate
- [ ] Consider performance impact
- [ ] Comply with regulations

**Common Mistakes to Avoid:**
1. ❌ Wrong return type (must match input)
2. ❌ Forgetting to test with different roles
3. ❌ Not documenting policy logic
4. ❌ Over-masking (hiding too much data)
5. ❌ Under-masking (not protecting enough)
6. ❌ Complex logic (performance impact)
7. ❌ Not auditing policy usage
8. ❌ Forgetting to unset before dropping

**Troubleshooting:**

**Issue**: Policy not applied
- **Check**: Policy applied to column?
- **Check**: Current role authorized?
- **Fix**: ALTER TABLE MODIFY COLUMN SET MASKING POLICY

**Issue**: Cannot drop policy
- **Cause**: Still applied to columns
- **Fix**: Unset from all columns first

**Issue**: Wrong data type error
- **Cause**: Return type doesn't match input
- **Fix**: Ensure RETURNS matches input type

**Issue**: Users see unmasked data
- **Cause**: User has authorized role
- **Fix**: Review policy logic and role assignments

**Audit Queries:**

```sql
-- View all masking policies
SHOW MASKING POLICIES;

-- View policy references
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'EMAIL_MASK'
));

-- View policy details
DESCRIBE MASKING POLICY email_mask;

-- Track policy changes
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.MASKING_POLICIES
WHERE deleted IS NULL;
```

**Compliance Mapping:**

**GDPR (EU):**
- Mask PII: email, phone, address
- Right to be forgotten
- Data minimization

**PCI-DSS (Payment Cards):**
- Mask credit card numbers
- Show last 4 digits only
- Protect cardholder data

**HIPAA (Healthcare):**
- Mask PHI: medical records, diagnoses
- Protect patient privacy
- Audit access

**CCPA (California):**
- Mask personal information
- Consumer privacy rights
- Data protection

**SOX (Financial):**
- Mask financial data
- Protect sensitive information
- Audit trails

**Data Classification:**

**Public**: No masking needed
**Internal**: Basic masking
**Confidential**: Strong masking
**Restricted**: Full masking or null

**Masking Strategy:**

1. **Identify** sensitive data
2. **Classify** by sensitivity level
3. **Create** appropriate policies
4. **Apply** to columns
5. **Test** with all roles
6. **Audit** regularly
7. **Monitor** usage
8. **Update** as needed

**Performance Considerations:**
- Simple logic is faster
- Avoid complex regex
- Cache policy results when possible
- No impact on writes
- Minimal impact on reads
- Test with production data volumes

**Next Steps:**
Tomorrow we'll learn about Row Access Policies to control which rows users can see based on their role and other conditions.
