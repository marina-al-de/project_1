CREATE OR REPLACE PROCEDURE dm.fill_f101_round_f(i_OnDate DATE)

AS $$

DECLARE 

	p_from_date DATE;
	p_to_date DATE;
	previous_period_end_date DATE;
	
BEGIN
	-- проверка i_OnDate является ли первым числом месяца
	IF EXTRACT(DAY FROM i_OnDate) != 1  
		THEN RAISE NOTICE 'Incorrect day, submit the first day of the month';
		RETURN;
	END IF;

	-- вычисляем даты начала и окончания текущего расчётного периода, окончание предыдущего расчётного периода 
	SELECT (i_OnDate - INTERVAL '1 DAY') INTO p_to_date;
	SELECT (i_OnDate - INTERVAL '1 MONTH') INTO p_from_date;
	SELECT (i_OnDate - INTERVAL '1 MONTH 1 DAY') INTO previous_period_end_date;

	DELETE FROM dm.dm_f101_round_f WHERE from_date = p_from_date AND to_date = p_to_date;

	-- извлекаем суммы дебитовых и кредитовых обротов в рублях для рублёвых и не рублёвых счетов и группируем по балансовым счетам второго порядка
	WITH turn_deb_cre AS (
		SELECT 
			SUM(CASE WHEN act.credit_amount_rub = act.credit_amount THEN act.credit_amount_rub ELSE 0 END) AS turn_cre_rub, 
			SUM(CASE WHEN act.credit_amount_rub != act.credit_amount THEN act.credit_amount_rub ELSE 0 END) AS turn_cre_val, 
			SUM(CASE WHEN act.debet_amount_rub = act.debet_amount THEN act.debet_amount_rub ELSE 0 END) AS turn_deb_rub,
			SUM(CASE WHEN act.debet_amount_rub != act.debet_amount THEN act.debet_amount_rub ELSE 0 END) AS turn_deb_val,
		LEFT(account_number,5)::INTEGER AS ledger_account
		FROM dm.dm_account_turnover_f act 
		INNER JOIN ds.md_account_d acc 
		ON acc.account_rk = act.account_rk
		GROUP BY 5
	),

	-- извлекаем суммы остатков за первый и последний день расчётного периода в рублях для рублёвых и не рублёвых счетов 
	-- и группируем по балансовым счетам второго порядка
	bal_in_out AS(
		SELECT 
			SUM(CASE WHEN bal1.balance_out_rub = bal1.balance_out THEN bal1.balance_out_rub ELSE 0 END) AS balance_in_rub, 
			SUM(CASE WHEN bal1.balance_out_rub != bal1.balance_out THEN bal1.balance_out_rub ELSE 0 END) AS balance_in_val, 
			SUM(CASE WHEN bal2.balance_out_rub = bal2.balance_out THEN bal2.balance_out_rub ELSE 0 END) AS balance_out_rub,
			SUM(CASE WHEN bal2.balance_out_rub != bal2.balance_out THEN bal2.balance_out_rub ELSE 0 END) AS balance_out_val,
		LEFT(account_number,5)::INTEGER AS ledger_account
		FROM dm.dm_account_balance_f bal1
		FULL JOIN (SELECT * FROM dm.dm_account_balance_f bal1) bal2
		ON bal1.account_rk = bal2.account_rk
		FULL JOIN ds.md_account_d acc 
		ON bal1.account_rk = acc.account_rk
		WHERE bal1.on_date = previous_period_end_date
			AND bal2.on_date = (SELECT MAX(on_date) FROM dm.dm_account_balance_f bal1)
		GROUP BY 5
	)

	-- объединяем остатки и обороты по счетам со справочной информацией из ds.md_ledger_account_s и загружаем полученные данные в витрину dm.dm_f101_round_f
	INSERT INTO dm.dm_f101_round_f (
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
	SELECT 
			p_from_date,
			p_to_date,
			chapter, 
			b.ledger_account::CHAR(5), 
			characteristic,
			balance_in_rub, 
			balance_in_val, 
			balance_in_rub + balance_in_val,
			COALESCE(turn_deb_rub, 0),
			COALESCE(turn_deb_val, 0),
			COALESCE(turn_deb_rub + turn_deb_val, 0),
			COALESCE(turn_cre_rub,0),
			COALESCE(turn_cre_val,0), 
			COALESCE(turn_cre_val + turn_cre_rub, 0), 
			balance_out_rub, 
			balance_out_val,
			(balance_out_val + balance_out_rub)
	FROM bal_in_out b
	LEFT JOIN turn_deb_cre t
	ON t.ledger_account = b.ledger_account 
	INNER JOIN ds.md_ledger_account_s la
	ON b.ledger_account = la.ledger_account;
	
END;
$$ LANGUAGE plpgsql;

CALL dm.fill_f101_round_f('2018-02-01');
