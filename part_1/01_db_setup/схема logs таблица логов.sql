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
	destination_table TEXT NOT NULL, --таблица для загрузки данных                        
	user_name TEXT, --пользователь, выполняющий загрузку
	pk_date DATE, -- первое поле составного ключа в destination_table
	pk_second_part NUMERIC, ---- второе поле составного ключа в destination_table
	operation TEXT --insert or update
);

