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

csv_file_path = './src/data_SQL/listing.csv'

with open(csv_file_path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file, delimiter=';')
    next(csv_reader)  # skip header row

    for row in tqdm(csv_reader, total=12321, desc="Inserting data"):
        sql = """INSERT INTO listing ( 
          id,
          host_id,
          price,
          description,
          availability_30,
          availability_60,
          availability_90,
          availability_365,
          review_scores_rating,
          review_scores_accuracy,
          review_scores_cleanliness,
          review_scores_checkin,
          review_scores_communication,
          review_scores_location,
          review_scores_value,
          reviews_per_month,
          location_id,
          property_id
        ) VALUES (
          %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )"""
        values = (
            int(row[0]) if len(row) > 0 else None,  # listing_id
            int(row[1]) if len(row) > 1 else None,  # host_id
            float(row[2].replace("$", "").replace(",", "")) if len(row) > 2 else None,  # price - $100.00
            row[3] if len(row) > 3 else None,  # description
            int(row[4]) if len(row) > 4 and row[4] != '' else None,  # availability_30
            int(row[5]) if len(row) > 5 and row[5] != '' else None,  # availability_60
            int(row[6]) if len(row) > 6 and row[6] != '' else None,  # availability_90
            int(row[7]) if len(row) > 7 and row[7] != '' else None,  # availability_365 
            float(row[8]) if len(row) > 8 and row[8] != '' else None, # review_scores_rating
            float(row[9]) if len(row) > 9 and row[9] != '' else None, # review_scores_accuracy
            float(row[10]) if len(row) > 10 and row[10] != '' else None, # review_scores_cleanliness
            float(row[11]) if len(row) > 11 and row[11] != '' else None, # review_scores_checkin
            float(row[12]) if len(row) > 12 and row[12] != '' else None, # review_scores_communication
            float(row[13]) if len(row) > 13 and row[13] != '' else None, # review_scores_location
            float(row[14]) if len(row) > 14 and row[14] != '' else None, # review_scores_value
            float(row[15]) if len(row) > 15 and row[15] != '' else None, # reviews_per_month
            int(row[16]) if len(row) > 16 else None, # location_id
            int(row[17]) if len(row) > 17 else None # property_id
        )

        cursor.execute(sql, values)
        conn.commit()


cursor.close()
conn.close()

print("Listing table populated successfully.")
