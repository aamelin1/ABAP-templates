
Simple way to show ALV in OO style:
``` abap
REPORT zfi_samples.  
TABLES: tcurt.  
SELECT-OPTIONS: so_spras FOR tcurt-spras DEFAULT sy-langu.  
  
START-OF-SELECTION.  
_"Select data_  
  SELECT *  
    FROM tcurt  
    INTO TABLE @DATA(it_rep)  
    WHERE spras IN @so_spras.  
_"Show ALV_  
  cl_salv_table=>factory( ##EXCP_UNHANDLED[CX_SALV_MSG]  
    IMPORTING  
      r_salv_table = DATA(go_alv)  
    CHANGING  
      t_table      = it_rep[] ).  
  go_alv->get_functions( )->set_all( 'X' ). _"Enable function buttons_  
  go_alv->get_columns( )->set_optimize( 'X' ). _"Optimize Column_  
  go_alv->get_display_settings( )->set_striped_pattern( cl_salv_display_settings=>true )._"Enable Zebra style_  
  go_alv->display( ). _"Display ALV_
```

Result:
![Simple_OO_ALV](IMG/ScreenShot2024-08-01%20at%2020.48.22@2x.png)
