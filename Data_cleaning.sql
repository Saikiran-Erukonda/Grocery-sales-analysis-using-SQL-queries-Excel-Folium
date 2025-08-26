-- check customers table where it is null
select * from customers where firstname = 'NULL'
								or 
								middleinitial = 'NULL'
								or 
								lastname = 'NULL'
								or 
								cityid is NULL
								or 
								address = 'NULL';

-- observed nulls in middleinitial and replaced with ''
Update customers set middleinitial = '' where middleinitial = 'NULL';

select * from employee ; -- everything is fine

-- there were no nulls but Unknowns in Resistant and isallergic.
select * from products where productname is NULL
							 or price is NULL
							 or category_id is NULL
							 or class_ is NULL
							 or modifydate is NULL
							 or resistant = 'Unknown'
							 or isallergic = 'Unknown'
							 or vitalitydays is NULL; --226 rows / 452 rows
-- As of now, we didn't changed in this product table

select * from all_sales order by 1 limit 300;
select * from all_sales where salesid is NULL
							or salespersonid is NULL
							or customerid is NULL
							or productid is NULL
							or quantity is NULL
							or discount is NULL
							or totalprice is NULL
							or effective_salesdate is NULL
							or transactionnumber is NULL
							order by 1;

-- Now give foriegn key to this new_table 
select * from sales order by 1;
select * from sales where salesid is NULL
							or salespersonid is NULL
							or customerid is NULL
							or productid is NULL
							or quantity is NULL
							or discount is NULL
							or totalprice is NULL
							or salesdate is NULL
							or transactionnumber is NULL
							order by 1;
-- Issues 
-- 1. totalprice is 0 for all rows. Need to calculate with help of products table and sales table
-- 2. Sales date is NULL for 67,526 rows /67,58,125 rows
-- Does it affecting revenues ?
select Extract(YEAR from salesdate) as Year,
	     Extract(Month from salesdate) as month,
       count(salesid) as sales_cnt,
			 sum(totalprice) as revenue
					from sales 
					group by 1,2
					order by 1,2;

-- --------------------------------------------------------------------------
-- ISSUE 1
UPDATE sales as s
SET totalprice = (s.quantity * p.price) * (1-s.discount)
from products as p
where s.productid = p.productid ; 

UPDATE sales set totalprice = Round(totalprice::numeric,2);

-- ----------------------------------------------------------------------------
-- ISSUE 2

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
