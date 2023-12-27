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

csv_file_path = './src/data_SQL/date.csv'

with open(csv_file_path, 'r') as file:
    csv_reader = csv.reader(file, delimiter=';')
    next(csv_reader)  # skip header row

    for row in tqdm(csv_reader, total=4245, desc="Inserting data"):
        sql = "INSERT INTO date (sqlDate, day_id, month_id, year_id, day_number, month_number, month_name, year_number) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
        values = (
            row[0],
            int(row[1]),
            int(row[2]),
            int(row[3]),
            int(row[4]),
            int(row[5]),
            row[6],
            int(row[7])
        )

        cursor.execute(sql, values)
        conn.commit()

cursor.close()
conn.close()

print("Date table populated successfully.")
