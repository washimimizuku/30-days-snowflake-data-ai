# Day 3: Tasks & Task Orchestration

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake Tasks and their use cases
- Create standalone and dependent tasks
- Schedule tasks using CRON expressions
- Build task trees and DAGs (Directed Acyclic Graphs)
- Use serverless vs. user-managed tasks
- Monitor and troubleshoot task execution
- Implement error handling and notifications
- Understand task observability and best practices

---

## Theory

### What are Tasks?

Tasks are Snowflake objects that enable you to schedule and automate SQL statements, stored procedures, and procedural logic. They're essential for building automated data pipelines.

**Key Characteristics:**
- **Scheduled execution**: Run on a schedule (CRON) or after predecessor tasks
- **Automated**: No manual intervention required
- **Serverless or user-managed**: Choose compute model
- **Orchestration**: Build complex workflows with task trees
- **Conditional execution**: Run based on conditions
- **Error handling**: Built-in retry and notification mechanisms

### When to Use Tasks

✅ **Use Tasks for:**
- Automated ETL/ELT pipelines
- Scheduled data refreshes
- Stream processing automation
- Data quality checks
- Report generation
- Incremental data loads
- Orchestrating complex workflows

❌ **Don't use Tasks for:**
- One-time operations (use manual execution)
- Real-time processing (use Snowpipe)
- Interactive queries
- Ad-hoc analysis

### Task Types

#### 1. Standalone Task
Runs on a schedule independently

```sql
CREATE TASK my_task
  WAREHOUSE = my_wh
  SCHEDULE = 'USING CRON 0 9 * * * UTC'
AS
  INSERT INTO target SELECT * FROM source;
```

#### 2. Child Task (Dependent Task)
Runs after a predecessor task completes

```sql
CREATE TASK child_task
  WAREHOUSE = my_wh
  AFTER parent_task
AS
  UPDATE target SET processed = TRUE;
```

#### 3. Serverless Task
Uses Snowflake-managed compute

```sql
CREATE TASK my_task
  SCHEDULE = '5 MINUTE'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
  CALL my_procedure();
```

### Task Scheduling

#### CRON Expressions

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
* * * * *
```

**Common patterns:**
```sql
-- Every 5 minutes
SCHEDULE = '5 MINUTE'

-- Every hour at minute 0
SCHEDULE = 'USING CRON 0 * * * * UTC'

-- Every day at 9 AM UTC
SCHEDULE = 'USING CRON 0 9 * * * UTC'

-- Every Monday at 8 AM UTC
SCHEDULE = 'USING CRON 0 8 * * 1 UTC'

-- First day of month at midnight
SCHEDULE = 'USING CRON 0 0 1 * * UTC'
```

### Task Trees and DAGs

Build complex workflows with task dependencies:

```
Root Task (scheduled)
    ├── Task A (AFTER root)
    │   ├── Task A1 (AFTER A)
    │   └── Task A2 (AFTER A)
    └── Task B (AFTER root)
        └── Task B1 (AFTER B)
```

**Rules:**
- Only root task has a schedule
- Child tasks use AFTER clause
- Maximum 1000 tasks per account
- Maximum 100 child tasks per parent
- No circular dependencies (must be DAG)

### Serverless vs. User-Managed Tasks

| Feature | Serverless | User-Managed |
|---------|-----------|--------------|
| Compute | Snowflake-managed | User-specified warehouse |
| Cost | Per-second billing | Warehouse credits |
| Setup | Simpler (no warehouse) | More control |
| Scaling | Automatic | Manual warehouse sizing |
| Best for | Most use cases | Large, predictable workloads |

**Serverless task:**
```sql
CREATE TASK my_task
  SCHEDULE = '5 MINUTE'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
  SELECT * FROM my_table;
```

**User-managed task:**
```sql
CREATE TASK my_task
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
AS
  SELECT * FROM my_table;
```

### Conditional Task Execution

Use WHEN clause to run tasks conditionally:

```sql
CREATE TASK process_stream_task
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('my_stream')
AS
  INSERT INTO target SELECT * FROM my_stream;
```

**Common conditions:**
- `SYSTEM$STREAM_HAS_DATA('stream_name')` - Stream has data
- `(SELECT COUNT(*) FROM table) > 0` - Table has rows
- `CURRENT_TIME BETWEEN '08:00' AND '18:00'` - Time window

### Task States

| State | Description |
|-------|-------------|
| STARTED | Task is active and will run on schedule |
| SUSPENDED | Task is paused, won't run |
| EXECUTING | Task is currently running |
| SUCCEEDED | Last execution completed successfully |
| FAILED | Last execution failed |
| SKIPPED | Skipped due to WHEN condition |

### Task Management

```sql
-- Resume task (activate)
ALTER TASK my_task RESUME;

-- Suspend task (pause)
ALTER TASK my_task SUSPEND;

-- Execute task manually
EXECUTE TASK my_task;

-- Modify schedule
ALTER TASK my_task SET SCHEDULE = '10 MINUTE';

-- Modify warehouse
ALTER TASK my_task SET WAREHOUSE = new_wh;

-- Add/modify WHEN condition
ALTER TASK my_task MODIFY WHEN SYSTEM$STREAM_HAS_DATA('my_stream');

-- Remove WHEN condition
ALTER TASK my_task MODIFY WHEN TRUE;
```

### Task Monitoring

```sql
-- Show tasks
SHOW TASKS;

-- Task execution history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  TASK_NAME => 'MY_TASK',
  SCHEDULED_TIME_RANGE_START => DATEADD(hour, -24, CURRENT_TIMESTAMP())
));

-- Task dependencies
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
  TASK_NAME => 'MY_TASK'
));

-- Account usage (detailed metrics)
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.TASK_HISTORY
WHERE NAME = 'MY_TASK'
  AND SCHEDULED_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY SCHEDULED_TIME DESC;
```

### Error Handling

**Task failure behavior:**
- Failed task stops execution
- Child tasks don't run if parent fails
- Task remains in FAILED state
- Can configure error notifications

**Error notifications:**
```sql
CREATE TASK my_task
  WAREHOUSE = my_wh
  SCHEDULE = '5 MINUTE'
  ERROR_INTEGRATION = my_notification_integration
AS
  CALL my_procedure();
```

**Retry logic:**
```sql
-- Tasks don't auto-retry by default
-- Implement retry logic in stored procedure:
CREATE PROCEDURE retry_logic()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
  var max_retries = 3;
  var retry_count = 0;
  
  while (retry_count < max_retries) {
    try {
      // Your logic here
      return "Success";
    } catch (err) {
      retry_count++;
      if (retry_count >= max_retries) {
        throw err;
      }
    }
  }
$$;
```

### Best Practices

**1. Task Naming**
- Use descriptive names: `load_customer_data_task`
- Include frequency: `hourly_sales_aggregation`
- Indicate dependencies: `parent_extract_task`, `child_transform_task`

**2. Scheduling**
- Use appropriate intervals (don't over-schedule)
- Consider time zones (UTC recommended)
- Stagger tasks to avoid resource contention
- Use WHEN conditions to skip unnecessary runs

**3. Resource Management**
- Start with smaller warehouses
- Use serverless for variable workloads
- Suspend tasks during maintenance
- Monitor credit usage

**4. Error Handling**
- Implement error notifications
- Log errors to tables
- Design idempotent operations
- Test failure scenarios

**5. Monitoring**
- Check task history regularly
- Set up alerts for failures
- Monitor execution times
- Track credit consumption

**6. Task Trees**
- Keep trees shallow (3-4 levels max)
- Limit child tasks per parent (< 20)
- Document dependencies
- Test entire tree before production

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Standalone Task
Create a simple scheduled task that runs every 5 minutes.

### Exercise 2: CRON Scheduling
Create tasks with various CRON schedules.

### Exercise 3: Create Task Tree
Build a parent-child task hierarchy.

### Exercise 4: Serverless Task
Create and test a serverless task.

### Exercise 5: Conditional Execution
Create a task that runs only when a stream has data.

### Exercise 6: Task Monitoring
Query task history and analyze execution.

### Exercise 7: Error Handling
Test task failure and recovery.

### Exercise 8: Complete ETL Pipeline
Build an end-to-end automated pipeline with tasks.

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:

1. What's the difference between serverless and user-managed tasks?
2. How many child tasks can a parent task have?
3. What does the WHEN clause do in a task?
4. Can child tasks have their own schedules?
5. What happens when a parent task fails?
6. Which function checks if a stream has data?
7. What's the maximum number of tasks per account?
8. How do you manually execute a task?
9. What state must a task be in to run?
10. Can you create circular task dependencies?

---

## 🎯 Key Takeaways

- Tasks automate SQL execution on schedules or after predecessors
- Two types: Serverless (Snowflake-managed) and User-managed (warehouse)
- Schedule with CRON expressions or simple intervals (5 MINUTE)
- Build task trees (DAGs) with AFTER clause for dependencies
- Only root task has schedule, children run after parents
- Use WHEN clause for conditional execution (e.g., stream has data)
- Tasks must be RESUMED to run (created in SUSPENDED state)
- Maximum 1000 tasks per account, 100 children per parent
- Monitor with TASK_HISTORY() and ACCOUNT_USAGE views
- Combine with Streams for automated CDC pipelines
- Failed tasks stop execution and don't trigger children
- Use ERROR_INTEGRATION for notifications

---

## 📚 Additional Resources

- [Snowflake Docs: Tasks](https://docs.snowflake.com/en/user-guide/tasks-intro)
- [Task Scheduling](https://docs.snowflake.com/en/user-guide/tasks-intro#scheduling-tasks)
- [Task Trees](https://docs.snowflake.com/en/user-guide/tasks-graphs)
- [Serverless Tasks](https://docs.snowflake.com/en/user-guide/tasks-intro#serverless-tasks)
- [Task Monitoring](https://docs.snowflake.com/en/user-guide/tasks-monitoring)

---

## 🔜 Tomorrow: Day 4 - Streams + Tasks Integration

We'll combine Streams and Tasks to build fully automated CDC pipelines with incremental processing.
