---

# **Amazon USA Sales Analysis Project**


### **Difficulty Level: Advanced**

---

## **Project Overview**

I worked on analyzing a dataset of over 20,000 sales records from an Amazon-like e-commerce platform. This project focuses on exploring customer behavior, product performance, and sales trends using MySQL.

Throughout the project, I solved various real-world SQL problems such as revenue analysis, customer segmentation, inventory tracking, and business performance evaluation.

I also performed data cleaning, handled null values, and used structured queries to address practical business scenarios

---

### **Entity Relationship Diagram (ERD)**

An ERD (Entity Relationship Diagram) is included to visually represent the database schema and table relationships.


![ERD Scratch](https://github.com/ChamaKaushik/Amazon_Sales_Analysis--SQL_Project/blob/main/Erd.png)

## **Database Setup & Design**

### **Schema Structure**

```sql
CREATE TABLE category
(
  category_id	INT PRIMARY KEY,
  category_name VARCHAR(20)
);

-- customers TABLE
CREATE TABLE customers
(
  customer_id INT PRIMARY KEY,	
  first_name	VARCHAR(20),
  last_name	VARCHAR(20),
  state VARCHAR(20),
  address VARCHAR(5) DEFAULT ('xxxx')
);

-- sellers TABLE
CREATE TABLE sellers
(
  seller_id INT PRIMARY KEY,
  seller_name	VARCHAR(25),
  origin VARCHAR(15)
);

-- products table
  CREATE TABLE products
  (
  product_id INT PRIMARY KEY,	
  product_name VARCHAR(50),	
  price	FLOAT,
  cogs	FLOAT,
  category_id INT, -- FK 
  CONSTRAINT product_fk_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

-- orders
CREATE TABLE orders
(
  order_id INT PRIMARY KEY, 	
  order_date	DATE,
  customer_id	INT, -- FK
  seller_id INT, -- FK 
  order_status VARCHAR(15),
  CONSTRAINT orders_fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT orders_fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_items
(
  order_item_id INT PRIMARY KEY,
  order_id INT,	-- FK 
  product_id INT, -- FK
  quantity INT,	
  price_per_unit FLOAT,
  CONSTRAINT order_items_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT order_items_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- payment TABLE
CREATE TABLE payments
(
  payment_id	
  INT PRIMARY KEY,
  order_id INT, -- FK 	
  payment_date DATE,
  payment_status VARCHAR(20),
  CONSTRAINT payments_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shipping
(
  shipping_id	INT PRIMARY KEY,
  order_id	INT, -- FK
  shipping_date DATE,	
  return_date	 DATE,
  shipping_providers	VARCHAR(15),
  delivery_status VARCHAR(15),
  CONSTRAINT shipping_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE inventory
(
  inventory_id INT PRIMARY KEY,
  product_id INT, -- FK
  stock INT,
  warehouse_id INT,
  last_stock_date DATE,
  CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
  );
```

---

## **Task: Data Cleaning**

I cleaned the dataset by:
- **Removing duplicates**: Duplicates in the customer and order tables were identified and removed.
- **Handling missing values**: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## **Handling Null Values**

Null values were handled based on their context:
- **Customer addresses**: Missing addresses were assigned default placeholder values.
- **Payment statuses**: Orders with null payment statuses were categorized as “Pending.”
- **Shipping information**: Null return dates were left as is, as not all shipments are returned.

---

## **Objective**

The primary objective of this project is to showcase SQL proficiency through complex queries that address real-world e-commerce business challenges. The analysis covers various aspects of e-commerce operations, including:
- Customer behavior
- Sales trends
- Inventory management
- Payment and shipping analysis
- Forecasting and product performance
  

## **Identifying Business Problems**

Key business problems identified:
1. Low product availability due to inconsistent restocking.
2. High return rates for specific product categories.
3. Shipping delays and inconsistent delivery times affecting customer experience and satisfaction.
4. High customer acquisition costs with a low customer retention rate, highlighting the need for better customer engagement strategies.

---

## **Solving Business Problems**

### Solutions Implemented:

1. Top Selling Products
Query the top 10 products by total sales value.
Challenge: Include product name, total quantity sold, and total sales value.

```sql
-- Step 1: Add a new column to store total sales
ALTER TABLE order_items
ADD total_sales FLOAT;

-- Step 2: Populate the total_sales column
UPDATE order_items
SET total_sales = quantity * price_per_unit;

-- Step 3: Preview updated order_items table
SELECT * 
FROM order_items;

-- Step 4: Get top 10 best-selling products by total sales
SELECT 
    p.product_id, 
    p.product_name, 
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.total_sales), 2) AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.product_id, p.product_name 
ORDER BY total_sales DESC 
LIMIT 10;
```


2. Revenue by Category
Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.

```sql
SELECT 
    c.category_id,
    c.category_name,
    ROUND(SUM(oi.total_sales), 2) AS revenue,
    ROUND((SELECT SUM(total_sales) FROM order_items), 2) AS total_revenue,
    ROUND((SUM(oi.total_sales) / (SELECT SUM(total_sales) FROM order_items)) * 100, 2) AS contribution
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN category AS c ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;
```


3. Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.

```sql
-- Step 1: Add a new column to store the customer's full name
ALTER TABLE customers
ADD full_name VARCHAR(30);

-- Step 2: Update full_name by combining first_name and last_name
UPDATE customers
SET full_name = CONCAT(first_name, ' ', last_name);

-- Step 3: View the updated customer records
SELECT * 
FROM customers;

-- Step 4: Calculate average order value (AOV) for each customer
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(od.order_id) AS total_orders,
    ROUND(SUM(oi.total_sales) / COUNT(od.order_id), 2) AS average_order_value
FROM customers AS c
JOIN orders AS od ON c.customer_id = od.customer_id 
JOIN order_items AS oi ON od.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(od.order_id) > 5 ;
```


4. Monthly Sales Trend
Query monthly total sales over the past year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!

```sql
-- Get the date exactly 2 years before today because order_date is upto 2024-7-24 .
SELECT *, 
       LAG(current_month_sale) OVER (ORDER BY year, month) AS last_month_sale
FROM (
    SELECT 
        YEAR(od.order_date) AS year,
        MONTH(od.order_date) AS month,
        ROUND(SUM(oi.total_sales), 2) AS current_month_sale
    FROM orders od
    JOIN order_items oi ON od.order_id = oi.order_id
    WHERE od.order_date >= CURDATE() - INTERVAL 2 YEAR
    GROUP BY YEAR(od.order_date), MONTH(od.order_date)
) AS t1 ;
```


5. Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.

```sql
Approach 1
SELECT *
-- reg_date - CURRENT_DATE                           
FROM customers 
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM orders
);
```
```sql
-- Approach 2
SELECT *
FROM customers as c
LEFT JOIN
orders as o
ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL
```


6. Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.

```sql
SELECT 
    state, 
    category_name, 
    ROUND(sales, 2) AS total_sales  
FROM (
    SELECT 
        cu.state, 
        c.category_name, 
        SUM(od.total_sales) AS sales,
        RANK() OVER (PARTITION BY cu.state ORDER BY SUM(od.total_sales) ASC) AS rnk 
    FROM category c
    JOIN products p ON p.category_id = c.category_id 
    JOIN order_items od ON p.product_id = od.product_id 
    JOIN orders o ON o.order_id = od.order_id 
    JOIN customers cu ON o.customer_id = cu.customer_id 
    GROUP BY cu.state, c.category_name
) AS t1
WHERE rnk = 1;
```


7. Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime.
Challenge: Rank customers based on their CLTV.

```sql
SELECT 
    c.customer_id, 
    c.full_name, 
    ROUND(SUM(od.total_sales), 2) AS cltv,
    DENSE_RANK() OVER (ORDER BY SUM(od.total_sales) DESC) AS rnk
FROM orders o
JOIN order_items od ON o.order_id = od.order_id 
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name;
```


8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.

```sql
SELECT 
    p.product_name, 
    i.inventory_id, 
    i.stock AS current_stock_left,
    i.warehouse_id, 
    i.last_stock_date
FROM products p
JOIN inventory i ON p.product_id = i.product_id
WHERE i.stock < 10;
```

9. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.

```sql
SELECT 
    c.customer_id, 
    c.full_name, 
    c.state, 
    od.order_id, 
    od.order_date, 
    od.seller_id, 
    od.order_status,
    s.shipping_id, 
    s.shipping_date, 
    s.shipping_providers
FROM customers c
JOIN orders od ON c.customer_id = od.customer_id
JOIN shipping s ON od.order_id = s.order_id 
WHERE DATEDIFF(s.shipping_date, od.order_date) > 3;
```

10. Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).

```sql
-- Approach 1
SELECT 
    payment_status,  
    COUNT(*) AS total_payments_successed,
    (COUNT(*) / (SELECT COUNT(*) FROM payments)) * 100 AS percentage
FROM payments
WHERE payment_status = 'Payment Successed'
GROUP BY payment_status;
```
```sql
-- Approach 2
SELECT 
    payment_status, 
    cnt, 
    pcnt AS percentage 
FROM (
    SELECT 
        payment_status, 
        COUNT(*) AS cnt,  
        (COUNT(*) / (SELECT COUNT(*) FROM payments)) * 100 AS pcnt
    FROM payments
    GROUP BY payment_status
) AS t1 
WHERE payment_status = 'Payment Successed';
```

11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.

```sql
-- Step 1: Identify top 5 sellers based on total sales
WITH top_sellers AS (
    SELECT 
        s.seller_id, 
        s.seller_name, 
        ROUND(SUM(oi.total_sales), 2) AS total_sale
    FROM orders od 
    JOIN order_items oi ON od.order_id = oi.order_id
    JOIN sellers s ON od.seller_id = s.seller_id
    GROUP BY s.seller_id, s.seller_name 
    ORDER BY total_sale DESC
    LIMIT 5
),
-- Step 2: Gather order reports for the top 5 sellers
sellers_reports AS (
    SELECT 
        od.seller_id, 
        ts.seller_name, 
        od.order_status, 
        COUNT(*) AS no_of_orders
    FROM orders od
    JOIN top_sellers ts ON od.seller_id = ts.seller_id
    WHERE order_status NOT IN ('Inprogress', 'Returned')
    GROUP BY od.seller_id, ts.seller_name, od.order_status
)
-- Step 3: Aggregate order statuses and calculate success rate
SELECT 
    seller_id, 
    seller_name,
    SUM(CASE WHEN order_status = 'Completed' THEN no_of_orders ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN no_of_orders ELSE 0 END) AS cancelled_orders,
    SUM(no_of_orders) AS total_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'Completed' THEN no_of_orders ELSE 0 END) * 100.0 
        / SUM(no_of_orders), 
        2
    ) AS successful_orders_percentage
FROM sellers_reports
GROUP BY seller_id, seller_name;
```


12. Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
*/


```sql
SELECT 
    product_id, 
    product_name, 
    ROUND(profit_margin, 2) AS profit_margin,
    RANK() OVER (ORDER BY profit_margin DESC) AS rnk
FROM (
    SELECT 
        p.product_id, 
        p.product_name, 
        SUM(od.total_sales - (p.cogs * od.quantity)) AS profit,
        (SUM(od.total_sales - (p.cogs * od.quantity)) / SUM(od.total_sales)) * 100 AS profit_margin
    FROM products p
    JOIN order_items od ON p.product_id = od.product_id 
    GROUP BY p.product_id, p.product_name
) AS t1;
```

13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.

```sql
SELECT 
    p.product_id, 
    p.product_name, 
    COUNT(*) AS total_units_sold,
    SUM(CASE WHEN od.order_status = 'Returned' THEN 1 ELSE 0 END) AS no_of_return,
    ROUND(
        SUM(CASE WHEN od.order_status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS return_percentage
FROM orders od
JOIN order_items oi ON od.order_id = oi.order_id 
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY no_of_return DESC
LIMIT 10;
```


14.  Orders Pending Shipment
Find orders that have been paid but are still pending shipment.
Challenge: Include order details, payment date, and customer information.

```sql
SELECT 
    c.full_name AS customer_name, 
    od.order_id, 
    od.order_status,
    p.payment_date, 
    p.payment_status
FROM customers c
JOIN orders od ON c.customer_id = od.customer_id
JOIN payments p ON od.order_id = p.order_id
WHERE p.payment_status = 'Payment Successed' 
  AND od.order_status = 'Inprogress';
```


15. Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.

```sql
-- for last 6 month = current_date()-interval 6 month & after -6 we get 2025-01-25
--  but the date is only upto 2024-07-30 
-- so we have to do current_date()-interval 1 year 6 month = 18 month

-- Identify sellers who haven't made any sales in the last 18 months
WITH ct1 AS (
    SELECT * 
    FROM sellers
    WHERE seller_id NOT IN (
        SELECT seller_id 
        FROM orders 
        WHERE order_date >= CURRENT_DATE() - INTERVAL 1 YEAR - INTERVAL 6 MONTH
    )
)
-- Retrieve their last sale date and last total sale value
SELECT 
    od.seller_id, 
    MAX(od.order_date) AS last_sale_date, 
    MAX(oi.total_sales) AS last_total_sales
FROM ct1
JOIN orders od ON ct1.seller_id = od.seller_id
JOIN order_items oi ON od.order_id = oi.order_id 
GROUP BY od.seller_id;
```


16. IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns

```sql
SELECT 
    customer_id, 
    full_name AS customer_name, 
    total_orders, 
    total_returns,
    CASE 
        WHEN total_returns > 5 THEN 'Returning' 
        ELSE 'New' 
    END AS identity_customers
FROM (
    SELECT 
        c.customer_id, 
        c.full_name, 
        COUNT(od.order_id) AS total_orders,
        SUM(CASE 
                WHEN od.order_status = 'Returned' THEN 1 
                ELSE 0 
            END) AS total_returns
    FROM customers c
    JOIN orders od ON c.customer_id = od.customer_id
    GROUP BY c.customer_id, c.full_name
) AS t1;
```


17. Top 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer.

```sql
select state, full_name as customer_name, total_orders, total_sales
from (
select c.state, c.full_name, 
count(od.order_id) as total_orders, sum(oi.total_sales) as total_sales,
dense_rank() over(partition by c.state order by count(od.order_id) desc) as rnk
from customers c
join orders od
on c.customer_id = od.customer_id
join order_items oi
on od.order_id = oi.order_id 
group by c.state, c.full_name ) as t1 
where rnk <= 5 ;
```


18. Revenue by Shipping Provider
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and the average delivery time for each provider.

```sql
SELECT 
    s.shipping_providers, 
    COUNT(od.order_id) AS total_orders, 
    ROUND(SUM(oi.total_sales), 2) AS revenue,
    COALESCE(AVG(s.return_date - s.shipping_date), 0) AS avg_delivery_time
FROM shipping s
JOIN orders od ON s.order_id = od.order_id
JOIN order_items oi ON od.order_id = oi.order_id
GROUP BY s.shipping_providers;
```


19. Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
Challenge: Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio at end Round the result
Note: Decrease ratio = cr-ls/ls* 100 (cs = current_year ls=last_year)

```sql
WITH last_year_sale AS (
    SELECT 
        p.product_id, 
        p.product_name, 
        c.category_name,
        SUM(oi.total_sales) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN category c ON p.category_id = c.category_id
    WHERE YEAR(o.order_date) = 2022
    GROUP BY p.product_id, p.product_name, c.category_name
),
current_year_sale AS (
    SELECT 
        p.product_id, 
        p.product_name, 
        c.category_name,
        SUM(oi.total_sales) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN category c ON p.category_id = c.category_id
    WHERE YEAR(o.order_date) = 2023
    GROUP BY p.product_id, p.product_name, c.category_name
)
SELECT
    cs.product_id, 
    cs.product_name, 
    cs.category_name,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,
    ls.revenue - cs.revenue AS rev_diff,
    ROUND((cs.revenue - ls.revenue) / ls.revenue * 100, 2) AS revenue_dec_ratio
FROM last_year_sale ls
JOIN current_year_sale cs ON ls.product_id = cs.product_id
WHERE ls.revenue > cs.revenue
ORDER BY revenue_dec_ratio
LIMIT 10;
```


20. Final Task: Stored Procedure
Create a stored procedure that, when a product is sold, performs the following actions:
Inserts a new sales record into the orders and order_items tables.
Updates the inventory table to reduce the stock based on the product and quantity purchased.
The procedure should ensure that the stock is adjusted immediately after recording the sale.

```SQL
DELIMITER //

-- Procedure: Add a sale, update order tables and inventory if stock is available
CREATE PROCEDURE add_sales (
    IN p_order_id INT,
    IN p_customer_id INT,
    IN p_seller_id INT,
    IN p_order_item_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_price FLOAT;
    DECLARE v_product VARCHAR(50);

    -- Step 1: Fetch product price and name
    SELECT price, product_name
    INTO v_price, v_product
    FROM products
    WHERE product_id = p_product_id;

    -- Step 2: Check if enough stock is available
    SELECT COUNT(*) 
    INTO v_count
    FROM inventory
    WHERE product_id = p_product_id
      AND stock >= p_quantity;

    -- Step 3: If stock is available, process sale
    IF v_count > 0 THEN
        -- Insert into orders table
        INSERT INTO orders (order_id, order_date, customer_id, seller_id)
        VALUES (p_order_id, CURDATE(), p_customer_id, p_seller_id);

        -- Insert into order_items table
        INSERT INTO order_items (
            order_item_id, order_id, product_id, quantity, price_per_unit, total_sales
        ) VALUES (
            p_order_item_id, p_order_id, p_product_id, p_quantity, v_price, v_price * p_quantity
        );

        -- Update inventory stock
        UPDATE inventory
        SET stock = stock - p_quantity
        WHERE product_id = p_product_id;

        -- Success message
        SELECT CONCAT('Product "', v_product, '" sale has been added. Inventory updated.') AS message;

    ELSE
        -- Stock not sufficient message
        SELECT CONCAT('Product "', v_product, '" is not available or out of stock.') AS message;
    END IF;

END //

DELIMITER ;
```


**Testing Store Procedure**
CALL add_sales(25006, 3, 4, 21630, 2, 30);
CALL add_sales(25007, 3, 4, 21631, 3, 93);

---

---

## **Learning Outcomes**

This project enabled me to:
- Design and implement a normalized database schema.
- Clean and preprocess real-world datasets for analysis.
- Use advanced SQL techniques, including window functions, subqueries, and joins.
- Conduct in-depth business analysis using SQL.
- Optimize query performance and handle large datasets efficiently.

---

## **Conclusion**

This advanced SQL project successfully demonstrates my ability to solve real-world e-commerce problems using structured queries. From improving customer retention to optimizing inventory and logistics, the project provides valuable insights into operational challenges and solutions.

By completing this project, I have gained a deeper understanding of how SQL can be used to tackle complex data problems and drive business decision-making.

---

