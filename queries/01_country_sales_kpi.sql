-- 01_country_sales_kpi.sql
-- 日本・米国の売上KPI比較

SELECT
    c.country,
    SUM(o.quantity * o.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS active_customers,
    SUM(o.quantity) AS total_quantity,
    ROUND(
        SUM(o.quantity * o.unit_price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,
    ROUND(
        SUM(o.quantity * o.unit_price) / COUNT(DISTINCT o.customer_id),
        2
    ) AS sales_per_customer
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_sales DESC;
