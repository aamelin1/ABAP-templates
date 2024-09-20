В "новых" системах SAP S/4HANA при проводке документов переоценки (тр. **FAGL_FCV**) формируются унифицированные документы, т.е. документы с **BSTAT = U**, такие документы не записываются в таблицы ракурса ввода (BSEG итп) и для них не вызываются проверки/замещения и события BTE (OPENFI, тр. FIBF). Для замещений полей в таких документах можно использовать **BAdI AC_DOCUMENT**

Так же, в настройках процедуры переоценки (Define Valuation Methods) есть возможность настроить правила формирования FI документов при переоценке. Например проводить по каждой позиции отдельный документ:

![image](https://private-user-images.githubusercontent.com/37226181/252629475-da15a599-cd45-45de-9baa-161850330e1e.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2Mjk0NzUtZGExNWE1OTktY2Q0NS00NWRlLTliYWEtMTYxODUwMzMwZTFlLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWIyOGE1M2ZlMzRmYzY5ZWU3YmE4YTIyOWY2OTg2MjVjYTlmM2YxMDNkOWM4MzU1ODJmZjE0OGY2N2U2MjhhOTMmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.V0ItnFpUfqXxJmOTImWi9183eUaL34H2nuZEpbfwIsg)

Все настройки находятся здесь: **SPRO->Financial Accounting->General Ledger Accounting->Periodic Processing->Valuate**. Присвоение счетов в таблице **T030H->KDF** (тр. **OBA1**)

Для переоценки открытых позиций используются эти поля:

![image](https://private-user-images.githubusercontent.com/37226181/252630139-56c4b281-b0b4-4da1-a07b-7e070973c873.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MzAxMzktNTZjNGIyODEtYjBiNC00ZGExLWEwN2ItN2UwNzA5NzNjODczLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWM3Nzc3NDU3N2Q0YTYyZmY1OTAyMjM5NmE5MzViNzNjOWQyMWI0NjAxY2E1N2ZlZjhhMGJlMGUxN2IwNzQ4MGEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.rJ82AzaH-WI4es-y4ZlptlN_AbGHEDLz-EkqV7nozTk)

Есть еще отдельная настройка с набором аналитик, которые будут копироваться в документы переоценки (к сожалению, поля VPTNR "партнер" там нет, но есть поле RASSC/VBUND "компания-партнер", что может быть полезно для анализа ВГО). Настройка тут (тр. **FINS_FCT**):

![image](https://private-user-images.githubusercontent.com/37226181/252625629-85189101-9cf9-4ba0-ba53-f1855a96cef4.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MjU2MjktODUxODkxMDEtOWNmOS00YmEwLWJhNTMtZjE4NTVhOTZjZWY0LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWUzNWVhMTgxYzFjZmU2NTk1OTcyMWJjMTA1MDAwZGMzMTBhMzk4YzcyYWQ4Nzg5NjA5MzIyZGU2M2MxMDk1NzEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.mqjR3NvNwr-xlxyZMterEmJ0uxC9ERpXIqxLuoyERrE)

Ниже пример как можно заполнить поля: партнер (номером контрагента) и компания-партнер (номером компании из мастер данных контрагента)

### Заполнение поля "Trading Partner No." ACDOCA-RASSC

[](https://github.com/aamelin1/SAP-FI-notes/wiki/%D0%9E%D0%B1%D0%BE%D0%B3%D0%B0%D1%89%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B0%D0%BD%D0%B0%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%BE%D0%B9-%D0%BA%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%B3%D0%B5%D0%BD%D1%82-%D0%B4%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2-%D0%BF%D0%B5%D1%80%D0%B5%D0%BE%D1%86%D0%B5%D0%BD%D0%BA%D0%B8-FAGL_FCV#%D0%B7%D0%B0%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BF%D0%BE%D0%BB%D1%8F-trading-partner-no-acdoca-rassc)

Все что требуется - это поставить галку оценивать в настройке **FINS_FCT** напротив поля **RASSC** "Company ID of Trading Partner" :

![image](https://private-user-images.githubusercontent.com/37226181/252626007-a17f58ee-7205-4ec9-911f-ccf85d25e23e.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MjYwMDctYTE3ZjU4ZWUtNzIwNS00ZWM5LTkxMWYtY2NmODVkMjVlMjNlLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTNlZTcwYmFlNzI5ZDJhYjBjMTFiZmZmOGQ3NTExNDdlNTBkYjY1NzkyM2E1ZGFmMDhlYmYxZTQyZGJjOTMyOGImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.zDpm3U6xglgEj-1BRAD-kcbFmVPAAUKOhHRrwFz0TZY)

После этого, в документах переоценки будет заполнятся поле **ACDOCA-RASSC** значением компании партнера (определяется на основании данных из контаргента LFA1-VBUND, KNA1-VBUND, BUT... итд)

Cам справочник компаний это таблица **T880**, настройки тут:

![image](https://private-user-images.githubusercontent.com/37226181/252628120-7373f603-3336-49dc-8e80-b8c9378d7a7d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MjgxMjAtNzM3M2Y2MDMtMzMzNi00OWRjLThlODAtYjhjOTM3OGQ3YTdkLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTkxYzZhZDM2MTU1NDEwZmUxOTVlNWUxY2UzNTdiMGRiOTc0OTA2MmViYjMwY2FmYzJmNTAyNDAxMDJmYjk1MDcmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.2Nxo61TwcKw75fxdyOjLiiBwY1WQRezkv9nLCDjLlRI)

В документе переоценки это отражается так:

![image](https://private-user-images.githubusercontent.com/37226181/252627114-b1774b60-32e5-4a14-b052-07fe8b296115.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MjcxMTQtYjE3NzRiNjAtMzJlNS00YTE0LWIwNTItMDdmZThiMjk2MTE1LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWFjZWUyNzdhYzg0OWRhODcyNThmMDQzMTQ1MDUzMDcyY2FiNWYxNzMwOWViM2YwMzAxOGY1MTRkNThjMWE2NjkmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.CUFkABoxuFs0hNh7h5X2dISE_sujU9SmSNt6kzjA0Gs)

### Заполнение поля "Partner" ACDOCA-VPTNR

[](https://github.com/aamelin1/SAP-FI-notes/wiki/%D0%9E%D0%B1%D0%BE%D0%B3%D0%B0%D1%89%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B0%D0%BD%D0%B0%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%BE%D0%B9-%D0%BA%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%B3%D0%B5%D0%BD%D1%82-%D0%B4%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2-%D0%BF%D0%B5%D1%80%D0%B5%D0%BE%D1%86%D0%B5%D0%BD%D0%BA%D0%B8-FAGL_FCV#%D0%B7%D0%B0%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BF%D0%BE%D0%BB%D1%8F-partner-acdoca-vptnr)

1. Создаем реализацию **BAdI AC_DOCUMENT в se18**. Нам нужен метод **CHANGE_INITIAL**, в нем доступен весь FI документ в **IM_DOCUMENT** TYPE ACC_DOCUMENT.
    
2. Проверяем, есть ли нужные нам поля для замещения в структуре ACC_DOCUMENT_SUBST->ITEM.Т.е. в se11 структура **ACCIT_SUB**. Если там нет нужных полей, то добавляем их через append structure
    

![image](https://private-user-images.githubusercontent.com/37226181/252633809-44cafe71-4cfb-4c17-adb9-beff0d4d10ac.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MzM4MDktNDRjYWZlNzEtNGNmYi00YzE3LWFkYjktYmVmZjBkNGQxMGFjLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTkzOWRjZjZlMTQ2YWZmZjkwY2M0YjIxN2JiNWQ2YWJlYmNiNzI0NGUxNzg5ZGIxMDk4ZjNjNjg5MTQ4Y2YyMjYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.-BOJEydBl-CsVKFf8l7NJuTxO092jvNduwAuOV3zpW4)

Должно получится как то так:

![image](https://private-user-images.githubusercontent.com/37226181/252634041-f2506e45-9aad-4d5f-9826-0fb36ae8f0a2.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MzQwNDEtZjI1MDZlNDUtOWFhZC00ZDVmLTk4MjYtMGZiMzZhZThmMGEyLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTA2NzM2OTk5YTgyNzI5ODU1Y2JhYzZhZjc1ZmYyNThjYzY2NmRjNjY2MDg2NGNmMDA1YmUyMjFhMWNmYWEwYTUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.yRxbF7W1e3xlgx7Oh_LH3tjvgMHmWJwYkOhyWHsbZ6U)

Активируем структуру

3. Идем в нашу реализацию BAdI AC_DOCUMENT и пишем реализацию в методе CHANGE_INITIAL с заполнением поля VPTNR

Для примера:

![image](https://private-user-images.githubusercontent.com/37226181/252634533-422614d9-6ba4-416f-af34-6d6e84a4ed20.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MzQ1MzMtNDIyNjE0ZDktNmJhNC00MTZmLWFmMzQtNmQ2ZTg0YTRlZDIwLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTlmYjBkOWU0MzUxNTI1OGFkYzcwZWNkNzIxM2M1YzlmNjAxNTFmNWFmMmEzYzA3MDNlZDI5OTNkMjMzYjk1YjgmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.qNUB8-5xb4f0gaZPQmi3HXBVxS5zLBEzPbqkFFGL6xI)

Логика внутри метода FILL_FCV_VPTNR:

1. Проверяем что расширение вызывается из программы переоценки (GLVOR = RFBU, AWTYP = BKPFF, BTTYPE и CBTTYPE = RFCV)
2. Отбрасываем позиции PL счетов(на основании T030H), на мой взгляд это опционально и можно вынести выборку из T030H в конструктор класса.
3. Находим контрагента из оригинального документа по ссылке в sgtxt
4. Замещаем поле cs_document_sub-item[]-vptnr нужным значением

```abap
  method FILL_FCV_VPTNR.
      "Fill VPTNR at FAGL_FCV docs (only at AP/AR items (not PL)
**********************************************************************
    DATA: lv_GLVOR TYPE GLVOR VALUE 'RFBU',
          lv_AWTYP TYPE AWTYP VALUE 'BKPFF',
          lv_BTTYPE TYPE FINS_BTTYPE VALUE 'RFCV' , "FAGL_FCV
          lv_CBTTYPE TYPE FINS_CUSTBTTYPE VALUE 'RFCV'. "FAGL_FCV
**********************************************************************
    CHECK is_document-header-GLVOR = lv_GLVOR.
    CHECK is_document-header-AWTYP = lv_AWTYP.

    LOOP AT is_document-ITEM ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE AWTYP = lv_AWTYP AND  BTTYPE = lv_BTTYPE AND  CBTTYPE = lv_CBTTYPE.
*      Check GL account (fill BP only at AP/AR reval account)
      DATA: lv_t_hkont TYPE hkont.
      CLEAR lv_t_hkont.
      SELECT SINGLE HKONT
        FROM T030H
        INTO lv_t_hkont
        WHERE LKORR = <fs_item>-hkont.
      CHECK lv_t_hkont IS NOT INITIAL.
*      Fill VPTNR at new FI doc
      DATA: ls_item_ex TYPE accit_sub.
      CLEAR ls_item_ex.
      MOVE-CORRESPONDING <fs_item> TO ls_item_ex.
*      Get partner by original doc (by sgtxt)
      DATA: lt_split    TYPE TABLE OF char50.
      SPLIT <fs_item>-sgtxt AT space INTO TABLE lt_split.
      CHECK lines( lt_split ) >= 4. "text+belnr+buzei+gjahr + bla bla bla (lang depends)
      DATA: lv_belnr TYPE BSEG-belnr,
            lv_buzei TYPE BSEG-BUZEI,
            lv_gjahr TYPE bseg-gjahr,
            lv_lifnr TYPE bseg-lifnr,
            lv_kunnr TYPE bseg-kunnr.
      CLEAR: lv_belnr, lv_buzei, lv_gjahr, lv_lifnr, lv_kunnr.
      READ TABLE lt_split INTO lv_belnr INDEX 2.
      READ TABLE lt_split INTO lv_buzei INDEX 3.
      READ TABLE lt_split INTO lv_gjahr INDEX 4.
      SELECT SINGLE lifnr, kunnr
        FROM BSEG
        INTO ( @lv_lifnr, @lv_kunnr )
        where bukrs = @<fs_item>-bukrs
          AND belnr = @lv_belnr
          AND buzei = @lv_buzei
          AND gjahr = @lv_gjahr.
      CHECK lv_lifnr IS NOT INITIAL or lv_kunnr IS NOT INITIAL.
      IF lv_lifnr IS NOT INITIAL.
        ls_item_ex-vptnr = lv_lifnr.
      ENDIF.
      IF lv_kunnr IS NOT INITIAL.
        ls_item_ex-vptnr = lv_kunnr.
      ENDIF.
      INSERT ls_item_ex INTO TABLE cs_document_sub-item.
    ENDLOOP.
    IF cs_document_sub-item[] IS NOT INITIAL.
      MOVE-CORRESPONDING is_document-header TO cs_document_sub-header.
    ENDIF.
**********************************************************************
  endmethod.
```

Активируем реализацию BAdI, тестируем, получаем такой результат (заполненное поле партнер в документе переоценки FAGL_FCV):

![image](https://private-user-images.githubusercontent.com/37226181/252636125-7ba10596-5b34-4379-9dc1-1680e6ea896d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY3OTc5MjMsIm5iZiI6MTcyNjc5NzYyMywicGF0aCI6Ii8zNzIyNjE4MS8yNTI2MzYxMjUtN2JhMTA1OTYtNWIzNC00Mzc5LTlkYzEtMTY4MGU2ZWE4OTZkLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA5MjAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwOTIwVDAyMDAyM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWE5NTlkNDk1YmZjN2I1YjE0YzI5NWQ0MDIwYzA3M2U4NTlkMDEwMmQ4NTk0YzZlYzEyZWIwNmU2YjdlNTYzODEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.5p8BfjKVUGHEFekdwK3tNv9qT5rW5ymjiutSv3BsA3Y)

**PS**. История переоценки хранится в таблице **FAGL_BSBW_HISTRY**.

Для анализа переоценки есть стандартный отчет из локализации РФ - **J3RFREVHISTFC**

Полезные ноты:

SAP KBA [1523296](https://service.sap.com/sap/support/notes/1523296) - FAGL_FC_VAL, FAGL_FCV and SAPF100 Account determination KDB or KDF

SAP KBA [2061774](https://service.sap.com/sap/support/notes/2061774) - How to use parameter NO_T030H to avoid read table T030H

SAP Note [2030975](https://service.sap.com/sap/support/notes/2030975) - FAGL_FCV: Account determination for G/L balances only from table T030S