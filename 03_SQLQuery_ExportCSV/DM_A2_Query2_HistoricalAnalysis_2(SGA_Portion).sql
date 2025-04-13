-- Analysis Historical Performance 2

USE h1b;

WITH fiscal_periods AS (
   SELECT 
       -- Calculate Fiscal Year (Starting from July)
       CASE 
           WHEN MONTH(a.post_date) >= 7 
           THEN YEAR(a.post_date)
           ELSE YEAR(a.post_date) - 1
       END AS fiscal_year,
       -- Calculate Quarter
       CASE 
           WHEN MONTH(a.post_date) BETWEEN 7 AND 9 THEN 1
           WHEN MONTH(a.post_date) BETWEEN 10 AND 12 THEN 2
           WHEN MONTH(a.post_date) BETWEEN 1 AND 3 THEN 3
           WHEN MONTH(a.post_date) BETWEEN 4 AND 6 THEN 4
       END AS fiscal_quarter,
       a.transaction_amount,
       a.account_number,
       ac.account_description
   FROM h1b.accounting a
   JOIN h1b.account_section ac ON a.account_number = ac.account_number
   WHERE ac.section_type = 'SGA'
)
SELECT 
   fiscal_year,
   fiscal_quarter,
   -- Total SGA expenses
   SUM(transaction_amount) as total_sga,
   -- Personnel related expenses (Salaries, Benefits, Insurance)
   SUM(CASE 
       WHEN account_number BETWEEN 51000 AND 58999 
       THEN transaction_amount ELSE 0 
   END) as personnel_expenses,
   -- Office operational costs (Supplies, Communications)
   SUM(CASE 
       WHEN account_number BETWEEN 62000 AND 62999 
       AND account_number NOT IN (62700, 62710, 62800)
       THEN transaction_amount ELSE 0 
   END) as office_operations,
   -- Marketing, Travel and Entertainment expenses
   SUM(CASE 
       WHEN account_number IN (62700, 62710, 62800)
       THEN transaction_amount ELSE 0 
   END) as marketing_and_travel,
   -- Facility maintenance and operational supplies
   SUM(CASE 
       WHEN account_number BETWEEN 63000 AND 63999
       THEN transaction_amount ELSE 0 
   END) as facility_expenses,
   -- Other administrative expenses (Licenses, Insurance, etc)
   SUM(CASE 
       WHEN account_number >= 66000
       THEN transaction_amount ELSE 0 
   END) as other_administrative
FROM fiscal_periods
GROUP BY fiscal_year, fiscal_quarter
ORDER BY fiscal_year, fiscal_quarter;

/**
SGA Classification Logic and Rationale:

*Personnel Expenses (51000-58999):
	Includes all employee-related costs
	Salaries, benefits, payroll taxes, insurance
	Basis: Standard accounting practice for labor cost grouping

*Office Operations (62000-62999):
	Daily office running costs
	Supplies, communications, equipment
	Excludes marketing/travel expenses
	Basis: Operational support function grouping

*Marketing and Travel (62700, 62710, 62800):
	Marketing, travel, and promotional expenses
	Separated due to direct business development nature
	Basis: Revenue generation support activities

*Facility Expenses (63000-63999):
	Building and facility maintenance costs
	Cleaning, operational supplies, uniforms
	Basis: Physical infrastructure maintenance

*Other Administrative (66000+):
	Remaining administrative expenses
	Licenses, insurance, bank charges
	Basis: General administrative overhead

Classification is based on:
	Account number ranges following standard chart of accounts
	Nature of expenses and their business function
	Common industry practice for expense categorization
**/