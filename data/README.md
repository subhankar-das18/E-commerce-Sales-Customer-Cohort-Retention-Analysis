# Data folder

This folder is intentionally empty in the repo (the raw CSVs are too large
and shouldn't be committed to GitHub).

## Setup

1. Download the dataset from Kaggle:
   https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
2. Unzip and place these 9 files directly in this folder:
   - `olist_customers_dataset.csv`
   - `olist_orders_dataset.csv`
   - `olist_order_items_dataset.csv`
   - `olist_order_payments_dataset.csv`
   - `olist_order_reviews_dataset.csv`
   - `olist_products_dataset.csv`
   - `olist_sellers_dataset.csv`
   - `olist_geolocation_dataset.csv`
   - `product_category_name_translation.csv`
3. Run `sql/01_load_data.sql` from the repo root.
