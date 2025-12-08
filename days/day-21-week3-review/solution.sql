/*******************************************************************************
 * Day 21: Week 3 Review & Governance Lab - SOLUTIONS
 * 
 * Complete solutions for the comprehensive governance lab
 * 
 *******************************************************************************/

-- Setup: Create sample healthcare database
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE healthcare_analytics;
USE DATABASE healthcare_analytics;
USE SCHEMA public;

-- Create sample tables
CREATE OR REPLACE TABLE patients (
  patient_id INT,
  ssn STRING,
  first_name STRING,
  last_name STRING,
  date_of_birth DATE,
  email STRING,
  phone STRING,
  hospital_id INT,
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE medical_records (
  record_id INT,
  patient_id INT,
  hospital_id INT,
  diagnosis STRING,
  treatment STRING,
  doctor_name STRING,
  visit_date DATE,
  cost DECIMAL(10,2)
);

CREATE OR REPLACE TABLE hospitals (
  hospital_id INT,
  hospital_name STRING,
  region STRING,
  type STRING
);

-- Insert sample data
INSERT INTO hospitals VALUES
  (1, 'City General Hospital', 'NORTH', 'PUBLIC'),
  (2, 'Regional Medical Center', 'SOUTH', 'PRIVATE'),
  (3, 'University Hospital', 'EAST', 'ACADEMIC'),
  (4, 'Community Health Center', 'WEST', 'PUBLIC');

INSERT INTO patients VALUES
  (1001, '123-45-6789', 'John', 'Doe', '1980-05-15', 'john.doe@email.com', '555-0101', 1, CURRENT_TIMESTAMP()),
  (1002, '234-56-7890', 'Jane', 'Smith', '1975-08-22', 'jane.smith@email.com', '555-0102', 1, CURRENT_TIMESTAMP()),
  (1003, '345-67-8901', 'Bob', 'Johnson', '1990-03-10', 'bob.j@email.com', '555-0103', 2, CURRENT_TIMESTAMP()),
  (1004, '456-78-9012', 'Alice', 'Williams', '1985-11-30', 'alice.w@email.com', '555-0104', 2, CURRENT_TIMESTAMP()),
  (1005, '567-89-0123', 'Charlie', 'Brown', '1978-07-18', 'charlie.b@email.com', '555-0105', 3, CURRENT_TIMESTAMP());

INSERT INTO medical_records VALUES
  (5001, 1001, 1, 'Hypertension', 'Medication', 'Dr. Anderson', '2024-01-10', 250.00),
  (5002, 1002, 1, 'Diabetes Type 2', 'Insulin Therapy', 'Dr. Brown', '2024-01-11', 500.00),
  (5003, 1003, 2, 'Asthma', 'Inhaler', 'Dr. Chen', '2024-01-12', 150.00),
  (5004, 1004, 2, 'Migraine', 'Pain Management', 'Dr. Davis', '2024-01-13', 200.00),
  (5005, 1005, 3, 'Arthritis', 'Physical Therapy', 'Dr. Evans', '2024-01-14', 350.00);

/*******************************************************************************
 * Section 1: Role Hierarchy & Access Control - SOLUTIONS
 *******************************************************************************/

-- Solution 1.1: Create role hierarchy
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS healthcare_admin;
CREATE ROLE IF NOT EXISTS data_engineer;
CREATE ROLE IF NOT EXISTS data_analyst;
CREATE ROLE IF NOT EXISTS hospital_1_analyst;
CREATE ROLE IF NOT EXISTS hospital_2_analyst;
CREATE ROLE IF NOT EXISTS research_partner;

-- Solution 1.2: Set up role inheritance
GRANT ROLE data_engineer TO ROLE healthcare_admin;
GRANT ROLE data_analyst TO ROLE healthcare_admin;
GRANT ROLE hospital_1_analyst TO ROLE data_analyst;
GRANT ROLE hospital_2_analyst TO ROLE data_analyst;
GRANT ROLE research_partner TO ROLE healthcare_admin;

-- Grant to SYSADMIN for management
GRANT ROLE healthcare_admin TO ROLE SYSADMIN;

-- Solution 1.3: Grant database and schema privileges
USE ROLE SYSADMIN;

GRANT USAGE ON DATABASE healthcare_analytics TO ROLE healthcare_admin;
GRANT USAGE ON DATABASE healthcare_analytics TO ROLE data_engineer;
GRANT USAGE ON DATABASE healthcare_analytics TO ROLE data_analyst;
GRANT USAGE ON DATABASE healthcare_analytics TO ROLE hospital_1_analyst;
GRANT USAGE ON DATABASE healthcare_analytics TO ROLE hospital_2_analyst;
GRANT USAGE ON DATABASE healthcare_analytics TO ROLE research_partner;

GRANT USAGE ON SCHEMA healthcare_analytics.public TO ROLE healthcare_admin;
GRANT USAGE ON SCHEMA healthcare_analytics.public TO ROLE data_engineer;
GRANT USAGE ON SCHEMA healthcare_analytics.public TO ROLE data_analyst;
GRANT USAGE ON SCHEMA healthcare_analytics.public TO ROLE hospital_1_analyst;
GRANT USAGE ON SCHEMA healthcare_analytics.public TO ROLE hospital_2_analyst;
GRANT USAGE ON SCHEMA healthcare_analytics.public TO ROLE research_partner;

-- Solution 1.4: Grant table privileges
-- data_engineer: ALL privileges
GRANT ALL ON ALL TABLES IN SCHEMA healthcare_analytics.public TO ROLE data_engineer;

-- data_analyst: SELECT on all tables
GRANT SELECT ON ALL TABLES IN SCHEMA healthcare_analytics.public TO ROLE data_analyst;

-- hospital analysts: SELECT (will be restricted by row access policy)
GRANT SELECT ON ALL TABLES IN SCHEMA healthcare_analytics.public TO ROLE hospital_1_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA healthcare_analytics.public TO ROLE hospital_2_analyst;

-- Solution 1.5: Set up future grants
GRANT ALL ON FUTURE TABLES IN SCHEMA healthcare_analytics.public TO ROLE data_engineer;
GRANT SELECT ON FUTURE TABLES IN SCHEMA healthcare_analytics.public TO ROLE data_analyst;
GRANT SELECT ON FUTURE TABLES IN SCHEMA healthcare_analytics.public TO ROLE hospital_1_analyst;
GRANT SELECT ON FUTURE TABLES IN SCHEMA healthcare_analytics.public TO ROLE hospital_2_analyst;

-- Solution 1.6 & 1.7: Create and populate user access mapping table
USE ROLE SYSADMIN;
USE DATABASE healthcare_analytics;

CREATE OR REPLACE TABLE user_hospital_access (
  role_name STRING,
  hospital_id INT,
  access_level STRING
);

INSERT INTO user_hospital_access VALUES
  ('HEALTHCARE_ADMIN', NULL, 'FULL'),  -- NULL means all hospitals
  ('DATA_ENGINEER', NULL, 'FULL'),
  ('DATA_ANALYST', NULL, 'FULL'),
  ('HOSPITAL_1_ANALYST', 1, 'READ'),
  ('HOSPITAL_2_ANALYST', 2, 'READ');

-- Grant access to mapping table
GRANT SELECT ON TABLE user_hospital_access TO ROLE healthcare_admin;
GRANT SELECT ON TABLE user_hospital_access TO ROLE data_engineer;
GRANT SELECT ON TABLE user_hospital_access TO ROLE data_analyst;
GRANT SELECT ON TABLE user_hospital_access TO ROLE hospital_1_analyst;
GRANT SELECT ON TABLE user_hospital_access TO ROLE hospital_2_analyst;

/*******************************************************************************
 * Section 2: Data Protection - SOLUTIONS
 *******************************************************************************/

-- Solution 2.1: Create masking policy for SSN
CREATE OR REPLACE MASKING POLICY ssn_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('HEALTHCARE_ADMIN', 'DATA_ENGINEER') THEN val
    WHEN CURRENT_ROLE() IN ('DATA_ANALYST') THEN 
      CONCAT('XXX-XX-', RIGHT(val, 4))
    ELSE 'XXX-XX-XXXX'
  END;

-- Solution 2.2: Create masking policy for email
CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('HEALTHCARE_ADMIN', 'DATA_ENGINEER') THEN val
    ELSE REGEXP_REPLACE(val, '^[^@]+', '***')
  END;

-- Solution 2.3: Create masking policy for phone
CREATE OR REPLACE MASKING POLICY phone_mask AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('HEALTHCARE_ADMIN', 'DATA_ENGINEER') THEN val
    ELSE REGEXP_REPLACE(val, '\\d{4}$', 'XXXX')
  END;

-- Solution 2.4: Apply masking policies to patients table
ALTER TABLE patients MODIFY COLUMN ssn SET MASKING POLICY ssn_mask;
ALTER TABLE patients MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE patients MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- Solution 2.5: Create row access policy for hospital isolation
CREATE OR REPLACE ROW ACCESS POLICY hospital_isolation_policy
  AS (hospital_id INT) RETURNS BOOLEAN ->
    CASE
      -- Admins and engineers see all data
      WHEN CURRENT_ROLE() IN ('HEALTHCARE_ADMIN', 'DATA_ENGINEER', 'DATA_ANALYST') THEN TRUE
      -- Hospital-specific analysts see only their hospital
      ELSE EXISTS (
        SELECT 1 FROM user_hospital_access
        WHERE role_name = CURRENT_ROLE()
          AND (user_hospital_access.hospital_id = hospital_id 
               OR user_hospital_access.hospital_id IS NULL)
      )
    END;

-- Solution 2.6: Apply row access policy to patients table
ALTER TABLE patients ADD ROW ACCESS POLICY hospital_isolation_policy ON (hospital_id);

-- Solution 2.7: Apply row access policy to medical_records table
ALTER TABLE medical_records ADD ROW ACCESS POLICY hospital_isolation_policy ON (hospital_id);

-- Solution 2.8: Create secure view for research partners
CREATE OR REPLACE SECURE VIEW research_patient_data AS
SELECT 
  -- Anonymized patient data
  patient_id,
  YEAR(date_of_birth) as birth_year,
  hospital_id,
  created_date
FROM patients;

CREATE OR REPLACE SECURE VIEW research_medical_stats AS
SELECT 
  hospital_id,
  diagnosis,
  COUNT(*) as case_count,
  AVG(cost) as avg_cost,
  MIN(cost) as min_cost,
  MAX(cost) as max_cost
FROM medical_records
GROUP BY hospital_id, diagnosis;

-- Grant access to research partner
GRANT SELECT ON VIEW research_patient_data TO ROLE research_partner;
GRANT SELECT ON VIEW research_medical_stats TO ROLE research_partner;

-- Solution 2.9: Test data protection
-- Test as data_analyst (should see masked SSN)
USE ROLE data_analyst;
SELECT patient_id, ssn, email, phone, hospital_id FROM patients LIMIT 3;

-- Test as hospital_1_analyst (should see only Hospital 1 with masked PII)
USE ROLE hospital_1_analyst;
SELECT patient_id, ssn, first_name, hospital_id FROM patients;
SELECT COUNT(*) as my_hospital_patients FROM patients;

-- Test as hospital_2_analyst
USE ROLE hospital_2_analyst;
SELECT patient_id, first_name, hospital_id FROM patients;
SELECT COUNT(*) as my_hospital_patients FROM patients;

-- Test as research_partner (should see only anonymized data)
USE ROLE research_partner;
SELECT * FROM research_patient_data LIMIT 5;
SELECT * FROM research_medical_stats;

/*******************************************************************************
 * Section 3: Data Recovery & Backup - SOLUTIONS
 *******************************************************************************/

USE ROLE SYSADMIN;
USE DATABASE healthcare_analytics;

-- Solution 3.1: Configure Time Travel retention
ALTER TABLE patients SET DATA_RETENTION_TIME_IN_DAYS = 30;
ALTER TABLE medical_records SET DATA_RETENTION_TIME_IN_DAYS = 30;
ALTER TABLE hospitals SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- Verify retention settings
SHOW TABLES;

-- Solution 3.2: Simulate accidental data deletion
DELETE FROM patients WHERE hospital_id = 3;

-- Verify deletion
SELECT COUNT(*) as remaining_patients FROM patients;
SELECT COUNT(*) as deleted_patients FROM patients WHERE hospital_id = 3;

-- Solution 3.3: Query historical data using Time Travel
-- Get query ID of the DELETE
SET delete_query_id = (
  SELECT query_id
  FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
  WHERE query_text ILIKE '%DELETE FROM patients WHERE hospital_id = 3%'
  ORDER BY start_time DESC
  LIMIT 1
);

-- View data before the deletion
SELECT * FROM patients BEFORE(STATEMENT => $delete_query_id)
WHERE hospital_id = 3;

-- Solution 3.4: Recover deleted data
INSERT INTO patients
SELECT * FROM patients BEFORE(STATEMENT => $delete_query_id)
WHERE hospital_id = 3;

-- Verify recovery
SELECT COUNT(*) as total_patients FROM patients;
SELECT COUNT(*) as hospital_3_patients FROM patients WHERE hospital_id = 3;

-- Solution 3.5: Create a backup procedure
CREATE OR REPLACE PROCEDURE create_healthcare_backup()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  backup_name STRING;
  result STRING;
BEGIN
  backup_name := 'HEALTHCARE_ANALYTICS_BACKUP_' || TO_CHAR(CURRENT_DATE(), 'YYYYMMDD');
  
  -- Drop if exists (for testing)
  EXECUTE IMMEDIATE 'DROP DATABASE IF EXISTS ' || backup_name;
  
  -- Create clone
  EXECUTE IMMEDIATE 'CREATE DATABASE ' || backup_name || ' CLONE HEALTHCARE_ANALYTICS';
  
  -- Add comment
  EXECUTE IMMEDIATE 'COMMENT ON DATABASE ' || backup_name || 
    ' IS ''Automated backup created on ' || CURRENT_TIMESTAMP()::STRING || 
    '. Retention: 30 days.''';
  
  result := 'Backup created successfully: ' || backup_name;
  RETURN result;
END;
$$;

-- Solution 3.6: Test the backup procedure
CALL create_healthcare_backup();

-- Solution 3.7: Create a point-in-time snapshot
CREATE DATABASE healthcare_analytics_snapshot_1hr CLONE healthcare_analytics
AT(OFFSET => -3600);

-- Solution 3.8: Verify backup integrity
-- Compare row counts
SELECT 'Production' as environment, COUNT(*) as patient_count 
FROM healthcare_analytics.public.patients
UNION ALL
SELECT 'Backup' as environment, COUNT(*) as patient_count 
FROM healthcare_analytics_backup_20240115.public.patients;

-- Detailed comparison
SELECT 
  'Production' as env,
  (SELECT COUNT(*) FROM healthcare_analytics.public.patients) as patients,
  (SELECT COUNT(*) FROM healthcare_analytics.public.medical_records) as records,
  (SELECT COUNT(*) FROM healthcare_analytics.public.hospitals) as hospitals
UNION ALL
SELECT 
  'Backup' as env,
  (SELECT COUNT(*) FROM healthcare_analytics_backup_20240115.public.patients) as patients,
  (SELECT COUNT(*) FROM healthcare_analytics_backup_20240115.public.medical_records) as records,
  (SELECT COUNT(*) FROM healthcare_analytics_backup_20240115.public.hospitals) as hospitals;

/*******************************************************************************
 * Section 4: Monitoring & Auditing - SOLUTIONS
 *******************************************************************************/

-- Solution 4.1: Create audit log for data access
CREATE OR REPLACE VIEW patient_data_access_log AS
SELECT 
  user_name,
  role_name,
  query_text,
  database_name,
  schema_name,
  start_time,
  end_time,
  total_elapsed_time / 1000 as elapsed_seconds,
  rows_produced,
  bytes_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%patients%'
  AND query_type = 'SELECT'
  AND execution_status = 'SUCCESS'
  AND start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- Query the audit log
SELECT * FROM patient_data_access_log LIMIT 20;

-- Solution 4.2: Monitor masking policy usage
CREATE OR REPLACE VIEW masking_policy_usage AS
SELECT 
  policy_name,
  ref_database_name,
  ref_schema_name,
  ref_entity_name,
  ref_column_name,
  policy_status
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'MASKING_POLICY'
  AND ref_database_name = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL;

SELECT * FROM masking_policy_usage;

-- Solution 4.3: Monitor row access policy effectiveness
CREATE OR REPLACE VIEW row_access_policy_usage AS
SELECT 
  policy_name,
  ref_database_name,
  ref_schema_name,
  ref_entity_name,
  ref_arg_column_names,
  policy_status
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'ROW_ACCESS_POLICY'
  AND ref_database_name = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL;

SELECT * FROM row_access_policy_usage;

-- Solution 4.4: Create alert for suspicious access patterns
CREATE OR REPLACE VIEW suspicious_access_patterns AS
SELECT 
  user_name,
  role_name,
  COUNT(*) as query_count,
  SUM(rows_produced) as total_rows_accessed,
  MAX(rows_produced) as max_rows_in_single_query,
  MIN(start_time) as first_access,
  MAX(start_time) as last_access
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%patients%'
  AND start_time > DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND execution_status = 'SUCCESS'
GROUP BY user_name, role_name
HAVING SUM(rows_produced) > 1000  -- Alert if accessing >1000 patient records
ORDER BY total_rows_accessed DESC;

SELECT * FROM suspicious_access_patterns;

-- Solution 4.5: Monitor Time Travel storage costs
CREATE OR REPLACE VIEW time_travel_storage_report AS
SELECT 
  table_catalog,
  table_schema,
  table_name,
  active_bytes / 1024 / 1024 / 1024 as active_gb,
  time_travel_bytes / 1024 / 1024 / 1024 as time_travel_gb,
  failsafe_bytes / 1024 / 1024 / 1024 as failsafe_gb,
  (time_travel_bytes + failsafe_bytes) / 1024 / 1024 / 1024 as total_protection_gb,
  ROUND((time_travel_bytes + failsafe_bytes)::FLOAT / 
    NULLIF(active_bytes, 0) * 100, 2) as protection_overhead_pct
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL
ORDER BY total_protection_gb DESC;

SELECT * FROM time_travel_storage_report;

-- Solution 4.6: Create compliance report
CREATE OR REPLACE VIEW compliance_access_report AS
SELECT 
  user_name,
  role_name,
  query_text,
  start_time,
  rows_produced,
  CASE 
    WHEN query_text ILIKE '%ssn%' THEN 'SSN_ACCESS'
    WHEN query_text ILIKE '%email%' THEN 'EMAIL_ACCESS'
    WHEN query_text ILIKE '%phone%' THEN 'PHONE_ACCESS'
    ELSE 'GENERAL_ACCESS'
  END as access_type,
  execution_status
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name = 'HEALTHCARE_ANALYTICS'
  AND (query_text ILIKE '%patients%' OR query_text ILIKE '%medical_records%')
  AND start_time > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

SELECT * FROM compliance_access_report LIMIT 50;

-- Generate summary report
SELECT 
  DATE(start_time) as access_date,
  role_name,
  access_type,
  COUNT(*) as access_count,
  SUM(rows_produced) as total_rows_accessed
FROM compliance_access_report
GROUP BY DATE(start_time), role_name, access_type
ORDER BY access_date DESC, access_count DESC;

-- Solution 4.7: Monitor clone storage
CREATE OR REPLACE VIEW clone_storage_report AS
SELECT 
  table_catalog,
  table_schema,
  table_name,
  is_clone,
  clone_group_id,
  bytes / 1024 / 1024 / 1024 as size_gb,
  row_count,
  created,
  DATEDIFF(day, created, CURRENT_TIMESTAMP()) as age_days
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE table_catalog LIKE 'HEALTHCARE_ANALYTICS%'
  AND deleted IS NULL
ORDER BY bytes DESC;

SELECT * FROM clone_storage_report;

-- Database-level clone summary
SELECT 
  database_name,
  CASE 
    WHEN database_name LIKE '%BACKUP%' THEN 'Backup'
    WHEN database_name LIKE '%SNAPSHOT%' THEN 'Snapshot'
    ELSE 'Production'
  END as database_type,
  created,
  DATEDIFF(day, created, CURRENT_TIMESTAMP()) as age_days
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE 'HEALTHCARE_ANALYTICS%'
  AND deleted IS NULL
ORDER BY created DESC;

-- Solution 4.8: Create security dashboard view
CREATE OR REPLACE VIEW security_dashboard AS
SELECT 
  'Masking Policies' as metric_category,
  'Active Policies' as metric_name,
  COUNT(DISTINCT policy_name)::STRING as metric_value
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'MASKING_POLICY'
  AND ref_database_name = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL

UNION ALL

SELECT 
  'Row Access Policies' as metric_category,
  'Active Policies' as metric_name,
  COUNT(DISTINCT policy_name)::STRING as metric_value
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'ROW_ACCESS_POLICY'
  AND ref_database_name = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL

UNION ALL

SELECT 
  'Data Access' as metric_category,
  'Queries Last 24h' as metric_name,
  COUNT(*)::STRING as metric_value
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name = 'HEALTHCARE_ANALYTICS'
  AND start_time > DATEADD(hour, -24, CURRENT_TIMESTAMP())

UNION ALL

SELECT 
  'Data Access' as metric_category,
  'Unique Users Last 24h' as metric_name,
  COUNT(DISTINCT user_name)::STRING as metric_value
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name = 'HEALTHCARE_ANALYTICS'
  AND start_time > DATEADD(hour, -24, CURRENT_TIMESTAMP())

UNION ALL

SELECT 
  'Storage' as metric_category,
  'Time Travel Storage (GB)' as metric_name,
  ROUND(SUM(time_travel_bytes) / 1024 / 1024 / 1024, 2)::STRING as metric_value
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL

UNION ALL

SELECT 
  'Backups' as metric_category,
  'Active Backups' as metric_name,
  COUNT(*)::STRING as metric_value
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE 'HEALTHCARE_ANALYTICS_BACKUP%'
  AND deleted IS NULL;

SELECT * FROM security_dashboard
ORDER BY metric_category, metric_name;

/*******************************************************************************
 * Bonus Challenges - SOLUTIONS
 *******************************************************************************/

-- BONUS 1: Implement data retention policy
-- Create archive table
CREATE OR REPLACE TABLE patients_archive LIKE patients;

-- Create stream to track changes
CREATE OR REPLACE STREAM patients_archive_stream ON TABLE patients;

-- Create task to archive old records
CREATE OR REPLACE TASK archive_old_patients
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 2 * * 0 America/New_York'  -- Weekly on Sunday at 2 AM
AS
  INSERT INTO patients_archive
  SELECT * FROM patients
  WHERE created_date < DATEADD(year, -7, CURRENT_DATE())
    AND patient_id NOT IN (SELECT patient_id FROM patients_archive);

-- Note: In production, you'd also delete from patients after archiving
-- ALTER TASK archive_old_patients RESUME;

-- BONUS 2: Create emergency access procedure
CREATE OR REPLACE TABLE emergency_access_log (
  access_time TIMESTAMP,
  user_name STRING,
  role_name STRING,
  reason STRING,
  approved_by STRING
);

CREATE OR REPLACE PROCEDURE request_emergency_access(
  reason STRING,
  approved_by STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Log the emergency access
  INSERT INTO emergency_access_log VALUES (
    CURRENT_TIMESTAMP(),
    CURRENT_USER(),
    CURRENT_ROLE(),
    :reason,
    :approved_by
  );
  
  -- In production, this would temporarily grant elevated privileges
  -- For demo, we just log it
  
  RETURN 'Emergency access granted and logged. Access expires in 1 hour.';
END;
$$;

-- Test emergency access
-- CALL request_emergency_access('Data recovery after incident', 'CTO');

-- BONUS 3: Implement data sharing with research partner
CREATE OR REPLACE SHARE healthcare_research_share;

-- Add database to share
GRANT USAGE ON DATABASE healthcare_analytics TO SHARE healthcare_research_share;
GRANT USAGE ON SCHEMA healthcare_analytics.public TO SHARE healthcare_research_share;

-- Share only the secure views (not raw tables)
GRANT SELECT ON VIEW healthcare_analytics.public.research_patient_data 
  TO SHARE healthcare_research_share;
GRANT SELECT ON VIEW healthcare_analytics.public.research_medical_stats 
  TO SHARE healthcare_research_share;

-- Add comment
COMMENT ON SHARE healthcare_research_share IS 
  'Anonymized healthcare data for research purposes. 
   Contains no PII. Updated daily.';

-- View share details
SHOW GRANTS TO SHARE healthcare_research_share;

-- In production, add consumer account:
-- ALTER SHARE healthcare_research_share ADD ACCOUNTS = xy12345;

-- BONUS 4: Build automated compliance reporting
CREATE OR REPLACE PROCEDURE generate_daily_compliance_report()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  report_date DATE;
  result STRING;
BEGIN
  report_date := CURRENT_DATE();
  
  -- Create compliance report table if not exists
  CREATE TABLE IF NOT EXISTS daily_compliance_reports (
    report_date DATE,
    metric_name STRING,
    metric_value STRING,
    generated_at TIMESTAMP
  );
  
  -- Insert daily metrics
  INSERT INTO daily_compliance_reports
  SELECT 
    report_date,
    'Total Patient Access Queries' as metric_name,
    COUNT(*)::STRING as metric_value,
    CURRENT_TIMESTAMP() as generated_at
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
  WHERE database_name = 'HEALTHCARE_ANALYTICS'
    AND query_text ILIKE '%patients%'
    AND DATE(start_time) = report_date;
  
  INSERT INTO daily_compliance_reports
  SELECT 
    report_date,
    'Unique Users Accessing Data' as metric_name,
    COUNT(DISTINCT user_name)::STRING as metric_value,
    CURRENT_TIMESTAMP() as generated_at
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
  WHERE database_name = 'HEALTHCARE_ANALYTICS'
    AND DATE(start_time) = report_date;
  
  INSERT INTO daily_compliance_reports
  SELECT 
    report_date,
    'Failed Access Attempts' as metric_name,
    COUNT(*)::STRING as metric_value,
    CURRENT_TIMESTAMP() as generated_at
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
  WHERE database_name = 'HEALTHCARE_ANALYTICS'
    AND execution_status = 'FAIL'
    AND DATE(start_time) = report_date;
  
  result := 'Compliance report generated for ' || report_date::STRING;
  RETURN result;
END;
$$;

-- Create task to run daily
CREATE OR REPLACE TASK daily_compliance_report_task
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 1 * * * America/New_York'  -- Daily at 1 AM
AS
  CALL generate_daily_compliance_report();

-- Enable task
-- ALTER TASK daily_compliance_report_task RESUME;

-- Test the procedure
CALL generate_daily_compliance_report();

-- BONUS 5: Implement change data capture for audit
CREATE OR REPLACE TABLE patients_audit_log (
  audit_id INT AUTOINCREMENT,
  patient_id INT,
  change_type STRING,  -- INSERT, UPDATE, DELETE
  changed_by STRING,
  changed_at TIMESTAMP,
  old_values VARIANT,
  new_values VARIANT
);

-- Create stream on patients table
CREATE OR REPLACE STREAM patients_changes ON TABLE patients;

-- Create task to capture changes
CREATE OR REPLACE TASK capture_patient_changes
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('patients_changes')
AS
  INSERT INTO patients_audit_log (
    patient_id,
    change_type,
    changed_by,
    changed_at,
    old_values,
    new_values
  )
  SELECT 
    patient_id,
    METADATA$ACTION as change_type,
    CURRENT_USER() as changed_by,
    CURRENT_TIMESTAMP() as changed_at,
    CASE 
      WHEN METADATA$ACTION = 'DELETE' THEN OBJECT_CONSTRUCT(*)
      WHEN METADATA$ACTION = 'UPDATE' AND METADATA$ISUPDATE = TRUE THEN OBJECT_CONSTRUCT(*)
      ELSE NULL
    END as old_values,
    CASE 
      WHEN METADATA$ACTION = 'INSERT' THEN OBJECT_CONSTRUCT(*)
      WHEN METADATA$ACTION = 'UPDATE' AND METADATA$ISUPDATE = FALSE THEN OBJECT_CONSTRUCT(*)
      ELSE NULL
    END as new_values
  FROM patients_changes;

-- Enable task
-- ALTER TASK capture_patient_changes RESUME;

-- Test: Make a change and check audit log
UPDATE patients SET email = 'newemail@test.com' WHERE patient_id = 1001;

-- Wait for task to run or manually execute
-- EXECUTE TASK capture_patient_changes;

-- View audit log
SELECT * FROM patients_audit_log ORDER BY changed_at DESC;

/*******************************************************************************
 * Testing & Validation - SOLUTIONS
 *******************************************************************************/

-- Test 1: Verify role hierarchy
USE ROLE SECURITYADMIN;
SHOW GRANTS TO ROLE healthcare_admin;
SHOW GRANTS TO ROLE data_analyst;
SHOW GRANTS TO ROLE hospital_1_analyst;

-- Verify role inheritance
SELECT 
  grantee_name,
  role_name,
  granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name IN ('HEALTHCARE_ADMIN', 'DATA_ANALYST', 'HOSPITAL_1_ANALYST')
  AND granted_on = 'ROLE'
  AND deleted_on IS NULL
ORDER BY grantee_name;

-- Test 2: Verify masking policies
USE ROLE data_analyst;
SELECT patient_id, ssn, email, phone FROM patients LIMIT 5;
-- Should see: XXX-XX-1234 for SSN, ***@domain.com for email, 555-XXXX for phone

USE ROLE hospital_1_analyst;
SELECT patient_id, ssn, email, phone FROM patients LIMIT 5;
-- Should see: XXX-XX-XXXX for SSN, ***@domain.com for email, 555-XXXX for phone

USE ROLE healthcare_admin;
SELECT patient_id, ssn, email, phone FROM patients LIMIT 5;
-- Should see: Full SSN, email, and phone

-- Test 3: Verify row access policies
USE ROLE hospital_1_analyst;
SELECT COUNT(*) as my_patients FROM patients;
SELECT DISTINCT hospital_id FROM patients;  -- Should only see hospital_id = 1

USE ROLE hospital_2_analyst;
SELECT COUNT(*) as my_patients FROM patients;
SELECT DISTINCT hospital_id FROM patients;  -- Should only see hospital_id = 2

USE ROLE data_analyst;
SELECT COUNT(*) as all_patients FROM patients;
SELECT DISTINCT hospital_id FROM patients;  -- Should see all hospitals

-- Test 4: Verify Time Travel
USE ROLE SYSADMIN;
SELECT COUNT(*) as current_count FROM patients;
SELECT COUNT(*) as count_1hr_ago FROM patients AT(OFFSET => -3600);

-- Test 5: Verify backups exist
SHOW DATABASES LIKE '%HEALTHCARE_ANALYTICS%';

SELECT 
  database_name,
  created,
  comment
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE 'HEALTHCARE_ANALYTICS%'
  AND deleted IS NULL
ORDER BY created DESC;

-- Test 6: Verify audit logging
SELECT * FROM patient_data_access_log LIMIT 10;
SELECT * FROM compliance_access_report LIMIT 10;
SELECT * FROM security_dashboard;

-- Test 7: Verify secure views for research
USE ROLE research_partner;
SELECT * FROM research_patient_data LIMIT 5;
SELECT * FROM research_medical_stats;

-- Verify cannot access raw tables
-- SELECT * FROM patients;  -- Should fail with insufficient privileges

/*******************************************************************************
 * Summary Report
 *******************************************************************************/

USE ROLE SYSADMIN;

-- Generate comprehensive security summary
SELECT '=== HEALTHCARE ANALYTICS SECURITY SUMMARY ===' as report_section;

SELECT 'Roles Created' as metric, COUNT(*) as value
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE name LIKE '%HOSPITAL%' OR name LIKE '%HEALTHCARE%' OR name LIKE '%RESEARCH%'
  AND deleted_on IS NULL

UNION ALL

SELECT 'Masking Policies' as metric, COUNT(DISTINCT policy_name) as value
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'MASKING_POLICY'
  AND ref_database_name = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL

UNION ALL

SELECT 'Row Access Policies' as metric, COUNT(DISTINCT policy_name) as value
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'ROW_ACCESS_POLICY'
  AND ref_database_name = 'HEALTHCARE_ANALYTICS'
  AND deleted IS NULL

UNION ALL

SELECT 'Secure Views' as metric, COUNT(*) as value
FROM SNOWFLAKE.ACCOUNT_USAGE.VIEWS
WHERE table_catalog = 'HEALTHCARE_ANALYTICS'
  AND is_secure = 'YES'
  AND deleted IS NULL

UNION ALL

SELECT 'Active Backups' as metric, COUNT(*) as value
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
WHERE database_name LIKE 'HEALTHCARE_ANALYTICS_BACKUP%'
  AND deleted IS NULL

UNION ALL

SELECT 'Data Shares' as metric, COUNT(*) as value
FROM SNOWFLAKE.ACCOUNT_USAGE.SHARES
WHERE name LIKE '%HEALTHCARE%'
  AND deleted IS NULL;

/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up all objects
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS healthcare_analytics CASCADE;
DROP DATABASE IF EXISTS healthcare_analytics_backup_20240115 CASCADE;
DROP DATABASE IF EXISTS healthcare_analytics_snapshot_1hr CASCADE;
DROP SHARE IF EXISTS healthcare_research_share;

USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS healthcare_admin;
DROP ROLE IF EXISTS data_engineer;
DROP ROLE IF EXISTS data_analyst;
DROP ROLE IF EXISTS hospital_1_analyst;
DROP ROLE IF EXISTS hospital_2_analyst;
DROP ROLE IF EXISTS research_partner;
*/

/*******************************************************************************
 * Congratulations!
 * 
 * You've completed the Week 3 Governance Lab and built a comprehensive
 * security and governance framework including:
 * 
 * ✅ Role hierarchy with least privilege access
 * ✅ Data masking for PII protection
 * ✅ Row-level security for multi-tenant isolation
 * ✅ Secure views for external data sharing
 * ✅ Time Travel configuration for data recovery
 * ✅ Automated backup procedures
 * ✅ Comprehensive audit logging and monitoring
 * ✅ Compliance reporting
 * 
 * This framework demonstrates production-ready security practices for
 * handling sensitive data in Snowflake, meeting HIPAA and other compliance
 * requirements.
 * 
 * Next: Take the 50-question Week 3 Review Quiz!
 * 
 *******************************************************************************/
