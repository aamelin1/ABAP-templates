
Simple way to show ALV in OO style:
``` abap
REPORT zfi_samples.  
TABLES: tcurt.  
  
SELECT-OPTIONS: so_spras  FOR tcurt-spras DEFAULT sy-langu.  
PARAMETERS:     p_var     TYPE slis_vari.  
  
INITIALIZATION.  
  DATA(ls_key) = VALUE salv_s_layout_key( report = sy-repid ).  
  p_var = cl_salv_layout_service=>get_default_layout( s_key = ls_key )-layout. "set def layout at sscr  
  
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_var.  
  p_var = cl_salv_layout_service=>f4_layouts( s_key = ls_key restrict = if_salv_c_layout=>restrict_none )-layout.  
  
START-OF-SELECTION.  
  "Select data  
  SELECT *  
    FROM tcurt  
    INTO TABLE @DATA(it_rep)  
    WHERE spras IN @so_spras.  
  "SALV  
  cl_salv_table=>factory( ##EXCP_UNHANDLED[CX_SALV_MSG]  
    IMPORTING  
      r_salv_table = DATA(o_alv)  
    CHANGING  
      t_table      = it_rep[] ).  
  
  o_alv->get_display_settings( )->set_list_header( 'Header text' ).  
  o_alv->get_layout( )->set_key( ls_key ).  
  o_alv->get_layout( )->set_save_restriction( cl_salv_layout=>restrict_none ).  
  o_alv->get_layout( )->set_default( abap_true ). "allow to save def layouts 
  o_alv->get_layout( )->set_initial_layout( p_var ). "set layout from sscr 
  o_alv->get_functions( )->set_all( abap_true ). "Enable function buttons
  o_alv->get_columns( )->set_optimize( abap_true ). "Optimize Column
  o_alv->get_display_settings( )->set_striped_pattern( cl_salv_display_settings=>true )."Enable Zebra style 
  o_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>MULTIPLE ). "Selection mode  
  TRY.  
    o_alv->get_columns( )->get_column( 'SPRAS' )->set_long_text( 'Long Name' ). "Set names manualy  
    o_alv->get_columns( )->get_column( 'SPRAS' )->set_medium_text( 'Med Name' ).  
    o_alv->get_columns( )->get_column( 'SPRAS' )->set_short_text( 'Sh Name' ).  
    CAST cl_salv_column_table( o_alv->get_columns(  )->get_column( 'SPRAS' ) )->set_cell_type( if_salv_c_cell_type=>hotspot ). "Set hotspot 
    CAST cl_salv_column_table( o_alv->get_columns(  )->get_column( 'KTEXT' ) )->set_color( VALUE lvc_s_colo( col = col_total int = 1 inv = 0 ) ). "Set color  
  CATCH CX_SALV_NOT_FOUND.  
  ENDTRY.  
  o_alv->display( ). "Display ALV
```

Result:

IMG...

 > **💡 Note**
 > 
 > Color options:
 
| name | code | 
|----|----|
| col_heading | '1' |
| col_normal  | '2' |
| col_total   | '3' |
| col_key     | '4' |
| col_positive| '5' |
| col_negative| '6' |
| col_group   | '7' |

> **💡 Note**
> 
> ALV selection mode (attributes of IF_SALV_C_SELECTION_MODE):

|  Mode  | 
| -| 
|  SINGLE |  
|  MULTIPLE |  
|  CELL |  
|  ROW_COLUMN |  
|  NONE |  