
-- ============================================================
-- 03 - REVENUE ANALYSIS
-- ============================================================

-- 1. Monthly item-price revenue
SELECT
    LEFT(o.order_purchase_timestamp, 7) AS purchase_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price::NUMERIC), 2) AS item_price_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
  AND o.order_status <> 'canceled'
GROUP BY LEFT(o.order_purchase_timestamp, 7)
ORDER BY purchase_month;


-- 2. Top 10 product categories by item-price revenue
SELECT
    COALESCE(
        NULLIF(p.product_category_name, ''),
        'unknown'
    ) AS product_category,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders_containing_category,
    ROUND(SUM(oi.price::NUMERIC), 2) AS item_price_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'canceled'
GROUP BY COALESCE(
    NULLIF(p.product_category_name, ''),
    'unknown'
)
ORDER BY item_price_revenue DESC
LIMIT 10;


-- 3. Monthly order-item revenue including shipping charges
SELECT
    LEFT(o.order_purchase_timestamp, 7) AS purchase_month,
    ROUND(SUM(oi.price::NUMERIC), 2) AS item_price_revenue,
    ROUND(SUM(oi.freight_value::NUMERIC), 2) AS shipping_charges,
    ROUND(
        SUM(oi.price::NUMERIC + oi.freight_value::NUMERIC),
        2
    ) AS item_plus_shipping_value
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
  AND o.order_status <> 'canceled'
GROUP BY LEFT(o.order_purchase_timestamp, 7)
ORDER BY purchase_month;


-- ============================================================
-- END OF REVENUE ANALYSIS
-- ============================================================
