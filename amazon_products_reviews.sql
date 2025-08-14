USE Personal_projects;
CREATE table appliances_reviews (review_text variant);

--create a sentiment analyzing function
CREATE OR REPLACE FUNCTION sentiment_analyzer(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('textblob')
HANDLER = 'analyze_sentiment'
AS $$
from textblob import TextBlob
def analyze_sentiment(text):
    polarity = TextBlob(text).sentiment.polarity
    if polarity > 0:
        return 'Positive'
    elif polarity < 0:
        return 'Negative'
    else:
        return 'Neutral'
$$;

--creating a table using all the info that we need
CREATE or REPLACE TABLE amazon_appliances_reviews AS
SELECT review_text:asin :: string AS product_id,
review_text:parent_asin :: string AS product_parent_id,
--the supposed timestamp was in milliseconds which we had to convert into seconds first before doing any conversion
TO_DATE(TO_TIMESTAMP(review_text:timestamp::int / 1000)) AS review_date,
review_text:user_id :: string AS user_id,
review_text:rating :: decimal AS review_rating,
review_text:text :: string AS written_review,
sentiment_analyzer(written_review) AS sentiments
FROM appliances_reviews;

SELECT * FROM amazon_appliances_reviews LIMIT 10;


