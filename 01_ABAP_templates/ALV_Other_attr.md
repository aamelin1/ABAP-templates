# Some ALV features

- [Colors](#Color-options)
- [Slection mode](#ALV-selection-mode)

## Color options
To set color for **whole column** you may use this:
  ``` abap
  CAST cl_salv_column_table( o_alv->get_columns(  )->get_column( 'FLD_NAME' ) )->set_color( 
  VALUE lvc_s_colo( col = col_total int = 1 inv = 0 ) )
  ```

Color codes:

| name | code | Int (x) | Inv (y) | Color code | Color |
|----|----|----|----|----|----|
| col_heading | 1 | 0/1 | 0/1 | 1xy | GreyBlue  |
| col_normal  | 2 | 0/1 | 0/1 | 2xy | LightGrey |
| col_total   | 3 | 0/1 | 0/1 | 3xy | Yellow    |
| col_key     | 4 | 0/1 | 0/1 | 4xy | BlueGreen |
| col_positive| 5 | 0/1 | 0/1 | 5xy | Green     |
| col_negative| 6 | 0/1 | 0/1 | 6xy | Red       |
| col_group   | 7 | 0/1 | 0/1 | 7xy | Violet    |

How it looks in SAP ALV:

![ALV Colors](IMGs/IMG_ALC_Colors.png)


## ALV selection mode
You can specify rows/cells selection behaviour by setting this atribute: 
``` abap
o_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>multiple ).
```

Available selection types:

|  Mode  | 
| -| 
|  SINGLE |  
|  MULTIPLE |  
|  CELL |  
|  ROW_COLUMN |  
|  NONE |  