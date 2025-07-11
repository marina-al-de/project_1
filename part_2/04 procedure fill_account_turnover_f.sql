CREATE OR REPLACE PROCEDURE ds.fill_account_turnover_f(i_OnDate DATE)

AS $$
BEGIN

	DELETE FROM dm.dm_account_turnover_f WHERE on_date = i_OnDate;

	-- извлекаем сумму по дебиту и кредиту счёта на заданную дату
	WITH postings_per_account AS(
		SELECT COALESCE(p1.oper_date, p2.oper_date) AS oper_date,
				COALESCE(credit_account_rk, debet_account_rk) AS account_rk, 
				COALESCE(credit_amount, 0) AS credit_amount, 
				COALESCE(debet_amount, 0) AS debet_amount
		FROM (
			SELECT oper_date, credit_account_rk, SUM(credit_amount) AS credit_amount
			FROM ds.ft_posting_f
			WHERE oper_date = i_OnDate
			GROUP BY 1, 2) p1 
		FULL JOIN (
			SELECT oper_date, debet_account_rk, SUM(debet_amount) AS debet_amount
			FROM ds.ft_posting_f 
			WHERE oper_date = i_OnDate
			GROUP BY 1, 2) p2
		ON p1.credit_account_rk = p2.debet_account_rk
			AND p1.oper_date = p2.oper_date
	), 

	-- извлекаем данные reduced_cource для account_rk  
	accounts_with_dates_and_ex_rate AS (
		SELECT account_rk, 
				er.reduced_cource AS er_course
		FROM ds.md_account_d acc
		INNER JOIN ds.md_currency_d curr
		ON curr.currency_rk = acc.currency_rk
		LEFT JOIN ds.md_exchange_rate_d er
		ON curr.currency_rk = er.currency_rk 	
			AND CASE 
                WHEN er.data_actual_date IS NULL THEN TRUE            
                ELSE i_OnDate BETWEEN er.data_actual_date AND er.data_actual_end_date
            END
)

	--расчитываем суммы по дебиту и кредиту в рублях и загружаем полученные данные в витрину dm.dm_account_turnover_f
	INSERT INTO dm.dm_account_turnover_f (on_date, account_rk, credit_amount, credit_amount_rub, debet_amount, debet_amount_rub)
	SELECT oper_date, 
		t1.account_rk AS account_rk, 
		credit_amount::NUMERIC(23,8), 
		(credit_amount*COALESCE(er_course,1))::NUMERIC(23,8) AS credit_amount_rub, 
		debet_amount::NUMERIC(23,8), 
		(debet_amount*COALESCE(er_course,1))::NUMERIC(23,8) AS debet_amount_rub
	FROM postings_per_account t1
	LEFT JOIN accounts_with_dates_and_ex_rate t2
	ON t1.account_rk = t2.account_rk;
			
		
END;
$$ LANGUAGE plpgsql;

-- запускаем процедуру ds.fill_account_turnover_f для всех данных из ds.ft_posting_f
DO
$$
DECLARE
	working_days_jan DATE[]; 
BEGIN

	SELECT array_agg(DISTINCT oper_date ORDER BY oper_date)::DATE[]
    INTO working_days_jan
    FROM ds.ft_posting_f;
	
	FOR i IN 1..array_length(working_days_jan, 1) 
	LOOP 
	CALL ds.fill_account_turnover_f(working_days_jan[i]);
	END LOOP;
	
END;
$$ language plpgsql;
