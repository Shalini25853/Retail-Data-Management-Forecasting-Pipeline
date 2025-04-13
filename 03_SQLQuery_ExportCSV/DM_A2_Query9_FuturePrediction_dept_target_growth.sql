WITH annual_sales AS (
    -- Calculate annual sales for the most recent fiscal year (FY2023)
    SELECT 
        s.department_id,
        SUM(s.sales_amount) as current_sales,
        COUNT(DISTINCT s.item_id) as item_count,
        MAX(s.sales_amount) as max_price,
        AVG(s.sales_amount) as avg_price,
        -- Calculate quarterly distribution
        SUM(CASE 
            WHEN MONTH(s.sales_date) BETWEEN 7 AND 9 THEN s.sales_amount 
            ELSE 0 
        END) as q1_sales,
        SUM(CASE 
            WHEN MONTH(s.sales_date) BETWEEN 10 AND 12 THEN s.sales_amount 
            ELSE 0 
        END) as q2_sales,
        SUM(CASE 
            WHEN MONTH(s.sales_date) BETWEEN 1 AND 3 THEN s.sales_amount 
            ELSE 0 
        END) as q3_sales,
        SUM(CASE 
            WHEN MONTH(s.sales_date) BETWEEN 4 AND 6 THEN s.sales_amount 
            ELSE 0 
        END) as q4_sales
    FROM h1b.sales s
    WHERE s.sales_amount != 0
    AND CASE 
        WHEN MONTH(s.sales_date) >= 7 THEN YEAR(s.sales_date)
        ELSE YEAR(s.sales_date) - 1
    END = 2023
    GROUP BY s.department_id
),
sales_target AS (
    -- Project growth targets for next two fiscal years
    SELECT 
        department_id,
        current_sales,
        -- FY2024 Targets
        CASE 
            WHEN department_id IN (1, 2) THEN current_sales * 1.25
            WHEN department_id IN (5, 13) THEN current_sales * 1.20
            ELSE current_sales * 1.15
        END as fy2024_target,
        -- FY2025 Targets
        CASE 
            WHEN department_id IN (1, 2) THEN current_sales * 1.5625 -- (1.25^2)
            WHEN department_id IN (5, 13) THEN current_sales * 1.44  -- (1.20^2)
            ELSE current_sales * 1.3225 -- (1.15^2)
        END as fy2025_target,
        q1_sales, q2_sales, q3_sales, q4_sales,
        item_count,
        max_price,
        avg_price
    FROM annual_sales
)
SELECT 
    d.department_id,
    -- Current and Target Metrics
    ROUND(d.current_sales, 2) as fy2023_sales,
    ROUND(d.fy2024_target, 2) as fy2024_target,
    ROUND(d.fy2025_target, 2) as fy2025_target,
    -- Growth Analysis
    ROUND(d.fy2024_target - d.current_sales, 2) as fy2024_required_growth,
    ROUND(d.fy2025_target - d.fy2024_target, 2) as fy2025_required_growth,
    -- Quarterly Distribution
    ROUND(d.q1_sales / d.current_sales * 100, 1) as q1_percentage,
    ROUND(d.q2_sales / d.current_sales * 100, 1) as q2_percentage,
    ROUND(d.q3_sales / d.current_sales * 100, 1) as q3_percentage,
    ROUND(d.q4_sales / d.current_sales * 100, 1) as q4_percentage,
    -- Product Analysis
    d.item_count,
    ROUND(d.max_price, 2) as max_price,
    ROUND(d.avg_price, 2) as avg_price
FROM sales_target d
ORDER BY d.current_sales DESC;

/*
Analysis Framework:
1. Base Period:
   - Using full FY2023 data as baseline
   - Provides seasonal patterns through quarterly breakdown

2. Growth Projections:
   - FY2024: First year growth (15-25%)
   - FY2025: Compound growth (32.25-56.25%)

3. Seasonal Analysis:
   - Quarter-by-quarter distribution
   - Helps in setting realistic periodic targets

4. Product Metrics:
   - Item diversity (item_count)
   - Pricing strategy (max_price, avg_price)

Purpose:
- More stable baseline using full year data
- Better seasonal trend visibility
- Realistic growth targets considering product mix
*/