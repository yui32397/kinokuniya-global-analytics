-- 11_monthly_seasonality_analysis.sql
-- 日本・米国の月別売上・季節性分析

WITH monthly_sales AS (
    SELECT
        c.country,
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM(o.quantity * o.unit_price) AS total_sales,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.country,
        EXTRACT(MONTH FROM o.order_date)
),

country_totals AS (
    SELECT
        country,
        SUM(total_sales) AS annual_sales
    FROM monthly_sales
    GROUP BY
        country
)

SELECT
    ms.country,
    ms.month,
    ROUND(ms.total_sales, 2) AS total_sales,
    ms.order_count,
    ms.active_customers,
    ROUND(
        ms.total_sales
        / NULLIF(ct.annual_sales, 0) * 100,
        1
    ) AS monthly_sales_share_percent,
    RANK() OVER (
        PARTITION BY ms.country
        ORDER BY ms.total_sales DESC
    ) AS monthly_sales_rank
FROM monthly_sales ms
JOIN country_totals ct
    ON ms.country = ct.country
ORDER BY
    ms.country,
    ms.month;
