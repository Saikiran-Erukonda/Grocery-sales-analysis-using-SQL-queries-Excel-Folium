create table sales(SalesID	int primary key,
				   SalesPersonID int,
				   CustomerID int,
				   ProductID int,
				   Quantity	int,
				   Discount	float,
				   TotalPrice float,
				   SalesDate Date, 
				   TransactionNumber varchar(100),
				  constraint fk_emp foreign key(SalesPersonID) references Employee(EmployeeID),
				  constraint fk_customer foreign key(CustomerID) references customers(CustomerID),
				  constraint fk_product foreign key(ProductID) references Products(ProductID));
				  
UPDATE sales as s
SET totalprice = (s.quantity * p.price) * (1-s.discount)
from products as p
where s.productid = p.productid ; 

UPDATE sales set totalprice = Round(totalprice::numeric,2);

-- ----------------------------------------------------------------------------


SELECT EXTRACT(YEAR from salesdate) as   Year,
		EXTRACT(Month from salesdate) as Month,
		Count(salesid) as sales_m,
		Round(sum(totalprice::numeric),2) as Revenue
		from sales
		group by 1,2
		order by 2;

select avg(sales_d) as Avg_day_sale from 
(SELECT EXTRACT(YEAR from salesdate) as   Year,
		EXTRACT(Month from salesdate) as Month,
		EXTRACT(day from salesdate) as day,
		Count(salesid) as sales_d,
		Round(sum(totalprice::numeric),2) as Revenue
		from sales
		where TO_CHAR(salesdate,'yyyy-mm-dd') >= '2018-05-01' 
		-- or salesdate is null
		group by 1,2,3
		order by 2,3);
		
select * from sales  order by 1 limit 5000;

with ranked_nulls as
(SELECT
    salesid,salesdate,
    ROW_NUMBER() OVER (ORDER BY salesid) AS rn
FROM sales
WHERE salesdate IS NULL)

Update sales 
SET salesdate = CASE
					when r.rn <= 51878 then date '2018-05-10'
					else date '2018-05-11'
			    end
from ranked_nulls as r
where sales.salesid = r.salesid;


select * from sales where salesid =  51 
							 or
						  salesid =  228 
						  or
						  salesid =  6706610
						  or
						  salesid =  6706775;
-- -----------------------------------------------------------------------successfully all data verified-
--1. Monthly Sales Performance
-- Calculate total sales for each month.
select 	EXTRACT(year from salesdate) as year,
		EXTRACT(month from salesdate) as month,
		count(*) as sales_count 
		from sales
		group by 1,2 
		order by 2;

-- Compare sales performance across different product categories each month.
select * from sales limit 10 ;
select * from products ;
select * from category;

Create view Monthly_category_sales as 
(select EXTRACT(month from s.salesdate) as month,
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
			  order by 1,4 desc);

-- Top Products Identification
-- Rank products based on total sales revenue.
select * from sales limit 5
select * from products limit 10;

select s.productid,p.productname,
	   round(sum(s.totalprice)::numeric,2) as sales_revenue,
	   rank() over(order by sum(s.totalprice) desc) as rank
	   from sales as s 
			  join
			  products as p
			  on p.productid = s.productid
	   group by 1,2;
	   
-- Analyze sales quantity and revenue to identify high-demand products.
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

-- Examine the impact of product classifications on sales performance.
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
	   
-- Customer purchase behaviour
-- Segment customers based on their purchase frequency and total spend.
select *  from customers limit 5;
Select c_customer_segment as Segment,count(customerid) as members,Sum(total_spend) from (
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

-- Identify repeat customers versus one-time buyers.
-- January month 
Select * from sales limit 2000;

with jan as (select customerid,count(distinct salesdate) as jan_visit from sales
where TO_CHAR(salesdate,'yyyy-mm') = '2018-01'
group by 1), -- January month //no 1-time buyer

feb as (select customerid,count(distinct salesdate) as feb_visit from sales
where TO_CHAR(salesdate,'yyyy-mm') = '2018-02'
group by 1), -- February 

mar as(select customerid,count(distinct salesdate) as mar_visit from sales
where TO_CHAR(salesdate,'yyyy-mm') = '2018-03'
group by 1), -- March

apr as (select customerid,count(distinct salesdate) as apr_visit from sales
where TO_CHAR(salesdate,'yyyy-mm') = '2018-04'
group by 1)--April

select coalesce(jan.customerid,feb.customerid,mar.customerid,apr.customerid) as customerid
	from jan
	inner join feb on jan.customerid = feb.customerid
	inner join mar on coalesce(jan.customerid = feb.customerid)
	inner join 



-- Analyze average order value and basket size.
select * from sales limit 200;
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
		

-- 4. Sales person Effectiveness
-- Calculate total sales attributed  to each  sales person
-- Identify top performing and underperforming sales staff
select * from employee;
select s.salespersonid,
	   e.firstname || ' ' || e.lastname AS name,
	   count(s.salesid) as sales_done,
	   rank() over(order by count(s.salesid) desc) as rank
	   from sales as s
	   join employee as e
	   on s.salespersonid = e.employeeid
	   group by 1,2 order by 1;

-- Analyze sales trends based on individual salesperson contributions over time
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
--
Select 
	COALESCE(jan.salespersonid,feb.salespersonid,mar.salespersonid,apr.salespersonid) as salespersonid,
	e.firstname || ' ' || e.lastname AS name,jan_sales,jan_rank,
	feb_sales,feb_rank,
	mar_sales,mar_rank,
	apr_sales,apr_rank
	from jan
	full outer join feb on jan.salespersonid =feb.salespersonid
	full outer join mar on COALESCE(jan.salespersonid,feb.salespersonid) = mar.salespersonid
	full outer join apr on COALESCE(jan.salespersonid,feb.salespersonid,mar.salespersonid) = apr.salespersonid
	join employee as e on jan.salespersonid = e.employeeid
	order by salespersonid
	
--5. Geographical sales insights
-- Map sales data to specific cities and countries to identify top performing region
-- // US is only country as of now
select  * from sales limit 10;
select * from customers limit 10;
select  * from city;
select * from products ;
select * from category; 

select c.cityid,ci.city_name,count(s.salesid) as city_sales,
		rank() over(order by count(s.salesid) desc) as rank
		from sales as s
		join customers as c on s.customerid = c.customerid
		left join city as ci on  c.cityid= ci.city_id 
		group by 1,2
		order by 3 desc; 

-- City wise Top Category SElling

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

						  