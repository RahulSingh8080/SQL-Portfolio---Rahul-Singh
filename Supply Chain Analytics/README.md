
# **Supply Chain Data Analysis Project**

## **Overview**

This project focuses on analyzing and optimizing supply chain operations using historical order data. The goal is to evaluate key performance metrics such as On Time In Full (OTIF), delivery performance, and identify areas for improvement by analyzing customer, product, and order-level data.

## **Database Structure**

### 1. **dim_customers**:  
This table contains customer information, including their unique `customer_id`, `customer_name`, and the `city` where the customer is located.

### 2. **dim_date**:  
Stores date details like the `date`, `mmm_yy` (month-year format), and `week_no` (week number).

### 3. **dim_products**:  
Contains product information, including the `product_id`, `product_name`, and `category` of each product.

### 4. **dim_targets_orders**:  
Stores customer-specific targets for on-time deliveries, in-full deliveries, and OTIF (On Time In Full) targets.

### 5. **fact_order_lines**:  
The fact table representing order data at the line level. It includes fields like `order_id`, `customer_id`, `product_id`, and various metrics like `order_qty`, `delivery_qty`, `on_time`, `in_full`, and `on_time_in_full`.

### 6. **fact_orders_aggregate**:  
Aggregated data for each order, with a focus on on-time and in-full delivery performance.

---

## **Key SQL Queries**

### 1. **Total Orders Placed in Each Month**

```sql
SELECT 
    FORMAT(order_placement_date, 'yyyy-MM') AS order_month,
    COUNT(order_id) AS total_orders
FROM 
    fact_orders_aggregate
GROUP BY 
    FORMAT(order_placement_date, 'yyyy-MM')
ORDER BY 
    order_month;
```

**Explanation**: This query calculates the total number of orders placed in each month based on the `order_placement_date`.

---

### 2. **Weekly Trend of Late Deliveries**

```sql
SELECT 
    d.week_no,
    COUNT(order_id) AS late_deliveries
FROM fact_order_lines f
LEFT JOIN dim_date d
ON f.order_placement_date = d.date
WHERE f.actual_delivery_date > f.agreed_delivery_date
GROUP BY d.week_no
ORDER BY d.week_no;
```

**Explanation**: This query provides a weekly trend of late deliveries by comparing the `actual_delivery_date` with the `agreed_delivery_date`.

---

### 3. **Month with Highest Number of Orders Not Delivered in Full**

```sql
SELECT TOP 1
    DATENAME(MONTH, order_placement_date) AS month,
    COUNT(CASE WHEN in_full = 0 THEN 1 END) AS total_not_in_full
FROM fact_order_lines
GROUP BY DATENAME(MONTH, order_placement_date)
ORDER BY total_not_in_full DESC;
```

**Explanation**: Identifies the month with the highest number of orders that were not delivered in full.

---

### 4. **Difference Between Agreed and Actual Delivery Dates**

```sql
SELECT 
    agreed_delivery_date,
    actual_delivery_date, 
    DATEDIFF(day, agreed_delivery_date, actual_delivery_date) AS days_diff
FROM fact_order_lines;
```

**Explanation**: Calculates the difference between the `agreed_delivery_date` and `actual_delivery_date` in days.

---

### 5. **OTIF Performance for Each City**

```sql
SELECT 
    c.city,
    CONCAT(CAST(COUNT(CASE WHEN On_Time_In_Full = 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)), '%')
    AS otif_performance
FROM fact_order_lines f
LEFT JOIN dim_customers c
ON f.customer_id = c.customer_id
GROUP BY c.city
ORDER BY otif_performance;
```

**Explanation**: This query calculates the On Time In Full (OTIF) performance for each city.

---

### 6. **Total Number of Orders Delivered Late**

```sql
SELECT 
    COUNT(order_id) total_late_deliveries
FROM fact_order_lines
WHERE actual_delivery_date > agreed_delivery_date;
```

**Explanation**: Counts the total number of orders delivered late.

---

### 7. **List of Product Categories Along with the Number of Unique Products in Each Category**

```sql
SELECT 
    category, 
    COUNT(DISTINCT product_id) AS total_products
FROM dim_products
GROUP BY category
ORDER BY total_products DESC;
```

**Explanation**: Lists the product categories along with the number of unique products in each category.

---

### 8. **Busiest Week in Terms of Order Placement**

```sql
SELECT TOP 1
    d.week_no, 
    COUNT(order_id) AS total_orders
FROM fact_order_lines f
LEFT JOIN dim_date d
ON f.order_placement_date = d.date
GROUP BY d.week_no
ORDER BY total_orders DESC;
```

**Explanation**: Identifies the busiest week in terms of order placement.

---

### 9. **Product Categories Performing Best in Meeting OTIF Targets**

```sql
SELECT TOP 1
    p.category,
    AVG(CAST(f.On_Time_In_Full AS DECIMAL(5,2))) AS performance
FROM fact_order_lines f
LEFT JOIN dim_products p
    ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY performance DESC;
```

**Explanation**: Identifies the product category with the best OTIF performance.

---

### 10. **Percentage of Orders That Met OTIF Criteria**

```sql
SELECT 
    CONCAT(CAST(COUNT(CASE WHEN On_Time_In_Full = 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)), '%')
    AS OTIF_percentage
FROM fact_order_lines;
```

**Explanation**: Calculates the percentage of orders that met the OTIF criteria.

---

### 11. **Orders Placed on Weekends Versus Weekdays**

```sql
SELECT 
    CASE WHEN (DATEPART(WEEKDAY, order_placement_date) IN(1, 7)) THEN 'weekend'
    ELSE 'weekday' END AS day_type,
    COUNT(order_id) AS total_orders
FROM fact_order_lines
GROUP BY CASE WHEN (DATEPART(WEEKDAY, order_placement_date) IN(1, 7)) THEN 'weekend'
    ELSE 'weekday' END;
```

**Explanation**: Counts the number of orders placed on weekends versus weekdays.

---

### 12. **Orders Delivered On Time But Not In Full**

```sql
SELECT 
    COUNT(*) AS total_orders
FROM fact_order_lines
WHERE On_Time = 1 AND In_Full = 0;
```

**Explanation**: Counts the number of orders that were delivered on time but not in full.

---

### 13. **Product Category with Highest Order Quantity**

```sql
SELECT TOP 1
    p.category, 
    SUM(f.order_qty) AS total_qty
FROM fact_order_lines f
INNER JOIN dim_products p
ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_qty DESC;
```

**Explanation**: Identifies the product category with the highest order quantity.

---

### 14. **Monthly Percentage of On-Time and In-Full Deliveries for Each Customer**

```sql
WITH monthly AS (
    SELECT 
        customer_id , 
        DATENAME(MONTH, order_placement_date) AS month,
        CAST(COUNT(CASE WHEN On_Time = 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,0)) AS on_time_percentage,
        CAST(COUNT(CASE WHEN In_Full = 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,0)) AS in_full_percentage
    FROM fact_order_lines 
    GROUP BY customer_id, DATENAME(MONTH, order_placement_date)
)
SELECT 
    m.customer_id, 
    month, 
    CASE WHEN on_time_percentage >= ontime_target_percentage THEN 'Target Met' ELSE 'Target Missed' END AS on_time_performance,
    CASE WHEN in_full_percentage >= infull_target_percentage THEN 'Target Met' ELSE 'Target Missed' END AS in_full_performance
FROM monthly m
INNER JOIN dim_targets_orders t
ON m.customer_id = t.customer_id
ORDER BY m.customer_id;
```

**Explanation**: Calculates the monthly percentage of on-time and in-full deliveries for each customer, comparing these results to the targets.

---

## **Conclusion**

This project provides valuable insights into supply chain performance, particularly focusing on delivery performance and meeting targets. The analysis can guide future strategies for improving on-time and in-full deliveries, as well as optimizing supply chain operations.


