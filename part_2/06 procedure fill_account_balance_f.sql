CREATE OR REPLACE PROCEDURE ds.fill_account_balance_f(i_OnDate DATE)

AS $$

DECLARE 
	previous_day DATE;

BEGIN

	-- полчуаем предыдущий рабочий день (необходим для расчёта баланса на текущий день)
	SELECT MAX(on_date) INTO previous_day FROM dm.dm_account_balance_f WHERE on_date < i_OnDate;
	
	DELETE FROM dm.dm_account_balance_f WHERE on_date = i_OnDate;

	-- вычисляем сумму движений по счёту
	WITH movements_on_account AS(
		SELECT *, on_date, act.account_rk as account_rk, 
			CASE char_type
				WHEN 'А' THEN debet_amount - credit_amount 
				WHEN 'П' THEN credit_amount - debet_amount
			END AS movement_amount,
			CASE char_type
				WHEN 'А' THEN debet_amount_rub - credit_amount_rub 
				WHEN 'П' THEN credit_amount_rub - debet_amount_rub
			END AS movement_amount_rub		
		FROM dm.dm_account_turnover_f act 
		INNER JOIN ds.md_account_d acc 
		ON acc.account_rk = act.account_rk
			AND on_date BETWEEN acc.data_actual_date AND acc.data_actual_end_date 
		WHERE on_date = i_OnDate
	)

	-- вычисляем баланс счёта на заданную дата и заполнеяем dm.dm_account_balance_f
	INSERT INTO dm.dm_account_balance_f (on_date, account_rk, balance_out, balance_out_rub)
	SELECT i_OnDate, 
			bal.account_rk , 
			COALESCE(movement_amount,0) + balance_out,  
			COALESCE(movement_amount_rub,0) + balance_out_rub
	FROM movements_on_account mov 
	FULL JOIN dm.dm_account_balance_f bal
	ON mov.account_rk = bal.account_rk
	WHERE bal.on_date = previous_day;

END;
$$ LANGUAGE plpgsql;


-- запускаем процедуру ds.fill_account_balance_f для всех данных из dm.dm_account_turnover_f
DO
$$
DECLARE
	working_days_jan DATE[]; 
BEGIN

	SELECT array_agg(DISTINCT on_date ORDER BY on_date)::DATE[]
    INTO working_days_jan
    FROM dm.dm_account_turnover_f;
	
	FOR i IN 1..array_length(working_days_jan, 1) 
	LOOP 
	CALL ds.fill_account_balance_f(working_days_jan[i]);
	END LOOP;
	
END;
$$ language plpgsql;
