# Snowflake Setup Guide

Complete setup guide for the 30 Days of Snowflake bootcamp.

---

## Table of Contents

1. [Snowflake Account Setup](#snowflake-account-setup)
2. [Initial Configuration](#initial-configuration)
3. [Cloud Storage Setup](#cloud-storage-setup)
4. [Verification](#verification)
5. [Troubleshooting](#troubleshooting)

---

## Snowflake Account Setup

### Option 1: Free Trial (Recommended)

1. **Sign Up**
   - Go to https://signup.snowflake.com
   - Fill in your information
   - Choose cloud provider (AWS recommended)
   - Select region closest to you

2. **What You Get**
   - 30 days free trial
   - $400 in credits
   - Full Enterprise Edition features
   - No credit card required

3. **Activation**
   - Check email for activation link
   - Set password
   - Log in to Snowsight

### Option 2: Existing Account

If you already have a Snowflake account:
- Ensure you have ACCOUNTADMIN role
- Verify you have sufficient credits
- Check your edition supports required features

---

## Initial Configuration

### Step 1: Create Bootcamp Database

```sql
-- Use ACCOUNTADMIN role
USE ROLE ACCOUNTADMIN;

-- Create database
CREATE DATABASE IF NOT EXISTS BOOTCAMP_DB
  COMMENT = '30 Days Snowflake Bootcamp';

-- Create schemas for each week
CREATE SCHEMA IF NOT EXISTS BOOTCAMP_DB.WEEK1_DATA_MOVEMENT;
CREATE SCHEMA IF NOT EXISTS BOOTCAMP_DB.WEEK2_PERFORMANCE;
CREATE SCHEMA IF NOT EXISTS BOOTCAMP_DB.WEEK3_SECURITY;
CREATE SCHEMA IF NOT EXISTS BOOTCAMP_DB.WEEK4_ADVANCED;

-- Verify
SHOW DATABASES LIKE 'BOOTCAMP%';
SHOW SCHEMAS IN DATABASE BOOTCAMP_DB;
```

### Step 2: Create Warehouses

```sql
-- Small warehouse for learning
CREATE WAREHOUSE IF NOT EXISTS BOOTCAMP_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Main warehouse for bootcamp exercises';

-- Larger warehouse for performance testing
CREATE WAREHOUSE IF NOT EXISTS BOOTCAMP_PERF_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for performance testing';

-- Verify
SHOW WAREHOUSES LIKE 'BOOTCAMP%';
```

### Step 3: Create Roles (Optional)

```sql
-- Create bootcamp role
CREATE ROLE IF NOT EXISTS BOOTCAMP_ROLE;

-- Grant privileges
GRANT USAGE ON DATABASE BOOTCAMP_DB TO ROLE BOOTCAMP_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE BOOTCAMP_DB TO ROLE BOOTCAMP_ROLE;
GRANT CREATE SCHEMA ON DATABASE BOOTCAMP_DB TO ROLE BOOTCAMP_ROLE;
GRANT USAGE ON WAREHOUSE BOOTCAMP_WH TO ROLE BOOTCAMP_ROLE;
GRANT USAGE ON WAREHOUSE BOOTCAMP_PERF_WH TO ROLE BOOTCAMP_ROLE;

-- Grant role to your user
GRANT ROLE BOOTCAMP_ROLE TO USER <your_username>;

-- Verify
SHOW GRANTS TO ROLE BOOTCAMP_ROLE;
```

---

## Cloud Storage Setup

Choose your cloud provider:

### AWS S3 Setup

See [AWS_SETUP.md](AWS_SETUP.md) for detailed instructions.

**Quick setup:**
```bash
# Create bucket
aws s3 mb s3://snowflake-bootcamp-[your-name] --region us-east-1

# Upload test file
echo '{"test": "data"}' > test.json
aws s3 cp test.json s3://snowflake-bootcamp-[your-name]/

# Verify
aws s3 ls s3://snowflake-bootcamp-[your-name]/
```

### Azure Blob Setup

See [AZURE_SETUP.md](AZURE_SETUP.md) for detailed instructions.

**Quick setup:**
```bash
# Create storage account
az storage account create \
  --name snowflakebootcamp \
  --resource-group mygroup \
  --location eastus

# Create container
az storage container create \
  --name data \
  --account-name snowflakebootcamp
```

### GCP Setup

**Quick setup:**
```bash
# Create bucket
gsutil mb -l us-east1 gs://snowflake-bootcamp-[your-name]

# Upload test file
echo '{"test": "data"}' > test.json
gsutil cp test.json gs://snowflake-bootcamp-[your-name]/

# Verify
gsutil ls gs://snowflake-bootcamp-[your-name]/
```

---

## Verification

### Test 1: Basic Queries

```sql
-- Use bootcamp warehouse
USE WAREHOUSE BOOTCAMP_WH;
USE DATABASE BOOTCAMP_DB;
USE SCHEMA WEEK1_DATA_MOVEMENT;

-- Create test table
CREATE OR REPLACE TABLE test_table (
  id INT,
  name VARCHAR,
  created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert data
INSERT INTO test_table (id, name) VALUES
  (1, 'Test 1'),
  (2, 'Test 2'),
  (3, 'Test 3');

-- Query data
SELECT * FROM test_table;

-- Clean up
DROP TABLE test_table;
```

### Test 2: Storage Integration

```sql
-- Create storage integration (replace with your values)
CREATE OR REPLACE STORAGE INTEGRATION test_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_ACCOUNT:role/snowflake-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket/');

-- Describe integration
DESC STORAGE INTEGRATION test_integration;

-- If successful, you'll see IAM user ARN
-- Use this to configure AWS IAM trust policy
```

### Test 3: Account Usage Views

```sql
-- Check if you have access to ACCOUNT_USAGE
SELECT COUNT(*) 
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(hour, -1, CURRENT_TIMESTAMP());

-- If this works, you have proper access
```

---

## Troubleshooting

### Issue: "Insufficient privileges"

**Solution:**
```sql
-- Switch to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Grant necessary privileges
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SYSADMIN;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE SYSADMIN;
```

### Issue: "Warehouse suspended"

**Solution:**
```sql
-- Resume warehouse
ALTER WAREHOUSE BOOTCAMP_WH RESUME;

-- Or enable auto-resume
ALTER WAREHOUSE BOOTCAMP_WH SET AUTO_RESUME = TRUE;
```

### Issue: "Cannot access ACCOUNT_USAGE"

**Solution:**
- ACCOUNT_USAGE views have 45-minute latency
- Use INFORMATION_SCHEMA for real-time data
- Ensure you have ACCOUNTADMIN role

### Issue: Storage integration fails

**Solution:**
1. Verify IAM role ARN is correct
2. Check trust policy in AWS IAM
3. Ensure external ID matches
4. See [AWS_SETUP.md](AWS_SETUP.md) for detailed steps

---

## Cost Management

### Monitor Credit Usage

```sql
-- Daily credit usage
SELECT 
  DATE_TRUNC('day', START_TIME) as day,
  WAREHOUSE_NAME,
  SUM(CREDITS_USED) as total_credits,
  ROUND(total_credits * 3, 2) as estimated_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;
```

### Set Resource Monitors

```sql
-- Create resource monitor
CREATE RESOURCE MONITOR bootcamp_monitor
  WITH CREDIT_QUOTA = 50
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Assign to warehouse
ALTER WAREHOUSE BOOTCAMP_WH SET RESOURCE_MONITOR = bootcamp_monitor;
```

### Best Practices

1. **Always set AUTO_SUSPEND**
   ```sql
   ALTER WAREHOUSE BOOTCAMP_WH SET AUTO_SUSPEND = 60;
   ```

2. **Use smallest warehouse possible**
   - Start with XSMALL
   - Scale up only if needed

3. **Suspend when not in use**
   ```sql
   ALTER WAREHOUSE BOOTCAMP_WH SUSPEND;
   ```

4. **Monitor regularly**
   - Check credit usage daily
   - Set up email alerts
   - Use resource monitors

---

## Next Steps

1. ✅ Complete this setup
2. 📖 Review [QUICKSTART.md](../QUICKSTART.md)
3. 🚀 Start [Day 1](../days/day-01-snowpipe-continuous-loading/README.md)
4. 📚 Bookmark [Snowflake Documentation](https://docs.snowflake.com)

---

## Additional Resources

- [Snowflake Trial Guide](https://docs.snowflake.com/en/user-guide/admin-trial-account)
- [Warehouse Sizing](https://docs.snowflake.com/en/user-guide/warehouses-considerations)
- [Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors)
- [Cost Management](https://docs.snowflake.com/en/user-guide/cost-understanding)
