
-- ============================================================
-- 02 - ORDER STATUS AND CUSTOMER ORDER ANALYSIS
-- ============================================================

-- 1. Distribution of order statuses
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 2. Orders by purchase year and month
SELECT
    LEFT(order_purchase_timestamp, 7) AS purchase_month,
    COUNT(*) AS total_orders
FROM orders
WHERE NULLIF(order_purchase_timestamp, '') IS NOT NULL
GROUP BY LEFT(order_purchase_timestamp, 7)
ORDER BY purchase_month;


-- 3. Count distinct customers who placed orders
SELECT
    COUNT(*) AS total_order_records,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM orders;


-- 4. Review scores: average and negative-review share
SELECT
    ROUND(AVG(review_score::NUMERIC), 2) AS average_review_score,
    ROUND(
        COUNT(*) FILTER (WHERE review_score::INTEGER <= 2)
        * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS negative_review_percentage
FROM order_reviews
WHERE NULLIF(review_score, '') IS NOT NULL;
