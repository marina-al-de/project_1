import psycopg2
import os
from psycopg2.extras import execute_batch
from csv_to_df_f101_v2 import * 
from upsert_f101_v2 import *


#db connection details from environmnet var
user = os.environ['PGUSER']
password = os.environ['PGPASS']
server = os.environ['WINDOWS_HOST']
port ='5432'
database ='project_1'


def upload(sql_upsert, df):
    try:
        conn = psycopg2.connect(
            user = user,
            password =password,
            host = server,
            port = port,
            database = database
        )

        cur = conn.cursor()

        data_tuples = [tuple(row) for row in df.itertuples(index=False)]
        psycopg2.extras.execute_batch(cur, sql_upsert,  data_tuples) 
        conn.commit()
        
        cur.close()
        conn.close()
        
        print("Successful upload")

        return
    
    except Exception as e:
        print("Data upload error: " + str(e))
        return

upload(dm_f101_round_f_v2_upsert, dm_f101_round_f_v2_df)