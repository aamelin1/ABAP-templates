---
title: "Read table from another SAP system via RFC_READ_TABLE"
keywords: RFC_READ_TABLE, DESTINATION, RFC, чтение из другой системы, remote table read, F4_CONV_SELOPT_TO_WHERECLAUSE, RFC_DB_OPT, TAB512
status: draft
---

# Read table from another SAP system via RFC_READ_TABLE

```abap
 DATA : p_inp(10) TYPE c. 
 DATA: t_fields TYPE TABLE OF  ddshselopt WITH HEADER LINE,
       lv_where TYPE string.
        
 DATA: lt_opt    TYPE STANDARD TABLE OF rfc_db_opt,
       ls_opt    LIKE LINE OF lt_opt,
       lt_fields TYPE STANDARD TABLE OF rfc_db_fld,
       lt_data   TYPE STANDARD TABLE OF tab512.       

	p_inp = 'SKA1'.

  t_fields-shlpfield = 'SAKNR'.
  t_fields-sign      = so_saknr-sign.
  t_fields-option    = so_saknr-option.
  t_fields-low       = so_saknr-low.
  t_fields-high      = so_saknr-high.
  APPEND t_fields.

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
```