# mysql-project
contains concepts of mysql like select queries update queries, alter queries, clauses,views,and triggers
🛒 Walmart Sales Data Analysis (MySQL)
An end-to-end SQL data analysis project built using MySQL 8.0+ (also fully compatible with MariaDB 10.x). This project focuses on analyzing retail sales performance across multiple Walmart branches, evaluating product profitability, studying customer purchasing behavior, and implementing automated database triggers to maintain strict data integrity.

📌 Project Overview
The objective of this project is to transform raw sales records into actionable business insights. It addresses critical retail questions such as top-performing product lines, branch-wise revenue trends, payment mode preferences, and basket size behavior across demographic segments.

Beyond data querying, this project implements production-level database design patterns including dynamic stored procedures, customized analytical views, relational table joins, and proactive data validation using database triggers.

🗄️ Database Architecture & Schema
The relational schema is composed of a primary transactional table and supporting reference tables:

sales: Main table storing transaction records (Invoice ID, Branch, City, Product Line, Unit Price, Quantity, Total, COGS, VAT, Date, Time, Payment Method, Rating, and derived features).

branch_targets: Reference table mapping each branch to its target revenue and branch manager.

promotions: Reference table containing product-line promotional codes and discount percentages.

sales_audit: Audit table logging transaction modifications and operational events.

🚀 Key Modules & Technical Highlights
1. Data Cleaning & Feature Engineering
Extracted temporal features to enable deeper time-series analysis:

time_of_day: Categorized transactions into MORNING, AFTERNOON, and EVENING shifts using CASE statement logic.

day_name: Extracted day of the week (e.g., Monday, Tuesday) to spot peak shopping days.

month_name: Extracted month names to track monthly sales performance.

2. Analytical Views (Business Intelligence)
Created views to encapsulate complex queries into simple virtual tables:

ww_branch_sales_summary: High-level summary of total transactions, units sold, total revenue, and average order value (AOV) per branch.

ww_customer_payment_behavior: Transaction count and spend breakdown by customer type (Member vs Normal) and payment method.

ww_product_profitability: Aggregated revenue, gross income, and customer satisfaction ratings per product line.

ww_monthly_trend: Monthly revenue vs. Cost of Goods Sold (COGS) comparison.

ww_gender_shopping_behavior: Average items per order, total spend, and cumulative revenue segmented by gender.

vw_transaction_tiers: Categorizes orders into standard, medium, or high-value tiers based on spend thresholds.

3. Stored Procedures
Written with input (IN) and output (OUT) parameters for dynamic workflow execution:

GetSalesByBranch: Retrieves full transaction details for a target branch.

getSalesByMultipleInputs: Filters sales records using a specific month and customer demographic.

getproductrevenue: Calculates and returns the exact rounded revenue for a product line into a variable.

getpaymentsummary: Summarizes total revenue, total transactions, and average value for a given payment method.

evaluateperformance: Evaluates branch total revenue against volume thresholds and outputs branch classification.

getsalesbydate: Retrieves daily itemized sales records.

4. Multi-Table Joins & Complex Filtering
Inner Joins: Linked sales records with branch performance targets to track target vs. actual metric gaps.

Left & Right Joins: Combined sales transactions with discount programs to check promotion usage.

Full Outer Joins: Implemented using UNION logic combining LEFT JOIN and RIGHT JOIN queries.

Conditional Aggregations: Applied GROUP BY, HAVING, and nested subqueries to filter data above dynamic statistical averages.

5. Automated Database Triggers
Proactive automation scripts to enforce logic directly inside the engine:

trg_simple_total / trg_before_update_sales: Automatically calculates total, cogs, and vat dynamically upon record insertion or modification.

trg_upper_case: Formats all branch input codes into uppercase string values prior to insertion.

Validation Guards: Prevents invalid branch inputs by throwing a custom SQL error (SIGNAL SQLSTATE '45000') during updates.

🛠️ How to Use
Clone or download this repository.

Open your preferred SQL client (MySQL Workbench, DBeaver, VS Code, etc.).

Execute the SQL script file sequentially from Part 1 to Part 8.

Run sample queries or call stored procedures to inspect results.



CALL evaluateperformance('A', @status);
SELECT @status AS branch_evaluation;
