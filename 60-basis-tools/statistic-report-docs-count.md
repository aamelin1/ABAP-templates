---
title: "Statistic report — documents count by customizable rules"
keywords: statistics, количество документов, docs count, dynamic itab, CL_ABAP_STRUCTDESCR, SALV, dynamic columns, COUNT DISTINCT, PIVB_CONV_RANGE_TO_WHERE, динамический отчёт, Z-таблица настройки
status: draft
summary: "Z-report ZFI_STAT_REP: считает документы по правилам из Z-таблицы (таблица/поле/дата), день-за-днём или на дату, drill-down в список документов"
---

# Statistic report — documents count by customizable rules

Main program

```abap
*&---------------------------------------------------------------------*
*& Report ZFI_STAT_REP
*&---------------------------------------------------------------------*
*&Amelin A 24.09.2024
*&---------------------------------------------------------------------*
REPORT zfi_stat_rep.
INCLUDE zfi_stat_rep_f01.

INITIALIZATION.
  DATA(lo_report) = NEW lcl_report( ).
  lo_report->init( ).

AT SELECTION-SCREEN OUTPUT.
  lo_report->get_default_layout( ).

  LOOP AT SCREEN.
    IF screen-group1 = 'DET'.
      IF rb_det = 'X'. "OR rb_plan = 'X'.
        screen-active = '1'.
      ELSE.
        screen-active = '0'.
      ENDIF.
    ELSEIF screen-group1 = 'TOT'.
      IF rb_tot = 'X'.
        screen-active = '1'.
      ELSE.
        screen-active = '0'.
      ENDIF.
    ELSE.
      "do nothing.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  NAME = 'P_ORG'.
  CLEAR: LIST, LIST[].
  SELECT DISTINCT ORG FROM ZTFI_STAT_ID_RST INTO TABLE @DATA(lt_org).
  LOOP AT lt_org ASSIGNING FIELD-SYMBOL(<org>).
    VALUE-KEY = VALUE-TEXT = <org>.
    APPEND VALUE TO LIST.
  ENDLOOP.
CALL FUNCTION 'VRM_SET_VALUES' EXPORTING ID = NAME VALUES = LIST.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  lo_report->f4_layouts( ).

START-OF-SELECTION.
  lo_report->create_itab( ).
  lo_report->get_data( ).
  lo_report->show_alv( ).
```

Include ZFI_STAT_REP_F01:

```abap
*&---------------------------------------------------------------------*
*& Include          ZFI_STAT_REP_F01
*&---------------------------------------------------------------------*
INCLUDE icons.
TABLES: ZTFI_STAT_ID.

DATA: NAME  TYPE VRM_ID,
      LIST  TYPE VRM_VALUES,
      VALUE LIKE LINE OF LIST.

**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: rb_det  RADIOBUTTON GROUP gr1 USER-COMMAND rb1 ,
              rb_tot  RADIOBUTTON GROUP gr1 DEFAULT 'X'.
  PARAMETERS: p_keydt TYPE dats DEFAULT sy-datum MODIF ID tot.
  SELECT-OPTIONS: so_datum  FOR sy-datum NO-EXTENSION OBLIGATORY MODIF ID det.
  SELECT-OPTIONS: so_id FOR ZTFI_STAT_ID-ID.
  PARAMETERS:     p_org TYPE ZTFI_STAT_ID_RST-ORG AS LISTBOX VISIBLE LENGTH 10.
SELECTION-SCREEN END OF BLOCK bl1.
PARAMETERS: p_hide  AS CHECKBOX DEFAULT 'X',
            variant LIKE disvariant-variant.
**********************************************************************
TYPES: BEGIN OF ls_names,
         id        TYPE  abap_compname,
         stat_name TYPE zde_stat_name,
       END OF ls_names.
**********************************************************************
DATA:
  gr_table      TYPE REF TO cl_salv_table,
  gx_variant    TYPE disvariant,
  w_tab         TYPE STANDARD TABLE OF abap_compdescr,
  lo_new_type   TYPE REF TO cl_abap_structdescr,
  lo_table_type TYPE REF TO cl_abap_tabledescr,
  w_tref        TYPE REF TO data,
  w_dy_line     TYPE REF TO data,
  w_typ         TYPE REF TO cl_abap_elemdescr,
  lt_tot_comp   TYPE cl_abap_structdescr=>component_table,
  la_comp       LIKE LINE OF lt_tot_comp,
  it_names      TYPE STANDARD TABLE OF ls_names.

FIELD-SYMBOLS: <dyn_tab> TYPE STANDARD TABLE."TYPE ANY TABLE.
**********************************************************************
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS:
      init,
      get_default_layout,
      f4_layouts,
      get_data,
      get_db_val
        IMPORTING
                  count   TYPE char1
                  ls_line TYPE ztfi_stat_id
                  ls_fld  TYPE zde_stat_name
        CHANGING  lv_res  TYPE i
                  lt_tab  TYPE ANY TABLE OPTIONAL,
      create_itab,
      show_alv.
  PRIVATE SECTION.
    METHODS:
      set_pf_status CHANGING co_alv TYPE REF TO cl_salv_table,
      set_alv_lo    CHANGING co_alv TYPE REF TO cl_salv_table,
      set_fcat      CHANGING co_alv TYPE REF TO cl_salv_table,
      set_col_text  IMPORTING column TYPE lvc_fname  text TYPE scrtext_s  CHANGING o_cols  TYPE REF TO cl_salv_columns_table .
ENDCLASS.
**********************************************************************
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click       FOR EVENT link_click      OF cl_salv_events_table IMPORTING row column,
      on_click            FOR EVENT added_function  OF cl_salv_events,
      handle_double_click FOR EVENT double_click    OF cl_salv_events_table IMPORTING row column.
ENDCLASS.
**********************************************************************
CLASS lcl_report IMPLEMENTATION.
  METHOD init.
    APPEND VALUE #( sign = 'I' option = 'BT'  low = sy-datum - 6 high = sy-datum ) TO so_datum.
    APPEND VALUE #( sign = 'I' option = 'BT'  low = '000' high = '300' ) TO so_id.
    APPEND VALUE #( sign = 'I' option = 'BT'  low = '312' high = '313' ) TO so_id.
    APPEND VALUE #( sign = 'I' option = 'BT'  low = '399' high = '415' ) TO so_id.
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

  METHOD create_itab.
* Read cust for stat lines
    DATA: lt_DFIES_TAB TYPE STANDARD TABLE OF dfies,
          lv_txt       TYPE zde_stat_name.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'ZTFI_STAT_ID'
*       FIELDNAME      = <flds>-name
        langu          = sy-langu
      TABLES
        dfies_tab      = lt_DFIES_TAB
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT lt_DFIES_TAB ASSIGNING FIELD-SYMBOL(<flds>) WHERE fieldname <> 'MANDT'.
      CLEAR: lv_txt.
      IF <flds>-fieldtext IS NOT INITIAL.
        lv_txt = <flds>-fieldtext.
      ELSE.
        lv_txt = <flds>-fieldname.
      ENDIF.
      it_names = VALUE #( BASE it_names ( id = <flds>-fieldname stat_name = lv_txt ) ).
      w_tab    = VALUE #( BASE w_tab ( name = <flds>-fieldname type_kind = <flds>-inttype length = <flds>-leng ) ).
    ENDLOOP.
*    Add icon buttons
    it_names = VALUE #( BASE it_names ( id = 'ICON_SEL' stat_name = 'SQL' ) ).
    w_tab    = VALUE #( BASE w_tab ( name = 'ICON_SEL' type_kind = 'C' length = 4 ) ).

    it_names = VALUE #( BASE it_names ( id = 'ICON_REST' stat_name = 'Restrictions' ) ).
    w_tab    = VALUE #( BASE w_tab ( name = 'ICON_REST' type_kind = 'C' length = 4 ) ).

    IF rb_det = 'X'. "OR rb_plan = 'X'.
*   Add total column
        w_tab = VALUE #( BASE w_tab ( name = |{ 'DA_ALL'  }| type_kind = 'I' length = 8 ) ).
        it_names = VALUE #( BASE it_names ( id = |{ 'DA_ALL' }| stat_name = |{ 'All' }| ) ).

*   Add columns with days (day by day)
      DATA: lv_datum TYPE dats.
      lv_datum = so_datum-low.
      WHILE lv_datum <= so_datum-high.
          w_tab = VALUE #( BASE w_tab ( name = |{ 'D_' && lv_datum }| type_kind = 'I' length = 8 ) ).
          it_names = VALUE #( BASE it_names ( id = |{ 'D_' && lv_datum }| stat_name = |{ lv_datum DATE = USER }| ) ).

        lv_datum = lv_datum + 1.
      ENDWHILE.

    ELSEIF rb_tot = 'X'. "Total rep (3 columns)
      CLEAR: so_datum, so_datum[].
      DATA: dat_to   TYPE dats,
            dat_from TYPE dats.
      dat_from = p_keydt.
      dat_from+6(2) = '01'.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = p_keydt
        IMPORTING
          last_day_of_month = dat_to.
      APPEND VALUE #( sign = 'I' option = 'BT'  low = dat_from high = dat_to ) TO so_datum.

*   Add total column
      w_tab = VALUE #( BASE w_tab ( name = |{ 'DA_ALL'  }| type_kind = 'I' length = 8 ) ).
      it_names = VALUE #( BASE it_names ( id = |{ 'DA_ALL' }| stat_name = |{ 'Act:Month' }| ) ).

      lv_datum = p_keydt.

      w_tab = VALUE #( BASE w_tab ( name = |{ 'BD_' && lv_datum }| type_kind = 'I' length = 8 ) ).
      it_names = VALUE #( BASE it_names ( id = |{ 'BD_' && lv_datum }| stat_name = `<Act:`  && |{ lv_datum DATE = USER }| ) ).

      w_tab = VALUE #( BASE w_tab ( name = |{ 'D_' && lv_datum }| type_kind = 'I' length = 8 ) ).
      it_names = VALUE #( BASE it_names ( id = |{ 'D_' && lv_datum }| stat_name = `Act: ` && |{ lv_datum DATE = USER }| ) ).

      w_tab = VALUE #( BASE w_tab ( name = |{ 'AD_' && lv_datum }| type_kind = 'I' length = 8 ) ).
      it_names = VALUE #( BASE it_names ( id = |{ 'AD_' && lv_datum }| stat_name = `>Act:`  && |{ lv_datum DATE = USER }| ) ).

    ENDIF.

* Create itab type
    LOOP AT w_tab ASSIGNING FIELD-SYMBOL(<w_tab_wa>).
      CASE <w_tab_wa>-type_kind.
        WHEN 'STRING'.  w_typ = cl_abap_elemdescr=>get_string( ).
        WHEN 'XSTRING'. w_typ = cl_abap_elemdescr=>get_xstring( ).
        WHEN 'I'.       w_typ = cl_abap_elemdescr=>get_i( ).
        WHEN 'F'.       w_typ = cl_abap_elemdescr=>get_f( ).
        WHEN 'D'.       w_typ = cl_abap_elemdescr=>get_d( ).
        WHEN 'T'.       w_typ = cl_abap_elemdescr=>get_t(  ).
        WHEN 'C'.       w_typ = cl_abap_elemdescr=>get_c( p_length = <w_tab_wa>-length ).
        WHEN 'N'.       w_typ = cl_abap_elemdescr=>get_n( p_length = <w_tab_wa>-length ).
        WHEN 'X'.       w_typ = cl_abap_elemdescr=>get_x( p_length = <w_tab_wa>-length ).
        WHEN 'P'.       w_typ = cl_abap_elemdescr=>get_p( p_length = <w_tab_wa>-length p_decimals = <w_tab_wa>-decimals ).
      ENDCASE.
      CLEAR la_comp.
      la_comp-type = w_typ.
      la_comp-name = <w_tab_wa>-name.
      APPEND la_comp TO lt_tot_comp.
    ENDLOOP.
    lo_new_type = cl_abap_structdescr=>create( lt_tot_comp ).
    lo_table_type = cl_abap_tabledescr=>create( p_line_type = lo_new_type
                p_table_kind = cl_abap_tabledescr=>tablekind_std ).
* create dyn itab
    CREATE DATA w_tref TYPE HANDLE lo_table_type.
    ASSIGN w_tref->* TO <dyn_tab>.
  ENDMETHOD.

  METHOD get_data.
    DATA: lt_lines TYPE STANDARD TABLE OF ztfi_stat_id.
    CLEAR: lt_lines, lt_lines[], <dyn_tab>, <dyn_tab>[].
* -> ZTFI_STAT_ID - lines
* <- <dyn_tab> - result
* Get all lies from cust
    SELECT *
      FROM ztfi_stat_id
      INTO TABLE @lt_lines
      WHERE id in @so_id.

    SORT lt_lines BY stat_name ASCENDING.

    LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<line>).
      APPEND INITIAL LINE TO <dyn_tab> ASSIGNING FIELD-SYMBOL(<fs_line>).
      ASSIGN COMPONENT 'ICON_SEL' OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<icon>) .
      <icon> = icon_select_detail.
      ASSIGN COMPONENT 'ICON_REST' OF STRUCTURE <fs_line> TO <icon>.
*      Change icons for restrictions (on/off)
      SELECT COUNT( id ) AS cnt FROM ztfi_stat_id_rst  WHERE id = @<line>-id AND org = @p_org INTO @DATA(lv_cnt).
      IF lv_cnt = 0.
        <icon> = icon_interval_include_red. "ICON_INTERVAL_EXCLUDE_GREEN. "ICON_DATABASE_TABLE_INA .
      ELSE.
        <icon> = icon_interval_include_green. "ICON_DATABASE_TABLE.
      ENDIF.
      CLEAR lv_cnt.
      LOOP AT it_names ASSIGNING FIELD-SYMBOL(<fld>).
        CASE <fld>+0(2) .
***     Fact count
          WHEN 'D_'. "Just 1 day
            "Main statistic selection
            ASSIGN COMPONENT <fld>-id OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<stat_res>).
            IF <stat_res> IS ASSIGNED.
              me->get_db_val( EXPORTING count = 'X' ls_line = <line> ls_fld = <fld>-id  CHANGING lv_res = <stat_res> ).
              UNASSIGN <stat_res>.
            ENDIF.
          WHEN 'DA'. " All dates
            ASSIGN COMPONENT <fld>-id OF STRUCTURE <fs_line> TO <stat_res>.
            IF <stat_res> IS ASSIGNED.
              <stat_res> = 0.
              me->get_db_val( EXPORTING count = 'X' ls_line = <line> ls_fld = <fld>-id  CHANGING lv_res = <stat_res> ).
              UNASSIGN <stat_res>.
            ENDIF.
          WHEN 'BD'. " <- dates
            ASSIGN COMPONENT <fld>-id OF STRUCTURE <fs_line> TO <stat_res>.
            IF <stat_res> IS ASSIGNED.
              <stat_res> = 0.
              me->get_db_val( EXPORTING count = 'X' ls_line = <line> ls_fld = <fld>-id  CHANGING lv_res = <stat_res> ).
              UNASSIGN <stat_res>.
            ENDIF.
          WHEN 'AD'. " -> dates
            ASSIGN COMPONENT <fld>-id OF STRUCTURE <fs_line> TO <stat_res>.
            IF <stat_res> IS ASSIGNED.
              <stat_res> = 0.
              me->get_db_val( EXPORTING count = 'X' ls_line = <line> ls_fld = <fld>-id  CHANGING lv_res = <stat_res> ).
              UNASSIGN <stat_res>.
            ENDIF.

          WHEN OTHERS. " Text fields (no need to calc)
            ASSIGN COMPONENT <fld>-id OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<fs_field>).
            IF <fs_field> IS ASSIGNED.
              ASSIGN COMPONENT <fld>-id OF STRUCTURE <line> TO FIELD-SYMBOL(<fs_value>).
              IF <fs_value> IS ASSIGNED.
                <fs_field> = <fs_value>.
                UNASSIGN <fs_value>.
              ENDIF.
              UNASSIGN <fs_field>.
            ENDIF.
        ENDCASE.
      ENDLOOP.
      UNASSIGN <fld>.
    ENDLOOP.
    UNASSIGN: <line>, <fs_line>.
  ENDMETHOD.

  METHOD get_db_val. " IMPORTING ls_line TYPE ZTFI_STAT_ID CHANGING lv_res TYPE int8,
    lv_res = 0.
    DATA: lt_select           TYPE STANDARD TABLE OF string,
          lv_sel              LIKE LINE OF lt_select,
          l_tabname           TYPE tabname,
          lt_where            TYPE rsds_where_tab,
          lt_group_by_checked TYPE STANDARD TABLE OF string,
          lt_trange_and       TYPE pivb_trange_t.
    CLEAR: lt_select, lt_select[], lv_sel, l_tabname, lt_where, lt_where[], lt_group_by_checked, lt_group_by_checked[], lt_trange_and[], lt_trange_and.

* Count field
    CHECK ls_line-count_fld IS NOT INITIAL.
    CHECK ls_line-stat_table IS NOT INITIAL.
    IF count = 'X'. "Select count
      IF ls_line-is_distinct = 'X'.
        lv_sel = |{ `COUNT( DISTINCT ` && ls_line-count_fld && ` ) as DBCNT`  }|.
      ELSE.
        lv_sel = |{ `COUNT( ` && ls_line-count_fld && ` ) as DBCNT`  }|.
      ENDIF.
    ELSE. "Select list of docs
      lv_sel = |{  ls_line-count_fld  }|.
    ENDIF.
    APPEND lv_sel TO lt_select.
* Source table
    l_tabname = ls_line-stat_table.
* Restrictions for date
    DATA: lt_trange TYPE rsds_trange,
          ls_trange LIKE LINE OF lt_trange,
          lt_FRANGE TYPE rsds_frange_t,
          ls_FRANGE LIKE LINE OF lt_FRANGE.
    DATA: ts_low  TYPE timestamp,
          ts_high TYPE timestamp.
    DATA: dt_from TYPE dats,
          dt_to   TYPE dats.

    IF ls_line-fld_datum IS NOT INITIAL.
      ls_FRANGE-fieldname = ls_line-fld_datum.
      IF strlen( ls_fld ) = 10. "Day by day
        IF ls_line-timestamp = 'X'.
          CONVERT DATE ls_fld+2(8) TIME '000000' INTO TIME STAMP ts_low  TIME ZONE 'UTC'.
          CONVERT DATE ls_fld+2(8) TIME '235959' INTO TIME STAMP ts_high TIME ZONE 'UTC'.
          APPEND VALUE #( sign = 'I' option = 'BT' low = ts_low high = ts_high   ) TO ls_FRANGE-selopt_t.
        ELSE.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_fld+2(8)   ) TO ls_FRANGE-selopt_t.
        ENDIF.
        APPEND ls_FRANGE TO lt_FRANGE.
        CLEAR ls_FRANGE.
        ls_trange-tablename = l_tabname.
        ls_trange-frange_t = lt_FRANGE.
        APPEND ls_trange TO lt_trange.
        CLEAR: ls_trange, lt_FRANGE, lt_FRANGE[].
      ELSEIF ls_fld = 'DA_ALL'. "All period
        IF ls_line-timestamp = 'X'.
          CONVERT DATE so_datum[ 1 ]-low  TIME '000000' INTO TIME STAMP ts_low  TIME ZONE 'UTC'.
          CONVERT DATE so_datum[ 1 ]-high TIME '235959' INTO TIME STAMP ts_high TIME ZONE 'UTC'.
          APPEND VALUE #( sign = 'I' option = 'BT' low = ts_low high = ts_high   ) TO ls_FRANGE-selopt_t.
        ELSE.
          APPEND VALUE #( sign = 'I' option = 'BT' low = so_datum[ 1 ]-low high = so_datum[ 1 ]-high   ) TO ls_FRANGE-selopt_t.
        ENDIF.
        APPEND ls_FRANGE TO lt_FRANGE.
        CLEAR ls_FRANGE.
        ls_trange-tablename = l_tabname.
        ls_trange-frange_t = lt_FRANGE.
        APPEND ls_trange TO lt_trange.
        CLEAR: ls_trange, lt_FRANGE, lt_FRANGE[].
      ELSEIF ls_fld+0(2) = 'BD'. "<-
        dt_from = p_keydt.
        dt_from+6(2) = '01'.
        dt_to = p_keydt - 1.
        IF ls_line-timestamp = 'X'.
          CONVERT DATE dt_from  TIME '000000' INTO TIME STAMP ts_low  TIME ZONE 'UTC'.
          CONVERT DATE dt_to TIME '235959' INTO TIME STAMP ts_high TIME ZONE 'UTC'.
          APPEND VALUE #( sign = 'I' option = 'BT' low = ts_low high = ts_high   ) TO ls_FRANGE-selopt_t.
        ELSE.
          APPEND VALUE #( sign = 'I' option = 'BT' low = dt_from high = dt_to   ) TO ls_FRANGE-selopt_t.
        ENDIF.
        APPEND ls_FRANGE TO lt_FRANGE.
        CLEAR ls_FRANGE.
        ls_trange-tablename = l_tabname.
        ls_trange-frange_t = lt_FRANGE.
        APPEND ls_trange TO lt_trange.
        CLEAR: ls_trange, lt_FRANGE, lt_FRANGE[].
      ELSEIF ls_fld+0(2) = 'AD'. "->
        dt_from = p_keydt + 1.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = dt_from
          IMPORTING
            last_day_of_month = dt_to.
        IF ls_line-timestamp = 'X'.
          CONVERT DATE dt_from  TIME '000000' INTO TIME STAMP ts_low  TIME ZONE 'UTC'.
          CONVERT DATE dt_to TIME '235959' INTO TIME STAMP ts_high TIME ZONE 'UTC'.
          APPEND VALUE #( sign = 'I' option = 'BT' low = ts_low high = ts_high   ) TO ls_FRANGE-selopt_t.
        ELSE.
          APPEND VALUE #( sign = 'I' option = 'BT' low = dt_from high = dt_to   ) TO ls_FRANGE-selopt_t.
        ENDIF.
        APPEND ls_FRANGE TO lt_FRANGE.
        CLEAR ls_FRANGE.
        ls_trange-tablename = l_tabname.
        ls_trange-frange_t = lt_FRANGE.
        APPEND ls_trange TO lt_trange.
        CLEAR: ls_trange, lt_FRANGE, lt_FRANGE[].
      ENDIF.
    ENDIF.
*Other dynamic restrictions
    SELECT *
      FROM ztfi_stat_id_rst
      INTO TABLE @DATA(dyn_rest)
      WHERE id = @ls_line-id
        AND org = @p_org.
    CHECK dyn_rest[] IS NOT INITIAL.
    LOOP AT dyn_rest ASSIGNING FIELD-SYMBOL(<dyn_rest>) GROUP BY <dyn_rest>-field_name INTO DATA(key).
      LOOP AT GROUP key ASSIGNING FIELD-SYMBOL(<members>).
        ls_FRANGE-fieldname = <members>-field_name.
        APPEND VALUE #( sign = <members>-r_sign option = <members>-r_option low = <members>-r_low high = <members>-r_high   ) TO ls_FRANGE-selopt_t.
      ENDLOOP.
      APPEND ls_FRANGE TO lt_FRANGE.
      CLEAR ls_FRANGE.
      ls_trange-tablename = ls_line-stat_table.
      ls_trange-frange_t = lt_FRANGE.
      APPEND ls_trange TO lt_trange.
      CLEAR: ls_trange, lt_FRANGE, lt_FRANGE[].
    ENDLOOP.

    CALL FUNCTION 'PIVB_CONV_RANGE_TO_WHERE'
      EXPORTING
        it_trange     = lt_trange[]
        it_trange_and = lt_trange_and[]
      IMPORTING
        et_where      = lt_where[].
    CLEAR: lt_FRANGE[], lt_FRANGE.

    TRY.
        SELECT (lt_select)
          FROM (l_tabname)
          WHERE (lt_where)
          INTO TABLE NEW @DATA(dref_tab).
      CATCH cx_sy_open_sql_db.
        lv_res = ''.
        EXIT.
      CATCH cx_sy_dynamic_osql_semantics.
        lv_res = ''.
        EXIT.
      CATCH cx_root.
        lv_res = ''.
        EXIT.
    ENDTRY ##MG_MISSING.
**********************************************************************
    FIELD-SYMBOLS: <gt_tab> TYPE ANY TABLE.
    ASSIGN dref_tab->* TO <gt_tab>.
    CHECK <gt_tab> IS ASSIGNED.
    IF count = 'X'. "Select count
      CHECK lines( <gt_tab> ) = 1. "should be only one line
      LOOP AT <gt_tab> ASSIGNING FIELD-SYMBOL(<result>).
        ASSIGN COMPONENT 'DBCNT' OF STRUCTURE <result> TO FIELD-SYMBOL(<fs_BDCNT>).
        IF <fs_BDCNT> IS ASSIGNED.
          lv_res = <fs_BDCNT>.
          UNASSIGN <fs_BDCNT>.
        ENDIF.
      ENDLOOP.
    ELSE. "List of docs
      lv_res = 0.
      lt_tab = <gt_tab>.
    ENDIF.
  ENDMETHOD.

  METHOD set_alv_lo.
    DATA:
      key    TYPE salv_s_layout_key,
      header TYPE lvc_title.
    key-report = sy-repid.
*---Setting the Layout Save property
    DATA(gr_layout) = co_alv->get_layout( ).
    gr_layout->set_key( key ).
    gr_layout->set_initial_layout( variant ).
    gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
    gr_layout->set_default( abap_true ).
*---Setting the list header
    DATA(gr_display) = co_alv->get_display_settings( ).
    IF rb_tot NE 'X'.
      header = |{ `Period: from ` }| && |{ so_datum-low DATE = USER }| && ` to ` && |{ so_datum-high DATE = USER }|.
    ELSE.
      header = |{ `On a date - ` }| && |{ p_keydt DATE = USER }|.
    ENDIF.
    gr_display->set_list_header( header ).
    gr_display->set_striped_pattern( abap_true ).
    gr_display->set_fit_column_to_table_size( abap_true ).
    DATA(oref_columns) = co_alv->get_columns( ).

    DATA(lr_events) = gr_table->get_event( ).
    DATA: gr_events TYPE REF TO lcl_event_handler.
    CREATE OBJECT gr_events.
    SET HANDLER gr_events->handle_double_click FOR lr_events.

    oref_columns->set_key_fixation( ).
  ENDMETHOD.

  METHOD set_col_text.
    DATA: lr_column TYPE REF TO cl_salv_column_table.
    TRY.
        lr_column ?= o_cols->get_column( column ).
        DATA: text_m TYPE scrtext_m,
              text_l TYPE scrtext_l.
        text_l = text_m = text.
        lr_column->set_short_text( text ).
        lr_column->set_medium_text( text_m ).
        lr_column->set_long_text( text_l ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.

  METHOD set_fcat.
    DATA: ls_color  TYPE lvc_s_colo.
    DATA(lo_cols) = co_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ). "--> Optimise all columns
    LOOP AT it_names ASSIGNING FIELD-SYMBOL(<name>).
      me->set_col_text( EXPORTING column = <name>-id   text = |{ <name>-stat_name }|      CHANGING o_cols = lo_cols ) .
      IF <name>+0(2) = 'D_' OR <name>+0(2) = 'P_' OR <name>+0(2) = 'Y_'.
      ENDIF.
      IF ( <name>+0(2) = 'D_' OR <name>+0(2) = 'BD' OR <name>+0(2) = 'AD' )." AND ( p_plan = 'X' OR p_yoy = 'X' ).
        TRY.
            CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( <name>-id ) )->set_color( VALUE lvc_s_colo( col = col_heading int = 1 inv = 1 ) ).
          CATCH cx_salv_not_found.                      "#EC NO_HANDLER
            "no need to handle ex
        ENDTRY.
      ENDIF.
    ENDLOOP.
    TRY.
        CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'IS_DISTINCT' ) )->set_cell_type( if_salv_c_cell_type=>checkbox ). "Set checkbox
        CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'TIMESTAMP' ) )->set_cell_type( if_salv_c_cell_type=>checkbox ). "Set checkbox
        CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'ICON_SEL' ) )->set_cell_type( if_salv_c_cell_type=>hotspot ).
        CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'ICON_REST' ) )->set_cell_type( if_salv_c_cell_type=>hotspot ).
        CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'DA_ALL' ) )->set_color( VALUE lvc_s_colo( col = col_total int = 1 inv = 0 ) ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
        "no need to handle ex
    ENDTRY.
    IF p_hide = 'X'.
      TRY.
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'IS_DISTINCT' ) )->set_technical( abap_true ).
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'TIMESTAMP' ) )->set_technical( abap_true ).
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'ICON_SEL' ) )->set_technical( abap_true ).
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'ICON_REST' ) )->set_technical( abap_true ).
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'STAT_TABLE' ) )->set_technical( abap_true ).
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'COUNT_FLD' ) )->set_technical( abap_true ).
          CAST cl_salv_column_table( gr_table->get_columns(  )->get_column( 'FLD_DATUM' ) )->set_technical( abap_true ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
          "no need to handle ex
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD set_pf_status.
    co_alv->set_screen_status(
      pfstatus      =  'Z_ALV'
      report        =  sy-repid
      set_functions = co_alv->c_functions_all ).
  ENDMETHOD.

  METHOD show_alv.
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = gr_table CHANGING t_table = <dyn_tab> ).
      CATCH cx_salv_msg .
    ENDTRY.
    me->set_pf_status( CHANGING co_alv = gr_table ).
    me->set_alv_lo( CHANGING co_alv = gr_table ).
    me->set_fcat( CHANGING co_alv = gr_table ).
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

**********************************************************************
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_link_click.
    DATA: l_STABLE     TYPE lvc_s_stbl.
    l_stable-row = 'X'.
    l_stable-col = 'X'.
    READ TABLE <dyn_tab> ASSIGNING FIELD-SYMBOL(<f_data>) INDEX row.
    ASSIGN COMPONENT 'ID' OF STRUCTURE <f_data> TO FIELD-SYMBOL(<id>).
    IF <id> IS ASSIGNED.
    ELSE.
      MESSAGE 'ID not found' TYPE 'E'.
    ENDIF.
    CASE column.
      WHEN 'ICON_SEL'.
        DATA: lt_txt TYPE catsxt_longtext_itab,
              lv_sel TYPE string.
        SELECT SINGLE *
          FROM ztfi_stat_id
          INTO @DATA(ls_id)
          WHERE id = @<id>.
        CASE ls_id-is_distinct.
          WHEN 'X'.
            lv_sel = |{ `SELECT COUNT( DISTINCT ` && ls_id-count_fld && ` ) as DBCNT`  }|.
          WHEN OTHERS.
            lv_sel = |{ `SELECT COUNT( ` && ls_id-count_fld && ` ) as DBCNT`  }|.
        ENDCASE.
*        lv_sel = lv_sel && cl_abap_char_utilities=>cr_lf.
        lv_sel = lv_sel && `  FROM ` && ls_id-stat_table.
        lv_sel = lv_sel && `  INTO db_count`.
        lv_sel = lv_sel && `  WHERE`.
        DATA: lt_trange     TYPE rsds_trange,
              ls_trange     LIKE LINE OF lt_trange,
              lt_FRANGE     TYPE rsds_frange_t,
              ls_FRANGE     LIKE LINE OF lt_FRANGE,
              lt_where      TYPE rsds_where_tab,
              lt_trange_and TYPE pivb_trange_t.
        SELECT *
          FROM ztfi_stat_id_rst
          INTO TABLE @DATA(dyn_rest)
          WHERE id = @ls_id-id
            AND org = @p_org.
        LOOP AT dyn_rest ASSIGNING FIELD-SYMBOL(<dyn_rest>) GROUP BY <dyn_rest>-field_name INTO DATA(key).
          LOOP AT GROUP key ASSIGNING FIELD-SYMBOL(<members>).
            ls_FRANGE-fieldname = <members>-field_name.
            APPEND VALUE #( sign = <members>-r_sign option = <members>-r_option low = <members>-r_low high = <members>-r_high   ) TO ls_FRANGE-selopt_t.
          ENDLOOP.
          APPEND ls_FRANGE TO lt_FRANGE.
          CLEAR ls_FRANGE.
          ls_trange-tablename = ls_id-stat_table.
          ls_trange-frange_t = lt_FRANGE.
          APPEND ls_trange TO lt_trange.
          CLEAR: ls_trange, lt_FRANGE, lt_FRANGE[].
        ENDLOOP.
        CALL FUNCTION 'PIVB_CONV_RANGE_TO_WHERE'
          EXPORTING
            it_trange     = lt_trange[]
            it_trange_and = lt_trange_and[]
          IMPORTING
            et_where      = lt_where[].
        CLEAR: lt_FRANGE[], lt_FRANGE.
        LOOP AT lt_where ASSIGNING FIELD-SYMBOL(<where>).
          lv_sel = lv_sel && <where>-line.
        ENDLOOP.
        IF ls_id-fld_datum IS NOT INITIAL.
          lv_sel = lv_sel && ` AND ` && ls_id-fld_datum && ` = @<date>`.
        ENDIF.
        CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
          EXPORTING
            i_string         = lv_sel
            i_tabline_length = 72
          TABLES
            et_table         = lt_txt.
        CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
          EXPORTING
            im_title        = 'SQL:'
            im_display_mode = 'X'
          CHANGING
            ch_text         = lt_txt.
      WHEN 'ICON_REST'.
        DATA: ls_dyn TYPE zsdev_dynamic_restrictions,
              lt_fld TYPE z_tdev_dynamic_restr_fields,
              ls_fld LIKE LINE OF lt_fld.
        IF <f_data> IS ASSIGNED.
          ASSIGN COMPONENT 'STAT_TABLE' OF STRUCTURE <f_data> TO FIELD-SYMBOL(<tab>).
          IF <tab> IS ASSIGNED.
            ls_dyn-object_name = <tab>.
          ELSE.
            MESSAGE 'Table not define' TYPE 'E'.
          ENDIF.
        ENDIF.
        CHECK <id> IS ASSIGNED AND <id> IS NOT INITIAL.
        "read cust table
        SELECT *
          FROM ztfi_stat_id_rst
          INTO TABLE @DATA(lt_restr)
          WHERE id = @<id>
            AND org = @p_org.
        LOOP AT lt_restr ASSIGNING FIELD-SYMBOL(<restr>).
          ls_fld-field_name = <restr>-field_name.
          ls_fld-sign = <restr>-r_sign.
          ls_fld-option = <restr>-r_option.
          ls_fld-low = <restr>-r_low.
          ls_fld-high = <restr>-r_high.
          APPEND ls_fld TO lt_fld.
        ENDLOOP.
        ls_dyn-object_restr = lt_fld.
        TRY.
            CALL METHOD zcldev_dynamic_selection=>show_dynamic_restrictions_new
              CHANGING
                cs_dynamic_restrictions = ls_dyn.
          CATCH zcx_generic.
        ENDTRY.
        "upd cust table
        DELETE FROM ztfi_stat_id_rst WHERE id = @<id> AND org = @p_org.
        COMMIT WORK AND WAIT.
        DATA: lt_nfld TYPE STANDARD TABLE OF ztfi_stat_id_rst,
              ls_nfld LIKE LINE OF lt_nfld.
        LOOP AT ls_dyn-object_restr ASSIGNING FIELD-SYMBOL(<new_rest>).
          ls_nfld-mandt          = sy-mandt.
          ls_nfld-id             = <id>.
          ls_nfld-org            = p_org.
          ls_nfld-buzei          = sy-tabix.
          ls_nfld-field_name     = <new_rest>-field_name.
          ls_nfld-r_sign         = <new_rest>-sign.
          ls_nfld-r_option       = <new_rest>-option.
          ls_nfld-r_low          = <new_rest>-low.
          ls_nfld-r_high         = <new_rest>-high.
          APPEND ls_nfld TO lt_nfld.
        ENDLOOP.
        INSERT ztfi_stat_id_rst FROM TABLE lt_nfld.
        COMMIT WORK AND WAIT.
        DATA(upd_report) = NEW lcl_report( ).
        upd_report->get_data( ).
      WHEN OTHERS.
    ENDCASE.
    gr_table->refresh( l_STABLE ).
  ENDMETHOD.

  METHOD on_click.
    DATA: lo_selections TYPE REF TO cl_salv_selections,
          lt_rows       TYPE salv_t_row,
          ls_row        LIKE LINE OF lt_rows,
          l_STABLE      TYPE lvc_s_stbl.
    l_stable-row = 'X'.
    l_stable-col = 'X'.
    CASE sy-ucomm.
      WHEN 'CUST'.
        CALL TRANSACTION 'ZFI_STAT_ID'.
        DATA(upd_report) = NEW lcl_report( ).
        upd_report->get_data( ).
      WHEN 'REFR'.
        DATA(upd_report2) = NEW lcl_report( ).
        upd_report2->get_data( ).
      WHEN OTHERS.
    ENDCASE.
    gr_table->refresh( l_STABLE ).
  ENDMETHOD.

  METHOD handle_double_click.
    "Show docs in popup ALV
    READ TABLE <dyn_tab> ASSIGNING FIELD-SYMBOL(<dd>) INDEX row.
    CHECK <dd> IS ASSIGNED.
    IF column+0(2) = 'D_' OR column+0(2) = 'DA' OR column+0(2) = 'AD' OR column+0(2) = 'BD'.
      ASSIGN COMPONENT column OF STRUCTURE <dd> TO FIELD-SYMBOL(<stat_res>).
      IF <stat_res> IS ASSIGNED.
        DATA: ls_line TYPE ztfi_stat_id.
        MOVE-CORRESPONDING <dd> TO ls_line.
        DATA(alv_report) = NEW lcl_report( ).
        ASSIGN COMPONENT 'COUNT_FLD' OF STRUCTURE <dd> TO FIELD-SYMBOL(<dtype>).
        CHECK <dtype> IS ASSIGNED.
        ASSIGN COMPONENT 'STAT_TABLE' OF STRUCTURE <dd> TO FIELD-SYMBOL(<table>).
        CHECK <table> IS ASSIGNED.
        SELECT SINGLE
          rollname
          FROM dd03l
          INTO @DATA(lv_de)
            WHERE tabname = @<table>
            AND fieldname = @<dtype>
            AND as4local = 'A'.
        IF lv_de IS INITIAL. " for CDSs
          SELECT SINGLE
            objectname
            FROM ddldependency
            INTO @DATA(lv_tab) "<table>
            WHERE ddlname = @<table>
              AND objecttype = 'VIEW'
              AND state = 'A'.
          SELECT SINGLE
            rollname
            FROM dd03l
            INTO @lv_de
              WHERE tabname = @lv_tab
              AND fieldname = @<dtype>
              AND as4local = 'A'.
        ENDIF.
        CHECK lv_de IS NOT INITIAL.
        DATA(fld_descriptor) = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( lv_de ) ).
        DATA(components) = VALUE abap_component_tab( ( name = <dtype> type = fld_descriptor ) ) .
        DATA(row_descriptor) = cl_abap_structdescr=>get( components ).
        DATA(table_descriptor) = cl_abap_tabledescr=>create( row_descriptor ).
        DATA alv TYPE REF TO data.
        CREATE DATA alv TYPE HANDLE table_descriptor.
        ASSIGN  alv->* TO FIELD-SYMBOL(<alv>).

        alv_report->get_db_val(
          EXPORTING
            count = ' '
            ls_line = ls_line
            ls_fld = column
          CHANGING
            lv_res = <stat_res>
            lt_tab = <alv> ).

        DATA(lv_name) = strlen( column  ).
        lv_name = lv_name - 2.
        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = <alv>
            if_multi       = abap_false
            id_title       = 'Data:' && column+2(lv_name)
          RECEIVING
            ro_f4_instance = DATA(go_popup).
        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 70
            id_end_line     = 15.
        UNASSIGN: <stat_res>, <dd>, <dtype>, <alv>.
      ENDIF.
    ELSE.
    ENDIF.
    UNASSIGN <dd>.
  ENDMETHOD.
ENDCLASS.

FORM status USING p_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD' EXCLUDING p_extab.
ENDFORM. " STATUS

FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  DATA: gd_repid LIKE sy-repid,
        ref_grid TYPE REF TO cl_gui_alv_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.
  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data.
  ENDIF.
  rs_selfield-refresh = 'X'.
ENDFORM. "USER_COMMAND
```

Table ZTFI_STAT_ID

MANDT	MANDT	CLNT	3	0	0	Client
ID	ZDE_STAT_ID	CHAR	3	0	0	ID
STAT_NAME	ZDE_STAT_NAME	CHAR	30	0	0	Name
STAT_TABLE	TABNAME16	CHAR	16	0	0	Table name, 16 characters
COUNT_FLD	ZDE_COUNT_FIELD	CHAR	30	0	0	Count by field
IS_DISTINCT	ZDE_DISTINCT	CHAR	1	0	0	Is dist?
FLD_DATUM	ZDE_DAT_FIELD	CHAR	30	0	0	Date field
TIMESTAMP	ZDE_TIMESTAMP	CHAR	1	0	0	Date in timestamp format?

Table ZTFI_STAT_ID_RST

MANDT	MANDT	CLNT	3	0	0	Client
ID	ZDE_STAT_ID	CHAR	3	0	0	ID
BUZEI	BUZEI	NUMC	3	0	0	Number of Line Item Within Accounting Document
ORG	ZDE_ORG	CHAR	3	0	0	OrgID
FIELD_NAME	ZEDEV_DYNAMIC_FIELD_NAME	CHAR	100	0	0	Field Name
R_SIGN	DDSIGN	CHAR	1	0	0	Type of SIGN component in row type of a Ranges type
R_OPTION	DDOPTION	CHAR	2	0	0	Type of OPTION component in row type of a Ranges type
R_LOW	ZEDEV_DYNAMIC_FIELD_VALUE	STRING	0	0	0	Динамические ограничения. Значение поля
R_HIGH	ZEDEV_DYNAMIC_FIELD_VALUE	STRING	0	0	0	Динамические ограничения. Значение поля