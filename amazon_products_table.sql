USE Personal_projects;

CREATE TABLE appliances_products (
product_text variant
);
--creating the table
CREATE or REPLACE TABLE amazon_products AS
SELECT product_text:parent_asin :: string AS product_parent_id,
product_text:average_rating:: decimal AS average_product_rating,
product_text:rating_number:: int AS number_of_ratings,
product_text:price:: string AS price,
product_text:store:: string AS store,
product_text:title:: string AS title, 
product_text:categories:: string AS categories
FROM appliances_products;

SELECT * FROM amazon_products LIMIT 10;