
--Query entire table to study data set
SELECT *
FROM telecom_customer;

--Which age groups send more sms messages than make phone calls?
SELECT age, age_group, SUM(frequency_of_sms) AS total_sms_messages, SUM(frequency_of_use) AS total_calls_made
FROM telecom_customer
GROUP BY age_group, age
HAVING SUM(frequency_of_sms) > SUM(frequency_of_use)
ORDER BY age_group;


--Is there a significant difference in length of phone calls between the different tariff plans?
SELECT CASE
        WHEN tariff_plan = 1 THEN 'Pay as you go'
		WHEN tariff_plan = 2 THEN 'Contractual' END AS tariff__plan, SUM(seconds_of_use) AS call_length
FROM telecom_customer
GROUP BY tariff_plan
ORDER BY SUM(seconds_of_use);

--Total number of distinct phone calls by age group
SELECT age, age_group, SUM(distinct_called_numbers) AS total_distinct_called_numbers
FROM telecom_customer
GROUP BY age, age_group
ORDER BY SUM(distinct_called_numbers);

--How likely is it for a customer to churn?
SELECT ROUND((churned * 1.0) / (total_customers) * 100, 2) AS likely_to_churn FROM
							(SELECT COUNT(CASE WHEN churn = 1 THEN 1 END) AS churned, 
							 COUNT(*) AS total_customers 
							 FROM telecom_customer) AS c







			


  




