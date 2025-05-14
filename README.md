# Retail-Data-Management-Forecasting-Pipeline
Designed and implemented a full data pipeline to clean, transform, and analyze retail sales data for historical insights and future forecasting.
#  Retail Data Management & Forecasting Pipeline

This project was developed as part of a Data Management course, focusing on end-to-end data handling—from ingestion and transformation to analysis and forecasting—using retail sales and product datasets.

## Overview

The objective was to build a robust data pipeline that could:
- Integrate and clean multiple retail data sources
- Analyze historical trends using SQL
- Predict future profit and department-wise growth
- Automate processes using PowerShell
- Document data structure using ER diagrams

## Tools & Technologies

- **SQL (MySQL / Azure SQL)** – Historical & future queries
- **Excel / Power Query** – Data cleaning & transformation
- **PowerShell** – Automation of data operations
- **CSV & XLSX** – Transformed datasets
- **ER Diagram** – Relational schema design

##  Project Structure

```bash
DM_A2_Trio6_Pack/
│
├── 01_Excel_Power_Query/
│   ├── sales_final_3.xlsx
│   ├── product cleaned final.xlsx
│   └── BBdata.xlsx
│
├── 02_Transformed_CSV/
│   └── Cleaned CSVs for SQL ingestion
│
├── 03_SQLQuery_ExportCSV/
│   ├── DM_A2_Query1_HistoricalAnalysis_1.sql
│   ├── ... up to Query9_FuturePrediction.sql
│   └── Query1.csv ... Query9.csv (results)
│
├── 04_Command_PowerShell/
│   └── DM_A2_PS_command.txt
│
├── 05_ER Diagram/
│   └── ER-Diagram.png
│
├── DM_A2_Trio6_Explanation.mp4
└── Project_Report.docx
