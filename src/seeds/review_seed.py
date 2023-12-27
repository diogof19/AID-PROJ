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

csv_file_path = './src/data_SQL/review.csv'

with open(csv_file_path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file, delimiter=';')
    next(csv_reader)  # skip header row
    
    for row in tqdm(csv_reader, total=744713, desc="Inserting data"):
        sql = """INSERT INTO review ( 
          reviewer_id,
          review,
          date_id,
          listing_id,
          host_id,
          property_id
        ) VALUES (
          %s, %s, %s, %s, %s, %s
        )"""
        values = (
            int(row[0]) if len(row) > 0 else None,  # id
            row[1] if len(row) > 1 else None,  # review
            int(row[2]) if len(row) > 2 else None,  # date_id
            int(row[3]) if len(row) > 3 else None,  # listing_id
            int(row[4]) if len(row) > 4 else None,  # host_id
            int(row[5]) if len(row) > 5 else None,  # property_id
        )

        try:
          cursor.execute(sql, values)
          conn.commit()
        except:
            print("Error inserting row: ", row)
            continue


cursor.close()
conn.close()

print("Review table populated successfully.")
