-- ============================================
-- E-commerce SQL Analytics Project
-- PostgreSQL + Power BI
-- ============================================



-- ============================================
-- 1. TOP CUSTOMERS ANALYSIS
-- ============================================

SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN payments p 
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_revenue DESC
LIMIT 10;



-- ============================================
-- 2. MONTHLY REVENUE TREND
-- ============================================

SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue
FROM orders o
JOIN payments p 
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;



-- ============================================
-- 3. TOP PRODUCT CATEGORIES
-- ============================================

SELECT 
    p.product_category_name,
    COUNT(oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;



-- ============================================
-- 4. CUSTOMER BEHAVIOR ANALYSIS
-- ============================================

WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY customer_type;



-- ============================================
-- 5. AVERAGE ORDERS PER CUSTOMER
-- ============================================

SELECT 
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) t;



-- ============================================
-- 6. CUSTOMER CHURN ANALYSIS
-- ============================================

WITH last_purchase AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase_date
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

max_date AS (
    SELECT 
        MAX(order_purchase_timestamp) AS max_date
    FROM orders
)

SELECT 
    lp.customer_unique_id,
    lp.last_purchase_date,
    CASE 
        WHEN max_date.max_date - lp.last_purchase_date > INTERVAL '180 days'
        THEN 'Churned'
        ELSE 'Active'
    END AS customer_status
FROM last_purchase lp, max_date;



-- ============================================
-- 7. DATA VALIDATION - NULL CHECKS
-- ============================================

SELECT COUNT(*) AS null_order_dates
FROM orders
WHERE order_purchase_timestamp IS NULL;

SELECT COUNT(*) AS null_payment_values
FROM payments
WHERE payment_value IS NULL;



-- ============================================
-- 8. DATA VALIDATION - DUPLICATE CHECK
-- ============================================

SELECT 
    order_id,
    COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;



-- ============================================
-- 9. DATA VALIDATION - DATE RANGE
-- ============================================

SELECT 
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM orders;