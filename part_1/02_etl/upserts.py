ft_balance_f_upsert = """MERGE INTO ds.ft_balance_f bal
USING(VALUES (%s, %s, %s, %s)) AS new(on_date, account_rk, currency_rk, balance_out)
    ON bal.on_date = new.on_date
        AND bal.account_rk = new.account_rk
    WHEN MATCHED THEN
        UPDATE SET balance_out = new.balance_out
    WHEN NOT MATCHED THEN
        INSERT (on_date, account_rk, currency_rk, balance_out) 
        VALUES (new.on_date, new.account_rk, new.currency_rk, new.balance_out);
"""

"""
У таблицы ft_posting_f нет первичного ключа. Можно считать, что мы всегда в нее будем загружать полный набор данных, перед
каждой загрузкой ее необходимо очищать. Поэтому для неё простой insert staement.
"""

ft_posting_f_insert = """INSERT INTO ds.ft_posting_f (oper_date, credit_account_rk, debet_account_rk, credit_amount, debet_amount)
VALUES (%s, %s, %s, %s, %s);
"""

md_account_d_upsert = """MERGE INTO ds.md_account_d acc
USING(VALUES (%s, %s, %s, %s, %s, %s, %s)) AS new(data_actual_date, data_actual_end_date, account_rk, account_number, char_type, currency_rk , currency_code)
    ON acc.data_actual_date = new.data_actual_date
        AND acc.account_rk = new.account_rk
    WHEN MATCHED THEN
        UPDATE SET data_actual_end_date = new.data_actual_end_date,
            account_number = new.account_number, 
            char_type = new.char_type, 
            currency_rk = new.currency_rk, 
            currency_code = new.currency_code
    WHEN NOT MATCHED THEN
        INSERT (data_actual_date, data_actual_end_date, account_rk, account_number, char_type, currency_rk, currency_code)
        VALUES (new.data_actual_date, new.data_actual_end_date, new.account_rk, new.account_number, new.char_type, new.currency_rk , new.currency_code);
"""

md_currency_d_upsert = """MERGE INTO ds.md_currency_d cur
USING(VALUES (%s, %s, %s, %s, %s)) AS  new(currency_rk, data_actual_date, data_actual_end_date, currency_code, code_iso_char)
    ON cur.currency_rk = new.currency_rk 
        AND cur.data_actual_date = new.data_actual_date
    WHEN MATCHED THEN
        UPDATE SET data_actual_end_date = new.data_actual_end_date,
            currency_code = CASE 
                WHEN new.currency_code IS NOT NULL 
                    THEN LEFT(CAST(new.currency_code AS varchar), CAST(POSITION('.' IN CAST(new.currency_code AS varchar)) AS INT) - 1)
            END,
            code_iso_char = new.code_iso_char
    WHEN NOT MATCHED THEN
        INSERT (currency_rk, data_actual_date, data_actual_end_date, currency_code, code_iso_char)
        VALUES (new.currency_rk, new.data_actual_date, new.data_actual_end_date,
            CASE 
                WHEN new.currency_code IS NOT NULL 
                    THEN LEFT(CAST(new.currency_code AS varchar), CAST(POSITION('.' IN CAST(new.currency_code AS varchar)) AS INT) - 1)
            END,
        new.code_iso_char);
"""

md_exchange_rate_d_upsert = """MERGE INTO ds.md_exchange_rate_d er
USING(VALUES (%s, %s, %s, %s, %s)) AS new(data_actual_date, data_actual_end_date, currency_rk, reduced_cource, code_iso_num)
    ON er.data_actual_date = new.data_actual_date
        AND er.currency_rk = new.currency_rk
    WHEN MATCHED THEN
        UPDATE SET data_actual_end_date = new.data_actual_end_date,
            reduced_cource = new.reduced_cource, 
            code_iso_num = new.code_iso_num
    WHEN NOT MATCHED THEN
        INSERT (data_actual_date, data_actual_end_date, currency_rk, reduced_cource, code_iso_num)
        VALUES (new.data_actual_date, new.data_actual_end_date, new.currency_rk, new.reduced_cource, new.code_iso_num);
"""

md_ledger_accountd_s_upsert = """MERGE INTO ds.md_ledger_account_s la
USING(VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)) AS new( 
        chapter, 
        chapter_name, 
        section_number, 
        section_name,
        subsection_name, 
        ledger1_account, 
        ledger1_account_name, 
        ledger_account, 
        ledger_account_name, 
        characteristic, 
        start_date, 
        end_date)
    ON la.ledger_account = new.ledger_account
        AND la.start_date = new.start_date
    WHEN MATCHED THEN
        UPDATE SET chapter = new.chapter, 
            chapter_name = new.chapter_name, 
            section_number = new.section_number, 
            section_name = new.section_name, 
            subsection_name = new.subsection_name,
            ledger1_account = new.ledger1_account, 
            ledger1_account_name = new.ledger1_account_name, 
            ledger_account_name = new.ledger_account_name, 
            characteristic = new.characteristic, 
            end_date = new.end_date
    WHEN NOT MATCHED THEN
        INSERT ( 
            chapter, 
            chapter_name, 
            section_number, 
            section_name, 
            subsection_name,
            ledger1_account, 
            ledger1_account_name, 
            ledger_account, 
            ledger_account_name, 
            characteristic, 
            start_date, 
            end_date)
                VALUES (
            new.chapter, 
            new.chapter_name, 
            new.section_number, 
            new.section_name, 
            new.subsection_name,
            new.ledger1_account, 
            new.ledger1_account_name, 
            new.ledger_account, 
            new.ledger_account_name, 
            new.characteristic, 
            new.start_date, 
            new.end_date);
"""
sql_upserts_list = [ft_balance_f_upsert, ft_posting_f_insert, md_account_d_upsert, md_currency_d_upsert, \
    md_exchange_rate_d_upsert, md_ledger_accountd_s_upsert]

