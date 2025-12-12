# SnowPro Advanced Data Engineer - Topics & Documentation Reference

## Data Movement & Transformation (30% - Days 1-6)

### Snowpipe & Continuous Data Loading
- **Snowpipe Overview**: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
- **Auto-ingest from Cloud Storage**: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3
- **REST API**: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-apis
- **Error Handling**: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-errors
- **Snowpipe Streaming**: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-streaming-overview

### Streams for Change Data Capture
- **Streams Overview**: https://docs.snowflake.com/en/user-guide/streams-intro
- **Stream Types**: https://docs.snowflake.com/en/user-guide/streams-manage
- **Stream Metadata**: https://docs.snowflake.com/en/user-guide/streams-columns
- **Consuming Streams**: https://docs.snowflake.com/en/user-guide/streams-consume

### Tasks & Orchestration
- **Tasks Overview**: https://docs.snowflake.com/en/user-guide/tasks-intro
- **Task Scheduling**: https://docs.snowflake.com/en/user-guide/tasks-create
- **Task Trees**: https://docs.snowflake.com/en/user-guide/tasks-graphs
- **Serverless Tasks**: https://docs.snowflake.com/en/user-guide/tasks-serverless
- **Task Observability**: https://docs.snowflake.com/en/user-guide/tasks-ts

### Dynamic Tables
- **Dynamic Tables Overview**: https://docs.snowflake.com/en/user-guide/dynamic-tables-about
- **Creating Dynamic Tables**: https://docs.snowflake.com/en/user-guide/dynamic-tables-create
- **Refresh Modes**: https://docs.snowflake.com/en/user-guide/dynamic-tables-refresh
- **Cost Optimization**: https://docs.snowflake.com/en/user-guide/dynamic-tables-costs

### Advanced SQL & Transformations
- **Window Functions**: https://docs.snowflake.com/en/sql-reference/functions-analytic
- **QUALIFY Clause**: https://docs.snowflake.com/en/sql-reference/constructs/qualify
- **Lateral Joins**: https://docs.snowflake.com/en/sql-reference/constructs/join-lateral
- **JSON Functions**: https://docs.snowflake.com/en/sql-reference/functions-semistructured

## Performance Optimization (25% - Days 7-11)

### Clustering & Micro-Partitions
- **Clustering Overview**: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
- **Micro-partitions**: https://docs.snowflake.com/en/user-guide/tables-clustering-micropartitions
- **Automatic Clustering**: https://docs.snowflake.com/en/user-guide/tables-auto-reclustering
- **Clustering Information**: https://docs.snowflake.com/en/sql-reference/functions/system_clustering_information

### Search Optimization Service
- **Search Optimization**: https://docs.snowflake.com/en/user-guide/search-optimization-service
- **Enabling Search Optimization**: https://docs.snowflake.com/en/user-guide/search-optimization-configure
- **Monitoring**: https://docs.snowflake.com/en/user-guide/search-optimization-monitor

### Materialized Views
- **Materialized Views**: https://docs.snowflake.com/en/user-guide/views-materialized
- **Creating Materialized Views**: https://docs.snowflake.com/en/user-guide/views-materialized-create
- **Maintenance**: https://docs.snowflake.com/en/user-guide/views-materialized-maintenance

### Query Performance
- **Query Profile**: https://docs.snowflake.com/en/user-guide/ui-query-profile
- **Query Optimization**: https://docs.snowflake.com/en/user-guide/queries-optimization
- **Join Optimization**: https://docs.snowflake.com/en/user-guide/querying-joins

### Warehouse Management
- **Virtual Warehouses**: https://docs.snowflake.com/en/user-guide/warehouses-overview
- **Warehouse Sizing**: https://docs.snowflake.com/en/user-guide/warehouses-considerations
- **Multi-cluster Warehouses**: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
- **Auto-suspend/Resume**: https://docs.snowflake.com/en/user-guide/warehouses-considerations#auto-suspension-and-auto-resumption

### Caching
- **Result Caching**: https://docs.snowflake.com/en/user-guide/querying-persisted-results
- **Warehouse Cache**: https://docs.snowflake.com/en/user-guide/warehouses-considerations#warehouse-cache

## Data Protection & Security (20% - Days 12-16)

### Encryption & Key Management
- **Encryption**: https://docs.snowflake.com/en/user-guide/security-encryption
- **Tri-Secret Secure**: https://docs.snowflake.com/en/user-guide/security-encryption-manage
- **Key Rotation**: https://docs.snowflake.com/en/user-guide/security-encryption-manage#key-rotation

### Access Control
- **Access Control Overview**: https://docs.snowflake.com/en/user-guide/security-access-control-overview
- **Role-based Access Control**: https://docs.snowflake.com/en/user-guide/security-access-control-configure
- **Future Grants**: https://docs.snowflake.com/en/sql-reference/sql/grant-privilege#future-grants
- **Secure Views**: https://docs.snowflake.com/en/user-guide/views-secure
- **Row Access Policies**: https://docs.snowflake.com/en/user-guide/security-row-access-intro
- **Column Masking**: https://docs.snowflake.com/en/user-guide/security-column-intro

### Data Governance
- **Object Tagging**: https://docs.snowflake.com/en/user-guide/object-tagging
- **Data Classification**: https://docs.snowflake.com/en/user-guide/governance-classify
- **Access History**: https://docs.snowflake.com/en/sql-reference/account-usage/access_history

### Time Travel & Fail-Safe
- **Time Travel**: https://docs.snowflake.com/en/user-guide/data-time-travel
- **Fail-safe**: https://docs.snowflake.com/en/user-guide/data-failsafe
- **Cloning**: https://docs.snowflake.com/en/sql-reference/sql/create-clone

### Data Sharing
- **Secure Data Sharing**: https://docs.snowflake.com/en/user-guide/data-sharing-intro
- **Reader Accounts**: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
- **Data Exchange**: https://docs.snowflake.com/en/user-guide/data-exchange

## Monitoring & Troubleshooting (15% - Days 17-20)

### Account Usage & Information Schema
- **Account Usage Views**: https://docs.snowflake.com/en/sql-reference/account-usage
- **Information Schema**: https://docs.snowflake.com/en/sql-reference/info-schema
- **Query History**: https://docs.snowflake.com/en/sql-reference/account-usage/query_history

### Resource Monitoring
- **Resource Monitors**: https://docs.snowflake.com/en/user-guide/resource-monitors
- **Warehouse Load Monitoring**: https://docs.snowflake.com/en/sql-reference/account-usage/warehouse_load_history
- **Cost Monitoring**: https://docs.snowflake.com/en/user-guide/cost-understanding-overall

### Performance Monitoring
- **Query Performance**: https://docs.snowflake.com/en/user-guide/ui-snowsight-activity#query-performance
- **Warehouse Performance**: https://docs.snowflake.com/en/user-guide/ui-snowsight-activity#warehouse-performance
- **Data Transfer**: https://docs.snowflake.com/en/sql-reference/account-usage/data_transfer_history

## Advanced Features (10% - Days 21-23)

### External Tables & Functions
- **External Tables**: https://docs.snowflake.com/en/user-guide/tables-external-intro
- **Partitioned External Tables**: https://docs.snowflake.com/en/user-guide/tables-external-partitions
- **External Functions**: https://docs.snowflake.com/en/sql-reference/external-functions-introduction

### Stored Procedures & UDFs
- **Stored Procedures**: https://docs.snowflake.com/en/sql-reference/stored-procedures-overview
- **JavaScript Procedures**: https://docs.snowflake.com/en/sql-reference/stored-procedures-javascript
- **User-Defined Functions**: https://docs.snowflake.com/en/sql-reference/udf-overview
- **Python UDFs**: https://docs.snowflake.com/en/sql-reference/udf-python
- **Java UDFs**: https://docs.snowflake.com/en/sql-reference/udf-java

### Snowpark
- **Snowpark Overview**: https://docs.snowflake.com/en/developer-guide/snowpark/index
- **Snowpark Python**: https://docs.snowflake.com/en/developer-guide/snowpark/python/index
- **DataFrame API**: https://docs.snowflake.com/en/developer-guide/snowpark/python/working-with-dataframes
- **User-Defined Table Functions**: https://docs.snowflake.com/en/sql-reference/udf-table-functions

## Additional Resources

### Exam Preparation
- **Exam Guide**: https://www.snowflake.com/certifications/snowpro-advanced-data-engineer/
- **Hands-On Labs**: https://quickstarts.snowflake.com/
- **Snowflake University**: https://learn.snowflake.com/

### Reference Materials
- **SQL Reference**: https://docs.snowflake.com/en/sql-reference
- **System Functions**: https://docs.snowflake.com/en/sql-reference/functions-system
- **Parameters Reference**: https://docs.snowflake.com/en/sql-reference/parameters
- **Limits & Constraints**: https://docs.snowflake.com/en/user-guide/intro-supported-operations

### Best Practices
- **Data Loading**: https://docs.snowflake.com/en/user-guide/data-load-best-practices
- **Query Performance**: https://docs.snowflake.com/en/user-guide/performance-query
- **Security Best Practices**: https://docs.snowflake.com/en/user-guide/security-best-practices
- **Cost Optimization**: https://docs.snowflake.com/en/user-guide/cost-understanding-compute
