-- Sales Data Analysis by Fiscal Year and Quarter for System Comparison

WITH fiscal_sales AS (
   SELECT 
       -- Calculate Fiscal Year (Starting from July)
       CASE 
           WHEN MONTH(s.sales_date) >= 7 
           THEN YEAR(s.sales_date)
           ELSE YEAR(s.sales_date) - 1
       END AS fiscal_year,
       -- Calculate Quarter
       CASE 
           WHEN MONTH(s.sales_date) BETWEEN 7 AND 9 THEN 1
           WHEN MONTH(s.sales_date) BETWEEN 10 AND 12 THEN 2
           WHEN MONTH(s.sales_date) BETWEEN 1 AND 3 THEN 3
           WHEN MONTH(s.sales_date) BETWEEN 4 AND 6 THEN 4
       END AS fiscal_quarter,
       s.sales_amount
   FROM h1b.sales s
)
SELECT 
   fiscal_year,
   fiscal_quarter,
   -- Sales Metrics for TouchNet System
   COUNT(*) as transaction_count,
   SUM(sales_amount) as total_sales_touchnet,
   ROUND(AVG(sales_amount), 2) as avg_transaction_amount
FROM fiscal_sales
GROUP BY 
   fiscal_year,
   fiscal_quarter
ORDER BY 
   fiscal_year,
   fiscal_quarter;

/*
Analysis Purpose:
- Compare sales data between TouchNet and BlackBaud systems
- Validate data consistency across systems
- Identify potential discrepancies in revenue recording

Key Metrics:
- transaction_count: Number of sales transactions per quarter
- total_sales_touchnet: Total revenue from TouchNet system
- avg_transaction_amount: Average sale value per transaction

Notes:
- TouchNet captures point-of-sale transactions
- Data should align with BlackBaud 42xxx revenue accounts
- Any differences might indicate timing or categorization issues
*/