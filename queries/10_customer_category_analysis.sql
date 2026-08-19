-- 10_customer_category_analysis.sql
-- 日本・米国の年齢層別 × 商品カテゴリ別売上分析

SELECT
    c.country,
    c.age_group,
    p.category,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.quantity) AS total_quantity,
    ROUND(
        SUM(o.quantity * o.unit_price),
        2
    ) AS total_sales,
    ROUND(
        SUM(o.quantity * o.unit_price)
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS sales_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN products p
    ON o.product_id = p.product_id
GROUP BY
    c.country,
    c.age_group,
    p.category
ORDER BY
    c.country,
    c.age_group,
    total_sales DESC;
