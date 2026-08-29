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

*(fill in with your actual numbers once you run the queries — see
placeholders below)*

- Top 5 product categories contributed to **X%** of total revenue
- Customers from **[state]** had the highest repeat purchase rate (**X%**)
- Repeat customers had an average lifetime value **X% higher** than
  one-time buyers
- Late deliveries were concentrated in **[region]**; average delay was
  **X days** vs. **Y days** nationally

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
