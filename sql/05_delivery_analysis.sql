-- ============================================================
-- 05_delivery_analysis.sql
-- Business question: Which states/cities have the highest order
-- volume and delivery issues?
-- ============================================================

-- Delivery performance by state
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400), 1)
        AS avg_delivery_days,
    ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400), 1)
        AS avg_delay_vs_estimate_days,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS pct_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY pct_late DESC;

-- Top 10 cities by order volume (with delay rate alongside, for context)
SELECT
    c.customer_city,
    c.customer_state,
    COUNT(*) AS total_orders,
    ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS pct_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city, c.customer_state
ORDER BY total_orders DESC
LIMIT 10;

-- Delay severity buckets (CASE-based bucketing, a common interview pattern)
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On time / early'
        WHEN order_delivered_customer_date - order_estimated_delivery_date <= INTERVAL '3 days' THEN 'Late 1-3 days'
        WHEN order_delivered_customer_date - order_estimated_delivery_date <= INTERVAL '7 days' THEN 'Late 4-7 days'
        ELSE 'Late 8+ days'
    END AS delay_bucket,
    COUNT(*) AS num_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
GROUP BY delay_bucket
ORDER BY num_orders DESC;
