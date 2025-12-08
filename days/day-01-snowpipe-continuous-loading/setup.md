# Day 1: Setup Guide for Snowpipe

This guide walks you through setting up the AWS and Snowflake components needed for Day 1 exercises.

## Prerequisites

- Snowflake account (trial or paid)
- AWS account with S3 access
- AWS CLI installed (optional but recommended)
- Basic understanding of IAM roles and policies

---

## Part 1: AWS Setup (15 minutes)

### Step 1: Create S3 Bucket

1. Go to AWS S3 Console
2. Click "Create bucket"
3. Bucket name: `snowflake-bootcamp-day01-[your-name]`
4. Region: Same as your Snowflake account (e.g., us-east-1)
5. Keep default settings
6. Click "Create bucket"

### Step 2: Create Sample Data Files

Create these JSON files locally:

**customer_events_001.json**
```json
[
  {"event_id": "evt_001", "customer_id": "cust_123", "event_type": "page_view", "event_timestamp": "2025-12-08T10:00:00", "event_data": {"page": "/home", "duration": 45}},
  {"event_id": "evt_002", "customer_id": "cust_124", "event_type": "add_to_cart", "event_timestamp": "2025-12-08T10:01:00", "event_data": {"product_id": "prod_456", "quantity": 2}},
  {"event_id": "evt_003", "customer_id": "cust_125", "event_type": "purchase", "event_timestamp": "2025-12-08T10:02:00", "event_data": {"order_id": "ord_789", "amount": 99.99}}
]
```

**customer_events_002.json**
```json
[
  {"event_id": "evt_004", "customer_id": "cust_123", "event_type": "page_view", "event_timestamp": "2025-12-08T10:05:00", "event_data": {"page": "/products", "duration": 120}},
  {"event_id": "evt_005", "customer_id": "cust_126", "event_type": "search", "event_timestamp": "2025-12-08T10:06:00", "event_data": {"query": "laptop", "results": 45}},
  {"event_id": "evt_006", "customer_id": "cust_124", "event_type": "purchase", "event_timestamp": "2025-12-08T10:07:00", "event_data": {"order_id": "ord_790", "amount": 149.99}}
]
```

**customer_events_003.json**
```json
[
  {"event_id": "evt_007", "customer_id": "cust_127", "event_type": "page_view", "event_timestamp": "2025-12-08T10:10:00", "event_data": {"page": "/checkout", "duration": 30}},
  {"event_id": "evt_008", "customer_id": "cust_128", "event_type": "purchase", "event_timestamp": "2025-12-08T10:11:00", "event_data": {"order_id": "ord_791", "amount": 299.99}},
  {"event_id": "evt_009", "customer_id": "cust_129", "event_type": "add_to_cart", "event_timestamp": "2025-12-08T10:12:00", "event_data": {"product_id": "prod_789", "quantity": 1}}
]
```

### Step 3: Upload Files to S3

**Using AWS Console:**
1. Open your S3 bucket
2. Click "Upload"
3. Add the 3 JSON files
4. Click "Upload"

**Using AWS CLI:**
```bash
aws s3 cp customer_events_001.json s3://snowflake-bootcamp-day01-[your-name]/
aws s3 cp customer_events_002.json s3://snowflake-bootcamp-day01-[your-name]/
aws s3 cp customer_events_003.json s3://snowflake-bootcamp-day01-[your-name]/
```

---

## Part 2: Snowflake Storage Integration (10 minutes)

### Step 1: Get Snowflake Account Info

Run this in Snowflake:
```sql
-- This will show you the AWS account and external ID for Snowflake
SELECT SYSTEM$GET_AWS_SNS_IAM_POLICY('arn:aws:sns:us-east-1:123456789012:dummy');
```

Save the output - you'll need:
- `SNOWFLAKE_AWS_ACCOUNT_ID`
- `SNOWFLAKE_EXTERNAL_ID`

### Step 2: Create IAM Role in AWS

1. Go to AWS IAM Console
2. Click "Roles" → "Create role"
3. Select "AWS account" → "Another AWS account"
4. Account ID: Enter `SNOWFLAKE_AWS_ACCOUNT_ID` from above
5. Check "Require external ID"
6. External ID: Enter `SNOWFLAKE_EXTERNAL_ID` from above
7. Click "Next"

### Step 3: Attach Permissions Policy

Create inline policy with this JSON:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::snowflake-bootcamp-day01-[your-name]/*",
        "arn:aws:s3:::snowflake-bootcamp-day01-[your-name]"
      ]
    }
  ]
}
```

### Step 4: Name and Create Role

1. Role name: `snowflake-s3-role`
2. Click "Create role"
3. Copy the Role ARN (you'll need this)

---

## Part 3: SNS and SQS Setup (10 minutes)

### Step 1: Create SNS Topic

1. Go to AWS SNS Console
2. Click "Topics" → "Create topic"
3. Type: Standard
4. Name: `snowflake-bootcamp-topic`
5. Click "Create topic"
6. Copy the Topic ARN

### Step 2: Create SQS Queue

1. Go to AWS SQS Console
2. Click "Create queue"
3. Type: Standard
4. Name: `snowflake-bootcamp-queue`
5. Click "Create queue"

### Step 3: Subscribe Queue to Topic

1. In SQS, select your queue
2. Click "Subscribe to Amazon SNS topic"
3. Select your SNS topic
4. Click "Save"

### Step 4: Configure S3 Event Notifications

1. Go to your S3 bucket
2. Click "Properties" tab
3. Scroll to "Event notifications"
4. Click "Create event notification"
5. Name: `snowflake-snowpipe-notification`
6. Event types: Check "All object create events"
7. Destination: SNS topic
8. Select your SNS topic
9. Click "Save changes"

---

## Part 4: Snowflake Configuration (5 minutes)

### Step 1: Create Storage Integration

Run in Snowflake (replace with your values):

```sql
CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_AWS_ACCOUNT:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-bootcamp-day01-[your-name]/');
```

### Step 2: Verify Integration

```sql
DESC STORAGE INTEGRATION s3_integration;
```

Look for `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` in the output.

### Step 3: Update IAM Trust Policy

Go back to AWS IAM and update the trust policy with the actual values from Snowflake:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::SNOWFLAKE_ACCOUNT:user/SNOWFLAKE_USER"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "SNOWFLAKE_EXTERNAL_ID"
        }
      }
    }
  ]
}
```

---

## Part 5: Verification (5 minutes)

### Test Storage Integration

```sql
-- Create stage
CREATE OR REPLACE STAGE s3_stage
  STORAGE_INTEGRATION = s3_integration
  URL = 's3://snowflake-bootcamp-day01-[your-name]/'
  FILE_FORMAT = (TYPE = 'JSON' STRIP_OUTER_ARRAY = TRUE);

-- List files (should see your 3 JSON files)
LIST @s3_stage;
```

If you see your files, setup is complete! ✅

---

## Troubleshooting

### Issue: "Access Denied" when listing stage

**Solution:**
- Verify IAM role ARN is correct in storage integration
- Check IAM trust policy has correct Snowflake user ARN
- Verify S3 bucket permissions policy
- Ensure external ID matches

### Issue: No files showing in LIST @s3_stage

**Solution:**
- Verify S3 bucket name is correct
- Check files were uploaded successfully
- Ensure storage integration URL matches bucket name
- Try refreshing: `ALTER STAGE s3_stage REFRESH;`

### Issue: SNS notifications not working

**Solution:**
- Verify SQS queue is subscribed to SNS topic
- Check S3 event notification is configured
- Ensure SNS topic ARN is correct in Snowpipe
- Check SNS topic policy allows S3 to publish

### Issue: Snowpipe not loading files

**Solution:**
- Check pipe status: `SELECT SYSTEM$PIPE_STATUS('pipe_name');`
- Verify pipe is not paused: `SHOW PIPES;`
- Check for errors: `SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(...))`
- Manually refresh: `ALTER PIPE pipe_name REFRESH;`

---

## Cost Considerations

**AWS Costs:**
- S3 storage: ~$0.023/GB/month (minimal for test files)
- S3 requests: ~$0.0004 per 1000 requests
- SNS: First 1M requests free, then $0.50 per million
- SQS: First 1M requests free, then $0.40 per million

**Snowflake Costs:**
- Storage: ~$40/TB/month (minimal for test data)
- Snowpipe compute: ~$0.06 per compute-second
- Expected cost for Day 1: < $0.10

**Tip:** Remember to clean up resources after completing the bootcamp to avoid ongoing charges.

---

## Next Steps

Once setup is complete:
1. Open `exercise.sql` and start with Exercise 1
2. Follow along with `README.md` for theory
3. Complete all exercises
4. Take the quiz in `quiz.md`
5. Check your work against `solution.sql`

---

## Additional Resources

- [Snowflake Storage Integration Docs](https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration)
- [AWS IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
- [Snowpipe Auto-Ingest](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3)

Good luck! 🚀
