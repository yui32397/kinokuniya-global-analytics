-- ==============================================================================
-- レベル2: 米国店舗における「MANGA・アニメグッズ」の前年比（YoY）成長率分析クエリ
-- 【ビジネス要求】Looker Studioの成長率折れ線グラフにマウントするため、
--  アメリカ（US）市場における特定のオタクカルチャー関連カテゴリーの売上伸び率を算出する
-- ==============================================================================

WITH usa_annual_summary AS (
    SELECT 
        -- 購買タイムスタンプから「購入年（YYYY）」を抽出
        DATE_FORMAT(purchase_timestamp, '%Y') AS purchase_year,
        product_category,
        
        -- アメリカの売上（USD）を合算
        SUM(price_usd) AS total_revenue_usd
    FROM 
        kinokuniya_usa_sales
    WHERE 
        -- 過去数年間のトレンドを追うため、2024年から2026年を対象にファクトチェック
        purchase_timestamp >= '2024-01-01'
        AND product_category IN ('Manga', 'Hobby') -- 英語版マンガとアニメグッズを狙い撃ち
    GROUP BY 
        1, 2
),
growth_calculated AS (
    SELECT 
        purchase_year,
        product_category,
        total_revenue_usd,
        -- 【ウィンドウ関数マウント】LAG関数を使って「ちょうど1年前の売上」を横に引っ張ってくる
        LAG(total_revenue_usd, 1) OVER (
            PARTITION BY product_category 
            ORDER BY purchase_year ASC
        ) AS last_year_revenue_usd
    FROM 
        usa_annual_summary
)
SELECT 
    purchase_year,
    product_category,
    total_revenue_usd,
    COALESCE(last_year_revenue_usd, 0) AS last_year_revenue_usd,
    -- 【YoY成長率KPI】（（今年 - 去年）/ 去年）× 100 で前年比伸び率（%）を計算
    CASE 
        WHEN last_year_revenue_usd IS NULL THEN 0.00
        ELSE ROUND(((total_revenue_usd - last_year_revenue_usd) * 100.0) / last_year_revenue_usd, 2)
    END AS yoy_growth_rate_percentage
FROM 
    growth_calculated
ORDER BY 
    product_category, 
    purchase_year ASC;
