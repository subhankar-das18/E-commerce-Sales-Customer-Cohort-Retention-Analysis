-- ============================================================
-- 04_cohort_analysis.sql
-- Business question: What is the monthly retention/cohort
-- behavior of customers (grouped by first purchase month)?
-- ============================================================

WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
orders_with_cohort AS (
    SELECT
        c.customer_unique_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_purchase fp ON c.customer_unique_id = fp.customer_unique_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS num_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    owc.cohort_month,
    EXTRACT(MONTH FROM AGE(owc.order_month, owc.cohort_month)) AS months_since_first_purchase,
    COUNT(DISTINCT owc.customer_unique_id) AS active_customers,
    cs.num_customers AS cohort_size,
    ROUND(100.0 * COUNT(DISTINCT owc.customer_unique_id) / cs.num_customers, 2) AS retention_pct
FROM orders_with_cohort owc
JOIN cohort_size cs ON owc.cohort_month = cs.cohort_month
GROUP BY owc.cohort_month, months_since_first_purchase, cs.num_customers
ORDER BY owc.cohort_month, months_since_first_purchase;

-- Tip: export this result set and pivot months_since_first_purchase into
-- columns (Excel PivotTable, pandas.pivot_table, or Tableau) to get the
-- classic cohort-retention heatmap/triangle for your README screenshot.
