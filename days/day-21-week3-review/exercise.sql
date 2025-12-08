/*******************************************************************************
 * Day 21: Week 3 Review & Governance Lab
 * 
 * Time: 40 minutes
 * 
 * Lab Sections:
 * 1. Role Hierarchy & Access Control (10 min)
 * 2. Data Protection (Masking & Row Access) (10 min)
 * 3. Data Recovery & Backup (10 min)
 * 4. Monitoring & Auditing (10 min)
 * 
 * Scenario:
 * You're building a complete security and governance framework for a 
 * healthcare analytics platform that handles sensitive patient data.
 * 
 * Requirements:
 * - HIPAA compliance (data masking, access control, audit logging)
 * - Multi-tenant isolation (hospitals can only see their data)
 * - Data recovery capabilities (Time Travel, backups)
 * - Secure data sharing with research partners
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
 * Section 1: Role Hierarchy & Access Control (10 min)
 * 
 * Build a complete role hierarchy for the healthcare platform.
 *******************************************************************************/

-- TODO 1.1: Create role hierarchy
-- Create the following roles:
-- - healthcare_admin (top-level admin)
-- - data_engineer (can manage data pipelines)
-- - data_analyst (can query all data)
-- - hospital_1_analyst (can only see Hospital 1 data)
-- - hospital_2_analyst (can only see Hospital 2 data)
-- - research_partner (limited access for research)


-- TODO 1.2: Set up role inheritance
-- Grant roles to appropriate parent roles
-- healthcare_admin should inherit all other roles


-- TODO 1.3: Grant database and schema privileges
-- Grant USAGE on database and schema to all roles


-- TODO 1.4: Grant table privileges
-- data_engineer: ALL privileges on all tables
-- data_analyst: SELECT on all tables
-- hospital analysts: SELECT on specific tables (will be restricted by row access policy)
-- research_partner: SELECT on specific secure views only


-- TODO 1.5: Set up future grants
-- Ensure new tables automatically get appropriate privileges


-- TODO 1.6: Create a user access mapping table
-- This will be used for row access policies
CREATE OR REPLACE TABLE user_hospital_access (
  role_name STRING,
  hospital_id INT,
  access_level STRING
);

-- TODO 1.7: Populate the mapping table
-- Map roles to hospitals they can access


/*******************************************************************************
 * Section 2: Data Protection (10 min)
 * 
 * Implement masking policies and row access policies for HIPAA compliance.
 *******************************************************************************/

-- TODO 2.1: Create masking policy for SSN
-- Full SSN for healthcare_admin and data_engineer
-- Masked (XXX-XX-1234) for data_analyst
-- Fully masked (XXX-XX-XXXX) for others


-- TODO 2.2: Create masking policy for email
-- Full email for admin and engineer
-- Masked (***@domain.com) for others


-- TODO 2.3: Create masking policy for phone
-- Full phone for admin and engineer
-- Masked (555-XXXX) for others


-- TODO 2.4: Apply masking policies to patients table


-- TODO 2.5: Create row access policy for hospital isolation
-- Allow users to see only their hospital's data
-- Admins and engineers can see all data
-- Use the user_hospital_access mapping table


-- TODO 2.6: Apply row access policy to patients table


-- TODO 2.7: Apply row access policy to medical_records table


-- TODO 2.8: Create secure view for research partners
-- Anonymized patient data (no PII)
-- Aggregated medical statistics


-- TODO 2.9: Test data protection
-- Query as different roles and verify masking/filtering works


/*******************************************************************************
 * Section 3: Data Recovery & Backup (10 min)
 * 
 * Implement Time Travel and backup strategies.
 *******************************************************************************/

-- TODO 3.1: Configure Time Travel retention
-- Set 30 days for patients and medical_records (critical data)
-- Set 7 days for hospitals (reference data)


-- TODO 3.2: Simulate accidental data deletion
-- Delete some patient records


-- TODO 3.3: Query historical data using Time Travel
-- View data as it was before the deletion


-- TODO 3.4: Recover deleted data
-- Use Time Travel to restore the deleted records


-- TODO 3.5: Create a backup procedure
-- Procedure should clone the database with date suffix


-- TODO 3.6: Test the backup procedure
-- Create a backup of the healthcare_analytics database


-- TODO 3.7: Create a point-in-time snapshot
-- Clone the database as it was 1 hour ago


-- TODO 3.8: Verify backup integrity
-- Compare row counts between production and backup


/*******************************************************************************
 * Section 4: Monitoring & Auditing (10 min)
 * 
 * Build audit queries and monitoring dashboards.
 *******************************************************************************/

-- TODO 4.1: Create audit log for data access
-- Query ACCOUNT_USAGE.QUERY_HISTORY to track who accessed patient data


-- TODO 4.2: Monitor masking policy usage
-- Track which roles are accessing masked columns


-- TODO 4.3: Monitor row access policy effectiveness
-- Verify users are only seeing their authorized data


-- TODO 4.4: Create alert for suspicious access patterns
-- Identify queries accessing large amounts of patient data


-- TODO 4.5: Monitor Time Travel storage costs
-- Track storage used by Time Travel and Fail-Safe


-- TODO 4.6: Create compliance report
-- Show all access to patient data in the last 7 days
-- Include: user, role, query, timestamp, rows accessed


-- TODO 4.7: Monitor clone storage
-- Track storage used by database clones


-- TODO 4.8: Create security dashboard view
-- Combine all monitoring queries into a single view


/*******************************************************************************
 * Bonus Challenges (Optional)
 *******************************************************************************/

-- BONUS 1: Implement data retention policy
-- Automatically archive patient records older than 7 years
-- Use tasks and streams


-- BONUS 2: Create emergency access procedure
-- Allow ACCOUNTADMIN to temporarily bypass row access policies
-- Log all emergency access


-- BONUS 3: Implement data sharing with research partner
-- Create share with anonymized data
-- Apply additional security policies to shared data


-- BONUS 4: Build automated compliance reporting
-- Create task that generates daily compliance reports
-- Include access logs, policy violations, etc.


-- BONUS 5: Implement change data capture for audit
-- Track all changes to patient records
-- Store audit trail in separate table


/*******************************************************************************
 * Testing & Validation
 *******************************************************************************/

-- Test 1: Verify role hierarchy
USE ROLE SECURITYADMIN;
SHOW GRANTS TO ROLE healthcare_admin;
SHOW GRANTS TO ROLE data_analyst;
SHOW GRANTS TO ROLE hospital_1_analyst;

-- Test 2: Verify masking policies
USE ROLE data_analyst;
SELECT * FROM patients LIMIT 5;  -- Should see masked SSN

USE ROLE hospital_1_analyst;
SELECT * FROM patients LIMIT 5;  -- Should see only Hospital 1 patients with masked PII

-- Test 3: Verify row access policies
USE ROLE hospital_1_analyst;
SELECT COUNT(*) FROM patients;  -- Should only count Hospital 1 patients

USE ROLE hospital_2_analyst;
SELECT COUNT(*) FROM patients;  -- Should only count Hospital 2 patients

-- Test 4: Verify Time Travel
SELECT COUNT(*) FROM patients AT(OFFSET => -3600);  -- 1 hour ago

-- Test 5: Verify backups exist
SHOW DATABASES LIKE '%backup%';

-- Test 6: Verify audit logging
SELECT 
  user_name,
  role_name,
  query_text,
  start_time,
  rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%patients%'
  AND start_time > DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 10;

/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up all objects
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS healthcare_analytics CASCADE;
DROP DATABASE IF EXISTS healthcare_analytics_backup_20240115 CASCADE;

USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS healthcare_admin;
DROP ROLE IF EXISTS data_engineer;
DROP ROLE IF EXISTS data_analyst;
DROP ROLE IF EXISTS hospital_1_analyst;
DROP ROLE IF EXISTS hospital_2_analyst;
DROP ROLE IF EXISTS research_partner;
*/

/*******************************************************************************
 * Key Takeaways
 * 
 * 1. RBAC Hierarchy
 *    - Design role hierarchy based on organizational structure
 *    - Use role inheritance for privilege management
 *    - Apply least privilege principle
 * 
 * 2. Data Protection
 *    - Use masking policies for PII protection
 *    - Apply row access policies for multi-tenant isolation
 *    - Create secure views for external sharing
 *    - Test policies with different roles
 * 
 * 3. Data Recovery
 *    - Configure appropriate Time Travel retention
 *    - Use cloning for backups and dev environments
 *    - Test recovery procedures regularly
 *    - Monitor storage costs
 * 
 * 4. Monitoring & Auditing
 *    - Track data access with ACCOUNT_USAGE views
 *    - Monitor policy effectiveness
 *    - Create compliance reports
 *    - Set up alerts for suspicious activity
 * 
 * 5. Compliance
 *    - Implement controls for regulatory requirements
 *    - Document security architecture
 *    - Regular audits and reviews
 *    - Maintain audit trails
 * 
 *******************************************************************************/
