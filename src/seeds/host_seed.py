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

csv_file_path = './src/data_SQL/host.csv'


with open(csv_file_path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file, delimiter=';')

    next(csv_reader)  # skip header row

    for row in tqdm(csv_reader, total=5171, desc="Inserting data"):
        sql = """
            INSERT INTO host (
                id, name, description, host_url, host_total_listings_count,
                is_superhost, has_profile_pic, has_identity_verified,
                host_response_id, host_response_time, host_response_rate,
                host_acceptance_rate, host_verifications_id, host_verifications
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            )
        """
        values = (
            int(row[0]) if len(row) > 0 else None,  # id
            row[1] if len(row) > 1 else None,  # name
            row[7] if len(row) > 7 else None,  # description
            row[2] if len(row) > 2 else None,  # host_url
            int(row[3]) if len(row) > 3 and row[3] else None,  # host_total_listings_count
            row[6] == 't' if len(row) > 6 and row[6] else None,  # is_superhost
            row[4] == 't' if len(row) > 4 and row[4] else None,  # has_profile_pic
            row[5] == 't' if len(row) > 5 and row[5] else None,  # has_identity_verified
            int(row[12]) if len(row) > 12 and row[12] else None,  # host_response_id
            row[8] if len(row) > 8 else None,  # host_response_time
            float(row[9].strip('%')) / 100 if len(row) > 9 and row[9] else None,  # host_response_rate
            float(row[10].strip('%')) / 100 if len(row) > 10 and row[10] else None,  # host_acceptance_rate
            int(row[13]) if len(row) > 13 and row[13] else None,  # host_verifications_id
            row[14] if len(row) > 14 else None,  # host_verifications
        )

        cursor.execute(sql, values)
        conn.commit()

cursor.close()
conn.close()

print("Host table populated successfully.")
