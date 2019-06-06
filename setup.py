# Requirements:
  # Python >= 3.6.
  # mysql-connector library (fx by running 'pip3 install mysql-connector')

import mysql.connector
import base64

def create_and_insert_user_links():
  try:

    # Connection. I assume root is being used.
    conn = mysql.connector.connect(host='db4.sdu.dk', 
                                   database='screens_db',
                                   user='root')
    cur = conn.cursor()
    cur.execute("SELECT * FROM users;")

    rows = cur.fetchall()

    # Create and insert user links based on the other fields.
    for row in rows:
      user_id, tracking_type, measurement_days, users, _ = row
      new_user_link = create_user_link(user_id, tracking_type, measurement_days, users)
      cur.execute(f"UPDATE users SET setup_link = '{new_user_link}' WHERE user_id = '{user_id}';")

    conn.commit()

  except Exception as e:
    print("Can't connect to database: " + str(e))


def create_user_link(user_id, tracking_type, measurement_days, users):
  # Encode as JSON
  data_string = f'{{"user_id":"{user_id}", "tracking_type":"{tracking_type}", \
    "measurement_days":"{measurement_days}", "users":"{users}"}}'

  # Convert to Base64
  data_bytes = data_string.encode()
  encoded_data_bytes = base64.b64encode(data_bytes)
  encoded_data_string = encoded_data_bytes.decode()

  # Create URL
  user_link = f"sdutracker://?data={encoded_data_string}"

  return user_link

def main():
  create_and_insert_user_links()

if __name__ == "__main__":
  main()