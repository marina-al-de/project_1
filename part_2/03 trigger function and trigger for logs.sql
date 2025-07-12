/*
Создаём функцию для добавления логов в таблицу logs.logs_for_ds_dm в начале загрузки. 
*/

CREATE OR REPLACE FUNCTION dm.changes_in_dm()
RETURNS TRIGGER AS
$func$

DECLARE p_record_date DATE;
		p_record_account NUMERIC;

BEGIN 

	 IF TG_OP = 'INSERT' THEN
      	p_record_date := NEW.on_date;
	   p_record_account := NEW.account_rk;
    
    ELSIF TG_OP = 'DELETE' THEN
       p_record_date := OLD.on_date;
	  p_record_account := OLD.account_rk;
	END IF;
		
    INSERT INTO logs.logs_for_ds_dm (
        load_start_tstamp, 
		destination_table,                        
		user_name,
		record_date,
		record_account,
		operation
    ) VALUES (
        CURRENT_TIMESTAMP,
        TG_TABLE_NAME,
        current_user,
		p_record_date,
		p_record_account,
		TG_OP
        );

	IF TG_OP = 'INSERT' THEN
	   RETURN NEW; 
	ELSIF TG_OP = 'DELETE' THEN
		RETURN OLD; 
	END IF;
END
$func$ LANGUAGE plpgsql;

/*
Создаём триггеры на вставку и удаление записей для dm.dm_account_balance_f и dm.dm_account_turnover_f. 
*/

-- триггеры на старт расчёта

CREATE OR REPLACE TRIGGER changes_dm_account_balance
BEFORE INSERT OR DELETE ON dm.dm_account_balance_f
FOR EACH ROW
EXECUTE PROCEDURE dm.changes_in_dm();

CREATE OR REPLACE TRIGGER changes_dm_account_turnover
BEFORE INSERT OR DELETE ON dm.dm_account_turnover_f
FOR EACH ROW
EXECUTE PROCEDURE dm.changes_in_dm();

-- триггеры на окончание расчёта

CREATE OR REPLACE TRIGGER changes_dm_account_balance_end
AFTER INSERT OR DELETE ON dm.dm_account_balance_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER changes_dm_account_turnover_end
AFTER INSERT OR DELETE ON dm.dm_account_turnover_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();
