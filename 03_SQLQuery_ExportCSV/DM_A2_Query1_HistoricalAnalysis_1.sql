-- Analysis Historical Performance 1

USE h1b;

WITH fiscal_periods AS (
    SELECT 
        -- Calculate Fiscal Year (Starting from July)
        CASE 
            WHEN MONTH(a.post_date) >= 7 
            THEN YEAR(a.post_date)
            ELSE YEAR(a.post_date) - 1
        END AS fiscal_year,
        -- Calculate Quarter (Q1: Jul-Sep, Q2: Oct-Dec, Q3: Jan-Mar, Q4: Apr-Jun)
        CASE 
            WHEN MONTH(a.post_date) BETWEEN 7 AND 9 THEN 1
            WHEN MONTH(a.post_date) BETWEEN 10 AND 12 THEN 2
            WHEN MONTH(a.post_date) BETWEEN 1 AND 3 THEN 3
            WHEN MONTH(a.post_date) BETWEEN 4 AND 6 THEN 4
        END AS fiscal_quarter,
        a.transaction_amount,
        s.section_type
    FROM h1b.accounting a
    JOIN h1b.account_section s ON a.account_number = s.account_number
)
SELECT 
    fiscal_year,
    fiscal_quarter,
    -- Calculate Revenue (Convert negative values to positive)
    ABS(SUM(CASE WHEN section_type = 'REVENUE' THEN transaction_amount ELSE 0 END)) as revenue,
    -- Sum of COGS
    SUM(CASE WHEN section_type = 'COGS' THEN transaction_amount ELSE 0 END) as cogs,
    -- Sum of SGA
    SUM(CASE WHEN section_type = 'SGA' THEN transaction_amount ELSE 0 END) as sga,
    -- Calculate COGS to Sales Ratio (as percentage)
    ROUND(
        SUM(CASE WHEN section_type = 'COGS' THEN transaction_amount ELSE 0 END) /
        ABS(SUM(CASE WHEN section_type = 'REVENUE' THEN transaction_amount ELSE 0 END)) * 100,
        2
    ) as cogs_sales_ratio,
    -- Calculate Gross Margin (Revenue - COGS)
    ABS(SUM(CASE WHEN section_type = 'REVENUE' THEN transaction_amount ELSE 0 END)) -
    SUM(CASE WHEN section_type = 'COGS' THEN transaction_amount ELSE 0 END) as gross_margin,
    -- Calculate Net Profit (Revenue - COGS - SGA)
    ABS(SUM(CASE WHEN section_type = 'REVENUE' THEN transaction_amount ELSE 0 END)) -
    SUM(CASE WHEN section_type = 'COGS' THEN transaction_amount ELSE 0 END) -
    SUM(CASE WHEN section_type = 'SGA' THEN transaction_amount ELSE 0 END) as net_profit_before_tax
FROM fiscal_periods
GROUP BY fiscal_year, fiscal_quarter
ORDER BY fiscal_year, fiscal_quarter;