import mysql.connector
import csv
from tqdm import tqdm

conn = mysql.connector.connect(
  host="localhost",
  user="root",
  password="password",
  database="airbnb"
)

cursor = conn.cursor()

csv_file_path = './src/data_SQL/city.csv'

with open(csv_file_path, 'r') as file:
    csv_reader = csv.reader(file, delimiter=';')
    next(csv_reader)  # skip header row

    for row in tqdm(csv_reader, total=17, desc="Inserting data"):
        sql = """INSERT INTO city (
          city,
          state_id
        ) VALUES (
          %s, %s
        )"""
        values = (
            row[0] if len(row) > 0 else None,  # city
            int(row[1]) if len(row) > 1 else None,  # state_id
        )

        cursor.execute(sql, values)
        conn.commit()

cursor.close()
conn.close()

print("City table populated successfully.")
