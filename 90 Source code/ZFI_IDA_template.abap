*&---------------------------------------------------------------------*
*& Report ZFI_IDA_template
*&---------------------------------------------------------------------*
*& ALV IDA template (for CDS) (Amelin A)
*&---------------------------------------------------------------------*
REPORT ZFI_IDA_template.
TABLES: ZVRFI_TEST.

SELECT-OPTIONS so_ktopl FOR ZVRFI_TEST-ktopl.
SELECT-OPTIONS so_saknr FOR ZVRFI_TEST-saknr.
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

  "Copy selection restriction from sscr
  DATA(o_sel) = NEW cl_salv_range_tab_collector( ).
  o_sel->add_ranges_for_name( iv_name = 'KTOPL' it_ranges = so_ktopl[] ).
  o_sel->add_ranges_for_name( iv_name = 'SAKNR' it_ranges = so_saknr[] ).
  o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_sel_crit) ).
  o_ida->set_select_options( it_ranges = lt_sel_crit ).

  "Change column headers
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'EN_TXT50' iv_header_text   = 'EN Name' ).
  o_ida->field_catalog( )->set_field_header_texts( iv_field_name    = 'PT_TXT50' iv_header_text   = 'PT Name' ).

  "Enable text search
  o_ida->standard_functions( )->set_text_search_active( abap_true ).
  o_ida->field_catalog( )->enable_text_search( 'EN_TXT50' ).
  o_ida->field_catalog( )->enable_text_search( 'PT_TXT50' ).

  "layouts
  o_ida->layout_persistence( )->set_persistence_options( is_persistence_key = VALUE #( report_name = sy-repid )
                                                         i_global_save_allowed = abap_true
                                                         i_user_specific_save_allowed = abap_true ).
  o_ida->toolbar( )->enable_listbox_for_layouts( ). "layout droplist on
  if p_layout is not initial. "def layout
    try.
         o_ida->layout_persistence( )->set_start_layout( p_layout ).
      catch cx_salv_ida_unknown_name.
        message i000(0k) with |Layout { p_layout } unknown - continue w/o start| | layout...|.
    endtry.
  endif.

  "Handlers
  TRY.
    DATA: gr_event_handler TYPE REF TO lcl_event_handler.
    CREATE OBJECT gr_event_handler.
    o_ida->field_catalog( )->display_options( )->display_as_link_to_action( 'SAKNR' ).
    SET HANDLER gr_event_handler->handle_hot_spot FOR o_ida->field_catalog( )->display_options( ).
  CATCH cx_salv_ida_unknown_name cx_salv_call_after_1st_display.
  ENDTRY.

  "Show ALV
  o_ida->fullscreen( )->display( ). 