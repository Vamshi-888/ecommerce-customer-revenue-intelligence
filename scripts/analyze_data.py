
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt

# Project paths
PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "Data"
OUTPUT_DIR = PROJECT_DIR / "outputs"

OUTPUT_DIR.mkdir(exist_ok=True)

# Load the dataset needed for the first analysis
orders = pd.read_csv(
    DATA_DIR / "olist_orders_dataset.csv",
    low_memory=False
)

order_items = pd.read_csv(
    DATA_DIR / "olist_order_items_dataset.csv",
    low_memory=False
)

payments = pd.read_csv(
    DATA_DIR / "olist_order_payments_dataset.csv",
    low_memory=False
)

# Parse timestamps
orders["order_purchase_timestamp"] = pd.to_datetime(
    orders["order_purchase_timestamp"],
    errors="coerce"
)

# Report basic data quality
print("=" * 60)
print("ECOMMERCE DATA ANALYSIS")
print("=" * 60)

print(f"\nOrders loaded: {len(orders):,}")
print(f"Order items loaded: {len(order_items):,}")
print(f"Payment records loaded: {len(payments):,}")

print("\nOrder status distribution:")
print(orders["order_status"].value_counts(dropna=False))

print("\nMissing values in orders:")
print(
    orders.isna()
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

# Monthly order trend
monthly_orders = (
    orders.dropna(subset=["order_purchase_timestamp"])
    .assign(
        purchase_month=lambda df:
        df["order_purchase_timestamp"].dt.to_period("M").astype(str)
    )
    .groupby("purchase_month")["order_id"]
    .nunique()
    .sort_index()
)

print("\nMonthly order counts:")
print(monthly_orders.to_string())

# Save monthly summary
monthly_orders.rename("total_orders").to_csv(
    OUTPUT_DIR / "monthly_orders.csv",
    index_label="purchase_month"
)

# Plot monthly order trend
plt.figure(figsize=(12, 5))
monthly_orders.plot(kind="line", marker="o")
plt.title("Monthly E-commerce Order Trend")
plt.xlabel("Purchase Month")
plt.ylabel("Number of Orders")
plt.xticks(rotation=60)
plt.grid(True, alpha=0.3)
plt.tight_layout()

chart_path = OUTPUT_DIR / "monthly_orders_trend.png"
plt.savefig(chart_path, dpi=150)
plt.close()

print(f"\nMonthly summary saved to: {OUTPUT_DIR / 'monthly_orders.csv'}")
print(f"Trend chart saved to: {chart_path}")
print("\nPython analysis completed.")
