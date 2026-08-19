-- 04_channel_sales_by_country.sql
-- 日本・米国の販売チャネル別売上比較

SELECT
    c.country,
    o.sales_channel,
    SUM(o.quantity * o.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS active_customers,
    SUM(o.quantity) AS total_quantity,
    ROUND(
        SUM(o.quantity * o.unit_price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    c.country,
    o.sales_channel
ORDER BY
    c.country,
    total_sales DESC;
