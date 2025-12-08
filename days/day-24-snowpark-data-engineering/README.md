# Day 24: Snowpark for Data Engineering

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowpark and its benefits
- Use Snowpark DataFrame API for data transformations
- Build data pipelines with Snowpark Python
- Create and deploy Snowpark stored procedures
- Understand Snowpark optimization techniques
- Compare Snowpark vs. traditional SQL approaches
- Apply best practices for Snowpark development
- Integrate Snowpark with data engineering workflows

---

## Theory

### What is Snowpark?

**Snowpark** is Snowflake's developer framework that brings data processing to the data, allowing you to write code in Python, Java, or Scala that executes directly in Snowflake.

**Key Benefits:**
- Write data pipelines in familiar languages (Python, Java, Scala)
- Execute code directly in Snowflake (no data movement)
- Leverage Snowflake's compute and optimization
- Use DataFrames for intuitive data manipulation
- Deploy as stored procedures or UDFs
- Integrate with ML libraries and frameworks

```
Traditional Approach:
Snowflake → Extract Data → Python/Spark → Transform → Load Back

Snowpark Approach:
Python Code → Snowpark → Execute in Snowflake → Results
```

### Snowpark Architecture

```
Your Python Code
      ↓
Snowpark DataFrame API
      ↓
Lazy Evaluation & Optimization
      ↓
SQL Generation
      ↓
Snowflake Execution Engine
      ↓
Results
```

**Key Concepts:**
- **Lazy Evaluation**: Operations are not executed until results are needed
- **Pushdown**: Computation happens in Snowflake, not client
- **Optimization**: Snowpark optimizes operations before execution
- **DataFrame API**: Familiar interface for data manipulation

### Setting Up Snowpark

#### Installation

```bash
# Install Snowpark Python
pip install snowflake-snowpark-python

# With pandas support
pip install "snowflake-snowpark-python[pandas]"

# With ML libraries
pip install "snowflake-snowpark-python[pandas]" scikit-learn
```

#### Connection

```python
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, sum, avg

# Create session
connection_parameters = {
    "account": "your_account",
    "user": "your_user",
    "password": "your_password",
    "role": "your_role",
    "warehouse": "your_warehouse",
    "database": "your_database",
    "schema": "your_schema"
}

session = Session.builder.configs(connection_parameters).create()
```

### Snowpark DataFrame API

#### Creating DataFrames

```python
# From table
df = session.table("customers")

# From SQL
df = session.sql("SELECT * FROM customers WHERE region = 'NORTH'")

# From values
from snowflake.snowpark.types import StructType, StructField, StringType, IntegerType

schema = StructType([
    StructField("id", IntegerType()),
    StructField("name", StringType())
])

data = [(1, "Alice"), (2, "Bob")]
df = session.create_dataframe(data, schema=schema)
```

#### Basic Operations

```python
# Select columns
df = df.select("customer_id", "customer_name", "total_purchases")

# Filter rows
df = df.filter(col("total_purchases") > 1000)

# Add computed column
df = df.with_column("tier", 
    when(col("total_purchases") > 10000, "PLATINUM")
    .when(col("total_purchases") > 5000, "GOLD")
    .otherwise("SILVER")
)

# Rename column
df = df.with_column_renamed("customer_name", "name")

# Drop column
df = df.drop("old_column")

# Sort
df = df.sort(col("total_purchases").desc())

# Limit
df = df.limit(10)
```

#### Aggregations

```python
# Group by and aggregate
df_agg = df.group_by("region").agg([
    sum("total_purchases").alias("total_sales"),
    avg("total_purchases").alias("avg_sales"),
    count("customer_id").alias("customer_count")
])

# Multiple aggregations
df_agg = df.group_by("region", "tier").agg([
    sum("total_purchases").alias("total_sales"),
    count("*").alias("count")
])
```

#### Joins

```python
# Inner join
customers = session.table("customers")
orders = session.table("orders")

result = customers.join(
    orders,
    customers["customer_id"] == orders["customer_id"],
    "inner"
)

# Left join
result = customers.join(
    orders,
    customers["customer_id"] == orders["customer_id"],
    "left"
)

# Multiple conditions
result = customers.join(
    orders,
    (customers["customer_id"] == orders["customer_id"]) &
    (customers["region"] == orders["region"]),
    "inner"
)
```

#### Window Functions

```python
from snowflake.snowpark.window import Window

# Define window
window = Window.partition_by("region").order_by(col("total_purchases").desc())

# Apply window function
df = df.with_column("rank", row_number().over(window))
df = df.with_column("running_total", sum("total_purchases").over(window))
```

### Executing and Collecting Results

```python
# Show first rows (executes query)
df.show()

# Collect all results to Python
results = df.collect()
for row in results:
    print(row["customer_id"], row["customer_name"])

# Convert to Pandas
pandas_df = df.to_pandas()

# Count rows
count = df.count()

# Write to table
df.write.mode("overwrite").save_as_table("customer_summary")

# Append to table
df.write.mode("append").save_as_table("customer_summary")
```

### Practical Example: ETL Pipeline

```python
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, sum, avg, when, current_timestamp

def run_customer_etl(session: Session):
    """
    ETL pipeline to process customer data
    """
    # Extract: Read from source tables
    customers = session.table("raw_customers")
    orders = session.table("raw_orders")
    
    # Transform: Calculate customer metrics
    customer_metrics = orders.group_by("customer_id").agg([
        sum("amount").alias("total_purchases"),
        count("order_id").alias("order_count"),
        avg("amount").alias("avg_order_value")
    ])
    
    # Join with customer data
    enriched = customers.join(
        customer_metrics,
        customers["customer_id"] == customer_metrics["customer_id"],
        "left"
    ).select(
        customers["customer_id"],
        customers["customer_name"],
        customers["email"],
        customers["region"],
        customer_metrics["total_purchases"],
        customer_metrics["order_count"],
        customer_metrics["avg_order_value"]
    )
    
    # Add tier classification
    final = enriched.with_column("tier",
        when(col("total_purchases") > 10000, "PLATINUM")
        .when(col("total_purchases") > 5000, "GOLD")
        .when(col("total_purchases") > 1000, "SILVER")
        .otherwise("BRONZE")
    ).with_column("processed_at", current_timestamp())
    
    # Load: Write to target table
    final.write.mode("overwrite").save_as_table("customer_summary")
    
    return f"Processed {final.count()} customers"

# Run the pipeline
result = run_customer_etl(session)
print(result)
```

### Snowpark Stored Procedures

Deploy Snowpark code as stored procedures:

```python
# Define the procedure
def calculate_customer_metrics(session: Session, region: str) -> str:
    """
    Calculate metrics for customers in a specific region
    """
    df = session.table("customers").filter(col("region") == region)
    
    metrics = df.agg([
        count("customer_id").alias("customer_count"),
        sum("total_purchases").alias("total_sales"),
        avg("total_purchases").alias("avg_sales")
    ]).collect()[0]
    
    return f"Region: {region}, Customers: {metrics['CUSTOMER_COUNT']}, " \
           f"Total Sales: ${metrics['TOTAL_SALES']}, " \
           f"Avg Sales: ${metrics['AVG_SALES']}"

# Register as stored procedure
session.sproc.register(
    func=calculate_customer_metrics,
    name="calculate_customer_metrics",
    packages=["snowflake-snowpark-python"],
    is_permanent=True,
    stage_location="@my_stage",
    replace=True
)

# Call the procedure
result = session.call("calculate_customer_metrics", "NORTH")
print(result)
```

### Snowpark UDFs

Create custom functions:

```python
from snowflake.snowpark.types import IntegerType

# Define UDF
def calculate_discount(tier: str) -> float:
    """Calculate discount based on customer tier"""
    discounts = {
        "PLATINUM": 0.20,
        "GOLD": 0.15,
        "SILVER": 0.10,
        "BRONZE": 0.05
    }
    return discounts.get(tier, 0.0)

# Register UDF
calculate_discount_udf = session.udf.register(
    func=calculate_discount,
    name="calculate_discount",
    packages=["snowflake-snowpark-python"],
    is_permanent=True,
    stage_location="@my_stage",
    replace=True
)

# Use UDF in DataFrame
df = session.table("customers")
df = df.with_column("discount", calculate_discount_udf(col("tier")))
df.show()
```

### Working with Pandas

```python
# Read Snowflake table to Pandas
pandas_df = session.table("customers").to_pandas()

# Process with Pandas
pandas_df["full_name"] = pandas_df["first_name"] + " " + pandas_df["last_name"]

# Write Pandas DataFrame to Snowflake
session.write_pandas(
    pandas_df,
    table_name="customers_processed",
    auto_create_table=True,
    overwrite=True
)
```

### Performance Optimization

#### 1. Lazy Evaluation

```python
# Operations are not executed until needed
df = session.table("large_table")
df = df.filter(col("amount") > 1000)  # Not executed yet
df = df.select("customer_id", "amount")  # Not executed yet

# Execution happens here
results = df.collect()  # Now all operations execute
```

#### 2. Caching

```python
# Cache DataFrame for reuse
df = session.table("customers")
df = df.cache_result()  # Materialize and cache

# Use cached DataFrame multiple times
count = df.count()
summary = df.group_by("region").count()
```

#### 3. Pushdown Optimization

```python
# Good: Filter before join (pushdown to Snowflake)
customers = session.table("customers").filter(col("region") == "NORTH")
orders = session.table("orders").filter(col("order_date") > "2024-01-01")
result = customers.join(orders, "customer_id")

# Bad: Collect then filter (brings data to client)
customers = session.table("customers").collect()  # Avoid!
filtered = [c for c in customers if c["region"] == "NORTH"]
```

#### 4. Batch Operations

```python
# Good: Single write operation
df.write.mode("overwrite").save_as_table("target")

# Bad: Row-by-row operations
for row in df.collect():  # Avoid!
    session.sql(f"INSERT INTO target VALUES (...)").collect()
```

### Best Practices

**1. Use Lazy Evaluation**
```python
# Chain operations before collecting
result = (session.table("customers")
    .filter(col("region") == "NORTH")
    .select("customer_id", "total_purchases")
    .sort(col("total_purchases").desc())
    .limit(10)
    .collect())  # Execute once
```

**2. Minimize Data Movement**
```python
# Good: Process in Snowflake
df = session.table("large_table")
summary = df.group_by("category").agg(sum("amount"))
summary.write.save_as_table("summary")

# Bad: Bring to Python
data = session.table("large_table").to_pandas()  # Avoid for large data
summary = data.groupby("category")["amount"].sum()
```

**3. Use Appropriate Data Types**
```python
from snowflake.snowpark.types import *

schema = StructType([
    StructField("id", IntegerType()),
    StructField("amount", DecimalType(10, 2)),
    StructField("date", DateType()),
    StructField("name", StringType())
])
```

**4. Error Handling**
```python
try:
    df = session.table("customers")
    result = df.filter(col("amount") > 1000).collect()
except Exception as e:
    print(f"Error: {e}")
    # Handle error appropriately
```

**5. Resource Management**
```python
# Always close session when done
try:
    session = Session.builder.configs(connection_parameters).create()
    # Do work
    result = session.table("customers").count()
finally:
    session.close()
```

### Snowpark vs. SQL

**When to Use Snowpark:**
- Complex data transformations requiring programming logic
- Integration with Python libraries (pandas, scikit-learn)
- Reusable data pipeline components
- CI/CD and version control for data pipelines
- Programmatic workflow orchestration

**When to Use SQL:**
- Simple queries and aggregations
- Ad-hoc analysis
- Reporting and dashboards
- When SQL is more readable
- Team expertise is primarily SQL

**Hybrid Approach:**
```python
# Use SQL for simple operations
df = session.sql("""
    SELECT customer_id, SUM(amount) as total
    FROM orders
    WHERE order_date >= '2024-01-01'
    GROUP BY customer_id
""")

# Use Snowpark for complex logic
df = df.with_column("tier",
    when(col("total") > 10000, "PLATINUM")
    .when(col("total") > 5000, "GOLD")
    .otherwise("SILVER")
)

# Continue with Snowpark transformations
result = df.filter(col("tier") == "PLATINUM")
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql` (conceptual exercises since Snowpark requires Python environment).

### Exercise 1: DataFrame Basics
Understand DataFrame creation and basic operations.

### Exercise 2: Transformations
Practice filtering, selecting, and adding columns.

### Exercise 3: Aggregations
Group by and aggregate data.

### Exercise 4: Joins
Combine multiple DataFrames.

### Exercise 5: ETL Pipeline
Build a complete data pipeline.

### Exercise 6: Stored Procedures
Deploy Snowpark code as procedures.

### Exercise 7: Performance Optimization
Apply optimization techniques.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- Snowpark brings data processing to the data
- Write Python/Java/Scala code that executes in Snowflake
- DataFrame API provides intuitive data manipulation
- Lazy evaluation optimizes query execution
- Deploy as stored procedures or UDFs
- Minimize data movement between Snowflake and client
- Use caching for frequently accessed DataFrames
- Combine Snowpark with SQL for optimal results
- Integrate with Python libraries and ML frameworks
- Best for complex transformations and programmatic workflows

---

## 📚 Additional Resources

- [Snowflake Docs: Snowpark](https://docs.snowflake.com/en/developer-guide/snowpark/index)
- [Snowpark Python API Reference](https://docs.snowflake.com/en/developer-guide/snowpark/reference/python/index)
- [Snowpark Best Practices](https://docs.snowflake.com/en/developer-guide/snowpark/python/working-with-dataframes)

---

## 🔜 Tomorrow: Day 25 - Hands-On Project Day

We'll build a complete end-to-end data engineering project incorporating all concepts learned throughout the bootcamp.
