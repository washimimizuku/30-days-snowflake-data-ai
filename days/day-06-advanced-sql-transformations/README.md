# Day 6: Advanced SQL Transformations

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Master window functions for analytics
- Use QUALIFY clause for filtering window function results
- Implement lateral joins for complex transformations
- Parse and query JSON and semi-structured data
- Use table functions effectively
- Implement advanced aggregation patterns
- Understand recursive CTEs
- Apply advanced SQL patterns for data engineering

---

## Theory

### Window Functions

Window functions perform calculations across rows related to the current row without collapsing the result set.

#### Basic Syntax
```sql
function_name() OVER (
  [PARTITION BY column]
  [ORDER BY column]
  [ROWS/RANGE frame_specification]
)
```

#### Ranking Functions

```sql
-- ROW_NUMBER: Unique sequential number
SELECT 
  customer_id,
  order_date,
  amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as order_sequence
FROM orders;

-- RANK: Same rank for ties, gaps in sequence
SELECT 
  product_id,
  sales,
  RANK() OVER (ORDER BY sales DESC) as sales_rank
FROM product_sales;

-- DENSE_RANK: Same rank for ties, no gaps
SELECT 
  product_id,
  sales,
  DENSE_RANK() OVER (ORDER BY sales DESC) as sales_rank
FROM product_sales;

-- NTILE: Divide into N buckets
SELECT 
  customer_id,
  total_spent,
  NTILE(4) OVER (ORDER BY total_spent) as spending_quartile
FROM customer_totals;
```

#### Aggregate Window Functions

```sql
-- Running totals
SELECT 
  order_date,
  amount,
  SUM(amount) OVER (ORDER BY order_date) as running_total
FROM orders;

-- Moving averages
SELECT 
  order_date,
  amount,
  AVG(amount) OVER (
    ORDER BY order_date 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) as moving_avg_7day
FROM daily_sales;

-- Cumulative aggregations
SELECT 
  product_id,
  sale_date,
  quantity,
  SUM(quantity) OVER (
    PARTITION BY product_id 
    ORDER BY sale_date
  ) as cumulative_quantity
FROM sales;
```

#### Value Functions

```sql
-- LAG: Previous row value
SELECT 
  order_date,
  amount,
  LAG(amount, 1) OVER (ORDER BY order_date) as previous_day_amount,
  amount - LAG(amount, 1) OVER (ORDER BY order_date) as day_over_day_change
FROM daily_sales;

-- LEAD: Next row value
SELECT 
  order_date,
  amount,
  LEAD(amount, 1) OVER (ORDER BY order_date) as next_day_amount
FROM daily_sales;

-- FIRST_VALUE and LAST_VALUE
SELECT 
  order_date,
  amount,
  FIRST_VALUE(amount) OVER (ORDER BY order_date) as first_amount,
  LAST_VALUE(amount) OVER (
    ORDER BY order_date 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) as last_amount
FROM daily_sales;
```

### QUALIFY Clause

QUALIFY filters results based on window function results (like HAVING for window functions).

```sql
-- Get top 3 products per category
SELECT 
  category,
  product_name,
  sales,
  RANK() OVER (PARTITION BY category ORDER BY sales DESC) as rank
FROM product_sales
QUALIFY rank <= 3;

-- Get customers with above-average spending
SELECT 
  customer_id,
  total_spent,
  AVG(total_spent) OVER () as avg_spent
FROM customer_totals
QUALIFY total_spent > AVG(total_spent) OVER ();

-- Deduplication (keep most recent)
SELECT 
  customer_id,
  email,
  updated_at,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) as rn
FROM customer_updates
QUALIFY rn = 1;
```

### Lateral Joins

LATERAL allows a subquery to reference columns from preceding tables in the FROM clause.

```sql
-- Get top 3 orders for each customer
SELECT 
  c.customer_id,
  c.customer_name,
  o.order_id,
  o.amount
FROM customers c,
LATERAL (
  SELECT order_id, amount
  FROM orders
  WHERE customer_id = c.customer_id
  ORDER BY amount DESC
  LIMIT 3
) o;

-- Calculate running statistics
SELECT 
  product_id,
  sale_date,
  amount,
  stats.avg_amount,
  stats.max_amount
FROM sales s,
LATERAL (
  SELECT 
    AVG(amount) as avg_amount,
    MAX(amount) as max_amount
  FROM sales
  WHERE product_id = s.product_id
    AND sale_date <= s.sale_date
) stats;
```

### JSON and Semi-Structured Data

#### Parsing JSON

```sql
-- Extract JSON fields
SELECT 
  event_id,
  event_data:user_id::INT as user_id,
  event_data:action::STRING as action,
  event_data:timestamp::TIMESTAMP as event_time
FROM events;

-- Flatten nested JSON
SELECT 
  order_id,
  value:product_id::INT as product_id,
  value:quantity::INT as quantity,
  value:price::DECIMAL(10,2) as price
FROM orders,
LATERAL FLATTEN(input => order_data:items);

-- Parse JSON arrays
SELECT 
  customer_id,
  value::STRING as tag
FROM customers,
LATERAL FLATTEN(input => PARSE_JSON(tags));
```

#### JSON Functions

```sql
-- OBJECT_CONSTRUCT: Create JSON object
SELECT 
  customer_id,
  OBJECT_CONSTRUCT(
    'name', customer_name,
    'email', email,
    'tier', customer_tier
  ) as customer_json
FROM customers;

-- ARRAY_AGG: Create JSON array
SELECT 
  customer_id,
  ARRAY_AGG(OBJECT_CONSTRUCT('order_id', order_id, 'amount', amount)) as orders
FROM orders
GROUP BY customer_id;

-- JSON_EXTRACT_PATH_TEXT: Extract nested values
SELECT 
  JSON_EXTRACT_PATH_TEXT(event_data, 'user.profile.name') as user_name
FROM events;
```

### Table Functions

```sql
-- FLATTEN: Explode arrays
SELECT 
  order_id,
  f.value:product_id as product_id,
  f.value:quantity as quantity
FROM orders,
TABLE(FLATTEN(input => items)) f;

-- SPLIT_TO_TABLE: Split strings
SELECT 
  customer_id,
  value as tag
FROM customers,
TABLE(SPLIT_TO_TABLE(tags, ','));

-- GENERATOR: Generate rows
SELECT 
  ROW_NUMBER() OVER (ORDER BY SEQ4()) as id,
  DATEADD(day, SEQ4(), '2025-01-01'::DATE) as date
FROM TABLE(GENERATOR(ROWCOUNT => 365));
```

### Advanced Aggregation Patterns

#### GROUPING SETS

```sql
-- Multiple grouping levels in one query
SELECT 
  category,
  product_id,
  SUM(sales) as total_sales
FROM product_sales
GROUP BY GROUPING SETS (
  (category, product_id),  -- By category and product
  (category),              -- By category only
  ()                       -- Grand total
);
```

#### ROLLUP

```sql
-- Hierarchical aggregations
SELECT 
  year,
  quarter,
  month,
  SUM(sales) as total_sales
FROM sales
GROUP BY ROLLUP (year, quarter, month);
```

#### CUBE

```sql
-- All possible combinations
SELECT 
  region,
  product_category,
  SUM(sales) as total_sales
FROM sales
GROUP BY CUBE (region, product_category);
```

### Recursive CTEs

```sql
-- Hierarchical data (org chart)
WITH RECURSIVE org_hierarchy AS (
  -- Anchor: Top level
  SELECT 
    employee_id,
    manager_id,
    employee_name,
    1 as level
  FROM employees
  WHERE manager_id IS NULL
  
  UNION ALL
  
  -- Recursive: Next level
  SELECT 
    e.employee_id,
    e.manager_id,
    e.employee_name,
    oh.level + 1
  FROM employees e
  JOIN org_hierarchy oh ON e.manager_id = oh.employee_id
)
SELECT * FROM org_hierarchy;

-- Date series generation
WITH RECURSIVE date_series AS (
  SELECT '2025-01-01'::DATE as date
  UNION ALL
  SELECT DATEADD(day, 1, date)
  FROM date_series
  WHERE date < '2025-12-31'::DATE
)
SELECT * FROM date_series;
```

### Advanced Patterns

#### Pivoting Data

```sql
-- Pivot: Rows to columns
SELECT *
FROM (
  SELECT customer_id, product_category, sales
  FROM sales
)
PIVOT (
  SUM(sales)
  FOR product_category IN ('Electronics', 'Clothing', 'Food')
) AS pivoted;
```

#### Unpivoting Data

```sql
-- Unpivot: Columns to rows
SELECT *
FROM monthly_sales
UNPIVOT (
  sales FOR month IN (jan, feb, mar, apr, may, jun)
);
```

#### Gap and Island Detection

```sql
-- Find consecutive sequences
WITH numbered AS (
  SELECT 
    date,
    value,
    ROW_NUMBER() OVER (ORDER BY date) as rn,
    DATEADD(day, -ROW_NUMBER() OVER (ORDER BY date), date) as island_id
  FROM daily_data
  WHERE value > threshold
)
SELECT 
  island_id,
  MIN(date) as start_date,
  MAX(date) as end_date,
  COUNT(*) as consecutive_days
FROM numbered
GROUP BY island_id;
```

### Best Practices

**1. Window Functions**
- Use PARTITION BY to limit scope
- Always specify ORDER BY for deterministic results
- Use QUALIFY instead of subqueries when possible
- Consider performance with large datasets

**2. JSON Processing**
- Use VARIANT type for flexible JSON storage
- Index frequently queried JSON paths
- Use FLATTEN for arrays
- Consider materializing frequently accessed JSON fields

**3. CTEs**
- Use for readability and maintainability
- Name CTEs descriptively
- Consider performance vs. subqueries
- Use recursive CTEs for hierarchical data

**4. Performance**
- Add appropriate indexes
- Use clustering keys for large tables
- Limit window function scope with PARTITION BY
- Test query performance with realistic data volumes

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Window Functions
Practice ranking, running totals, and moving averages.

### Exercise 2: QUALIFY Clause
Use QUALIFY for filtering and deduplication.

### Exercise 3: Lateral Joins
Implement complex joins with LATERAL.

### Exercise 4: JSON Processing
Parse and query semi-structured data.

### Exercise 5: Table Functions
Use FLATTEN, SPLIT_TO_TABLE, and GENERATOR.

### Exercise 6: Advanced Aggregations
Implement GROUPING SETS, ROLLUP, and CUBE.

### Exercise 7: Recursive CTEs
Build hierarchical queries.

### Exercise 8: Real-World Patterns
Apply multiple techniques to solve complex problems.

---

## ✅ Quiz (5 min)

Answer these questions in `quiz.md`:

1. What's the difference between RANK() and DENSE_RANK()?
2. What does the QUALIFY clause do?
3. When would you use a LATERAL join?
4. How do you extract a field from JSON in Snowflake?
5. What does the FLATTEN function do?
6. What's the difference between ROLLUP and CUBE?
7. How do you create a recursive CTE?
8. What's the purpose of PARTITION BY in window functions?
9. How do you deduplicate data using window functions?
10. What's the difference between ROWS and RANGE in window frames?

---

## 🎯 Key Takeaways

- Window functions enable analytics without collapsing rows
- QUALIFY filters window function results (like HAVING)
- LATERAL joins allow subqueries to reference preceding tables
- JSON data can be queried with : notation and FLATTEN
- Table functions like FLATTEN and SPLIT_TO_TABLE transform data
- GROUPING SETS, ROLLUP, CUBE provide flexible aggregations
- Recursive CTEs handle hierarchical data
- Advanced SQL patterns solve complex data engineering problems
- Performance considerations are crucial for large datasets
- Combining techniques enables powerful transformations

---

## 📚 Additional Resources

- [Snowflake Docs: Window Functions](https://docs.snowflake.com/en/sql-reference/functions-analytic)
- [Snowflake Docs: QUALIFY](https://docs.snowflake.com/en/sql-reference/constructs/qualify)
- [Snowflake Docs: LATERAL](https://docs.snowflake.com/en/sql-reference/constructs/join-lateral)
- [Snowflake Docs: Semi-Structured Data](https://docs.snowflake.com/en/user-guide/semistructured-concepts)

---

## 🔜 Tomorrow: Day 7 - Week 1 Review & Mini-Project

We'll review all Week 1 concepts and build a complete end-to-end data pipeline combining everything learned.
