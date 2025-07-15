import pandas as pd
from sqlalchemy import create_engine
import os
from datetime import datetime


# DB connection details from environment variables
user = os.environ['PGUSER']
password = os.environ['PGPASS']
server = os.environ['WINDOWS_HOST']
port = '5432'
database = 'project_1'


def download_to_csv(table_name):

    try:
        # SQLAlchemy engine
        connection_string = f"postgresql://{user}:{password}@{server}:{port}/{database}"
        engine = create_engine(connection_string)

        #timestamp for filename
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        
        # define csv_file name 
        csv_filename = f"{table_name}_{timestamp}.csv"

        # sql query with wrapper function instead of direct access to table dm.dm_f101_round_f
        # to log downloads from the table
        query = f"SELECT * FROM dm.download_f101()"
        
        # read data into DataFrame
        df = pd.read_sql_query(query, engine)
        
        # save to CSV
        df.to_csv(csv_filename, sep = ';', index=False)
        
        #close engine
        engine.dispose()
        
        print(f"Successfully downloaded {table_name} to {csv_filename}")
        return 
        
    except Exception as e:
        print(f"Data download error: {str(e)}")
        return 

table_name = "dm_f101_round_f"

download_to_csv(table_name)