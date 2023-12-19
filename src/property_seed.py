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

csv_file_path = './src/data_SQL/property.csv'


with open(csv_file_path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file, delimiter=';')

    next(csv_reader)  # skip header row

    for row in tqdm(csv_reader, total=12817, desc="Inserting data"):
        sql = """
            INSERT INTO property (
                accommodates, bedrooms, beds, amenities,
                room_type, property_type, bathrooms
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s
            )
        """
        values = (
            int(row[0]) if len(row) > 0 else None,  # accommodates
            int(float(row[1])) if len(row) > 1 and row[1] != '' else None,  # bedrooms
            int(float(row[2])) if len(row) > 2 and row[2] != '' else None,  # beds
            row[3] if len(row) > 3 else None,  # amenities
            row[4]if len(row) > 4 else None,  # room_type
            row[5] if len(row) > 5 else None,  # property_type
            row[6] if len(row) > 6 else None   # bathrooms
        )

        cursor.execute(sql, values)
        conn.commit()

cursor.close()
conn.close()

print("Property table populated successfully.")
