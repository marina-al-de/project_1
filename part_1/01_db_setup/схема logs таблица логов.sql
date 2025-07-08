/*
Создаём схему LOGS для хранения логов загрузки данных в таблицы схемы DS.
*/

CREATE SCHEMA LOGS;

/*
Создаём таблицу для хранения логов. Таблица содержит поля: первичный ключ, начало и окончание загрузки данных, 
название обновляемой таблицы, количество загруженных записей, пользователь, выполнивший загрузку, составной PK 
обновляемй таблицы, выполненное действие (insert/update).
*/

CREATE TABLE logs.uploads_in_ds
(
    log_id SERIAL PRIMARY KEY,         
    load_start_tstamp TIMESTAMP NOT NULL, 
	load_end_tstamp TIMESTAMP, 
	destination_table TEXT NOT NULL,                        
	user_name TEXT,
	pk_date DATE,
	pk_second_part NUMERIC,
	operation TEXT
);

