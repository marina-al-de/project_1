CREATE OR REPLACE PROCEDURE ds.fill_account_balance_f(i_OnDate DATE)

AS $$

DECLARE 
	previous_day DATE;
	working_days_jan DATE[]; 

BEGIN

	-- находим предыдущий день
	SELECT i_OnDate - 1 INTO previous_day;

	-- находим даты, когда были движения по счетам
	SELECT array_agg(DISTINCT on_date ORDER BY on_date)::DATE[]
    INTO working_days_jan
    FROM dm.dm_account_turnover_f;

	-- удаляем данные из витрины на заданную дату
	DELETE FROM dm.dm_account_balance_f WHERE on_date = i_OnDate;

	-- если были движения по счетам на заданную дату, то вычисляем баланс	
	IF i_OnDate = ANY(working_days_jan) THEN 
	
		-- вычисляем сумму движений по счёту на заданную дату
		WITH movements_on_account AS(
			SELECT act.account_rk AS account_rk, 
				CASE acc.char_type
					WHEN 'А' THEN act.debet_amount - act.credit_amount 
					WHEN 'П' THEN act.credit_amount - act.debet_amount
				END AS movement_amount,
				CASE acc.char_type
					WHEN 'А' THEN act.debet_amount_rub - act.credit_amount_rub 
					WHEN 'П' THEN act.credit_amount_rub - act.debet_amount_rub
				END AS movement_amount_rub		
			FROM dm.dm_account_turnover_f act 
			INNER JOIN ds.md_account_d acc 
			ON acc.account_rk = act.account_rk
				AND act.on_date BETWEEN acc.data_actual_date AND acc.data_actual_end_date 
			WHERE act.on_date = i_OnDate
			)

		-- вычисляем баланс счёта на заданную дату и заполнеяем dm.dm_account_balance_f
		INSERT INTO dm.dm_account_balance_f (on_date, account_rk, balance_out, balance_out_rub)
		SELECT i_OnDate, 
			bal.account_rk, 
			COALESCE(mov.movement_amount,0) + bal.balance_out,  
			COALESCE(mov.movement_amount_rub,0) + bal.balance_out_rub
		FROM movements_on_account mov 
		FULL JOIN dm.dm_account_balance_f bal
		ON mov.account_rk = bal.account_rk
		WHERE bal.on_date = previous_day;


	-- если движений по счётам на заданную дату не было, копируем балансы предыдущего дня
	ELSE
		
		INSERT INTO dm.dm_account_balance_f (on_date, account_rk, balance_out, balance_out_rub)
		SELECT i_OnDate, account_rk, balance_out, balance_out_rub
		FROM dm.dm_account_balance_f 
		WHERE on_date = previous_day;

	END IF;

END;
$$ LANGUAGE plpgsql;


-- запускаем процедуру ds.fill_account_balance_f для каждого дня в январе 2018 года
DO
$$
DECLARE

	january_date DATE;
	
BEGIN

    FOR january_date IN 
        SELECT generate_series('2018-01-01'::DATE, '2018-01-31'::DATE, '1 day')::DATE
    LOOP 
        CALL ds.fill_account_balance_f(january_date);
    END LOOP;
	
END;
$$ language plpgsql;
