*&---------------------------------------------------------------------*
*& Report ZFI_ACDOCA_IDA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_ACDOCA_IDA.
TABLES ACDOCA.
DATA lo_docking_container TYPE REF TO cl_gui_docking_container.
**********************************************************************
"Селекционный экран
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS so_bukrs FOR ACDOCA-RBUKRS no INTERVALS DEFAULT '1000'.
SELECT-OPTIONS so_RLDNR FOR ACDOCA-RLDNR NO INTERVALS DEFAULT '0L'.
SELECT-OPTIONS so_RACCT FOR ACDOCA-RACCT.
SELECT-OPTIONS so_BUDAT FOR ACDOCA-BUDAT.

SELECTION-SCREEN END OF BLOCK bl1.

INITIALIZATION.


AT SELECTION-SCREEN OUTPUT.
  data(extension) = sy-srows * 17.
  IF lo_docking_container IS NOT BOUND.
    lo_docking_container = NEW #( repid     = sy-repid
                                  dynnr     = sy-dynnr
                                  side      = cl_gui_docking_container=>dock_at_bottom
                                  metric    = cl_gui_docking_container=>metric_pixel
                                  extension = extension
                                  ).



    "Инициализация АЛВ_ИДА
    data: lo_exc type ref to cx_salv_function_not_supported.
    try.
        DATA(o_ida) = cl_salv_gui_table_ida=>create_for_cds_view( IV_CDS_VIEW_NAME = 'ZFI_ACDOCA_ADD3'
                                                                  io_gui_container = lo_docking_container ).
      catch cx_salv_function_not_supported into lo_exc.
        message lo_exc type 'I'.
    endtry.
******Параметры CDS
***    if cl_abap_dbfeatures=>use_features(
***          requested_features =
***               VALUE #( ( cl_abap_dbfeatures=>views_with_parameters ) ) ) eq abap_true.
***      o_ida->set_view_parameters( value #( ( name = 'st_date' value = so_BUDAT-low ) ) ).
***    endif.


***Функции ALV
    o_ida->layout_persistence( )->set_persistence_options( is_persistence_key = VALUE #( report_name = sy-repid )
                                                                  i_global_save_allowed = abap_true
                                                                  i_user_specific_save_allowed = abap_true ).
    o_ida->toolbar( )->enable_listbox_for_layouts( ).
    o_ida->standard_functions( )->set_text_search_active( abap_true ).
*    o_ida->standard_functions( )->SET_EXPORT_ACTIVE( abap_true ).
*    o_ida->standard_functions( )->SET_PRINT_ACTIVE( abap_true ).
*    o_ida->standard_functions( )->SET_FILTER_ACTIVE( abap_true ).
*    o_ida->standard_functions( )->SET_SORT_ACTIVE( abap_true ).
*    o_ida->standard_functions( )->SET_DETAIL_ACTIVE( abap_true ).
*    o_ida->standard_functions( )->SET_AGGREGATION_ACTIVE( abap_true ).


**********************************************************************
    DATA(o_sel) = new cl_salv_range_tab_collector( ).
    "Формируем ограничения копируя диапазоны с сел экрана
    o_sel->add_ranges_for_name( iv_name = 'RBUKRS' it_ranges = so_bukrs[] ).

    o_sel->add_ranges_for_name( iv_name = 'RLDNR' it_ranges = so_RLDNR[] ).
    o_sel->add_ranges_for_name( iv_name = 'BUDAT' it_ranges = so_BUDAT[] ).
    o_sel->add_ranges_for_name( iv_name = 'RACCT' it_ranges = so_RACCT[] ).
    o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_sel_crit) ).
    "Ограничения выборки из БД
    o_ida->set_select_options( it_ranges = lt_sel_crit ).

**********************************************************************
    "Формируем филдкаталог (если не указать, то выводятся все поля)
***    DATA lt_fcat TYPE IF_SALV_GUI_TYPES_IDA=>YTS_FIELD_NAME.
***    lt_fcat = VALUE #(
***    ( CONV string('RBUKRS') )
***    o_ida->field_catalog( )->set_available_fields( EXPORTING its_field_names = lt_fcat ).
    "Поля валюты/кол-ва
    o_ida->field_catalog( )->set_currency_reference_field( iv_amount_field_name   = 'HSL'
                                                           iv_currency_field_name = 'RHCUR' ).
**********************************************************************
    "Включаем поиск по текстовым полям
    o_ida->field_catalog( )->enable_text_search( 'SGTXT' ).
    o_ida->field_catalog( )->enable_text_search( 'TXT50' ).
    o_ida->field_catalog( )->enable_text_search( 'ZZPARTNER' ).
    o_ida->field_catalog( )->enable_text_search( 'ZZCONTRACT' ).
*    o_ida->field_catalog( )->enable_text_search( 'BPNAME' ).
    o_ida->field_catalog( )->enable_text_search( 'RECNTXT' ).
    o_ida->field_catalog( )->enable_text_search( 'RECNNREXT' ).
    o_ida->field_catalog( )->enable_text_search( 'TEXT' ).
    o_ida->field_catalog( )->enable_text_search( 'OSTXT' ).
    o_ida->field_catalog( )->enable_text_search( 'LTEXT' ).
    o_ida->field_catalog( )->enable_text_search( 'KTEXT' ).
    o_ida->field_catalog( )->enable_text_search( 'PCTXT' ).
**********************************************************************
    " Сортировки и группировки
    o_ida->default_layout( )->set_sort_order( VALUE #(
    ( field_name = 'RACCT' is_grouped = abap_false  )
    ( field_name = 'TXT50' is_grouped = abap_true  )
*  ( field_name = 'DRCRK' is_grouped = abap_true  )
    ) ).
    " И суммирование
    data ls_aggr_rule  type if_salv_gui_types_ida=>ys_aggregation_rule.
    data lt_aggr_rules type if_salv_gui_types_ida=>yt_aggregation_rule.
    ls_aggr_rule-field_name = 'HSL'.
    ls_aggr_rule-function = if_salv_service_types=>cs_function_code-sum.
    append ls_aggr_rule to lt_aggr_rules.
    try.
        o_ida->default_layout( )->set_aggregations( lt_aggr_rules ).
      catch cx_salv_ida_contract_violation.
        MESSAGE 'Что то пошло не так)' TYPE 'E'.
    endtry.
**********************************************************************
  ENDIF.
