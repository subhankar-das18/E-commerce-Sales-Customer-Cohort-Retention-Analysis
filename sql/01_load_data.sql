-- ============================================================
-- 01_load_data.sql
-- Creates schema and loads the 9 Olist CSVs into PostgreSQL.
-- Prereq: download CSVs from Kaggle and place them in the
-- /data folder (see data/README.md), then run this file with:
--   psql -d olist_ecommerce -f sql/01_load_data.sql
-- ============================================================

-- Drop tables if re-running from scratch
DROP TABLE IF EXISTS order_reviews, order_payments, order_items,
    orders, products, customers, sellers, geolocation,
    product_category_name_translation CASCADE;

CREATE TABLE customers (
    customer_id             VARCHAR PRIMARY KEY,
    customer_unique_id      VARCHAR,
    customer_zip_code_prefix VARCHAR,
    customer_city           VARCHAR,
    customer_state          VARCHAR
);

CREATE TABLE sellers (
    seller_id               VARCHAR PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR,
    seller_city             VARCHAR,
    seller_state            VARCHAR
);

CREATE TABLE product_category_name_translation (
    product_category_name          VARCHAR PRIMARY KEY,
    product_category_name_english  VARCHAR
);

CREATE TABLE products (
    product_id                  VARCHAR PRIMARY KEY,
    product_category_name       VARCHAR,
    product_name_lenght         INT,
    product_description_lenght  INT,
    product_photos_qty          INT,
    product_weight_g            NUMERIC,
    product_length_cm           NUMERIC,
    product_height_cm           NUMERIC,
    product_width_cm            NUMERIC
);

CREATE TABLE orders (
    order_id                       VARCHAR PRIMARY KEY,
    customer_id                    VARCHAR REFERENCES customers(customer_id),
    order_status                   VARCHAR,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP
);

CREATE TABLE order_items (
    order_id             VARCHAR REFERENCES orders(order_id),
    order_item_id        INT,
    product_id           VARCHAR REFERENCES products(product_id),
    seller_id            VARCHAR REFERENCES sellers(seller_id),
    shipping_limit_date  TIMESTAMP,
    price                NUMERIC,
    freight_value        NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id              VARCHAR REFERENCES orders(order_id),
    payment_sequential    INT,
    payment_type          VARCHAR,
    payment_installments  INT,
    payment_value         NUMERIC,
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id                 VARCHAR,
    order_id                  VARCHAR REFERENCES orders(order_id),
    review_score              INT,
    review_comment_title      VARCHAR,
    review_comment_message    TEXT,
    review_creation_date      TIMESTAMP,
    review_answer_timestamp   TIMESTAMP
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR,
    geolocation_lat             NUMERIC,
    geolocation_lng             NUMERIC,
    geolocation_city            VARCHAR,
    geolocation_state           VARCHAR
);

-- ---- Load data (adjust file paths as needed) ----
\COPY customers FROM 'data/olist_customers_dataset.csv' CSV HEADER;
\COPY sellers FROM 'data/olist_sellers_dataset.csv' CSV HEADER;
\COPY product_category_name_translation FROM 'data/product_category_name_translation.csv' CSV HEADER;
\COPY products FROM 'data/olist_products_dataset.csv' CSV HEADER;
\COPY orders FROM 'data/olist_orders_dataset.csv' CSV HEADER;
\COPY order_items FROM 'data/olist_order_items_dataset.csv' CSV HEADER;
\COPY order_payments FROM 'data/olist_order_payments_dataset.csv' CSV HEADER;
\COPY order_reviews FROM 'data/olist_order_reviews_dataset.csv' CSV HEADER;
\COPY geolocation FROM 'data/olist_geolocation_dataset.csv' CSV HEADER;

-- ---- Sanity check row counts ----
SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation;
