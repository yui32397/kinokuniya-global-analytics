-- 02_yoy_sales_comparison.sql
-- 日本・米国の前年比（YoY）売上比較

WITH yearly_sales AS (
    SELECT
        c.country,
        EXTRACT(YEAR FROM o.order_date) AS year,
        SUM(o.quantity * o.unit_price) AS total_sales,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM orders AS o
    LEFT JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.country,
        EXTRACT(YEAR FROM o.order_date)
),

yoy_sales AS (
    SELECT
        country,
        year,
        total_sales,
        order_count,
        active_customers,
        LAG(total_sales) OVER (
            PARTITION BY country
            ORDER BY year
        ) AS previous_year_sales
    FROM yearly_sales
)

SELECT
    country,
    year,
    ROUND(total_sales, 2) AS total_sales,
    order_count,
    active_customers,
    ROUND(previous_year_sales, 2) AS previous_year_sales,
    ROUND(
        (total_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS yoy_growth_rate
FROM yoy_sales
WHERE previous_year_sales IS NOT NULL
ORDER BY
    country,
    year;
