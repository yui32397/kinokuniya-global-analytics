-- 07_product_sales_ranking.sql
-- 日本・米国の商品別売上ランキング

WITH product_sales AS (
    SELECT
        c.country,
        p.product_id,
        p.product_name,
        p.category,
        SUM(o.quantity) AS total_quantity,
        SUM(o.quantity * o.unit_price) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY
        c.country,
        p.product_id,
        p.product_name,
        p.category
),

ranked_products AS (
    SELECT
        country,
        product_id,
        product_name,
        category,
        total_quantity,
        total_sales,
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM product_sales
)

SELECT
    country,
    sales_rank,
    product_id,
    product_name,
    category,
    total_quantity,
    ROUND(total_sales, 2) AS total_sales
FROM ranked_products
ORDER BY
    country,
    sales_rank;
