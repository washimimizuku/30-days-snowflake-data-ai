/*******************************************************************************
 * Day 25: Hands-On Project - E-Commerce Analytics Platform
 * 
 * Time: 2 hours (120 minutes)
 * 
 * Project Phases:
 * 1. Setup & Infrastructure (10 min)
 * 2. Data Ingestion (15 min)
 * 3. Change Tracking (10 min)
 * 4. Data Processing (20 min)
 * 5. Security Implementation (15 min)
 * 6. Analytics Layer (10 min)
 * 7. Monitoring & Governance (10 min)
 * 8. Testing & Validation (10 min)
 * 9. Documentation (20 min)
 * 
 * Instructions:
 * - Follow each phase in order
 * - Complete all TODO sections
 * - Test each component before moving to the next
 * - Document your decisions and observations
 * 
 *******************************************************************************/

/*******************************************************************************
 * PHASE 1: Setup & Infrastructure (10 min)
 *******************************************************************************/

-- TODO 1.1: Create database structure
USE ROLE SYSADMIN;

-- Create databases


-- Create schemas


-- TODO 1.2: Create warehouses


-- TODO 1.3: Create role hierarchy
USE ROLE SECURITYADMIN;


-- Grant roles to SYSADMIN for management


/*******************************************************************************
 * PHASE 2: Data Ingestion (15 min)
 *******************************************************************************/

USE ROLE SYSADMIN;
USE DATABASE ecommerce_raw;
USE SCHEMA landing;
USE WAREHOUSE ingestion_wh;

-- TODO 2.1: Create external stage and file formats
-- Note: In production, you would use actual S3 bucket
-- For this lab, we'll create internal stage


-- TODO 2.2: Create landing tables


-- TODO 2.3: Create sample data
-- Insert sample orders


-- Insert sample customers


-- Insert sample products


-- TODO 2.4: Create Snowpipe (simulated)
-- In production: CREATE PIPE with AUTO_INGEST
-- For lab: We'll use manual COPY INTO


/*******************************************************************************
 * PHASE 3: Change Tracking (10 min)
 *******************************************************************************/

-- TODO 3.1: Create streams on landing tables


-- TODO 3.2: Verify streams are created


/*******************************************************************************
 * PHASE 4: Data Processing (20 min)
 *******************************************************************************/

USE DATABASE ecommerce_curated;
USE SCHEMA core;
USE WAREHOUSE processing_wh;

-- TODO 4.1: Create curated tables with clustering


-- TODO 4.2: Create stored procedure for ETL


-- TODO 4.3: Create UDFs for business logic
-- UDF to calculate customer tier based on total spent


-- UDF to calculate discount based on tier


-- TODO 4.4: Create automated task


/*******************************************************************************
 * PHASE 5: Security Implementation (15 min)
 *******************************************************************************/

-- TODO 5.1: Grant privileges to roles


-- TODO 5.2: Create masking policies


-- TODO 5.3: Create row access policies


-- TODO 5.4: Configure Time Travel retention


/*******************************************************************************
 * PHASE 6: Analytics Layer (10 min)
 *******************************************************************************/

USE DATABASE ecommerce_analytics;
USE SCHEMA reporting;
USE WAREHOUSE analytics_wh;

-- TODO 6.1: Create materialized views


-- TODO 6.2: Create secure views for analysts


-- TODO 6.3: Create dynamic table (optional)


/*******************************************************************************
 * PHASE 7: Monitoring & Governance (10 min)
 *******************************************************************************/

USE DATABASE ecommerce_governance;
USE SCHEMA audit;

-- TODO 7.1: Create audit tables


-- TODO 7.2: Create monitoring views


-- TODO 7.3: Create data quality checks


/*******************************************************************************
 * PHASE 8: Testing & Validation (10 min)
 *******************************************************************************/

-- TODO 8.1: Test data ingestion


-- TODO 8.2: Test stream processing


-- TODO 8.3: Test task execution


-- TODO 8.4: Test security policies


-- TODO 8.5: Test performance


-- TODO 8.6: Test UDFs


/*******************************************************************************
 * PHASE 9: Documentation (20 min)
 *******************************************************************************/

-- TODO 9.1: Document architecture
/*
Architecture Overview:
- Databases: [List databases and their purposes]
- Warehouses: [List warehouses and their sizing]
- Security: [Describe security implementation]
- Performance: [Document optimization strategies]
*/

-- TODO 9.2: Document data flow
/*
Data Flow:
1. [Describe ingestion process]
2. [Describe transformation process]
3. [Describe analytics process]
*/

-- TODO 9.3: Create runbook
/*
Common Operations:
- How to refresh data: [Steps]
- How to add new user: [Steps]
- How to troubleshoot failed tasks: [Steps]
- How to recover from data loss: [Steps]
*/

-- TODO 9.4: Document monitoring queries
/*
Key Monitoring Queries:
- Pipeline health: [Query]
- Performance metrics: [Query]
- Cost tracking: [Query]
- Data quality: [Query]
*/

/*******************************************************************************
 * Bonus Challenges (Optional)
 *******************************************************************************/

-- BONUS 1: Implement incremental loading strategy


-- BONUS 2: Create alerting mechanism for failures


-- BONUS 3: Implement data retention policy


-- BONUS 4: Create backup and recovery procedures


-- BONUS 5: Optimize warehouse usage and costs


/*******************************************************************************
 * Project Completion Checklist
 *******************************************************************************/

/*
[ ] All databases and schemas created
[ ] All warehouses configured
[ ] Role hierarchy implemented
[ ] Landing tables created
[ ] Streams configured
[ ] Processing stored procedure working
[ ] Tasks scheduled and running
[ ] Curated tables populated
[ ] Clustering implemented
[ ] Masking policies applied
[ ] Row access policies applied
[ ] Materialized views created
[ ] Audit logging in place
[ ] Monitoring views created
[ ] All tests passing
[ ] Documentation complete
[ ] Performance benchmarks recorded
[ ] Security validated
[ ] Ready for production
*/

/*******************************************************************************
 * Cleanup (Optional)
 *******************************************************************************/

-- Uncomment to clean up all project resources
/*
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS ecommerce_raw CASCADE;
DROP DATABASE IF EXISTS ecommerce_curated CASCADE;
DROP DATABASE IF EXISTS ecommerce_analytics CASCADE;
DROP DATABASE IF EXISTS ecommerce_governance CASCADE;

DROP WAREHOUSE IF EXISTS ingestion_wh;
DROP WAREHOUSE IF EXISTS processing_wh;
DROP WAREHOUSE IF EXISTS analytics_wh;

USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS ecommerce_admin;
DROP ROLE IF EXISTS data_engineer;
DROP ROLE IF EXISTS data_analyst;
DROP ROLE IF EXISTS regional_manager_north;
DROP ROLE IF EXISTS regional_manager_south;
*/

/*******************************************************************************
 * Reflection Questions
 * 
 * Answer these questions after completing the project:
 * 
 * 1. What was the most challenging part of the project?
 * 
 * 2. How would you improve the architecture for better performance?
 * 
 * 3. What additional security measures would you implement?
 * 
 * 4. How would you monitor this system in production?
 * 
 * 5. What did you learn from building this end-to-end solution?
 * 
 *******************************************************************************/
