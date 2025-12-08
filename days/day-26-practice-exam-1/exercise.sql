/*******************************************************************************
 * Day 26: Practice Exam 1 - Exercise
 * 
 * This day focuses on taking the practice exam in quiz.md
 * 
 * Time: 115 minutes for exam + 30 minutes for review
 * 
 *******************************************************************************/

/*******************************************************************************
 * INSTRUCTIONS
 *******************************************************************************/

-- Today's focus is on taking the full practice exam in quiz.md
-- 
-- Steps:
-- 1. Open quiz.md
-- 2. Set a timer for 115 minutes
-- 3. Answer all 65 questions without references
-- 4. Score your exam using the answer key
-- 5. Review all incorrect answers
-- 6. Complete the post-exam analysis in README.md
--
-- This file contains optional review queries you can run AFTER the exam
-- to reinforce concepts from questions you missed.

/*******************************************************************************
 * POST-EXAM REVIEW QUERIES
 * 
 * Run these AFTER completing the exam to reinforce concepts
 *******************************************************************************/

-- Use your practice database
USE DATABASE practice_db;
USE SCHEMA public;
USE WAREHOUSE compute_wh;

/*******************************************************************************
 * REVIEW TOPIC 1: Streams and Change Data Capture
 *******************************************************************************/

-- TODO: Create a table and stream to practice CDC
-- CREATE TABLE orders (...);
-- CREATE STREAM orders_stream ON TABLE orders;
-- INSERT some data and query the stream

/*******************************************************************************
 * REVIEW TOPIC 2: Tasks and Orchestration
 *******************************************************************************/

-- TODO: Create a simple task to practice scheduling
-- CREATE TASK my_task
--   WAREHOUSE = compute_wh
--   SCHEDULE = '5 MINUTE'
-- AS
--   INSERT INTO log_table VALUES (CURRENT_TIMESTAMP());

/*******************************************************************************
 * REVIEW TOPIC 3: Clustering and Performance
 *******************************************************************************/

-- TODO: Check clustering information on a table
-- SELECT SYSTEM$CLUSTERING_INFORMATION('table_name');

/*******************************************************************************
 * REVIEW TOPIC 4: Security Policies
 *******************************************************************************/

-- TODO: Create a masking policy
-- CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() = 'ADMIN' THEN val
--     ELSE '***@' || SPLIT_PART(val, '@', 2)
--   END;

/*******************************************************************************
 * REVIEW TOPIC 5: Monitoring and Troubleshooting
 *******************************************************************************/

-- TODO: Query your recent query history
-- SELECT 
--   query_id,
--   query_text,
--   total_elapsed_time / 1000 as seconds,
--   rows_produced
-- FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
-- WHERE start_time > DATEADD(hour, -1, CURRENT_TIMESTAMP())
-- ORDER BY start_time DESC
-- LIMIT 10;

/*******************************************************************************
 * NOTES
 *******************************************************************************/

-- Use this space to write notes about concepts you need to review:
--
-- Topics to review:
-- 1. _______________________________
-- 2. _______________________________
-- 3. _______________________________
-- 4. _______________________________
-- 5. _______________________________
--
-- Questions I got wrong:
-- Q#: ___ - Topic: _______________
-- Q#: ___ - Topic: _______________
-- Q#: ___ - Topic: _______________
--
-- Study plan for tomorrow:
-- Morning: Review _________________
-- Afternoon: Practice ______________

