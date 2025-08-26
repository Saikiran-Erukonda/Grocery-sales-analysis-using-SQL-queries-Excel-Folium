# Grocery-sales-analysis
## About Dataset
The Grocery Sales Database is a structured relational dataset designed for analyzing sales transactions, customer demographics, product details, employee records, and geographical information across multiple cities and countries. This dataset is ideal for data analysts, data scientists, and machine learning practitioners looking to explore sales trends, customer behaviors, and business insights.

|File Name	|Description|
|-----------|------------|
|`categories.csv`|Defines the categories of the products.|
| `cities.csv` |	Contains city-level geographic data.|
|`countries.csv`	|Stores country-related metadata.|
|`customers.csv`	|Contains information about the customers who make purchases.|
| `employees.csv`|	Stores details of employees handling sales transactions.|
|`products.csv`|	Stores details about the products being sold.|
|`sales.csv` |	Contains transactional data for each sale.|

## 1. Data Wrangling (ETL process)
- The Queries which are needed for creating Database & table structures in PostgreSQL are shown in       [`setup_tables.sql`](https://github.com/Saikiran-Erukonda/Grocery-sales-analysis/blob/main/setup_tables.sql)
-  The resulting Database schema is shown below
<img width="1184" height="777" alt="Screenshot 2025-08-25 153043" src="https://github.com/user-attachments/assets/5a25a5fa-29c6-4f04-b661-554cc4a4ab20" />

## 2. Data Cleaning
- The issues found in data cleaning and their cleaning steps as query are demonstrated in [`Data_cleaning.sql`](https://github.com/Saikiran-Erukonda/Grocery-sales-analysis/blob/main/Data_cleaning.sql)
- After successful cleaning of all tables. Export the tables and stored them as '.csv' files in `cleaned_dataset` folder
## 3. Processing data.

## 4. Descriptive Statistics.
