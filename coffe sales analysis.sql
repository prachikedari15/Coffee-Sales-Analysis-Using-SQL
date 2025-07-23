create database coffee;
use coffee;
select * from coffeecsv;

describe coffeecsv;

-- change the datatype of transaction_date and transaction_time
SET SQL_SAFE_UPDATES = 0;
UPDATE coffeecsv
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');
alter table coffeecsv modify transaction_date date;

update coffeecsv
set transaction_time = str_to_date(transaction_time,'%H:%i:%s');
alter table coffeecsv modify transaction_time time;

-- Calculate the total sale for each respective month
SELECT 
  MONTH(transaction_date) AS Month_Number,
  MONTHNAME(transaction_date) AS Month_Name,
  ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffeecsv
GROUP BY Month_Number,Month_Name
ORDER BY Month_Number;

-- Determine the month on month increase or decrease in sales
SELECT 
    MONTH(transaction_date) AS Month_Number,
    MONTHNAME(transaction_date) AS Month_Name,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    CONCAT(
    ROUND(
        (SUM(unit_price * transaction_qty) - 
         LAG(SUM(unit_price * transaction_qty)) OVER (ORDER BY MONTH(transaction_date))) * 100
        / LAG(SUM(unit_price * transaction_qty)) OVER (ORDER BY MONTH(transaction_date)),2),'%')
	AS Month_on_Month_Increase_or_decrease_Percentage_Change_in_sales
FROM coffeecsv
GROUP BY Month_Number,Month_Name
ORDER BY Month_Number;
    
    
-- Calculate the difference in sales between the selected month and previous month
select
	 month(transaction_date) as Month_number,
     monthname(transaction_date) as Month_Name,
     round(sum(unit_price * transaction_qty)) as Total_sales,
     round(
     sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty)) OVER (ORDER BY  month(transaction_date)),2) AS  Difference_in_sales_between_the_selected_month_and_previous_month,
	  concat(
     ROUND(
        (SUM(unit_price * transaction_qty) - 
         LAG(SUM(unit_price * transaction_qty)) OVER (ORDER BY MONTH(transaction_date)))
        / LAG(SUM(unit_price * transaction_qty)) OVER (ORDER BY MONTH(transaction_date)) * 100
    , 2), '%') AS Percentage_Change
 from coffeecsv
 group by Month_number,Month_Name
 order by Month_number;
 
 -- Calculate the total Number of Orders for each respective month
SELECT
	MONTH(transaction_date) AS Month_Number,
    MONTHNAME(transaction_date) AS Month_Name,
    COUNT(DISTINCT transaction_id) AS Num_of_orders
FROM coffeecsv
GROUP BY Month_Number, Month_Name
ORDER BY Month_Number;

-- Determine the month on month increase or decrease in number of orders
WITH monthlyorders AS (
    SELECT
        MONTH(transaction_date) AS month_number,
        MONTHNAME(transaction_date) AS month_name,
        COUNT(DISTINCT transaction_id) AS num_of_orders
    FROM coffeecsv
    GROUP BY month_number, month_name
)

SELECT
    month_number,
    month_name,
    num_of_orders,
    ROUND(
        (num_of_orders - LAG(num_of_orders) OVER (ORDER BY month_number)) * 100.0 /
        LAG(num_of_orders) OVER (ORDER BY month_number),
        2
    ) AS monthly_percent_change
FROM monthlyorders
ORDER BY month_number;

-- Calculate the difference in no of orders between selected month and previous month
with monthlyorders as (
	select 
		MONTH(transaction_date) AS month_number,
        MONTHNAME(transaction_date) AS month_name,
        COUNT(DISTINCT transaction_id) AS num_of_orders
	from coffeecsv
    group by month_number, month_name)
select 
	month_number,
	month_name,
    num_of_orders,
    LAG(num_of_orders) OVER (ORDER BY month_number) AS prev_month_orders,
    (num_of_orders - LAG(num_of_orders) OVER (ORDER BY month_number)) AS change_in_orders,
    ROUND(
        (num_of_orders - LAG(num_of_orders) OVER (ORDER BY month_number)) * 100.0 /
        LAG(num_of_orders) OVER (ORDER BY month_number),
        2
    ) AS monthly_percent_change
FROM monthlyorders
ORDER BY month_number;

-- Calculate total Quantity sold for each respective month
select
	month(transaction_date) as Month_number,
    monthname(transaction_date) as Month_name,
    sum(transaction_qty) as Total_Quantity
from coffeecsv
group by Month_number,Month_name
order by Month_number;

-- Determine the month on month increase or decrease in total quantity sold
WITH monthly_totals AS (
    SELECT
        MONTH(transaction_date) AS Month_number,
        MONTHNAME(transaction_date) AS Month_name,
        SUM(transaction_qty) AS Total_Quantity
    FROM coffeecsv
    GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
)
SELECT
    Month_number,
    Month_name,
    Total_Quantity,
    ROUND(
        (Total_Quantity - LAG(Total_Quantity) OVER (ORDER BY Month_number)) * 100.0
        / NULLIF(LAG(Total_Quantity) OVER (ORDER BY Month_number), 0),
        2
    ) AS Month_on_month_percent_change
FROM monthly_totals
ORDER BY Month_number;

-- Calculate the difference in total quantity sold between the selected month and previous month
with monthly_orders_sold as (
	select month(transaction_date) as month_number,
    monthname(transaction_date) as month_name,
    sum(transaction_qty) as total_quantity
from coffeecsv
group by month_number,month_name)
select
	month_number,
	month_name,
    total_quantity,
    lag(total_quantity) over (order by month_number) as prev_month_quantity_sold,
    (total_quantity) - lag(total_quantity) over (order by month_number) as change_in_quantity_sold,
    round(
		(total_quantity - LAG(total_quantity) OVER (ORDER BY month_number)) * 100.0
        / NULLIF(LAG(total_quantity) OVER (ORDER BY month_number), 0),
        2
    ) AS Month_on_month_percent_change
from monthly_orders_sold
group by month_number,month_name
order by month_number;
		

    
    
	



 


