# Day 12 Quiz: Warehouse Sizing & Scaling

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. How many credits per hour does a Large warehouse consume?

A) 4  
B) 8  
C) 16  
D) 32  

**Your answer:**

---

### 2. What is the minimum billing increment for warehouse usage?

A) 1 second  
B) 10 seconds  
C) 60 seconds  
D) 5 minutes  

**Your answer:**

---

### 3. When should you scale UP a warehouse?

A) When you have many concurrent users  
B) When queries are slow and processing large data volumes  
C) When you want to save costs  
D) When queries are already fast  

**Your answer:**

---

### 4. When should you scale OUT (multi-cluster)?

A) When individual queries are slow  
B) When you have high concurrency and query queuing  
C) When you want to reduce costs  
D) When processing small datasets  

**Your answer:**

---

### 5. What does the STANDARD scaling policy do?

A) Waits 6 minutes before starting a cluster  
B) Starts clusters quickly to minimize queuing  
C) Never starts additional clusters  
D) Always runs maximum clusters  

**Your answer:**

---

### 6. What does the ECONOMY scaling policy do?

A) Starts clusters immediately  
B) Waits longer before starting clusters to save costs  
C) Never suspends warehouses  
D) Disables auto-resume  

**Your answer:**

---

### 7. What is the recommended AUTO_SUSPEND setting for development warehouses?

A) NULL (never suspend)  
B) 60-120 seconds  
C) 600 seconds (10 minutes)  
D) 3600 seconds (1 hour)  

**Your answer:**

---

### 8. What happens when AUTO_RESUME is enabled?

A) Warehouse starts automatically when a query is submitted  
B) Warehouse never suspends  
C) Warehouse scales up automatically  
D) Warehouse adds clusters automatically  

**Your answer:**

---

### 9. What is the maximum number of clusters in a multi-cluster warehouse?

A) 5  
B) 10  
C) 20  
D) Unlimited  

**Your answer:**

---

### 10. What do Resource Monitors do?

A) Improve query performance  
B) Set credit limits and trigger actions when thresholds are reached  
C) Automatically resize warehouses  
D) Cache query results  

**Your answer:**

---

## Answer Key

1. **B** - 8 credits per hour
2. **C** - 60 seconds (1 minute minimum)
3. **B** - When queries are slow and processing large data volumes
4. **B** - When you have high concurrency and query queuing
5. **B** - Starts clusters quickly to minimize queuing
6. **B** - Waits longer before starting clusters to save costs
7. **B** - 60-120 seconds (aggressive suspend for dev)
8. **A** - Warehouse starts automatically when a query is submitted
9. **B** - 10 clusters maximum
10. **B** - Set credit limits and trigger actions when thresholds are reached

---

## Score Yourself

- 9-10/10: Excellent! You understand warehouse sizing and scaling thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Warehouse Sizes**: X-Small (1) to 4X-Large (128 credits/hour)  
✅ **Billing**: 60-second minimum, then per-second  
✅ **Scale Up**: For complex queries, large data volumes  
✅ **Scale Out**: For high concurrency, many users  
✅ **Standard Policy**: Minimizes queuing, starts clusters quickly  
✅ **Economy Policy**: Saves costs, allows some queuing  
✅ **Auto-Suspend**: Saves credits during idle periods  
✅ **Auto-Resume**: Instant availability (1-2 seconds)  
✅ **Multi-Cluster**: 1-10 clusters, Enterprise Edition required  
✅ **Resource Monitors**: Credit limits with notifications and actions  

## Exam Tips

**Common exam question patterns:**
- Credit consumption calculations
- When to scale up vs. scale out
- Scaling policy differences (Standard vs. Economy)
- Auto-suspend and auto-resume behavior
- Multi-cluster warehouse configuration
- Resource monitor triggers and actions
- Right-sizing strategies
- Cost optimization techniques

**Remember for the exam:**
- Warehouse sizes: X-Small=1, Small=2, Medium=4, Large=8, X-Large=16, 2X-Large=32, 3X-Large=64, 4X-Large=128 credits/hour
- Billing: 60-second minimum, per-second after
- Scale up: Complex queries, large data
- Scale out: Concurrency, many users
- Standard: ~6 seconds before starting cluster
- Economy: ~6 minutes before starting cluster
- Auto-suspend: Recommended 60-600 seconds
- Auto-resume: ~1-2 seconds to start
- Multi-cluster: Max 10 clusters, Enterprise Edition
- Resource monitors: NOTIFY, SUSPEND, SUSPEND_IMMEDIATE

## Next Steps

- If you scored 8-10: Move to Day 13 (Result Caching)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Calculate monthly cost for a Medium warehouse running 8 hours/day
2. When would you choose Standard vs. Economy scaling policy?
3. How do you identify an undersized warehouse?
4. What auto-suspend setting for a 24/7 application?
5. How do you prevent cost overruns?
6. When should you consolidate warehouses?
7. How do you monitor warehouse efficiency?
8. What's the impact of increasing MIN_CLUSTER_COUNT?

## Real-World Applications

**Development Environment:**
- Size: X-Small
- Auto-suspend: 60 seconds
- Single cluster
- Cost-optimized

**ETL/Batch Processing:**
- Size: Large or X-Large
- Auto-suspend: 60 seconds
- Single cluster
- Performance-optimized

**BI Dashboards:**
- Size: Medium
- Multi-cluster: 1-5
- Scaling: Standard
- Auto-suspend: 300 seconds
- Balance performance and cost

**Real-Time Applications:**
- Size: Medium or Large
- Multi-cluster: 2-4 (min 2)
- Scaling: Standard
- Auto-suspend: 600 seconds or NULL
- Always available

**Cost Optimization Strategies:**
1. Aggressive auto-suspend (60-120 seconds)
2. Right-size based on actual usage
3. Separate workloads by warehouse
4. Use resource monitors
5. Monitor and adjust regularly
6. Leverage result caching
7. Scale up temporarily for large jobs
8. Use Economy policy for batch workloads

**Monitoring Checklist:**
- [ ] Credit consumption trends
- [ ] Query queuing frequency
- [ ] Warehouse utilization
- [ ] Credits per query
- [ ] Idle time percentage
- [ ] Resource monitor status
- [ ] Multi-cluster scaling events
- [ ] Cost vs. performance balance

