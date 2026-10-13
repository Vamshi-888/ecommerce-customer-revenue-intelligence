from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "Data"
OUTPUT_DIR = PROJECT_DIR / "outputs"
OUTPUT_DIR.mkdir(exist_ok=True)

# Load the required datasets
orders = pd.read_csv(
    DATA_DIR / "olist_orders_dataset.csv",
    low_memory=False
)

order_items = pd.read_csv(
    DATA_DIR / "olist_order_items_dataset.csv",
    low_memory=False
)

# Convert purchase timestamps to datetime
orders["order_purchase_timestamp"] = pd.to_datetime(
    orders["order_purchase_timestamp"],
    errors="coerce"
)

# Convert price and freight columns to numeric
order_items["price"] = pd.to_numeric(
    order_items["price"], errors="coerce"
)

order_items["freight_value"] = pd.to_numeric(
    order_items["freight_value"], errors="coerce"
)

# Aggregate item values by order first to avoid duplicate orders
items_by_order = (
    order_items.groupby("order_id", as_index=False)
    .agg(
        item_revenue_brl=("price", "sum"),
        shipping_charges_brl=("freight_value", "sum")
    )
)

# Join order-level values to order dates and statuses
analysis = orders[
    ["order_id", "order_purchase_timestamp", "order_status"]
].merge(
    items_by_order,
    on="order_id",
    how="left"
)

# Use delivered orders for the main revenue summary
delivered = analysis[
    (analysis["order_status"] == "delivered")
    & (analysis["order_purchase_timestamp"].notna())
].copy()

delivered["purchase_month"] = (
    delivered["order_purchase_timestamp"]
    .dt.to_period("M")
    .astype(str)
)

# Create monthly summary
monthly_revenue = (
    delivered.groupby("purchase_month", as_index=False)
    .agg(
        delivered_orders=("order_id", "nunique"),
        item_revenue_brl=("item_revenue_brl", "sum"),
        shipping_charges_brl=("shipping_charges_brl", "sum")
    )
)

monthly_revenue["item_revenue_brl"] = (
    monthly_revenue["item_revenue_brl"].round(2)
)

monthly_revenue["shipping_charges_brl"] = (
    monthly_revenue["shipping_charges_brl"].round(2)
)
monthly_revenue["avg_item_value_per_delivered_order_brl"] = (
    monthly_revenue["item_revenue_brl"]
    / monthly_revenue["delivered_orders"]
).round(2)

output_path = OUTPUT_DIR / "monthly_revenue.csv"
monthly_revenue.to_csv(output_path, index=False)

print(monthly_revenue.to_string(index=False))
print(f"\nSaved revenue summary to: {output_path}")
print("\nRevenue summary created successfully.")
