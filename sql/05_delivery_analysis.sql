
-- ============================================================
-- 05 - DELIVERY PERFORMANCE ANALYSIS
-- ============================================================


-- 1. Overall delivery performance
-- Only delivered orders with both timestamps are included.
SELECT
    COUNT(*) AS delivered_orders_with_dates,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::TIMESTAMP
                    - order_purchase_timestamp::TIMESTAMP
                )
            ) / 86400.0
        ),
        2
    ) AS avg_days_from_purchase_to_delivery,
    ROUND(
        MIN(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::TIMESTAMP
                    - order_purchase_timestamp::TIMESTAMP
                )
            ) / 86400.0
        ),
        2
    ) AS min_days,
    ROUND(
        MAX(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::TIMESTAMP
                    - order_purchase_timestamp::TIMESTAMP
                )
            ) / 86400.0
        ),
        2
    ) AS max_days
FROM orders
WHERE order_status = 'delivered'
  AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL;


-- 2. Compare estimated vs actual delivery time
SELECT
    COUNT(*) AS delivered_orders_with_estimate,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date::TIMESTAMP
                    - order_purchase_timestamp::TIMESTAMP
                )
            ) / 86400.0
        ),
        2
    ) AS avg_actual_days,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_estimated_delivery_date::TIMESTAMP
                    - order_purchase_timestamp::TIMESTAMP
                )
            ) / 86400.0
        ),
        2
    ) AS avg_estimated_days,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date::TIMESTAMP
              > order_estimated_delivery_date::TIMESTAMP
    ) AS delivered_late_orders,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date::TIMESTAMP
                  > order_estimated_delivery_date::TIMESTAMP
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered'
  AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL;


-- 3. Average delivery time by customer state
SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date::TIMESTAMP
                    - o.order_purchase_timestamp::TIMESTAMP
                )
            ) / 86400.0
        ),
        2
    ) AS avg_delivery_days
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND NULLIF(o.order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;


-- ============================================================
-- END OF DELIVERY ANALYSIS
-- ============================================================
