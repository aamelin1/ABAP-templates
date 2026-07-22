---
title: "FAGL_FCV — обогащение документов переоценки аналитикой контрагента (VPTNR, RASSC)"
keywords: FAGL_FCV, переоценка, foreign currency valuation, VPTNR, RASSC, VBUND, BSTAT U, AC_DOCUMENT, CHANGE_INITIAL, ACCIT_SUB, FINS_FCT, T030H, OBA1, FAGL_BSBW_HISTRY, J3RFREVHISTFC, Note 1523296, Note 2030975
status: ok
---

# FAGL_FCV — обогащение документов переоценки аналитикой контрагента (VPTNR, RASSC)

В "новых" системах SAP S/4HANA при проводке документов переоценки (тр. **FAGL_FCV**) формируются унифицированные документы, т.е. документы с **BSTAT = U**, такие документы не записываются в таблицы ракурса ввода (BSEG итп) и для них не вызываются проверки/замещения и события BTE (OPENFI, тр. FIBF). Для замещений полей в таких документах можно использовать **BAdI AC_DOCUMENT**

Так же, в настройках процедуры переоценки (Define Valuation Methods) есть возможность настроить правила формирования FI документов при переоценке. Например проводить по каждой позиции отдельный документ:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Все настройки находятся здесь: **SPRO->Financial Accounting->General Ledger Accounting->Periodic Processing->Valuate**.
Присвоение счетов в таблице **T030H->KDF** (тр. **OBA1**)

Для переоценки открытых позиций используются эти поля:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Есть еще отдельная настройка с набором аналитик, которые будут копироваться в документы переоценки (к сожалению, поля VPTNR "партнер" там нет, но есть поле RASSC/VBUND "компания-партнер", что может быть полезно для анализа ВГО).
Настройка тут (тр. **FINS_FCT**):

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_



Ниже пример как можно заполнить поля: партнер (номером контрагента) и компания-партнер (номером компании из мастер данных контрагента)

### Заполнение поля "Trading Partner No." ACDOCA-RASSC

Все что требуется - это поставить галку оценивать в настройке **FINS_FCT** напротив поля **RASSC** "Company ID of Trading Partner" :

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

После этого, в документах переоценки будет заполнятся поле **ACDOCA-RASSC** значением компании партнера (определяется на основании данных из контаргента LFA1-VBUND, KNA1-VBUND, BUT... итд)

Cам справочник компаний это таблица **T880**, настройки тут:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

В документе переоценки это отражается так:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_


### Заполнение поля "Partner" ACDOCA-VPTNR
1) Создаем реализацию **BAdI AC_DOCUMENT в se18**. Нам нужен метод **CHANGE_INITIAL**, в нем доступен весь FI документ в **IM_DOCUMENT** TYPE ACC_DOCUMENT. 

2) Проверяем, есть ли нужные нам поля для замещения в структуре ACC_DOCUMENT_SUBST->ITEM.Т.е. в se11 структура **ACCIT_SUB**. Если там нет нужных полей, то добавляем их через append structure

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Должно получится как то так:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Активируем структуру

3) Идем в нашу реализацию BAdI AC_DOCUMENT и пишем реализацию в методе CHANGE_INITIAL с заполнением поля VPTNR

Для примера:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Логика внутри метода FILL_FCV_VPTNR:
1) Проверяем что расширение вызывается из программы переоценки (GLVOR = RFBU, AWTYP = BKPFF, BTTYPE и CBTTYPE = RFCV)
2) Отбрасываем позиции PL счетов(на основании T030H), на мой взгляд это опционально и можно вынести выборку из T030H в конструктор класса. 
3) Находим контрагента из оригинального документа по ссылке в sgtxt
4) Замещаем поле cs_document_sub-item[]-vptnr нужным значением

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

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

**PS**. История переоценки хранится в таблице **FAGL_BSBW_HISTRY**.

Для анализа переоценки есть стандартный отчет из локализации РФ - **J3RFREVHISTFC**

Полезные ноты:

SAP KBA [1523296](https://service.sap.com/sap/support/notes/1523296) - FAGL_FC_VAL, FAGL_FCV and SAPF100 Account determination KDB or KDF

SAP KBA [2061774](https://service.sap.com/sap/support/notes/2061774) - How to use parameter NO_T030H to avoid read table T030H

SAP Note [2030975](https://service.sap.com/sap/support/notes/2030975) - FAGL_FCV: Account determination for G/L balances only from table T030S