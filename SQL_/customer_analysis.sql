select * from customer_analytics

-- do krijoj nje tabele te re qe do jete e paster 

SELECT
    customer_id,
    age,
    gender,
    country,
    ISNULL(avg_order_value, 0) AS avg_order_value,
    total_orders,
    last_purchase,
    is_fraudulent,
    preferred_category,
    ISNULL(email_open_rate, 0) AS email_open_rate,
    CAST(customer_since AS DATE) AS customer_since,
    loyalty_score,
    ISNULL(churn_risk, 0) AS churn_risk
INTO data_analytics_clean
FROM customer_analytics;

select * from data_analytics_clean

-- e bera null = o per ta bere me te lehte per ne power bi ndersa churn risk ka vetem 3 raste kshu qe e bera 0

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM data_analytics_clean;

-- kontrollova nese total rows jane 5000 sa tek tabela e pare

-- krijoj view-n e pare customer_analytics

CREATE VIEW vw_customer_analytics AS
SELECT
    customer_id,
    age,
    gender,
    country,
    avg_order_value,
    total_orders,

    avg_order_value * total_orders AS estimated_total_spend,

    last_purchase,
    is_fraudulent,
    preferred_category,
    email_open_rate,
    customer_since,
    loyalty_score,
    churn_risk,

    CASE
        WHEN churn_risk >= 0.60 THEN 'High Risk'
        WHEN churn_risk >= 0.30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_category,

    CASE
        WHEN loyalty_score >= 70 THEN 'High Loyalty'
        WHEN loyalty_score >= 40 THEN 'Medium Loyalty'
        ELSE 'Low Loyalty'
    END AS loyalty_category

FROM data_analytics_clean;

SELECT *
FROM vw_customer_analytics;

-- bej nje analize

SELECT
    country,
    COUNT(*) AS customers,
    SUM(estimated_total_spend) AS estimated_revenue,
    AVG(avg_order_value) AS avg_order_value,
    AVG(churn_risk) AS avg_churn_risk
FROM vw_customer_analytics
GROUP BY country
ORDER BY estimated_revenue DESC;

-- krijoj nje view per KPI-te e customer_analytics

CREATE VIEW vw_customer_kpi AS
SELECT
    customer_id,
    country,
    gender,
    age,
    preferred_category,
    avg_order_value,
    total_orders,
    avg_order_value * total_orders AS estimated_total_spend,
    last_purchase,
    is_fraudulent,
    email_open_rate,
    loyalty_score,
    churn_risk,
    churn_category,
    loyalty_category
FROM vw_customer_analytics;

SELECT *
FROM vw_customer_kpi;

-- krijoj view per segmentimin e klienteve

CREATE VIEW vw_customer_segments AS
SELECT
    customer_id,
    country,
    age,
    gender,
    preferred_category,
    estimated_total_spend,
    total_orders,
    loyalty_score,
    churn_risk,

    CASE
        WHEN estimated_total_spend >= 3000 THEN 'High Value'
        WHEN estimated_total_spend >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment

FROM vw_customer_analytics;

-- do marr analizat kreysore per dashboardin ne power bi

SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(estimated_total_spend) AS estimated_revenue,
    AVG(loyalty_score) AS avg_loyalty,
    AVG(churn_risk) AS avg_churn
FROM vw_customer_segments
GROUP BY customer_segment
ORDER BY estimated_revenue DESC;

-- krijoj nje view per risk dhe fraud

CREATE VIEW vw_customer_risk AS
SELECT
    customer_id,
    country,
    preferred_category,
    total_orders,
    estimated_total_spend,
    loyalty_score,
    churn_risk,
    churn_category,
    is_fraudulent,

    CASE
        WHEN is_fraudulent = 1 THEN 'Fraudulent'
        ELSE 'Normal'
    END AS fraud_status

FROM vw_customer_analytics;

-- me pas i analizoj

SELECT
    fraud_status,
    COUNT(*) AS customers,
    SUM(estimated_total_spend) AS estimated_revenue,
    AVG(churn_risk) AS avg_churn_risk
FROM vw_customer_risk
GROUP BY fraud_status;

-- krijoj nje view final per ne dashboard qe te mos kem nevoje per shume transformime ne power bi

CREATE VIEW vw_powerbi_customer AS
SELECT
    customer_id,
    age,
    gender,
    country,
    preferred_category,
    avg_order_value,
    total_orders,
    estimated_total_spend,
    last_purchase,
    is_fraudulent,
    email_open_rate,
    customer_since,
    loyalty_score,
    churn_risk,
    churn_category,
    loyalty_category,

    CASE
        WHEN estimated_total_spend >= 3000 THEN 'High Value'
        WHEN estimated_total_spend >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,

    CASE
        WHEN is_fraudulent = 1 THEN 'Fraudulent'
        ELSE 'Normal'
    END AS fraud_status

FROM vw_customer_analytics;

