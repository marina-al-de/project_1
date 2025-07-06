ft_balance_f_upsert = """INSERT INTO ds.ft_balance_f (on_date, account_rk, currency_rk , balance_out)
VALUES (%s, %s, %s, %s)
ON CONFLICT (on_date, account_rk) DO UPDATE SET
balance_out = EXCLUDED.balance_out;
"""

"""
У таблицы ft_posting_f нет первичного ключа. Можно считать, что мы всегда в нее будем загружать полный набор данных, перед
каждой загрузкой ее необходимо очищать. Поэтому не включаем в insert statement on conflict ... do update.
"""

ft_posting_f_insert = """INSERT INTO ft_posting_f (oper_date, credit_account_rk, debet_account_rk, credit_amount, debet_amount)
VALUES (%s, %s, %s, %s, %s);
"""

md_account_d_upsert = """INSERT INTO md_account_d (data_actual_date, data_actual_end_date, account_rk, account_number, char_type, currency_rk , curency_code)
VALUES (%s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (data_actual_date, account_rk) DO UPDATE SET
data_actual_end_date = EXCLUDED.data_actual_end_date,
account_number = EXCLUDED.account_number, 
char_type = EXCLUDED.char_type,
currency_rk = EXCLUDED.currency_rk;
"""

md_currency_d_upsert = """INSERT INTO md_currency_d (currency_rk, data_actual_date, data_actual_end_date, currency_code, code_iso_char)
VALUES (%s, %s, %s, %s, %s)
ON CONFLICT (currency_rk, data_actual_date) DO UPDATE SET
data_actual_end_date = EXCLUDED.data_actual_end_date,
currency_code = EXCLUDED.currency_code,
code_iso_char = EXCLUDED.code_iso_char;
"""

md_exhacnge_rate_d_upsert = """INSERT INTO md_exhacnge_rate_d ( data_actual_date, data_actual_end_date, currency_rk, reduced_course, code_iso_num)
VALUES (%s, %s, %s, %s, %s)
ON CONFLICT (data_actual_date, currency_rk) DO UPDATE SET
data_actual_end_date = EXCLUDED.data_actual_end_date,
reduced_course = EXCLUDED.reduced_course, 
code_iso_num = EXCLUDED.code_iso_num;
"""

md_ledger_accountd_s_upsert = """INSERT INTO md_ledger_accountd_s ( 
    chapter, 
    chapter_name, 
    section_number, 
    section_name, 
    ledger1_account, 
    ledger1_account_name, 
    ledger_account, 
    ledger_account_name, 
    charactreristic, 
    start_date, 
    end_date)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (ledger_account, start_date) DO UPDATE SET
chapter = EXCLUDED.chapter, 
chapter_name = EXCLUDED.chapter_name, 
section_number = EXCLUDED.section_number, 
section_name = EXCLUDED.section_name, 
ledger1_account = EXCLUDED.ledger1_account, 
ledger1_account_name = EXCLUDED.ledger1_account_name, 
ledger_account_name = EXCLUDED.ledger_account_name, 
charactreristic = EXCLUDED.charactreristic, 
end_date = EXCLUDED.end_date;
"""
sql_upserts_list = [ft_balance_f_upsert, ft_posting_f_insert, md_account_d_upsert, md_currency_d_upsert, \
    md_exhacnge_rate_d_upsert, md_ledger_accountd_s_upsert]

