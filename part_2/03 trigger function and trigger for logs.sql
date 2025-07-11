/*
Создаём функцию для добавления логов в таблицу logs.changes_in_dm в начале загрузки. 
*/

CREATE OR REPLACE FUNCTION dm.changes_in_dm()
RETURNS TRIGGER AS
$func$

DECLARE on_date DATE;
	account_rk NUMERIC;

BEGIN 

	 IF TG_OP = 'INSERT' THEN
       on_date := NEW.on_date;
	   account_rk := NEW.account_rk;
    
    ELSIF TG_OP = 'DELETE' THEN
       on_date := OLD.on_date;
	   account_rk := OLD.account_rk;
	END IF;
		
    INSERT INTO logs.changes_in_dm (
        change_tstamp, 
		dm_changed,                        
		user_name,
		on_date,
		account_rk,
		operation
    ) VALUES (
        CURRENT_TIMESTAMP,
        TG_TABLE_NAME,
        current_user,
		on_date,
		account_rk,
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

CREATE OR REPLACE TRIGGER changes_dm_account_balance
BEFORE INSERT OR DELETE ON dm.dm_account_balance_f
FOR EACH ROW
EXECUTE PROCEDURE dm.changes_in_dm();

CREATE OR REPLACE TRIGGER changes_dm_account_turnover
BEFORE INSERT OR DELETE ON dm.dm_account_turnover_f
FOR EACH ROW
EXECUTE PROCEDURE dm.changes_in_dm();




