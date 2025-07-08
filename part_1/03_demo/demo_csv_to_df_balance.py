import pandas as pd


def extract_data(file_path, encoding = 'utf-8'):
    # Read the CSV file into a DataFrame
    data = pd.read_csv(file_path, encoding = encoding, sep=';')
    return data


ft_balance_f_df = extract_data('~/learning/neo_25/csv_files/ft_balance_f.csv')
ft_balance_f_df['ON_DATE'] = pd.to_datetime(ft_balance_f_df['ON_DATE'], format='%d.%m.%Y')

