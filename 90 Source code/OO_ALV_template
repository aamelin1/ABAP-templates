*&---------------------------------------------------------------------*
*& Report ZFI_CUST_TOT_REPS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_cust_tot_reps.
TABLES: acdoca.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_bukrs FOR acdoca-rbukrs MEMORY ID buk        NO INTERVALS NO-EXTENSION OBLIGATORY,
                  so_rldnr FOR acdoca-rldnr DEFAULT '0L'          NO INTERVALS NO-EXTENSION OBLIGATORY,
                  so_gjahr FOR acdoca-gjahr DEFAULT sy-datum+0(4) NO INTERVALS NO-EXTENSION OBLIGATORY,
                  so_poper FOR acdoca-poper DEFAULT sy-datum+4(2) NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl1.
PARAMETERS variant LIKE disvariant-variant.

**********************************************************************
DATA: lt_rep     TYPE STANDARD TABLE OF acdoca,
      gr_table   TYPE REF TO cl_salv_table,
      gx_variant TYPE disvariant.

**********************************************************************
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS:
      init,
      get_default_layout,
      f4_layouts,
      get_data,
      show_alv.
  PRIVATE SECTION.
    METHODS:
      set_pf_status CHANGING co_alv TYPE REF TO cl_salv_table,
      set_alv_lo    CHANGING co_alv TYPE REF TO cl_salv_table,
      set_fcat      CHANGING co_alv TYPE REF TO cl_salv_table.
ENDCLASS.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click      OF cl_salv_events_table IMPORTING row column,
      on_click      FOR EVENT added_function  OF cl_salv_events.
ENDCLASS.

**********************************************************************
INITIALIZATION.
  DATA: lo_report TYPE REF TO lcl_report.
  CREATE OBJECT lo_report.
  lo_report->init( ).

**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  lo_report->get_default_layout( ).

**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  lo_report->f4_layouts( ).

**********************************************************************
START-OF-SELECTION.
  lo_report->get_data( ).
  lo_report->show_alv( ).


**********************************************************************
CLASS lcl_report IMPLEMENTATION.
  METHOD init.
  ENDMETHOD.

  METHOD get_default_layout.
    CHECK variant IS INITIAL.
    gx_variant-report = sy-repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      CHANGING
        cs_variant = gx_variant
      EXCEPTIONS
        not_found  = 2.
    IF sy-subrc = 0.
      variant = gx_variant-variant.
    ENDIF.
  ENDMETHOD.

  METHOD  f4_layouts.
    DATA: g_exit    TYPE c,
          g_variant TYPE disvariant,
          g_save    TYPE c.
    CLEAR g_variant.
    g_variant-report = sy-repid.
    g_save = 'X'.
    CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
      EXPORTING
        is_variant         = g_variant
        i_save             = g_save
        i_display_via_grid = 'X'
      IMPORTING
        e_exit             = g_exit
        es_variant         = gx_variant
      EXCEPTIONS
        not_found          = 2.
    IF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF g_exit = space.
        variant = gx_variant-variant.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_data.
    SELECT *
      FROM acdoca INTO TABLE @lt_rep.
  ENDMETHOD.

  METHOD set_pf_status.
    co_alv->set_screen_status(
      pfstatus      =  'Z_ALV'
      report        =  sy-repid
      set_functions = co_alv->c_functions_all ).
  ENDMETHOD.

  METHOD set_alv_lo.
    DATA:
      key          TYPE salv_s_layout_key,
      header       TYPE lvc_title.
    key-report = sy-repid.
*---Setting the Layout Save property
    DATA(gr_layout) = co_alv->get_layout( ).
    gr_layout->set_key( key ).
    gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
    gr_layout->set_initial_layout( variant ).
*---Setting the list header
    DATA(gr_display) = co_alv->get_display_settings( ).
    header = |{ 'Company code: ' && so_bukrs-low && '. Period:' }| && |{ so_poper-low }|.
    gr_display->set_list_header( header ).
    gr_display->set_striped_pattern( abap_true ).
    gr_display->set_fit_column_to_table_size( abap_true ).
    DATA(oref_columns) = co_alv->get_columns( ).
    oref_columns->set_key_fixation( ).
  ENDMETHOD.

  METHOD set_fcat.
    DATA: lr_column TYPE REF TO cl_salv_column_table,
          ls_color  TYPE lvc_s_colo.

    DATA(lo_cols) = co_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ). "--> Optimise all columns
    TRY.
        DATA(lo_column) = lo_cols->get_column( 'BELNR' ).
        lo_column->set_long_text( 'test' ).
        lo_column->set_medium_text( 'test' ).
        lo_column->set_short_text( 'test' ).                    "
        lr_column ?= lo_cols->get_column( 'BELNR' ).
        ls_color-col = col_positive.
        lr_column->set_color( ls_color ).
        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.

  METHOD show_alv.
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = gr_table CHANGING t_table = lt_rep ).
      CATCH cx_salv_msg .
    ENDTRY.
    lo_report->set_pf_status( CHANGING co_alv = gr_table ).
    lo_report->set_alv_lo( CHANGING co_alv = gr_table ).
    lo_report->set_fcat( CHANGING co_alv = gr_table ).
*   Get the event object, instantiate the event handler object
    DATA(lo_events) = gr_table->get_event( ).
    DATA: lo_event_handler TYPE REF TO lcl_event_handler.
    CREATE OBJECT lo_event_handler.
    SET HANDLER lo_event_handler->on_link_click FOR lo_events.
    SET HANDLER lo_event_handler->on_click FOR lo_events.
*   Displaying the ALV
    gr_table->display( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_link_click.
    DATA: l_STABLE     TYPE lvc_s_stbl.
    l_stable-row = 'X'.
    l_stable-col = 'X'.
    FIELD-SYMBOLS: <f_data> LIKE LINE OF lt_rep.
    READ TABLE lt_rep ASSIGNING <f_data> INDEX row.
    CHECK sy-subrc IS INITIAL.
    CASE column.
      WHEN 'BELNR'.
        MESSAGE 'Hotspot drilldown' TYPE 'I'.
      WHEN OTHERS.
    ENDCASE.
    gr_table->refresh( l_STABLE ).
  ENDMETHOD.

  METHOD on_click.
    DATA: lo_selections TYPE REF TO cl_salv_selections,
          lt_rows TYPE salv_t_row,
          ls_row  LIKE LINE OF lt_rows,
          l_STABLE     TYPE lvc_s_stbl.
    l_stable-row = 'X'.
    l_stable-col = 'X'.
    CASE sy-ucomm.
      WHEN '...'.
      WHEN OTHERS.
    ENDCASE.
    gr_table->refresh( l_STABLE ).
  ENDMETHOD.
ENDCLASS.
