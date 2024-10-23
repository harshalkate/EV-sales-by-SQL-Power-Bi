select * from ev_dataset;

select `Year`, Month_Name, `Date`, State, Vehicle_Class, Vehicle_Category, Vehicle_Type, EV_Sales_Quantity, count(*)
from ev_dataset
group by `Year`, Month_Name, `Date`, State, Vehicle_Class, Vehicle_Category, Vehicle_Type, EV_Sales_Quantity
having count(*) > 1;
-- checking nulls values from the data set
select `Year`
from ev_dataset 
where `Year` is null;

select `Month_Name`
from ev_dataset 
where `Month_Name` is null;

select State
from ev_dataset 
where State is null;

-- insights : there no null values in any of the column

select * from ev_dataset;

-- droping the column year and month name
alter table ev_dataset
drop column `Year`;

alter table ev_dataset
drop column Month_Name;

describe ev_dataset;

-- changing format of date column vachar to date
UPDATE ev_dataset
SET `Date` = STR_TO_DATE(`Date`, '%d-%m-%Y');


alter table ev_dataset
modify `Date` DATE;

select * from ev_dataset;

-- changing the column names from upper case fully loweer case
-- date, State, Vehicle_Class, Vehicle_Category, Vehicle_Type, EV_Sales_Quantity
alter table ev_dataset
rename column `Date` to `date`;

alter table ev_dataset
rename column State to state;

alter table ev_dataset
rename column Vehicle_Class to vehicle_class;

alter table ev_dataset
rename column Vehicle_Category to vehicle_category;

alter table ev_dataset
rename column Vehicle_Type to vehicle_type;

alter table ev_dataset
rename column EV_Sales_Quantity to ev_sales_quantity;

select * from ev_dataset;

-- 1. Summary statistics of EV sales quantity
SELECT 
    MIN(EV_Sales_Quantity) AS min_sales,
    MAX(EV_Sales_Quantity) AS max_sales,
    AVG(EV_Sales_Quantity) AS avg_sales,
    SUM(EV_Sales_Quantity) AS sum_sales
FROM
    ev_dataset;
    
-- 2. Sales trend over time (yearly or monthly)
SELECT 
    EXTRACT(YEAR FROM `date`) AS sales_year,
    SUM(ev_sales_quantity) AS sum_sales
FROM
    ev_dataset
GROUP BY EXTRACT(YEAR FROM `date`)
ORDER BY sales_year;

-- 3. State-wise Sales Distribution
select state, sum(EV_Sales_Quantity) as total_sales
from ev_dataset
group by state
order by total_sales desc;

-- insights : as we can see UP has on  top by ev vehicles 

-- 4. Top Vehicle Classes
select Vehicle_Class, sum(EV_Sales_Quantity) as total_sales
from ev_dataset
group by Vehicle_Class
order by total_sales desc;

-- 5. Vehicle Category Insights
SELECT 
    Vehicle_Category, SUM(EV_Sales_Quantity) AS total_sales
FROM
    ev_dataset
GROUP BY Vehicle_Category
ORDER BY total_sales DESC;

-- 6. State-wise Performance for Each Vehicle Class
SELECT 
    state, Vehicle_Class, SUM(EV_Sales_Quantity) AS total_sales
FROM
    ev_dataset
GROUP BY state , Vehicle_Class
ORDER BY total_sales DESC;

-- 7. Sales Growth Rate
with yearly_sales as (
select extract(year from `date`) as sales_year,
sum(ev_sales_quantity) as total_sales
from ev_dataset
group by extract(year from `date`)
)
select sales_year,total_sales,
lag(total_sales) over( order by sales_year) as previous_salesyear,
round((total_sales - lag(total_sales) over(order by sales_year)) / 
lag(total_sales) over( order by sales_year)*100,2) as growth_rate
from yearly_sales 
order by sales_year;

-- 8. Most Popular EV Types top 3
SELECT 
    Vehicle_Type, SUM(EV_Sales_Quantity) AS total_sales
FROM
    ev_dataset
GROUP BY Vehicle_Type
ORDER BY total_sales DESC
LIMIT 3;

-- cumulative sales analysis
select `date`,
sum(ev_sales_quantity) over( order by `date` desc rows between unbounded preceding and current row) as cumulative_sales
from ev_dataset
order by `date` limit 10;

-- Sales Share by Vehicle Class Over Time

with monthly_sales as (
select extract( year from `date`) as sales_year,vehicle_class,
sum(ev_sales_quantity) as class_sales
from ev_dataset
group by extract( year from `date`) ,vehicle_class
),
total_sales as (
select extract(year from `date`) as sales_year,
sum(ev_sales_quantity) as total_sales
from ev_dataset
group by extract(year from `date`)
)
select m.sales_year,m.vehicle_class,m.class_sales,
round((m.class_sales / t.total_sales) * 100,2) as sales_share
from monthly_sales m
join total_sales t on m.sales_year = t.sales_year
order by m.sales_year,sales_share desc;

select * from ev_dataset;
