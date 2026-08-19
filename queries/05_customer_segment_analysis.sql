-- 05_customer_segment_analysis.sql
-- 日本・米国の顧客セグメント別購入分析

WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.country,
        c.age_group,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(o.quantity) AS total_quantity,
        SUM(o.quantity * o.unit_price) AS total_sales
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.country,
        c.age_group
)

SELECT
    country,
    age_group,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(order_count) AS total_orders,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(
        SUM(total_sales)
        / NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS sales_per_customer,
    ROUND(
        SUM(total_sales)
        / NULLIF(SUM(order_count), 0),
        2
    ) AS average_order_value
FROM customer_sales
GROUP BY
    country,
    age_group
ORDER BY
    country,
    total_sales DESC;
