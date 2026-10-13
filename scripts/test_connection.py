
import psycopg


def main():
    try:
        with psycopg.connect(
            dbname="ecommerce_intelligence",
            host="localhost",
            port=5432,
            user="kanna",
        ) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT current_database(), version();")
                database_name, version = cursor.fetchone()

                print("Connection successful!")
                print(f"Database: {database_name}")
                print(f"Version: {version.split(',')[0]}")

    except Exception as error:
        print(f"Connection failed: {error}")


if __name__ == "__main__":
    main()
