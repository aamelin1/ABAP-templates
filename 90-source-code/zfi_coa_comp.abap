*&---------------------------------------------------------------------*
*& Report ZFI_COA_COMP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_coa_comp.


TABLES: ska1, skb1, tka02.

SELECT-OPTIONS so_KTOPL FOR ska1-ktopl DEFAULT 'CAEC' NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS so_SAKNR FOR ska1-saknr.
SELECT-OPTIONS so_bukrs FOR tka02-bukrs NO INTERVALS.
SELECT-OPTIONS so_kokrs FOR tka02-kokrs NO-DISPLAY.
SELECT-OPTIONS so_langu FOR sy-langu NO INTERVALS.

PARAMETERS p_dest TYPE rfcdest DEFAULT 'PRDCLNT600_IDOC'.



DATA: lt_rep TYPE STANDARD TABLE OF zfi_coa_comp,
      ls_rep LIKE LINE OF lt_rep.

CONSTANTS: lv_green TYPE icon_d VALUE ICON_LED_GREEN,
           lv_yellow TYPE icon_d VALUE ICON_LED_YELLOW,
           lv_red TYPE icon_d VALUE ICON_LED_RED,
           lv_grey TYPE icon_d VALUE ICON_LED_INACTIVE.

DATA:
  s_ska1 TYPE STANDARD TABLE OF ska1,
  t_ska1 TYPE STANDARD TABLE OF ska1,
  s_skb1 TYPE STANDARD TABLE OF skb1,
  t_skb1 TYPE STANDARD TABLE OF skb1,
  s_skat TYPE STANDARD TABLE OF skat,
  t_skat TYPE STANDARD TABLE OF skat,
  s_cska TYPE STANDARD TABLE OF cska,
  t_cska TYPE STANDARD TABLE OF cska,
  s_cskb TYPE STANDARD TABLE OF cskb,
  t_cskb TYPE STANDARD TABLE OF cskb.

CLASS cl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_double_click                 " DOUBLE_CLICK
      FOR EVENT if_salv_events_actions_table~double_click
      OF cl_salv_events_table
      IMPORTING row
                column.
ENDCLASS.                    "cl_event_handler DEFINITION

CLASS cl_event_handler IMPLEMENTATION.
  METHOD on_double_click.
    READ TABLE lt_rep ASSIGNING FIELD-SYMBOL(<dd>) INDEX row.
    CASE column.
      WHEN 'T_SKA1'.
        DATA: lt_det_ska1 TYPE STANDARD TABLE OF ska1.
        CLEAR lt_det_ska1[].
        LOOP AT s_ska1 ASSIGNING FIELD-SYMBOL(<det_ska1>) WHERE ktopl = <dd>-ktopl AND saknr = <dd>-saknr.
          APPEND <det_ska1> TO lt_det_ska1.
        ENDLOOP.
        LOOP AT t_ska1 ASSIGNING <det_ska1> WHERE ktopl = <dd>-ktopl AND saknr = <dd>-saknr.
          APPEND <det_ska1> TO lt_det_ska1.
        ENDLOOP.
        DATA:
          go_popup  TYPE REF TO cl_reca_gui_f4_popup,
          gf_choice TYPE flag.

        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = lt_det_ska1[]
            if_multi       = abap_false
            id_title       = 'Details: SKA1'
          RECEIVING
            ro_f4_instance = go_popup.

        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 90
            id_end_line     = 20
          IMPORTING
            et_result       = lt_det_ska1[]
            ef_cancelled    = gf_choice.

      WHEN 'T_SKB1'.
        DATA: lt_det_skb1 TYPE STANDARD TABLE OF skb1.
        CLEAR lt_det_skb1[].
        LOOP AT s_skb1 ASSIGNING FIELD-SYMBOL(<det_skb1>) WHERE  saknr = <dd>-saknr.
          APPEND <det_skb1> TO lt_det_skb1.
        ENDLOOP.
        LOOP AT t_skb1 ASSIGNING <det_skb1> WHERE   saknr = <dd>-saknr.
          APPEND <det_skb1> TO lt_det_skb1.
        ENDLOOP.

        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = lt_det_skb1[]
            if_multi       = abap_false
            id_title       = 'Details: SKB1'
          RECEIVING
            ro_f4_instance = go_popup.

        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 90
            id_end_line     = 20
          IMPORTING
            et_result       = lt_det_skb1[]
            ef_cancelled    = gf_choice.
      WHEN 'T_SKAT'.
        DATA: lt_det_skat TYPE STANDARD TABLE OF skat.
        CLEAR lt_det_skat[].
        LOOP AT s_skat ASSIGNING FIELD-SYMBOL(<det_skat>) WHERE ktopl = <dd>-ktopl AND saknr = <dd>-saknr AND spras in so_langu.
          APPEND <det_skat> TO lt_det_skat.
        ENDLOOP.
        LOOP AT t_skat ASSIGNING <det_skat> WHERE ktopl = <dd>-ktopl AND saknr = <dd>-saknr AND spras in so_langu.
          APPEND <det_skat> TO lt_det_skat.
        ENDLOOP.

        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = lt_det_skat[]
            if_multi       = abap_false
            id_title       = 'Details: SKAT'
          RECEIVING
            ro_f4_instance = go_popup.

        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 90
            id_end_line     = 20
          IMPORTING
            et_result       = lt_det_skat[]
            ef_cancelled    = gf_choice.
      WHEN 'T_CSKA'.
        DATA: lt_det_cska TYPE STANDARD TABLE OF cska.
        CLEAR lt_det_cska[].
        LOOP AT s_cska ASSIGNING FIELD-SYMBOL(<det_cska>) WHERE ktopl = <dd>-ktopl AND kstar = <dd>-saknr.
          APPEND <det_cska> TO lt_det_cska.
        ENDLOOP.
        LOOP AT t_cska ASSIGNING <det_cska> WHERE ktopl = <dd>-ktopl AND kstar = <dd>-saknr .
          APPEND <det_cska> TO lt_det_cska.
        ENDLOOP.

        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = lt_det_cska[]
            if_multi       = abap_false
            id_title       = 'Details: CSKA'
          RECEIVING
            ro_f4_instance = go_popup.

        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 90
            id_end_line     = 20
          IMPORTING
            et_result       = lt_det_cska[]
            ef_cancelled    = gf_choice.
      WHEN 'T_CSKB'.
        DATA: lt_det_cskb TYPE STANDARD TABLE OF cskb.
        CLEAR lt_det_cskb[].
        LOOP AT s_cskb ASSIGNING FIELD-SYMBOL(<det_cskb>) WHERE kokrs in so_kokrs AND kstar = <dd>-saknr.
          APPEND <det_cskb> TO lt_det_cskb.
        ENDLOOP.
        LOOP AT t_cskb ASSIGNING <det_cskb> WHERE kokrs in so_kokrs AND kstar = <dd>-saknr .
          APPEND <det_cskb> TO lt_det_cskb.
        ENDLOOP.

        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = lt_det_cskb[]
            if_multi       = abap_false
            id_title       = 'Details: CSKB'
          RECEIVING
            ro_f4_instance = go_popup.

        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 90
            id_end_line     = 20
          IMPORTING
            et_result       = lt_det_cskb[]
            ef_cancelled    = gf_choice.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "cl_event_handler IMPLEMENTATION


INITIALIZATION.
APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'EN' ) TO so_langu.
APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'PT' ) TO so_langu.

**********************************************************************
START-OF-SELECTION.
  DATA: lt_opt    TYPE STANDARD TABLE OF rfc_db_opt,
        ls_opt    LIKE LINE OF lt_opt,
        lt_fields TYPE STANDARD TABLE OF rfc_db_fld,
        lt_data   TYPE STANDARD TABLE OF tab512.
**********************************************************************
* Get CC, CO area etc.
  SELECT t001~bukrs, tka02~kokrs
    FROM t001 INNER JOIN tka02
    ON t001~bukrs EQ tka02~bukrs
    INTO TABLE @DATA(lt_t001)
    WHERE ktopl IN @so_ktopl
      AND t001~bukrs in @so_bukrs.
  LOOP AT lt_t001 ASSIGNING FIELD-SYMBOL(<t001>).
    APPEND VALUE #( sign = 'I' option = 'EQ'  low = <t001>-bukrs ) TO so_bukrs.
    APPEND VALUE #( sign = 'I' option = 'EQ'  low = <t001>-kokrs ) TO so_kokrs.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM so_kokrs[].
  SORT so_bukrs[].
  DELETE ADJACENT DUPLICATES FROM so_bukrs[].
**********************************************************************
* DEV
  SELECT *
    FROM ska1
    INTO CORRESPONDING FIELDS OF TABLE @s_ska1
    WHERE ktopl IN @so_KTOPL
      AND saknr IN @so_saknr.
  LOOP AT s_ska1 ASSIGNING FIELD-SYMBOL(<s_a>).
    ls_rep-ktopl = <s_a>-ktopl.
    ls_rep-saknr = <s_a>-saknr.
    APPEND ls_rep TO lt_rep.
  ENDLOOP.

  SELECT *
    FROM skb1
    INTO CORRESPONDING FIELDS OF TABLE @s_skb1
    WHERE bukrs IN @so_bukrs
      AND saknr IN @so_saknr.

  SELECT *
    FROM skat
    INTO CORRESPONDING FIELDS OF TABLE @s_skat
      WHERE ktopl IN @so_KTOPL
        AND saknr IN @so_saknr.

  SELECT *
    FROM cska
    INTO CORRESPONDING FIELDS OF TABLE @s_cska
      WHERE ktopl IN @so_KTOPL
        AND KSTAR IN @so_saknr.


  SELECT *
    FROM cskb
    INTO CORRESPONDING FIELDS OF TABLE @s_cskb
      WHERE kokrs IN @so_kokrs
        AND KSTAR IN @so_saknr.

**********************************************************************
* Target (PRD)
  DATA : p_inp(10) TYPE c.

  p_inp = 'SKA1'.
  DATA: t_fields TYPE TABLE OF  ddshselopt WITH HEADER LINE,
        lv_where TYPE string.

  LOOP AT so_ktopl.
    t_fields-shlpfield = 'KTOPL'.
    t_fields-sign      = so_ktopl-sign.
    t_fields-option    = so_ktopl-option.
    t_fields-low       = so_ktopl-low.
    t_fields-high      = so_ktopl-high.
    APPEND t_fields.
  ENDLOOP.

  LOOP AT so_saknr.
    t_fields-shlpfield = 'SAKNR'.
    t_fields-sign      = so_saknr-sign.
    t_fields-option    = so_saknr-option.
    t_fields-low       = so_saknr-low.
    t_fields-high      = so_saknr-high.
    APPEND t_fields.
  ENDLOOP.

  CALL FUNCTION 'F4_CONV_SELOPT_TO_WHERECLAUSE'
    IMPORTING
      where_clause = lv_where
    TABLES
      selopt_tab   = t_fields.

   CLEAR: lt_opt, lt_opt[].
   CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
    EXPORTING
      i_string               = lv_where
      i_tabline_length       = 72
*     I_UNICODE              =
    TABLES
      et_table               = lt_opt.
*  ls_opt-text = lv_where.
*  APPEND ls_opt TO lt_opt.

  CALL FUNCTION 'RFC_READ_TABLE' DESTINATION p_dest
    EXPORTING
      query_table          = p_inp
    TABLES
      options              = lt_opt
      fields               = lt_fields
      data                 = lt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.


  DATA : obj_data TYPE REF TO data,
         ls_fld   LIKE LINE OF lt_fields.
  FIELD-SYMBOLS : <fs_table> TYPE STANDARD TABLE,
                  <fs_wa>    TYPE any.
  IF lt_data[] IS NOT INITIAL.
    CREATE DATA obj_data TYPE TABLE OF (p_inp).
    ASSIGN obj_data->* TO <fs_table>.
    FREE : obj_data.
    CREATE DATA obj_data TYPE (p_inp).
    ASSIGN obj_data->* TO <fs_wa>.
    DATA :wa_data LIKE LINE OF lt_data.
    FIELD-SYMBOLS : <lv_field> TYPE any.
    FIELD-SYMBOLS : <fs> TYPE tab512.
    DATA : lc_cnt TYPE sy-tfill.
    DESCRIBE TABLE lt_fields LINES sy-tfill.
    IF sy-subrc IS INITIAL.
      lc_cnt = sy-tfill.
    ENDIF.
    LOOP AT lt_data INTO wa_data.
      DO lc_cnt TIMES.
        READ TABLE lt_fields INTO ls_fld INDEX sy-index.
        IF sy-subrc IS INITIAL.
          ASSIGN COMPONENT ls_fld-fieldname OF STRUCTURE <fs_wa> TO <lv_field>.
          IF <lv_field> IS ASSIGNED AND sy-subrc IS INITIAL.
            MOVE : wa_data-wa+ls_fld-offset(ls_fld-length) TO <lv_field>.
          ENDIF.
        ENDIF.
      ENDDO.
      APPEND : <fs_wa> TO <fs_table>.
      CLEAR : wa_data-wa.
    ENDLOOP.
  ENDIF.
  IF <fs_table> IS ASSIGNED.
    t_ska1[] = <fs_table>[].
  ENDIF.
  UNASSIGN <fs_table>.
  LOOP AT t_ska1 ASSIGNING FIELD-SYMBOL(<t_a>).
    ls_rep-ktopl = <t_a>-ktopl.
    ls_rep-saknr = <t_a>-saknr.
    APPEND ls_rep TO lt_rep.
  ENDLOOP.

**********************************************************************
*SKAT
  CLEAR: lt_fields[], lt_data[].
  p_inp = 'SKAT'.
  CALL FUNCTION 'RFC_READ_TABLE' DESTINATION p_dest
    EXPORTING
      query_table          = p_inp
    TABLES
      options              = lt_opt
      fields               = lt_fields
      data                 = lt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  IF lt_data[] IS NOT INITIAL.
    CREATE DATA obj_data TYPE TABLE OF (p_inp).
    ASSIGN obj_data->* TO <fs_table>.
    FREE : obj_data.
    CREATE DATA obj_data TYPE (p_inp).
    ASSIGN obj_data->* TO <fs_wa>.
    DESCRIBE TABLE lt_fields LINES sy-tfill.
    IF sy-subrc IS INITIAL.
      lc_cnt = sy-tfill.
    ENDIF.
    LOOP AT lt_data INTO wa_data.
      DO lc_cnt TIMES.
        READ TABLE lt_fields INTO ls_fld INDEX sy-index.
        IF sy-subrc IS INITIAL.
          ASSIGN COMPONENT ls_fld-fieldname OF STRUCTURE <fs_wa> TO <lv_field>.
          IF <lv_field> IS ASSIGNED AND sy-subrc IS INITIAL.
            MOVE : wa_data-wa+ls_fld-offset(ls_fld-length) TO <lv_field>.
          ENDIF.
        ENDIF.
      ENDDO.
      APPEND : <fs_wa> TO <fs_table>.
      CLEAR : wa_data-wa.
    ENDLOOP.
  ENDIF.
  IF <fs_table> IS ASSIGNED.
    t_skat[] = <fs_table>[].
  ENDIF.
  UNASSIGN <fs_table>.
*End of SKAT
**********************************************************************
**********************************************************************
*SKB1
  CLEAR: lt_fields[], lt_data[], lt_opt.
  p_inp = 'SKB1'.
  CLEAR:  t_fields,  t_fields[].

  LOOP AT so_saknr.
    t_fields-shlpfield = 'SAKNR'.
    t_fields-sign      = so_saknr-sign.
    t_fields-option    = so_saknr-option.
    t_fields-low       = so_saknr-low.
    t_fields-high      = so_saknr-high.
    APPEND t_fields.
  ENDLOOP.

  LOOP AT so_bukrs.
    t_fields-shlpfield = 'BUKRS'.
    t_fields-sign      = so_bukrs-sign.
    t_fields-option    = so_bukrs-option.
    t_fields-low       = so_bukrs-low.
    t_fields-high      = so_bukrs-high.
    APPEND t_fields.
  ENDLOOP.

  CALL FUNCTION 'F4_CONV_SELOPT_TO_WHERECLAUSE'
    IMPORTING
      where_clause = lv_where
    TABLES
      selopt_tab   = t_fields.

  CLEAR: lt_opt, lt_opt[].
  CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
    EXPORTING
      i_string               = lv_where
      i_tabline_length       = 72
*     I_UNICODE              =
    TABLES
      et_table               = lt_opt.
*  ls_opt-text = lv_where.
*  APPEND ls_opt TO lt_opt.

  CALL FUNCTION 'RFC_READ_TABLE' DESTINATION p_dest
    EXPORTING
      query_table          = p_inp
    TABLES
      options              = lt_opt
      fields               = lt_fields
      data                 = lt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  IF lt_data[] IS NOT INITIAL.
    CREATE DATA obj_data TYPE TABLE OF (p_inp).
    ASSIGN obj_data->* TO <fs_table>.
    FREE : obj_data.
    CREATE DATA obj_data TYPE (p_inp).
    ASSIGN obj_data->* TO <fs_wa>.
    DESCRIBE TABLE lt_fields LINES sy-tfill.
    IF sy-subrc IS INITIAL.
      lc_cnt = sy-tfill.
    ENDIF.
    LOOP AT lt_data INTO wa_data.
      DO lc_cnt TIMES.
        READ TABLE lt_fields INTO ls_fld INDEX sy-index.
        IF sy-subrc IS INITIAL.
          ASSIGN COMPONENT ls_fld-fieldname OF STRUCTURE <fs_wa> TO <lv_field>.
          IF <lv_field> IS ASSIGNED AND sy-subrc IS INITIAL.
            MOVE : wa_data-wa+ls_fld-offset(ls_fld-length) TO <lv_field>.
          ENDIF.
        ENDIF.
      ENDDO.
      APPEND : <fs_wa> TO <fs_table>.
      CLEAR : wa_data-wa.
    ENDLOOP.
  ENDIF.
  IF <fs_table> IS ASSIGNED.
    t_skb1[] = <fs_table>[].
  ENDIF.
  UNASSIGN <fs_table>.
*End of SKAT
**********************************************************************
*CSKA
  CLEAR: lt_fields[], lt_data[].
  p_inp = 'CSKA'.
  CLEAR:  t_fields,  t_fields[].
  LOOP AT so_saknr.
    t_fields-shlpfield = 'KSTAR'.
    t_fields-sign      = so_saknr-sign.
    t_fields-option    = so_saknr-option.
    t_fields-low       = so_saknr-low.
    t_fields-high      = so_saknr-high.
    APPEND t_fields.
  ENDLOOP.

  LOOP AT so_ktopl.
    t_fields-shlpfield = 'KTOPL'.
    t_fields-sign      = so_ktopl-sign.
    t_fields-option    = so_ktopl-option.
    t_fields-low       = so_ktopl-low.
    t_fields-high      = so_ktopl-high.
    APPEND t_fields.
  ENDLOOP.

  CALL FUNCTION 'F4_CONV_SELOPT_TO_WHERECLAUSE'
    IMPORTING
      where_clause = lv_where
    TABLES
      selopt_tab   = t_fields.

  CLEAR: lt_opt, lt_opt[].
  CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
    EXPORTING
      i_string               = lv_where
      i_tabline_length       = 72
*     I_UNICODE              =
    TABLES
      et_table               = lt_opt.

  CALL FUNCTION 'RFC_READ_TABLE' DESTINATION p_dest
    EXPORTING
      query_table          = p_inp
    TABLES
      options              = lt_opt
      fields               = lt_fields
      data                 = lt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  IF lt_data[] IS NOT INITIAL.
    CREATE DATA obj_data TYPE TABLE OF (p_inp).
    ASSIGN obj_data->* TO <fs_table>.
    FREE : obj_data.
    CREATE DATA obj_data TYPE (p_inp).
    ASSIGN obj_data->* TO <fs_wa>.
    DESCRIBE TABLE lt_fields LINES sy-tfill.
    IF sy-subrc IS INITIAL.
      lc_cnt = sy-tfill.
    ENDIF.
    LOOP AT lt_data INTO wa_data.
      DO lc_cnt TIMES.
        READ TABLE lt_fields INTO ls_fld INDEX sy-index.
        IF sy-subrc IS INITIAL.
          ASSIGN COMPONENT ls_fld-fieldname OF STRUCTURE <fs_wa> TO <lv_field>.
          IF <lv_field> IS ASSIGNED AND sy-subrc IS INITIAL.
            MOVE : wa_data-wa+ls_fld-offset(ls_fld-length) TO <lv_field>.
          ENDIF.
        ENDIF.
      ENDDO.
      APPEND : <fs_wa> TO <fs_table>.
      CLEAR : wa_data-wa.
    ENDLOOP.
  ENDIF.
  IF <fs_table> IS ASSIGNED.
    t_cska[] = <fs_table>[].
  ENDIF.
  UNASSIGN <fs_table>.
*End of CSKA
**********************************************************************
*CSKB
  CLEAR: lt_fields[], lt_data[].
  p_inp = 'CSKB'.
  CLEAR:  t_fields,  t_fields[].
  LOOP AT so_saknr.
    t_fields-shlpfield = 'KSTAR'.
    t_fields-sign      = so_saknr-sign.
    t_fields-option    = so_saknr-option.
    t_fields-low       = so_saknr-low.
    t_fields-high      = so_saknr-high.
    APPEND t_fields.
  ENDLOOP.

  LOOP AT so_kokrs.
    t_fields-shlpfield = 'KOKRS'.
    t_fields-sign      = so_kokrs-sign.
    t_fields-option    = so_kokrs-option.
    t_fields-low       = so_kokrs-low.
    t_fields-high      = so_kokrs-high.
    APPEND t_fields.
  ENDLOOP.

  CALL FUNCTION 'F4_CONV_SELOPT_TO_WHERECLAUSE'
    IMPORTING
      where_clause = lv_where
    TABLES
      selopt_tab   = t_fields.

  CLEAR: lt_opt, lt_opt[].
  CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
    EXPORTING
      i_string               = lv_where
      i_tabline_length       = 72
*     I_UNICODE              =
    TABLES
      et_table               = lt_opt.
  CALL FUNCTION 'RFC_READ_TABLE' DESTINATION p_dest
    EXPORTING
      query_table          = p_inp
    TABLES
      options              = lt_opt
      fields               = lt_fields
      data                 = lt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  IF lt_data[] IS NOT INITIAL.
    CREATE DATA obj_data TYPE TABLE OF (p_inp).
    ASSIGN obj_data->* TO <fs_table>.
    FREE : obj_data.
    CREATE DATA obj_data TYPE (p_inp).
    ASSIGN obj_data->* TO <fs_wa>.
    DESCRIBE TABLE lt_fields LINES sy-tfill.
    IF sy-subrc IS INITIAL.
      lc_cnt = sy-tfill.
    ENDIF.
    LOOP AT lt_data INTO wa_data.
      DO lc_cnt TIMES.
        READ TABLE lt_fields INTO ls_fld INDEX sy-index.
        IF sy-subrc IS INITIAL.
          ASSIGN COMPONENT ls_fld-fieldname OF STRUCTURE <fs_wa> TO <lv_field>.
          IF <lv_field> IS ASSIGNED AND sy-subrc IS INITIAL.
            MOVE : wa_data-wa+ls_fld-offset(ls_fld-length) TO <lv_field>.
          ENDIF.
        ENDIF.
      ENDDO.
      APPEND : <fs_wa> TO <fs_table>.
      CLEAR : wa_data-wa.
    ENDLOOP.
  ENDIF.
  IF <fs_table> IS ASSIGNED.
    t_cskb[] = <fs_table>[].
  ENDIF.
  UNASSIGN <fs_table>.
*End of CSKB


**********************************************************************
* Comparing
  SORT lt_rep BY ktopl saknr.
  DELETE ADJACENT DUPLICATES FROM lt_rep.
  LOOP AT lt_rep ASSIGNING FIELD-SYMBOL(<rep>).
**********************************************************************
*    SKA1 compare
    READ TABLE s_ska1 WITH KEY ktopl = <rep>-ktopl saknr = <rep>-saknr ASSIGNING FIELD-SYMBOL(<sa>).
    READ TABLE t_ska1 WITH KEY ktopl = <rep>-ktopl saknr = <rep>-saknr ASSIGNING FIELD-SYMBOL(<ta>).
    IF <sa> IS ASSIGNED AND <ta> IS ASSIGNED.
      IF      <sa>-xbilk = <ta>-xbilk
          AND <sa>-bilkt = <ta>-bilkt
          AND <sa>-gvtyp = <ta>-gvtyp
          AND <sa>-ktoks = <ta>-ktoks
          AND <sa>-xloev = <ta>-xloev
          AND <sa>-xspea = <ta>-xspea
          AND <sa>-xspeb = <ta>-xspeb
          AND <sa>-xspep = <ta>-xspeb
          AND <sa>-glaccount_type = <ta>-glaccount_type
          AND <sa>-glaccount_subtype = <ta>-glaccount_subtype.
        <rep>-t_ska1 = lv_green. "Ok
      ELSE.
        <rep>-t_ska1 = lv_yellow. "Some fields not ok
      ENDIF.
    ELSE.
      <rep>-t_ska1 = lv_red. "do not exist at one of the systems
    ENDIF.
    UNASSIGN: <sa>, <ta>.
*    End of SKA1
**********************************************************************
*    SKAT
    LOOP AT so_langu.
      READ TABLE s_skat WITH KEY ktopl = <rep>-ktopl saknr = <rep>-saknr spras = so_langu-low ASSIGNING FIELD-SYMBOL(<st>).
      READ TABLE t_skat WITH KEY ktopl = <rep>-ktopl saknr = <rep>-saknr spras = so_langu-low ASSIGNING FIELD-SYMBOL(<tt>).
      IF <st> IS ASSIGNED AND <tt> IS ASSIGNED.
        IF <st>-TXT20 = <tt>-TXT20 and <st>-TXT50 = <tt>-TXT50.
          IF  <rep>-t_skat <> lv_yellow and  <rep>-t_skat <> lv_red. "Some fields not ok. "Some fields not ok.
            <rep>-t_skat = lv_green. "Ok
          ENDIF.
        ELSE.
          IF <rep>-t_skat <> lv_red.
             <rep>-t_skat = lv_yellow. "Some fields not ok
          ENDIF.
        ENDIF.
      ELSE.
        <rep>-t_skat = lv_red. "do not exist at one of the systems
      ENDIF.
      UNASSIGN: <st>, <tt>.
    ENDLOOP.
*    End of SKAT
**********************************************************************
*    SKB1
    LOOP AT so_bukrs.
      READ TABLE s_skb1 WITH KEY saknr = <rep>-saknr bukrs = so_bukrs-low ASSIGNING FIELD-SYMBOL(<sb>).
      READ TABLE t_skb1 WITH KEY saknr = <rep>-saknr bukrs = so_bukrs-low ASSIGNING FIELD-SYMBOL(<tb>).
      IF <sb> IS ASSIGNED AND <tb> IS ASSIGNED.
        IF    <sb>-BEGRU = <tb>-BEGRU
          and <sb>-FDGRV = <tb>-FDGRV
          and <sb>-FDLEV = <tb>-FDLEV
          and <sb>-FIPLS = <tb>-FIPLS
          and <sb>-FSTAG = <tb>-FSTAG
          and <sb>-HBKID = <tb>-HBKID
          and <sb>-HKTID = <tb>-HKTID
          and <sb>-KDFSL = <tb>-KDFSL
          and <sb>-MITKZ = <tb>-MITKZ
          and <sb>-MWSKZ = <tb>-MWSKZ
          and <sb>-STEXT = <tb>-STEXT
          and <sb>-VZSKZ = <tb>-VZSKZ
          and <sb>-WAERS = <tb>-WAERS
          and <sb>-WMETH = <tb>-WMETH
          and <sb>-XGKON = <tb>-XGKON
          and <sb>-XINTB = <tb>-XINTB
          and <sb>-XKRES = <tb>-XKRES
          and <sb>-XKRES = <tb>-XKRES
          and <sb>-XLOEB = <tb>-XLOEB
          and <sb>-XNKON = <tb>-XNKON
          and <sb>-XOPVW = <tb>-XOPVW
          and <sb>-XSPEB = <tb>-XSPEB
          and <sb>-ZUAWA = <tb>-ZUAWA
          and <sb>-ALTKT = <tb>-ALTKT
          and <sb>-XMITK = <tb>-XMITK
          and <sb>-RECID = <tb>-RECID
          and <sb>-FIPOS = <tb>-FIPOS
          and <sb>-XMWNO = <tb>-XMWNO
          and <sb>-XSALH = <tb>-XSALH
          and <sb>-BEWGP = <tb>-BEWGP
          and <sb>-INFKY = <tb>-INFKY
          and <sb>-TOGRU = <tb>-TOGRU
          and <sb>-XLGCLR = <tb>-XLGCLR
          and <sb>-X_UJ_CLR = <tb>-X_UJ_CLR
          and <sb>-MCAKEY = <tb>-MCAKEY.
          IF  <rep>-t_skb1 <> lv_yellow and  <rep>-t_skb1 <> lv_red. "Some fields not ok. "Some fields not ok.
            <rep>-t_skb1 = lv_green. "Ok
          ENDIF.
        ELSE.
          IF <rep>-t_skb1 <> lv_red.
             <rep>-t_skb1 = lv_yellow. "Some fields not ok
          ENDIF.
        ENDIF.
      ELSE.
        IF <sb> IS NOT ASSIGNED AND <tb> IS NOT ASSIGNED AND <rep>-t_skb1 <> lv_red.
          <rep>-t_skb1 = lv_grey. "do not exist at one both systems at CC level
        ELSE.
          <rep>-t_skb1 = lv_red. "do not exist at one of the systems
        ENDIF.
      ENDIF.
      UNASSIGN: <sb>, <tb>.
    ENDLOOP.
*    End of SKB1
**********************************************************************
*    CSKA
    READ TABLE s_cska WITH KEY ktopl = <rep>-ktopl kstar = <rep>-saknr ASSIGNING FIELD-SYMBOL(<sca>).
    READ TABLE t_cska WITH KEY ktopl = <rep>-ktopl kstar = <rep>-saknr ASSIGNING FIELD-SYMBOL(<tca>).
    IF <sca> IS ASSIGNED AND <tca> IS ASSIGNED.
      IF     <sca>-STEKZ = <tca>-STEKZ
         AND <sca>-ZAHKZ = <tca>-ZAHKZ
         AND <sca>-KSTSN = <tca>-KSTSN
         AND <sca>-FUNC_AREA = <tca>-FUNC_AREA.
        <rep>-t_cska = lv_green. "Ok
      ELSE.
        <rep>-t_cska = lv_yellow. "Some fields not ok
      ENDIF.
    ELSE.
      IF <sca> IS NOT ASSIGNED AND <tca> IS NOT ASSIGNED.
        <rep>-t_cska = lv_grey. "do not exist at one both systems at CO level
      ELSE.
        <rep>-t_cska = lv_red. "do not exist at one of the systems
      endif.
    ENDIF.
    UNASSIGN: <sca>, <tca>.
*    End of CSKA
**********************************************************************
*    CSKB
    LOOP AT so_kokrs.
      READ TABLE s_cskb WITH KEY kstar = <rep>-saknr kokrs = so_kokrs-low ASSIGNING FIELD-SYMBOL(<scb>).
      READ TABLE t_cskb WITH KEY kstar = <rep>-saknr kokrs = so_kokrs-low ASSIGNING FIELD-SYMBOL(<tcb>).
      IF <scb> IS ASSIGNED AND <tcb> IS ASSIGNED.
        IF  <scb>-KATYP = <tcb>-KATYP.
          IF  <rep>-t_cskb <> lv_yellow and  <rep>-t_cskb <> lv_red. "Some fields not ok. "Some fields not ok.
            <rep>-t_cskb = lv_green. "Ok
          ENDIF.
        ELSE.
          IF <rep>-t_cskb <> lv_red.
             <rep>-t_cskb = lv_yellow. "Some fields not ok
          ENDIF.
        ENDIF.
      ELSE.
        IF <scb> IS NOT ASSIGNED AND <tcb> IS NOT ASSIGNED AND  <rep>-t_cskb <> lv_red.
          <rep>-t_cskb = lv_grey. "do not exist at one both systems at CC level
        ELSE.
          <rep>-t_cskb = lv_red. "do not exist at one of the systems
        ENDIF.
      ENDIF.
      UNASSIGN: <scb>, <tcb>.
    ENDLOOP.
*    End of CSKB
  ENDLOOP.
**********************************************************************
*ALV
  TRY.
      cl_salv_table=>factory( IMPORTING  r_salv_table   = DATA(alv)
                              CHANGING   t_table        = lt_rep  ).
    CATCH cx_salv_msg.
  ENDTRY.

  alv->get_layout( )->set_key( VALUE #( report = sy-repid ) ).
  alv->get_layout( )->set_default( abap_true ).
  alv->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
  alv->get_functions( )->set_all( abap_true ).
  DATA: columns TYPE REF TO cl_salv_columns_table,
        column  TYPE REF TO cl_salv_column.
  TRY.
      columns = alv->get_columns( ).
      column = columns->get_column( 'T_SKA1' ).
      column->set_short_text( 'SKA1' ).
      column->set_medium_text( 'SKA1' ).
      column->set_long_text( 'SKA1' ).
      column = columns->get_column( 'T_SKB1' ).
      column->set_short_text( 'SKB1' ).
      column->set_medium_text( 'SKB1' ).
      column->set_long_text( 'SKB1' ).
      column = columns->get_column( 'T_SKAT' ).
      column->set_short_text( 'SKAT' ).
      column->set_medium_text( 'SKAT' ).
      column->set_long_text( 'SKAT' ).
      column = columns->get_column( 'T_CSKA' ).
      column->set_short_text( 'CSKA' ).
      column->set_medium_text( 'CSKA' ).
      column->set_long_text( 'CSKA' ).
      column = columns->get_column( 'T_CSKB' ).
      column->set_short_text( 'CSKB' ).
      column->set_medium_text( 'CSKB' ).
      column->set_long_text( 'CSKB' ).
      column = columns->get_column( 'TOTAL' ).
      column->set_short_text( 'TotStat' ).
      column->set_medium_text( 'TotStat' ).
      column->set_long_text( 'TotalStatus' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  DATA: lo_events     TYPE REF TO cl_salv_events_table.
  lo_events = alv->get_event( ).
  SET HANDLER cl_event_handler=>on_double_click FOR lo_events.

  CALL METHOD alv->display.
