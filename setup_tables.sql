CREATE TABLE Country(country_id int Primary Key,
					country_Name VARCHAR(200),
					Country_code varchar(5)
					)
					
DROP Table if exists City;
Create TABLE City(City_id int Primary Key,
				  City_Name varchar(200),
				  Zipcode varchar(15),
				  country_id int,
				  constraint fk_country_id foreign key(country_id) references Country(country_id))

Create TABLE Category(
			CategoryID int Primary Key,CategoryName Varchar(30))

DROP Table if exists Products;
CREATE TABLE Products(ProductID INT Primary key,
			 ProductName VARCHAR(150),
			 Price FLOAT,
			 Category_id INT,
			 Class_ VARCHAR(15),
			 ModifyDate DATE,
			 Resistant VARCHAR(15),
			 IsAllergic VARCHAR(15),
			 VitalityDays INT,
			 constraint fk_categoryid foreign key(Category_id) references Category(CategoryID));

create Table customers(CustomerID int Primary key, 	
					   FirstName	varchar(50),
					   MiddleInitial varchar(5),	
					   LastName	varchar(40),
					   CityID	int,
					   Address  varchar(150),
					   constraint fk_city foreign key(CityID) references City(City_id));


Create table Employee(EmployeeID int primary key,
					  FirstName	varchar(40),
					  MiddleInitial varchar(3),
					  LastName varchar(40),
					  BirthDate Date,
					  Gender varchar(3),
					  CityID int,
					  HireDate date,
					  constraint fk_city foreign key(CityID) references City(City_id));

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

-- Start importing data in order country,city,category,products,customers,Employee,Sales.
select * from category;
select * from country;
select * from city;
select * from customers;
select * from employee;
select  * from products;


select count(*) from products where price = 0;  -- there were no product with price Zero.
select count(*) from products where resistant = 'Unknown';  --there were 140 Unknown in resistant column
select count(*) from products where isallergic = 'Unknown'; --there were 130 Unknown in isallergic column


-- DATA Cleaning and handling missing values;
-- check nulls in column price
select * from sales limit 250;
select count(*) from sales where totalprice = 0; --  all are empty

-- using update we are changing the total price.
-- update sales set s.totalprice = s.quantity * p.price 
--				from sales as s
--				join
--				products as p
--				on s.productid = p.productid ;
-- It works in SQL server but not in Postgresql
UPDATE sales as s
SET totalprice = s.quantity * p.price, 2
from products as p
where s.productid = p.productid ; 

UPDATE sales set totalprice = Round(totalprice::numeric,2);

select  Productid,productname,resistant from products order by 3;

select Extract(YEAR from salesdate) as Year,
	   Extract(Month from salesdate) as month,count(salesid) as sales_cnt,
					sum(totalprice) as revenue
					from sales 
					group by 1,2
					order by 1,2;

