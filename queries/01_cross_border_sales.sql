-- ==============================================================================
# [Portfolio / Unofficial] kinokuniya-global-analytics
-- レベル1: 日米クロスボーダー売上・商品構成比 比較クエリ（海外事業・経営陣向け）
-- 【ビジネス要求】日本版とアメリカ版の購買ログを統合し、
--  国ごとの「総売上」「客単価」「書籍 vs ホビー（アニメグッズ等）の売上比率」を算出する
-- ==============================================================================

WITH global_raw_logs AS (
    -- 1. 日本国内の購買データを整形して抽出
    SELECT 
        'JP' AS country_code,
        order_id,
        user_id,
        product_category, -- 'Book'(一般書籍/雑誌), 'Hobby'(アニメグッズ/サンリオ/文具)
        price_jpy AS revenue_converted -- 日本円ベース
    FROM 
        kinokuniya_jp_sales
    WHERE 
        purchase_timestamp >= '2026-01-01'

    UNION ALL

    -- 2. アメリカ店舗（Kinokuniya USA）の購買データを日本円に換算して統合
    SELECT 
        'US' AS country_code,
        order_id,
        user_id,
        product_category,
        -- アメリカの売上（USD）を2026年の為替相場（想定: 1ドル=150円）で日本円にクレンジング
        (price_usd * 150) AS revenue_converted
    FROM 
        kinokuniya_usa_sales
    WHERE 
        purchase_timestamp >= '2026-01-01'
),
country_summary AS (
    -- 国ごとのベースとなる売上・客数を集計
    SELECT 
        country_code,
        SUM(revenue_converted) AS total_revenue,
        COUNT(DISTINCT order_id) AS total_orders,
        -- 【書籍売上】
        SUM(CASE WHEN product_category = 'Book' THEN revenue_converted ELSE 0 END) AS book_revenue,
        -- 【ホビー・オタクグッズ売上】
        SUM(CASE WHEN product_category = 'Hobby' THEN revenue_converted ELSE 0 END) AS hobby_revenue
    FROM 
        global_raw_logs
    GROUP BY 
        country_code
)
SELECT 
    country_code,
    -- 総売上高（円）
    total_revenue,
    -- 総注文数
    total_orders,
    -- 【グローバル客単価KPI】
    ROUND(total_revenue / total_orders, 0) AS average_order_value_jpy,
    -- 【ローカライズ比率分析】書籍の売上シェア（%）
    ROUND((book_revenue * 100.0) / total_revenue, 2) AS book_revenue_share_pct,
    -- 【ローカライズ比率分析】ホビー・グッズの売上シェア（%）
    ROUND((hobby_revenue * 100.0) / total_revenue, 2) AS hobby_revenue_share_pct
FROM 
    country_summary
ORDER BY 
    total_revenue DESC;
