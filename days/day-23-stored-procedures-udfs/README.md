# Day 23: Stored Procedures & User-Defined Functions (UDFs)

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand stored procedures and UDFs in Snowflake
- Create stored procedures in JavaScript and SQL
- Build user-defined functions (UDFs) in multiple languages
- Understand scalar vs. table functions (UDTFs)
- Use stored procedures for complex business logic
- Optimize UDF and stored procedure performance
- Apply security best practices
- Choose the right approach for different scenarios

---

## Theory

### Stored Procedures vs. UDFs

**Stored Procedures:**
- Execute procedural logic (loops, conditionals, transactions)
- Can perform DML operations (INSERT, UPDATE, DELETE)
- Can call other procedures
- Return a single value or table
- Written in JavaScript, SQL, Python, Java, or Scala

**User-Defined Functions (UDFs):**
- Return a value based on input parameters
- Cannot perform DML operations
- Used in SELECT statements like built-in functions
- Scalar UDFs return single values
- Table UDFs (UDTFs) return tables
- Written in JavaScript, Python, Java, or Scala

```
Stored Procedure:
  Input → Complex Logic → DML Operations → Output

UDF:
  Input → Calculation → Output (no side effects)
```

### Stored Procedures

#### JavaScript Stored Procedures

Most common and flexible:

```sql
CREATE OR REPLACE PROCEDURE calculate_bonus(employee_id INT)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
  // JavaScript code
  var sql_command = "SELECT salary FROM employees WHERE id = " + EMPLOYEE_ID;
  var stmt = snowflake.createStatement({sqlText: sql_command});
  var result = stmt.execute();
  
  if (result.next()) {
    var salary = result.getColumnValue(1);
    var bonus = salary * 0.10;
    
    // Update bonus
    var update_sql = "UPDATE employees SET bonus = " + bonus + 
                     " WHERE id = " + EMPLOYEE_ID;
    snowflake.createStatement({sqlText: update_sql}).execute();
    
    return "Bonus calculated: $" + bonus;
  }
  return "Employee not found";
$$;

-- Call the procedure
CALL calculate_bonus(1001);
```

#### SQL Stored Procedures

Simpler syntax for SQL-only logic:

```sql
CREATE OR REPLACE PROCEDURE update_customer_tier()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Update customer tiers based on total purchases
  UPDATE customers
  SET tier = CASE
    WHEN total_purchases > 10000 THEN 'PLATINUM'
    WHEN total_purchases > 5000 THEN 'GOLD'
    WHEN total_purchases > 1000 THEN 'SILVER'
    ELSE 'BRONZE'
  END;
  
  RETURN 'Customer tiers updated';
END;
$$;

CALL update_customer_tier();
```

#### Python Stored Procedures

For complex data processing:

```sql
CREATE OR REPLACE PROCEDURE analyze_sales_trends()
RETURNS TABLE(month DATE, trend STRING)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('pandas', 'numpy')
HANDLER = 'analyze_trends'
AS
$$
import pandas as pd
import numpy as np

def analyze_trends(session):
    # Query data
    df = session.sql("SELECT * FROM sales").to_pandas()
    
    # Analyze trends
    monthly = df.groupby(pd.Grouper(key='sale_date', freq='M')).sum()
    monthly['trend'] = np.where(monthly['amount'].pct_change() > 0, 'UP', 'DOWN')
    
    return monthly[['trend']]
$$;

CALL analyze_sales_trends();
```

### User-Defined Functions (UDFs)

#### Scalar UDFs

Return a single value:

```sql
-- JavaScript UDF
CREATE OR REPLACE FUNCTION calculate_tax(amount FLOAT, rate FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
AS
$$
  return AMOUNT * RATE;
$$;

-- Use in query
SELECT 
  order_id,
  amount,
  calculate_tax(amount, 0.08) as tax,
  amount + calculate_tax(amount, 0.08) as total
FROM orders;
```

#### SQL UDFs

Simplest form:

```sql
CREATE OR REPLACE FUNCTION full_name(first STRING, last STRING)
RETURNS STRING
AS
$$
  first || ' ' || last
$$;

SELECT full_name(first_name, last_name) as name
FROM employees;
```

#### Python UDFs

For complex calculations:

```sql
CREATE OR REPLACE FUNCTION sentiment_score(text STRING)
RETURNS FLOAT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'calculate_sentiment'
AS
$$
def calculate_sentiment(text):
    # Simple sentiment analysis
    positive_words = ['good', 'great', 'excellent', 'amazing']
    negative_words = ['bad', 'terrible', 'awful', 'poor']
    
    text_lower = text.lower()
    pos_count = sum(word in text_lower for word in positive_words)
    neg_count = sum(word in text_lower for word in negative_words)
    
    if pos_count + neg_count == 0:
        return 0.0
    return (pos_count - neg_count) / (pos_count + neg_count)
$$;

SELECT 
  comment_id,
  comment_text,
  sentiment_score(comment_text) as sentiment
FROM customer_comments;
```

### Table Functions (UDTFs)

Return multiple rows:

```sql
CREATE OR REPLACE FUNCTION split_string(input STRING, delimiter STRING)
RETURNS TABLE(value STRING)
LANGUAGE JAVASCRIPT
AS
$$
{
  processRow: function(row, rowWriter, context) {
    var parts = row.INPUT.split(row.DELIMITER);
    for (var i = 0; i < parts.length; i++) {
      rowWriter.writeRow({VALUE: parts[i]});
    }
  }
}
$$;

-- Use in query
SELECT value
FROM TABLE(split_string('apple,banana,orange', ','));
```

### Secure UDFs

Protect sensitive logic:

```sql
CREATE OR REPLACE SECURE FUNCTION calculate_commission(sales FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
AS
$$
  // Commission logic hidden from users
  if (SALES < 10000) return SALES * 0.05;
  if (SALES < 50000) return SALES * 0.08;
  return SALES * 0.10;
$$;

-- Users can call but can't see the logic
SELECT 
  salesperson_id,
  total_sales,
  calculate_commission(total_sales) as commission
FROM sales_summary;
```

### Practical Examples

#### Example 1: Data Quality Procedure

```sql
CREATE OR REPLACE PROCEDURE check_data_quality(table_name STRING)
RETURNS TABLE(check_name STRING, status STRING, details STRING)
LANGUAGE JAVASCRIPT
AS
$$
  var results = [];
  
  // Check for null values
  var null_check = `
    SELECT COUNT(*) as null_count 
    FROM ${TABLE_NAME} 
    WHERE id IS NULL
  `;
  var stmt = snowflake.createStatement({sqlText: null_check});
  var result = stmt.execute();
  result.next();
  var null_count = result.getColumnValue(1);
  
  results.push({
    CHECK_NAME: 'Null ID Check',
    STATUS: null_count == 0 ? 'PASS' : 'FAIL',
    DETAILS: `Found ${null_count} null IDs`
  });
  
  // Check for duplicates
  var dup_check = `
    SELECT COUNT(*) - COUNT(DISTINCT id) as dup_count 
    FROM ${TABLE_NAME}
  `;
  stmt = snowflake.createStatement({sqlText: dup_check});
  result = stmt.execute();
  result.next();
  var dup_count = result.getColumnValue(1);
  
  results.push({
    CHECK_NAME: 'Duplicate Check',
    STATUS: dup_count == 0 ? 'PASS' : 'FAIL',
    DETAILS: `Found ${dup_count} duplicates`
  });
  
  return results;
$$;

CALL check_data_quality('customers');
```

#### Example 2: ETL Orchestration Procedure

```sql
CREATE OR REPLACE PROCEDURE run_daily_etl()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  rows_processed INT;
  error_msg STRING;
BEGIN
  -- Step 1: Load staging data
  INSERT INTO staging_sales
  SELECT * FROM external_sales_table
  WHERE load_date = CURRENT_DATE();
  
  rows_processed := SQLROWCOUNT;
  
  -- Step 2: Data quality checks
  DELETE FROM staging_sales
  WHERE amount < 0 OR customer_id IS NULL;
  
  -- Step 3: Load to production
  MERGE INTO sales s
  USING staging_sales st
  ON s.sale_id = st.sale_id
  WHEN MATCHED THEN
    UPDATE SET amount = st.amount, updated_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN
    INSERT VALUES (st.sale_id, st.customer_id, st.amount, CURRENT_TIMESTAMP());
  
  -- Step 4: Log success
  INSERT INTO etl_log VALUES (
    CURRENT_TIMESTAMP(),
    'daily_etl',
    'SUCCESS',
    rows_processed
  );
  
  RETURN 'ETL completed successfully. Rows processed: ' || rows_processed;
  
EXCEPTION
  WHEN OTHER THEN
    error_msg := SQLERRM;
    INSERT INTO etl_log VALUES (
      CURRENT_TIMESTAMP(),
      'daily_etl',
      'FAILED',
      error_msg
    );
    RETURN 'ETL failed: ' || error_msg;
END;
$$;

CALL run_daily_etl();
```

#### Example 3: Custom Aggregation UDF

```sql
CREATE OR REPLACE FUNCTION weighted_average(values ARRAY, weights ARRAY)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
AS
$$
  if (VALUES.length !== WEIGHTS.length) {
    return null;
  }
  
  var sum = 0;
  var weight_sum = 0;
  
  for (var i = 0; i < VALUES.length; i++) {
    sum += VALUES[i] * WEIGHTS[i];
    weight_sum += WEIGHTS[i];
  }
  
  return weight_sum > 0 ? sum / weight_sum : null;
$$;

-- Use in query
SELECT 
  student_id,
  weighted_average(
    ARRAY_CONSTRUCT(exam1, exam2, final_exam),
    ARRAY_CONSTRUCT(0.3, 0.3, 0.4)
  ) as final_grade
FROM student_scores;
```

### Performance Optimization

#### 1. Minimize SQL Calls in Procedures

```sql
-- Bad: Multiple SQL calls
CREATE OR REPLACE PROCEDURE update_orders_bad()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
  var stmt = snowflake.createStatement({
    sqlText: "SELECT order_id FROM orders"
  });
  var result = stmt.execute();
  
  while (result.next()) {
    var order_id = result.getColumnValue(1);
    // Separate update for each order (slow!)
    snowflake.createStatement({
      sqlText: `UPDATE orders SET processed = TRUE WHERE order_id = ${order_id}`
    }).execute();
  }
  return "Done";
$$;

-- Good: Single SQL statement
CREATE OR REPLACE PROCEDURE update_orders_good()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  UPDATE orders SET processed = TRUE;
  RETURN 'Done';
END;
$$;
```

#### 2. Use Batch Operations

```sql
-- Process in batches
CREATE OR REPLACE PROCEDURE process_large_table()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  batch_size INT DEFAULT 10000;
  total_processed INT DEFAULT 0;
  rows_affected INT;
BEGIN
  LOOP
    -- Process batch
    UPDATE large_table
    SET processed = TRUE
    WHERE processed = FALSE
    LIMIT batch_size;
    
    rows_affected := SQLROWCOUNT;
    total_processed := total_processed + rows_affected;
    
    -- Exit if no more rows
    IF (rows_affected = 0) THEN
      BREAK;
    END IF;
  END LOOP;
  
  RETURN 'Processed ' || total_processed || ' rows';
END;
$$;
```

#### 3. Cache Results in UDFs

```sql
-- Cache expensive calculations
CREATE OR REPLACE FUNCTION fibonacci(n INT)
RETURNS INT
LANGUAGE JAVASCRIPT
MEMOIZABLE
AS
$$
  if (N <= 1) return N;
  return fibonacci(N-1) + fibonacci(N-2);
$$;
```

### Security Best Practices

#### 1. Use Caller's Rights

```sql
-- Execute with caller's privileges
CREATE OR REPLACE PROCEDURE sensitive_operation()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
  -- Uses caller's privileges
  DELETE FROM sensitive_table WHERE id = 123;
  RETURN 'Done';
END;
$$;
```

#### 2. Use Owner's Rights for Elevated Access

```sql
-- Execute with owner's privileges
CREATE OR REPLACE PROCEDURE admin_operation()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
  -- Uses owner's privileges (typically higher)
  GRANT SELECT ON sensitive_table TO ROLE analyst;
  RETURN 'Done';
END;
$$;
```

#### 3. Secure UDFs

```sql
-- Hide implementation details
CREATE OR REPLACE SECURE FUNCTION proprietary_calculation(input FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
AS
$$
  // Proprietary logic hidden from users
  return INPUT * 1.23456 + 789.01;
$$;
```

### Error Handling

#### Stored Procedures

```sql
CREATE OR REPLACE PROCEDURE safe_update(table_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  error_msg STRING;
BEGIN
  EXECUTE IMMEDIATE 'UPDATE ' || table_name || ' SET updated = TRUE';
  RETURN 'Success';
EXCEPTION
  WHEN STATEMENT_ERROR THEN
    error_msg := SQLERRM;
    INSERT INTO error_log VALUES (CURRENT_TIMESTAMP(), error_msg);
    RETURN 'Failed: ' || error_msg;
  WHEN OTHER THEN
    RETURN 'Unknown error occurred';
END;
$$;
```

#### JavaScript Error Handling

```sql
CREATE OR REPLACE PROCEDURE safe_operation()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
  try {
    var stmt = snowflake.createStatement({
      sqlText: "SELECT * FROM non_existent_table"
    });
    stmt.execute();
    return "Success";
  } catch (err) {
    return "Error: " + err.message;
  }
$$;
```

### Best Practices

**1. Choose the Right Tool**
- Simple calculations → SQL UDFs
- Complex logic → JavaScript/Python UDFs
- DML operations → Stored Procedures
- ETL orchestration → SQL Stored Procedures

**2. Naming Conventions**
```sql
-- Procedures: verb_noun
CREATE PROCEDURE calculate_bonus(...);
CREATE PROCEDURE update_inventory(...);

-- Functions: noun or adjective
CREATE FUNCTION tax_amount(...);
CREATE FUNCTION is_valid_email(...);
```

**3. Documentation**
```sql
CREATE OR REPLACE PROCEDURE complex_operation()
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Performs daily ETL: loads staging, validates, merges to production'
AS
$$
BEGIN
  -- Implementation
END;
$$;
```

**4. Testing**
```sql
-- Create test procedures
CREATE OR REPLACE PROCEDURE test_calculate_bonus()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Test case 1
  CALL calculate_bonus(1001);
  -- Verify results
  -- Test case 2
  CALL calculate_bonus(1002);
  -- Verify results
  RETURN 'All tests passed';
END;
$$;
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: JavaScript Stored Procedures
Create procedures with complex logic.

### Exercise 2: SQL Stored Procedures
Build ETL orchestration procedures.

### Exercise 3: Scalar UDFs
Create custom functions for calculations.

### Exercise 4: Table Functions (UDTFs)
Build functions that return multiple rows.

### Exercise 5: Python UDFs
Implement complex data processing.

### Exercise 6: Secure Functions
Protect proprietary logic.

### Exercise 7: Error Handling
Implement robust error handling.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Stored procedures execute procedural logic and can perform DML
- UDFs return values and cannot perform DML operations
- JavaScript is most flexible for stored procedures
- SQL procedures are simpler for SQL-only logic
- Python UDFs enable complex data processing
- Scalar UDFs return single values, UDTFs return tables
- Secure UDFs hide implementation details
- Use EXECUTE AS CALLER/OWNER for security control
- Minimize SQL calls in procedures for performance
- Choose the right tool for the job

---

## 📚 Additional Resources

- [Snowflake Docs: Stored Procedures](https://docs.snowflake.com/en/sql-reference/stored-procedures)
- [JavaScript Stored Procedures](https://docs.snowflake.com/en/sql-reference/stored-procedures-javascript)
- [User-Defined Functions](https://docs.snowflake.com/en/sql-reference/udf-overview)
- [Python UDFs](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python)

---

## 🔜 Tomorrow: Day 24 - Snowpark for Data Engineering

We'll learn about Snowpark, Snowflake's developer framework for building data pipelines in Python, Java, and Scala.
