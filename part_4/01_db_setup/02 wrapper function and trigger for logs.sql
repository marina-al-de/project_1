/*
Создаём wrapper-function , для того, чтобы логировать выгрузки из dm.dm_f101_round_f.
*/

CREATE OR REPLACE FUNCTION dm.download_f101()
RETURNS TABLE (
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
)
AS $$

DECLARE 
    pk_date DATE;
    pk_second_part NUMERIC;
    cur CURSOR FOR SELECT t.from_date, CAST(t.ledger_account AS NUMERIC) 
                   FROM dm.dm_f101_round_f t;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO pk_date, pk_second_part;
        EXIT WHEN NOT FOUND; 
           INSERT INTO logs.logs_for_ds_dm (
            load_start_tstamp,
            destination_table,
            user_name,  
            pk_date, 
            pk_second_part,  
            operation
        ) VALUES (
            CURRENT_TIMESTAMP,
            'dm_f101_round_f',
            current_user,
            pk_date, 
            pk_second_part, 
            'SELECT'
        );
    END LOOP;
    CLOSE cur;
	
    RETURN QUERY SELECT * FROM dm.dm_f101_round_f;
	
END;
$$ LANGUAGE plpgsql;

/*
Создаём триггеры на начало и  окончание загрузки данных в таблицу dm.dm_f101_round_v2. 
*/

CREATE OR REPLACE TRIGGER chages_dm_f101_round_f_v2
BEFORE INSERT OR UPDATE ON dm.dm_f101_round_f_v2
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

CREATE OR REPLACE TRIGGER chages_dm_f101_round_f_v2_end
AFTER INSERT OR UPDATE ON dm.dm_f101_round_f_v2
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();
