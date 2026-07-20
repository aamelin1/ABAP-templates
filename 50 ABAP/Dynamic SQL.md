Dynamic select:
``` abap
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
