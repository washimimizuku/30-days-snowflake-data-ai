# Quick Start Guide - 30 Days of Snowflake for Data & AI

Get started in 10 minutes! ⚡

---

## Prerequisites Check (2 min)

✅ **Required:**
- [ ] SnowPro Core Certification (you should have this)
- [ ] Intermediate SQL knowledge
- [ ] AWS/Azure/GCP account access
- [ ] Basic understanding of data engineering concepts

✅ **Recommended:**
- [ ] Basic Python knowledge (for Snowpark days)
- [ ] Familiarity with cloud storage (S3/Azure Blob/GCS)

**Not ready?** See [PREREQUISITES.md](docs/PREREQUISITES.md) for detailed requirements.

---

## Setup Steps (8 min)

### Step 1: Create Snowflake Trial Account (3 min)

1. Go to [signup.snowflake.com](https://signup.snowflake.com)
2. Choose your cloud provider (AWS recommended)
3. Select region closest to you
4. Complete registration
5. Verify email and log in

**You get:**
- 30 days free trial
- $400 in credits
- Full enterprise features

### Step 2: Set Up Cloud Storage (3 min)

**For AWS (Recommended):**
```bash
# Create S3 bucket
aws s3 mb s3://snowflake-bootcamp-[your-name]

# Verify
aws s3 ls
```

**For Azure:**
```bash
# Create storage account and container
az storage account create --name snowflakebootcamp --resource-group mygroup
az storage container create --name data --account-name snowflakebootcamp
```

**For GCP:**
```bash
# Create GCS bucket
gsutil mb gs://snowflake-bootcamp-[your-name]
```

### Step 3: Verify Snowflake Setup (2 min)

Run this in Snowflake:

```sql
-- Create test database
CREATE DATABASE IF NOT EXISTS BOOTCAMP_TEST;

-- Create test table
CREATE TABLE BOOTCAMP_TEST.PUBLIC.test (id INT, name VARCHAR);

-- Insert test data
INSERT INTO BOOTCAMP_TEST.PUBLIC.test VALUES (1, 'Hello Snowflake!');

-- Query test data
SELECT * FROM BOOTCAMP_TEST.PUBLIC.test;

-- Clean up
DROP DATABASE BOOTCAMP_TEST;
```

If this works, you're ready! ✅

---

## Start Learning (Now!)

### Option 1: Structured 30-Day Path
```bash
# Start with Day 1
cd days/day-01-snowpipe-continuous-loading
open README.md
```

**Daily routine:**
1. Read `README.md` (15 min theory)
2. Complete `exercise.sql` (40 min hands-on)
3. Take `quiz.md` (5 min)
4. Check `solution.sql` if stuck

### Option 2: Jump to Specific Topics

**Week 1: Data Movement**
- Day 1: Snowpipe
- Day 2: Streams
- Day 3: Tasks
- Day 4: Streams + Tasks
- Day 5: Dynamic Tables

**Week 2: Performance**
- Day 8: Clustering
- Day 11: Query Tuning
- Day 12: Warehouse Sizing

**Week 3: Security**
- Day 16: Access Control
- Day 18: Time Travel
- Day 20: Monitoring

**Week 4: Exam Prep**
- Day 26-27: Practice Exams
- Day 30: Certification Exam

### Option 3: Exam-Focused Sprint (2 weeks)

Focus on high-weight topics:
1. Days 1-6 (Data Movement - 30%)
2. Days 8-13 (Performance - 25%)
3. Days 15-20 (Security & Monitoring - 35%)
4. Days 26-28 (Practice Exams)

---

## Quick Reference

### Essential Commands

```sql
-- Check your Snowflake edition
SELECT CURRENT_VERSION();

-- View your account info
SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

-- List databases
SHOW DATABASES;

-- Check credit usage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

### Useful Links

- **Snowflake Docs**: https://docs.snowflake.com
- **Exam Guide**: [docs/EXAM_GUIDE.md](docs/EXAM_GUIDE.md)
- **Troubleshooting**: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Full Curriculum**: [docs/CURRICULUM.md](docs/CURRICULUM.md)

---

## Daily Time Commitment

**Total: 2 hours/day**
- 15 min: Read theory (README.md)
- 40 min: Hands-on exercises (exercise.sql)
- 5 min: Quiz (quiz.md)
- 60 min: Deep practice and exploration

**Flexible schedule:**
- Morning: 1 hour theory + exercises
- Evening: 1 hour practice
- Weekend: Catch up or get ahead

---

## Getting Help

### Stuck on an Exercise?
1. Check `solution.sql` in the day folder
2. Review `README.md` theory section
3. Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
4. Search Snowflake documentation

### Common Issues

**"Access Denied" errors:**
- Check IAM roles and permissions
- Verify storage integration setup
- See [docs/AWS_SETUP.md](docs/AWS_SETUP.md)

**"Insufficient privileges":**
- Ensure you have ACCOUNTADMIN role
- Grant necessary privileges
- See [docs/SETUP.md](docs/SETUP.md)

**Snowpipe not loading:**
- Verify SNS/SQS configuration
- Check pipe status: `SELECT SYSTEM$PIPE_STATUS('pipe_name')`
- See Day 1 troubleshooting section

---

## Tips for Success

### Do's ✅
- Complete exercises hands-on (don't just read)
- Take notes in your own words
- Build real pipelines, not toy examples
- Review quiz answers even if you got them right
- Join Snowflake community forums

### Don'ts ❌
- Don't skip hands-on exercises
- Don't just copy/paste solutions
- Don't rush through days
- Don't ignore error messages
- Don't forget to suspend warehouses (costs!)

---

## Cost Management

**Keep costs low:**
```sql
-- Auto-suspend warehouses after 1 minute
ALTER WAREHOUSE my_warehouse SET AUTO_SUSPEND = 60;

-- Use XS warehouses for learning
CREATE WAREHOUSE learning_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Monitor credit usage
SELECT 
  DATE_TRUNC('day', START_TIME) as day,
  WAREHOUSE_NAME,
  SUM(CREDITS_USED) as credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC;
```

**Expected costs:**
- Trial credits: $400 (should be enough for entire bootcamp)
- Typical daily usage: $2-5 in credits
- Total bootcamp: $60-150 (well within trial credits)

---

## Progress Tracking

Create a simple checklist:

```markdown
## Week 1: Data Movement
- [ ] Day 1: Snowpipe ✅
- [ ] Day 2: Streams
- [ ] Day 3: Tasks
- [ ] Day 4: Streams + Tasks
- [ ] Day 5: Dynamic Tables
- [ ] Day 6: Advanced SQL
- [ ] Day 7: Review & Project

## Week 2: Performance
- [ ] Day 8: Clustering
...
```

---

## Next Steps

1. ✅ Complete this quickstart
2. 📖 Read [README.md](README.md) for full overview
3. 🚀 Start [Day 1](days/day-01-snowpipe-continuous-loading/README.md)
4. 📅 Set calendar reminders for daily 2-hour blocks
5. 🎯 Schedule exam for Day 31 (after bootcamp completion)

---

## Ready to Start?

```bash
# Navigate to Day 1
cd days/day-01-snowpipe-continuous-loading

# Open the lesson
open README.md

# Start coding!
```

**Good luck on your SnowPro Advanced: Data Engineer journey!** 🚀

---

**Questions?** Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) or open an issue.

**Want to contribute?** See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) (coming soon).
