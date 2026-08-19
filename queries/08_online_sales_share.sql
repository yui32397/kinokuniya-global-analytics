-- 08_online_sales_share.sql
-- 日本・米国のOnline売上比率比較

WITH channel_sales AS (
    SELECT
        c.country,
        o.sales_channel,
        SUM(o.quantity * o.unit_price) AS channel_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.country,
        o.sales_channel
),

country_sales AS (
    SELECT
        country,
        SUM(channel_sales) AS total_sales
    FROM channel_sales
    GROUP BY
        country
)

SELECT
    cs.country,
    cs.sales_channel,
    ROUND(cs.channel_sales, 2) AS channel_sales,
    ROUND(ct.total_sales, 2) AS total_country_sales,
    ROUND(
        cs.channel_sales
        / NULLIF(ct.total_sales, 0) * 100,
        1
    ) AS sales_share_percent
FROM channel_sales cs
JOIN country_sales ct
    ON cs.country = ct.country
ORDER BY
    cs.country,
    sales_share_percent DESC;
