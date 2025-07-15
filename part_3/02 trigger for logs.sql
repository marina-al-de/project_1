
/*
Создаём триггеры на вставку и удаление записей для dm.dm_account_balance_f и dm.dm_account_turnover_f,
используя ранее созданные функции ds.update_logs_start() и ds.update_logs_end(). 
*/

-- триггер на старт расчёта 

CREATE OR REPLACE TRIGGER changes_dm_f101_round_f
BEFORE INSERT OR DELETE ON dm.dm_f101_round_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_start();

-- триггер на окончание расчёта

CREATE OR REPLACE TRIGGER changes_dm_f101_round_f_end
AFTER INSERT OR DELETE ON dm.dm_f101_round_f
FOR EACH ROW
EXECUTE PROCEDURE ds.update_logs_end();




