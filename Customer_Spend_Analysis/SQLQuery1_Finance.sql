
Create table dim_customers ( customer_id varchar(25) primary key, age_group varchar(20), city varchar(20), occupation varchar(25), gender nvarchar(15),
marital_status nvarchar(50), avg_income INT)

BULK INSERT dim_customers
FROM 'C:\Users\thaku\OneDrive - Manipal University Jaipur\SQL Project\Finance\dim_customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skip header row
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    TABLOCK
);


Create table fact_spends ( customer_id varchar(20) , month varchar(20), category varchar(30), payment_type varchar(25),
spend int
)

Bulk insert fact_spends
FROM 'C:\Users\thaku\OneDrive - Manipal University Jaipur\SQL Project\Finance\fact_spends.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skip header row
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    TABLOCK
);

Select * from fact_spends
Select * from dim_customers


--Get all customers who are married.
Select * from dim_customers where marital_status = 'Married';

----Find the total number of customers in each city.
Select COUNT(Customer_id) as Total_Customer, city from dim_customers group by city;

--1. Show the total spends for each customer 
 Select customer_id, SUM(spend) as total_spend from fact_spends group by customer_id;

--2. Show all customers who spent in the 'Electronics' category
Select customer_id, spend from fact_spends where category = 'Electronics'

--3. Find the average spend for each payment type
Select payment_type, AVG(spend) as average_spend from fact_spends group by payment_type

--4. List the total amount spent by each customer in the month of May.
Select f.customer_id, SUM(f.spend) as total_spend, f.month from fact_spends f left join dim_customers d on d.customer_id=f.customer_id 
where f.month='May' group by f.customer_id, f.month;


--5. Get the number of customers in each occupation.
Select occupation, COUNT(Customer_id) as no_of_Customer from dim_customers group by occupation;


--6. Retrieve the details of customers who are in the age group '25-34'.
Select * from dim_customers where age_group = '25-34';

--7. List all customers who spent using Debit Card.
SELECT customer_id, SUM(spend) AS total_spent FROM fact_spends WHERE payment_type = 'Debit Card'
GROUP BY customer_id;

Select * from fact_spends
Select * from dim_customers

--8. Get the total spend for each age group in the Entertainment category.
Select age_group, SUM(spend) as total_spend from dim_customers d left join fact_spends f on f.customer_id=d.customer_id where category = 'Entertainment'
group by age_group;

--9. Find the highest spend by a customer in the 'Food' category in the month of October.
SELECT TOP 1 
    f.customer_id, 
    f.spend
FROM 
    fact_spends f
JOIN 
    dim_customers d ON f.customer_id = d.customer_id
WHERE 
    f.category = 'Food' AND f.month = 'October'
ORDER BY 
    f.spend DESC;


--10. Show the average income of customers in each occupation.

SELECT 
    occupation, 
    AVG(avg_income) AS avg_income
FROM 
    dim_customers
GROUP BY 
    occupation;

--11.Show all customers who spent in the 'Electronics' category, including their name and age group.

SELECT 
    d.customer_id, 
    d.age_group, 
    f.category
FROM 
    fact_spends f
JOIN 
    dim_customers d ON f.customer_id = d.customer_id
WHERE 
    f.category = 'Electronics';

--12. Find the total spends per customer 
SELECT 
    customer_id, 
    SUM(spend) AS total_spend
FROM 
    fact_spends
GROUP BY 
    customer_id;

--13. Find the total spend for each city
SELECT 
    d.city, 
    SUM(f.spend) AS total_spend
FROM 
    fact_spends f
JOIN 
    dim_customers d ON f.customer_id = d.customer_id
GROUP BY 
    d.city;


--14. Show the average income of customers who spent on 'Entertainment' in the month of July.

SELECT 
    AVG(d.avg_income) AS avg_income
FROM 
    fact_spends f
JOIN 
    dim_customers d ON f.customer_id = d.customer_id
WHERE 
    f.category = 'Entertainment' AND f.month = 'July';

--15. Show the total spend per customer by age group and category.

SELECT 
    d.customer_id, 
    d.age_group, 
    f.category, 
    SUM(f.spend) AS total_spend
FROM 
    fact_spends f
JOIN 
    dim_customers d ON f.customer_id = d.customer_id
GROUP BY 
    d.customer_id, d.age_group, f.category;
