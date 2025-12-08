# Project Structure

This document explains the organization and structure of the 30 Days of Snowflake bootcamp.

---

## Directory Structure

```
30-days-snowflake-data-ai/
├── LICENSE                    # MIT License
├── README.md                  # Main overview and introduction
├── QUICKSTART.md             # Quick setup guide (5-10 min)
├── CURRENT_STATUS.md         # Project status and progress tracking
├── .gitignore                # Git ignore file
│
├── days/                     # All 30 daily lessons
│   ├── day-01-snowpipe-continuous-loading/
│   │   ├── README.md        # Theory and learning objectives
│   │   ├── exercise.sql     # Hands-on exercises with TODOs
│   │   ├── solution.sql     # Complete solutions
│   │   ├── quiz.md          # Quiz with answers
│   │   └── setup.md         # Setup instructions (optional)
│   ├── day-02-streams-change-data-capture/
│   ├── day-03-tasks-orchestration/
│   └── ... (through day-30)
│
├── docs/                     # Documentation
│   ├── SETUP.md             # Detailed Snowflake setup
│   ├── CURRICULUM.md        # Detailed curriculum breakdown
│   ├── PREREQUISITES.md     # Prerequisites and readiness check
│   ├── PROJECT_STRUCTURE.md # This file
│   ├── AWS_SETUP.md         # AWS configuration guide (coming soon)
│   ├── AZURE_SETUP.md       # Azure configuration guide (coming soon)
│   ├── TROUBLESHOOTING.md   # Common issues and solutions (coming soon)
│   ├── EXAM_GUIDE.md        # Exam preparation guide (coming soon)
│   └── RESOURCES.md         # Additional learning resources (coming soon)
│
├── data/                     # Sample data files
│   ├── raw/                 # Raw sample data
│   │   ├── customer_events.json
│   │   ├── sales_data.csv (coming soon)
│   │   └── sensor_data.parquet (coming soon)
│   └── processed/           # Processed/cleaned data
│
└── tools/                    # Utility scripts
    ├── setup_check.sql      # Verify Snowflake setup
    ├── cleanup.sql          # Clean up resources (coming soon)
    └── cheatsheet.md        # Quick reference guide
```

---

## File Naming Conventions

### Day Folders
- **Format**: `day-XX-topic-name`
- **Example**: `day-01-snowpipe-continuous-loading`
- **Rules**:
  - Use lowercase
  - Use hyphens (not underscores or spaces)
  - Two-digit day number (01, 02, ..., 30)
  - Descriptive topic name

### Files in Each Day

#### Required Files

**README.md**
- Main lesson content
- Theory and concepts
- Learning objectives
- Key takeaways
- Links to resources

**exercise.sql**
- Hands-on exercises
- TODO comments for students
- Clear section headers
- Progressive difficulty

**solution.sql**
- Complete working solutions
- Well-commented code
- Additional examples
- Troubleshooting queries

**quiz.md**
- 10 questions
- Space for student answers
- Correct answers provided
- Scoring guide
- Exam tips

#### Optional Files

**setup.md**
- Detailed setup instructions
- For complex days requiring AWS/Azure configuration
- Step-by-step guides
- Troubleshooting tips

**data files (.json, .csv, .parquet)**
- Sample data for exercises
- Realistic but small file sizes
- Various formats to demonstrate different scenarios

---

## Content Structure

### README.md Template

```markdown
# Day X: Topic Name

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Objective 1
- Objective 2
- Objective 3

---

## Theory

### Concept 1
Explanation with code examples

### Concept 2
Explanation with code examples

---

## 💻 Exercises (40 min)

### Exercise 1: Title
Description and instructions

### Exercise 2: Title
Description and instructions

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:
1. Question 1
2. Question 2
...

---

## 🎯 Key Takeaways

- Key point 1
- Key point 2
- Key point 3

---

## 📚 Additional Resources

- Link 1
- Link 2

---

## 🔜 Tomorrow: Day X+1 - Topic

Preview of next day's content
```

### exercise.sql Template

```sql
/*
Day X: Topic Name - Exercises
Complete each exercise below
Time: 40 minutes
*/

-- ============================================================================
-- Exercise 1: Title (X min)
-- ============================================================================

-- TODO: Description
-- YOUR CODE HERE

-- ============================================================================
-- Exercise 2: Title (X min)
-- ============================================================================

-- TODO: Description
-- YOUR CODE HERE

-- ============================================================================
-- Bonus Challenge (Optional)
-- ============================================================================

-- TODO: Advanced exercise
-- YOUR CODE HERE
```

### quiz.md Template

```markdown
# Day X Quiz: Topic Name

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. Question text?

A) First option  
B) Second option  
C) Third option  
D) Fourth option  

**Your answer:**

---

### 2. Question text?

A) First option  
B) Second option  
C) Third option  
D) Fourth option  

**Your answer:**

---

[... continue for all questions ...]

---

## Answer Key

1. **B** - Explanation of correct answer
2. **C** - Explanation of correct answer
[... all answers ...]

---

## Score Yourself

- 9-10/10: Excellent!
- 7-8/10: Good!
- 5-6/10: Review the lesson
- 0-4/10: Re-read and retry

## Exam Tips

Key concepts to remember for the exam
```

### Quiz Question Counts

**By Day Type:**

| Day Type | Question Count | Purpose |
|----------|---------------|---------|
| Normal Days (1-6, 8-13, 15-20, 22-25) | 10 questions | Daily knowledge check |
| Review Days (7, 14, 21, 28) | 50 questions | Comprehensive weekly review |
| Practice Exams (26-27) | 65 questions | Full exam simulation |
| Final Review (29) | 20 questions | Rapid-fire confidence builder |

**Question Format:**
- Multiple choice with 4 options (A, B, C, D)
- One correct answer per question
- Distractors should be plausible but clearly wrong
- Mix of difficulty levels (easy, medium, hard)
- Cover all key concepts from the day/week

---

## Time Allocation

Each day is designed for exactly **2 hours**:

| Activity | Time | File |
|----------|------|------|
| Theory & Reading | 15 min | README.md |
| Hands-on Exercises | 40 min | exercise.sql |
| Quiz | 5 min | quiz.md |
| Deep Practice | 60 min | Exploration & building |

**Total**: 2 hours per day × 30 days = 60 hours

---

## Content Guidelines

### Theory (README.md)

**Do:**
- ✅ Explain concepts clearly with examples
- ✅ Use code snippets to illustrate
- ✅ Include diagrams or ASCII art when helpful
- ✅ Link to official Snowflake documentation
- ✅ Provide real-world use cases

**Don't:**
- ❌ Copy/paste from documentation
- ❌ Use overly technical jargon without explanation
- ❌ Include irrelevant information
- ❌ Make it too long (keep to 15 min reading time)

### Exercises (exercise.sql)

**Do:**
- ✅ Start simple, increase complexity
- ✅ Use clear TODO comments
- ✅ Provide context and instructions
- ✅ Include bonus challenges
- ✅ Test all code before committing

**Don't:**
- ❌ Make exercises too easy or too hard
- ❌ Skip error handling scenarios
- ❌ Forget to include setup code
- ❌ Use unrealistic examples

### Solutions (solution.sql)

**Do:**
- ✅ Provide complete working code
- ✅ Add explanatory comments
- ✅ Show alternative approaches
- ✅ Include troubleshooting queries
- ✅ Demonstrate best practices

**Don't:**
- ❌ Just copy exercise file with answers
- ❌ Skip comments
- ❌ Use shortcuts that skip learning
- ❌ Forget to test thoroughly

### Quiz (quiz.md)

**Do:**
- ✅ Test understanding, not memorization
- ✅ Include scenario-based questions
- ✅ Provide detailed explanations
- ✅ Relate to exam format
- ✅ Cover key concepts from the day

**Don't:**
- ❌ Make questions too easy
- ❌ Use trick questions
- ❌ Test obscure details
- ❌ Forget to provide answers

---

## Data Files

### When to Include Data Files

Include sample data files when:
- Students need to upload files to cloud storage
- Testing different file formats (JSON, CSV, Parquet)
- Demonstrating data quality issues
- Building end-to-end pipelines
- Showing realistic data volumes

### Data File Guidelines

**Size:**
- Keep files small (< 1 MB for Git)
- Use realistic but minimal data
- Compress large files

**Format:**
- JSON: For semi-structured data
- CSV: For tabular data
- Parquet: For columnar data
- Avro: For schema evolution examples

**Organization:**
- `data/raw/` - Original, unprocessed files
- `data/processed/` - Cleaned or transformed files
- Use descriptive filenames
- Include README.md in data folders

---

## Documentation Files

### docs/ Folder Contents

**SETUP.md**
- Snowflake account setup
- Initial configuration
- Warehouse creation
- Role setup

**CURRICULUM.md**
- Complete 30-day breakdown
- Week-by-week structure
- Topic coverage
- Time estimates

**PREREQUISITES.md**
- Required knowledge
- Self-assessment quiz
- Preparation resources
- Readiness checklist

**AWS_SETUP.md** (coming soon)
- S3 bucket creation
- IAM role configuration
- SNS/SQS setup
- Storage integration

**TROUBLESHOOTING.md** (coming soon)
- Common errors
- Solutions
- Debugging tips
- FAQ

**EXAM_GUIDE.md** (coming soon)
- Exam format
- Study strategies
- Practice questions
- Tips for success

---

## Tools

### tools/ Folder Contents

**setup_check.sql**
- Verify Snowflake setup
- Check privileges
- Test basic operations
- Validate configuration

**cheatsheet.md**
- Quick reference
- Common commands
- Key concepts
- Exam tips

**cleanup.sql** (coming soon)
- Remove bootcamp resources
- Drop databases
- Delete warehouses
- Clean up storage

---

## Version Control

### What to Commit

✅ **Do commit:**
- All .md files
- All .sql files
- Small sample data files (< 1 MB)
- Documentation
- Configuration templates

❌ **Don't commit:**
- Credentials or passwords
- Large data files (> 1 MB)
- Personal notes
- IDE-specific files
- Temporary files

### .gitignore

The `.gitignore` file excludes:
- Credentials and secrets
- Large data files
- IDE files
- OS-specific files
- Temporary files
- Build artifacts

---

## Contributing

### Adding a New Day

1. Create folder: `days/day-XX-topic-name/`
2. Create required files:
   - README.md
   - exercise.sql
   - solution.sql
   - quiz.md
3. Optional: Add setup.md if needed
4. Test all SQL code
5. Update CURRENT_STATUS.md
6. Update CURRICULUM.md if needed

### Updating Documentation

1. Make changes to relevant .md files
2. Update CURRENT_STATUS.md
3. Test any code examples
4. Ensure links work
5. Check formatting

### Adding Sample Data

1. Create small, realistic data files
2. Place in `data/raw/` or `data/processed/`
3. Document in README.md
4. Keep files < 1 MB
5. Use appropriate formats

---

## Quality Standards

### Code Quality

- ✅ All SQL code must be tested
- ✅ Use consistent formatting
- ✅ Include comments
- ✅ Handle errors gracefully
- ✅ Follow Snowflake best practices

### Documentation Quality

- ✅ Clear and concise writing
- ✅ Proper grammar and spelling
- ✅ Working links
- ✅ Accurate information
- ✅ Up-to-date content

### Exercise Quality

- ✅ Appropriate difficulty
- ✅ Clear instructions
- ✅ Realistic scenarios
- ✅ Progressive complexity
- ✅ Time-appropriate (40 min)

---

## Maintenance

### Regular Updates

- Review and update for new Snowflake features
- Fix broken links
- Update version numbers
- Refresh sample data
- Improve based on feedback

### Issue Tracking

- Document known issues
- Track feature requests
- Monitor student feedback
- Prioritize improvements

---

## Questions?

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (coming soon)
- Review [SETUP.md](SETUP.md)
- See [QUICKSTART.md](../QUICKSTART.md)
- Open an issue on GitHub
