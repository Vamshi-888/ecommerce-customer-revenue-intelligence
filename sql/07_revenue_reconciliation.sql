
-- ============================================================
-- 07 - REVENUE RECONCILIATION
-- ============================================================

-- 1. Total item prices and shipping charges
SELECT
    ROUND(SUM(price::NUMERIC), 2) AS item_price_total_brl,
    ROUND(SUM(freight_value::NUMERIC), 2) AS shipping_total_brl,
    ROUND(
        SUM(price::NUMERIC + freight_value::NUMERIC),
        2
    ) AS items_plus_shipping_brl
FROM order_items;


-- 2. Total recorded payment values
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value::NUMERIC), 2) AS payment_total_brl
FROM order_payments
GROUP BY payment_type
ORDER BY payment_total_brl DESC;


-- 3. Payment values by order status
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value::NUMERIC), 2) AS recorded_payment_total_brl
FROM orders AS o
JOIN order_payments AS p
    ON o.order_id = p.order_id
GROUP BY o.order_status
ORDER BY recorded_payment_total_brl DESC;


-- 4. Compare payment totals and item-plus-shipping totals
-- These totals cover different records and definitions, so they
-- should be interpreted as a reconciliation check, not assumed equal.
SELECT
    (
        SELECT ROUND(SUM(payment_value::NUMERIC), 2)
        FROM order_payments
    ) AS all_recorded_payments_brl,
    (
        SELECT ROUND(
            SUM(price::NUMERIC + freight_value::NUMERIC), 2
        )
        FROM order_items
    ) AS all_items_plus_shipping_brl;


-- ============================================================
-- END OF REVENUE RECONCILIATION
-- ============================================================
