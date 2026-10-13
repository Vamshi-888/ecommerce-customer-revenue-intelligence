
import csv
import io
import psycopg
from pathlib import Path
from psycopg import sql

DATA_DIR = Path(__file__).resolve().parent.parent / "Data"

DB_CONFIG = {
    "dbname": "ecommerce_intelligence",
    "host": "localhost",
    "port": 5432,
    "user": "kanna",
}

# These are the remaining files. The customers table is already imported.
FILES = {
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def import_csv(connection, table_name, filename):
    file_path = DATA_DIR / filename

    if not file_path.exists():
        raise FileNotFoundError(f"CSV not found: {file_path}")

    with file_path.open("r", encoding="utf-8-sig", newline="") as source:
        reader = csv.reader(source)
        columns = next(reader, None)

        if not columns:
            raise ValueError(f"No header row in {filename}")

        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT EXISTS (
                    SELECT 1
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                      AND table_name = %s
                )
                """,
                (table_name,),
            )

            if cursor.fetchone()[0]:
                print(f"SKIPPED {table_name}: table already exists.")
                return

            definitions = sql.SQL(", ").join(
                sql.SQL("{} TEXT").format(sql.Identifier(column))
                for column in columns
            )

            cursor.execute(
                sql.SQL("CREATE TABLE {} ({})").format(
                    sql.Identifier(table_name),
                    definitions,
                )
            )

            copy_query = sql.SQL(
                "COPY {} ({}) FROM STDIN WITH (FORMAT CSV, HEADER FALSE, NULL '')"
            ).format(
                sql.Identifier(table_name),
                sql.SQL(", ").join(
                    sql.Identifier(column) for column in columns
                ),
            )

            row_count = 0

            with cursor.copy(copy_query) as copy:
                # Stream rows in batches to avoid holding large files in memory.
                batch = io.StringIO()
                writer = csv.writer(batch, lineterminator="\n")

                for row in reader:
                    writer.writerow(row)
                    row_count += 1

                    if batch.tell() >= 1024 * 1024:
                        copy.write(batch.getvalue())
                        batch.seek(0)
                        batch.truncate(0)

                if batch.tell():
                    copy.write(batch.getvalue())

    print(f"IMPORTED {table_name}: {row_count:,} rows.")


def main():
    if not DATA_DIR.exists():
        raise FileNotFoundError(f"Data folder not found: {DATA_DIR}")

    with psycopg.connect(**DB_CONFIG) as connection:
        for table_name, filename in FILES.items():
            try:
                import_csv(connection, table_name, filename)
            except Exception as error:
                print(f"FAILED {table_name}: {error}")
                raise

    print("\nImport process completed.")


if __name__ == "__main__":
    main()
