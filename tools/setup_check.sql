/*
Setup Verification Script
Run this to verify your Snowflake environment is ready for the bootcamp
*/

-- ============================================================================
-- 1. Account Information
-- ============================================================================
SELECT '=== ACCOUNT INFORMATION ===' as section;

SELECT 
  CURRENT_ACCOUNT() as account_name,
  CURRENT_REGION() as region,
  CURRENT_VERSION() as snowflake_version,
  CURRENT_USER() as current_user,
  CURRENT_ROLE() as current_role;

-- ============================================================================
-- 2. Check Roles and Privileges
-- ============================================================================
SELECT '=== ROLES AND PRIVILEGES ===' as section;

-- Show your roles
SHOW ROLES;

-- Check if you have ACCOUNTADMIN
SELECT 
  CASE 
    WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN '✅ You have ACCOUNTADMIN role'
    ELSE '⚠️  Switch to ACCOUNTADMIN: USE ROLE ACCOUNTADMIN;'
  END as status;

-- ============================================================================
-- 3. Check Databases
-- ============================================================================
SELECT '=== DATABASES ===' as section;

SHOW DATABASES;

-- Check if bootcamp database exists
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ BOOTCAMP_DB exists'
    ELSE '⚠️  Create BOOTCAMP_DB: CREATE DATABASE BOOTCAMP_DB;'
  END as status
FROM INFORMATION_SCHEMA.DATABASES
WHERE DATABASE_NAME = 'BOOTCAMP_DB';

-- ============================================================================
-- 4. Check Warehouses
-- ============================================================================
SELECT '=== WAREHOUSES ===' as section;

SHOW WAREHOUSES;

-- Check if bootcamp warehouse exists
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ BOOTCAMP_WH exists'
    ELSE '⚠️  Create BOOTCAMP_WH: CREATE WAREHOUSE BOOTCAMP_WH WAREHOUSE_SIZE=XSMALL;'
  END as status
FROM INFORMATION_SCHEMA.WAREHOUSES
WHERE WAREHOUSE_NAME = 'BOOTCAMP_WH';

-- ============================================================================
-- 5. Test Basic Operations
-- ============================================================================
SELECT '=== BASIC OPERATIONS TEST ===' as section;

-- Create test table
CREATE OR REPLACE TEMP TABLE setup_test (
  id INT,
  test_value VARCHAR,
  created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert test data
INSERT INTO setup_test (id, test_value) VALUES
  (1, 'Test 1'),
  (2, 'Test 2'),
  (3, 'Test 3');

-- Query test data
SELECT * FROM setup_test;

-- Verify
SELECT 
  CASE 
    WHEN COUNT(*) = 3 THEN '✅ Basic operations working'
    ELSE '❌ Basic operations failed'
  END as status
FROM setup_test;

-- ============================================================================
-- 6. Check ACCOUNT_USAGE Access
-- ============================================================================
SELECT '=== ACCOUNT_USAGE ACCESS ===' as section;

-- Try to query ACCOUNT_USAGE
SELECT 
  CASE 
    WHEN COUNT(*) >= 0 THEN '✅ ACCOUNT_USAGE access confirmed'
    ELSE '❌ No ACCOUNT_USAGE access'
  END as status
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
LIMIT 1;

-- ============================================================================
-- 7. Check Credit Usage (Last 7 Days)
-- ============================================================================
SELECT '=== CREDIT USAGE (LAST 7 DAYS) ===' as section;

SELECT 
  DATE_TRUNC('day', START_TIME) as day,
  WAREHOUSE_NAME,
  SUM(CREDITS_USED) as total_credits,
  ROUND(total_credits * 3, 2) as estimated_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;

-- ============================================================================
-- 8. Check Storage Usage
-- ============================================================================
SELECT '=== STORAGE USAGE ===' as section;

SELECT 
  DATABASE_NAME,
  ROUND(AVERAGE_DATABASE_BYTES / (1024*1024*1024), 2) as avg_storage_gb,
  ROUND(AVERAGE_FAILSAFE_BYTES / (1024*1024*1024), 2) as avg_failsafe_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
WHERE USAGE_DATE >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;

-- ============================================================================
-- 9. Check Available Features
-- ============================================================================
SELECT '=== AVAILABLE FEATURES ===' as section;

-- Check edition
SELECT 
  SYSTEM$GET_SNOWFLAKE_PLATFORM_INFO() as platform_info;

-- ============================================================================
-- 10. Final Status Summary
-- ============================================================================
SELECT '=== SETUP STATUS SUMMARY ===' as section;

SELECT 
  '✅ Account: ' || CURRENT_ACCOUNT() as check_1,
  '✅ Region: ' || CURRENT_REGION() as check_2,
  '✅ User: ' || CURRENT_USER() as check_3,
  '✅ Role: ' || CURRENT_ROLE() as check_4;

SELECT 
  CASE 
    WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN '✅ READY TO START!'
    ELSE '⚠️  Switch to ACCOUNTADMIN role first'
  END as final_status;

-- ============================================================================
-- Recommendations
-- ============================================================================
SELECT '=== RECOMMENDATIONS ===' as section;

SELECT 
  'Set up auto-suspend on warehouses' as recommendation,
  'ALTER WAREHOUSE BOOTCAMP_WH SET AUTO_SUSPEND = 60;' as command
UNION ALL
SELECT 
  'Enable auto-resume on warehouses',
  'ALTER WAREHOUSE BOOTCAMP_WH SET AUTO_RESUME = TRUE;'
UNION ALL
SELECT 
  'Create resource monitor',
  'CREATE RESOURCE MONITOR bootcamp_monitor WITH CREDIT_QUOTA = 50;'
UNION ALL
SELECT 
  'Set up cost alerts',
  'See docs/SETUP.md for resource monitor configuration';

-- ============================================================================
-- Next Steps
-- ============================================================================
SELECT '=== NEXT STEPS ===' as section;

SELECT 
  '1. Review output above for any ⚠️  warnings' as step
UNION ALL
SELECT '2. Fix any issues before starting Day 1'
UNION ALL
SELECT '3. Read QUICKSTART.md for quick setup'
UNION ALL
SELECT '4. Start with days/day-01-snowpipe-continuous-loading/'
UNION ALL
SELECT '5. Set calendar reminders for daily 2-hour blocks';

-- ============================================================================
-- Clean up
-- ============================================================================
DROP TABLE IF EXISTS setup_test;

SELECT '✅ Setup check complete!' as final_message;
