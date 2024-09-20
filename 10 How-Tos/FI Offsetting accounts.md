**Что такое корреспонденция счетов?**

Проводки могут быть записаны в виде записи, когда к каждому счету в явном виде определяется вторая сторона проводки (т.е. корреспондирующий счет).

Например, допустим у нас есть входящий инвойс, в SAP эта проводка хранится (в bseg, acdoca итд) без указания корр.счета, т.е. просто список позиций документов:

| Dr/Cr | Account    | Amount  |
| ----- | ---------- | ------- |
| Кт    | Контрагент | 120 RUB |
| Дт    | ПМ/ПСч     | 100 RUB |
| Дт    | НДС        | 20 RUB  |


С точки зрения записи проводки с корреспонденцией счетов она должна выглядеть так

| Dr Account | Amount  | Cr Account | Amount  |
| ---------- | ------- | ---------- | ------- |
| ПМ/ПСч     | 100 RUB | Контрагент | 100 RUB |
| НДС        | 20 RUB  | Контрагент | 20 RUB  |


В системе SAP есть несколько способов как достичь этого:

# Корреспонденция счетов без РФ локализации (заполнение поля GKONT и GKOAR)

[](https://github.com/aamelin1/SAP-FI-notes/wiki/%D0%9A%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-(gkont,-j3rf,-%D1%80%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-acdoca)#%D0%BA%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%D0%B1%D0%B5%D0%B7-%D1%80%D1%84-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8-%D0%B7%D0%B0%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BF%D0%BE%D0%BB%D1%8F-gkont-%D0%B8-gkoar)

Это базовый вариант корреспонденции счетов, без использования РФ локализации, предполагает заполнение поля **GKONT** значением корр.счета (или значением контрагента из корр.позиции). Важно понимать что это **не настоящая корреспонденция счетов** в понимании РСБУ, а лишь доп. аналитика. Т.е. например в документах входящих инвойсов типа:


| Позиция | Дт/Кт | Счет       | Сумма   |
| ------- | ----- | ---------- | ------- |
| 1       | Кт    | Контрагент | 120 RUB |
| 2       | Дт    | ПМ/ПСч     | 100 RUB |
| 3       | Дт    | НДС        | 20 RUB  |

Позиция 1 **не будет разделена** на две позиции. Для позиции 1 корр.счет определится как счет ПМ/ПСч из позиции 2 (или не определится вовсе, зависит от настроек описанных ниже). Пример как это работает: Допустим у нас есть такой документ:

![image](https://private-user-images.githubusercontent.com/37226181/239383503-358fed55-141f-4a83-ac2a-fa41ac3335ff.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzkzODM1MDMtMzU4ZmVkNTUtMTQxZi00YTgzLWFjMmEtZmE0MWFjMzMzNWZmLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTZkZGEyOGY0OTRlZjY4YTQ2NzMyNGMzN2MzOTMzMDRiM2JmMWMwZjEzZmEyY2JiZGNmNjQ2OGQ3OTIzNDMxMTUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.UTnSTTBTYQodZ0Vy-NUhjcbchDHJ4iIkmAh_369CiwA)

Как это отразится в acdoca:

![image](https://private-user-images.githubusercontent.com/37226181/239383881-0378d7db-b6ec-49ce-9298-faaffc7c7f6f.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzkzODM4ODEtMDM3OGQ3ZGItYjZlYy00OWNlLTkyOTgtZmFhZmZjN2M3ZjZmLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTA4ODhjMGNlNzRhZWVlYmZiMDI4NjJjZjZkODNlNWM5MThmMGJmMzZmMGRkOGY1YmNmYzQ5MTNkZmRhYzZkMmQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.ybEo6oKHyCigeYq6AJFgg0XfBi_3_UjoWRPUxJ9LjMc)

Обратите внимание, что в позициях где тип корр.счета отмечен как K или D (поле `GKOAR`) значения в поле корр.счет (`GKONT`) будет равно контрагенту (кредитору или дебитору), а не номеру счета ГК.

При этом логика заполнения этих полей в BSEG может отличаться, тот же документ в `BSEG`:

![image](https://private-user-images.githubusercontent.com/37226181/239384646-c80a5fb6-4e63-476f-b05d-5df7044ffe22.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzkzODQ2NDYtYzgwYTVmYjYtNGU2My00NzZmLWIwNWQtNWRmNzA0NGZmZTIyLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTljMDI1MmViZjk0MmZlMmIwMTQxMzdmNjUzODMwNzFmYjI5Nzg3MjNjZGIxZjlhZTYyMTIwMzQ3ZWI3YTkyZTAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.6qO3iwBhbjqgHZUDIrHdKwgXSL4lD7kOOcUUjY-sti0)

Это хорошо видно в отчетах ГК, например в `FAGLL03h` (поля `GKONT` и `GHKON`). Одно поле из `acdoca`, второе из `bseg`

![image](https://private-user-images.githubusercontent.com/37226181/239385777-27ac7562-e924-456a-a26d-89ebe49576ff.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzkzODU3NzctMjdhYzc1NjItZTkyNC00NTZhLWEyNmQtODllYmU0OTU3NmZmLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWNjZDk1MGM2YzUyNjE1YzBjMGYzNDk3N2JmMDg0MWE5M2VhMTI2ZjMwY2RmM2Y4MDY5MDYzZTg5ODIyNjA0YjImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.ypLTgz6P-bFd2dUURBGMgnn50hx2nm5JctENjwSWMug)

Логику определения `GKONT` можно посмотреть в ФМ `GET_GKONT`. Так же может быть полезна нота [2476266](https://launchpad.support.sap.com/#/notes/2476266)

**Построить на этом решении полноценный учет корр.счетов невозможно**

Настройки с правилами заполнения "псевдо" корр.счета находятся тут

![image](https://private-user-images.githubusercontent.com/37226181/239324399-f1cc8484-c469-42da-88e5-8f5346520736.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzkzMjQzOTktZjFjYzg0ODQtYzQ2OS00MmRhLTg4ZTUtOGY1MzQ2NTIwNzM2LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTBmNmNmZWIyODVmYzAwMjgyMzhkNTgzMGEwMDIxMjMyZGEyZDQ2NWM2YTFmZmY0M2JlMTNmOTdkODFlMTNjZTQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0._9PvBzrzcc_Ys7qCZycJOhjrYD8C1Qtc1QKfSQK_1uc)

Возможные варианты определения корр.счета:

![image](https://private-user-images.githubusercontent.com/37226181/239324713-d05f980a-27d5-4ffa-8bb5-44a508d7dc54.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzkzMjQ3MTMtZDA1Zjk4MGEtMjdkNS00ZmZhLThiYjUtNDRhNTA4ZDdkYzU0LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTlhMmY4MjZlMWJhMGRjMDRjYjMxYjI2NjE1NWNlMWRjMjE4MWY1OGM0MjIyYmIzMGU1MTIwYzUwZDJhOTFlMDMmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.Vv4wxayzbpfSz-gScbQs8gIPzfRSwAnHWcHyqxF6MZo)

Таблица `FINS_MIG_CUST`

Так же в системе есть функционал для перезаполнения корр.счета в уже проведенных документах, транзакция `FINS_MIG_GKONT`.

# Корреспонденция счетов в S/4HANA (локализация РФ)

[](https://github.com/aamelin1/SAP-FI-notes/wiki/%D0%9A%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-(gkont,-j3rf,-%D1%80%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-acdoca)#%D0%BA%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%D0%B2-s4hana-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D1%80%D1%84)

Основная идея этого решения - **разделение позиций документа в ракурсе ГК**. Напомню, что с точки зрения FI у каждого документа есть ракурс ввода - это таблица `BSEG`/`BSEG_ADD` и ракурс ГК - это таблица `ACDOCA` (ранее, до S/4 - `faglflex`). Исключение - унифицированные документы (`BSTAT = U`), у них нет ракурса ввода.

Т.е., если упрощено - то в момент проводки любого документа в системе формируется ракурс ввода, и, если активирован функционал новой корреспонденции счетов - то в системе запускается механизм сплиттинга позиций в ракурсе ГК и для каждой позиции записывается ссылка на корреспондирующую позицию. С технической точки зрения это значит что для каждой строки acdoca есть ссылка на другую строку в acdoca. Ссылки реализованы по полям `acdoca-docln` <-> `acdoca-gkont`. И там и там записывается номер корр.позиции (из ракурса ГК, может не совпадать с номером позиции в `bseg-buzei`).

Если в момент проводки не удалось определить корр.счет (например не хватает настроек для определения пар счетов), то такой документ не проведется и система выдаст ошибку:

![image](https://private-user-images.githubusercontent.com/37226181/239533691-41761fa0-fb33-42f5-818c-099d04dbf728.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzM2OTEtNDE3NjFmYTAtZmIzMy00MmY1LTgxOGMtMDk5ZDA0ZGJmNzI4LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTZlY2VlNjMyZDczYjU5MmI0OTFiNDIwZDU0NThmZDJmNzg1YWMxZTdmYjQ2ZjkyMmZhMTQwY2ExZTdlZjQ3NGImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.xp6dh2mdWFIrUgY_nUQWPeIkx9WZoBYy-XDfpIoSJxs)

Как следствие этого подхода - **переразобрать корреспонденцию в уже проведенных документах невозможно**. Необходимо их сторнировать, менять правило разбора и проводить заново.

Как это работает, на примерах: Допустим у нас есть входящий инвойс (ракурс ввода):

![image](https://private-user-images.githubusercontent.com/37226181/239524846-ac8a849a-9229-48f5-a2d8-5844a3d39a68.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MjQ4NDYtYWM4YTg0OWEtOTIyOS00OGY1LWEyZDgtNTg0NGEzZDM5YTY4LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTE3MzIxYWZkZjc3Y2I2NDNmNmFjMjMyMGI3OTBmZTQ0ODZlMmFkMjI0ODIwODdjYmYxMzY5NTgxNGY1MzE3MWQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.EmBEu07E5PtQEY7M8pqkx807gTnPWC7eYsIfAHTu920)

В ракурсе ГК (`acdoca`) с включенной новой ПКС он будет выглядет вот так:

![image](https://private-user-images.githubusercontent.com/37226181/239524963-c81530fd-0cfe-42df-8654-d34b4a28a72a.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MjQ5NjMtYzgxNTMwZmQtMGNmZS00MmRmLTg2NTQtZDM0YjRhMjhhNzJhLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWVkNjY1M2YzMDQxMTk2ZWRhNWNkZmYwYTJkYmFkYjY5MzFiY2FiYmEwNmQ0NTY2NGI0ZTcxYzgwZWFiNDNjYWEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.hwJB_mPy8OXigvR_3LhlyCKTY3eUipmUKa9afBiI5UM)

Обратите внимание что строка с кредиторской задолженностью разделилась на две строки в ракурсе ГК. Строка с `BUZEI = 1` разделилась на две строки где `BUZEI = 1`, а `DOCLN = 000002 и 000004`. При этом каждая новая строка имеет ссылку на корр. строку в этом же документе (`GKONT = 1 и 3`)

Так же можно сделать небольшую доработку для `FB03` и добавить поле с номером корр счета. Т.е. для каждой строчки acdoca считать из той же таблицы acdoca значение из поля `RACCT` по условиям

```abap
ACDOCA-RLDNR  = ACDOCA-RLDNR
ACDOCA-RBUKRS = ACDOCA-RBUKRS
ACDOCA-GJAHR  = ACDOCA-GJAHR
ACDOCA-BELNR  = ACDOCA-BELNR
ACDOCA-DOCLN  = ACDOCA-GKONT
```

И вывести его в новый столбец в `FB03` в ракурсе ГК:

![image](https://private-user-images.githubusercontent.com/37226181/239533200-64792c0c-2ba4-4be5-aa8c-0ba53643b3f0.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzMyMDAtNjQ3OTJjMGMtMmJhNC00YmU1LWFhOGMtMGJhNTM2NDNiM2YwLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWY0YWNkOTNjMWZkODRkYzI4ZTBhZjBmMzg1NjM3OWM5ZjRhMzVlZjhhMjk0MGQ0MzExYTdkYTk0ZjdmYzdmY2YmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.aiAZr5ikFDOWubFWLsE_NacXeyFDZGuZ7o28JFVnefM)

`FB03`->ракурс ГК

![image](https://private-user-images.githubusercontent.com/37226181/239532584-07c7572b-2732-4db9-b080-4c406e4a980d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzI1ODQtMDdjNzU3MmItMjczMi00ZGI5LWIwODAtNGM0MDZlNGE5ODBkLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTA5MTYyZTI1Yzk1ZjAxYmQ4YmUwZTYyZGJlMzYyZTVkZTdmOGQyYWFlYmU5YmVjOWQzYTk0Y2ZiZmIwYTUwMGMmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.8EjZUd6AYaj9M3DfiD8J8WQSlhuNLDtzDkHY5aa0pJs)

Аналогично можно доработать отчеты по отдельным позициям ГК, например добавить в `FAGLL03h` новое поле (`ZZGKONT`)

![image](https://private-user-images.githubusercontent.com/37226181/239534095-7b419537-62d1-4757-82cd-629a7581ead7.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzQwOTUtN2I0MTk1MzctNjJkMS00NzU3LTgyY2QtNjI5YTc1ODFlYWQ3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTVjMWZjNzI4ZmU5NjdlMzBhZWEzZWQ3NjFjMDc5ZWZlYmJhYmQzMTY1MjIyYmJkZDhiNDU4N2VkMzI2YjgyNmQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.FfkWccQCJouHzavkvUGrujCBzMPqZr8gJw9YANhAxMg)

заполняемое по такой же логике:

![image](https://private-user-images.githubusercontent.com/37226181/239534145-caeb9e1e-db50-44e4-a37f-6eed1160555f.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzQxNDUtY2FlYjllMWUtZGI1MC00NGU0LWEzN2YtNmVlZDExNjA1NTVmLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTYwMWI2YmFiMzcwNTMwY2Q1ZWY0NWQ0OGYzMzliNTNlOTJlYWI5NzQzZjE0NTllYTNhNzFmZDNmMGZhY2Y0MGYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.F359XKjS5gTof-HG5HLJi5ccbPnl15MZ_D_kl9SbvZg)

Описание от SAP тут: [Offsetting Account Determination_New.pdf](https://github.com/aamelin1/ABAP-templates/files/11515735/Offsetting.Account.Determination_New.pdf)

Настройки решения находятся тут:

![image](https://private-user-images.githubusercontent.com/37226181/239534878-14ce2e55-86ab-450d-b9f4-22448c2cd266.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzQ4NzgtMTRjZTJlNTUtODZhYi00NTBkLWI5ZjQtMjI0NDhjMmNkMjY2LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTdjNjIwYjBhMDg1MTc1ZDYwMjVkZWNiMzgwM2M0ZGIxYWFlYjY5MTQ0MmE2OGI5OTgzZDYzMjNkOTg4MjYxMmImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.te5gP0_rX3zKA1S4UM28HkFRliOxAZeb-fCT3iJDuSk)

- Таблицы с настройками правил - `FIRUD_OFFS_*`
- Внутренняя логика обработки/разделения документов в классах `CL_FIRU_OFFSET_PROCESSING`, `CL_FIRU_OFFSET_DETERMINATION`
- Расширения - `BADI_FINS_ACDOCA_MODIFY` (общее, не только для GKONT)
- При активации новой ПКС – старую пока можно не деактивировать, т.е. `J_3_corr_item` и `J_3*kkr0` могут продолжить заполняться.

Сравнение концепций [новой ПКС](https://github.com/aamelin1/ABAP-templates/wiki/%D0%9A%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%28gkont%2C-j3rf%2C-%D1%80%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-acdoca%29/_edit#%D0%BA%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%D0%B2-s4hana-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D1%80%D1%84) и [старого решения](https://github.com/aamelin1/ABAP-templates/wiki/%D0%9A%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%28gkont%2C-j3rf%2C-%D1%80%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-acdoca%29/_edit#%D0%BA%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%D1%81%D1%82%D0%B0%D1%80%D0%BE%D0%B5-%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D1%80%D1%84)

![image](https://private-user-images.githubusercontent.com/37226181/239539163-c604eb44-c2a4-456b-a7c3-49ace04ddca6.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1MzkxNjMtYzYwNGViNDQtYzJhNC00NTZiLWE3YzMtNDlhY2UwNGRkY2E2LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWE1MjI1YjQxNWFmZjRmYzFlNmYxZWJhMGNhMjVmNDgzN2U5YzJjMWFmMzYyZDA3YzUxZmNmNWVhYzdjYWQ5OTImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.U2XD7IUFANiL-AnzLLrAXfxH8eG-mNXra4Aj-sSCTeA)

# Корреспонденция счетов старое решение (локализация РФ)

[](https://github.com/aamelin1/SAP-FI-notes/wiki/%D0%9A%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-(gkont,-j3rf,-%D1%80%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-acdoca)#%D0%BA%D0%BE%D1%80%D1%80%D0%B5%D1%81%D0%BF%D0%BE%D0%BD%D0%B4%D0%B5%D0%BD%D1%86%D0%B8%D1%8F-%D1%81%D1%87%D0%B5%D1%82%D0%BE%D0%B2-%D1%81%D1%82%D0%B0%D1%80%D0%BE%D0%B5-%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-%D1%80%D1%84)

Основная идея этого решения состоит в том, что в системе добавляется отдельная подсистема по разбору FI документов, которая записывает информацию по корр. счетам в отдельные `J3RF*` таблицы. Разбор корреспонденции может осуществлятся как на лету (т.е. в процессе проводки документов, через openfi), так и постфактум путем запуска отдельных программ по разбору/переопределению корр.счетов.

Таблицы для хранения результатов разбора корреспонденции счетов:

- `J_3RKKR0` - суммовая таблица со значениями корреспонденции с разбивкой по периодам
- `J_3RKKRS` (в старых системах) или `J_3RK_CORR_ITEMS` - с отдельными позициями в разрезе позиций FI документов с указанием корр счета.

Примечание - в таблицах хранятся суммы без учета знаков и без учета метки красное сторно (т.е. информация по КС там есть, но для корректного отображения оборотов необходимо учитывать метку КС - XNEGP...)

Транзакции для разбора документов:

- `J3RKKRD` - просмотр и разбор корр.счетов по одному документу
- `J3RKKRS` - автоматический разбор документов
- `J3RKNID` - список необработанных документов

Настройки правил разбора:

- `J3RKACT`
- `J3RKAID`
- `J3RKBOOL`
- `J3RKKRN`
- `J3RKNGLL`
- `J3RKPAC`
- `J3RKPAI`
- `J3RKSORT`
- `J3RKSPLIT`

Или в `SPRO` тут:

![image](https://private-user-images.githubusercontent.com/37226181/239557573-47e3e61c-4f35-4760-9b63-2effcc3b048d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1NTc1NzMtNDdlM2U2MWMtNGYzNS00NzYwLTliNjMtMmVmZmNjM2IwNDhkLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTYxN2M0NTViZjYzOTU5YzhmNWZlMDFlZjkxYThmMDU0OTMwOTQ5ZWUzNDFhOWI0NGQ2M2EzMjUzZjE0OThhMzgmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.SmiKdDuZcBXeVt-v2_6LLat4jurU0-JJDnPlElsX_tA)

Примечание - настройка приоритетов пар счетов в данном случае не работает так как это можно ожидать) BAdI - `/CCIS/SMOD_J_3RKAC1`

Отчеты:

- `J3RKOBS`
- `J3RKOBX`
- `J3RKKRL`
- `J3RKGLK`

В целом, можно в `se93` посмотреть все транзакции по маске `J3RK*`

Активация онлайн разбора корреспонденции: В `FIBF` (openFI) необходимо активировать продукт `J3RKORRS/J3RF`Так же настроить обработку ошибок разбора корреспонденции, т.е. тип сообщения об ошибках в момент проводки

![image](https://private-user-images.githubusercontent.com/37226181/239557434-fd1c3531-d6da-48c5-905c-70925188a467.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTcxNzcsIm5iZiI6MTcyNjc5Njg3NywicGF0aCI6Ii8zNzIyNjE4MS8yMzk1NTc0MzQtZmQxYzM1MzEtZDZkYS00OGM1LTkwNWMtNzA5MjUxODhhNDY3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAxNDc1N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTAzZWNmNGJlY2RkODRmOTQ5NTFlZTlkYzZlZjY1NWY0OGYwNjMzNDk0M2M3ZTUyMzBlMDU0NTg1MmJhMjkwYTQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.8t1uvOEBE5x6J-vHMlwEzO_cgCSMzjAIRTm6wa-qnvM)

При необходимости - можно повторно обработать корреспонденцию счетов и переопределить ее для уже проведенных документов. Особенности - если необходимо переопределить корреспонденцию для закрытых периодов - то в `ob52` дожен быть открыт период для типа "+"

Так же может быть полезна нота [740745](https://me.sap.com/notes/740745) - "Account turnover in J3RKOBS doesn't match sum of doc.tur" и поставляемая с ней программа `Z_CORR_FIX` для обновления/корректировки данных в суммовых таблицах. Так же важно понимать что для унифицированных документов (`BSTAT = U`) вы столкнетесь с трудностями, т.к. по ним нет строк в `BSEG` (на эту тему есть несколько SAP OSS нот)

Описание решения от SAP тут [Корреспонденция счетов ГК.pdf](https://github.com/aamelin1/ABAP-templates/files/11517497/default.pdf)