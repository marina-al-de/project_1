# Решение задачи 1.4

## Перечень технологий
Технологии использованные при решении задачи:
- Реляционная СУБД: PostgreSQL 17;
- Среда SQL разработки : pgAdmin; 
- ETL c помощью Python 3.12, дополнительные библиотеки: pandas, psycopg2, psycopg2.extras, sqlalchemy

## Подготовка базы данных

- **Копия витрины для формы 101**

Cоздаём копию витрины для формы 101 `dm.dm_f101_round_f_v2`.

[Скрипт для создания таблицы](https://github.com/marina-al-de/project_1/blob/main/part_4/01_db_setup/01%20create%20table%20dm.dm_f101_round_f_v2.sql)

- **Логирование**

Для логирования изменений в таблице `dm.dm_f101_round_f_v2` воспользуемся ранее созданной таблицей для логов `logs.logs_for_ds_dm` и триггерными функциями `ds.update_logs_start()` и `ds.update_logs_end()`.
Добавим триггеры для `dm.dm_f101_round_f_v2`.

Чтобы логировать выгрузки из `dm.dm_f101_round_f` создадим wrapper-функцию `dm.download_f101()`. В etl-скрипте будет использоваться wrapper-функция, а не прямой доступ в таблице `dm.dm_f101_round_f`.

[Скрипт для wrapper-функции и триггеров](https://github.com/marina-al-de/project_1/blob/main/part_4/01_db_setup/02%20wrapper%20function%20and%20trigger%20for%20logs.sql)

## Выгрузка формы 101 в csv-файл

С помощью sqlalchemy подключаемся к БД. Посредством метода `pd.read_sql_query()` извлекаем данные из `dm.dm_f101_round_f`. Как говорилось ранее, к `dm.dm_f101_round_f` доступ осуществляется не напрямую, 
а через wrapper-функцию `dm.download_f101()`, чтобы залогировать выгрузку данных. Затем сохраняем csv-файл в текущей директории. 

[Скрипт](https://github.com/marina-al-de/project_1/blob/main/part_4/02_etl/download_to_csv_f101.py)

## Повторная загрузка csv-файла в копию таблицы 101-формы 

Воспользуемся созданным в задаче 1.1 etl-решением, адаптировав для текущей задачи.

- **Подготовка данных из csv-файла**

Находим акутальную версию csv-файла. С помощью pandas преобразуем данные из csv-файлов в dataframe. Меняем форматы данных для столбцов с датами на `datetime64`, для столбцов `chapter`, `ledger_account`, `characteristic` на `string`.

[Скрипт для созания df](https://github.com/marina-al-de/project_1/blob/main/part_4/02_etl/csv_to_df_f101_v2.py) 

- **SQL-cкрипт для курсоров**

Cоставляем SQL-statement для загрузки данных в таблицу `dm.dm_f101_round_f_v2` в режиме «Запись или замена» при помощи оператора `merge`.

[SQL-cкрипт](https://github.com/marina-al-de/project_1/blob/main/part_4/02_etl/upsert_f101_v2.py)

- **Загрузка данных в копию таблицы 101-формы**

С помощью psycopg2 подключаемся к БД и осздаём курсор для работы с БД. Посредством метода psycopg2.extras.execute_batch() осуществляется загрузка в БД. Помимо курсора, передаём в данный метод SQL-statement и dataframe, преобразованный в data_tuples.

[Скрипт](https://github.com/marina-al-de/project_1/blob/main/part_4/02_etl/etl_f101_v2_.py)

## Демонстрация

[Ссылка на видео с демонстрацией работы в этом файле](https://github.com/marina-al-de/project_1/blob/main/part_4/video_link.txt)


