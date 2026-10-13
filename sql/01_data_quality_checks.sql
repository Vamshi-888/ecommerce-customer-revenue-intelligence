
-- ============================================================
-- E-COMMERCE CUSTOMER & REVENUE INTELLIGENCE
-- 01 - DATA QUALITY CHECKS
-- ============================================================


-- 1. Check total orders and duplicate order IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM orders;


-- 2. Check order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 3. Check missing purchase timestamps
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE NULLIF(order_purchase_timestamp, '') IS NULL
    ) AS missing_purchase_timestamps
FROM orders;


-- 4. Check order items for missing or invalid prices
-- Prices were initially imported as TEXT, so cast them to NUMERIC.
SELECT
    COUNT(*) AS total_items,
    COUNT(*) FILTER (
        WHERE NULLIF(price, '') IS NULL
    ) AS missing_prices,
    COUNT(*) FILTER (
        WHERE NULLIF(price, '') IS NOT NULL
          AND price::NUMERIC <= 0
    ) AS non_positive_prices
FROM order_items;


-- 5. Check payment types and their frequency
SELECT
    payment_type,
    COUNT(*) AS payment_records
FROM order_payments
GROUP BY payment_type
ORDER BY payment_records DESC;


-- 6. Check missing delivery timestamps
-- Missing delivery dates can be valid for cancelled or unfulfilled orders.
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE NULLIF(order_delivered_customer_date, '') IS NULL
    ) AS missing_customer_delivery_dates,
    COUNT(*) FILTER (
        WHERE NULLIF(order_delivered_carrier_date, '') IS NULL
    ) AS missing_carrier_delivery_dates
FROM orders;


-- 7. Check for duplicate order-item combinations
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (order_id, order_item_id)) AS unique_order_item_pairs,
    COUNT(*) - COUNT(DISTINCT (order_id, order_item_id))
        AS duplicate_order_item_pairs
FROM order_items;


-- 8. Check missing product categories
SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (
        WHERE NULLIF(product_category_name, '') IS NULL
    ) AS missing_product_categories
FROM products;


-- 9. Check review score distribution
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- END OF DATA QUALITY CHECKS
-- ============================================================
