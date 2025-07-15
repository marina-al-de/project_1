dm_f101_round_f_v2_upsert = """MERGE INTO dm.dm_f101_round_f_v2 f
USING(VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)) 
    AS new(
            from_date, 
			to_date, 
			chapter, 
			ledger_account,
			characteristic,
			balance_in_rub, 
			balance_in_val, 
			balance_in_total,
			turn_deb_rub, 
			turn_deb_val, 
			turn_deb_total,
			turn_cre_rub,
			turn_cre_val, 
			turn_cre_total, 
			balance_out_rub, 
			balance_out_val,
			balance_out_total)
    ON f.ledger_account = new.ledger_account
        AND f.from_date = new.from_date
        AND f.to_date = new.to_date
    WHEN MATCHED THEN
        UPDATE SET chapter = new.chapter,
            characteristic = new.characteristic,
			balance_in_rub = new.balance_in_rub, 
			balance_in_val = new.balance_in_val, 
			balance_in_total = new.balance_in_total,
			turn_deb_rub = new.turn_deb_rub, 
			turn_deb_val = new.turn_deb_val, 
			turn_deb_total = new.turn_deb_total,
			turn_cre_rub = new.turn_cre_rub,
			turn_cre_val = new.turn_cre_val, 
			turn_cre_total = new.turn_cre_total, 
			balance_out_rub = new.balance_out_rub, 
			balance_out_val = new.balance_out_val,
			balance_out_total = new.balance_out_total
    WHEN NOT MATCHED THEN
        INSERT (
            from_date, 
			to_date, 
			chapter, 
			ledger_account,
			characteristic,
			balance_in_rub, 
			balance_in_val, 
			balance_in_total,
			turn_deb_rub, 
			turn_deb_val, 
			turn_deb_total,
			turn_cre_rub,
			turn_cre_val, 
			turn_cre_total, 
			balance_out_rub, 
			balance_out_val,
			balance_out_total
        ) 
        VALUES (
            new.from_date, 
			new.to_date, 
			new.chapter, 
			new.ledger_account,
			new.characteristic,
			new.balance_in_rub, 
			new.balance_in_val, 
			new.balance_in_total,
			new.turn_deb_rub, 
			new.turn_deb_val, 
			new.turn_deb_total,
			new.turn_cre_rub,
			new.turn_cre_val, 
			new.turn_cre_total, 
			new.balance_out_rub, 
			new.balance_out_val,
			new.balance_out_total
        );
"""



