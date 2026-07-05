-- ==============================================================================
-- レベル3: 日米ローカライズ顧客分析（購買頻度・RFMベース抽出クエリ）
-- 【ビジネス要求】Looker Studioの顧客セグメント散布図にマウントするため、
--  日本（JP）とアメリカ（US）それぞれの顧客ごとの「総購入金額」「購入回数」を抽出・分類する
-- ==============================================================================

WITH customer_raw_data AS (
    -- 日本の顧客ごとの集計
    SELECT 
        'JP' AS country_code,
        user_id,
        COUNT(DISTINCT order_id) AS purchase_frequency,
        SUM(price_jpy) AS total_monetary_jpy
    FROM 
        kinokuniya_jp_sales
    WHERE 
        purchase_timestamp >= '2026-01-01'
    GROUP BY 
        user_id

    UNION ALL

    -- アメリカの顧客ごとの集計（ドルを150円換算してがっちゃんこ）
    SELECT 
        'US' AS country_code,
        user_id,
        COUNT(DISTINCT order_id) AS purchase_frequency,
        SUM(price_usd * 150) AS total_monetary_jpy
    FROM 
        kinokuniya_usa_sales
    WHERE 
        purchase_timestamp >= '2026-01-01'
    GROUP BY 
        user_id
)
SELECT 
    country_code,
    user_id,
    purchase_frequency AS total_orders_count,
    total_monetary_jpy,
    -- 【ローカライズセグメント分岐】
    -- 購入回数と金額をもとに、顧客が「コアなリピーター」か「ライト層」かを実務的に分類
    CASE 
        WHEN purchase_frequency >= 5 AND total_monetary_jpy >= 30000 THEN 'ロイヤル・ファン'
        WHEN purchase_frequency >= 2 THEN 'アクティブ・リピーター'
        ELSE 'ワンタイム・ビジター'
    END AS customer_loyalty_class
FROM 
    customer_raw_data
ORDER BY 
    total_monetary_jpy DESC;
