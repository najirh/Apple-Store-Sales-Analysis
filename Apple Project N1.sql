-- SQL B7 Day2 N2


-- Apple Store Project

-- Exploring (EDA)

SELECT * FROM products;

SELECT * FROM store;

SELECT * FROM sales;

-- Checking if there any null we have in sales table

SELECT 
    COUNT(*)
FROM sales
WHERE quantity IS NULL

SELECT 
    COUNT(*)
FROM sales;


SELECT 
    COUNT(*)
FROM products;


SELECT 
    COUNT(*)
FROM store;


-- Feature Engineering 

-- creating a sale column
ALTER TABLE sales
ADD COLUMN sale FLOAT;

SELECT * FROM sales;

-- creating a profit col
ALTER TABLE sales
ADD COLUMN profit FLOAT;



UPDATE sales as s
SET sale = p.price * s.quantity,
    profit = (p.price * s.quantity) - (p.cogs * s.quantity)
FROM products as p 
WHERE s.product_id = p.product_id;


-- Creating a day of sale column
ALTER TABLE sales
ADD COLUMN day_of_sale VARCHAR(15);


UPDATE sales
SET day_of_sale = TRIM(TO_CHAR(saledate, 'Day'));
SELECT * FROM sales;

SELECT
    COUNT(*) as total_order
FROM sales
WHERE day_of_sale = 'Monday'


SELECT 
    p.product_name,
    p.price,
    s.quantity,
    p.price * s.quantity as sale_amt,
    (p.price * s.quantity) - (p.cogs * s.quantity) as profit
FROM products as p
JOIN
sales as s
ON s.product_id = p.product_id;


-- Business Problems
-- Classifying Products by Price Range: 
-- Classify products into different price ranges: 'Budget', 'Mid-Range', and 'Premium'
-- if price is > 1500 then Premium, if price between 500 and 1000 call mid-Range esle budget



SELECT 
    *,
    CASE
        WHEN launched_price > 1500 THEN 'Premium'
        WHEN launched_price BETWEEN 500 AND 1500 THEN 'mid_Range'
        ELSE 'budget'
    END prod_category
FROM products
WHERE launched_price IS NOT NULL


SELECT
    *,
    COALESCE(launched_price, 0)
FROM products



-- BREAK TILL 9:30 PK IST


SELECT * FROM sales

SELECT 
    *
FROM sales
WHERE day_of_sale = 'Monday'

SELECT
    LENGTH(day_of_sale)
FROM sales

UPDATE sales
SET day_of_sale = TO_CHAR(saledate, 'day')

-- 729 ms

EXPLAIN ANALYZE
SELECT
    *
FROM sales
WHERE product_id = 4

CREATE INDEX pid_index ON sales(product_id);



EXPLAIN ANALYZE
SELECT
    SUM(sale)
FROM sales
WHERE product_id = 7


-- VIEW & Importance of Views

-- rahul

CREATE VIEW india_sales
AS
SELECT
    s.sale_id,
    s.store_id,
    s.saledate,
    s.profit,
    s.day_of_sale,
    st.store_name,
    st.country
FROM sales as s
JOIN store as st
ON st.store_id = s.store_id
WHERE st.country = 'India';

-- WINDOW
-- RANK, DENSE_RANK, ROW_NUMBER, LEAD and LAG


-- INTERVAL
-- DATE FUNCTION
/*
Store Performance Analysis: How are stores ranked based on their performance(profit)?

Find the product with highest total profit from each country of 2020 (return country, product name, total unit sold, total profit
Find out top 5 store with the highest sale 
Find year and year growth for each store based on total profit. (return year, store name, running total)
Find out best selling quarter from each year. (Return quarter no total sale, total profit
*/

-- 

SELECT 
    s1.store_id,
    s1.store_name,
    COUNT(1) as unit_sold,
    ROW_NUMBER() OVER(ORDER BY COUNT(1) DESC) as row_number,
    RANK() OVER(ORDER BY COUNT(1) DESC) as ranks,
    DENSE_RANK() OVER(ORDER BY COUNT(1) DESC) as d_rank    
FROM sales as s
JOIN store as s1
ON s1.store_id = s.store_id
GROUP BY 1, 2


--Write an SQL query to get the product which has highest profit in each country

SELECT * FROM 
(
    SELECT
        s1.country,
        p.product_name,
        SUM(profit) as profit,
        RANK() OVER(PARTITION BY country ORDER BY SUM(profit) DESC) as ranks,
        DENSE_RANK() OVER(PARTITION BY country ORDER BY SUM(profit) DESC) as d_ranks
    FROM sales as s
    JOIN store as s1
    ON s1.store_id = s.store_id
    JOIN products as p
    ON s.product_id = p.product_id
    GROUP BY 1, 2
) as new_table
WHERE d_ranks = 3 

