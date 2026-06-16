-- =========================================================
-- 1. OVERALL CHURN RATE
-- =========================================================

SELECT
    ROUND(
        SUM(churn) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM customers;


-- =========================================================
-- 2. CHURN BY CONTRACT TYPE
-- =========================================================

SELECT
    contract_type,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        SUM(churn) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY contract_type
ORDER BY churn_rate DESC;


-- =========================================================
-- 3. CHURN BY TENURE GROUP
-- =========================================================

SELECT
    CASE
        WHEN tenure <= 6 THEN '0-6 Months'
        WHEN tenure <= 12 THEN '7-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        ELSE '25+ Months'
    END AS tenure_group,
    COUNT(*) AS customers,
    SUM(churn) AS churned_customers,
    ROUND(
        SUM(churn) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY tenure_group
ORDER BY churn_rate DESC;


-- =========================================================
-- 4. CHURN BY INTERNET SERVICE
-- =========================================================

SELECT
    internet_service,
    COUNT(*) AS customers,
    SUM(churn) AS churned_customers,
    ROUND(
        SUM(churn) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY internet_service
ORDER BY churn_rate DESC;


-- =========================================================
-- 5. AVERAGE TENURE BY CHURN STATUS
-- =========================================================

SELECT
    churn,
    ROUND(AVG(tenure), 2) AS avg_tenure
FROM customers
GROUP BY churn;


-- =========================================================
-- 6. HIGH VS LOW VALUE CUSTOMER CHURN
-- =========================================================

SELECT
    CASE
        WHEN monthly_charges >= 70 THEN 'High Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customers,
    SUM(churn) AS churned_customers,
    ROUND(
        SUM(churn) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY customer_segment;


-- =========================================================
-- 7. CUSTOMER RISK SCORING
-- =========================================================

SELECT
    customer_id,
    tenure,
    monthly_charges,
    contract_type,
    CASE
        WHEN tenure < 6
             AND contract_type = 'Month-to-month'
        THEN 'High Risk'

        WHEN tenure BETWEEN 6 AND 12
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS risk_segment
FROM customers;


-- =========================================================
-- 8. CHURN RATE VS COMPANY AVERAGE
-- =========================================================

WITH company_avg AS (
    SELECT
        AVG(churn) * 100.0 AS avg_churn_rate
    FROM customers
)

SELECT
    contract_type,
    ROUND(
        AVG(churn) * 100.0,
        2
    ) AS churn_rate,
    ROUND(
        AVG(churn) * 100.0 - company_avg.avg_churn_rate,
        2
    ) AS difference_from_company_avg
FROM customers
CROSS JOIN company_avg
GROUP BY contract_type, company_avg.avg_churn_rate
ORDER BY difference_from_company_avg DESC;


-- =========================================================
-- 9. CHURN SEGMENT RANKING
-- =========================================================

SELECT
    contract_type,
    ROUND(
        AVG(churn) * 100.0,
        2
    ) AS churn_rate,
    RANK() OVER (
        ORDER BY AVG(churn) DESC
    ) AS churn_rank
FROM customers
GROUP BY contract_type;


-- =========================================================
-- 10. TOP CHURN-DRIVING COMBINATIONS
-- =========================================================

SELECT
    contract_type,
    internet_service,
    online_security,
    COUNT(*) AS customers,
    ROUND(
        AVG(churn) * 100.0,
        2
    ) AS churn_rate
FROM customers
GROUP BY
    contract_type,
    internet_service,
    online_security
ORDER BY churn_rate DESC;


-- =========================================================
-- 11. RETENTION LEADERBOARD
-- =========================================================

SELECT
    contract_type,
    ROUND(
        (1 - AVG(churn)) * 100.0,
        2
    ) AS retention_rate,
    RANK() OVER (
        ORDER BY (1 - AVG(churn)) DESC
    ) AS retention_rank
FROM customers
GROUP BY contract_type;


-- =========================================================
-- 12. CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- =========================================================

SELECT
    churn,
    ROUND(
        AVG(tenure * monthly_charges),
        2
    ) AS avg_customer_lifetime_value
FROM customers
GROUP BY churn;


-- =========================================================
-- 13. TENURE TREND ANALYSIS
-- =========================================================

SELECT
    tenure,
    ROUND(
        AVG(churn) * 100.0,
        2
    ) AS churn_rate
FROM customers
GROUP BY tenure
ORDER BY tenure;


-- =========================================================
-- 14. CUMULATIVE CHURN BY TENURE
-- =========================================================

WITH tenure_churn AS (
    SELECT
        tenure,
        COUNT(*) AS customers,
        SUM(churn) AS churned
    FROM customers
    GROUP BY tenure
)

SELECT
    tenure,
    churned,
    SUM(churned) OVER (
        ORDER BY tenure
    ) AS cumulative_churn
FROM tenure_churn
ORDER BY tenure;


-- =========================================================
-- 15. CHURN ANOMALY DETECTION
-- =========================================================

SELECT
    contract_type,
    ROUND(
        AVG(churn) * 100.0,
        2
    ) AS churn_rate,
    ROUND(
        (
            AVG(churn) -
            AVG(AVG(churn)) OVER ()
        )
        /
        NULLIF(
            STDDEV(AVG(churn)) OVER (),
            0
        ),
        2
    ) AS z_score
FROM customers
GROUP BY contract_type;
