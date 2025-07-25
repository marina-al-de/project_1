# Решение задачи 1.2

## Перечень технологий
Технологии использованные при решении задачи:
- Реляционная СУБД: PostgreSQL 17;
- Среда SQL разработки : pgAdmin;

## Подготовка  слоя DM в базе данных

- **Схема DM с таблицами под загрузку данных**

В БД создаём схему DM с витриной оборотов `dm.dm_account_turnobver_f` и витриной остатков `dm.dm_account_balance_f`.
Скрипт для создания таблиц:

`part_2/01 create schema DM account turnover and balance.sql`


- **Таблица для логирования изменений в витринах**

Воспользуемся таблицей для логов, созданной в задаче 1.1, только поменяла название таблицы.

Скрипт для таблицы:

`part_2/02 log table for dm.sql`


- **Триггерная функция и триггер на заполнение логов**

Воспользуемся ранее созданными в задаче 1.1 функциями `ds.update_logs_start()` и `ds.update_logs_end()`, но сначала расширим их функционал.  
В `ds.update_logs_start()` изменены блоки для для присваивания значений переменным `pk_date`, `pk_second_part` и `diff_found` с учётом операции DELETE и всех витрин из слоя DM.
В `ds.update_logs_end()` изменения в условии `WHERE`.

Скрипт для функций и триггеров:

`part_2/03 trigger function and trigger for logs.sql`

## Заполнение витрин данных

- **Витрина dm.dm_account_turnover_f**

Создаём процедуру `ds.fill_account_turnover_f` для заполнения витрины `dm.dm_account_turnover_f`. Сначала удаляем записи за дату расчета. Затем с помощью СТЕ `postings_per_account` подсчитываем суммы оборотов по дебиту и кредиту счёта на заданную дату.
В СТЕ `accounts_with_dates_and_ex_rate` извлекаем данные reduced_cource для account_rk на дату расчета. Финальный шаг - объединение СТЕ `postings_per_account` и `accounts_with_dates_and_ex_rate`, чтобы получить суммы по дебиту и кредиту в рублях, 
и вставка полученных значений в витрину `dm_account_turnover_f`. В конце с помощью анонимного блока запускаем процедуру `ds.fill_account_turnover_f` для всех записей таблицы `ds.ft_posting_f`. 

Скрипт процедуры и её запуск:

`part_2/04 procedure fill_account_turnover_f.sql`

- **Витрина dm.dm_account_balance_f**

Перед расчётом остатков по счёту за январь заполняем данные за предыдущий рабочий день 31.12.2017. 

Скрипт на заполение  dm.dm_account_balance_f остатками по счетам на 31.12.2017:

`part_2/05 december ft_balance to md_account_balance.sql`

Далее создаём процедуру `ds.fill_account_balance_f` для заполнения витрины `dm.dm_account_balance_f`. Сначала удаляем записи за дату расчета. С помощью СТЕ `movements_on_account` расчитываем движения по счетам на заданную дату, затем расчитываем остатки
на заданную дату и добавляем данные в `dm.dm_account_balance_f`.  В конце с помощью анонимного блока запускаем процедуру `ds.fill_account_balance_f` для всех записей таблицы `dm.dm_account_turnover_f`.

Скрипт процедуры и её запуск:

`part_2/06 procedure fill_account_balance_f.sql`

## Демонстрация

Ссылка на видео с демонстрацией работы в файле:

`part_2/video_link.txt`



