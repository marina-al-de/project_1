DO
$$

BEGIN

	-- извлекаем данные reduced_cource на дату 31.12.2017
	WITH currency_and_ex_rate_end_december AS (
		SELECT  curr.currency_rk AS currency_rk, 
				er.reduced_cource AS er_course
		FROM ds.md_currency_d curr
		LEFT JOIN ds.md_exchange_rate_d er
		ON curr.currency_rk = er.currency_rk 	
			AND CASE 
                WHEN er.data_actual_date IS NULL THEN TRUE            
                ELSE '2017-12-31' BETWEEN er.data_actual_date AND er.data_actual_end_date
            END
		
	)

	--расчитываем баланс в рублях и загружаем полученные данные в витрину dm.dm_account_balance_f
	INSERT INTO dm.dm_account_balance_f (on_date, account_rk, balance_out, balance_out_rub)
	SELECT on_date, 
			account_rk, 
			balance_out::NUMERIC(23,8), 
			(balance_out*COALESCE(er_course,1))::NUMERIC(23,8) AS balance_out_rub
	FROM ds.ft_balance_f bal 
	LEFT JOIN currency_and_ex_rate_end_december curr 
	ON bal.currency_rk = curr.currency_rk;

END;
$$ language plpgsql;