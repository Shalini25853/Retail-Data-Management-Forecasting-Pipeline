-- Reconciliation Analysis between TouchNet and BlackBaud Systems
WITH touchnet_sales AS (
   SELECT 
       fiscal_year,
       fiscal_quarter,
       SUM(sales_amount) as touchnet_amount
   FROM (
       SELECT 
           CASE 
               WHEN MONTH(sales_date) >= 7 
               THEN YEAR(sales_date)
               ELSE YEAR(sales_date) - 1
           END AS fiscal_year,
           CASE 
               WHEN MONTH(sales_date) BETWEEN 7 AND 9 THEN 1
               WHEN MONTH(sales_date) BETWEEN 10 AND 12 THEN 2
               WHEN MONTH(sales_date) BETWEEN 1 AND 3 THEN 3
               WHEN MONTH(sales_date) BETWEEN 4 AND 6 THEN 4
           END AS fiscal_quarter,
           sales_amount
       FROM h1b.sales
   ) fs
   GROUP BY fiscal_year, fiscal_quarter
),
blackbaud_revenue AS (
   SELECT 
       fiscal_year,
       fiscal_quarter,
       ABS(SUM(transaction_amount)) as blackbaud_amount
   FROM (
       SELECT 
           CASE 
               WHEN MONTH(post_date) >= 7 
               THEN YEAR(post_date)
               ELSE YEAR(post_date) - 1
           END AS fiscal_year,
           CASE 
               WHEN MONTH(post_date) BETWEEN 7 AND 9 THEN 1
               WHEN MONTH(post_date) BETWEEN 10 AND 12 THEN 2
               WHEN MONTH(post_date) BETWEEN 1 AND 3 THEN 3
               WHEN MONTH(post_date) BETWEEN 4 AND 6 THEN 4
           END AS fiscal_quarter,
           transaction_amount
       FROM h1b.accounting a
       JOIN h1b.account_section ac ON a.account_number = ac.account_number
       WHERE ac.section_type = 'REVENUE'
   ) fd
   GROUP BY fiscal_year, fiscal_quarter
)
SELECT 
   COALESCE(t.fiscal_year, b.fiscal_year) as fiscal_year,
   COALESCE(t.fiscal_quarter, b.fiscal_quarter) as fiscal_quarter,
   t.touchnet_amount as touchnet_sales,
   b.blackbaud_amount as blackbaud_revenue,
   (t.touchnet_amount - b.blackbaud_amount) as difference,
   CASE 
       WHEN b.blackbaud_amount = 0 THEN NULL
       ELSE ROUND((t.touchnet_amount - b.blackbaud_amount) / b.blackbaud_amount * 100, 2)
   END as difference_percentage
FROM touchnet_sales t
LEFT JOIN blackbaud_revenue b 
   ON t.fiscal_year = b.fiscal_year 
   AND t.fiscal_quarter = b.fiscal_quarter
ORDER BY fiscal_year, fiscal_quarter;