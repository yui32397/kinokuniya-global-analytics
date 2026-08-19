-- 09_repeat_purchase_analysis.sql
-- 日本・米国のリピート購入分析

WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.country,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(o.quantity * o.unit_price) AS total_sales
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.country
),

customer_segments AS (
    SELECT
        customer_id,
        country,
        order_count,
        total_sales,
        CASE
            WHEN order_count = 1 THEN 'One-time'
            WHEN order_count >= 2 THEN 'Repeat'
        END AS customer_type
    FROM customer_orders
)

SELECT
    country,
    customer_type,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(order_count) AS total_orders,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(
        COUNT(DISTINCT customer_id) * 100.0
        / SUM(COUNT(DISTINCT customer_id))
          OVER (PARTITION BY country),
        1
    ) AS customer_share_percent
FROM customer_segments
GROUP BY
    country,
    customer_type
ORDER BY
    country,
    customer_type;
