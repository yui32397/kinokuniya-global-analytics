-- 12_global_kpi_summary.sql
-- 日本・米国の主要KPIサマリー

SELECT
    c.country,
    COUNT(DISTINCT o.customer_id) AS active_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_quantity,
    ROUND(
        SUM(o.quantity * o.unit_price),
        2
    ) AS total_sales,
    ROUND(
        SUM(o.quantity * o.unit_price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value,
    ROUND(
        SUM(o.quantity * o.unit_price)
        / NULLIF(COUNT(DISTINCT o.customer_id), 0),
        2
    ) AS sales_per_customer,
    ROUND(
        SUM(o.quantity * o.unit_price)
        / NULLIF(SUM(o.quantity), 0),
        2
    ) AS average_unit_price
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    c.country
ORDER BY
    total_sales DESC;
