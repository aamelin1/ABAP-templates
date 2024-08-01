
Simple way to show ALV in OO style:
``` abap
REPORT z<name>.
TABLES: acdoca.
SELECT-OPTIONS: so_bukrs FOR acdoca-rbukrs MEMORY ID buk,  
                so_rldnr FOR acdoca-rldnr DEFAULT '0L' OBLIGATORY,  
                so_koart FOR acdoca-koart DEFAULT 'M' OBLIGATORY NO INTERVALS.

START-OF-SELECTION.

"Select data
  SELECT *  
    FROM acdoca  
    INTO TABLE @DATA(it_rep)  
    WHERE rbukrs IN @so_bukrs  
      AND rldnr IN @so_rldnr  
      AND koart IN @so_koart.

"Var for ALV
DATA: go_alv        TYPE REF TO cl_salv_table.  
DATA: lr_columns    TYPE REF TO cl_salv_columns_table.  
DATA: lr_column     TYPE REF TO cl_salv_column_table.  
DATA: lr_functions  TYPE REF TO cl_salv_functions_list.  
DATA: gr_display    TYPE REF TO cl_salv_display_settings.  
DATA: gr_selections TYPE REF TO cl_salv_selections.

_**ALV Class_  
  TRY.  
      cl_salv_table=>factory(  
        IMPORTING  
          r_salv_table = go_alv  
        CHANGING  
          t_table      = it_rep[] ).  
    CATCH cx_salv_msg.  
  ENDTRY.  
  
_**Enable function buttons_  
  lr_functions = go_alv->get_functions( ).  
  lr_functions->set_all( 'X' ).  
  
_**Optimize Column_  
  lr_columns = go_alv->get_columns( ).  
  lr_columns->set_optimize( 'X' ).  
  
_**Enable Zebra style_  
  gr_display = go_alv->get_display_settings( ).  
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).  
  
_**Display ALV_  
  go_alv->display( ).
```
