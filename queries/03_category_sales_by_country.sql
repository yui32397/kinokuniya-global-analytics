-- 03_category_sales_by_country.sql
-- 日本・米国の商品カテゴリ別売上比較

SELECT
    c.country,
    p.category,
    SUM(o.quantity * o.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.quantity) AS total_quantity,
    ROUND(
        SUM(o.quantity * o.unit_price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN products p
    ON o.product_id = p.product_id
GROUP BY
    c.country,
    p.category
ORDER BY
    c.country,
    total_sales DESC;
