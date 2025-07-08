import psycopg2
import os
from psycopg2.extras import execute_batch
from upserts import * 
from csv_to_df import *


#db connection details from environmnet var
user = os.environ['PGUSER']
password = os.environ['PGPASS']
server = os.environ['WINDOWS_HOST']
port ='5432'
database ='project_1'


def upload(sql_upserts_list, df_list):
    try:
        conn = psycopg2.connect(
            user = user,
            password =password,
            host = server,
            port = port,
            database = database
        )

        cur = conn.cursor()

        for i in range(len(df_list)):
            data_tuples = [tuple(row) for row in df_list[i].itertuples(index=False)]
            psycopg2.extras.execute_batch(cur, sql_upserts_list[i], data_tuples) 
            conn.commit()
        cur.close()
        conn.close()
        
    except Exception as e:
        print("Data upload error: " + str(e))

upload(sql_upserts_list, df_list)
