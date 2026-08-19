-- 06_category_sales_share.sql
-- 日本・米国における商品カテゴリ別売上構成比

WITH category_sales AS (
    SELECT
        c.country,
        p.category,
        SUM(o.quantity * o.unit_price) AS category_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY
        c.country,
        p.category
),

country_totals AS (
    SELECT
        country,
        SUM(category_sales) AS total_country_sales
    FROM category_sales
    GROUP BY
        country
)

SELECT
    cs.country,
    cs.category,
    ROUND(cs.category_sales, 2) AS category_sales,
    ROUND(ct.total_country_sales, 2) AS total_country_sales,
    ROUND(
        cs.category_sales
        / NULLIF(ct.total_country_sales, 0) * 100,
        1
    ) AS sales_share_percent,
    RANK() OVER (
        PARTITION BY cs.country
        ORDER BY cs.category_sales DESC
    ) AS category_sales_rank
FROM category_sales cs
JOIN country_totals ct
    ON cs.country = ct.country
ORDER BY
    cs.country,
    category_sales_rank;
