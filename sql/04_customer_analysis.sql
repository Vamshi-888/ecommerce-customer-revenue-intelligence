
-- ============================================================
-- 04 - CUSTOMER PURCHASING BEHAVIOR
-- Use customer_unique_id to identify actual customers.
-- ============================================================


-- 1. One-time vs repeat customers
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM customer_orders
GROUP BY customer_type
ORDER BY total_customers DESC;


-- 2. Distribution of orders per unique customer
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    order_count,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY order_count
ORDER BY order_count;


-- 3. Top 10 unique customers by item-price spending
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price::NUMERIC), 2) AS item_price_spending
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'canceled'
GROUP BY c.customer_unique_id
ORDER BY item_price_spending DESC
LIMIT 10;


-- ============================================================
-- END OF CUSTOMER ANALYSIS
-- ============================================================
