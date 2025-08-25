# Grocery-sales-analysis

## ETL Process on Postgresql
- First, try to Check the data in MS EXCEL, if you can change the things like here we noticed date format is different than regular "dd-mm-yyyy". So I changed the date format for all tables except sales table. 
``` sql
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
```
