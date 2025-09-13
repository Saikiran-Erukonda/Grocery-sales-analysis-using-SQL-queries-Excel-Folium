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
|2018   |1	|1607050|
|2018	|2	|1451366|
|2018	|3	|1609190|
|2018|	4	|1556091|
|2018	|5	|534428|

<img src="https://github.com/user-attachments/assets/cf5db461-8662-46b3-be3d-ccee63a9cae2" alt="Monthly sales" style="width:40%; height:auto;" />

> Compare sales performance across different product categories each month
``` sql
select EXTRACT(month from s.salesdate) as month,
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
			  group by 1,2,3
			  order by 1,4 desc
```
|Monthly category-wise sales|Category-wise sales|
|---|---|
|<img src="https://github.com/user-attachments/assets/b9ececc4-f01e-4fbf-8dc5-ff5ac0f54214"  alt="Monthly Category sales" style ="width:100%; height:auto;" /> |<img src="https://github.com/user-attachments/assets/b426a73a-dc7b-40a4-b016-d930226461a0" alt="Sales by Category" style= "width:85%; height:auto;" />|

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
| Top 5 Selling Products by Revenue | Top 5 Selling products by Quantity |
|-------------------------|--|
|<img src="https://github.com/user-attachments/assets/88a91afd-e092-4edf-8a7c-77d6cf123685" style= "width:90%; height:auto;" /> |<img src="https://github.com/user-attachments/assets/23bdc7ae-feef-4fc3-96ed-22543ccb70f7" style= "width:80%; height:auto;" />|


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
<img src="https://github.com/user-attachments/assets/54aebd6e-6f60-488b-8ad6-1a52fd39de7c" alt = "Class performance" style= "width:40%; height:auto;" />

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

|No.of Customers by Segment|Revenue based on Segment|
|--|---|
|<img src="https://github.com/user-attachments/assets/535f85bd-5116-4c6b-bfbe-f2a8095b7d06" style= "width:100%; height:auto;" />|<img src="https://github.com/user-attachments/assets/4eeddc1c-b122-4cd1-846b-2b4fa9e64659" style= "width:90%; height:auto;" />|
> Identify the repeat customers vs 1 time buyer

> Analyze average order value and basket size per customer.
``` sql
with table1 as (select customerid,
	 round(avg(totalprice)::numeric,2) as avg_order_value,
	 sum(quantity) as basket_size
	 from sales
group by 1 order by 2,3 asc)
-- Starting value 37 to 1591 
-- divide into 4 parts 0 - 400 | 400 -800 |800-1200| 1200 -1600
Select Case 
		when avg_order_value < 401 then '0$ to 400$'
		when avg_order_value > 400 and avg_order_value < 801 then '401$ to 800$'
		when avg_order_value > 800 and avg_order_value <1201 then '801$ to 1200$'
		when avg_order_value > 1200 and avg_order_value < 1600 then '1201$ to 1600$'
		end as bins,
		count(customerid) as no_of_customers,
		avg(basket_size) as basket_size
		from table1
		group by 1
		order by 1;
```
<img src="https://github.com/user-attachments/assets/9bc273d1-f437-4b81-b9ce-f06b97eed39b" style ="width:60%; height:auto;" />


### 4) Sales Person Effectiveness
> Calculate total sales attributed  to each  sales person and Identify top performing and underperforming sales staff
``` sql
select salespersonid,
	   count(salesid) as sales_done,
	   rank() over(order by count(salesid) desc) as rank
	   from sales
	   group by 1 order by 1;
```
> Analyze sales trends based on individual salesperson contributions over time

``` sql
with jan as(select salespersonid,
	   count(salesid) as jan_sales,
	   rank() over(order by count(salesid) desc) as jan_rank
	   from sales
	   where TO_Char(salesdate,'yyyy-mm')='2018-01'
	   group by 1),
feb as(select salespersonid,
	   count(salesid) as feb_sales,
	   rank() over(order by count(salesid) desc) as feb_rank
	   from sales
	   where TO_Char(salesdate,'yyyy-mm')='2018-02'
	   group by 1),
mar as(select salespersonid,
	   count(salesid) as mar_sales,
	   rank() over(order by count(salesid) desc) as mar_rank
	   from sales
	   where TO_Char(salesdate,'yyyy-mm')='2018-03'
	   group by 1),
apr as(select salespersonid,
		count(salesid) as apr_sales,
		rank() over(order by count(salesid) desc) as apr_rank
		from sales
		where To_char(salesdate,'yyyy-mm')='2018-04'
		group by 1)
-- final join
Select 
	COALESCE(jan.salespersonid,feb.salespersonid,mar.salespersonid,apr.salespersonid) as salespersonid,
	jan_sales,jan_rank,
	feb_sales,feb_rank,
	mar_sales,mar_rank,
	apr_sales,apr_rank
	from jan
	full outer join feb on jan.salespersonid =feb.salespersonid
	full outer join mar on COALESCE(jan.salespersonid,feb.salespersonid) = mar.salespersonid
	full outer join apr on COALESCE(jan.salespersonid,feb.salespersonid,mar.salespersonid) = apr.salespersonid
	order by salespersonid
```

|Jan Sales|Feb Sales|March Sales|April Sales| Overall Sales|
|----|---|---|--|--|
|<img src="https://github.com/user-attachments/assets/62624ac3-77f9-45e8-85b3-ad84de20ef09" alt="Jan sales" style ="width:100%; height:auto;" /> |<img  src="https://github.com/user-attachments/assets/21e38925-33b9-4f3b-9b57-a516bfc14704" alt="feb sales" style ="width:100%; height:auto;" />|<img  src="https://github.com/user-attachments/assets/02f10f35-d501-4cb1-8b7d-38490c9df4ee" alt="March sales" style ="width:100%; height:auto;" />|<img   src="https://github.com/user-attachments/assets/f3f7293a-8afb-4d9f-b39d-a598e614031f" alt="April sales" style ="width:100%; height:auto;" />|<img   src="https://github.com/user-attachments/assets/9b9e8ff3-f970-4c49-811f-695d28191915" alt="Overall sales" style ="width:100%; height:auto;" />|



### 5) Geographical Sales insights
> Map salesdata to specific cities and countries to identify top performing region
``` sql
select c.cityid,ci.city_name,count(s.salesid) as city_sales,
		rank() over(order by count(s.salesid) desc) as rank
		from sales as s
		join customers as c on s.customerid = c.customerid
		left join city as ci on  c.cityid= ci.city_id 
		group by 1,2
		order by 3 desc; 
```
> City wise 2nd last Selling Category (rank = 10) 
``` sql
With City_cat_sales as (Select  c.cityid,ci.city_name,
		cat.categoryname,
		count(s.salesid) as city_sales,
		rank() over(partition by ci.city_name order by count(salesid) desc) as rank 
		from sales as s
		join customers as c on s.customerid = c.customerid
		left join products as p on p.productid = s.productid
		left join city as ci on  c.cityid= ci.city_id
		left join category as cat on cat.categoryid = p.category_id
		group by 1,2,3
		order by 1,4 desc)
Select city_name,categoryname,city_sales,rank from City_cat_sales where rank = 10 -- change rank 0 to 11 to know position
``` 
