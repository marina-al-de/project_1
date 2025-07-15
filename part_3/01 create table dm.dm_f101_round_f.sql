
--Создаём таблицу для витрины по форме 101 (DM.DM_F101_ROUND_F).

CREATE TABLE IF NOT EXISTS DM.DM_F101_ROUND_F 
(
	from_date DATE, 
	to_date DATE, 
	chapter CHAR(1), 
	ledger_account CHAR(5),
	characteristic CHAR(1),
	balance_in_rub NUMERIC(23,8), 
	balance_in_val NUMERIC(23,8), 
	balance_in_total NUMERIC(23,8),
	turn_deb_rub NUMERIC(23,8), 
	turn_deb_val NUMERIC(23,8), 
	turn_deb_total NUMERIC(23,8),
	turn_cre_rub NUMERIC(23,8),
	turn_cre_val NUMERIC(23,8), 
	turn_cre_total NUMERIC(23,8), 
	balance_out_rub NUMERIC(23,8), 
	balance_out_val NUMERIC(23,8),
	balance_out_total NUMERIC(23,8)
);


