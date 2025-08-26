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
### 1) Monthly Sales Performance
> Calculate total sales for each month.
``` sql
select 	EXTRACT(year from salesdate) as year,
		EXTRACT(month from salesdate) as month,
		count(*) as sales_count 
		from sales
		group by 1,2 
		order by 2;
```
|"year"|	"month"	|"sales_count"|
-------|-----------|--------------|
|2018|	1	|1607050|
|2018	|2	|1451366|
|2018	|3	|1609190|
|2018|	4	|1556091|
|2018	|5	|534428|

> Compare sales performance across different product categories each month
``` sql
select EXTRACT(year from s.salesdate) as year,
	   EXTRACT(month from s.salesdate) as month,
	   p.category_id,
	   c.categoryname,
	   count(s.salesid) as sales_count ,
	   Rank() OVER(partition by EXTRACT(month from s.salesdate) order by count(s.salesid) desc) as rank
from sales as s 
			  join
			  products as p
			  on p.productid = s.productid
			  join
			  category as c 
			  on c.categoryid = p.category_id
			  group by 1,2,3,4
			  order by 2,3
```
