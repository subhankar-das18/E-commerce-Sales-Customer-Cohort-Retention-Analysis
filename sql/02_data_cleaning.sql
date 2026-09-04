-- ============================================================
-- 02_data_cleaning.sql
-- Exploration + cleaning checks. Run after 01_load_data.sql.
-- Each query documents a data-quality issue and how it's handled
-- downstream (used directly in the README "Data Overview" section).
-- ============================================================

-- 1. Order status breakdown — how many orders are cancelled/unavailable
--    and therefore excluded from revenue/delivery analysis?
SELECT order_status, COUNT(*) AS num_orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY num_orders DESC;

-- 2. NULL delivery dates — expected for orders never delivered
SELECT
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_delivered_date,
    COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS null_approved_at,
    COUNT(*) AS total_orders
FROM olist_orders_dataset

-- 3. Duplicate order_items are EXPECTED (multi-item orders) — confirm
--    the grain is (order_id, order_item_id), not just order_id
SELECT order_id, COUNT(*) AS num_items
FROM olist_order_items_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY num_items DESC
LIMIT 10;

-- 4. Products missing an English category translation
SELECT p.product_category_name, COUNT(*) AS num_products
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL
GROUP BY p.product_category_name;

-- 5. Outlier check: zero or negative payment values
SELECT *
FROM olist_order_payments_dataset
WHERE payment_value <= 0;

-- 6. Outlier check: unrealistic delivery times (e.g., > 100 days)
SELECT order_id,
       order_purchase_timestamp,
       order_delivered_customer_date,
       order_delivered_customer_date - order_purchase_timestamp AS delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND (order_delivered_customer_date - order_purchase_timestamp) > INTERVAL '100 days'
ORDER BY delivery_time DESC;

-- Decision used throughout the analysis scripts in this repo:
--   * Revenue queries exclude order_status IN ('canceled','unavailable')
--   * Delivery queries only use order_status = 'delivered'
--     (delivered orders are the only ones with a non-null
--     order_delivered_customer_date to compare against the estimate)
