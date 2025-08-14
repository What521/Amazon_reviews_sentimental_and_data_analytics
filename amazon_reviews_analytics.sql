--Number of different products in each category
with cte as(
SELECT
    product_parent_id,
    category.value::string AS category
FROM amazon_products,
LATERAL FLATTEN(input => PARSE_JSON(categories)) AS category)

SELECT category, COUNT(*) AS number_of_products FROM cte
GROUP BY category
ORDER BY number_of_products DESC;

--top 10 users who have reviewed the most products that is part of the appliances
SELECT r.user_id, COUNT(distinct r.product_parent_id) AS number_of_reviews
FROM amazon_appliances_reviews r
JOIN amazon_products p ON r.product_parent_id = p.product_parent_id
WHERE p.categories ilike '%appliances%'
GROUP BY r.user_id
ORDER BY number_of_reviews DESC 
LIMIT 10;

--rank all categories of products from most popular to least popular based on the number of reviews
with cte as(
SELECT
    product_parent_id,
    category.value::string AS category
FROM amazon_products,
LATERAL FLATTEN(input => PARSE_JSON(categories)) AS category)
SELECT category, COUNT(*) AS number_of_reviews FROM cte
JOIN amazon_appliances_reviews r ON cte.product_parent_id = r.product_parent_id
GROUP BY category
ORDER BY number_of_reviews DESC;

--2 most recent reviews for each products
with cte AS (SELECT r.product_parent_id, p.title, review_date, row_number() over(partition by r.product_parent_id ORDER BY review_date DESC) AS rn
FROM amazon_appliances_reviews r
JOIN amazon_products p ON r.product_parent_id = p.product_parent_id
)
SELECT * FROM cte
WHERE rn <=2;

--rank the years based on the highest number of reviews
SELECT YEAR(review_date) AS year, COUNT(*) AS number_of_reviews FROM amazon_appliances_reviews
GROUP BY year
ORDER BY number_of_reviews DESC;

--the percent of 5/5 ratings for each product
SELECT p.product_parent_id, p.title, COUNT(*) AS number_of_reviews, SUM(CASE when r.review_rating=5 THEN 1 else 0 END) AS number_of_5_rating, (number_of_5_rating/number_of_reviews)*100 AS percentage_of_5_rating
FROM amazon_appliances_reviews r
JOIN amazon_products p ON r.product_parent_id = p.product_parent_id
GROUP BY p.product_parent_id, p.title
ORDER BY number_of_reviews DESC;

--3 most reviewed product from each store
with cte AS (SELECT p.product_parent_id, p.title, p.store, COUNT(*) AS number_of_reviews
FROM amazon_appliances_reviews r
JOIN amazon_products p ON r.product_parent_id = p.product_parent_id
GROUP BY p.product_parent_id, p.title, p.store),

ranked AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY store ORDER BY number_of_reviews DESC) AS rn
    FROM cte
)
SELECT *
FROM ranked
WHERE rn <= 3;

--top 10 users who have done the most reviews and all the products they reviewed
WITH cte AS (SELECT r.user_id, COUNT(*) AS number_of_reviews
FROM amazon_appliances_reviews r
JOIN amazon_products p ON r.product_parent_id = p.product_parent_id
GROUP BY r.user_id
ORDER BY number_of_reviews DESC 
LIMIT 10)

SELECT user_id, product_parent_id FROM amazon_appliances_reviews
WHERE user_id IN (SELECT user_id FROM cte);

--top 10 products with highest number of positive sentiments
SELECT p.product_parent_id, p.title, COUNT(*) AS number_of_reviews
FROM amazon_appliances_reviews r
JOIN amazon_products p ON r.product_parent_id = p.product_parent_id
WHERE sentiments = 'Positive'
GROUP BY p.product_parent_id, p.title
ORDER BY number_of_reviews DESC 
LIMIT 10;

--product with the highest positive sentiments in each category
with cte AS (SELECT 
    category.value::string AS category,
    p.product_parent_id,
    p.title,
    COUNT(*) AS number_of_reviews
FROM amazon_appliances_reviews r
JOIN amazon_products p 
    ON r.product_parent_id = p.product_parent_id
, LATERAL FLATTEN(input => PARSE_JSON(categories)) AS category
WHERE sentiments = 'Positive'
GROUP BY category, p.product_parent_id, p.title)

SELECT *
FROM cte
QUALIFY ROW_NUMBER() OVER (PARTITION BY category ORDER BY number_of_reviews DESC) = 1;

--product with the most negative sentiments from each store
with cte AS (SELECT p.product_parent_id, p.title, p.store, COUNT(*) AS number_of_reviews FROM amazon_products p
JOIN amazon_appliances_reviews r ON p.product_parent_id = r.product_parent_id
WHERE r.sentiments = 'Negative'
GROUP BY p.product_parent_id, p.title, p.store)

SELECT * FROM cte
QUALIFY row_number() over (PARTITION BY store ORDER BY number_of_reviews DESC) = 1;

--top 10 products with the most positive sentiments in the appliances category
SELECT p.product_parent_id, p.title, COUNT(*) AS number_of_reviews
FROM amazon_products p
JOIN amazon_appliances_reviews r ON p.product_parent_id = r.product_parent_id
WHERE r.sentiments = 'Positive' AND p.categories ilike '%appliances%'
GROUP BY p.product_parent_id, p.title
ORDER BY number_of_reviews DESC
LIMIT 10;