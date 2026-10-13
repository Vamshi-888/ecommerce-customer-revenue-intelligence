
-- ============================================================
-- 06 - BUSINESS SUMMARY
-- ============================================================

-- 1. Overall order and customer counts
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_order_customer_ids
FROM orders;


-- 2. Total item-price revenue from non-cancelled orders
SELECT
    ROUND(SUM(oi.price::NUMERIC), 2) AS item_price_revenue_brl
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'canceled';


-- 3. Total shipping charges from non-cancelled orders
SELECT
    ROUND(SUM(oi.freight_value::NUMERIC), 2) AS shipping_charges_brl
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'canceled';


-- 4. Order status summary
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 5. Review summary
SELECT
    ROUND(AVG(review_score::NUMERIC), 2) AS average_review_score,
    COUNT(*) FILTER (
        WHERE review_score::INTEGER <= 2
    ) AS negative_reviews,
    COUNT(*) AS total_reviews
FROM order_reviews
WHERE NULLIF(review_score, '') IS NOT NULL;


-- ============================================================
-- END OF BUSINESS SUMMARY
-- ============================================================
