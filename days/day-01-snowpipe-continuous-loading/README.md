# Day 1: Snowpipe & Continuous Data Loading

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowpipe architecture and when to use it
- Configure auto-ingest from cloud storage (S3/Azure/GCS)
- Create and monitor Snowpipe for continuous data loading
- Handle errors and troubleshoot Snowpipe issues
- Know the difference between Snowpipe and COPY command

---

## Theory

### What is Snowpipe?

Snowpipe is Snowflake's continuous data ingestion service that automatically loads data within minutes after files arrive in cloud storage.

**Key Characteristics:**
- **Serverless**: No warehouse required (uses Snowflake-managed compute)
- **Continuous**: Loads data automatically as files arrive
- **Cost-effective**: Pay per file loaded (not per hour)
- **Low latency**: Typically loads within 1-2 minutes

### When to Use Snowpipe

✅ **Use Snowpipe for:**
- Real-time analytics dashboards
- IoT sensor data ingestion
- Log file processing
- Event streaming from applications
- Continuous CDC (Change Data Capture)

❌ **Don't use Snowpipe for:**
- Large batch loads (use COPY instead)
- One-time data loads
- When you need immediate consistency
- When serverless compute cost is prohibitive

### Snowpipe Architecture

#### Auto-Ingest (Recommended)
```
Cloud Storage → Event Notification → Snowpipe → Snowflake Table
     ↓                ↓
  (S3/Azure/GCS)  (SQS/Event Grid)
```

**How it works:**
1. File lands in S3 bucket (or Azure/GCS)
2. Cloud storage sends event notification
3. Snowpipe receives notification
4. Snowpipe loads file into table
5. File is tracked to prevent duplicates

#### REST API (Manual Trigger)
```
Your Application → REST API Call → Snowpipe → Snowflake Table
```

### Snowpipe Components

**1. Pipe Object**
```sql
CREATE PIPE my_pipe
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC = 'arn:aws:sns:region:account:topic'
AS
  COPY INTO my_table
  FROM @my_stage
  FILE_FORMAT = (TYPE = 'JSON');
```

**2. Stage** - Points to cloud storage location
**3. Target Table** - Destination for loaded data
**4. Event Notification** - SQS (AWS), Event Grid (Azure), Pub/Sub (GCP)

### Monitoring Snowpipe

```sql
-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('my_pipe');

-- View load history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'MY_TABLE',
  START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
));

-- Check for errors
SELECT *
FROM TABLE(VALIDATE_PIPE_LOAD(
  PIPE_NAME => 'my_pipe',
  START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
));
```

### Best Practices

**File Size:**
- Optimal: 100-250 MB compressed
- Too small (< 10 MB): High overhead
- Too large (> 500 MB): Longer load times

**File Naming:**
- Use timestamps: `data_20251208_143000.json`
- Include sequence numbers: `data_001.json`
- Avoid special characters
- Use consistent patterns

**Cost Optimization:**
- Batch small files before loading
- Use compression (GZIP, BROTLI)
- Monitor credit usage
- Set up alerts for unusual activity

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql` and `setup.md`.

### Exercise 1: Setup Environment
Create database, schema, and target table for customer events.

### Exercise 2: Create Storage Integration
Set up S3 integration with IAM roles and external stage.

### Exercise 3: Manual Load Test
Test data loading with COPY command before setting up Snowpipe.

### Exercise 4: Create Snowpipe
Set up auto-ingest Snowpipe with SNS/SQS notifications.

### Exercise 5: Test Auto-Ingest
Upload files and monitor automatic loading.

### Exercise 6: Error Handling
Test error scenarios and learn to troubleshoot.

### Exercise 7: Monitoring Dashboard
Create queries to monitor Snowpipe performance and costs.

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:

1. What is the main difference between Snowpipe and COPY command?
2. Does Snowpipe require a virtual warehouse?
3. What AWS service is used for auto-ingest notifications?
4. Can Snowpipe load the same file twice?
5. What is the typical load latency for Snowpipe?
6. How is Snowpipe billed?
7. What is the optimal file size for Snowpipe?
8. Which function checks pipe status?
9. Can you pause a Snowpipe?
10. What happens if a file has errors?

---

## 🎯 Key Takeaways

- Snowpipe enables continuous, serverless data ingestion
- Auto-ingest uses cloud storage event notifications (SQS for AWS)
- Files are loaded within 1-2 minutes automatically
- Snowpipe is idempotent (prevents duplicate loads)
- Cost is based on compute resources used (per-second billing)
- Optimal file size is 100-250 MB compressed
- Monitor using COPY_HISTORY and PIPE_USAGE_HISTORY views

---

## 📚 Additional Resources

- [Snowflake Docs: Snowpipe](https://docs.snowflake.com/en/user-guide/data-load-snowpipe)
- [Snowflake Docs: Auto-Ingest](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto)
- [AWS S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
- [Snowpipe Best Practices](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-best-practices)

---

## 🔜 Tomorrow: Day 2 - Streams for Change Data Capture

We'll learn how to track changes in tables using Streams and build CDC pipelines.
