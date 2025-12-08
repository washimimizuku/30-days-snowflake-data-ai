# Day 3 Quiz: Tasks & Task Orchestration

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What's the difference between serverless and user-managed tasks?

A) Serverless tasks are faster than user-managed tasks  
B) Serverless uses Snowflake-managed compute, user-managed requires a warehouse  
C) Serverless tasks can only run SQL, user-managed can run stored procedures  
D) User-managed tasks are free, serverless tasks cost extra  

**Your answer:**

---

### 2. What is the maximum number of child tasks a parent task can have?

A) 10  
B) 50  
C) 100  
D) Unlimited  

**Your answer:**

---

### 3. What does the WHEN clause do in a task?

A) Specifies when the task was created  
B) Sets the task schedule  
C) Defines a condition that must be TRUE for the task to run  
D) Determines which warehouse to use  

**Your answer:**

---

### 4. Can child tasks have their own schedules?

A) Yes, each task can have its own schedule  
B) No, only the root task has a schedule  
C) Yes, but only if they're serverless tasks  
D) Only if the parent task is suspended  

**Your answer:**

---

### 5. What happens when a parent task fails?

A) Child tasks run anyway  
B) Child tasks are skipped and don't run  
C) Child tasks run with a warning  
D) The entire task tree is deleted  

**Your answer:**

---

### 6. Which function checks if a stream has data before running a task?

A) CHECK_STREAM_DATA('stream_name')  
B) STREAM_HAS_DATA('stream_name')  
C) SYSTEM$STREAM_HAS_DATA('stream_name')  
D) GET_STREAM_STATUS('stream_name')  

**Your answer:**

---

### 7. What is the maximum number of tasks allowed per Snowflake account?

A) 100  
B) 500  
C) 1,000  
D) 10,000  

**Your answer:**

---

### 8. How do you manually execute a task?

A) RUN TASK task_name;  
B) START TASK task_name;  
C) EXECUTE TASK task_name;  
D) CALL TASK task_name;  

**Your answer:**

---

### 9. What state must a task be in to run on its schedule?

A) CREATED  
B) STARTED (RESUMED)  
C) ACTIVE  
D) ENABLED  

**Your answer:**

---

### 10. Can you create circular task dependencies (Task A → Task B → Task A)?

A) Yes, circular dependencies are allowed  
B) No, tasks must form a DAG (Directed Acyclic Graph)  
C) Yes, but only with serverless tasks  
D) Yes, but only within the same schema  

**Your answer:**

---

## Answer Key

1. **B** - Serverless uses Snowflake-managed compute, user-managed requires a warehouse
2. **C** - 100 child tasks maximum per parent
3. **C** - Defines a condition that must be TRUE for the task to run
4. **B** - No, only the root task has a schedule (children use AFTER clause)
5. **B** - Child tasks are skipped and don't run
6. **C** - SYSTEM$STREAM_HAS_DATA('stream_name')
7. **D** - 10,000 tasks maximum per account
8. **C** - EXECUTE TASK task_name;
9. **B** - STARTED (RESUMED) - tasks are created in SUSPENDED state
10. **B** - No, tasks must form a DAG (Directed Acyclic Graph) - no circular dependencies

---

## Score Yourself

- 9-10/10: Excellent! You understand Tasks thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Two types**: Serverless (Snowflake-managed) and User-managed (warehouse)  
✅ **Scheduling**: CRON expressions or simple intervals (5 MINUTE)  
✅ **Task trees**: Root has schedule, children use AFTER clause  
✅ **Limits**: 10,000 tasks per account, 100 children per parent  
✅ **Conditional**: Use WHEN clause (e.g., SYSTEM$STREAM_HAS_DATA)  
✅ **States**: SUSPENDED (default), STARTED (running), EXECUTING, SUCCEEDED, FAILED  
✅ **Execution**: EXECUTE TASK for manual runs  
✅ **Dependencies**: Must be DAG (no circular dependencies)  
✅ **Failure**: Parent failure stops children from running  
✅ **Resume order**: Resume children first, then root  

## Exam Tips

**Common exam question patterns:**
- When to use serverless vs. user-managed tasks
- Task tree structure and dependencies
- WHEN clause usage with streams
- Task limits (1000 per account, 100 children per parent)
- Task states and lifecycle
- How to schedule tasks (CRON vs simple intervals)
- What happens when tasks fail

**Remember for the exam:**
- Tasks are created in SUSPENDED state (must RESUME)
- Only root task has schedule
- Child tasks use AFTER clause
- Maximum 10,000 tasks per account
- Maximum 100 child tasks per parent
- No circular dependencies (must be DAG)
- Failed parent = children don't run
- EXECUTE TASK for manual execution
- WHEN clause for conditional execution

**Scenario questions:**
- "How to automate stream processing?" → Task with WHEN SYSTEM$STREAM_HAS_DATA
- "Task tree not running" → Check if root task is RESUMED
- "Need to run task only during business hours" → Use WHEN with time condition
- "Parent task failed, what happens to children?" → Children are skipped
- "How to test a task without waiting for schedule?" → EXECUTE TASK

## Common Mistakes to Avoid

❌ **Mistake**: Creating task and expecting it to run immediately  
✅ **Correct**: Tasks are created SUSPENDED, must ALTER TASK ... RESUME

❌ **Mistake**: Giving child tasks their own schedules  
✅ **Correct**: Only root task has schedule, children use AFTER

❌ **Mistake**: Resuming root task before children  
✅ **Correct**: Resume children first, then root task

❌ **Mistake**: Creating circular dependencies  
✅ **Correct**: Task dependencies must form a DAG (no cycles)

❌ **Mistake**: Not checking WHEN conditions before execution  
✅ **Correct**: Use WHEN clause to avoid unnecessary runs

## Real-World Scenarios

**Scenario 1: Automated CDC Pipeline**
- Stream tracks changes on source table
- Task with WHEN SYSTEM$STREAM_HAS_DATA processes changes
- Runs every minute but only when data exists
- Benefit: Efficient, no wasted executions

**Scenario 2: Daily ETL Pipeline**
- Root task: Extract (scheduled daily at 2 AM)
- Child task 1: Transform (after extract)
- Child task 2: Load (after transform)
- Child task 3: Send notification (after load)
- Benefit: Orchestrated, sequential execution

**Scenario 3: Multi-Source Data Integration**
- Root task: Check all sources (every 5 minutes)
- Child tasks: Process each source independently
- Grandchild task: Merge all results
- Benefit: Parallel processing, efficient

**Scenario 4: Business Hours Processing**
- Task with WHEN CURRENT_TIME BETWEEN '08:00' AND '18:00'
- Runs every 15 minutes but only during business hours
- Benefit: Resource optimization, cost savings

## Next Steps

- If you scored 8-10: Move to Day 4 (Streams + Tasks Integration)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Practice Questions

Try answering these without looking:

1. What command resumes a suspended task?
2. How do you create a task that runs every 5 minutes?
3. What's the difference between SCHEDULE and AFTER clauses?
4. Can you have more than 100 child tasks for one parent?
5. What happens if you don't resume a task after creating it?

**Answers:**
1. ALTER TASK task_name RESUME;
2. SCHEDULE = '5 MINUTE' or SCHEDULE = 'USING CRON */5 * * * * UTC'
3. SCHEDULE is for root tasks (when to run), AFTER is for child tasks (run after parent)
4. No, maximum is 100 child tasks per parent
5. Nothing - task stays SUSPENDED and never runs
