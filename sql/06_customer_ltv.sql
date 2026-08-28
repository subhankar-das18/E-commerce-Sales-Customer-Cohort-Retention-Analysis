-- ============================================================
-- 06_customer_ltv.sql
-- Business question: How do repeat customers behave vs
-- one-time buyers?
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS num_orders,
        SUM(oi.price) AS total_spent
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id, c.customer_state
)
SELECT
    CASE WHEN num_orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,
    ROUND(AVG(total_spent), 2) AS avg_lifetime_value,
    ROUND(SUM(total_spent), 2) AS total_revenue_contribution
FROM customer_orders
GROUP BY customer_type;

-- Repeat purchase rate by state, ranked (RANK window function)
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS num_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id, c.customer_state
)
SELECT
    customer_state,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct,
    RANK() OVER (ORDER BY 100.0 * SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) DESC) AS repeat_rate_rank
FROM customer_orders
GROUP BY customer_state
HAVING COUNT(*) >= 50   -- exclude tiny states to avoid noisy rankings
ORDER BY repeat_rate_pct DESC;
