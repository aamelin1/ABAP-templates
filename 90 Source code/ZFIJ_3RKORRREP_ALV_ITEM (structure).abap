DEBIT	1 Тип	SAKNR	CHAR	10	0	Номер основного счета
DUMMY	1 Тип	CHAR1	CHAR	1	0	Индикатор из одной позиции
COLOR	1 Тип	CHAR4	CHAR	4	0	Более точно не опр. область, возм. исп. для уровня "заплат"
GTEXT	1 Тип	TEXT50	CHAR	50	0	Поле текста
CREDIT	1 Тип	SAKNR	CHAR	10	0	Номер основного счета
BELNR	1 Тип	BELNR_D	CHAR	10	0	Номер бухгалтерского документа
BUDAT	1 Тип	BUDAT	DATS	8	0	Дата проводки в документе
DLIFNR	1 Тип	J_3RK_DEBIT_LIFNR	CHAR	10	0	Дебет: номер счета поставщика или кредитора
DLNAME	1 Тип	J_3RK_DEBIT_LNAME	CHAR	40	0	Дебет: имя поставщика или кредитора
DKUNNR	1 Тип	J_3RK_DEBIT_KUNNR	CHAR	10	0	Дебет: номер дебитора
DKNAME	1 Тип	J_3RK_DEBIT_KNAME	CHAR	40	0	Дебет: имя дебитора
KLIFNR	1 Тип	J_3RK_CREDIT_LIFNR	CHAR	10	0	Кредит: номер счета поставщика или кредитора
KLNAME	1 Тип	J_3RK_CREDIT_LNAME	CHAR	40	0	Кредит: имя поставщика или кредитора
KKUNNR	1 Тип	J_3RK_CREDIT_KUNNR	CHAR	10	0	Номер кредитуемого клиента
KKNAME	1 Тип	J_3RK_CREDIT_KNAME	CHAR	40	0	Кредит: имя дебитора
BEG_BAL	1 Тип	J_3RK_DEBIT_TURNOVER	CURR	15	2	Дебетовый оборот
END_BAL	1 Тип	J_3RK_CREDIT_TURNOVER	CURR	15	2	Оборот кредита
WAERS	1 Тип	WAERS	CUKY	5	0	Код валюты
NOTE1	1 Тип	J_3RK_NOTE	CHAR	50	0	Примечание
NOTE2	1 Тип	J_3RK_NOTE	CHAR	50	0	Примечание
ZFI_BANK_ACC	1 Тип	ZFI_BANK_ACC	CHAR	20	0	Номер банковского счета
