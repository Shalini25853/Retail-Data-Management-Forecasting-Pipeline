-- Future Projection with Adjusted Labor Cost Reduction Rate for Break-even by 2025 Q4
WITH RECURSIVE quarters AS (
   SELECT 2024 as fiscal_year, 1 as fiscal_quarter
   UNION ALL
   SELECT 
       CASE WHEN fiscal_quarter = 4 THEN fiscal_year + 1 ELSE fiscal_year END,
       CASE WHEN fiscal_quarter = 4 THEN 1 ELSE fiscal_quarter + 1 END
   FROM quarters
   WHERE fiscal_year < 2026
),
base_year AS (
   -- Base metrics from FY2023 Q4
   SELECT 
       ABS(SUM(CASE WHEN ac.section_type = 'REVENUE' THEN a.transaction_amount ELSE 0 END)) as base_revenue,
       SUM(CASE WHEN ac.section_type = 'COGS' THEN a.transaction_amount ELSE 0 END) as base_cogs,
       SUM(CASE WHEN ac.section_type = 'SGA' AND ac.account_number BETWEEN 51000 AND 58999 
           THEN a.transaction_amount ELSE 0 END) as base_labor,
       SUM(CASE WHEN ac.section_type = 'SGA' AND ac.account_number NOT BETWEEN 51000 AND 58999 
           THEN a.transaction_amount ELSE 0 END) as base_other_sga
   FROM h1b.accounting a
   JOIN h1b.account_section ac ON a.account_number = ac.account_number
   WHERE YEAR(a.post_date) = 2023 
   AND MONTH(a.post_date) BETWEEN 10 AND 12
),
projected_metrics AS (
   SELECT 
       q.fiscal_year,
       q.fiscal_quarter,
       -- Revenue with 20% annual growth (approximately 4.66% quarterly)
       ROUND(base_revenue * POWER(1.0466, (q.fiscal_year - 2024) * 4 + q.fiscal_quarter), 2) as revenue,
       -- COGS with 2% annual increase (approximately 0.5% quarterly)
       ROUND(base_cogs * POWER(1.005, (q.fiscal_year - 2024) * 4 + q.fiscal_quarter), 2) as cogs,
       -- Labor costs with 25% annual reduction (approximately 6.9% quarterly)
       ROUND(base_labor * POWER(0.931, (q.fiscal_year - 2024) * 4 + q.fiscal_quarter), 2) as labor_costs,
       -- Other SGA with 2% annual increase (approximately 0.5% quarterly)
       ROUND(base_other_sga * POWER(1.005, (q.fiscal_year - 2024) * 4 + q.fiscal_quarter), 2) as other_sga
   FROM quarters q
   CROSS JOIN base_year
)
SELECT 
   fiscal_year,
   fiscal_quarter,
   revenue,
   cogs,
   labor_costs,
   other_sga,
   ROUND(cogs / revenue * 100, 2) as cogs_ratio,
   revenue - cogs as gross_margin,
   revenue - cogs - labor_costs - other_sga as net_profit
FROM projected_metrics
ORDER BY fiscal_year, fiscal_quarter;

/*
Revised Projection Model Assumptions:

Time Period:
- FY2024 Q1 through FY2025 Q4
- Base Period: FY2023 Q4

Quarterly Growth Rates:
1. Revenue Growth:
  • 4.66% per quarter (20% annually)
  • Focus on sustainable growth through pricing and volume

2. Cost Management:
  • Labor cost reduction: 6.9% per quarter (25% annually) 
  • COGS increase: 0.5% per quarter (2% annually)
  • Other SGA increase: 0.5% per quarter (2% annually)

Key Changes:
- Reduced labor cost reduction rate to achieve break-even specifically in Q4 2025
- Maintained aggressive but achievable revenue growth
- Kept other cost factors consistent

Target:
- Achieve break-even (Net Profit = 0) by Q4 2025
- More gradual labor cost reduction for sustainable implementation
*/