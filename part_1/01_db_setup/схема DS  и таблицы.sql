/*
Создаём базу данных банковских операций.
*/

CREATE SCHEMA DS;


/*
Создаём таблицы для слоя детальных данных: DS.FT_BALANCE_F (баланс на счёте), DS.FT_POSTING_F (проводки), DS.MD_ACCOUNT_D (счета), 
DS.MD_CURRENCY_D (валюта), DS.MD_EXCHANGE_RATE_D (обменнный курс), DS.MD_LEDGER_ACCOUNT_S (справочник балансовых счетов). 

FOREIGN KEY не добавлены, т.к. PRIMARY KEY композитные и следовательно FOREIGN KEY должны содержать те же самые столбцы, что 
невозможно реализвовать ввиду определенной в задании структуры таблиц. 
*/

CREATE TABLE IF NOT EXISTS DS.FT_BALANCE_F 
(
	on_date DATE NOT NULL,
	account_rk NUMERIC NOT NULL, 
	currency_rk NUMERIC, 
	balance_out FLOAT,
	CONSTRAINT balance_pkey PRIMARY KEY(on_date, account_rk)
);

CREATE TABLE IF NOT EXISTS DS.FT_POSTING_F
(
	oper_date DATE NOT NULL,
	credit_account_rk NUMERIC NOT NULL, 
	debet_account_rk NUMERIC NOT NULL, 
	credit_amount FLOAT,
	debet_amount FLOAT
);

CREATE TABLE IF NOT EXISTS DS.MD_ACCOUNT_D
(
	data_actual_date DATE NOT NULL,
	data_actual_end_date DATE NOT NULL,
	account_rk NUMERIC NOT NULL, 
	account_number VARCHAR(20) NOT NULL,
	char_type VARCHAR(1) NOT NULL,
	currency_rk NUMERIC NOT NULL, 
	currency_code VARCHAR(3) NOT NULL,
	CONSTRAINT account_pkey PRIMARY KEY(data_actual_date, account_rk)
);

CREATE TABLE IF NOT EXISTS DS.MD_CURRENCY_D
(
	currency_rk NUMERIC NOT NULL,
	data_actual_date DATE NOT NULL,
	data_actual_end_date DATE,
	currency_code VARCHAR(3),
	code_iso_char VARCHAR(3)
);

CREATE TABLE IF NOT EXISTS DS.MD_EXCHANGE_RATE_D
(
	data_actual_date DATE NOT NULL,
	data_actual_end_date DATE, 
	currency_rk NUMERIC NOT NULL, 
	reduced_cource FLOAT,
	code_iso_num VARCHAR(3), 
	CONSTRAINT exchange_rate_pkey PRIMARY KEY(data_actual_date, currency_rk)
);

CREATE TABLE IF NOT EXISTS DS.MD_LEDGER_ACCOUNT_S
(
	chapter CHAR(1),
	chapter_name VARCHAR(16),
	section_number INTEGER,
	section_name VARCHAR(22),
	subsection_name VARCHAR(21),
	ledger1_account INTEGER,
	ledger1_account_name VARCHAR(47),
	ledger_account INTEGER NOT NULL,
	ledger_account_name VARCHAR(153),
	characteristic CHAR(1),
	is_resident INTEGER,
	is_reserve INTEGER,
	is_reserved INTEGER,
	is_loan INTEGER,
	is_reserved_assets INTEGER,
	is_overdue INTEGER,
	is_interest INTEGER,
	pair_account VARCHAR(5),
	start_date  DATE NOT NULL,
	end_date  DATE,
	is_rub_only INTEGER,
	min_term VARCHAR(1),
	min_term_measure VARCHAR(1),
	max_term VARCHAR(1),
	max_term_measure VARCHAR(1),
	ledger_acc_full_name_translit VARCHAR(1),
	is_revaluation VARCHAR(1),
	is_correct VARCHAR(1),
	CONSTRAINT ledger_account_pkey PRIMARY KEY(ledger_account, start_date)
);