import pandas as pd
from pathlib import Path 

latest_csv = max(Path('.').glob('*.csv'))



def extract_data(file_path, encoding = 'utf-8'):
    # Read the CSV file into a DataFrame
    data = pd.read_csv(file_path, encoding = encoding, sep=';')
    return data


dm_f101_round_f_v2_df = extract_data(latest_csv)
dm_f101_round_f_v2_df['from_date'] = pd.to_datetime(dm_f101_round_f_v2_df['from_date'])
dm_f101_round_f_v2_df['to_date'] = pd.to_datetime(dm_f101_round_f_v2_df['to_date'])
dm_f101_round_f_v2_df['chapter'] = dm_f101_round_f_v2_df['chapter'].astype('string')
dm_f101_round_f_v2_df['ledger_account'] = dm_f101_round_f_v2_df['ledger_account'].astype('string')
dm_f101_round_f_v2_df['characteristic'] = dm_f101_round_f_v2_df['characteristic'].astype('string')
