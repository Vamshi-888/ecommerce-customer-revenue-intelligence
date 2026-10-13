
import csv
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent.parent / "data"


def inspect_csv(file_path):
    print(f"\n{'=' * 60}")
    print(f"FILE: {file_path.name}")
    print("=" * 60)

    with file_path.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        columns = reader.fieldnames or []
        row_count = 0
        missing_counts = {column: 0 for column in columns}

        for row in reader:
            row_count += 1

            for column in columns:
                value = row.get(column)
                if value is None or not value.strip():
                    missing_counts[column] += 1

    print(f"Rows: {row_count:,}")
    print(f"Columns: {len(columns)}")
    print("Column names:", ", ".join(columns))

    missing = {
        column: count
        for column, count in missing_counts.items()
        if count > 0
    }

    if missing:
        print("\nBlank values:")
        for column, count in sorted(
            missing.items(),
            key=lambda item: item[1],
            reverse=True
        ):
            print(f"  {column}: {count:,}")
    else:
        print("\nNo blank values found.")


def main():
    if not DATA_DIR.exists():
        print(f"Data folder not found: {DATA_DIR}")
        return

    csv_files = sorted(DATA_DIR.glob("*.csv"))

    if not csv_files:
        print("No CSV files found.")
        return

    print(f"Found {len(csv_files)} CSV files.")

    for file_path in csv_files:
        try:
            inspect_csv(file_path)
        except Exception as error:
            print(f"Error reading {file_path.name}: {error}")


if __name__ == "__main__":
    main()
