USE sakila;


-- Create a view
CREATE VIEW customer_rental_summary
SELECT 
COUNT(re.rental_id) as rental_count,
re.customer_id,
cu.first_name,
cu.last_name,
cu.email
FROM rental re
JOIN customer cu
ON cu.customer_id = re.customer_id
GROUP BY
re.customer_id,
cu.first_name,
cu.last_name,
cu.email;

-- Create a temporary table 
CREATE TEMPORARY TABLE cust_rental_summary as
	SELECT 
	COUNT(re.rental_id) as rental_count,
	re.customer_id,
	cu.first_name,
	cu.last_name,
	cu.email
	FROM rental re
	JOIN customer cu
	ON cu.customer_id = re.customer_id
	GROUP BY
	re.customer_id,
	cu.first_name,
	cu.last_name,
	cu.email;

CREATE TEMPORARY TABLE total_paid_cust
	SELECT
    crs.customer_id,
    crs.first_name,
    crs.last_name,
    crs.email,
    SUM(pa.amount) as total_paid
    FROM cust_rental_summary crs
    JOIN payment pa
    ON crs.customer_id = pa.customer_id
    GROUP BY 
    crs.customer_id,
    crs.first_name,
    crs.last_name,
    crs.email;
    
-- Create a CTE
WITH cte_view as (
	SELECT
    crs.customer_id,
    crs.first_name,
    crs.last_name,
    crs.email,
    crs.rental_count, 
    tpc.total_paid
    FROM cust_rental_summary crs
    JOIN total_paid_cust tpc
    ON crs.customer_id = tpc.customer_id
)
SELECT
customer_id,
first_name,
last_name,
email,
rental_count,
total_paid,
ROUND (((total_paid) / (rental_count)), 2) as avg_payment_per_rental
FROM cte_view
GROUP BY 
customer_id,
first_name,
last_name,
email,
rental_count,
total_paid;