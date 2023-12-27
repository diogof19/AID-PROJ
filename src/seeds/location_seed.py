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

csv_file_path = './src/data_SQL/location.csv'

with open(csv_file_path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file, delimiter=';')
    next(csv_reader)  # skip header row

    for row in tqdm(csv_reader, total=12321, desc="Inserting data"):
        sql = """INSERT INTO location (
          latitude,
          longitude,
          neighbourhood_id
        ) VALUES (
          %s, %s, %s
        )"""
        values = (
            float(row[0]) if len(row) > 0 else None,  # latitude
            float(row[1]) if len(row) > 1 else None,  # longitude
            int(row[2]) if len(row) > 2 else None,  # neighbourhood_id
        )

        cursor.execute(sql, values)
        conn.commit()

cursor.close()
conn.close()

print("Location table populated successfully.")
