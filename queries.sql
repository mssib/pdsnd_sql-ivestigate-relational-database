/* Query 1 - the query used for the 1st insight */

WITH family_films AS
(SELECT *
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE name ='Animation'
OR name ='Children'
OR name ='Classics'
OR name ='Comedy'
OR name ='Family'
OR name ='Music')

SELECT title film_title, name category_name,
COUNT (*) rental_count
FROM family_films
GROUP BY 1,2
ORDER BY 3 DESC;

/* Query 2 - the query used for the 2nd insight */

SELECT
DATE_PART ('month',rental.rental_date) AS rental_month,
DATE_PART ('year',rental.rental_date) AS rental_year,
store.store_id, COUNT(rental.rental_id) count_rental
FROM store
JOIN staff
ON store.store_id = staff.store_id
JOIN payment
ON staff.staff_id = payment.staff_id
JOIN rental
ON rental.rental_id = payment.rental_id
GROUP BY 1,2,3
ORDER BY 2,1;

/* Query 3 - the query used for the 3rd insight */

SELECT f.title film_title, COUNT (r.rental_id) count_rental
FROM film f
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/* Query 4 - the query used for the 4th insight */

SELECT all_countries.country,
TO_CHAR(all_countries.payment_date,'YYYY-MM-DD') as payment_date,
SUM(all_countries.payment_amount) OVER (PARTITION BY all_countries.country  ORDER BY
all_countries.payment_date ) as cumulative_payments

FROM (SELECT country.country as country,
DATE_TRUNC ('day',p.payment_date)  as payment_date,
SUM(p.amount) as payment_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
JOIN address a
ON c.address_id = a.address_id
JOIN city
ON a.city_id = city.city_id
JOIN country
ON country.country_id = city.country_id
GROUP BY 1,2) all_countries

JOIN (SELECT country.country as country , SUM(p.amount) as payment_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
JOIN address a
ON c.address_id = a.address_id
JOIN city
ON a.city_id = city.city_id
JOIN country
ON country.country_id = city.country_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5) top_five
ON top_five.country = all_countries.country;
