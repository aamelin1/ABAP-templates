Popup with ALV table:
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
