
-- ============================================================
-- 08 - TABLEAU MONTHLY SUMMARY (CORRECTED)
-- Aggregate order items and payments separately to prevent
-- duplicated totals when an order has multiple records.
-- ============================================================

WITH monthly_orders AS (
    SELECT
        TO_CHAR(
            order_purchase_timestamp::TIMESTAMP,
            'YYYY-MM'
        ) AS purchase_month,
        order_id,
        customer_id
    FROM orders
    WHERE NULLIF(order_purchase_timestamp, '') IS NOT NULL
),

monthly_items AS (
    SELECT
        mo.purchase_month,
        COUNT(DISTINCT mo.order_id) AS orders_with_items,
        ROUND(SUM(oi.price::NUMERIC), 2) AS item_revenue_brl,
        ROUND(SUM(oi.freight_value::NUMERIC), 2) AS shipping_charges_brl
    FROM monthly_orders AS mo
    JOIN order_items AS oi
        ON mo.order_id = oi.order_id
    GROUP BY mo.purchase_month
),

monthly_payments AS (
    SELECT
        mo.purchase_month,
        ROUND(SUM(p.payment_value::NUMERIC), 2) AS payment_value_brl
    FROM monthly_orders AS mo
    JOIN order_payments AS p
        ON mo.order_id = p.order_id
    GROUP BY mo.purchase_month
),

monthly_customer_counts AS (
    SELECT
        purchase_month,
        COUNT(DISTINCT customer_id) AS unique_customers,
        COUNT(DISTINCT order_id) AS total_orders
    FROM monthly_orders
    GROUP BY purchase_month
)

SELECT
    mc.purchase_month,
    mc.total_orders,
    mc.unique_customers,
    COALESCE(mi.orders_with_items, 0) AS orders_with_items,
    COALESCE(mi.item_revenue_brl, 0) AS item_revenue_brl,
    COALESCE(mi.shipping_charges_brl, 0) AS shipping_charges_brl,
    COALESCE(mp.payment_value_brl, 0) AS payment_value_brl
FROM monthly_customer_counts AS mc
LEFT JOIN monthly_items AS mi
    ON mc.purchase_month = mi.purchase_month
LEFT JOIN monthly_payments AS mp
    ON mc.purchase_month = mp.purchase_month
ORDER BY mc.purchase_month;


-- ============================================================
-- END OF CORRECTED MONTHLY SUMMARY
-- ============================================================
