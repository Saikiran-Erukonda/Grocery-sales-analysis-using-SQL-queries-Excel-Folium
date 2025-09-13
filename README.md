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
|-------|-----------|--------------|
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
### 2) Top products Identification
> Rank Products based on total sales revenue
``` sql
select s.productid,p.productname,
	   round(sum(s.totalprice)::numeric,2) as sales_revenue,
	   rank() over(order by sum(s.totalprice) desc) as rank
	   from sales as s 
			  join
			  products as p
			  on p.productid = s.productid
	   group by 1,2;
```
> Analyze sales quantity and revenue to identify high-demand products.
``` sql
select s.productid,p.productname,
	   count(s.salesid) as sales_count,
	   round(sum(s.totalprice)::numeric,2) as sales_revenue,
	   sum(s.quantity) as quantity,
	   rank() over(order by sum(s.quantity) desc) as rank
	   from sales as s 
			  join
			  products as p
			  on p.productid = s.productid
	   group by 1,2;
```

> Examine the impact of product classification on sales performance
``` sql
select p.class_,
	   count(s.salesid) as sales_count,
	   round(sum(s.totalprice)::numeric,2) as sales_revenue,
	   sum(s.quantity) as quantity,
	   rank() over(order by count(s.salesid) desc) as rank
	   from sales as s 
			  join
			  products as p
			  on p.productid = s.productid
	   group by 1;
```

### 3) Customer Purchase behaviour
> Segment customers based on their purchase frequency and total spend.

|parameters|value|
|----------|-----|
|min purchase frequency| 36|
|max purchase frequency|103 |
|avg purchase frequency| 68|
|min spend |1971 $|
|max spend |130324 $|
|avg spend|43868 $|

The customer whose purchase_frequency>90 and total spend>60000 $ then categorized as 'GOLD' segment else "SILVER"
``` sql
Select c_customer_segment as Segment,count(customerid) as members from (
SELECT 
  s.customerid,
  c.firstname || ' ' || c.middleinitial || ' ' || c.lastname AS name,
  COUNT(s.salesid) AS purchase_frequency,
  Round(sum(s.totalprice)::numeric,2) as total_spend,
  Case 
  	when (Round(sum(s.totalprice)::numeric,2) > 60000) OR (count(s.salesid) > 90) Then 'GOLD'
	else 'SILVER' 
	END as C_customer_segment
FROM customers AS c
JOIN sales AS s ON s.customerid = c.customerid
GROUP BY s.customerid, name
ORDER BY total_spend desc )as c_cat 
group by 1;
```
The count of customers in each segment as per above Query
|Segment| Members|
|-------|-------|
|*GOLD*	|29421|
|*SILVER*|	69338|

> Identify the repeat customers vs 1 time buyer

> Analyze average order value and basket size per customer.
``` sql
select customerid,
	 round(avg(totalprice)::numeric,2) as avg_order_value,
	 sum(quantity) as basket_size
	 from sales
group by 1 order by 2,3 asc
```

### 4) Sales Person Effectiveness
> Calculate total sales attributed  to each  sales person
``` sql
select salespersonid,
	   count(salesid) as sales_done,
	   rank() over(order by count(salesid) desc) as rank
	   from sales
	   group by 1 order by 1;
```
|salespersonid|sales_done|rank|
|----|---|---|
|1	|293394|	19|
|2	|293737	|13|
|3	|293175	|21|
|4	|294744	|2|
|5	|293711	|14|
|6	|293973	|9|
|7	|293967	|10|
|8	|294449	|3|
|9	|294180	|5|
|10	|293888	|11|
|11	|294110	|6|
|12	|293164	|22|
|13	|293530	|18|
|14	|294035	|8|
|15	|294096	|7|
|16	|293685	|16|
|17	|292521	|23|
|18	|294419	|4|
|19	|293875	|12|
|20	|293562	|17|
|21	|294983	|1|
|22	|293224	|20|
|23	|293703	|15|
