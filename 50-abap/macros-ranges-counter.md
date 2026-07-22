---
title: "ABAP шаблоны — макрос BDC, ranges, прогресс-индикатор, popup"
keywords: DEFINE, END-OF-DEFINITION, macro, макрос, BDCDATA, CALL TRANSACTION, RANGE OF, RSDSSELOPT_T, CL_PROGRESS_INDICATOR, CATSXT_SIMPLE_TEXT_EDITOR, CL_RECA_GUI_F4_POPUP, RP_LAST_DAY_OF_MONTHS, dynamic SQL
status: ok
---

# ABAP шаблоны — макрос BDC, ranges, прогресс-индикатор, popup

### Макрос для пакетников
Объявление макроса
```abap
*   Macro to fill the necessary BDC data
FIELD-SYMBOLS:
      <ls_bdc> TYPE bdcdata.
DEFINE add_bdc.
  APPEND INITIAL LINE TO lt_bdc ASSIGNING <ls_bdc>.
  <ls_bdc>-fnam = &1.
  <ls_bdc>-fval = &2.
  <ls_bdc>-program  = &3.
  <ls_bdc>-dynpro   = &4.
  <ls_bdc>-dynbegin = &5.
END-OF-DEFINITION.
```
Вызов транзакции:
```abap
DATA: lt_bdc TYPE TABLE OF bdcdata,
      it_msg type standard table of bdcmsgcoll.
      CLEAR: lt_bdc[], it_msg, it_msg[].
      
      add_bdc: ' ' ' '  'saplaist' '0100' 'x',
               'bdc_okcode'  '=entedel' '' '' '',
               'anla-anln1'  <fs_anla>-anln1 '' '' ''.
*   Call transaction with the batch input data
      CALL TRANSACTION 'XXXX'
        USING lt_bdc
        MODE 'E'
        UPDATE 'S'
        MESSAGES INTO it_msg.
      COMMIT WORK AND WAIT.
```
### Ranges
```abap
TYPES: tt_BUKRS   TYPE RANGE OF bukrs.
DATA:  rg_BUKRS   TYPE tt_BUKRS,
APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'XXXX' ) TO rg_BUKRS.
```
или так (удобно для select-options)
```abap
DATA(so_xxxx) = VALUE rsdsselopt_t( sign = 'I' option = 'BT' ( low = 'XXX' high = 'YYY' ) 
```
### Счетчик
```abap
  lv_tot = lines( it_... ).
  LOOP AT it_...
    lv_idx = sy-tabix.
    cl_progress_indicator=>progress_indicate( 
      EXPORTING 
        i_text       = 'Processing...'
        i_processed  = lv_idx
        i_total      = lv_tot
        i_output_immediately   = ' ' ).
  ENDLOOP.
```
Или так
```abap
cl_progress_indicator=>progress_indicate(
        i_text = |Processing: { sy-tabix }/{ lines( it_... ) }|
        i_output_immediately = abap_true ).
```


Popup window with text editor:
```abap
DATA: lt_txt TYPE catsxt_longtext_itab.
        CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
          EXPORTING
            i_string         = <f_data>-sel_str
            i_tabline_length = 72
          TABLES
            et_table         = lt_txt.
        CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
          EXPORTING
            im_title        = 'SQL:'
            im_display_mode = 'X'
          CHANGING
            ch_text         = lt_txt.
```

Popup simple ALV:
```abap
     SELECT  ...
          FROM ...
          INTO TABLE @DATA(lt_popup)
          WHERE ...

        CALL METHOD cl_reca_gui_f4_popup=>factory_grid
          EXPORTING
            it_f4value     = lt_popup[]
            if_multi       = abap_false
            id_title       = 'Popup header:'
          RECEIVING
            ro_f4_instance = DATA(go_popup).

        CALL METHOD go_popup->display
          EXPORTING
            id_start_column = 5
            id_start_line   = 5
            id_end_column   = 70
            id_end_line     = 15
          IMPORTING
            et_result       = lt_popup[]
            ef_cancelled    = DATA(gf_choice).
```


Last day of month:
```abap
CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = so_datum-low
      IMPORTING
        last_day_of_month = so_datum-high
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
```

Dynamic SQL select:
```abap
DATA:       lt_where            TYPE rsds_where_tab,
            l_tabname           TYPE tabname,
            lt_group_by_checked TYPE STANDARD TABLE OF string,
            lt_select           TYPE STANDARD TABLE OF string,
 
TRY.
          SELECT (lt_select)
            FROM (l_tabname)
            WHERE (lt_where)
            GROUP BY (lt_group_by_checked)
            INTO TABLE NEW @DATA(dref_tab).
        CATCH cx_sy_open_sql_db.
          MESSAGE 'SQL error' TYPE 'I'.
      ENDTRY ##MG_MISSING.

FIELD-SYMBOLS: <gt_tab> TYPE ANY TABLE.
ASSIGN dref_tab->* TO <gt_tab>.

LOOP AT <gt_tab> ASSIGNING FIELD-SYMBOL(<fs_line>).
  ASSIGN COMPONENT 'FLD_NAME' OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<fs_field_val>).
  IF <fs_field_val> IS ASSIGNED.
    ls_rep-FLD_NAME = <fs_field_val>.
  ENDIF.
ENDLOOP.
```