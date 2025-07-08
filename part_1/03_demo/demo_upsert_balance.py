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



