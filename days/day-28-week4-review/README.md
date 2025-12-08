# Day 28: Week 4 Review & Final Preparation

## 📖 Overview (5 min)

Today is your **final comprehensive review** before the certification exam. You'll review all key concepts from Weeks 1-4 and take a 50-question review quiz to solidify your knowledge.

**Goals for Today:**
- Review all major concepts from the bootcamp
- Take 50-question comprehensive review quiz
- Create your final cheat sheet
- Build confidence for exam day

**Time Allocation:**
- Concept review: 60 minutes
- 50-question quiz: 30 minutes
- Create cheat sheet: 20 minutes
- Final preparation: 10 minutes

**Total Time: 2 hours**

---

## Comprehensive Review

### Week 1: Data Movement & Transformation

**Key Concepts:**
- **Snowpipe**: Continuous loading, auto-ingest, serverless compute, 14-day history
- **Streams**: CDC with METADATA$ columns, Standard vs. Append-Only, offset management
- **Tasks**: CRON scheduling, DAGs, SYSTEM$STREAM_HAS_DATA(), serverless vs. user-managed
- **Dynamic Tables**: TARGET_LAG, automatic refresh, incremental vs. full

**Critical Facts:**
- Snowpipe uses serverless compute (not warehouses)
- Streams track INSERT/DELETE (UPDATE = DELETE + INSERT)
- Minimum task schedule: 1 minute
- Stream retention = table's Time Travel retention

**Common Mistakes:**
- Confusing streams with dynamic tables
- Forgetting WHEN clause for conditional task execution
- Not understanding stream offset consumption

---

### Week 2: Performance Optimization

**Key Concepts:**
- **Clustering**: Organize micro-partitions, max 4 keys, check clustering_depth
- **Search Optimization**: Point lookups on high-cardinality columns
- **Materialized Views**: Pre-computed results, automatic maintenance, cost trade-off
- **Warehouse Sizing**: XS to 6XL, multi-cluster for concurrency, auto-suspend/resume
- **Result Caching**: 24-hour TTL, exact query match, invalidated on data changes

**Critical Facts:**
- Max clustering keys: 4
- Clustering depth > 10 suggests reclustering needed
- Multi-cluster max: 10 clusters
- Result cache requires exact query text match

**Common Mistakes:**
- Over-clustering (too many keys)
- Using clustering for low-cardinality columns
- Confusing materialized views with regular views
- Not understanding partition pruning

---

### Week 3: Security & Governance

**Key Concepts:**
- **RBAC**: Role hierarchy, future grants, OWNERSHIP vs. USAGE
- **Masking Policies**: Column-level, role-based visibility
- **Row Access Policies**: Row-level filtering, one per table
- **Time Travel**: 0-90 days (Enterprise), query historical data, UNDROP
- **Fail-safe**: 7 days, Snowflake Support only, non-recoverable by users
- **Data Sharing**: Secure shares, reader accounts, no data movement

**Critical Facts:**
- Time Travel max: 90 days (Enterprise), 1 day (Standard)
- Fail-safe: Always 7 days, cannot be disabled
- Masking = columns, Row Access = rows
- Encryption: AES-256 at rest

**Common Mistakes:**
- Confusing Time Travel with Fail-safe
- Thinking Fail-safe is user-accessible
- Mixing up masking and row access policies
- Not understanding role hierarchy inheritance

---

### Week 4: Advanced Features

**Key Concepts:**
- **Stored Procedures**: JavaScript/SQL/Python, can contain DML, EXECUTE AS CALLER/OWNER
- **UDFs**: Scalar and Table (UDTF), cannot contain DML, MEMOIZABLE for caching
- **Snowpark**: DataFrame API, lazy evaluation, pushdown optimization
- **External Tables**: Read-only, query data in cloud storage, partitioning

**Critical Facts:**
- Stored procedures can contain DML, UDFs cannot
- MEMOIZABLE caches UDF results for identical inputs
- Snowpark uses lazy evaluation (.collect() triggers execution)
- External tables are read-only

**Common Mistakes:**
- Trying to use DML in UDFs
- Not understanding EXECUTE AS CALLER vs. OWNER
- Confusing Snowpark lazy vs. eager evaluation

---

## Monitoring & Troubleshooting

**Key Concepts:**
- **ACCOUNT_USAGE**: 45 min to 3-hour latency, 365-day retention
- **INFORMATION_SCHEMA**: Real-time, 7-day retention
- **Query Profile**: Identify bottlenecks, partition pruning, spilling
- **Resource Monitors**: Credit limits, suspend/notify actions

**Critical Facts:**
- ACCOUNT_USAGE latency: 45 min to 3 hours
- INFORMATION_SCHEMA: Real-time but limited retention
- Query history: 7 days (INFORMATION_SCHEMA), 365 days (ACCOUNT_USAGE)
- Spilling to disk = warehouse too small

**Common Mistakes:**
- Using ACCOUNT_USAGE for real-time monitoring
- Not checking query profile for performance issues
- Ignoring partition pruning metrics

---

## Critical Facts Checklist

Memorize these for the exam:

### Limits and Maximums
- [ ] Time Travel: 0-90 days (Enterprise), 0-1 day (Standard)
- [ ] Fail-safe: 7 days (always)
- [ ] Clustering keys: Maximum 4
- [ ] Task schedule: Minimum 1 minute
- [ ] Result cache: 24-hour TTL
- [ ] Snowpipe history: 14 days
- [ ] Multi-cluster warehouses: Maximum 10 clusters
- [ ] Query history (INFORMATION_SCHEMA): 7 days
- [ ] Query history (ACCOUNT_USAGE): 365 days

### Key Differences
- [ ] Streams vs. Dynamic Tables
- [ ] Masking vs. Row Access Policies
- [ ] EXECUTE AS CALLER vs. OWNER
- [ ] Standard vs. Economy scaling
- [ ] ACCOUNT_USAGE vs. INFORMATION_SCHEMA
- [ ] Stored Procedures vs. UDFs
- [ ] Time Travel vs. Fail-safe

### Security
- [ ] Encryption: AES-256 at rest
- [ ] Tri-Secret Secure: Customer-managed keys
- [ ] Role hierarchy: Parent inherits from child
- [ ] Future grants: Apply to future objects

---

## 💻 Take the Review Quiz (30 min)

**Open `quiz.md` and complete the 50-question comprehensive review.**

This quiz covers all major topics from the bootcamp with emphasis on high-frequency exam topics.

---

## Create Your Final Cheat Sheet (20 min)

Create a one-page cheat sheet with:

### Section 1: Critical Numbers
- Time Travel limits
- Clustering maximums
- Task minimums
- Cache TTLs
- Retention periods

### Section 2: Key Differences
- Streams vs. Dynamic Tables
- Masking vs. Row Access
- CALLER vs. OWNER
- Standard vs. Economy
- ACCOUNT_USAGE vs. INFORMATION_SCHEMA

### Section 3: Common Patterns
- Stream + Task pattern
- Clustering strategy
- Security policy application
- Monitoring queries

### Section 4: Troubleshooting
- Task failures → Check TASK_HISTORY
- Slow queries → Check Query Profile
- Snowpipe issues → SYSTEM$PIPE_STATUS
- High costs → WAREHOUSE_METERING_HISTORY

---

## Final Preparation Checklist

### Knowledge Check
- [ ] Can explain Streams vs. Dynamic Tables
- [ ] Understand Task orchestration and dependencies
- [ ] Know clustering best practices
- [ ] Understand all security policy types
- [ ] Can troubleshoot common issues
- [ ] Know all critical limits and maximums

### Practice Exam Results
- [ ] Practice Exam 1 score: _____ %
- [ ] Practice Exam 2 score: _____ %
- [ ] Average score: _____ %
- [ ] Confidence level: _____ /5

### Weak Areas Addressed
- [ ] Identified all weak areas
- [ ] Reviewed relevant day materials
- [ ] Practiced hands-on exercises
- [ ] Feel confident in previously weak areas

---

## Exam Day Preparation

### Tomorrow (Day 29): Final Review
- Light review of cheat sheet (1 hour)
- 20 rapid-fire confidence-building questions
- Relax and stay positive
- Get good sleep (8 hours)

### Day 30: Exam Day
- Arrive 15 minutes early
- Have ID ready
- Quiet space, stable internet
- Stay calm and confident
- Trust your preparation

---

## Exam Strategy Reminders

### Time Management
- 115 minutes for 65 questions
- ~1.75 minutes per question
- Flag difficult questions, return later
- Save 10-15 minutes for review

### Question Approach
1. Read carefully (watch for "NOT" questions)
2. Eliminate obviously wrong answers
3. Choose between remaining options
4. Don't overthink
5. Trust your first instinct

### Common Traps
- Absolute words: "always", "never", "must"
- "All of the above" - verify each option
- Similar options - look for subtle differences
- Scenario questions - identify the key requirement

---

## Confidence Building

### You've Completed
- ✅ 25 days of intensive study
- ✅ Hands-on project integrating all concepts
- ✅ 2 full practice exams (130 questions)
- ✅ Multiple quizzes (200+ questions total)
- ✅ Comprehensive review of all topics

### You're Ready Because
- You understand core concepts deeply
- You've practiced hands-on extensively
- You know the exam format and question types
- You've identified and addressed weak areas
- You've scored well on practice exams

### Remember
- You've already passed SnowPro Core
- You've put in the work (60+ hours)
- You have the knowledge and skills
- You're prepared for this certification
- You can do this!

---

## 🎯 Success Criteria

Today is successful when:
- ✅ Reviewed all major concepts
- ✅ Completed 50-question review quiz
- ✅ Created final cheat sheet
- ✅ Feel confident and prepared
- ✅ Ready for exam day

---

## 📚 Final Resources

- **Your Cheat Sheet**: Review tomorrow
- **Practice Exam Results**: Identify patterns
- **Snowflake Docs**: Quick reference if needed
- **Your Notes**: Days 1-27

---

## 🔜 Tomorrow: Day 29 - Final Review & Confidence Builder

Tomorrow is a light review day with 20 rapid-fire questions to build confidence. Focus on staying relaxed and positive.

**You're almost there!** 💪

