/*******************************************************************************
 * Day 28: Week 4 Review & Final Preparation - Exercise
 * 
 * Focus: Comprehensive review and final cheat sheet creation
 * 
 * Time: 2 hours
 * 
 *******************************************************************************/

-- Today's focus is on reviewing all concepts and taking the 50-question quiz
-- This file provides a template for creating your final cheat sheet

/*******************************************************************************
 * FINAL CHEAT SHEET TEMPLATE
 *******************************************************************************/

-- TODO: Fill in this cheat sheet with key facts you need to remember

/*******************************************************************************
 * SECTION 1: Critical Numbers
 *******************************************************************************/

-- Time Travel
-- - Enterprise Edition: _____ days max
-- - Standard Edition: _____ day max
--
-- Fail-safe
-- - Period: _____ days
-- - Accessible by: _____
--
-- Clustering
-- - Maximum keys: _____
-- - Good clustering depth: < _____
--
-- Tasks
-- - Minimum schedule: _____ minute
-- - Maximum overlapping: _____
--
-- Caching
-- - Result cache TTL: _____ hours
-- - Requires: _____ query match
--
-- History Retention
-- - Snowpipe: _____ days
-- - Query (INFORMATION_SCHEMA): _____ days
-- - Query (ACCOUNT_USAGE): _____ days
--
-- Multi-cluster
-- - Maximum clusters: _____
--
-- Monitoring
-- - ACCOUNT_USAGE latency: _____ to _____ hours
-- - INFORMATION_SCHEMA latency: _____

/*******************************************************************************
 * SECTION 2: Key Differences
 *******************************************************************************/

-- Streams vs. Dynamic Tables
-- - Streams: _____
-- - Dynamic Tables: _____
--
-- Masking vs. Row Access Policies
-- - Masking: _____
-- - Row Access: _____
--
-- EXECUTE AS CALLER vs. OWNER
-- - CALLER: _____
-- - OWNER: _____
--
-- Standard vs. Economy Scaling
-- - Standard: _____
-- - Economy: _____
--
-- ACCOUNT_USAGE vs. INFORMATION_SCHEMA
-- - ACCOUNT_USAGE: _____
-- - INFORMATION_SCHEMA: _____
--
-- Stored Procedures vs. UDFs
-- - Stored Procedures: _____
-- - UDFs: _____
--
-- Time Travel vs. Fail-safe
-- - Time Travel: _____
-- - Fail-safe: _____

/*******************************************************************************
 * SECTION 3: Common Patterns
 *******************************************************************************/

-- Stream + Task Pattern
-- 1. CREATE STREAM on source table
-- 2. CREATE TASK with WHEN SYSTEM$STREAM_HAS_DATA()
-- 3. Task processes stream data with MERGE
-- 4. Stream offset advances after consumption

-- Clustering Strategy
-- 1. Identify frequently filtered columns
-- 2. Choose high-cardinality columns
-- 3. Maximum 4 columns
-- 4. Monitor clustering_depth
-- 5. Recluster if depth > 10

-- Security Policy Application
-- 1. CREATE MASKING POLICY for columns
-- 2. ALTER TABLE MODIFY COLUMN SET MASKING POLICY
-- 3. CREATE ROW ACCESS POLICY for rows
-- 4. ALTER TABLE ADD ROW ACCESS POLICY

/*******************************************************************************
 * SECTION 4: Troubleshooting Guide
 *******************************************************************************/

-- Task Failures
-- → Check: INFORMATION_SCHEMA.TASK_HISTORY()
-- → Look for: error_code, error_message
-- → Verify: Stream has data, privileges, warehouse

-- Slow Queries
-- → Check: Query Profile
-- → Look for: Spilling, partition pruning, join order
-- → Fix: Increase warehouse, add clustering, optimize query

-- Snowpipe Issues
-- → Check: SYSTEM$PIPE_STATUS('pipe_name')
-- → Verify: S3 notifications, file format, stage permissions
-- → Review: TABLE(VALIDATE_PIPE_LOAD())

-- High Costs
-- → Check: WAREHOUSE_METERING_HISTORY
-- → Identify: Which warehouse consuming most credits
-- → Fix: Right-size warehouses, adjust auto-suspend, optimize queries

/*******************************************************************************
 * SECTION 5: Exam Strategy
 *******************************************************************************/

-- Time Management
-- - 115 minutes for 65 questions
-- - ~1.75 minutes per question
-- - Flag difficult questions
-- - Save 10-15 minutes for review

-- Question Approach
-- 1. Read carefully (watch for "NOT")
-- 2. Eliminate wrong answers
-- 3. Choose between remaining options
-- 4. Don't overthink
-- 5. Trust first instinct

-- Common Traps
-- - Absolute words: "always", "never"
-- - "All of the above" - verify each
-- - Similar options - find differences
-- - Scenario questions - identify key requirement

/*******************************************************************************
 * MY WEAK AREAS TO REVIEW
 *******************************************************************************/

-- Based on practice exams, list your weak areas:
-- 1. _____________________________
-- 2. _____________________________
-- 3. _____________________________

/*******************************************************************************
 * CONFIDENCE CHECK
 *******************************************************************************/

-- Rate your confidence (1-5) on each domain:
-- Data Movement: _____/5
-- Performance Optimization: _____/5
-- Security & Governance: _____/5
-- Monitoring & Troubleshooting: _____/5
-- Advanced Features: _____/5
--
-- Overall Readiness: _____/5

/*******************************************************************************
 * FINAL PREPARATION CHECKLIST
 *******************************************************************************/

-- [ ] Completed 50-question review quiz
-- [ ] Created final cheat sheet
-- [ ] Reviewed all weak areas
-- [ ] Practice Exam 1 score: _____ %
-- [ ] Practice Exam 2 score: _____ %
-- [ ] Feel confident and prepared
-- [ ] Ready for exam day

