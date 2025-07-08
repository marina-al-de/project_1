import psycopg2
import os
from psycopg2.extras import execute_batch
from demo_upsert_balance import * 
from demo_csv_to_df_balance import *


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

        data_tuples = [tuple(row) for row in df_list.itertuples(index=False)]
        psycopg2.extras.execute_batch(cur, sql_upserts_list,  data_tuples) 
        conn.commit()
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print("Data upload error: " + str(e))

upload(ft_balance_f_upsert, ft_balance_f_df)