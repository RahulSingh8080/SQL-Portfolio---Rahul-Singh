Create database supply_chain

Use supply_chain

Create table dim_customers (customer_id int primary key,  customer_name varchar(50), city varchar(50))

Select * from dim_customers

BULK INSERT dim_customers
FROM 'C:\Users\thaku\OneDrive - Manipal University Jaipur\Startup Growth & Funding Trends\Supply Chain\dim_customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skip header row
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    TABLOCK
);

Create table dim_date(date DATE, mmm_yy varchar(20), week_no varchar(20))

Select * from dim_date

Bulk insert dim_date
from 'C:\Users\thaku\OneDrive - Manipal University Jaipur\Startup Growth & Funding Trends\Supply Chain\dim_date.csv'
with (
Format = 'CSV',
FirstRow = 2,
Fieldterminator = ',',
Rowterminator = '\n',
Tablock
);

Create table dim_products(product_name varchar(50),	product_id int primary key,	category varchar(50));
Bulk insert dim_products
from 'C:\Users\thaku\OneDrive - Manipal University Jaipur\Startup Growth & Funding Trends\Supply Chain\dim_products.csv'
with (
Format = 'CSV',
FirstRow = 2,
Fieldterminator = ',',
Rowterminator = '\n',
Tablock
);

Select * from dim_customers

Create table dim_targets_orders( customer_id int primary key, ontime_target int, infull_target int, otif_target int);
Bulk insert dim_targets_orders
from 'C:\Users\thaku\OneDrive - Manipal University Jaipur\Startup Growth & Funding Trends\Supply Chain\dim_targets_orders.csv'
with (
Format = 'CSV',
FirstRow = 2,
Fieldterminator = ',',
Rowterminator = '\n',
Tablock
);

select * from dim_targets_orders

CREATE TABLE fact_order_lines (
    order_id VARCHAR(20),
    order_placement_date DATE,
    customer_id INT,
    product_id INT,
    order_qty INT,
    agreed_delivery_date DATE,
    actual_delivery_date DATE,
    delivery_qty INT,
    "In Full" INT,
    "On Time" INT,
    "On Time In Full" INT
);

BULK INSERT fact_order_lines
FROM 'C:\Users\thaku\OneDrive - Manipal University Jaipur\Startup Growth & Funding Trends\Supply Chain\fact_order_lines.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

select * from fact_order_lines

CREATE TABLE fact_orders_aggregate (
    order_id VARCHAR(20),
    customer_id INT,
    order_placement_date DATE,
    on_time TINYINT,
    in_full TINYINT,
    otif TINYINT             -- On Time In Full
);

Bulk insert fact_orders_aggregate
from 'C:\Users\thaku\OneDrive - Manipal University Jaipur\Startup Growth & Funding Trends\Supply Chain\fact_orders_aggregate.csv'
with (
Format = 'CSV',
FirstRow = 2,
Fieldterminator = ',',
Rowterminator = '\n',
Tablock
);

Select * from fact_orders_aggregate
Select * from dim_customers
select * from fact_order_lines
Select * from dim_targets_orders
Select * from dim_date
Select * from dim_products

--1. How many orders were placed in each month?
SELECT 
    FORMAT(order_placement_date, 'yyyy-MM') AS order_month,
    COUNT(order_id) AS total_orders
FROM 
    fact_orders_aggregate
GROUP BY 
    FORMAT(order_placement_date, 'yyyy-MM')
ORDER BY 
    order_month;

--2. What is the weekly trend of late deliveries?


SELECT 
	d.week_no,
	COUNT(order_id) as late_deliveries
FROM fact_order_lines f
LEFT JOIN dim_date d
ON f.order_placement_date = d.date
WHERE f.actual_delivery_date > f.agreed_delivery_date
GROUP BY d.week_no
ORDER BY d.week_no

use supply_chain

select * from information_schema.columns

--3. Identify the month with the highest number of orders that were not delivered in full
SELECT TOP 1
	DATENAME(MONTH, order_placement_date) as month,
	COUNT(CASE WHEN in_full = 0 THEN 1 END ) AS total_not_in_full
FROM fact_order_lines
GROUP BY DATENAME(MONTH, order_placement_date)
ORDER BY total_not_in_full DESC


--4. Find the difference between agreed delivery dates and actual delivery dates for all orders
SELECT 
	agreed_delivery_date ,
	actual_delivery_date, 
	DATEDIFF(day, agreed_delivery_date ,actual_delivery_date ) AS days_diff
FROM fact_order_lines 


--5. What is the OTIF performance for each city?
SELECT 
	c.city,
	CONCAT(CAST(COUNT(CASE WHEN On_Time_In_Full = 1 THEN 1 END) *100.0/ COUNT(*) AS DECIMAL(5,2)), '%')
	AS otif_performace
FROM fact_order_lines f
LEFT JOIN dim_customers c
ON f.customer_id = c.customer_id
GROUP BY c.city
ORDER BY otif_performace


--6. What is the total number of orders delivered late?
SELECT 
	COUNT(order_id) total_late_deliveries
FROM fact_order_lines
WHERE actual_delivery_date > agreed_delivery_date 


--7. List the product categories along with the number of unique products in each category
SELECT 
	category, 
	COUNT (DISTINCT product_id ) total_products
FROM dim_products
GROUP BY category
ORDER BY total_products DESC


--8. Identify the busiest week in terms of order placement
SELECT TOP 1
	d.week_no, 
	COUNT(order_id) as total_orders
FROM fact_order_lines f
LEFT JOIN dim_date d
ON f.order_placement_date = d.date
GROUP BY d.week_no
ORDER BY total_orders DESC


--9. Which product categories perform best in terms of meeting OTIF targets?
SELECT TOP 1
    p.category,
    AVG(CAST(f.On_Time_In_Full AS DECIMAL(5,2))) AS performance
FROM fact_order_lines f
LEFT JOIN dim_products p
    ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY performance DESC;

--10. What is the percentage of orders that met OTIF criteria?
SELECT 
	CONCAT(CAST(COUNT(CASE WHEN On_Time_In_Full = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (10,2)), '%')
	AS OTIF_percentage
FROM fact_order_lines


--11. How many orders were placed on weekends versus weekdays?
SELECT 
	CASE WHEN (DATEPART(WEEKDAY, order_placement_date) IN(1, 7))  THEN 'weekend'
    ELSE 'weekday' END AS day_type,
    COUNT(order_id) AS total_orders
FROM fact_order_lines
GROUP BY CASE WHEN (DATEPART(WEEKDAY, order_placement_date) IN(1, 7))  THEN 'weekend'
    ELSE 'weekday' END


--12. How many orders were delivered on time but not in full?
SELECT 
	COUNT(*) total_orders
FROM fact_order_lines
WHERE On_Time = 1 AND In_Full = 0


--13. Which product category has the highest order quantity?
SELECT TOP 1
	p.category, 
	SUM(f.order_qty) total_qty
FROM fact_order_lines f
INNER JOIN dim_products p
ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY  total_qty DESC


--14. For each customer, calculate the monthly percentage of on-time and in-full deliveries. 
--Compare these results against the targets to identify any underperforming customers

WITH monthly AS (
SELECT 
	customer_id , 
	DATENAME(MONTH, order_placement_date) AS month,
	CAST(COUNT(CASE WHEN On_Time = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS on_time_percenatge,
	CAST(COUNT(CASE WHEN In_Full = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS in_full_percenatge
FROM fact_order_lines 
GROUP BY customer_id, DATENAME(MONTH, order_placement_date) 
)

SELECT 
	m.customer_id, 
	month, 
	CASE WHEN on_time_percenatge >= ontime_target_percentage THEN 'Target Met' ELSE 'Target Missed' END 
	AS on_time_performance ,
	CASE WHEN in_full_percenatge >= infull_target_percentage THEN 'Target Met' ELSE 'Target Missed' END 
	AS in_full_performance 	
FROM monthly m
INNER JOIN dim_targets_orders t
ON m.customer_id = t.customer_id
ORDER BY m.customer_id


--15.Identify the categories with the highest and lowest on-time delivery rates over the past year. 
--Show the on-time percentage for each category and filter out categories with fewer than 200 total orders.
with 


--16. Calculate the percentage of orders delivered on-time for each customer
SELECT 
	c.customer_name, 
	CONCAT(CAST(COUNT(CASE WHEN On_Time = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,2)), '%')  
	AS on_time_percentage 
FROM fact_order_lines f
INNER JOIN dim_customers c
ON f.customer_id = c.customer_id
GROUP BY c.customer_name


--17. Calculate the percentage of orders that were successfully delivered 
--(i.e., delivered_qty = order_qty) for each customer
SELECT
	customer_name,
	CONCAT(CAST(COUNT(CASE WHEN delivery_qty = order_qty THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)), '%')
	AS sucessfully_delivered_order_percentage
FROM fact_order_lines f
LEFT JOIN dim_customers c
ON f.customer_id = c.customer_id
GROUP BY customer_name


--18. For each product category, calculate the percentage of orders that were delivered on time.
SELECT 
	p.category, 
	CONCAT(CAST(COUNT(CASE WHEN On_Time = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,2)), '%')  
	AS on_time_percentage 
FROM fact_order_lines f
INNER JOIN dim_products p
ON f.product_id = p.product_id
GROUP BY p.category;


--19. Show the customers who exceeded their "ontime_target %" based on their actual delivery performance
WITH ontime AS (
SELECT 
	customer_id,
	CAST(COUNT(CASE WHEN On_Time =1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS on_time_percentage
FROM fact_order_lines
GROUP BY customer_id
)

SELECT o.customer_id
FROM ontime o
INNER JOIN dim_targets_orders t
ON o.customer_id = t.customer_id
WHERE on_time_percentage > ontime_target_percentage


--20. Find customers who placed orders with total product quantity greater than the average order quantity
SELECT 
	c.customer_name,
	SUM(order_qty) AS total_qantity
FROM fact_order_lines f
INNER JOIN dim_customers c
ON f.customer_id = c.customer_id
GROUP BY customer_name, c.customer_id
HAVING SUM(order_qty) > (
						SELECT AVG(order_qty)
						FROM fact_order_lines)


--21. Create a CTE to calculate delivery performance for each customer. 
--Then, use the CTE to select customers whose performance is below the target for both on-time and in-full delivery
WITH performance AS (
SELECT 
	customer_id,
	CAST(COUNT(CASE WHEN On_Time = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS on_time_percentage,
	CAST(COUNT(CASE WHEN In_Full = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS in_full_percentage
FROM fact_order_lines 
GROUP BY customer_id )

SELECT 
	t.customer_id,
	on_time_percentage,
	in_full_percentage
FROM performance p
INNER JOIN dim_targets_orders t
ON p.customer_id = t.customer_id
WHERE (on_time_percentage < ontime_target_percentage) AND 
	  (in_full_percentage < infull_target_percentage)


--22. Use a CTE to calculate the percentage of orders delivered on-time and in-full for each customer, 
--then select the customers with performance below 80% for both metrics
WITH performance AS (
SELECT 
	customer_id,
	CAST(COUNT(CASE WHEN On_Time = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS on_time_percentage,
	CAST(COUNT(CASE WHEN In_Full = 1 THEN 1 END ) * 100.0 / COUNT(*) AS DECIMAL (5,0)) AS in_full_percentage
FROM fact_order_lines 
GROUP BY customer_id )

SELECT 
	t.customer_id,
	on_time_percentage,
	in_full_percentage
FROM performance p
INNER JOIN dim_targets_orders t
ON p.customer_id = t.customer_id
WHERE (on_time_percentage < ontime_target_percentage * 0.8) AND 
	  (in_full_percentage < infull_target_percentage * 0.8)



