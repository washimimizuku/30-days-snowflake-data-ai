# Day 18: Data Sharing & Secure Views

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake's Secure Data Sharing
- Create and manage shares
- Use secure views to protect sensitive data
- Implement reader accounts for external consumers
- Share data across regions and clouds
- Monitor and audit data sharing
- Apply best practices for secure data sharing
- Understand data marketplace concepts

---

## Theory

### Snowflake Secure Data Sharing

**Secure Data Sharing** allows you to share live data with other Snowflake accounts without copying or moving data.

**Key Features**:
- **Zero-copy**: No data duplication
- **Live access**: Real-time data, no ETL
- **Secure**: Provider controls access
- **No cost to consumer**: Provider pays for storage
- **Cross-region/cloud**: Share across regions and clouds

```
Provider Account                Consumer Account
    ↓                                ↓
  Share ────────────────────→  Database (read-only)
(Live data)                    (No storage cost)
```

### Benefits of Data Sharing

**For Providers**:
- Monetize data
- Share with partners/customers
- No data duplication
- Maintain control
- Real-time updates

**For Consumers**:
- Instant access to data
- No ETL pipelines
- Always current data
- No storage costs
- Query with own compute

### Types of Data Sharing

#### 1. Direct Share

Share with specific Snowflake accounts:

```sql
-- Create share
CREATE SHARE sales_share;

-- Add objects to share
GRANT USAGE ON DATABASE sales_db TO SHARE sales_share;
GRANT USAGE ON SCHEMA sales_db.public TO SHARE sales_share;
GRANT SELECT ON TABLE sales_db.public.orders TO SHARE sales_share;

-- Add consumer account
ALTER SHARE sales_share ADD ACCOUNTS = xy12345;
```

#### 2. Reader Account

Share with organizations that don't have Snowflake:

```sql
-- Create reader account
CREATE MANAGED ACCOUNT reader_account_1
  ADMIN_NAME = 'admin_user'
  ADMIN_PASSWORD = 'SecurePass123!'
  TYPE = READER;

-- Add reader account to share
ALTER SHARE sales_share ADD ACCOUNTS = reader_account_1;
```

#### 3. Data Marketplace

List data products on Snowflake Marketplace:
- Public or private listings
- Free or paid data
- Discoverable by all Snowflake customers
- Automated provisioning

### Creating Shares

#### Basic Share Creation

```sql
-- Create share
CREATE SHARE customer_share
  COMMENT = 'Share customer data with partners';

-- Grant database access
GRANT USAGE ON DATABASE customer_db TO SHARE customer_share;

-- Grant schema access
GRANT USAGE ON SCHEMA customer_db.public TO SHARE customer_share;

-- Grant table access
GRANT SELECT ON TABLE customer_db.public.customers TO SHARE customer_share;
GRANT SELECT ON TABLE customer_db.public.orders TO SHARE customer_share;

-- Add consumer accounts
ALTER SHARE customer_share ADD ACCOUNTS = xy12345, ab67890;

-- View share details
SHOW GRANTS TO SHARE customer_share;
DESC SHARE customer_share;
```

### Secure Views

**Secure Views** hide the underlying query definition and protect sensitive data.

**Why Use Secure Views**:
- Hide complex logic
- Protect sensitive columns
- Apply row-level filtering
- Share subset of data
- Maintain data privacy

**Regular View vs. Secure View**:

| Feature | Regular View | Secure View |
|---------|-------------|-------------|
| **Definition** | Visible | Hidden |
| **Optimization** | Full | Limited |
| **Security** | Basic | Enhanced |
| **Sharing** | Not recommended | Required |

#### Creating Secure Views

```sql
-- Create secure view
CREATE SECURE VIEW customer_summary AS
SELECT 
  customer_id,
  customer_name,
  region,
  total_orders,
  total_revenue
FROM customers
WHERE region IN ('NORTH', 'SOUTH');  -- Filter data

-- Share secure view
GRANT SELECT ON VIEW customer_summary TO SHARE customer_share;
```

#### Secure View with Masking

```sql
-- Secure view with data masking
CREATE SECURE VIEW customer_protected AS
SELECT 
  customer_id,
  customer_name,
  CONCAT('***@', SPLIT_PART(email, '@', 2)) as email,  -- Mask email
  CONCAT('***-***-', RIGHT(phone, 4)) as phone,  -- Mask phone
  region,
  total_orders
FROM customers;
```

#### Secure View with Row Filtering

```sql
-- Secure view with row-level security
CREATE SECURE VIEW regional_sales AS
SELECT 
  sale_id,
  customer_id,
  product_name,
  amount,
  sale_date
FROM sales
WHERE region = CURRENT_SESSION_PARAMETER('CONSUMER_REGION');
```

### Sharing Best Practices

#### 1. Use Secure Views

```sql
-- Don't share base tables directly
-- Bad:
GRANT SELECT ON TABLE customers TO SHARE my_share;

-- Good: Use secure view
CREATE SECURE VIEW customers_shared AS
SELECT 
  customer_id,
  customer_name,
  region,
  -- Exclude sensitive columns
  -- email, phone, ssn not included
FROM customers;

GRANT SELECT ON VIEW customers_shared TO SHARE my_share;
```

#### 2. Apply Data Filtering

```sql
-- Filter data before sharing
CREATE SECURE VIEW partner_sales AS
SELECT 
  sale_id,
  product_name,
  amount,
  sale_date
FROM sales
WHERE partner_id = CURRENT_SESSION_PARAMETER('PARTNER_ID')
  AND sale_date >= DATEADD(year, -1, CURRENT_DATE());
```

#### 3. Document Shares

```sql
CREATE SHARE analytics_share
  COMMENT = 'Analytics data for Partner XYZ. Updated daily. Contact: data-team@company.com';
```

#### 4. Monitor Usage

```sql
-- Track share usage
SELECT 
  share_name,
  consumer_account,
  query_count,
  bytes_transferred
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
ORDER BY bytes_transferred DESC;
```

### Reader Accounts

**Reader Accounts** allow sharing with non-Snowflake users.

**Characteristics**:
- Managed by provider
- Provider pays for compute
- Read-only access
- No data storage
- Limited to shared data

#### Creating Reader Accounts

```sql
-- Create reader account
CREATE MANAGED ACCOUNT partner_reader
  ADMIN_NAME = 'partner_admin'
  ADMIN_PASSWORD = 'SecurePass123!'
  TYPE = READER
  COMMENT = 'Reader account for Partner ABC';

-- Add to share
ALTER SHARE customer_share ADD ACCOUNTS = partner_reader;

-- View reader accounts
SHOW MANAGED ACCOUNTS;

-- Drop reader account
DROP MANAGED ACCOUNT partner_reader;
```

### Cross-Region and Cross-Cloud Sharing

Share data across regions and cloud providers:

```sql
-- Create share for cross-region
CREATE SHARE global_share;

-- Enable replication
ALTER SHARE global_share SET REPLICATION = TRUE;

-- Add accounts from different regions
ALTER SHARE global_share ADD ACCOUNTS = 
  xy12345,  -- Same region
  ab67890;  -- Different region

-- Note: Cross-region sharing incurs data transfer costs
```

### Managing Shares

#### View Shares

```sql
-- Show all shares (as provider)
SHOW SHARES;

-- Show inbound shares (as consumer)
SHOW SHARES IN ACCOUNT;

-- Describe share
DESC SHARE customer_share;

-- Show grants to share
SHOW GRANTS TO SHARE customer_share;
```

#### Modify Shares

```sql
-- Add objects to share
GRANT SELECT ON TABLE new_table TO SHARE customer_share;

-- Remove objects from share
REVOKE SELECT ON TABLE old_table FROM SHARE customer_share;

-- Add consumer accounts
ALTER SHARE customer_share ADD ACCOUNTS = new_account;

-- Remove consumer accounts
ALTER SHARE customer_share REMOVE ACCOUNTS = old_account;

-- Add comment
ALTER SHARE customer_share SET COMMENT = 'Updated share description';
```

#### Drop Shares

```sql
-- Remove all consumers first
ALTER SHARE customer_share REMOVE ACCOUNTS = xy12345, ab67890;

-- Drop share
DROP SHARE customer_share;
```

### Consuming Shared Data

As a consumer:

```sql
-- View available shares
SHOW SHARES IN ACCOUNT;

-- Create database from share
CREATE DATABASE shared_customer_data
  FROM SHARE provider_account.customer_share;

-- Query shared data
USE DATABASE shared_customer_data;
SELECT * FROM public.customers LIMIT 10;

-- Drop shared database
DROP DATABASE shared_customer_data;
```

### Secure View Optimization

Secure views have limited optimization:

```sql
-- Regular view: Snowflake can optimize
CREATE VIEW regular_view AS
SELECT * FROM large_table WHERE region = 'NORTH';

-- Query: WHERE clause can be pushed down
SELECT * FROM regular_view WHERE sale_date = '2024-01-01';
-- Optimized: WHERE region = 'NORTH' AND sale_date = '2024-01-01'

-- Secure view: Limited optimization
CREATE SECURE VIEW secure_view AS
SELECT * FROM large_table WHERE region = 'NORTH';

-- Query: May not optimize as well
SELECT * FROM secure_view WHERE sale_date = '2024-01-01';
-- May scan more data
```

**Mitigation**:
- Pre-filter data in secure view
- Use materialized views
- Cluster underlying tables

### Monitoring and Auditing

#### Track Share Usage

```sql
-- Data transfer by share
SELECT 
  share_name,
  target_account_name,
  SUM(bytes_transferred) / 1024 / 1024 / 1024 as gb_transferred,
  COUNT(*) as transfer_count
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY share_name, target_account_name
ORDER BY gb_transferred DESC;
```

#### Track Consumer Queries

```sql
-- Queries on shared objects
SELECT 
  query_id,
  user_name,
  query_text,
  execution_time,
  rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name = 'SHARED_DATABASE'
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

#### Audit Share Changes

```sql
-- Share modification history
SELECT 
  share_name,
  granted_on,
  grantee_name,
  privilege,
  granted_by,
  created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES
WHERE deleted_on IS NULL
ORDER BY created_on DESC;
```

### Common Patterns

#### Pattern 1: Partner Data Sharing

```sql
-- Create share for partner
CREATE SHARE partner_xyz_share;

-- Create secure view with partner's data
CREATE SECURE VIEW partner_xyz_sales AS
SELECT 
  sale_id,
  product_name,
  quantity,
  amount,
  sale_date
FROM sales
WHERE partner_id = 'XYZ'
  AND sale_date >= DATEADD(month, -6, CURRENT_DATE());

-- Grant access
GRANT USAGE ON DATABASE sales_db TO SHARE partner_xyz_share;
GRANT USAGE ON SCHEMA sales_db.public TO SHARE partner_xyz_share;
GRANT SELECT ON VIEW partner_xyz_sales TO SHARE partner_xyz_share;

-- Add partner account
ALTER SHARE partner_xyz_share ADD ACCOUNTS = partner_account;
```

#### Pattern 2: Analytics Data Sharing

```sql
-- Create share for analytics
CREATE SHARE analytics_share;

-- Create aggregated secure view
CREATE SECURE VIEW daily_metrics AS
SELECT 
  DATE(order_timestamp) as order_date,
  region,
  COUNT(*) as order_count,
  SUM(amount) as total_revenue,
  AVG(amount) as avg_order_value
FROM orders
WHERE order_date >= DATEADD(year, -1, CURRENT_DATE())
GROUP BY order_date, region;

-- Share view
GRANT USAGE ON DATABASE analytics_db TO SHARE analytics_share;
GRANT USAGE ON SCHEMA analytics_db.public TO SHARE analytics_share;
GRANT SELECT ON VIEW daily_metrics TO SHARE analytics_share;
```

#### Pattern 3: Multi-Tenant Sharing

```sql
-- Create share per tenant
CREATE SHARE tenant_a_share;
CREATE SHARE tenant_b_share;

-- Create tenant-specific secure views
CREATE SECURE VIEW tenant_a_data AS
SELECT * FROM multi_tenant_table WHERE tenant_id = 'A';

CREATE SECURE VIEW tenant_b_data AS
SELECT * FROM multi_tenant_table WHERE tenant_id = 'B';

-- Grant to respective shares
GRANT SELECT ON VIEW tenant_a_data TO SHARE tenant_a_share;
GRANT SELECT ON VIEW tenant_b_data TO SHARE tenant_b_share;
```

### Security Considerations

#### 1. Never Share Sensitive Data Directly

```sql
-- Bad: Sharing table with PII
GRANT SELECT ON TABLE customers TO SHARE my_share;

-- Good: Use secure view with masking
CREATE SECURE VIEW customers_shared AS
SELECT 
  customer_id,
  customer_name,
  CONCAT('***@', SPLIT_PART(email, '@', 2)) as email,
  region
FROM customers;

GRANT SELECT ON VIEW customers_shared TO SHARE my_share;
```

#### 2. Limit Data Scope

```sql
-- Only share necessary data
CREATE SECURE VIEW limited_sales AS
SELECT 
  sale_id,
  product_name,
  amount,
  sale_date
FROM sales
WHERE sale_date >= DATEADD(month, -3, CURRENT_DATE())  -- Last 3 months only
  AND region IN ('NORTH', 'SOUTH');  -- Specific regions only
```

#### 3. Regular Access Reviews

```sql
-- Review share consumers
SHOW GRANTS TO SHARE customer_share;

-- Review shared objects
DESC SHARE customer_share;

-- Remove unnecessary consumers
ALTER SHARE customer_share REMOVE ACCOUNTS = old_account;
```

### Troubleshooting

#### Issue 1: Consumer Can't See Data

**Cause**: Missing grants

**Solution**:
```sql
-- Check grants
SHOW GRANTS TO SHARE my_share;

-- Ensure all levels granted
GRANT USAGE ON DATABASE mydb TO SHARE my_share;
GRANT USAGE ON SCHEMA mydb.public TO SHARE my_share;
GRANT SELECT ON VIEW mydb.public.myview TO SHARE my_share;
```

#### Issue 2: Secure View Performance

**Cause**: Limited optimization

**Solution**:
```sql
-- Pre-filter in secure view
CREATE SECURE VIEW optimized_view AS
SELECT * FROM large_table
WHERE date_column >= DATEADD(year, -1, CURRENT_DATE())  -- Pre-filter
  AND region IN ('NORTH', 'SOUTH');  -- Pre-filter

-- Or use materialized view
CREATE MATERIALIZED VIEW mat_view AS
SELECT * FROM large_table WHERE ...;

CREATE SECURE VIEW secure_mat_view AS
SELECT * FROM mat_view;
```

#### Issue 3: Cross-Region Costs

**Cause**: Data transfer fees

**Solution**:
- Use replication for frequently accessed data
- Consider regional shares
- Monitor data transfer costs

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Shares
Create and configure data shares.

### Exercise 2: Create Secure Views
Build secure views for data sharing.

### Exercise 3: Share Data
Grant access to shares.

### Exercise 4: Consume Shared Data
Access data from shares.

### Exercise 5: Reader Accounts
Create and manage reader accounts.

### Exercise 6: Monitor Sharing
Track share usage and access.

### Exercise 7: Secure View Patterns
Implement common secure view patterns.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Secure Data Sharing enables zero-copy data sharing
- No data duplication or movement
- Provider controls access and pays for storage
- Consumer pays only for compute
- Secure views protect sensitive data and hide logic
- Reader accounts enable sharing with non-Snowflake users
- Cross-region/cloud sharing is supported
- Always use secure views for sharing
- Monitor and audit share usage regularly
- Data marketplace enables data monetization

---

## 📚 Additional Resources

- [Snowflake Docs: Secure Data Sharing](https://docs.snowflake.com/en/user-guide/data-sharing-intro)
- [Secure Views](https://docs.snowflake.com/en/user-guide/views-secure)
- [Reader Accounts](https://docs.snowflake.com/en/user-guide/data-sharing-reader-create)

---

## 🔜 Tomorrow: Day 19 - Time Travel & Fail-Safe

We'll learn about Snowflake's time travel and fail-safe features for data recovery and historical queries.
