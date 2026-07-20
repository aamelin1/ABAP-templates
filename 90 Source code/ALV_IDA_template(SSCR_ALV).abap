*&---------------------------------------------------------------------*
*& Report ZAA_TRY_IDA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZAA_TRY_IDA.

TABLES ANLA.

**********************************************************************
"Селекционный экран
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS so_bukrs FOR ANLA-BUKRS no INTERVALS DEFAULT '1000'.
SELECT-OPTIONS so_anlkl FOR anla-anlkl .
SELECT-OPTIONS so_anln1 FOR anla-anln1 .
SELECT-OPTIONS so_anln2 FOR anla-anln2 DEFAULT '0000'.
SELECTION-SCREEN END OF BLOCK bl1.

END-OF-SELECTION.
**********************************************************************
  "Инициализация АЛВ_ИДА
  DATA(o_ida) = cl_salv_gui_table_ida=>create( iv_table_name = 'ANLA' ).
  DATA(o_sel) = new cl_salv_range_tab_collector( ).

**********************************************************************
  "Формируем ограничения копируя диапазоны с сел экрана
  o_sel->add_ranges_for_name( iv_name = 'BUKRS' it_ranges = so_bukrs[] ).
  o_sel->add_ranges_for_name( iv_name = 'ANLKL' it_ranges = so_anlkl[] ).
  o_sel->add_ranges_for_name( iv_name = 'ANLN1' it_ranges = so_anln1[] ).
  o_sel->add_ranges_for_name( iv_name = 'ANLN2' it_ranges = so_anln2[] ).
  o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_sel_crit) ).
  "Ограничения выборки из БД
  o_ida->set_select_options( it_ranges = lt_sel_crit ).

**********************************************************************
  "Формируем филдкаталог (если не указать, то выводятся все поля)
  DATA lt_fcat TYPE IF_SALV_GUI_TYPES_IDA=>YTS_FIELD_NAME.
  lt_fcat = VALUE #(
  ( CONV string('BUKRS') )
  ( CONV string('ANLN1') )
  ( CONV string('ANLN2') )
  ( CONV string('ANLKL') )
  ( CONV string('TXT50') )
  ( CONV string('AKTIV') )
  ( CONV string('DEAKT') ) ).
  o_ida->field_catalog( )->set_available_fields( EXPORTING its_field_names = lt_fcat ).
  "Поля валюты/кол-ва
  "o_ida->field_catalog( )->set_currency_reference_field( iv_amount_field_name   = 'HSL'
  "                                                      iv_currency_field_name = 'RHCUR' ).
**********************************************************************
  "Включаем поиск по текстовым полям
  o_ida->standard_functions( )->set_text_search_active( abap_true ).
  o_ida->field_catalog( )->enable_text_search( 'TXT50' ).

**********************************************************************
  " Сортировки и группировки
  o_ida->default_layout( )->set_sort_order( VALUE #(
  ( field_name = 'ANLKL' is_grouped = abap_true  ) ) ).
  " И суммирование
  "data ls_aggr_rule  type if_salv_gui_types_ida=>ys_aggregation_rule.
  "data lt_aggr_rules type if_salv_gui_types_ida=>yt_aggregation_rule.
  "ls_aggr_rule-field_name = 'HSL'.
  "ls_aggr_rule-function = if_salv_service_types=>cs_function_code-sum.
  "append ls_aggr_rule to lt_aggr_rules.
  "try.
  "    o_ida->default_layout( )->set_aggregations( lt_aggr_rules ).
  "  catch cx_salv_ida_contract_violation.
  "    MESSAGE 'Что то пошло не так)' TYPE 'E'.
  " endtry.
**********************************************************************
  "Вывод АЛВ на экран
  o_ida->fullscreen( )->display( ).
