-- 01_country_sales_comparison.sql
-- 日本・米国の売上パフォーマンス比較

SELECT
    CASE
        WHEN customer_id LIKE 'JP%' THEN 'Japan'
        WHEN customer_id LIKE 'US%' THEN 'USA'
    END AS country,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(quantity) AS units_sold,
    SUM(quantity * unit_price) AS total_sales,
    ROUND(
        SUM(quantity * unit_price) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM orders
GROUP BY
    CASE
        WHEN customer_id LIKE 'JP%' THEN 'Japan'
        WHEN customer_id LIKE 'US%' THEN 'USA'
    END
ORDER BY total_sales DESC;
