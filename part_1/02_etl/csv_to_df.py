import pandas as pd


def extract_data(file_path, encoding = 'utf-8'):
    # Read the CSV file into a DataFrame
    data = pd.read_csv(file_path, encoding = encoding, sep=';')
    return data


ft_balance_f_df = extract_data('~/learning/neo_25/csv_files/ft_balance_f.csv')
ft_balance_f_df['ON_DATE'] = pd.to_datetime(ft_balance_f_df['ON_DATE'], format='%d.%m.%Y')


ft_posting_f_df = extract_data('~/learning/neo_25/csv_files/ft_posting_f.csv')
ft_posting_f_df['OPER_DATE'] = pd.to_datetime(ft_posting_f_df['OPER_DATE'], format='%d-%m-%Y')


md_account_d_df = extract_data('~/learning/neo_25/csv_files/md_account_d.csv')
md_account_d_df['DATA_ACTUAL_DATE'] = pd.to_datetime(md_account_d_df['DATA_ACTUAL_DATE'], format='%Y-%m-%d')
md_account_d_df['DATA_ACTUAL_END_DATE'] = pd.to_datetime(md_account_d_df['DATA_ACTUAL_END_DATE'], format='%Y-%m-%d')


md_currency_d_df = extract_data('~/learning/neo_25/csv_files/md_currency_d.csv', 'cp1252')
md_currency_d_df['DATA_ACTUAL_DATE'] = pd.to_datetime(md_currency_d_df['DATA_ACTUAL_DATE'], format='%Y-%m-%d')
md_currency_d_df['DATA_ACTUAL_END_DATE'] = pd.to_datetime(md_currency_d_df['DATA_ACTUAL_END_DATE'], format='%Y-%m-%d')
md_currency_d_df['CURRENCY_CODE'] = md_currency_d_df['CURRENCY_CODE'].astype(object)
md_currency_d_df = md_currency_d_df.where(pd.notnull(md_currency_d_df), None)
md_currency_d_df = md_currency_d_df.replace({'CODE_ISO_CHAR':'˜'}, {'CODE_ISO_CHAR':None})


md_exchange_rate_d_df = extract_data('~/learning/neo_25/csv_files/md_exchange_rate_d.csv')
md_exchange_rate_d_df['DATA_ACTUAL_DATE'] = pd.to_datetime(md_exchange_rate_d_df['DATA_ACTUAL_DATE'], format='%Y-%m-%d')
md_exchange_rate_d_df['DATA_ACTUAL_END_DATE'] = pd.to_datetime(md_exchange_rate_d_df['DATA_ACTUAL_END_DATE'], format='%Y-%m-%d')


md_ledger_account_s_df = extract_data('~/learning/neo_25/csv_files/md_ledger_account_s.csv')
md_ledger_account_s_df['START_DATE'] = pd.to_datetime(md_ledger_account_s_df['START_DATE'], format='%Y-%m-%d')
md_ledger_account_s_df['END_DATE'] = pd.to_datetime(md_ledger_account_s_df['END_DATE'], format='%Y-%m-%d')

df_list = [ft_balance_f_df, ft_posting_f_df, md_account_d_df, md_currency_d_df, md_exchange_rate_d_df, md_ledger_account_s_df]

