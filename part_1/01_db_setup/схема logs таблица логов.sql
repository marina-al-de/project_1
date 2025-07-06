/*
Создаём схему LOGS для хранения логов загрузки данных в таблицы схемы DS.
*/

CREATE SCHEMA LOGS;

/*
Создаём таблицу для хранения логов. Таблица содержит поля: первичный ключ, начало и окончание загрузки данных, 
название обновляемой таблицы, количество загруженных записей, пользователь, выполнивший загрузку.
*/

CREATE TABLE logs.uploads_in_ds
(
    log_id SERIAL PRIMARY KEY,         
    load_start_tstamp TIMESTAMP NOT NULL, 
	load_end_tstamp TIMESTAMP, 
	destination_table TEXT NOT NULL,       
    records_loaded_cnt INT,                  
	user_name TEXT
);

