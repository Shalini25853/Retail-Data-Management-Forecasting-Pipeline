-- Financial Prediction Query for FY2024-FY2026

WITH 
-- Base Data: Last Complete Fiscal Year (FY2023)
base_revenue AS (
   SELECT 
       fiscal_year,
       fiscal_quarter,
       SUM(CASE WHEN section_type = 'REVENUE' THEN ABS(transaction_amount) ELSE 0 END) as revenue,
       SUM(CASE WHEN section_type = 'COGS' THEN transaction_amount ELSE 0 END) as cogs,
       SUM(CASE 
           WHEN section_type = 'SGA' AND account_number BETWEEN 51000 AND 58999 
           THEN transaction_amount ELSE 0 END) as labor_costs,
       SUM(CASE 
           WHEN section_type = 'SGA' AND account_number NOT BETWEEN 51000 AND 58999 
           THEN transaction_amount ELSE 0 END) as other_sga
   FROM (
       SELECT 
           CASE 
               WHEN MONTH(a.post_date) >= 7 THEN YEAR(a.post_date)
               ELSE YEAR(a.post_date) - 1
           END AS fiscal_year,
           CASE 
               WHEN MONTH(a.post_date) BETWEEN 7 AND 9 THEN 1
               WHEN MONTH(a.post_date) BETWEEN 10 AND 12 THEN 2
               WHEN MONTH(a.post_date) BETWEEN 1 AND 3 THEN 3
               WHEN MONTH(a.post_date) BETWEEN 4 AND 6 THEN 4
           END AS fiscal_quarter,
           a.transaction_amount,
           ac.section_type,
           a.account_number
       FROM h1b.accounting a
       JOIN h1b.account_section ac ON a.account_number = ac.account_number
   ) base_data
   WHERE fiscal_year = 2023
   GROUP BY fiscal_year, fiscal_quarter
),

-- Calculate Seasonal Factors
seasonal_factors AS (
   SELECT 
       fiscal_quarter,
       AVG(revenue) as avg_quarterly_revenue,
       AVG(revenue) / SUM(revenue) OVER () * 4 as seasonal_factor
   FROM base_revenue
   GROUP BY fiscal_quarter
),

-- Generate Future Periods
future_periods AS (
   SELECT 2024 as fiscal_year, q.n as fiscal_quarter
   FROM (SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) q
   UNION ALL
   SELECT 2025 as fiscal_year, q.n as fiscal_quarter
   FROM (SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) q
   UNION ALL
   SELECT 2026 as fiscal_year, q.n as fiscal_quarter
   FROM (SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) q
),

-- Calculate Predictions
predictions AS (
   SELECT 
       f.fiscal_year,
       f.fiscal_quarter,
       -- Revenue prediction with 2.5% annual increase
       b.revenue * POWER(1.025, f.fiscal_year - 2023) * s.seasonal_factor as predicted_revenue,
       -- COGS prediction with 2% annual increase
       b.cogs * POWER(1.02, f.fiscal_year - 2023) * s.seasonal_factor as predicted_cogs,
       -- Labor costs with 3% annual increase
       b.labor_costs * POWER(1.03, f.fiscal_year - 2023) * s.seasonal_factor as predicted_labor_costs,
       -- Other SGA with 2% annual increase
       b.other_sga * POWER(1.02, f.fiscal_year - 2023) * s.seasonal_factor as predicted_other_sga
   FROM future_periods f
   JOIN seasonal_factors s ON f.fiscal_quarter = s.fiscal_quarter
   CROSS JOIN (
       SELECT AVG(revenue) as revenue, AVG(cogs) as cogs, 
              AVG(labor_costs) as labor_costs, AVG(other_sga) as other_sga 
       FROM base_revenue
   ) b
)

-- Final Output with Financial Metrics
SELECT 
   fiscal_year,
   fiscal_quarter,
   ROUND(predicted_revenue, 2) as revenue,
   ROUND(predicted_cogs, 2) as cogs,
   ROUND(predicted_labor_costs, 2) as labor_costs,
   ROUND(predicted_other_sga, 2) as other_sga,
   ROUND(predicted_cogs / predicted_revenue * 100, 2) as cogs_ratio,
   ROUND(predicted_revenue - predicted_cogs, 2) as gross_margin,
   ROUND(predicted_revenue - predicted_cogs - predicted_labor_costs - predicted_other_sga, 2) as net_profit
FROM predictions
ORDER BY fiscal_year, fiscal_quarter;

/*
Financial Prediction Model Assumptions:
- Base Period: Using FY2023 as the baseline for projections
- Time Span: Predictions for FY2024-FY2026 by quarter
- Revenue Growth: 2.5% annual price increase applied
- Cost Structure:
  - COGS: 2% annual increase due to inflation
  - Labor Costs: 3% annual increase
  - Other SGA: 2% annual increase aligned with inflation
- Seasonality: Quarterly patterns based on FY2023 actual data
- Growth Rates: Applied uniformly across quarters within each fiscal year
- All projections account for historical seasonal variations
*/