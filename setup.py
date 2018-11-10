import psycopg2
import base64

def create_and_insert_user_links():
  try:
    conn = psycopg2.connect("host='localhost' dbname='postgres' user='postgres'")
    cur = conn.cursor()
    cur.execute("SELECT * FROM users;")
    rows = cur.fetchall()

    for row in rows:
      user_id, tracking_type, measurement_days, users, user_link = row
      if not user_link:
        new_user_link = create_user_link(user_id, tracking_type, measurement_days, users)
        cur.execute(f"UPDATE users SET setuplink = '{new_user_link}' WHERE userid = '{user_id}';")
    conn.commit()
  except Exception as e:
    print("Can't connect to database: " + str(e))

def create_user_link(user_id, tracking_type, measurement_days, users):
  data_string = f'{{"user_id":"{user_id}", "tracking_type":"{tracking_type}", "measurement_days":"{measurement_days}", "users":"{users}"}}'

  data_bytes = data_string.encode()
  encoded_data_bytes = base64.b64encode(data_bytes)
  encoded_data_string = encoded_data_bytes.decode()

  user_link = f"sdutracker://?data={encoded_data_string}"

  return user_link

def main():
  #create_and_insert_user_links()
  print(create_user_link("kasperid", 1, 30, "[kasper, peter]"))

if __name__ == "__main__":
  main()