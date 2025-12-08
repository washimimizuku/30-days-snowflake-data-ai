# Day 15: Role-Based Access Control (RBAC)

## 📖 Learning Objectives (15 min)

By the end of today, you will:
- Understand Snowflake's RBAC security model
- Master the hierarchy of roles and privileges
- Create and manage custom roles effectively
- Implement least privilege access principles
- Grant and revoke privileges appropriately
- Use role hierarchies for efficient access management
- Understand system-defined roles (ACCOUNTADMIN, SYSADMIN, etc.)
- Apply RBAC best practices for production environments

---

## Theory

### Snowflake's RBAC Model

Snowflake uses **Role-Based Access Control (RBAC)** where:
- **Users** are assigned **Roles**
- **Roles** are granted **Privileges** on **Objects**
- **Roles** can be granted to other **Roles** (role hierarchy)

```
User → Role → Privileges → Objects
         ↓
    Child Roles
```

### Core Concepts

#### 1. Securable Objects

Objects that can have privileges granted on them:

```
Account
├─ Databases
│  ├─ Schemas
│  │  ├─ Tables
│  │  ├─ Views
│  │  ├─ Stages
│  │  ├─ File Formats
│  │  ├─ Sequences
│  │  ├─ Functions
│  │  └─ Procedures
│  └─ Shares
├─ Warehouses
├─ Resource Monitors
├─ Integration Objects
└─ Users and Roles
```

#### 2. Privileges

**Object Privileges** (on specific objects):
- `SELECT` - Query data
- `INSERT` - Add data
- `UPDATE` - Modify data
- `DELETE` - Remove data
- `TRUNCATE` - Remove all data
- `REFERENCES` - Create foreign keys
- `OWNERSHIP` - Full control (transferable)
- `ALL` - All applicable privileges

**Schema Privileges**:
- `CREATE TABLE`, `CREATE VIEW`, `CREATE STAGE`, etc.
- `USAGE` - Access schema
- `MONITOR` - View schema details
- `MODIFY` - Alter schema

**Database Privileges**:
- `CREATE SCHEMA`
- `USAGE` - Access database
- `MONITOR` - View database details
- `MODIFY` - Alter database

**Account Privileges**:
- `CREATE DATABASE`, `CREATE WAREHOUSE`, `CREATE ROLE`, etc.
- `MANAGE GRANTS` - Grant/revoke privileges
- `MONITOR USAGE` - View account usage
- `EXECUTE TASK` - Run tasks

#### 3. Roles

**System-Defined Roles**:

```
ACCOUNTADMIN (Top-level admin)
    ↓
SECURITYADMIN (User/role management)
    ↓
USERADMIN (User/role creation)

SYSADMIN (Object management)
    ↓
Custom Roles
    ↓
PUBLIC (All users)
```

**ACCOUNTADMIN**:
- Highest privilege role
- Can manage account-level objects
- Should be used sparingly
- Best practice: Assign to 1-2 users only

**SECURITYADMIN**:
- Manages users and roles
- Can grant/revoke privileges
- Inherits USERADMIN privileges
- Recommended for security operations

**USERADMIN**:
- Creates and manages users and roles
- Cannot grant privileges on objects
- Recommended for user management

**SYSADMIN**:
- Creates and manages databases, warehouses, etc.
- Recommended for day-to-day admin tasks
- Custom roles should be granted to SYSADMIN

**PUBLIC**:
- Automatically granted to all users
- Use for truly public objects only
- Be cautious with PUBLIC grants

### Role Hierarchy

Roles can inherit privileges from other roles:

```sql
-- Create role hierarchy
CREATE ROLE data_engineer;
CREATE ROLE data_analyst;
CREATE ROLE data_viewer;

-- Grant child roles to parent roles
GRANT ROLE data_viewer TO ROLE data_analyst;
GRANT ROLE data_analyst TO ROLE data_engineer;
GRANT ROLE data_engineer TO ROLE SYSADMIN;

-- Result:
-- data_engineer has all privileges of data_analyst and data_viewer
-- data_analyst has all privileges of data_viewer
```

### Privilege Inheritance

```
SYSADMIN
    ↓ (inherits)
data_engineer
    ↓ (inherits)
data_analyst
    ↓ (inherits)
data_viewer
    ↓ (inherits)
PUBLIC
```

### USAGE Privilege

**Critical concept**: `USAGE` is required to access containers:

```sql
-- To query a table, you need:
GRANT USAGE ON DATABASE mydb TO ROLE analyst;        -- Access database
GRANT USAGE ON SCHEMA mydb.myschema TO ROLE analyst; -- Access schema
GRANT SELECT ON TABLE mydb.myschema.mytable TO ROLE analyst; -- Query table

-- Without USAGE on database or schema, SELECT privilege is useless!
```

### OWNERSHIP Privilege

- Every object has exactly one owner (a role)
- Owner has all privileges on the object
- Ownership can be transferred
- When a role is dropped, ownership must be transferred first

```sql
-- Transfer ownership
GRANT OWNERSHIP ON TABLE mytable TO ROLE new_owner;

-- Transfer with COPY CURRENT GRANTS
GRANT OWNERSHIP ON TABLE mytable TO ROLE new_owner COPY CURRENT GRANTS;
```

### Future Grants

Grant privileges on objects that will be created in the future:

```sql
-- All future tables in schema
GRANT SELECT ON FUTURE TABLES IN SCHEMA myschema TO ROLE analyst;

-- All future schemas in database
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE mydb TO ROLE analyst;

-- All future objects of a type
GRANT SELECT ON FUTURE TABLES IN DATABASE mydb TO ROLE analyst;
GRANT SELECT ON FUTURE VIEWS IN DATABASE mydb TO ROLE analyst;
```

### Best Practices

#### 1. Least Privilege Principle

Grant only the minimum privileges needed:

```sql
-- Bad: Granting too much
GRANT ALL ON DATABASE mydb TO ROLE analyst;

-- Good: Grant only what's needed
GRANT USAGE ON DATABASE mydb TO ROLE analyst;
GRANT USAGE ON SCHEMA mydb.public TO ROLE analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA mydb.public TO ROLE analyst;
```

#### 2. Role Hierarchy

Use role hierarchies to simplify management:

```sql
-- Create functional roles
CREATE ROLE read_only;
CREATE ROLE read_write;
CREATE ROLE admin;

-- Build hierarchy
GRANT ROLE read_only TO ROLE read_write;
GRANT ROLE read_write TO ROLE admin;
GRANT ROLE admin TO ROLE SYSADMIN;
```

#### 3. Separate Roles by Function

```sql
-- Data access roles
CREATE ROLE sales_reader;
CREATE ROLE sales_writer;
CREATE ROLE sales_admin;

-- Functional roles
CREATE ROLE etl_role;
CREATE ROLE bi_role;
CREATE ROLE data_science_role;

-- Environment roles
CREATE ROLE dev_role;
CREATE ROLE test_role;
CREATE ROLE prod_role;
```

#### 4. Use Future Grants

Automate privilege management:

```sql
-- Set up future grants for new tables
GRANT SELECT ON FUTURE TABLES IN SCHEMA analytics TO ROLE analyst;
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA staging TO ROLE etl_role;
```

#### 5. Regular Audits

Monitor and audit access:

```sql
-- Review grants
SHOW GRANTS TO ROLE analyst;
SHOW GRANTS ON TABLE sensitive_data;
SHOW GRANTS TO USER john_doe;

-- Review role hierarchy
SHOW GRANTS OF ROLE data_engineer;
```

### Common Patterns

#### Pattern 1: Three-Tier Access Model

```sql
-- Tier 1: Read-only access
CREATE ROLE viewer_role;
GRANT USAGE ON DATABASE mydb TO ROLE viewer_role;
GRANT USAGE ON ALL SCHEMAS IN DATABASE mydb TO ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN DATABASE mydb TO ROLE viewer_role;
GRANT SELECT ON FUTURE TABLES IN DATABASE mydb TO ROLE viewer_role;

-- Tier 2: Read-write access
CREATE ROLE editor_role;
GRANT ROLE viewer_role TO ROLE editor_role;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN DATABASE mydb TO ROLE editor_role;
GRANT INSERT, UPDATE, DELETE ON FUTURE TABLES IN DATABASE mydb TO ROLE editor_role;

-- Tier 3: Admin access
CREATE ROLE admin_role;
GRANT ROLE editor_role TO ROLE admin_role;
GRANT ALL ON DATABASE mydb TO ROLE admin_role;
```

#### Pattern 2: Department-Based Roles

```sql
-- Sales department
CREATE ROLE sales_analyst;
GRANT USAGE ON DATABASE sales_db TO ROLE sales_analyst;
GRANT USAGE ON SCHEMA sales_db.public TO ROLE sales_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA sales_db.public TO ROLE sales_analyst;

-- Finance department
CREATE ROLE finance_analyst;
GRANT USAGE ON DATABASE finance_db TO ROLE finance_analyst;
GRANT USAGE ON SCHEMA finance_db.public TO ROLE finance_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA finance_db.public TO ROLE finance_analyst;

-- Cross-functional role
CREATE ROLE executive_role;
GRANT ROLE sales_analyst TO ROLE executive_role;
GRANT ROLE finance_analyst TO ROLE executive_role;
```

#### Pattern 3: ETL Pipeline Roles

```sql
-- ETL service account role
CREATE ROLE etl_service_role;

-- Read from source
GRANT USAGE ON DATABASE source_db TO ROLE etl_service_role;
GRANT USAGE ON SCHEMA source_db.public TO ROLE etl_service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA source_db.public TO ROLE etl_service_role;

-- Write to staging
GRANT USAGE ON DATABASE staging_db TO ROLE etl_service_role;
GRANT USAGE ON SCHEMA staging_db.public TO ROLE etl_service_role;
GRANT CREATE TABLE ON SCHEMA staging_db.public TO ROLE etl_service_role;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA staging_db.public TO ROLE etl_service_role;

-- Execute tasks
GRANT EXECUTE TASK ON ACCOUNT TO ROLE etl_service_role;
GRANT USAGE ON WAREHOUSE etl_wh TO ROLE etl_service_role;
```

### Security Considerations

#### 1. ACCOUNTADMIN Usage

```sql
-- Bad: Using ACCOUNTADMIN for daily tasks
USE ROLE ACCOUNTADMIN;
CREATE TABLE mytable (...);  -- Don't do this!

-- Good: Use SYSADMIN for object creation
USE ROLE SYSADMIN;
CREATE TABLE mytable (...);
```

#### 2. PUBLIC Role

```sql
-- Bad: Granting to PUBLIC
GRANT SELECT ON TABLE sensitive_data TO ROLE PUBLIC;  -- Everyone can see!

-- Good: Grant to specific roles
GRANT SELECT ON TABLE sensitive_data TO ROLE authorized_role;
```

#### 3. Ownership Management

```sql
-- Transfer ownership to SYSADMIN for manageability
GRANT OWNERSHIP ON DATABASE mydb TO ROLE SYSADMIN;
GRANT OWNERSHIP ON SCHEMA mydb.public TO ROLE SYSADMIN;
```

### Monitoring and Auditing

#### Check Current Role

```sql
SELECT CURRENT_ROLE();
SELECT CURRENT_USER();
```

#### View Grants

```sql
-- Grants TO a role (what the role has)
SHOW GRANTS TO ROLE data_analyst;

-- Grants OF a role (child roles)
SHOW GRANTS OF ROLE data_analyst;

-- Grants ON an object (who has access)
SHOW GRANTS ON TABLE mytable;

-- Grants TO a user
SHOW GRANTS TO USER john_doe;
```

#### Audit Queries

```sql
-- View all roles
SHOW ROLES;

-- View role hierarchy
SELECT 
  grantee_name,
  role,
  granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE deleted_on IS NULL
  AND granted_on = 'ROLE';

-- View object privileges
SELECT 
  grantee_name,
  privilege,
  table_name,
  granted_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE deleted_on IS NULL
  AND granted_on = 'TABLE';
```

### Troubleshooting Access Issues

#### Issue 1: "Object does not exist"

**Cause**: Missing USAGE privilege on database or schema

**Solution**:
```sql
GRANT USAGE ON DATABASE mydb TO ROLE myrole;
GRANT USAGE ON SCHEMA mydb.myschema TO ROLE myrole;
```

#### Issue 2: "Insufficient privileges"

**Cause**: Missing required privilege

**Solution**:
```sql
-- Check what privileges the role has
SHOW GRANTS TO ROLE myrole;

-- Grant missing privilege
GRANT SELECT ON TABLE mytable TO ROLE myrole;
```

#### Issue 3: "Cannot perform operation"

**Cause**: Using wrong role

**Solution**:
```sql
-- Check current role
SELECT CURRENT_ROLE();

-- Switch to appropriate role
USE ROLE appropriate_role;
```

---

## 💻 Exercises (40 min)

Complete the exercises in `exercise.sql`.

### Exercise 1: Create Role Hierarchy
Build a multi-tier role structure.

### Exercise 2: Grant Database Access
Set up database and schema access.

### Exercise 3: Table-Level Privileges
Grant granular table access.

### Exercise 4: Future Grants
Automate privilege management.

### Exercise 5: Warehouse Access
Control compute resource access.

### Exercise 6: Role Switching
Practice using different roles.

### Exercise 7: Audit and Monitor
Review and audit access controls.

---

## ✅ Quiz (5 min)

Test your understanding in `quiz.md`.

---

## 🎯 Key Takeaways

- RBAC: Users → Roles → Privileges → Objects
- System roles: ACCOUNTADMIN, SECURITYADMIN, USERADMIN, SYSADMIN, PUBLIC
- USAGE privilege required for database/schema access
- Role hierarchies simplify management
- Future grants automate privilege assignment
- Least privilege principle: grant only what's needed
- ACCOUNTADMIN should be used sparingly
- Regular audits ensure proper access control
- Ownership can be transferred between roles
- PUBLIC role grants to all users (use carefully)

---

## 📚 Additional Resources

- [Snowflake Docs: Access Control](https://docs.snowflake.com/en/user-guide/security-access-control)
- [RBAC Overview](https://docs.snowflake.com/en/user-guide/security-access-control-overview)
- [Privileges Reference](https://docs.snowflake.com/en/user-guide/security-access-control-privileges)

---

## 🔜 Tomorrow: Day 16 - Data Masking & Privacy

We'll learn how to protect sensitive data using dynamic data masking and masking policies.
