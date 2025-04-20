# rahul-sql-portfolio



 
# 📊 Customer Spend Analysis – SQL Project

## 📝 Overview
This project focuses on analyzing customer spending behavior using SQL Server. It involves querying transactional data (`fact_spends`) and customer demographics (`dim_customers`) to extract insights such as high spenders, category-wise spends, income patterns, and more.

---

## 🎯 Objectives

- Analyze total and category-wise customer spends.
- Identify spending behavior by age group, city, and occupation.
- Understand income trends by occupation.
- Filter spend data based on time (months) and product categories.

---

## 🗂️ Dataset Structure


Get all customers who are married.
Find the total number of customers in each city.
1. Show the total spends for each customer 
2. Show all customers who spent in the 'Electronics' category
3. Find the average spend for each payment type
4. List the total amount spent by each customer in the month of May.
5. Get the number of customers in each occupation.
6. Retrieve the details of customers who are in the age group '25-34'.
7. List all customers who spent using Debit Card.
8. Get the total spend for each age group in the Entertainment category.
9. Find the highest spend by a customer in the 'Food' category in the month of October.
10. Show the average income of customers in each occupation.
11.Show all customers who spent in the 'Electronics' category, including their name and age group.
12. Find the total spends per customer 
13. Find the total spend for each city
14. Show the average income of customers who spent on 'Entertainment' in the month of July.
15. Show the total spend per customer by age group and category.

### 1. `fact_spends`

| Column       | Description                                     |
|--------------|-------------------------------------------------|
| customer_id  | Unique identifier for a customer                |
| spend        | Transaction amount                              |
| category     | Spend category (e.g., Food, Electronics)        |
| card_type    | Payment method (e.g., Debit Card)               |

### 2. `dim_customers`

| Column        | Description                                     |
|---------------|-------------------------------------------------|
| customer_id   | Unique identifier                               |
| customer_name | Full name                                       |
| age_group     | Age group (e.g., 18–25, 26–35)                  |
| occupation    | Job or profession                               |
| income        | Monthly/annual income                           |
| city          | Customer's city                                 |
| month         | Month of transaction                            |

---

## 📌 SQL Queries

### 1. Total spends per customer
```sql
SELECT customer_id, SUM(spend) AS total_spend
FROM fact_spends
GROUP BY customer_id;
```

### 2. Total spends per customer using Debit Card
```sql
SELECT customer_id, SUM(spend) AS total_spent
FROM fact_spends
WHERE card_type = 'Debit Card'
GROUP BY customer_id;
```

### 3. Highest spend in 'Food' category in October
```sql
SELECT TOP 1 customer_id, spend
FROM fact_spends f
JOIN dim_customers d ON f.customer_id = d.customer_id
WHERE category = 'Food' AND month = 'October'
ORDER BY spend DESC;
```

### 4. Average income by occupation
```sql
SELECT occupation, AVG(income) AS avg_income
FROM dim_customers
GROUP BY occupation;
```

### 5. Customers who spent on 'Electronics'
```sql
SELECT d.customer_name, d.age_group
FROM fact_spends f
JOIN dim_customers d ON f.customer_id = d.customer_id
WHERE category = 'Electronics';
```

### 6. Total spend by city
```sql
SELECT d.city, SUM(f.spend) AS total_spend
FROM fact_spends f
JOIN dim_customers d ON f.customer_id = d.customer_id
GROUP BY d.city;
```

### 7. Average income of customers who spent on 'Entertainment' in July
```sql
SELECT AVG(d.income) AS avg_income
FROM fact_spends f
JOIN dim_customers d ON f.customer_id = d.customer_id
WHERE category = 'Entertainment' AND month = 'July';
```

### 8. Total spend per customer by age group and category
```sql
SELECT d.customer_id, d.age_group, f.category, SUM(f.spend) AS total_spend
FROM fact_spends f
JOIN dim_customers d ON f.customer_id = d.customer_id
GROUP BY d.customer_id, d.age_group, f.category;
```

---

## 💾 How to Run the Project

1. Import the CSV files into SQL Server using:
   - **SSMS** → `Tasks` → `Import Flat File`
   - Or use a `BULK INSERT` query.

2. Ensure the tables `fact_spends` and `dim_customers` are created.

3. Run the provided SQL queries in SSMS or your preferred SQL editor.

4. Export results as CSV (optional) by right-clicking result grid → **Save Results As** → CSV.

---

## 📈 Optional Enhancements

- Visualize results in **Power BI** or **Tableau**.
- Automate data load and export using **Python (pandas + pyodbc)**.
- Create stored procedures or views for reusable insights.

---

## 🧠 Skills Used

- SQL Aggregations (`SUM`, `AVG`, `COUNT`)
- Joins (`INNER`, `LEFT JOIN`)
- Filtering with `WHERE` and `GROUP BY`
- Data cleaning & transformation (optional preprocessing in Excel/Python)
