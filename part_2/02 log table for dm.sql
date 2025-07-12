/*
Изменим название таблицы logs.uploads_in_ds и столбцов в ней, чтобы сделать их более универсальными и подходящими для витрин из слоя DM.
*/


ALTER TABLE logs.uploads_in_ds RENAME TO logs_for_ds_dm;


ALTER TABLE logs.logs_for_ds_dm RENAME COLUMN pk_date TO record_date;
ALTER TABLE logs.logs_for_ds_dm RENAME COLUMN pk_second_part TO record_account;


