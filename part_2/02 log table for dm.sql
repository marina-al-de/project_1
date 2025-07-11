/*
Cоздаём таблицу logs.changes_in_dm со столбцами: 
- log_id (PRIMARY KEY), 
- change_tstamp - дата и время внесения изменений в витрину данных,
- dm_changed - витрина данных, где были изменения, 
- user_name - пользователь, сделавший изменения, 
- on_date - дата, за которую производится расчёт в витрине,
- account_rk - счёт, для которого производится расчёт,
- operation - insert or delete
*/

CREATE TABLE logs.changes_in_dm
(
    log_id SERIAL PRIMARY KEY,         
    change_tstamp TIMESTAMP NOT NULL, 
	dm_changed TEXT NOT NULL,                        
	user_name TEXT,
	on_date DATE,
	account_rk NUMERIC,
	operation TEXT
);


