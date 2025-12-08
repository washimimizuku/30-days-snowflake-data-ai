# Day 23 Quiz: Stored Procedures & User-Defined Functions

## Instructions
- 10 multiple choice questions
- Choose the best answer for each question
- Answers and explanations at the end
- Passing score: 7/10 (70%)

---

## Questions

### Question 1
What is the main difference between stored procedures and UDFs in Snowflake?

A) Stored procedures are faster than UDFs  
B) Stored procedures can perform DML operations, UDFs cannot  
C) UDFs can only be written in JavaScript  
D) Stored procedures cannot return values

### Question 2
Which language provides the MOST flexibility for stored procedures in Snowflake?

A) SQL  
B) JavaScript  
C) Python  
D) Java

### Question 3
What does a scalar UDF return?

A) Multiple rows  
B) A table  
C) A single value  
D) An array of values

### Question 4
Which keyword makes a UDF hide its implementation details from users?

A) PRIVATE  
B) HIDDEN  
C) SECURE  
D) PROTECTED

### Question 5
What is a UDTF (User-Defined Table Function)?

A) A function that creates tables  
B) A function that returns multiple rows  
C) A function that updates tables  
D) A function that drops tables

### Question 6
Which execution mode runs a stored procedure with the caller's privileges?

A) EXECUTE AS CALLER  
B) EXECUTE AS OWNER  
C) EXECUTE AS ADMIN  
D) EXECUTE AS USER

### Question 7
Can UDFs perform INSERT, UPDATE, or DELETE operations?

A) Yes, all UDFs can perform DML  
B) Only JavaScript UDFs can  
C) Only Python UDFs can  
D) No, UDFs cannot perform DML operations

### Question 8
What is the MEMOIZABLE keyword used for in UDFs?

A) To cache function results for better performance  
B) To make the function secure  
C) To enable parallel execution  
D) To allow DML operations

### Question 9
Which is the BEST choice for simple calculations that don't require complex logic?

A) JavaScript stored procedure  
B) Python UDF  
C) SQL UDF  
D) Java UDF

### Question 10
How do you call a stored procedure in Snowflake?

A) `SELECT procedure_name();`  
B) `EXECUTE procedure_name();`  
C) `CALL procedure_name();`  
D) `RUN procedure_name();`

---

## Answer Key

### Question 1: B
**Correct Answer: B) Stored procedures can perform DML operations, UDFs cannot**

Explanation: The fundamental difference is that stored procedures can perform DML operations (INSERT, UPDATE, DELETE) and have side effects, while UDFs are pure functions that only return values based on inputs without modifying data. This makes stored procedures suitable for data manipulation and UDFs suitable for calculations.

### Question 2: B
**Correct Answer: B) JavaScript**

Explanation: JavaScript provides the most flexibility for stored procedures in Snowflake. It supports complex logic, loops, conditionals, dynamic SQL, and can handle various data types. While SQL procedures are simpler for SQL-only logic and Python/Java are available, JavaScript is the most commonly used and flexible option.

### Question 3: C
**Correct Answer: C) A single value**

Explanation: A scalar UDF returns a single value (like a number, string, or date) for each input row. This is in contrast to table functions (UDTFs) which return multiple rows. Scalar UDFs are used like built-in functions in SELECT statements.

### Question 4: C
**Correct Answer: C) SECURE**

Explanation: The SECURE keyword makes a UDF hide its implementation details from users. Users can call the function and see results, but they cannot view the function's definition or logic. This is useful for protecting proprietary algorithms or sensitive business logic.

### Question 5: B
**Correct Answer: B) A function that returns multiple rows**

Explanation: A UDTF (User-Defined Table Function) returns multiple rows, effectively returning a table. UDTFs are used in the FROM clause with the TABLE() function. They're useful for operations like splitting strings, generating sequences, or exploding arrays.

### Question 6: A
**Correct Answer: A) EXECUTE AS CALLER**

Explanation: EXECUTE AS CALLER runs the stored procedure with the caller's privileges. This means the procedure can only access objects that the calling user has permissions for. The alternative is EXECUTE AS OWNER, which runs with the procedure owner's privileges (typically higher).

### Question 7: D
**Correct Answer: D) No, UDFs cannot perform DML operations**

Explanation: UDFs (User-Defined Functions) cannot perform DML operations regardless of the language they're written in. UDFs are designed to be pure functions that return values without side effects. If you need to perform DML operations, you must use a stored procedure instead.

### Question 8: A
**Correct Answer: A) To cache function results for better performance**

Explanation: The MEMOIZABLE keyword enables caching of function results. When a function is called with the same inputs multiple times, Snowflake can return the cached result instead of re-executing the function. This significantly improves performance for expensive calculations, especially with recursive functions like Fibonacci.

### Question 9: C
**Correct Answer: C) SQL UDF**

Explanation: SQL UDFs are the best choice for simple calculations. They have the simplest syntax, best performance for SQL operations, and are easiest to maintain. JavaScript/Python UDFs should be used only when you need complex logic that can't be expressed in SQL.

### Question 10: C
**Correct Answer: C) `CALL procedure_name();`**

Explanation: The CALL statement is used to execute stored procedures in Snowflake. For example: `CALL my_procedure(param1, param2);`. This is different from functions, which are called directly in SELECT statements or other SQL expressions.

---

## Scoring Guide

- **9-10 correct**: Excellent! You understand stored procedures and UDFs thoroughly.
- **7-8 correct**: Good job! Review the questions you missed.
- **5-6 correct**: Fair. Review the README.md and retry the exercises.
- **Below 5**: Review the material and complete the hands-on exercises again.

---

## Key Concepts to Remember

1. **Stored Procedures vs. UDFs**
   - Procedures: Can perform DML, have side effects
   - UDFs: Return values only, no side effects
   - Procedures: Called with CALL
   - UDFs: Used in SELECT statements

2. **Languages**
   - JavaScript: Most flexible, most common
   - SQL: Simplest for SQL-only logic
   - Python: Complex data processing, ML
   - Java/Scala: Enterprise applications

3. **UDF Types**
   - Scalar UDF: Returns single value
   - Table UDF (UDTF): Returns multiple rows
   - Secure UDF: Hides implementation

4. **Security**
   - EXECUTE AS CALLER: Uses caller's privileges
   - EXECUTE AS OWNER: Uses owner's privileges
   - SECURE: Hides function definition

5. **Performance**
   - MEMOIZABLE: Cache results
   - Minimize SQL calls in procedures
   - Use batch operations
   - SQL UDFs faster than JavaScript for simple logic

6. **Best Practices**
   - Choose right tool for the job
   - Implement error handling
   - Document your code
   - Test thoroughly
   - Use secure functions for proprietary logic

7. **When to Use What**
   - Simple calculation → SQL UDF
   - Complex logic → JavaScript UDF
   - Data processing → Python UDF
   - DML operations → Stored Procedure
   - ETL orchestration → SQL Stored Procedure

8. **Error Handling**
   - Use EXCEPTION blocks in SQL procedures
   - Use try-catch in JavaScript procedures
   - Log errors for troubleshooting
   - Return meaningful error messages

---

## Exam Tips

1. **Remember the limitations**: UDFs cannot perform DML operations.

2. **Know the languages**: JavaScript is most flexible, SQL is simplest.

3. **Understand SECURE**: Hides implementation, not about access control.

4. **EXECUTE AS**: CALLER uses caller's privileges, OWNER uses owner's.

5. **MEMOIZABLE**: Caches results for performance.

6. **UDTF usage**: Used with TABLE() in FROM clause.

7. **CALL vs SELECT**: CALL for procedures, SELECT for functions.

8. **Choose wisely**: SQL UDF for simple, JavaScript/Python for complex.

---

## Additional Practice

Try these scenarios:

1. **Scenario**: You need to calculate a complex commission formula that's proprietary. What should you use?
   - **Answer**: Secure JavaScript UDF to hide the formula.

2. **Scenario**: You need to orchestrate a multi-step ETL process with error handling. What's best?
   - **Answer**: SQL stored procedure with EXCEPTION blocks.

3. **Scenario**: You need to split a comma-separated string into multiple rows. What should you use?
   - **Answer**: UDTF (User-Defined Table Function).

4. **Scenario**: You need to calculate tax on salary using a simple formula. What's most efficient?
   - **Answer**: SQL UDF for simplicity and performance.

5. **Scenario**: You need to update employee bonuses based on performance. What should you use?
   - **Answer**: Stored procedure (can perform UPDATE operations).

---

## Next Steps

- If you scored 8-10: Move to Day 24 (Snowpark for Data Engineering)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

---

## Resources for Further Study

- [Snowflake Docs: Stored Procedures](https://docs.snowflake.com/en/sql-reference/stored-procedures)
- [JavaScript Stored Procedures](https://docs.snowflake.com/en/sql-reference/stored-procedures-javascript)
- [User-Defined Functions](https://docs.snowflake.com/en/sql-reference/udf-overview)
- [Python UDFs](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python)

---

**Congratulations on completing Day 23!** 🎉

Tomorrow, we'll explore Snowpark, Snowflake's developer framework for building data pipelines in Python, Java, and Scala.
