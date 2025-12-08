# Day 18 Quiz: Data Sharing & Secure Views

## Instructions
Choose the best answer for each question. Answers are provided at the end.

---

## Questions

### 1. What is Snowflake Secure Data Sharing?

A) Copying data to another account  
B) Sharing live data without copying or moving it  
C) Encrypting data before sharing  
D) Emailing data files  

**Your answer:**

---

### 2. Who pays for storage in Snowflake data sharing?

A) Consumer  
B) Provider  
C) Both equally  
D) Snowflake  

**Your answer:**

---

### 3. Who pays for compute in Snowflake data sharing?

A) Consumer  
B) Provider  
C) Both equally  
D) Snowflake  

**Your answer:**

---

### 4. What is a secure view?

A) A view with encryption  
B) A view that hides the query definition  
C) A view that requires password  
D) A view that expires  

**Your answer:**

---

### 5. Why should you use secure views for data sharing?

A) They are faster  
B) They protect sensitive data and hide logic  
C) They are required by Snowflake  
D) They cost less  

**Your answer:**

---

### 6. What is a reader account?

A) A read-only user  
B) A managed account for non-Snowflake users  
C) A backup account  
D) A monitoring account  

**Your answer:**

---

### 7. Who pays for compute in a reader account?

A) Reader account user  
B) Provider  
C) Snowflake  
D) No one, it's free  

**Your answer:**

---

### 8. Can you share data across different cloud providers?

A) No, same cloud only  
B) Yes, with additional configuration  
C) Only between AWS regions  
D) Only with replication  

**Your answer:**

---

### 9. What must you grant to a share to make data accessible?

A) Only SELECT on tables  
B) USAGE on database, schema, and SELECT on objects  
C) Only USAGE on database  
D) OWNERSHIP on all objects  

**Your answer:**

---

### 10. What is the Snowflake Data Marketplace?

A) A place to buy Snowflake licenses  
B) A platform to discover and access data products  
C) A storage marketplace  
D) A compute marketplace  

**Your answer:**

---

## Answer Key

1. **B** - Sharing live data without copying or moving it
2. **B** - Provider
3. **A** - Consumer
4. **B** - A view that hides the query definition
5. **B** - They protect sensitive data and hide logic
6. **B** - A managed account for non-Snowflake users
7. **B** - Provider
8. **B** - Yes, with additional configuration
9. **B** - USAGE on database, schema, and SELECT on objects
10. **B** - A platform to discover and access data products

---

## Score Yourself

- 9-10/10: Excellent! You understand data sharing thoroughly
- 7-8/10: Good! Review the concepts you missed
- 5-6/10: Fair - Review README.md and try exercises again
- 0-4/10: Review today's lesson completely before moving on

## Key Concepts to Remember

✅ **Zero-Copy Sharing**: No data duplication or movement  
✅ **Provider Pays**: Storage costs borne by provider  
✅ **Consumer Pays**: Compute costs borne by consumer  
✅ **Secure Views**: Hide query definition and protect data  
✅ **Reader Accounts**: For non-Snowflake users, provider pays compute  
✅ **Cross-Cloud**: Can share across regions and clouds  
✅ **Grants Required**: USAGE on database/schema, SELECT on objects  
✅ **Live Data**: Always current, no ETL needed  
✅ **Data Marketplace**: Platform for data products  
✅ **Security**: Always use secure views for sharing  

## Exam Tips

**Common exam question patterns:**
- Zero-copy sharing concept
- Cost allocation (provider vs. consumer)
- Secure view characteristics
- Reader account purpose and costs
- Required grants for sharing
- Cross-region/cloud sharing
- Data marketplace features
- Secure view vs. regular view
- Share management commands
- Best practices for sharing

**Remember for the exam:**
- Zero-copy = no data duplication
- Provider pays storage, consumer pays compute
- Reader accounts: provider pays everything
- Secure views hide definition
- Always use secure views for sharing
- USAGE + SELECT grants required
- Cross-cloud sharing supported
- Live data, no ETL
- Data marketplace for discovery
- Monitor share usage regularly

## Next Steps

- If you scored 8-10: Move to Day 19 (Time Travel & Fail-Safe)
- If you scored 5-7: Review exercises and retry
- If you scored 0-4: Re-read README.md and complete all exercises

## Additional Practice

Try these scenarios:
1. Create a share
2. Create secure views with masking
3. Grant access to share
4. Add consumer accounts
5. Create reader account
6. Monitor share usage
7. Implement row filtering in secure view
8. Test cross-region sharing

## Real-World Applications

**Partner Data Sharing:**
```sql
-- Share sales data with partner
CREATE SHARE partner_share;
CREATE SECURE VIEW partner_sales AS
SELECT * FROM sales WHERE partner_id = 'ABC';
GRANT SELECT ON VIEW partner_sales TO SHARE partner_share;
ALTER SHARE partner_share ADD ACCOUNTS = partner_account;
```

**Analytics Data Sharing:**
```sql
-- Share aggregated analytics
CREATE SECURE VIEW analytics_summary AS
SELECT 
  DATE_TRUNC('month', date) as month,
  region,
  SUM(revenue) as total_revenue
FROM sales
GROUP BY month, region;
```

**Product Catalog Sharing:**
```sql
-- Share product catalog (hide costs)
CREATE SECURE VIEW public_catalog AS
SELECT 
  product_id,
  product_name,
  category,
  price
  -- cost excluded
FROM products;
```

**Customer Data Sharing:**
```sql
-- Share customer data (mask PII)
CREATE SECURE VIEW customer_shared AS
SELECT 
  customer_id,
  customer_name,
  CONCAT('***@', SPLIT_PART(email, '@', 2)) as email,
  region
FROM customers;
```

**Sharing Patterns:**

**Direct Share:**
- Share with specific Snowflake accounts
- Consumer has Snowflake account
- Consumer pays for compute
- Best for B2B partnerships

**Reader Account:**
- Share with non-Snowflake users
- Provider pays for compute
- Managed by provider
- Best for external customers

**Data Marketplace:**
- Public or private listings
- Discoverable by all Snowflake users
- Automated provisioning
- Best for data monetization

**Best Practices Checklist:**
- [ ] Always use secure views
- [ ] Mask PII in shared views
- [ ] Filter data appropriately
- [ ] Document shares clearly
- [ ] Monitor share usage
- [ ] Regular access reviews
- [ ] Test before sharing
- [ ] Use aggregated data when possible
- [ ] Grant minimal necessary access
- [ ] Track data transfer costs

**Common Mistakes to Avoid:**
1. ❌ Sharing base tables directly
2. ❌ Not using secure views
3. ❌ Sharing sensitive data unmasked
4. ❌ Not documenting shares
5. ❌ Not monitoring usage
6. ❌ Over-sharing data
7. ❌ Forgetting required grants
8. ❌ Not testing shares

**Troubleshooting:**

**Issue**: Consumer can't see data
- **Check**: All grants applied?
- **Check**: USAGE on database and schema?
- **Fix**: Grant USAGE and SELECT

**Issue**: Secure view slow
- **Cause**: Limited optimization
- **Fix**: Pre-filter in view, use materialized views

**Issue**: High data transfer costs
- **Cause**: Cross-region sharing
- **Fix**: Use replication, monitor usage

**Issue**: Can't drop share
- **Cause**: Consumers still attached
- **Fix**: Remove all consumers first

**Cost Considerations:**

**Provider Costs:**
- Storage (always)
- Compute for reader accounts
- Cross-region data transfer

**Consumer Costs:**
- Compute (queries)
- No storage costs
- No data transfer (same region)

**Reader Account Costs:**
- Provider pays all costs
- Storage + compute
- Consider usage limits

**Monitoring Queries:**

```sql
-- View all shares
SHOW SHARES;

-- Data transfer history
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY
WHERE share_name IS NOT NULL;

-- Grants to shares
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_SHARES
WHERE deleted_on IS NULL;

-- Share details
DESC SHARE share_name;
```

**Security Best Practices:**

**1. Use Secure Views:**
- Hide query logic
- Protect sensitive data
- Required for sharing

**2. Mask PII:**
- Email: `***@domain.com`
- Phone: `***-***-1234`
- SSN: `***-**-1234`

**3. Filter Data:**
- Share only necessary rows
- Time-based filtering
- Region-based filtering

**4. Aggregate When Possible:**
- Reduce data sensitivity
- Provide insights without details
- Protect individual records

**5. Regular Audits:**
- Review share consumers
- Check shared objects
- Monitor usage patterns
- Remove unnecessary access

**Compliance Considerations:**

**GDPR:**
- Mask personal data
- Document data sharing
- Right to be forgotten

**CCPA:**
- Consumer privacy rights
- Data sharing transparency
- Opt-out mechanisms

**HIPAA:**
- Protect PHI
- Business associate agreements
- Audit trails

**SOX:**
- Financial data controls
- Access documentation
- Change tracking

**Next Steps:**
Tomorrow we'll learn about Time Travel & Fail-Safe for data recovery and historical queries in Snowflake.
