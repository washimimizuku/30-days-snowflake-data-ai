# Day 17: Row Access Policies

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand row-level security in Snowflake
- Create and apply row access policies
- Implement role-based row filtering
- Use mapping tables for complex access control
- Combine row access policies with masking policies
- Apply policies to tables and views
- Monitor and audit row access policies
- Implement multi-tenant data isolation

---

## Theory

### What are Row Access Policies?

**Row Access Policies** control which rows users can see based on their role, user identity, or other conditions.

**Key Differences from Masking Policies**:

| Feature | Masking Policies | Row Access Policies |
|---------|-----------------|---------------------|
| **What** | Hide column values | Hide entire rows |
| **Level** | Column-level | Row-level |
| **Result** | Masked data | Filtered rows |
| **Use Case** | Protect sensitive values | Control data access |

```
Without Row Access Policy:
User queries table → Sees all rows

With Row Access Policy:
User queries table → Policy filters rows → Sees only authorized rows
```

### Why Use Row Access Policies?

**Use Cases**:
- Multi-tenant applications (isolate customer data)
- Regional data access (users see only their region)
- Department-based access (sales sees sales data only)
- Hierarchical access (managers see their team's data)
- Data sovereignty (comply with regional regulations)
- Customer data isolation (SaaS applications)

**Benefits**:
- Transparent to applications
- Centralized access control
- No query rewriting needed
- Consistent enforcement
- Audit trail

### Row Access Policy Syntax

```sql
CREATE ROW ACCESS POLICY policy_name AS (column_name TYPE) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN column_name = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END;
```

**Components**:
- **Input**: One or more column values from the table
- **Returns**: BOOLEAN (TRUE = show row, FALSE = hide row)
- **Logic**: Conditional expression based on role, user, or data

### Basic Row Access Policy Example

```sql
-- Create policy: Users see only their own data
CREATE ROW ACCESS POLICY user_isolation AS (user_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN user_id = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END;

-- Apply policy to table
ALTER TABLE orders ADD ROW ACCESS POLICY user_isolation ON (user_id);

-- Query results:
-- ADMIN role: Sees all rows
-- Regular user: Sees only rows where user_id = their username
```

### Row Access Policy Patterns

#### Pattern 1: Role-Based Access

```sql
-- Sales team sees only sales data
CREATE ROW ACCESS POLICY department_access AS (dept STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'EXECUTIVE') THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_ROLE' AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'FINANCE_ROLE' AND dept = 'FINANCE' THEN TRUE
    WHEN CURRENT_ROLE() = 'HR_ROLE' AND dept = 'HR' THEN TRUE
    ELSE FALSE
  END;

ALTER TABLE employees ADD ROW ACCESS POLICY department_access ON (department);
```

#### Pattern 2: Regional Access

```sql
-- Users see only data from their region
CREATE ROW ACCESS POLICY regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'NORTH_AMERICA_ROLE' AND region = 'NORTH_AMERICA' THEN TRUE
    WHEN CURRENT_ROLE() = 'EUROPE_ROLE' AND region = 'EUROPE' THEN TRUE
    WHEN CURRENT_ROLE() = 'ASIA_ROLE' AND region = 'ASIA' THEN TRUE
    ELSE FALSE
  END;

ALTER TABLE sales ADD ROW ACCESS POLICY regional_access ON (region);
```

#### Pattern 3: User-Based Access

```sql
-- Users see only their own records
CREATE ROW ACCESS POLICY owner_access AS (owner STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN owner = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END;

ALTER TABLE documents ADD ROW ACCESS POLICY owner_access ON (created_by);
```

#### Pattern 4: Hierarchical Access

```sql
-- Managers see their team's data
CREATE ROW ACCESS POLICY manager_access AS (manager_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'EXECUTIVE') THEN TRUE
    WHEN manager_id = CURRENT_USER() THEN TRUE
    WHEN CURRENT_USER() IN (
      SELECT employee_id FROM employees WHERE manager_id = manager_id
    ) THEN TRUE
    ELSE FALSE
  END;

ALTER TABLE performance_reviews ADD ROW ACCESS POLICY manager_access ON (manager_id);
```

### Using Mapping Tables

For complex access control, use mapping tables:

```sql
-- Create mapping table
CREATE TABLE user_region_mapping (
  username STRING,
  region STRING
);

INSERT INTO user_region_mapping VALUES
  ('alice', 'NORTH'),
  ('bob', 'SOUTH'),
  ('carol', 'EAST');

-- Create policy using mapping table
CREATE ROW ACCESS POLICY mapped_regional_access AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN region IN (
      SELECT region FROM user_region_mapping WHERE username = CURRENT_USER()
    ) THEN TRUE
    ELSE FALSE
  END;

ALTER TABLE sales ADD ROW ACCESS POLICY mapped_regional_access ON (region);
```

### Multi-Column Policies

Policies can reference multiple columns:

```sql
-- Access based on region AND department
CREATE ROW ACCESS POLICY multi_column_access AS (
  region STRING,
  dept STRING
) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_NORTH' 
      AND region = 'NORTH' 
      AND dept = 'SALES' THEN TRUE
    WHEN CURRENT_ROLE() = 'SALES_SOUTH' 
      AND region = 'SOUTH' 
      AND dept = 'SALES' THEN TRUE
    ELSE FALSE
  END;

ALTER TABLE employees ADD ROW ACCESS POLICY multi_column_access ON (region, department);
```

### Applying Row Access Policies

#### Apply to Table

```sql
-- Add policy
ALTER TABLE customers ADD ROW ACCESS POLICY customer_isolation ON (customer_id);

-- Remove policy
ALTER TABLE customers DROP ROW ACCESS POLICY;

-- Replace policy
ALTER TABLE customers DROP ROW ACCESS POLICY;
ALTER TABLE customers ADD ROW ACCESS POLICY new_policy ON (customer_id);
```

#### Apply to View

```sql
-- Policies can be applied to views
CREATE VIEW customer_view AS
  SELECT * FROM customers;

ALTER VIEW customer_view ADD ROW ACCESS POLICY customer_isolation ON (customer_id);
```

#### Apply at Table Creation

```sql
CREATE TABLE orders (
  order_id INT,
  customer_id STRING,
  amount DECIMAL(10,2)
) ROW ACCESS POLICY customer_isolation ON (customer_id);
```

### Combining with Masking Policies

Row access and masking policies work together:

```sql
-- Row access policy: Filter rows by region
CREATE ROW ACCESS POLICY regional_filter AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'NORTH_ROLE' AND region = 'NORTH' THEN TRUE
    ELSE FALSE
  END;

-- Masking policy: Mask sensitive columns
CREATE MASKING POLICY ssn_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE CONCAT('***-**-', RIGHT(val, 4))
  END;

-- Apply both policies
ALTER TABLE employees ADD ROW ACCESS POLICY regional_filter ON (region);
ALTER TABLE employees MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;

-- Result: Users see only their region's rows, with SSN masked
```

### Managing Row Access Policies

#### View Policies

```sql
-- Show all row access policies
SHOW ROW ACCESS POLICIES;

-- Show policies in schema
SHOW ROW ACCESS POLICIES IN SCHEMA myschema;

-- Describe policy
DESCRIBE ROW ACCESS POLICY customer_isolation;
```

#### View Policy References

```sql
-- See where policy is applied
SELECT * 
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'CUSTOMER_ISOLATION'
));
```

#### Modify Policy

```sql
-- Alter policy logic
ALTER ROW ACCESS POLICY customer_isolation SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN', 'SUPPORT') THEN TRUE
    WHEN customer_id = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END;
```

#### Drop Policy

```sql
-- Must remove from all tables first
ALTER TABLE customers DROP ROW ACCESS POLICY;

-- Then drop policy
DROP ROW ACCESS POLICY customer_isolation;
```

### Best Practices

#### 1. Use Mapping Tables for Flexibility

```sql
-- Instead of hardcoding in policy
CREATE TABLE role_region_mapping (
  role_name STRING,
  region STRING
);

CREATE ROW ACCESS POLICY flexible_regional AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN region IN (
      SELECT region FROM role_region_mapping WHERE role_name = CURRENT_ROLE()
    ) THEN TRUE
    ELSE FALSE
  END;
```

#### 2. Test Thoroughly

```sql
-- Test with different roles
USE ROLE sales_role;
SELECT COUNT(*) FROM customers;  -- Should see filtered count

USE ROLE admin;
SELECT COUNT(*) FROM customers;  -- Should see all rows
```

#### 3. Document Policies

```sql
CREATE ROW ACCESS POLICY customer_isolation AS (customer_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN customer_id = CURRENT_USER() THEN TRUE
    ELSE FALSE
  END
  COMMENT = 'Isolates customer data - users see only their own records';
```

#### 4. Monitor Performance

```sql
-- Check query performance with policies
SELECT 
  query_id,
  query_text,
  execution_time,
  rows_produced
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text ILIKE '%customers%'
ORDER BY start_time DESC
LIMIT 10;
```

#### 5. Centralize Policy Management

```sql
-- Create dedicated schema for policies
CREATE SCHEMA security_policies;

-- Create all policies in this schema
CREATE ROW ACCESS POLICY security_policies.customer_isolation AS ...;
CREATE ROW ACCESS POLICY security_policies.regional_access AS ...;
```

### Multi-Tenant Isolation

Perfect for SaaS applications:

```sql
-- Tenant isolation policy
CREATE ROW ACCESS POLICY tenant_isolation AS (tenant_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('PLATFORM_ADMIN') THEN TRUE
    WHEN tenant_id = CURRENT_SESSION_PARAMETER('TENANT_ID') THEN TRUE
    ELSE FALSE
  END;

-- Set tenant context
ALTER SESSION SET TENANT_ID = 'tenant_123';

-- Apply to all multi-tenant tables
ALTER TABLE customers ADD ROW ACCESS POLICY tenant_isolation ON (tenant_id);
ALTER TABLE orders ADD ROW ACCESS POLICY tenant_isolation ON (tenant_id);
ALTER TABLE invoices ADD ROW ACCESS POLICY tenant_isolation ON (tenant_id);
```

### Monitoring and Auditing

#### Track Policy Usage

```sql
-- View policy references
SELECT 
  policy_name,
  ref_entity_name,
  ref_entity_domain,
  ref_column_names
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_NAME => 'CUSTOMERS',
  REF_ENTITY_DOMAIN => 'TABLE'
));
```

#### Audit Access

```sql
-- Query history with row filtering
SELECT 
  query_id,
  user_name,
  role_name,
  query_text,
  rows_produced,
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
  policy_owner,
  created,
  last_altered,
  comment
FROM SNOWFLAKE.ACCOUNT_USAGE.ROW_ACCESS_POLICIES
WHERE deleted IS NULL
ORDER BY last_altered DESC;
```

### Common Patterns

#### Pattern 1: Customer Data Isolation (SaaS)

```sql
CREATE ROW ACCESS POLICY saas_isolation AS (customer_id STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('PLATFORM_ADMIN', 'SUPPORT_ADMIN') THEN TRUE
    WHEN customer_id = CURRENT_SESSION_PARAMETER('CUSTOMER_ID') THEN TRUE
    ELSE FALSE
  END;
```

#### Pattern 2: Geographic Compliance

```sql
CREATE ROW ACCESS POLICY gdpr_compliance AS (data_region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('GLOBAL_ADMIN') THEN TRUE
    WHEN data_region = 'EU' AND CURRENT_ROLE() IN ('EU_DATA_PROCESSOR') THEN TRUE
    WHEN data_region != 'EU' THEN TRUE
    ELSE FALSE
  END;
```

#### Pattern 3: Time-Based Access

```sql
CREATE ROW ACCESS POLICY time_based_access AS (
  record_date DATE
) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN CURRENT_ROLE() = 'ANALYST' 
      AND record_date >= DATEADD(day, -90, CURRENT_DATE()) THEN TRUE
    ELSE FALSE
  END;
```

### Troubleshooting

#### Issue 1: No Rows Returned

**Symptoms**: Query returns 0 rows unexpectedly

**Causes**:
- Policy too restrictive
- Wrong role
- Mapping table empty

**Solutions**:
```sql
-- Check current role
SELECT CURRENT_ROLE();

-- Check policy logic
DESCRIBE ROW ACCESS POLICY policy_name;

-- Test without policy
USE ROLE ACCOUNTADMIN;
SELECT COUNT(*) FROM table_name;
```

#### Issue 2: Performance Degradation

**Symptoms**: Queries slower with policy

**Cause**: Complex policy logic or subqueries

**Solution**:
```sql
-- Simplify policy logic
-- Bad: Complex subquery
CREATE ROW ACCESS POLICY slow_policy AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN region IN (
      SELECT region FROM complex_view WHERE condition = TRUE
    ) THEN TRUE
    ELSE FALSE
  END;

-- Good: Simple lookup
CREATE ROW ACCESS POLICY fast_policy AS (region STRING) RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN TRUE
    WHEN region = 'NORTH' AND CURRENT_ROLE() = 'NORTH_ROLE' THEN TRUE
    ELSE FALSE
  END;
```

#### Issue 3: Cannot Drop Policy

**Symptoms**: Error when dropping policy

**Cause**: Policy still applied to tables

**Solution**:
```sql
-- Find all references
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'CUSTOMER_ISOLATION'
));

-- Remove from all tables
ALTER TABLE customers DROP ROW ACCESS POLICY;

-- Then drop
DROP ROW ACCESS POLICY customer_isolation;
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Basic Row Access Policies
Create policies for different access patterns.

### Exercise 2: Apply Policies to Tables
Apply row access policies to tables.

### Exercise 3: Role-Based Row Filtering
Implement role-based access control.

### Exercise 4: Mapping Table Access
Use mapping tables for flexible access.

### Exercise 5: Multi-Column Policies
Create policies using multiple columns.

### Exercise 6: Combine with Masking
Use row access and masking together.

### Exercise 7: Audit and Monitor
Monitor and audit row access policies.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Row access policies control which rows users can see
- Policies return BOOLEAN (TRUE = show, FALSE = hide)
- Applied at table or view level
- Can reference multiple columns
- Use mapping tables for flexibility
- Combine with masking policies for complete security
- Transparent to applications
- Essential for multi-tenant applications
- Support complex access patterns
- Regular auditing ensures compliance

---

## 📚 Additional Resources

- [Snowflake Docs: Row Access Policies](https://docs.snowflake.com/en/user-guide/security-row-intro)
- [CREATE ROW ACCESS POLICY](https://docs.snowflake.com/en/sql-reference/sql/create-row-access-policy)
- [Row-Level Security](https://docs.snowflake.com/en/user-guide/security-row)

---

## 🔜 Tomorrow: Day 18 - Data Sharing & Secure Views

We'll learn how to securely share data with external parties using Snowflake's data sharing features.
