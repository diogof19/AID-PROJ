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

csv_file_path = './src/data_SQL/reviewer.csv'

with open(csv_file_path, 'r', encoding='utf-8') as file:
    csv_reader = csv.reader(file, delimiter=';')

    next(csv_reader)  # skip header row

    # totalRows = int(len(list(csv_reader))) na verdade aqui é mais 1
    # print(totalRows)

    for row in tqdm(csv_reader, total=698170, desc="Inserting data"):
        sql = """
            INSERT INTO reviewer (id, name) VALUES (%s, %s)
        """
        values = (
            int(row[0]) if len(row) > 0 else None,  # id
            row[1] if len(row) > 1 else None,  # name
        )

        cursor.execute(sql, values)
        conn.commit()

cursor.close()
conn.close()

print("Reviewer table populated successfully.")
