# Olist E-Commerce Sales & Customer Cohort Analysis          

SQL-driven analysis of ~100K real e-commerce orders from Olist, a Brazilian
online marketplace, to identify revenue drivers, customer retention
patterns, and delivery performance issues.    

## Problem Statement    

Analyze Olist's 2016–2018 order data to understand revenue drivers, customer
retention, and delivery performance in order to support business decisions
around category investment, retention strategy, and logistics.

## Data

**Source:** [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| Table | Rows (approx.) | Purpose |
|---|---|---|
| `orders` | 99,441 | Order status + all key timestamps |
| `customers` | 99,441 | Customer location, unique ID for repeat-purchase tracking |
| `order_items` | 112,650 | Line-item price/freight, one row per item |
| `products` | 32,951 | Product category + dimensions |
| `order_payments` | 103,886 | Payment type/installments |
| `order_reviews` | 99,224 | Review scores/comments |
| `sellers` | 3,095 | Seller location |
| `geolocation` | ~1M | Zip-code-level lat/long |
| `product_category_name_translation` | 71 | PT → EN category mapping |

**Cleaning steps** (see `sql/02_data_cleaning.sql`):
- Converted all timestamp columns to proper datetime types on load
- Confirmed NULL delivery dates correspond to `canceled`/`unavailable`
  orders — excluded from revenue and delivery analysis rather than dropped
  from the dataset entirely
- Mapped Portuguese product categories to English via the translation table
- Checked for and excluded zero/negative payment values as data errors
- Flagged delivery times >100 days as outliers for review   

## Key Business Questions & Insights
Revenue is concentrated but not monopolized by a few categories. The top 10 product categories drove ~63% of total revenue. Health & Beauty (9.4%), Watches/Gifts (9.0%), and Bed/Bath/Table (7.8%) led the pack — notably, Watches/Gifts had the highest average order value ($213.81) despite ~40% fewer orders than the top category, marking it as a smaller but higher-ticket segment.

Revenue grew steadily through 2017 before plateauing in 2018. Monthly revenue climbed from ~$120K (Jan 2017) to a peak of over $1M (Nov 2017), then settled into a plateau of ~$850K–$990K/month through mid-2018. (Note: 2016 data reflects Olist's soft launch — near-zero volume — and Sept 2018 is a partial month due to the dataset's cutoff; both are excluded from trend claims.)

Retention is the single biggest finding: only 3% of customers ever make a second purchase. Month-1 retention sits under 1% for every cohort analyzed, holding steady out to 11 months post-first-purchase. Confirmed independently via customer-level analysis: 97% of customers (92,168) were one-time buyers, while the 3% who returned (2,853 customers) had an average lifetime value of $260.11 — 88% higher than the $138.36 average for one-time buyers. Olist's revenue growth is being driven almost entirely by new customer acquisition, not repeat purchases.

Repeat-purchase rate varies modestly by state, with Rio de Janeiro the standout among high-volume states. RJ had a 3.40% repeat rate across 12,384 customers — ahead of São Paulo's 3.22% despite SP having 3x the customer base. (Acre and Rondônia technically ranked higher, but with only 77 and 240 customers respectively, RJ is the more statistically credible leader.)

Delivery performance is strong overall but geographically uneven. 91.9% of all orders arrive on time or early, and when delays occur they tend to be severe rather than marginal — 3.47% of orders arrive 8+ days late, more than the 1–7 day late buckets combined. Northeastern states carry the worst performance: Alagoas has both the longest average delivery time (24.5 days) and the highest late rate (23.9%) — over 4x São Paulo's 5.89% late rate, despite SP shipping 100x the volume in less than half the time (8.8 days avg). Among major cities, Salvador (Bahia) stands out with a 17.51% late rate — nearly 3x São Paulo's 6.26% — despite being only the 8th-largest city by order volume.

## Techniques Demonstrated

- Multi-table JOINs across up to 6 tables
- CTEs for multi-stage aggregation
- Window functions: `RANK()`, `LAG()`, rolling averages (`ROWS BETWEEN`)
- Cohort retention analysis (first-purchase-month grouping)
- `CASE`-based bucketing for delay severity
- Date/time arithmetic (`DATE_TRUNC`, `EXTRACT`, `AGE`)

## Repo Structure          

```
olist-ecommerce-analysis/
├── README.md
├── data/                 # place downloaded CSVs here (not committed — see data/README.md)
├── sql/
│   ├── 01_load_data.sql        # schema + \COPY load
│   ├── 02_data_cleaning.sql    # data quality checks
│   ├── 03_revenue_analysis.sql # category revenue + monthly trend
│   ├── 04_cohort_analysis.sql  # monthly cohort retention
│   ├── 05_delivery_analysis.sql# delivery delay by state/city
│   └── 06_customer_ltv.sql     # repeat vs one-time customer LTV
├── notebooks/
│   └── visuals.ipynb     # optional: charts from query outputs
└── images/               # chart screenshots for this README
```

## How to Run

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
   and place the CSVs in `data/` (see `data/README.md`).
2. Create a database: `createdb olist_ecommerce`
3. Load the schema and data:
   ```bash
   psql -d olist_ecommerce -f sql/01_load_data.sql
   ```
4. Run the cleaning checks: `psql -d olist_ecommerce -f sql/02_data_cleaning.sql`
5. Run each analysis script (03–06) and export/chart the results.

## Tools

PostgreSQL · *(add Tableau / Python+matplotlib / Power BI once you pick one)*

## Sample Query — Monthly Cohort Retention

```sql
WITH first_purchase AS (
    SELECT customer_unique_id,
           DATE_TRUNC('month', MIN(order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY customer_unique_id
)
-- full query in sql/04_cohort_analysis.sql
```

*(Add a screenshot of the resulting cohort heatmap here once you've run it.)*
