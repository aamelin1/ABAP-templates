---
title: "Создание CDS и отчёты IDA (ALV on HANA)"
keywords: CDS, Core Data Services, IDA, Integrated Data Access, CL_SALV_GUI_TABLE_IDA, create_for_cds_view, ALV on HANA, DDL, Eclipse ADT, CL_SALV_RANGE_TAB_COLLECTOR, text search, hotspot, layout, SALV_IDA, Note 3196994
status: ok
source:
  - 90-source-code/zfi_ida_template.abap
  - 90-source-code/alv_ida_cds.abap
  - 90-source-code/alv_ida_template_sscr_alv.abap
  - 90-source-code/alv_ida_template_sscr_same_page.abap
  - 90-source-code/zfi_glrep_items_ida.abap
---

# Создание CDS и отчёты IDA (ALV on HANA)

# Что такое CDS и чем они могут быть полезны?

CDS расшифровывается как **Core Data Services**. 
Это функционал, позволяющий создавать представления/ракурсы данных посредством языка **DDL (Data Definition Language)**.

Простым языком - вы можете создать свой ракурс на основании соединений таблиц SAP с дополнительной логикой заполнения полей в этом ракурсе.

Например взять одну таблицу как основной источник, обогатить ее данными из связанных таблиц (например через соединения join/association) и добавить логику для заполнения отдельных столбцов в создаваемом ракурсе. В итоге получить ракурс с нужными вам данными и далее работать с ним напрямую, например делать выборки в abap программах или визуализировать через инструменты SAP, например через IDA или кастомное Fiori приложение через odata.

[Описание CDS от SAP](https://help.sap.com/docs/btp/sap-abap-cds-development-user-guide/abap-cds-entities?locale=en-US)

# Что такое IDA aka ALV on HANA?
IDA - Это инструмент визуализации данных в SAP GUI, расшифровывается как SAP List Viewer with **Integrated Data Access**. Иногда его называют ALV on HANA.

Основная суть инструмента - в него можно передать название CDS и дополнительные ограничения (а не готовую внутреннюю таблицу как в случае с классическим ALV), система выберет нужные данные и выведет их в виде таблицы, визуально похожей на ALV Grid, но более функциональную. 

Преимущества IDA:
* Построение иерархий, т.е. вложенных уровней и подсуммирования по ним
* Доступны все стандартные функции ALV (кроме редактирования и части форматирования)
* Большая производительность на больших данных (т.к. не требует предвыборки всех данных)
* Возможность использование текстового поиска
* Возможность добавления полей не из CDS (расчетные поля)

Основные отличия IDA от классического ALV Grid 

|   | SAP List Viewer  |  ALV with IDA |
|---|---|---|
| Выборка данных  | Выборка данных производится до вывода ALV, сначала все данные должны быть сохранены во внутреннюю таблицу (ITAB) | При вызове IDA достаточно передать только название таблицы/CDS, все выборки производятся средствами IDA  |
| Потребление памяти | В памяти хранится вся отображаемая внутренняя таблица ITAB  | В памяти хранится только видимая часть таблицы  |
| Производительность  | Сначала выбираются все данные для внутренней таблице, потом все данные передаются для вывода на экран  | Выборка и передача только видимой части данных  |
| Пролистывание отчета  | Обработка только на стороне сервера приложений/презентаций, не нужны запросы к БД  | При пролистывании вызываются новые выборки из БД для новых данных  |
| Сортировка, фильтрация, суммирование итд  | На уровне сервера приложений по данным ITAB, при этом обрабатывается весь объем данных  | Вызывается новая выборка из БД, если используются суммы/подсуммы, то агрегация так же выполняется на уровне БД HANA  |


[Описание IDA от SAP](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_FOR_SOH_740/b1c834a22d05483b8a75710743b5ff26/efeb734c8e6f41939c39fa15ce51eb4e.html)

# Как это работает?

## Предпосылки
* У вас должна быть относительно свежая система SAP S/4HANA
* Установлен [Eclipse](https://www.eclipse.org/downloads/)
* В Eclipse установлен плагин ADT, см [SAP Dev Tools](https://tools.eu1.hana.ondemand.com/)
* В Eclipse настроено подключение к системе разработки SAP
* Вы хотите сделать отчет на основе данных из SAP используя новые функции S/4HANA

Полезные ссылки:

[Installing ABAP Development Tools](https://help.sap.com/doc/2e9cf4a457d84c7a81f33d8c3fdd9694/Cloud/en-US/inst_guide_abap_development_tools.pdf)

[Configuring the ABAP Back-end for ABAP Development Tools](https://help.sap.com/doc/2e65ad9a26c84878b1413009f8ac07c3/201909.001/en-US/config_guide_system_backend_abap_development_tools.pdf)

## Создание простой CDS
Приступим к созданию простой CDS.
Для этого открываем Eclipse, выбираем нужную систему (систему разработки и нужный мандант), переходим в наш Z пакет (удобно добавить его в избранное для быстрого доступа) и нажимаем правой кнопкой по названию пакета и создаем новый объект

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Выбираем **core data services->data definition**

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Указываем имя новой CDS

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

И создаем новый транспортный запрос

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Должна появится заготовка для CDS вида:
```abap
@AbapCatalog.sqlViewName: ''
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'test CDS'
define view ZVFI_TEST as select from data_source_name
association [1] to target_data_source_name as _association_name
    on $projection.element_name = _association_name.target_element_name {
    
    _association_name // Make association public
}
```

Для примера сделаем CDS с данными по плану счетов и текстами сразу на двух языках. Т.е. нам нужны будут таблицы 
* SKA1 (данные счетов ГК)
* SKAT (текстовая таблица)

Между собой таблицы связаны по полям ktopl и saknr. В skat-spras есть еще ключевое поле spras с языком для текстов.

И итоговая таблица должна быть, допустим, со столбцами:
* ПСч (SKA1-KTOPL)
* Счет (SKA1-SAKNR)
* Название на английском языке (SKAT-TXT50, где SPRAS = EN)
* Название на португальском языке (SKAT-TXT50, где SPRAS = PT)

Сначала зададим имя CDS для репозитария (sqlViewName), по этому имени можно будет получить доступ к ракурсу например в se16n. Для этого заполним его в первой строке:

@AbapCatalog.sqlViewName: '**ZVRFI_TEST**'

Далее добавим условия соединений таблиц SKA1 и SKAT и определим нужные нам поля в ракурсе, сначала для английского языка в SAKT, должно получится что-то вроде этого:

```abap
define view ZVFI_TEST as select from SKA1
association [1..1] to skat as _skat_en  
    on ska1.ktopl = _skat_en.ktopl
    and ska1.saknr = _skat_en.saknr
    and _skat_en.spras = 'E'
{
    key SKA1.ktopl as Ktopl,
    key SKA1.saknr as Saknr,
    _skat_en.txt50
}
```

Активируем нашу CDS и проверим как это работает. Проверить можно двумя способами:
1. Напрямую в Eclipse нажать F8 и посмотреть результат:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

2. Зайти в SAP GUI и запустить se16, se16n, se16h итд

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

После того, как мы убедились что все работает - добавим тексты на португальском языке:

```abap
define view ZVFI_TEST as select from ska1
association [1..1] to skat as _skat_en  
    on ska1.ktopl = _skat_en.ktopl
    and ska1.saknr = _skat_en.saknr
    and _skat_en.spras = 'E'
association [1..1] to skat as _skat_pt  
    on ska1.ktopl = _skat_pt.ktopl
    and ska1.saknr = _skat_pt.saknr
    and _skat_pt.spras = 'P'
{
    key ska1.ktopl as Ktopl,
    key ska1.saknr as Saknr,
    _skat_en.txt50 as en_txt50,
    _skat_pt.txt50 as pt_txt50
}
```

Проверим:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Все работает. Для простого примера на этом остановимся и перейдем к визуализации данных с помощью IDA.
Детальней про возможности CDS можно почитать [тут](https://help.sap.com/docs/btp/sap-abap-cds-development-user-guide/abap-cds-entities?locale=en-US)

## Создание отчета на основе CDS с помощью IDA

Создадим новую программу в se38. В ней вызываем **create_for_cds_view->fullscreen->display** в классе **CL_SALV_GUI_TABLE_IDA**, в параметр iv_cds_view_name подставляем имя нашей CDS, т.е. так, всего одна строка кода:

```abap
REPORT ZFI_TEST_CDS.
cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = 'ZVFI_TEST' )->fullscreen( )->display( ).
```
Активируем и проверяем что получилось, запускаем отчет (F8), получаем:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Все работает, данные из нашей CDS отображаются в отчете.

Обычно, все же, нам нужен еще и селекционный экран, где мы могли бы указать какие то ограничения. Пусть в нашем примере ограничением будут поля:
* ПСч (SKA1-KTOPL)
* Счет (SKA1-SAKNR)

Для этого добавим в программу блок с селекционным экраном и этими полями
```abap
TABLES: ZVRFI_TEST.

SELECT-OPTIONS so_ktopl FOR ZVRFI_TEST-ktopl.
SELECT-OPTIONS so_saknr FOR ZVRFI_TEST-saknr.
```

И передадим ограничения с селекционного экрана в IDA, в итоге получим:
```abap
REPORT ZFI_TEST_CDS.
TABLES: ZVRFI_TEST.

SELECT-OPTIONS so_ktopl FOR ZVRFI_TEST-ktopl.
SELECT-OPTIONS so_saknr FOR ZVRFI_TEST-saknr.

START-OF-SELECTION.
  DATA(o_ida) = cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = 'ZVFI_TEST' ).
  "Формируем ограничения копируя диапазоны с сел экрана
  DATA(o_sel) = NEW cl_salv_range_tab_collector( ).
  o_sel->add_ranges_for_name( iv_name = 'KTOPL' it_ranges = so_ktopl[] ).
  o_sel->add_ranges_for_name( iv_name = 'SAKNR' it_ranges = so_saknr[] ).
  o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_sel_crit) ).
  o_ida->set_select_options( it_ranges = lt_sel_crit ).
  "Вывод АЛВ на экран
  o_ida->fullscreen( )->display( ).
```

В результате получим, селекционный экран при запуске:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Отчет с учетом ограничений с селекционного экрана:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

Получили уже почти хороший отчет. Но, раз уж мы используем новые инструменты, то добавим красоты в отчет:
* Переименуем столбы для текстов
* Добавим быстрый выбор вариантов (layout)
* Добавим выбор варианта (layout) на селекционный экран
* Добавим полнотекстовый поиск по наименованием счетов
* Добавим проваливание (hotspot) в мастер данные счета (тр. **FSP0**)

```abap
*&---------------------------------------------------------------------*
*& Report ZFI_TEST_CDS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_TEST_CDS.
TABLES: ZVRFI_TEST.

SELECT-OPTIONS so_ktopl FOR ZVRFI_TEST-ktopl.
SELECT-OPTIONS so_saknr FOR ZVRFI_TEST-saknr.
"Добавим поле с layout на сел экран
PARAMETERS: p_layout TYPE if_salv_gui_layout_persistence=>y_layout_name.

**********************************************************************
CLASS lcl_event_handler DEFINITION .
  PUBLIC SECTION .
    METHODS:
      handle_hot_spot FOR EVENT cell_action OF if_salv_gui_field_display_opt
        IMPORTING ev_field_name
                  eo_row_data.
  PRIVATE SECTION.
ENDCLASS.
**********************************************************************
CLASS lcl_event_handler IMPLEMENTATION .
  METHOD handle_hot_spot.
    DATA: ls_wa TYPE ZVRFI_TEST.
    TRY.
        eo_row_data->get_row_data(
              EXPORTING iv_request_type = if_salv_gui_selection_ida=>cs_request_type-all_fields
              IMPORTING es_row          =  ls_wa ).
*        Hotspot actions
        CASE ev_field_name.
          WHEN 'SAKNR'.
            SET PARAMETER ID 'SAK' FIELD ls_wa-saknr.
            SET PARAMETER ID 'KPL' FIELD ls_wa-ktopl.
            CALL TRANSACTION 'FSP0'.
          WHEN OTHERS.
        ENDCASE.
      CATCH cx_salv_ida_contract_violation
              cx_salv_ida_sel_row_deleted.
    ENDTRY.
  ENDMETHOD.
ENDCLASS .


INITIALIZATION.
 DATA ls_persistence_key TYPE if_salv_gui_layout_persistence=>ys_persistence_key.
 ls_persistence_key-report_name = sy-repid.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  cl_salv_gui_grid_utils_ida=>f4_for_layouts( EXPORTING is_persistence_key = ls_persistence_key
                                              IMPORTING es_selected_layout = DATA(ls_selected_layout) ).
  p_layout = ls_selected_layout-name.

START-OF-SELECTION.
  DATA(o_ida) = cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = 'ZVFI_TEST' ).

  "Формируем ограничения копируя диапазоны с сел экрана
  DATA(o_sel) = NEW cl_salv_range_tab_collector( ).
  o_sel->add_ranges_for_name( iv_name = 'KTOPL' it_ranges = so_ktopl[] ).
  o_sel->add_ranges_for_name( iv_name = 'SAKNR' it_ranges = so_saknr[] ).
  o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_sel_crit) ).
  o_ida->set_select_options( it_ranges = lt_sel_crit ).

  "Поменяем название столбцов
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'EN_TXT50' iv_header_text   = 'EN Name' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'PT_TXT50' iv_header_text   = 'PT Name' ).

  "Включаем поиск по текстовым полям
  o_ida->standard_functions( )->set_text_search_active( abap_true ).
  o_ida->field_catalog( )->enable_text_search( 'EN_TXT50' ).
  o_ida->field_catalog( )->enable_text_search( 'PT_TXT50' ).

  "установим режимы layout
  o_ida->layout_persistence( )->set_persistence_options( is_persistence_key = VALUE #( report_name = sy-repid )
                                                         i_global_save_allowed = abap_true
                                                         i_user_specific_save_allowed = abap_true ).
  o_ida->toolbar( )->enable_listbox_for_layouts( ). "включим выпадающий список вариантов
  if p_layout is not initial. "установим layout с селекционного экрана
    try.
         o_ida->layout_persistence( )->set_start_layout( p_layout ).
      catch cx_salv_ida_unknown_name.
        message i000(0k) with |Layout { p_layout } unknown - continue w/o start| | layout...|.
    endtry.
  endif.

  "Добавим обработчик проваливаний
  TRY.
    DATA: gr_event_handler TYPE REF TO lcl_event_handler.
    CREATE OBJECT gr_event_handler.
    o_ida->field_catalog( )->display_options( )->display_as_link_to_action( 'SAKNR' ).
    SET HANDLER gr_event_handler->handle_hot_spot FOR o_ida->field_catalog( )->display_options( ).
  CATCH cx_salv_ida_unknown_name cx_salv_call_after_1st_display.
  ENDTRY.

  "Вывод АЛВ на экран
  o_ida->fullscreen( )->display( ).
```

Что получили в итоге, обычный селекционный экран (добавили только поле с вариантами):

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

В самом отчете переименовались колонки и появились новые функции:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

По сравнению с классическим ALV:
* Текстовый поиск (два механизм: search и fuzzy search), пример как работает:

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

* Быстрый выбор вариантов (layout), в тулбаре наверху появился выпадающий список с сохраненными вариантами (я предсохранил варианты ttt и ttt2):

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

В некоторых версиях системы есть ошибка с сохранением вариантов, лечится нотой 3196994 - "IDA-ALV - ALV Layout not being saved"

* Механизм группировок (на мой взгляд это очень удобный функционал)

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_

С помощью него можно выстраивать любые иерархии в отчетах (по нескольким полям сразу), делать подсуммы итд. Пример двухуровневой иерархии, первый уровень - план счетов, второй уровень - счет и его название (через слэш):

> 🖼️ _(скриншот отсутствует — оригинал был во вложениях GitHub, добавить вручную)_



Дополнительно про IDA можно почитать [тут](https://help.sap.com/doc/saphelp_nw74/7.4.16/en-us/ef/eb734c8e6f41939c39fa15ce51eb4e/frameset.htm)

Или посмотреть в системе примеры программ по маске **SALV_IDA***


---
**Исходный код:**
- [ZFI_IDA_template.abap](../90-source-code/zfi_ida_template.abap)
- [ALV_IDA_CDS.abap](../90-source-code/alv_ida_cds.abap) — пример CDS
- [ALV_IDA_template(SSCR_ALV)](../90-source-code/alv_ida_template_sscr_alv.abap), [ALV_IDA_template (SSCR on same page)](../90-source-code/alv_ida_template_sscr_same_page.abap)
- [ZFI_GLREP_ITEMS (IDA)](../90-source-code/zfi_glrep_items_ida.abap) — отчёт по позициям ГК на CDS
