create database if not exists retail_analytics;
use retail_analytics;

/*Retail Case Study
1. Data Problem
2. Hypothesis 
3. Data Undestanding and Data Cleaning
4. Analysis (EDA)
*/

/*3. Data Undestanding and Data Cleaning*/
# Learn about the table

-- 3.1 Learning about the tables and columns

SELECT * FROM customer_profiles;

/*
	with customer_profiles table
    we have
    customerid but ? unique or not
    age, gender, location of a customer
    joinDate of customer but ? of first purchase or first purchase failed
    
    col name rename ï»¿CustomerID to CustomerID
    
    how many rows ?
*/

SELECT * from product_inventory;

/*
	with product_inventory table
    we have
    ProductID but ? unique or not
    ProductName - how many products do we have?
    Category - ? how many category are there and which product comes under which category
    Stocklevel - ? means inventory
    price - individual product price
    
    rename column ï»¿ProductID to ProductID
*/

SELECT * FROM sales_transaction;

/*
	with sales_transaction table
    we have
	TransactionID ? unique or not
    customerID, ProductID ? primary key or foreign key
    quantitypurchased ? individual product quantity
    transactionDate ? but success or failed
    price? individual product price purchased by customer
    
    rename column ï»¿TransactionID to TransactionID
*/

-- 3.2 Learning about the Tables more -- rename the column name to proper format

DESC customer_profiles;
DESC product_inventory;
DESC sales_transaction;

#Rename the col for customer_profiles
ALTER TABLE customer_profiles
RENAME COLUMN ï»¿CustomerID TO CustomerID;

select * from customer_profiles;

#Rename the col for product_inventory
ALTER TABLE product_inventory
RENAME column ï»¿ProductID TO ProductID;

select * from product_inventory;

#Rename the col for sales_transaction
ALTER TABLE sales_transaction
RENAME column ï»¿TransactionID TO TransactionID;

select * from sales_transaction;

-- 3.3 What is Primary key and foreign key in each table and Remove Dublicates?

-- for customer_profiles table
select * from customer_profiles;

-- customerid should be unique for making primary key

select count(*) from customer_profiles;  -- we have 1K rows

select 
		customerID, count(*) as cnt
from customer_profiles
group by CustomerID
having cnt > 1
order by cnt desc; -- now from here we conclude that customerid is unique and eligible for primary key

ALTER TABLE customer_profiles
MODIFY column customerID INT PRIMARY KEY;

DESC customer_profiles;

-- for product_inventory table
select * from product_inventory;

-- check productid is unique or not?

select count(*) from product_inventory; -- we have 200 rows

select 
		productID, count(*) cnt
from product_inventory
group by ProductID
having cnt > 1; -- from here we conclude that productID is unique and eligible for primary key

ALTER TABLE product_inventory
MODIFY COLUMN productID int primary key;

desc product_inventory;

-- for sales_transaction
select * from sales_transaction;

-- check for transactionID is unique or not

select count(*) from sales_transaction; -- we have 5002 rows

select
		transactionid,
        count(*) cnt
from sales_transaction
group by TransactionID
having cnt > 1; -- we have 4999 and 5000 id number that have 2 counts

select * from sales_transaction
where TransactionID in (4999,5000); -- from here we get that there is a duplication occur in a table

/*
	we have to remove the duplicates
    create dummy table
    insert data into dummy by removing duplicate
    drop orignal table
    rename dummy name to orignal name
*/

create table sales_dummy
select distinct * from sales_transaction;

drop table sales_transaction;

alter table sales_dummy
Rename to sales_transaction;

desc sales_transaction;

select
		transactionid,
        count(*) cnt
from sales_transaction
group by TransactionID
having cnt > 1; -- from here we conclude that transactionid is unique and eligible for primary key

alter table sales_transaction
modify column transactionid int primary key;

select 
	customerid, count(*) cnt
from sales_transaction
group by customerid
having cnt > 1; -- from here we get that customerid is not unique but reference from table customer_profiles so it act as foreign key

alter table sales_transaction
add foreign key (customerid ) references customer_profiles(customerid);

select 
	productid, count(*) cnt
from sales_transaction
group by productid
having cnt > 1; -- from here we get that productid is not unique but reference from table product_inventory so it act as foreign key

alter table sales_transaction
add foreign key (productid) references product_inventory(productid);

desc sales_transaction;

/*
 3.4 check and compare values for discrepancy
*/

select * from product_inventory;
select * from sales_transaction;

select
	st.productID,
    st.Price as sales_trans_price,
    pi.price as prod_invntry_price
from sales_transaction st
left join product_inventory pi
on pi.productID = st.productID
where st.Price <> pi.Price; -- from here we find that for productID 51 in sales_transaction table its price increases to 100 x i think it may be by mistake

-- handling the discrepancy

update sales_transaction st
left join product_inventory pi
on st.productID = pi.productID
set st.price = pi.price
where st.price <> pi.price; -- from this discrepancy has been solved

/*
| Subquery Type           | Used In                  | Returns                    | Why Use It (One-Line Purpose)                               | Example                                                                       | Relationship Type           |
| ----------------------- | ------------------------ | -------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------- | --------------------------- |
| **Scalar Subquery**     | `SELECT`, `SET`, `WHERE` | Single value               | To fetch **1 value** (cell) per row or per query            | `SELECT name, (SELECT MAX(salary) FROM employees)`                            | **1-to-1**                  |
| **Column Subquery**     | `IN`, `= ANY`, etc.      | One column, many rows      | To compare a value against a **list** of values             | `WHERE dept_id IN (SELECT dept_id FROM departments)`                          | **1-to-Many**               |
| **Table Subquery**      | In `FROM` clause         | A virtual table            | To build a **temporary table** for filtering or joining     | `SELECT * FROM (SELECT * FROM sales WHERE price > 100)`                       | **Many-to-Many** or **N/A** |
| **Correlated Subquery** | `WHERE`, `EXISTS`, `SET` | Re-evaluated per outer row | To fetch related data **row-by-row** from outer query       | `WHERE EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customers.id)` | **1-to-Many**               |
*/


/*
	3.5 Missing values and working on NULL
*/

select count(*) from customer_profiles 
where location is NULL;

SET SQL_SAFE_UPDATES = 0;

update customer_profiles
set location = 'Unknown'
where location is null;

select count(*) from customer_profiles
where location = '';

update customer_profiles
set location = 'unknown'
where location = '';

/*
	3.6 Dates
*/

desc customer_profiles; -- as joindate is in text form convert it in date type

drop table dummy1;

create table dummy1 
select * , str_to_date(joinDate,'%d/%m/%Y') as updated_joinDate from customer_profiles;

select * from dummy1;

drop table customer_profiles;

alter table sales_transaction
drop foreign key sales_transaction_ibfk_1;

alter table dummy1
rename to customer_profiles;

alter table customer_profiles
add constraint pk_customerid
primary key (customerid);

alter table sales_transaction
add constraint fk_customerid
foreign key (customerid ) references customer_profiles(customerid);

-- check date type in sales_transaction table

desc sales_transaction; -- transactiondate in text type convert it to in date type

alter table sales_transaction
drop column updated_transactiondate;

alter table sales_transaction
add column updated_transactiondate date after transactiondate;

update sales_transaction
set updated_transactiondate = str_to_date(transactiondate,'%d/%m/%y');

select * from sales_transaction;

/*
	Exploratory Data Analysis
*/

-- distribution of customer_profile table

select * from customer_profiles;

select count(*) from customer_profiles; -- total number of rows we have

select location,count(*) total_customers from customer_profiles
group by location; -- location wise distribution

select 
		age,
		count(*) number_of_Customers
from customer_profiles
group by age
order by number_of_customers desc; -- age wise distribution

select 
		gender,
		count(*) number_of_Customers
from customer_profiles
group by gender
order by number_of_customers desc; -- gender wise distribution

select 
		month(updated_joindate) as month,
        count(*) number_of_Customers
from customer_profiles
group by month
order by number_of_customers desc; -- month wise distribution

select 
		year(updated_joindate) as year,
        count(*) number_of_Customers
from customer_profiles
group by year
order by number_of_customers desc; -- year wise distribution

select
		gender,
        round(avg(age),2) as avg_age,
        count(*) as number_of_customers
from customer_profiles
group by gender;

-- product_inventory distribution

select * from product_inventory;

select count(*) from product_inventory; -- count number of rows

select 
		productname,
        count(*) as number_of_products
from product_inventory
group by productname
having number_of_products > 1
order by number_of_products desc; -- get number of products do we have

select
		category,
		count(*) as number_of_products,
        sum(StockLevel) as total_stock_available,
        round(avg(price),2) as avg_price
from product_inventory
group by category
order by total_stock_available;

-- sales transaction distribution

select count(*) from sales_transaction; -- we have 5000 rows

select
		customerid,
        productid,
        count(transactionid) as number_of_transactions,
        sum(QuantityPurchased) as total_quantity,
        round(avg(price),2) as average_price
from sales_transaction
group by customerid,productid
order by number_of_transactions desc; -- which customer purchase with product how many number of times

select 
		month(updated_transactiondate) as month,
        count(*) as number_of_transactions
from sales_transaction
group by month;

select 
		year(updated_transactiondate) as year,
        count(*) as number_of_transactions
from sales_transaction
group by year;

/*
	Get a summary of total sales and quantities sold per product.
*/

SELECT 
    pi.Category,
    ROUND(SUM(st.QuantityPurchased * st.Price), 2) AS total_Sales,
    SUM(st.QuantityPurchased) AS total_quantity
FROM
    sales_transaction st
        LEFT JOIN
    product_inventory pi ON st.ProductID = pi.productID
GROUP BY pi.Category;
	
    
/*
	customer purchase frequency
*/

select
		customerid,
        count(*) as number_of_transactions
from sales_transaction
group by CustomerID;

/*
	product category performance
*/

select
		category,
		count(*) as number_of_products,
        sum(StockLevel) as total_stock_available,
        round(avg(price),2) as avg_price
from product_inventory
group by category
order by total_stock_available;

/*
	high sales product top 10 or top 5
*/

select
		st.productID,
        round(sum(st.QuantityPurchased*st.Price),2) as total_sales
from sales_transaction st
left join product_inventory pi 
on st.ProductID = pi.productID
group by st.productID
order by total_sales desc
limit 5;

/*
	low sales product
*/

select
		st.productID,
        round(sum(st.QuantityPurchased*st.Price),2) as total_sales
from sales_transaction st
left join product_inventory pi 
on st.ProductID = pi.productID
group by st.productID
order by total_sales
limit 5;

/*
	sales trend
*/

select
		year(updated_transactiondate) as year,
        month(updated_transactiondate) as month,
        round(sum(QuantityPurchased*price),2) as totalsales
from sales_transaction
group by year,month;

/* Step 11. Growth rate of sales M-o_M 
Write a SQL query to understand the month on month growth rate of sales of the company 
which will help understand the growth trend of the company.
*/

-- (Current-Previous/Previous) * 100

with cte as (
select 
		month(updated_transactiondate) as month,
        round(sum(quantitypurchased*price),2) as curr_month_sales,
        lag(round(sum(QuantityPurchased*price),2),1) over (order by month(updated_transactiondate)) as prev_month_sales
from sales_transaction
group by month
)

select
		month,
        coalesce(prev_month_sales,0),
        curr_month_sales,
        concat(ifnull(round(((curr_month_sales - prev_month_sales) / prev_month_sales)*100,2),0),'%') as growthrate
from cte;

/*
	Customers - High Purchase Frequency and Revenue
*/

select 
		customerid,
        count(*) as frequency,
        round(sum(QuantityPurchased*price),2) as revenue
from sales_transaction
group by customerid
having frequency > 10
order by frequency desc, revenue desc;

/*
	Occasional Customers - Low Purchase Frequency
*/

select 
		customerid,
        count(*) as frequency,
        round(sum(QuantityPurchased*price),2) as revenue
from sales_transaction
group by customerid
having frequency <= 2
order by frequency desc, revenue desc;

/*
	Repeat Purchase Patterns
*/

select
		customerid,
        count(ProductID) as count_of_products
from sales_transaction
group by customerid
having count_of_products > 1
order by count_of_products desc;

/*
	Loyalty Indicators 
*/

select
		CustomerID,
        min(updated_transactiondate) as first_purchase,
        max(updated_transactiondate) as last_purchase,
        (max(updated_transactiondate) - min(updated_transactiondate)) as daydiff,
        count(customerid) over (partition by (max(updated_transactiondate) - min(updated_transactiondate))) as num_of_customer
from sales_transaction
group by customerid
order by daydiff desc;

/*
	Customer Segmentation based on quantity purchased  (31156)-(31554)
*/

create table customer_seg
select
		customerid,
        case
			when totalquantity > 30 then 'high'
            when totalquantity between 10 and 30 then 'medium'
            when totalquantity between 1 and 10 then 'low'
            else 'none'
		end as customer_segment
from (
		select 
				customerid,
                sum(quantitypurchased) as totalquantity
		from sales_transaction
        group by CustomerID
) as customer_purchased;

select 
		customer_segment,
        count(*) number_of_customers
from customer_seg
group by customer_segment;

-- how to check multiple columns for null or empty 

select * from customer_profiles
where customerid = 1001;

insert into customer_profiles values(1001,null,null,null,null,null);

SELECT 
  GROUP_CONCAT(
    CONCAT(
      'SUM(CASE WHEN `', COLUMN_NAME, '` IS NULL OR TRIM(`', COLUMN_NAME, '`) = '''' THEN 1 ELSE 0 END) AS `', COLUMN_NAME, '_null_or_empty`'
    )
    SEPARATOR ',\n'
  ) AS sql_code
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA ='retail_analytics'
  AND TABLE_NAME = 'product_inventory';
  
  select 
SUM(CASE WHEN `Age` IS NULL OR TRIM(`Age`) = '' THEN 1 ELSE 0 END) AS `Age_null_or_empty`,
 SUM(CASE WHEN `customerID` IS NULL OR TRIM(`customerID`) = '' THEN 1 ELSE 0 END) AS `customerID_null_or_empty`,
 SUM(CASE WHEN `Gender` IS NULL OR TRIM(`Gender`) = '' THEN 1 ELSE 0 END) AS `Gender_null_or_empty`,
 SUM(CASE WHEN `JoinDate` IS NULL OR TRIM(`JoinDate`) = '' THEN 1 ELSE 0 END) AS `JoinDate_null_or_empty`,
 SUM(CASE WHEN `Location` IS NULL OR TRIM(`Location`) = '' THEN 1 ELSE 0 END) AS `Location_null_or_empty`,
 SUM(CASE WHEN `updated_joinDate` IS NULL OR TRIM(`updated_joinDate`) = '' THEN 1 ELSE 0 END) AS `updated_joinDate_null_or_empty`
from customer_profiles;

-- i want which category mostly influence the total revenue

with cte as (
select
		pi.category,
        cast(sum(st.quantitypurchased*st.price) as decimal(10,2)) as totalrevenue
from sales_transaction st 
left join product_inventory pi 
on st.ProductID = pi.productID
group by pi.Category
order by totalrevenue desc
),
cte2 as (
		select category,
				concat(round((totalrevenue / (select sum(totalrevenue) from cte))*100,2),'%') as percent_contribution
		from cte
)

select * from cte2;

-- now i want in category which product influence the total revenue most

with cte as (
select
		pi.category,
        cast(sum(st.quantitypurchased*st.price) as decimal(10,2)) as totalrevenue
from sales_transaction st 
left join product_inventory pi 
on st.ProductID = pi.productID
group by pi.Category
),
cte1 as (
select
		category,
        st.productid,
        round(sum(QuantityPurchased*st.price),2) as totalrevenue
from sales_transaction st 
join product_inventory pi
on st.ProductID = pi.productID
where category = 'Electronics'
group by 1,2
order by category,st.productid,totalrevenue desc
),
cte2 as (
			select 
					category,
                    productid,
                    round((totalrevenue / (select totalrevenue from cte where cte.category = cte1.category))*100,2) as percent_contribution
			from cte1
            order by percent_contribution desc
)

select
		category,
        productid,
        concat(percent_contribution,'%') as percent_contribution,
        round(sum(percent_contribution) over (order by percent_contribution desc),2) as cumulative_percent_contribution
from cte2;
