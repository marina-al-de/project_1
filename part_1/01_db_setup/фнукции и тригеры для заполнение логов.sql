/*
Создаём функцию для добавления записей в таблицу logs.uploads_in_ds в начале загрузки. 
*/

CREATE OR REPLACE FUNCTION ds.update_logs_start()
RETURNS TRIGGER AS
$func$
 
	-- объявляем переменные для хранения составного PK для каждой таблицы кроме, DS.FT_POSTING_F, т.к. у неё нет PK согласно условию задания
	-- diff_found - флаг, который обозначает были ли внесены изменения в строку при очередном update. при отсутсвии изменений запись в таблицу 
	-- logs.uploads_in_ds не производится.
	
DECLARE pk_date DATE;
		pk_second_part NUMERIC;
		diff_found BOOLEAN := FALSE;
BEGIN 
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
    ELSE
        pk_date := NULL;
        pk_second_part := NULL;
	END IF;

	IF TG_OP = 'INSERT' THEN
	   diff_found := TRUE;
	ELSIF TG_OP = 'UPDATE' THEN
	   IF (ROW(OLD.*) IS DISTINCT FROM ROW(NEW.*)) THEN
	   		diff_found := TRUE;
		ELSE
			diff_found := FALSE;
		END IF;
	END IF;

	IF diff_found THEN 
    INSERT INTO logs.uploads_in_ds (
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
	
RETURN NEW; 
END
$func$ LANGUAGE plpgsql;

/*
Создаём функцию для добавления времени окончания загрузки с учётом интервала в 5 секунд. 
*/

CREATE OR REPLACE FUNCTION ds.update_logs_end() 
	RETURNS TRIGGER AS

$func$

BEGIN 

	UPDATE logs.uploads_in_ds
		SET load_end_tstamp = (CURRENT_TIMESTAMP + interval '5 second')
		load_end_tstamp IS NULL;
	
RETURN NULL;

END
$func$  LANGUAGE plpgsql;

/*
Создаём и активируем триггеры на начало загрузки данных в таблицы в схеме DS. 
*/

CREATE OR REPLACE TRIGGER upload_start_balance
BEFORE INSERT OR UPDATE ON ds.ft_balance_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER upload_start_posting
BEFORE INSERT OR UPDATE ON ds.ft_posting_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER upload_start_currency
BEFORE INSERT OR UPDATE ON ds.md_currency_d
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER upload_start_account
BEFORE INSERT OR UPDATE ON ds.md_account_d
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER upload_start_exchange_rate
BEFORE INSERT OR UPDATE ON ds.md_exchange_rate_d
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER upload_start_ledger_account
BEFORE INSERT OR UPDATE ON ds.md_ledger_account_s
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

/*
Создаём и активируем триггеры на окончание загрузки данных в таблицы в схеме DS. 
*/

CREATE OR REPLACE TRIGGER upload_end_balance
AFTER INSERT OR UPDATE ON ds.ft_balance_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER upload_end_posting
AFTER INSERT OR UPDATE ON ds.ft_posting_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER upload_end_currency
AFTER INSERT OR UPDATE ON ds.md_currency_d
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER upload_end_account
AFTER INSERT OR UPDATE ON ds.md_account_d
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER upload_end_exchange_rate
AFTER INSERT OR UPDATE ON ds.md_exchange_rate_d
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();

CREATE OR REPLACE TRIGGER upload_end_ledger_account
AFTER INSERT OR UPDATE ON ds.md_ledger_account_s
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();
