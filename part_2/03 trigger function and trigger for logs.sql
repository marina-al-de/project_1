/*
Обновим функцию ds.update_logs_start(), чтобы использовать её для витрин 'dm_account_balance_f','dm_acount_turnover_f', 'dm_f101_round_f', 'dm_f101_round_f_v2' из слоя DM.
*/

CREATE OR REPLACE FUNCTION ds.update_logs_start()
RETURNS TRIGGER AS
$func$
	
DECLARE pk_date DATE;
		pk_second_part NUMERIC;
		diff_found BOOLEAN := FALSE;
BEGIN 

	-- поменяем блок для присваивания значений переменным pk_date и pk_second_part с учётом операции DELETE и витрин из слоя DM.
	
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN  
	
		IF TG_TABLE_NAME = 'ft_balance_f' THEN
			pk_date := NEW.on_date;
        	pk_second_part := NEW.account_rk;

    	ELSIF TG_TABLE_NAME = 'md_account_d' THEN
        	pk_date := NEW.data_actual_date;
       		pk_second_part := NEW.account_rk;

		ELSIF TG_TABLE_NAME = 'md_currency_d' THEN
        	pk_date := NEW.data_actual_date;
        	pk_second_part := NEW.currency_rk;

    	ELSIF TG_TABLE_NAME = 'md_exchange_rate_d' THEN
        	pk_date := NEW.data_actual_date;
        	pk_second_part := NEW.currency_rk;

    	ELSIF TG_TABLE_NAME = 'md_ledger_account_s' THEN
        	pk_date := NEW.start_date;
        	pk_second_part := CAST(NEW.ledger_account AS NUMERIC);
			
		ELSIF TG_TABLE_NAME IN ('dm_account_balance_f','dm_account_turnover_f') THEN
			pk_date := NEW.on_date;
        	pk_second_part := NEW.account_rk;
			
		ELSIF TG_TABLE_NAME IN ('dm_f101_round_f', 'dm_f101_round_f_v2') THEN
			pk_date := NEW.from_date;
        	pk_second_part := CAST(NEW.ledger_account AS NUMERIC);
    	
		ELSE
        	pk_date := NULL;
        	pk_second_part := NULL;
		END IF;

	ELSIF TG_OP = 'DELETE' THEN
	
		IF TG_TABLE_NAME IN ('dm_account_balance_f','dm_account_turnover_f') THEN
			pk_date := OLD.on_date;
        	pk_second_part := OLD.account_rk;

		ELSIF TG_TABLE_NAME = 'dm_f101_round_f' THEN
			pk_date := OLD.from_date;
        	pk_second_part := CAST(OLD.ledger_account AS NUMERIC);
			
		ELSE
        	pk_date := NULL;
        	pk_second_part := NULL;
		END IF;
			
	END IF;

	-- поменяем блок для присваивания значений переменной diff_found с учётом операции DELETE.
	
	IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
	   diff_found := TRUE;
	ELSIF TG_OP = 'UPDATE' THEN
	   IF (ROW(OLD.*) IS DISTINCT FROM ROW(NEW.*)) THEN
	   		diff_found := TRUE;
		ELSE
			diff_found := FALSE;
		END IF;
	END IF;

	IF diff_found THEN 
    INSERT INTO  logs.logs_for_ds_dm (
        load_start_tstamp,
        destination_table,
        user_name,  
		pk_date, 
		pk_second_part,  
		operation
    ) VALUES (
        CURRENT_TIMESTAMP,
        TG_TABLE_NAME,
        current_user,
		pk_date, 
		pk_second_part, 
		TG_OP
        );
	END IF;
	
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
	   RETURN NEW; 
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD; 
	END IF;
END
$func$ LANGUAGE plpgsql;

/*
Обновление функции ds.update_logs_end() в блоке WHERE.
*/

CREATE OR REPLACE FUNCTION ds.update_logs_end() 
	RETURNS TRIGGER AS

$func$

BEGIN 

	UPDATE logs.logs_for_ds_dm
		SET load_end_tstamp = (CURRENT_TIMESTAMP + interval '5 second')
		WHERE log_id = (
			SELECT MAX(log_id) 
			FROM logs.logs_for_ds_dm 
			WHERE destination_table = TG_TABLE_NAME 
				AND load_end_tstamp IS NULL
		);
	
RETURN NULL;

END
$func$  LANGUAGE plpgsql;

/*
Создаём триггеры на вставку и удаление записей для dm.dm_account_balance_f и dm.dm_account_turnover_f. 
*/

-- триггеры на старт расчёта

-- триггеры на старт расчёта

CREATE OR REPLACE TRIGGER changes_dm_account_balance
BEFORE INSERT OR DELETE ON dm.dm_account_balance_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER changes_dm_account_turnover
BEFORE INSERT OR DELETE ON dm.dm_account_turnover_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

-- триггеры на окончание расчёта

-- триггеры на окончание расчёта
CREATE OR REPLACE TRIGGER changes_dm_account_balance_end
AFTER INSERT OR DELETE ON dm.dm_account_balance_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER changes_dm_account_turnover_end
AFTER INSERT OR DELETE ON dm.dm_account_turnover_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();


