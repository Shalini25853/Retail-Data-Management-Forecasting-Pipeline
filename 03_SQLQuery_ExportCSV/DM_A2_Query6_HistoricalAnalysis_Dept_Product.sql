-- Query 1: Sales Analysis by Department and Fiscal Year
WITH fiscal_sales AS (
   SELECT 
       -- Calculate Fiscal Year (Starting from July)
       CASE 
           WHEN MONTH(sales_date) >= 7 
           THEN YEAR(sales_date)
           ELSE YEAR(sales_date) - 1
       END AS fiscal_year,
       department_id,
       sales_amount
   FROM h1b.sales
)
SELECT 
   fiscal_year,
   department_id,
   -- Sales Metrics by Department
   COUNT(*) as transaction_count,
   SUM(sales_amount) as total_sales,
   ROUND(AVG(sales_amount), 2) as avg_transaction_amount,
   -- Calculate department contribution
   ROUND(SUM(sales_amount) / SUM(SUM(sales_amount)) OVER (PARTITION BY fiscal_year) * 100, 2) as sales_percentage
FROM fiscal_sales
GROUP BY fiscal_year, department_id
ORDER BY fiscal_year, total_sales DESC;

-- Query 2: Department and Product Analysis
WITH product_sales AS (
   SELECT 
       s.department_id,
       s.item_id,
       p.item_name,
       COUNT(*) as transaction_count,
       SUM(s.sales_amount) as total_sales,
       ROUND(AVG(s.sales_amount), 2) as avg_price
   FROM h1b.sales s
   JOIN h1b.product p ON s.item_id = p.item_id
   GROUP BY s.department_id, s.item_id, p.item_name
)
SELECT 
   ps.department_id,
   ps.item_id,
   ps.item_name,
   ps.transaction_count,
   ps.total_sales,
   ps.avg_price,
   -- Calculate product contribution within department
   ROUND(ps.total_sales / SUM(ps.total_sales) OVER (PARTITION BY ps.department_id) * 100, 2) as dept_product_percentage,
   -- Rank products within department
   RANK() OVER (PARTITION BY ps.department_id ORDER BY ps.total_sales DESC) as product_rank_in_dept
FROM product_sales ps
ORDER BY ps.department_id, ps.total_sales DESC;

/*
Analysis Purpose:
- Understand sales performance by department over fiscal years
- Identify product mix and popularity within each department
- Determine department specialization and focus areas

Key Metrics:
- Transaction volume and total sales by department
- Average transaction values
- Department contribution to total sales
- Product popularity within departments
- Department specialization based on product mix

Note: Results can be used to:
- Optimize department resource allocation
- Improve product placement
- Identify cross-selling opportunities
- Guide inventory management decisions
*/