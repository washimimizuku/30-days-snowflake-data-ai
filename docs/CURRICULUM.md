# SnowPro Advanced Data Engineer - 30 Day Curriculum

## Quick Reference

| Week | Focus Area | Days | Hours | Key Topics |
|------|-----------|------|-------|------------|
| 1 | Data Movement & Transformation | 1-7 | 14h | Snowpipe, Streams, Tasks, Dynamic Tables |
| 2 | Performance Optimization | 8-14 | 14h | Clustering, Warehouses, Query Tuning |
| 3 | Security & Data Protection | 15-21 | 14h | Encryption, RBAC, Governance, Time Travel |
| 4 | Advanced Features & Exam Prep | 22-30 | 18h | Snowpark, Practice Exams, Review |

**Total**: 60 hours over 30 days (2 hours/day)

---

## Detailed Daily Breakdown

### Week 1: Data Movement & Transformation (14 hours)

| Day | Topic | Time | Hands-On Focus |
|-----|-------|------|----------------|
| 1 | Snowpipe & Continuous Loading | 2h | Set up auto-ingest from S3 |
| 2 | Streams for CDC | 2h | Track changes on tables |
| 3 | Tasks & Orchestration | 2h | Build task DAG |
| 4 | Streams + Tasks Integration | 2h | CDC pipeline with SCD Type 2 |
| 5 | Dynamic Tables | 2h | 3-layer dynamic table pipeline |
| 6 | Advanced SQL Transformations | 2h | Window functions, JSON parsing |
| 7 | Review & Mini-Project | 2h | End-to-end data pipeline |

**Exam Weight**: 30% (Data Movement & Transformation)

---

### Week 2: Performance Optimization (14 hours)

| Day | Topic | Time | Hands-On Focus |
|-----|-------|------|----------------|
| 8 | Clustering & Micro-Partitions | 2h | Optimize 3 large tables |
| 9 | Search Optimization Service | 2h | Optimize lookup queries |
| 10 | Materialized Views | 2h | Build 5 materialized views |
| 11 | Query Performance Tuning | 2h | Optimize 5 slow queries |
| 12 | Warehouse Sizing & Scaling | 2h | Right-size 3 workloads |
| 13 | Result Caching | 2h | Maximize cache utilization |
| 14 | Review & Performance Lab | 2h | Optimize poorly performing pipeline |

**Exam Weight**: 25% (Performance Optimization)

---

### Week 3: Security & Data Protection (14 hours)

| Day | Topic | Time | Hands-On Focus |
|-----|-------|------|----------------|
| 15 | Data Encryption & Key Management | 2h | Implement Tri-Secret Secure |
| 16 | Access Control & Security | 2h | Build security framework |
| 17 | Data Governance & Compliance | 2h | Create audit queries |
| 18 | Time Travel & Fail-Safe | 2h | Data recovery scenarios |
| 19 | Data Sharing & Secure Sharing | 2h | Share data securely |
| 20 | Monitoring & Troubleshooting | 2h | Build monitoring dashboard |
| 21 | Review & Security Lab | 2h | Comprehensive security implementation |

**Exam Weight**: 20% (Data Protection & Security) + 15% (Monitoring)

---

### Week 4: Advanced Features & Exam Prep (18 hours)

| Day | Topic | Time | Activity |
|-----|-------|------|----------|
| 22 | External Tables & Functions | 2h | Query external data, build external function |
| 23 | Stored Procedures & UDFs | 2h | Build 5 stored procedures |
| 24 | Snowpark for Data Engineering | 2h | Build Snowpark pipeline |
| 25 | Hands-On Project | 2h | Production-grade pipeline |
| 26 | Practice Exam 1 | 2h | Full-length practice exam |
| 27 | Practice Exam 2 & Review | 2h | Second exam + review weak areas |
| 28 | Focused Review | 2h | Review all notes, key facts |
| 29 | Final Review | 2h | Confidence builder |
| 30 | Exam Day | 2h | Take certification exam |

**Exam Weight**: 10% (Advanced Features)

---

## Exam Topic Coverage

### Domain 1: Data Movement & Transformation (30%)
- **Days 1-6**: Snowpipe, Streams, Tasks, Dynamic Tables, SQL transformations
- **Practice**: 7 hands-on exercises
- **Project**: End-to-end data pipeline

### Domain 2: Performance Optimization (25%)
- **Days 8-13**: Clustering, Search Optimization, Query Tuning, Warehouses, Caching
- **Practice**: Optimize 15+ queries and tables
- **Lab**: Performance optimization challenge

### Domain 3: Data Protection & Security (20%)
- **Days 15-19**: Encryption, RBAC, Governance, Time Travel, Data Sharing
- **Practice**: Build complete security framework
- **Lab**: Comprehensive security implementation

### Domain 4: Monitoring & Troubleshooting (15%)
- **Day 20**: Account Usage, Query History, Cost Monitoring, Alerts
- **Practice**: Build 10+ monitoring queries
- **Deliverable**: Monitoring dashboard

### Domain 5: Advanced Features (10%)
- **Days 22-24**: External Tables, Stored Procedures, UDFs, Snowpark
- **Practice**: Build external integrations
- **Project**: Snowpark data pipeline

---

## Key Facts to Memorize

### Time Travel & Fail-Safe
- Time Travel: 0-90 days (configurable)
- Fail-safe: 7 days (non-configurable)
- Transient tables: 0-1 day Time Travel, no Fail-safe
- Temporary tables: No Time Travel or Fail-safe

### Warehouse Sizes & Credits
- XS: 1 credit/hour
- S: 2 credits/hour
- M: 4 credits/hour
- L: 8 credits/hour
- XL: 16 credits/hour
- 2XL: 32 credits/hour
- 3XL: 64 credits/hour
- 4XL: 128 credits/hour

### Task Limitations
- Max 1000 tasks per account
- Max 100 child tasks per parent
- Serverless tasks: Snowflake-managed compute
- User-managed tasks: Require warehouse

### Stream Types
- Standard: INSERT, UPDATE, DELETE
- Append-Only: INSERT only
- Insert-Only: INSERT only (for external tables)

### Clustering
- Max 4 clustering keys
- Best for large tables (multi-TB)
- Automatic clustering available
- Re-clustering consumes credits

---

## Study Schedule Options

### Option 1: Consistent Daily (Recommended)
- 2 hours every day for 30 days
- Best for retention
- Steady progress

### Option 2: Weekday Intensive
- 2.5 hours Mon-Fri (50 hours)
- 5 hours on 2 weekends (10 hours)
- Faster completion (4 weeks)

### Option 3: Weekend Warrior
- 6 hours every Saturday & Sunday
- 10 weekends = 60 hours
- Slower but flexible

---

## Progress Tracking

### Week 1 Checklist
- [ ] Completed all 7 daily exercises
- [ ] Built end-to-end data pipeline
- [ ] Can explain Streams vs. Dynamic Tables
- [ ] Understand Task orchestration

### Week 2 Checklist
- [ ] Optimized 15+ queries/tables
- [ ] Can read query profiles
- [ ] Understand clustering strategies
- [ ] Know warehouse sizing best practices

### Week 3 Checklist
- [ ] Built security framework
- [ ] Created audit queries
- [ ] Understand RBAC hierarchy
- [ ] Know Time Travel vs. Fail-safe

### Week 4 Checklist
- [ ] Completed hands-on project
- [ ] Scored 80%+ on practice exams
- [ ] Reviewed all weak areas
- [ ] Ready for exam

---

## Exam Day Preparation

### Before Exam
- [ ] Good night's sleep (8 hours)
- [ ] Light breakfast
- [ ] Quiet environment
- [ ] Stable internet connection
- [ ] ID ready
- [ ] Arrive 15 minutes early

### During Exam
- [ ] Read questions carefully
- [ ] Flag difficult questions
- [ ] Manage time (1.75 min/question)
- [ ] Review flagged questions
- [ ] Don't overthink

### Exam Format
- 65 multiple choice questions
- 115 minutes (1 hour 55 minutes)
- 70% passing score (46/65 correct)
- No negative marking
- Can flag and review questions

---

## Post-Exam Next Steps

### If You Pass ✅
1. Update LinkedIn with certification
2. Add to resume
3. Build Project S2 (CDC Pipeline)
4. Write blog post about exam experience
5. Start SnowPro Advanced Architect (optional)

### If You Don't Pass ❌
1. Review exam report (topic breakdown)
2. Focus on weak areas
3. Retake after 14 days
4. Additional study: 10-20 hours on weak topics
5. Take more practice exams

---

## Success Rate Prediction

**If you complete all 30 days**: 85-90% pass rate  
**If you skip hands-on**: 50-60% pass rate  
**If you only do practice exams**: 40-50% pass rate

**Key Success Factors**:
1. Hands-on practice (most important)
2. Understanding concepts (not just memorization)
3. Practice exams (identify weak areas)
4. Consistent daily study
5. Real-world thinking

Good luck! 🚀
