# Day 16: Data Masking & Privacy

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand dynamic data masking in Snowflake
- Create and apply masking policies
- Implement column-level security
- Use conditional masking based on roles
- Apply masking to different data types
- Understand masking policy inheritance
- Monitor and audit masking policies
- Apply data privacy best practices for compliance

---

## Theory

### What is Dynamic Data Masking?

**Dynamic Data Masking** protects sensitive data by replacing it with masked values at query time based on the user's role.

**Key Features**:
- Data is masked at query time (not stored masked)
- Original data remains unchanged
- Different users see different values based on their role
- No performance impact on writes
- Centralized policy management

```
Original Data: 4111-1111-1111-1111
    ↓
Masking Policy Applied
    ↓
Authorized Role: 4111-1111-1111-1111
Unauthorized Role: ****-****-****-1111
```

### Why Use Data Masking?

**Compliance Requirements**:
- GDPR (General Data Protection Regulation)
- CCPA (California Consumer Privacy Act)
- HIPAA (Health Insurance Portability and Accountability Act)
- PCI-DSS (Payment Card Industry Data Security Standard)
- SOX (Sarbanes-Oxley Act)

**Use Cases**:
- Protect PII (Personally Identifiable Information)
- Secure PHI (Protected Health Information)
- Hide credit card numbers
- Mask email addresses
- Protect salary information
- Secure social security numbers

### Masking Policies

A **masking policy** is a schema-level object that defines how to mask column data.

**Syntax**:
```sql
CREATE MASKING POLICY policy_name AS (val TYPE) RETURNS TYPE ->
  CASE
    WHEN CURRENT_ROLE() IN ('AUTHORIZED_ROLE') THEN val
    ELSE 'MASKED_VALUE'
  END;
```

**Components**:
- **Input**: Column value and data type
- **Returns**: Same data type as input
- **Logic**: Conditional expression (usually based on role)

### Basic Masking Policy Example

```sql
-- Create masking policy for email addresses
CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'COMPLIANCE_OFFICER') THEN val
    ELSE '***@*****.com'
  END;

-- Apply policy to column
ALTER TABLE customers MODIFY COLUMN email 
  SET MASKING POLICY email_mask;

-- Query results:
-- ADMIN role sees: john.doe@example.com
-- Other roles see: ***@*****.com
```

### Masking Policy Types

#### 1. Full Masking

Replace entire value with a constant:

```sql
CREATE MASKING POLICY full_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE '********'
  END;
```

#### 2. Partial Masking

Show part of the value:

```sql
-- Credit card: Show last 4 digits
CREATE MASKING POLICY cc_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('FINANCE_ADMIN') THEN val
    ELSE CONCAT('****-****-****-', RIGHT(val, 4))
  END;

-- Email: Show domain only
CREATE MASKING POLICY email_partial_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE CONCAT('***@', SPLIT_PART(val, '@', 2))
  END;
```

#### 3. Hashing

Replace with hash value:

```sql
CREATE MASKING POLICY hash_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE SHA2(val)
  END;
```

#### 4. Nullification

Replace with NULL:

```sql
CREATE MASKING POLICY null_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE NULL
  END;
```

#### 5. Tokenization

Replace with consistent token:

```sql
CREATE MASKING POLICY token_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE CONCAT('TOKEN_', ABS(HASH(val)))
  END;
```

### Data Type-Specific Masking

#### String Masking

```sql
-- SSN masking
CREATE MASKING POLICY ssn_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN', 'PAYROLL') THEN val
    ELSE CONCAT('***-**-', RIGHT(val, 4))
  END;

-- Phone number masking
CREATE MASKING POLICY phone_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('SALES_MANAGER') THEN val
    ELSE CONCAT('***-***-', RIGHT(val, 4))
  END;
```

#### Number Masking

```sql
-- Salary masking
CREATE MASKING POLICY salary_mask AS (val NUMBER) RETURNS NUMBER ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN', 'EXECUTIVE') THEN val
    ELSE 0
  END;

-- Salary range masking
CREATE MASKING POLICY salary_range_mask AS (val NUMBER) RETURNS NUMBER ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN') THEN val
    WHEN CURRENT_ROLE() IN ('MANAGER') THEN ROUND(val, -4)  -- Round to nearest 10k
    ELSE NULL
  END;
```

#### Date Masking

```sql
-- Birth date masking (show year only)
CREATE MASKING POLICY birthdate_mask AS (val DATE) RETURNS DATE ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN') THEN val
    ELSE DATE_FROM_PARTS(YEAR(val), 1, 1)
  END;

-- Date nullification
CREATE MASKING POLICY date_null_mask AS (val DATE) RETURNS DATE ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE NULL
  END;
```

### Conditional Masking

Mask based on multiple conditions:

```sql
-- Mask based on role AND data value
CREATE MASKING POLICY conditional_mask AS (val STRING, category STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    WHEN CURRENT_ROLE() IN ('ANALYST') AND category = 'PUBLIC' THEN val
    ELSE '***MASKED***'
  END;

-- Mask based on user
CREATE MASKING POLICY user_based_mask AS (val STRING, owner STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    WHEN CURRENT_USER() = owner THEN val
    ELSE '***MASKED***'
  END;
```

### Applying Masking Policies

#### Apply to Existing Column

```sql
-- Apply policy
ALTER TABLE customers MODIFY COLUMN email 
  SET MASKING POLICY email_mask;

-- Remove policy
ALTER TABLE customers MODIFY COLUMN email 
  UNSET MASKING POLICY;

-- Replace policy
ALTER TABLE customers MODIFY COLUMN email 
  SET MASKING POLICY new_email_mask 
  FORCE;
```

#### Apply to Multiple Columns

```sql
-- Apply same policy to multiple columns
ALTER TABLE customers MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE customers MODIFY COLUMN backup_email SET MASKING POLICY email_mask;

-- Apply different policies
ALTER TABLE customers MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;
ALTER TABLE customers MODIFY COLUMN credit_card SET MASKING POLICY cc_mask;
ALTER TABLE customers MODIFY COLUMN salary SET MASKING POLICY salary_mask;
```

#### Apply at Table Creation

```sql
CREATE TABLE employees (
  employee_id INT,
  name STRING,
  email STRING MASKING POLICY email_mask,
  ssn STRING MASKING POLICY ssn_mask,
  salary NUMBER MASKING POLICY salary_mask
);
```

### Masking Policy Inheritance

Policies can be inherited through views:

```sql
-- Base table with masking
CREATE TABLE customers (
  customer_id INT,
  email STRING MASKING POLICY email_mask
);

-- View inherits masking
CREATE VIEW customer_view AS
  SELECT * FROM customers;

-- Query view: masking still applies
SELECT * FROM customer_view;
```

### Managing Masking Policies

#### View Policies

```sql
-- Show all masking policies
SHOW MASKING POLICIES;

-- Show policies in schema
SHOW MASKING POLICIES IN SCHEMA myschema;

-- Describe policy
DESCRIBE MASKING POLICY email_mask;
```

#### View Policy References

```sql
-- See where policy is applied
SELECT * 
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'EMAIL_MASK'
));
```

#### Modify Policy

```sql
-- Alter policy logic
ALTER MASKING POLICY email_mask SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'MANAGER') THEN val
    ELSE '***@*****.com'
  END;
```

#### Drop Policy

```sql
-- Must unset from all columns first
ALTER TABLE customers MODIFY COLUMN email UNSET MASKING POLICY;

-- Then drop policy
DROP MASKING POLICY email_mask;
```

### Best Practices

#### 1. Role-Based Masking

```sql
-- Create roles for data access levels
CREATE ROLE data_admin;      -- Full access
CREATE ROLE data_analyst;    -- Partial access
CREATE ROLE data_viewer;     -- Masked access

-- Create masking policy
CREATE MASKING POLICY tiered_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DATA_ADMIN') THEN val
    WHEN CURRENT_ROLE() IN ('DATA_ANALYST') THEN CONCAT(LEFT(val, 3), '***')
    ELSE '***MASKED***'
  END;
```

#### 2. Centralized Policy Management

```sql
-- Create dedicated schema for policies
CREATE SCHEMA security_policies;

-- Create all policies in this schema
CREATE MASKING POLICY security_policies.email_mask AS ...;
CREATE MASKING POLICY security_policies.ssn_mask AS ...;
CREATE MASKING POLICY security_policies.cc_mask AS ...;
```

#### 3. Consistent Masking Patterns

```sql
-- Standard email masking
CREATE MASKING POLICY std_email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'COMPLIANCE') THEN val
    ELSE REGEXP_REPLACE(val, '^[^@]+', '***')
  END;

-- Standard phone masking
CREATE MASKING POLICY std_phone_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'SALES_MANAGER') THEN val
    ELSE CONCAT('***-***-', RIGHT(val, 4))
  END;
```

#### 4. Testing Masking Policies

```sql
-- Test with different roles
USE ROLE data_admin;
SELECT email FROM customers LIMIT 5;  -- See real data

USE ROLE data_viewer;
SELECT email FROM customers LIMIT 5;  -- See masked data

-- Verify masking works as expected
```

#### 5. Documentation

```sql
-- Add comments to policies
CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE '***@*****.com'
  END
  COMMENT = 'Masks email addresses for non-admin users. Compliant with GDPR.';
```

### Monitoring and Auditing

#### Track Policy Usage

```sql
-- View policy references
SELECT 
  policy_name,
  ref_entity_name,
  ref_entity_domain,
  ref_column_name
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_NAME => 'CUSTOMERS',
  REF_ENTITY_DOMAIN => 'TABLE'
));
```

#### Audit Access

```sql
-- Query history with masking
SELECT 
  query_id,
  user_name,
  role_name,
  query_text,
  execution_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%customers%'
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

#### Policy Change History

```sql
-- Track policy changes
SELECT 
  policy_name,
  policy_kind,
  policy_owner,
  created,
  last_altered
FROM SNOWFLAKE.ACCOUNT_USAGE.MASKING_POLICIES
WHERE deleted IS NULL
ORDER BY last_altered DESC;
```

### Common Patterns

#### Pattern 1: PII Protection

```sql
-- Mask all PII columns
CREATE MASKING POLICY pii_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('PRIVACY_OFFICER', 'ADMIN') THEN val
    ELSE '***PII_MASKED***'
  END;

ALTER TABLE customers MODIFY COLUMN ssn SET MASKING POLICY pii_mask;
ALTER TABLE customers MODIFY COLUMN email SET MASKING POLICY pii_mask;
ALTER TABLE customers MODIFY COLUMN phone SET MASKING POLICY pii_mask;
```

#### Pattern 2: Financial Data Protection

```sql
-- Mask financial data
CREATE MASKING POLICY financial_mask AS (val NUMBER) RETURNS NUMBER ->
  CASE
    WHEN CURRENT_ROLE() IN ('FINANCE_ADMIN', 'CFO') THEN val
    WHEN CURRENT_ROLE() IN ('FINANCE_ANALYST') THEN ROUND(val, -3)
    ELSE NULL
  END;

ALTER TABLE transactions MODIFY COLUMN amount SET MASKING POLICY financial_mask;
ALTER TABLE accounts MODIFY COLUMN balance SET MASKING POLICY financial_mask;
```

#### Pattern 3: Healthcare Data (HIPAA)

```sql
-- Mask PHI (Protected Health Information)
CREATE MASKING POLICY phi_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DOCTOR', 'NURSE', 'ADMIN') THEN val
    ELSE '***PHI_PROTECTED***'
  END;

ALTER TABLE patients MODIFY COLUMN medical_record_number SET MASKING POLICY phi_mask;
ALTER TABLE patients MODIFY COLUMN diagnosis SET MASKING POLICY phi_mask;
```

### Troubleshooting

#### Issue 1: Policy Not Applied

**Symptoms**: Users see unmasked data

**Causes**:
- User has privileged role
- Policy not applied to column
- Policy logic incorrect

**Solutions**:
```sql
-- Check policy references
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'EMAIL_MASK'
));

-- Verify current role
SELECT CURRENT_ROLE();

-- Test policy logic
SELECT 
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN 'test@example.com'
    ELSE '***@*****.com'
  END;
```

#### Issue 2: Cannot Drop Policy

**Symptoms**: Error when dropping policy

**Cause**: Policy still applied to columns

**Solution**:
```sql
-- Find all references
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'EMAIL_MASK'
));

-- Unset from all columns
ALTER TABLE customers MODIFY COLUMN email UNSET MASKING POLICY;

-- Then drop
DROP MASKING POLICY email_mask;
```

#### Issue 3: Performance Impact

**Symptoms**: Queries slower with masking

**Cause**: Complex masking logic

**Solution**:
```sql
-- Simplify masking logic
-- Bad: Complex regex
CREATE MASKING POLICY slow_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE REGEXP_REPLACE(REGEXP_REPLACE(val, '[A-Z]', 'X'), '[0-9]', '#')
  END;

-- Good: Simple replacement
CREATE MASKING POLICY fast_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE '***MASKED***'
  END;
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Basic Masking Policies
Create policies for different data types.

### Exercise 2: Apply Masking to Tables
Apply policies to sensitive columns.

### Exercise 3: Partial Masking
Implement partial data masking.

### Exercise 4: Conditional Masking
Create role-based conditional masking.

### Exercise 5: Test Masking
Verify masking with different roles.

### Exercise 6: Manage Policies
Modify and manage masking policies.

### Exercise 7: Audit Masking
Monitor and audit masking policies.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Dynamic data masking protects sensitive data at query time
- Masking policies are schema-level objects
- Policies define conditional logic based on roles
- Original data remains unchanged
- Masking is transparent to applications
- Policies can be applied to multiple columns
- Different masking types: full, partial, hash, null, token
- Role-based access determines what users see
- Policies inherit through views
- Regular auditing ensures compliance
- Centralized policy management recommended

---

## 📚 Additional Resources

- [Snowflake Docs: Data Masking](https://docs.snowflake.com/en/user-guide/security-column-ddm)
- [Masking Policies](https://docs.snowflake.com/en/sql-reference/sql/create-masking-policy)
- [Column-Level Security](https://docs.snowflake.com/en/user-guide/security-column-intro)

---

## 🔜 Tomorrow: Day 17 - Row Access Policies

We'll learn how to control access at the row level using row access policies.
