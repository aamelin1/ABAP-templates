*&---------------------------------------------------------------------*
*& Report ZFI_GLREP_ITEMS
*&---------------------------------------------------------------------*
*& GL item IDA report based on CDS ZVFI_ACDOC_I/ZVFI_ACDOC_ITEMS (Amelin A. 02/2023)
*&---------------------------------------------------------------------*
REPORT zfi_glrep_items.
TABLES: zvfi_acdoc_i.
**********************************************************************
"Селекционный экран
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS so_bukrs FOR zvfi_acdoc_i-rbukrs NO INTERVALS MEMORY ID buk.
  SELECT-OPTIONS so_RLDNR FOR zvfi_acdoc_i-rldnr DEFAULT '0L'.
  SELECT-OPTIONS so_budat FOR zvfi_acdoc_i-budat NO-EXTENSION OBLIGATORY.
  SELECT-OPTIONS so_st FOR zvfi_acdoc_i-status no-DISPLAY.
  PARAMETERS p_sb AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK bl1.

PARAMETERS: p_layout TYPE if_salv_gui_layout_persistence=>y_layout_name.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS so_werks FOR zvfi_acdoc_i-werks.
  SELECT-OPTIONS so_matnr FOR zvfi_acdoc_i-matnr.
  SELECT-OPTIONS so_lifnr FOR zvfi_acdoc_i-lifnr.
  SELECT-OPTIONS so_kunnr FOR zvfi_acdoc_i-kunnr.
  SELECT-OPTIONS so_ptnr  FOR zvfi_acdoc_i-partner MATCHCODE OBJECT BUPA.
  SELECT-OPTIONS so_anln1 FOR zvfi_acdoc_i-anln1.
  SELECT-OPTIONS so_blart FOR zvfi_acdoc_i-blart.
  SELECT-OPTIONS so_belnr FOR zvfi_acdoc_i-belnr.
SELECTION-SCREEN END OF BLOCK bl2.




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
    DATA: ls_wa TYPE zvfi_acdoc_i.
    TRY.
        eo_row_data->get_row_data(
              EXPORTING iv_request_type = if_salv_gui_selection_ida=>cs_request_type-all_fields
              IMPORTING es_row          =  ls_wa ).
*        Hotspot actions
        CASE ev_field_name.
          WHEN 'BELNR'.
            SET PARAMETER ID 'BLN' FIELD ls_wa-belnr.
            SET PARAMETER ID 'BUK' FIELD ls_wa-rbukrs.
            SET PARAMETER ID 'GJR' FIELD ls_wa-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          WHEN 'AWKEY'.
            CALL FUNCTION 'AC_DOCUMENT_SENDER'
              EXPORTING
                i_awsys = ls_wa-awsys
                i_awtyp = ls_wa-awtyp
                i_awref = ls_wa-awkey+00(10)
                i_aworg = ls_wa-awkey+10(10)
                i_bukrs = ls_wa-rbukrs.
          WHEN OTHERS.
        ENDCASE.
      CATCH cx_salv_ida_contract_violation
              cx_salv_ida_sel_row_deleted.
    ENDTRY.
  ENDMETHOD.
ENDCLASS .

**********************************************************************
INITIALIZATION.
 DATA ls_persistence_key TYPE if_salv_gui_layout_persistence=>ys_persistence_key.
  ls_persistence_key-report_name = sy-repid.
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  PERFORM f4_for_variant CHANGING p_layout.

**********************************************************************
END-OF-SELECTION.
  "Инициализация АЛВ_ИДА
  DATA(o_ida) = cl_salv_gui_table_ida=>create_for_cds_view( iv_cds_view_name = 'ZVFI_ACDOC_ITEMS' ).
  o_ida->set_view_parameters( it_parameters =  VALUE #( (  name = 'ST_DATE' value = so_budat-low ) ) ) .
  DATA(o_sel) = NEW cl_salv_range_tab_collector( ).
**********************************************************************
  "Формируем ограничения копируя диапазоны с сел экрана
  o_sel->add_ranges_for_name( iv_name = 'RBUKRS' it_ranges = so_bukrs[] ).
  o_sel->add_ranges_for_name( iv_name = 'RLDNR' it_ranges = so_RLDNR[] ).
  o_sel->add_ranges_for_name( iv_name = 'WERKS' it_ranges = so_werks[] ).
  o_sel->add_ranges_for_name( iv_name = 'MATNR' it_ranges = so_matnr[] ).
  o_sel->add_ranges_for_name( iv_name = 'LIFNR' it_ranges = so_lifnr[] ).
  o_sel->add_ranges_for_name( iv_name = 'KUNNR' it_ranges = so_kunnr[] ).
  o_sel->add_ranges_for_name( iv_name = 'PARTNER' it_ranges = so_ptnr[] ).
  o_sel->add_ranges_for_name( iv_name = 'ANLN1' it_ranges = so_anln1[] ).
  o_sel->add_ranges_for_name( iv_name = 'BLART' it_ranges = so_blart[] ).
  o_sel->add_ranges_for_name( iv_name = 'BELNR' it_ranges = so_belnr[] ).
  IF p_sb ne 'X'.
    READ TABLE so_budat ASSIGNING FIELD-SYMBOL(<fs_b>) INDEX 1.
    <fs_b>-low = so_budat-low = '00000000'.
    UNASSIGN <fs_b>.
  ENDIF.
  o_sel->add_ranges_for_name( iv_name = 'BUDAT' it_ranges = so_budat[] ).
  o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_sel_crit) ).
  o_ida->set_select_options( it_ranges = lt_sel_crit ).
**********************************************************************
  o_ida->layout_persistence( )->set_persistence_options( is_persistence_key = VALUE #( report_name = sy-repid )
                                                         i_global_save_allowed = abap_true
                                                         i_user_specific_save_allowed = abap_true ).
  o_ida->toolbar( )->enable_listbox_for_layouts( ).
**********************************************************************
  "Поля валюты/кол-ва
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'TSL_ST' iv_header_text   = 'T:SB' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'TSL_DR' iv_header_text   = 'T:Dr' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'TSL_CR' iv_header_text   = 'T:Cr' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'TSL'    iv_header_text   = 'T:EB' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'HSL_ST' iv_header_text   = 'C:SB' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'HSL_DR' iv_header_text   = 'C:Dr' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'HSL_CR' iv_header_text   = 'C:Cr' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'HSL'    iv_header_text   = 'C:EB' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'KSL_ST' iv_header_text   = 'G:SB' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'KSL_DR' iv_header_text   = 'G:Dr' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'KSL_CR' iv_header_text   = 'G:Cr' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'KSL'    iv_header_text   = 'G:EB' ).
**********************************************************************
  "Включаем поиск по текстовым полям
  o_ida->standard_functions( )->set_text_search_active( abap_true ).
  o_ida->field_catalog( )->enable_text_search( 'SGTXT' ).
  o_ida->field_catalog( )->enable_text_search( 'BKTXT' ).
**********************************************************************
  TRY.
      DATA: gr_event_handler TYPE REF TO lcl_event_handler.
      CREATE OBJECT gr_event_handler.
      o_ida->field_catalog( )->display_options( )->display_as_link_to_action( 'BELNR' ).
      o_ida->field_catalog( )->display_options( )->display_as_link_to_action( 'AWKEY' ).
      SET HANDLER gr_event_handler->handle_hot_spot FOR o_ida->field_catalog( )->display_options( ).
    CATCH cx_salv_ida_unknown_name cx_salv_call_after_1st_display.
  ENDTRY.
*   set start layout
  if p_layout is not initial.
    try.
         o_ida->layout_persistence( )->set_start_layout( p_layout ).
      catch cx_salv_ida_unknown_name.
        message i000(0k) with |Layout { p_layout } unknown - continue w/o start| | layout...|  ##EC_NOTEXT.
    endtry.
  endif.
**********************************************************************
  "Вывод АЛВ на экран
  o_ida->fullscreen( )->display( ).


*----------------------------------------------------------------------*
FORM f4_for_variant CHANGING c_variant TYPE disvariant-variant.
*----------------------------------------------------------------------*
  cl_salv_gui_grid_utils_ida=>f4_for_layouts( EXPORTING is_persistence_key = ls_persistence_key
                                              IMPORTING es_selected_layout = DATA(ls_selected_layout) ).
  c_variant = ls_selected_layout-name.
ENDFORM.
