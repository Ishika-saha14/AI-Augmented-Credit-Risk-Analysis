# 1. What is the overall loan default situation?
SELECT
    COUNT(*) AS total_loans,
    SUM(loan_status = 1) AS defaulted_loans,
    SUM(loan_status = 0) AS non_defaulted_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned;

# 2. Which loan grades have the highest default rates?
SELECT
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_status = 1) AS defaults,
    ROUND(AVG(loan_status) * 100,
    2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY loan_grade
ORDER BY default_rate_pct DESC;

# 3. Which loan purposes have the highest default rates?
SELECT
    loan_intent,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY loan_intent
ORDER BY default_rate_pct DESC;

# 4. How does home ownership relate to default risk?
SELECT
    person_home_ownership,
    COUNT(*) AS total_loans,
    SUM(loan_status = 1) AS defaults,
    ROUND(
        SUM(loan_status = 1) * 100.0 / COUNT(*), 2
    ) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY person_home_ownership
ORDER BY default_rate_pct DESC;

# 5.How does loan burden relate to default risk?
SELECT
    loan_burden,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY loan_burden
ORDER BY default_rate_pct DESC;

# 6. Are higher interest-rate loans associated with higher default rates?
SELECT
    CASE
        WHEN loan_int_rate < 10 THEN 'Below 10%'
        WHEN loan_int_rate < 15 THEN '10% to below 15%'
        ELSE '15% and above'
    END AS interest_rate_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
WHERE loan_int_rate IS NOT NULL
GROUP BY
    CASE
        WHEN loan_int_rate < 10 THEN 'Below 10%'
        WHEN loan_int_rate < 15 THEN '10% to below 15%'
        ELSE '15% and above'
    END
ORDER BY default_rate_pct DESC;

# 7. Does a previous default on file correspond to higher current default rates?
SELECT
    cb_person_default_on_file,
    COUNT(*) AS total_loans,
    SUM(loan_status = 1) AS defaults,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY cb_person_default_on_file
ORDER BY default_rate_pct DESC;

# 8. How does credit history length relate to default rates?
SELECT
    CASE
        WHEN cb_person_cred_hist_length < 3 THEN 'Under 3 years'
        WHEN cb_person_cred_hist_length < 7 THEN '3 to 6 years'
        ELSE '7 years and above'
    END AS credit_history_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY
    CASE
        WHEN cb_person_cred_hist_length < 3 THEN 'Under 3 years'
        WHEN cb_person_cred_hist_length < 7 THEN '3 to 6 years'
        ELSE '7 years and above'
    END
ORDER BY default_rate_pct DESC;

# 9. Which annual-income group has the highest default rate?
SELECT
    CASE
        WHEN person_income < 30000 THEN 'Below 30K'
        WHEN person_income < 60000 THEN '30K to below 60K'
        WHEN person_income < 100000 THEN '60K to below 100K'
        ELSE '100K and above'
    END AS income_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY
    CASE
        WHEN person_income < 30000 THEN 'Below 30K'
        WHEN person_income < 60000 THEN '30K to below 60K'
        WHEN person_income < 100000 THEN '60K to below 100K'
        ELSE '100K and above'
    END
ORDER BY default_rate_pct DESC;

# 10. Are larger loans associated with higher default rates?
SELECT
    CASE
        WHEN loan_amnt < 5000 THEN 'Below 5K'
        WHEN loan_amnt < 10000 THEN '5K to below 10K'
        WHEN loan_amnt < 20000 THEN '10K to below 20K'
        ELSE '20K and above'
    END AS loan_amount_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY
    CASE
        WHEN loan_amnt < 5000 THEN 'Below 5K'
        WHEN loan_amnt < 10000 THEN '5K to below 10K'
        WHEN loan_amnt < 20000 THEN '10K to below 20K'
        ELSE '20K and above'
    END
ORDER BY default_rate_pct DESC;

# 11. Does employment length correspond to different default rates?
SELECT
    CASE
        WHEN person_emp_length < 2 THEN 'Under 2 years'
        WHEN person_emp_length < 5 THEN '2 to 4 years'
        ELSE '5 years and above'
    END AS employment_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
WHERE person_emp_length IS NOT NULL
GROUP BY
    CASE
        WHEN person_emp_length < 2 THEN 'Under 2 years'
        WHEN person_emp_length < 5 THEN '2 to 4 years'
        ELSE '5 years and above'
    END
ORDER BY default_rate_pct DESC;

#  12. Which loan-grade and loan-purpose combinations have elevated default rates?
SELECT
    loan_grade,
    loan_intent,
    COUNT(*) AS total_loans,
    SUM(loan_status = 1) AS defaults,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
GROUP BY loan_grade, loan_intent
HAVING COUNT(*) >= 30
ORDER BY default_rate_pct DESC;

# 13. Which high-burden borrowers have the greatest observed default risk across housing categories?
SELECT
    person_home_ownership,
    COUNT(*) AS total_loans,
    SUM(loan_status = 1) AS defaults,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_default_cleaned
WHERE loan_burden = 'High'
GROUP BY person_home_ownership
HAVING COUNT(*) >= 30
ORDER BY default_rate_pct DESC;

# 14.How can we rank grades by default rate and retain the group size for context?
WITH grade_summary AS (
    SELECT
        loan_grade,
        COUNT(*) AS total_loans,
        ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
    FROM loan_default_cleaned
    GROUP BY loan_grade
)
SELECT
    loan_grade,
    total_loans,
    default_rate_pct,
    RANK() OVER (
        ORDER BY default_rate_pct DESC
    ) AS risk_rank
FROM grade_summary
ORDER BY risk_rank;