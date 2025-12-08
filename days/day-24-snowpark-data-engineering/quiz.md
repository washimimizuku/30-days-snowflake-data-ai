# Day 24 Quiz: Snowpark for Data Engineering

## Instructions
- 10 multiple choice questions
- Choose the best answer for each question
- Answers and explanations at the end
- Passing score: 7/10 (70%)

---

## Questions

### Question 1
What is Snowpark?

A) A new type of Snowflake warehouse  
B) A developer framework for writing code in Python/Java/Scala that executes in Snowflake  
C) A data visualization tool  
D) A machine learning platform

### Question 2
Where does Snowpark code execute?

A) On the client machine  
B) In a separate Spark cluster  
C) Directly in Snowflake's compute engine  
D) In a cloud function (Lambda/Azure Functions)

### Question 3
What is lazy evaluation in Snowpark?

A) Operations execute slowly  
B) Operations are not executed until results are needed  
C) Operations are cached automatically  
D) Operations run in the background

### Question 4
Which method is used to execute a Snowpark DataFrame and bring results to the client?

A) `.execute()`  
B) `.run()`  
C) `.collect()`  
D) `.fetch()`

### Question 5
What is the primary benefit of Snowpark over extracting data to Python/Spark?

A) Snowpark is faster than Spark  
B) Computation happens in Snowflake without data movement  
C) Snowpark is easier to learn  
D) Snowpark supports more languages

### Question 6
How do you create a DataFrame from a Snowflake table in Snowpark?

A) `df = session.read("table_name")`  
B) `df = session.table("table_name")`  
C) `df = session.query("table_name")`  
D) `df = session.load("table_name")`

### Question 7
What does `df.cache_result()` do in Snowpark?

A) Saves the DataFrame to a file  
B) Materializes and caches the DataFrame for reuse  
C) Compresses the DataFrame  
D) Exports the DataFrame to Pandas

### Question 8
Which is TRUE about Snowpark DataFrames?

A) They load all data into memory immediately  
B) They use lazy evaluation and generate SQL  
C) They require Spark to be installed  
D) They can only read data, not write

### Question 9
How do you deploy Snowpark code as a stored procedure?

A) `session.procedure.create()`  
B) `session.deploy()`  
C) `session.sproc.register()`  
D) `session.store()`

### Question 10
When should you use Snowpark instead of SQL?

A) For all queries  
B) For simple SELECT statements  
C) For complex transformations requiring programming logic  
D) Never, SQL is always better

---

## Answer Key

### Question 1: B
**Correct Answer: B) A developer framework for writing code in Python/Java/Scala that executes in Snowflake**

Explanation: Snowpark is Snowflake's developer framework that allows you to write data processing code in Python, Java, or Scala. The code executes directly in Snowflake's compute engine, bringing the processing to the data rather than moving data to external processing engines.

### Question 2: C
**Correct Answer: C) Directly in Snowflake's compute engine**

Explanation: Snowpark code executes directly in Snowflake's compute engine. This is a key advantage because it eliminates the need to move data out of Snowflake for processing. The Snowpark API translates your Python/Java/Scala code into optimized SQL that runs in Snowflake.

### Question 3: B
**Correct Answer: B) Operations are not executed until results are needed**

Explanation: Lazy evaluation means that DataFrame operations (filter, select, join, etc.) are not executed immediately. Instead, Snowpark builds an execution plan and only executes it when you call an action like `.collect()`, `.show()`, or `.count()`. This allows Snowpark to optimize the entire query before execution.

### Question 4: C
**Correct Answer: C) `.collect()`**

Explanation: The `.collect()` method executes the DataFrame operations and brings the results to the client as a list of Row objects. Other action methods include `.show()` (displays results), `.count()` (returns row count), and `.to_pandas()` (converts to Pandas DataFrame).

### Question 5: B
**Correct Answer: B) Computation happens in Snowflake without data movement**

Explanation: The primary benefit of Snowpark is that computation happens where the data lives (in Snowflake), eliminating the need to extract data to external systems like Python or Spark. This reduces data movement, improves performance, and simplifies architecture.

### Question 6: B
**Correct Answer: B) `df = session.table("table_name")`**

Explanation: The `session.table()` method creates a DataFrame from a Snowflake table. You can also use `session.sql()` to create a DataFrame from a SQL query. The session object is your connection to Snowflake.

### Question 7: B
**Correct Answer: B) Materializes and caches the DataFrame for reuse**

Explanation: `df.cache_result()` materializes the DataFrame (executes the query and stores results) and caches it for reuse. This is useful when you need to use the same DataFrame multiple times, as it avoids re-executing the query each time.

### Question 8: B
**Correct Answer: B) They use lazy evaluation and generate SQL**

Explanation: Snowpark DataFrames use lazy evaluation - operations are not executed immediately but instead build an execution plan. When an action is called, Snowpark generates optimized SQL and executes it in Snowflake. This is similar to how Spark DataFrames work.

### Question 9: C
**Correct Answer: C) `session.sproc.register()`**

Explanation: The `session.sproc.register()` method deploys a Python function as a stored procedure in Snowflake. You can then call this procedure using `session.call()` or the SQL `CALL` statement. This allows you to deploy reusable data processing logic.

### Question 10: C
**Correct Answer: C) For complex transformations requiring programming logic**

Explanation: Use Snowpark when you need complex transformations that benefit from programming constructs (loops, conditionals, functions), integration with Python libraries, or when you want to version control your data pipelines. For simple queries and aggregations, SQL is often simpler and more readable.

---

## Scoring Guide

- **9-10 correct**: Excellent! You understand Snowpark thoroughly.
- **7-8 correct**: Good job! Review the questions you missed.
- **5-6 correct**: Fair. Review the README.md and retry the exercises.
- **Below 5**: Review the material and complete the hands-on exercises again.

---

## Key Concepts to Remember

1. **Snowpark Fundamentals**
   - Developer framework for Python/Java/Scala
   - Code executes in Snowflake (not client)
   - Eliminates data movement
   - Leverages Snowflake's compute and optimization

2. **DataFrame API**
   - Similar to Pandas/Spark DataFrames
   - Lazy evaluation (operations build execution plan)
   - Actions trigger execution (.collect(), .show(), .count())
   - Generates optimized SQL

3. **Key Operations**
   - Create: `session.table()`, `session.sql()`
   - Transform: `.filter()`, `.select()`, `.with_column()`
   - Aggregate: `.group_by().agg()`
   - Join: `.join()`
   - Execute: `.collect()`, `.show()`, `.count()`
   - Write: `.write.save_as_table()`

4. **Lazy Evaluation**
   - Operations not executed immediately
   - Build execution plan
   - Execute when action is called
   - Allows optimization

5. **Performance**
   - Computation in Snowflake (no data movement)
   - Lazy evaluation enables optimization
   - Caching with `.cache_result()`
   - Pushdown optimization

6. **Deployment**
   - Stored procedures: `session.sproc.register()`
   - UDFs: `session.udf.register()`
   - Permanent or temporary
   - Specify packages and dependencies

7. **When to Use Snowpark**
   - Complex transformations
   - Programming logic needed
   - Integration with Python libraries
   - Version control for pipelines
   - CI/CD workflows

8. **When to Use SQL**
   - Simple queries
   - Ad-hoc analysis
   - Reporting
   - Team expertise is SQL
   - Readability is priority

---

## Exam Tips

1. **Remember execution location**: Snowpark code executes IN Snowflake, not on client.

2. **Lazy evaluation**: Operations build a plan, execution happens on action.

3. **Key methods**: `session.table()`, `.collect()`, `.write.save_as_table()`.

4. **Deployment**: `session.sproc.register()` for procedures, `session.udf.register()` for functions.

5. **Benefits**: No data movement, leverage Snowflake compute, integrate with Python libraries.

6. **Caching**: `.cache_result()` materializes and caches for reuse.

7. **Use cases**: Complex transformations, ML integration, programmatic workflows.

8. **Comparison**: Snowpark for complex logic, SQL for simple queries.

---

## Additional Practice

Try these scenarios:

1. **Scenario**: You need to process 10 TB of data with complex business logic. Should you extract to Python or use Snowpark?
   - **Answer**: Use Snowpark to avoid moving 10 TB of data and leverage Snowflake's compute.

2. **Scenario**: You're building a data pipeline that needs version control and CI/CD. What's the best approach?
   - **Answer**: Use Snowpark to write pipelines in Python, enabling version control and CI/CD.

3. **Scenario**: You need to apply a machine learning model to data in Snowflake. How?
   - **Answer**: Use Snowpark to load scikit-learn models and apply them as UDFs.

4. **Scenario**: You have a simple aggregation query. Should you use Snowpark or SQL?
   - **Answer**: SQL is simpler and more readable for basic aggregations.

5. **Scenario**: You're chaining multiple DataFrame operations. When does execution happen?
   - **Answer**: Execution happens when you call an action like `.collect()`, `.show()`, or `.count()`.

---

## Next Steps

- If you scored 8-10: Move to Day 25 (Hands-On Project Day)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and review Snowpark documentation

---

## Resources for Further Study

- [Snowflake Docs: Snowpark](https://docs.snowflake.com/en/developer-guide/snowpark/index)
- [Snowpark Python API Reference](https://docs.snowflake.com/en/developer-guide/snowpark/reference/python/index)
- [Snowpark Best Practices](https://docs.snowflake.com/en/developer-guide/snowpark/python/working-with-dataframes)
- [Snowpark for Python Tutorial](https://quickstarts.snowflake.com/guide/getting_started_with_snowpark_python/)

---

**Congratulations on completing Day 24!** 🎉

Tomorrow is Hands-On Project Day where you'll build a complete end-to-end data engineering project incorporating all concepts from the bootcamp!
