create database zepto_sql_project;
drop database zepto_sql_project;
use zepto_sql_project;
create table zepto (
sku_id int primary key auto_increment,
category varchar(120),
name varchar(150) not null,
mrp numeric(8,2),
discountpercent numeric (5,2),
availableQuantity int,
discountedSellingPrice numeric(8,2),
weightIngms int,
outofstock boolean,
quantity int);

LOAD DATA LOCAL INFILE "C:/Users/santo/Downloads/zepto_v2.csv"
INTO TABLE zepto
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(category, name, mrp, discountpercent, availableQuantity, discountedSellingPrice, weightIngms, @outofstock, quantity)
SET outofstock = IF(@outofstock='TRUE',1,0);

-- data exploration

-- count of rows
select count(*) from zepto;

-- sample data
select * from zepto limit 10;

-- handling null values
select * from zepto
where name is null or
category is null or
mrp is null or
discountpercent is null or
availablequantity is null or
discountedsellingprice is null or
weightingms is null or
outofstock is null;

-- checking types of products and categories
select distinct name,category from zepto 
order by category;

-- checking whether the product in stock or outofstock
select outofstock,count(sku_id) from zepto 
group by outofstock;

-- which product names in multiple times
select name,count(sku_id) as 'number of sku' from zepto
group by name
having count(sku_id)>1
order by count(sku_id) desc;

-- data cleaning

-- product with price =0
select * from zepto
where mrp = 0 or discountedsellingprice = 0;

delete from zepto
where sku_id = 3607;

-- convert price from rupees to paise
update zepto
set mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0;

-- business insights 
-- find the top 10 best-valued products based on the discount percentage
select distinct name,mrp,discountpercent from zepto
order by discountpercent desc
limit 10;

-- what are the products with high mrp  but outofstock
select distinct name,mrp from zepto
where outofstock = 0
order by mrp desc;

-- calculate estimated revenue for each category
select category,sum(discountedsellingprice*availableQuantity) as total_revenue from zepto
group by category
order by total_revenue;

-- find all products where MRP is greater than 500 and discount is less than 10%
select distinct name ,mrp,discountpercent from zepto
where mrp > 500 and discountpercent < 10
order by mrp desc , discountpercent desc;

-- Identify the top 5 categories offering the highest average discount percentage
select category,round(avg(discountpercent),2) as 'discountedproduct' from zepto
group by category
order by discountedproduct desc
limit 5;

-- find the price per gram for products above 100 g and sort by best values
select distinct name,(discountedsellingprice/weightingms)*100 as product from zepto
where weightingms > 100
order by product ;

-- group the products into categories like low,medium,high
select distinct name, weightingms, case
when weightingms < 1000 then 'low'
when weightingms < 5000 then 'medium'
else 'bulk'
end as weight_category 
from zepto;

-- what is the total inventory weight per category
select category,sum(weightingms*availablequantity) as inventoryweight from zepto
group by category
order by inventoryweight ;


























