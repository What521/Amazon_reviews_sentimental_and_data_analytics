# Amazon Appliances Review sentimental and data Analysis

This project analyzes Amazon appliance product data and customer reviews to uncover trends, top products, and sentiment patterns.

## Overview
The workflow includes:
1. **Data Preparation** – Splitting and converting raw JSON files in Jupyter Notebook.
2. **Data Loading** – Importing prepared data into Snowflake tables.
3. **Data Transformation** – Extracting key fields like product IDs, categories, prices, ratings, and review text.
4. **Sentiment Analysis** – Using a Python UDF in Snowflake (with TextBlob) to classify reviews as Positive, Negative, or Neutral.
5. **SQL Analysis** – Querying Snowflake to answer questions such as:
   - Most reviewed products & categories
   - Top users by number of reviews
   - Products with highest positive or negative sentiment
   - Yearly review trends

## Tools & Skills
**Tools:**
- Jupyter Notebook
- Snowflake

**Skills:**
- SQL (data extraction, aggregation, joins)
- Python (data processing, sentiment analysis)
