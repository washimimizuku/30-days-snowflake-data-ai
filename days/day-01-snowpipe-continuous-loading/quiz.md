# Day 1 Quiz: Snowpipe & Continuous Data Loading

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is the main difference between Snowpipe and COPY command?

A) Snowpipe requires a warehouse, COPY does not  
B) Snowpipe is continuous and serverless, COPY is manual and requires a warehouse  
C) Snowpipe is slower than COPY command  
D) Snowpipe can only load JSON files, COPY can load any format  

**Your answer:**

---

### 2. Does Snowpipe require a virtual warehouse?

A) Yes, you must specify a warehouse in the CREATE PIPE statement  
B) Yes, but only for the initial setup  
C) No, Snowpipe uses serverless compute managed by Snowflake  
D) Only for files larger than 1 GB  

**Your answer:**

---

### 3. What AWS service is used for auto-ingest notifications?

A) Lambda and API Gateway  
B) SQS and SNS  
C) Kinesis and DynamoDB  
D) CloudWatch and EventBridge  

**Your answer:**

---

### 4. Can Snowpipe load the same file twice?

A) Yes, every time the file is modified  
B) Yes, if you manually refresh the pipe  
C) No, Snowpipe is idempotent and tracks loaded files  
D) Only if the file is renamed  

**Your answer:**

---

### 5. What is the typical load latency for Snowpipe?

A) Seconds (< 30 seconds)  
B) Minutes (1-2 minutes)  
C) Hours (1-2 hours)  
D) Real-time (< 1 second)  

**Your answer:**

---

### 6. How is Snowpipe billed?

A) Fixed monthly fee per pipe  
B) Per file loaded, regardless of size  
C) Per-second billing based on compute resources used  
D) Per hour like virtual warehouses  

**Your answer:**

---

### 7. What is the optimal file size for Snowpipe?

A) 1-10 MB compressed  
B) 100-250 MB compressed  
C) 500-1000 MB compressed  
D) Over 1 GB compressed  

**Your answer:**

---

### 8. Which function checks pipe status?

A) SHOW_PIPE_STATUS('pipe_name')  
B) GET_PIPE_STATUS('pipe_name')  
C) SYSTEM$PIPE_STATUS('pipe_name')  
D) CHECK_PIPE('pipe_name')  

**Your answer:**

---

### 9. Can you pause a Snowpipe?

A) No, pipes cannot be paused once created  
B) Yes, using ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE  
C) Yes, but only by dropping and recreating the pipe  
D) Only if no files are currently being processed  

**Your answer:**

---

### 10. What happens if a file has errors during Snowpipe loading?

A) Snowpipe stops and waits for manual intervention  
B) The entire batch is rolled back  
C) Snowpipe skips the file and continues processing others  
D) The file is automatically retried every 5 minutes  

**Your answer:**

---

## Answer Key

1. **B** - Snowpipe is continuous and serverless, COPY is manual and requires a warehouse
2. **C** - No, Snowpipe uses serverless compute managed by Snowflake
3. **B** - SQS and SNS (S3 → SNS → SQS → Snowpipe)
4. **C** - No, Snowpipe is idempotent and tracks loaded files
5. **B** - Minutes (1-2 minutes typical)
6. **C** - Per-second billing based on compute resources used
7. **B** - 100-250 MB compressed
8. **C** - SYSTEM$PIPE_STATUS('pipe_name')
9. **B** - Yes, using ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE
10. **C** - Snowpipe skips the file and continues processing others

---

## Score Yourself

- 9-10/10: Excellent! You understand Snowpipe thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Serverless**: No warehouse needed  
✅ **Auto-ingest**: Uses cloud storage events (SQS/SNS)  
✅ **Idempotent**: Prevents duplicate loads  
✅ **Low latency**: 1-2 minutes typical  
✅ **Cost model**: Pay per file loaded  
✅ **Optimal size**: 100-250 MB compressed  
✅ **Monitoring**: COPY_HISTORY and PIPE_USAGE_HISTORY  

## Exam Tips

**Common exam question patterns:**
- When to use Snowpipe vs. COPY command
- Components required for auto-ingest (SQS, SNS, IAM roles)
- How Snowpipe prevents duplicate loads
- Billing model (serverless compute)
- Monitoring and troubleshooting queries
- File size best practices

**Remember for the exam:**
- Maximum file size: 5 GB (but not optimal)
- Snowpipe uses Snowflake-managed compute
- Event notifications are required for auto-ingest
- Files are tracked by name to prevent duplicates
- Can pause/resume pipes with ALTER PIPE

## Next Steps

- If you scored 8-10: Move to Day 2 (Streams)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. What if files arrive faster than Snowpipe can load them?
2. How would you handle files with different schemas?
3. What's the best way to monitor Snowpipe in production?
4. How do you troubleshoot a pipe that stopped loading?
5. When would you choose COPY over Snowpipe?
