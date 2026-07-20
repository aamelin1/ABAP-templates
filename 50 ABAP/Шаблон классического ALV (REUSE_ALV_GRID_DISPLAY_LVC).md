Простой шаблон для отчетов с классическим ALV

GUI статус можно скопировать из группы функций **SALV**, статус **STANDARD** "Standard for General List Output"

```abap
*&---------------------------------------------------------------------*
*& Report ZFI_template
*&---------------------------------------------------------------------*
*& Амелин А. (Шаблон AVL отчета)
*&---------------------------------------------------------------------*
REPORT ZFI_xxxxxxx.
TABLES: ...

*&---------------------------------------------------------------------*
PARAMETERS p_bukrs TYPE bukrs DEFAULT 'XXXX'.
SELECT-OPTIONS so_... FOR ...-....
PARAMETERS: variant LIKE disvariant-variant.

*&---------------------------------------------------------------------*
DATA: it_... TYPE STANDARD TABLE OF ZFI_....
DATA: fcat         TYPE lvc_t_fcat,
      hcat         TYPE lvc_s_fcat,
      glay         TYPE lvc_s_glay,     
      gs_layout_fm TYPE lvc_s_layo,
      g_save       TYPE c VALUE 'X',
      g_variant    TYPE disvariant,
      gx_variant   TYPE disvariant,
      g_exit       TYPE c.

*&---------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT .
  PERFORM ssc_output.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  PERFORM f4_layout.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  PERFORM show_alv.

*&---------------------------------------------------------------------*
FORM GET_DATA .
  ...
ENDFORM.

*&---------------------------------------------------------------------*
FORM SHOW_ALV .
**************************************
CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZFI_...'
    CHANGING
      CT_FIELDCAT            = fcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
  ENDIF.

  LOOP AT fcat ASSIGNING FIELD-SYMBOL(<f>).
    CASE <f>-fieldname.
      WHEN 'XXXXX'. 
        <f>-tech = abap_true. "скрыть(тех)
        <f>-coltext   = '...'. "тексты
        <f>-scrtext_l = '...'. "тексты
        <f>-scrtext_m = '...'. "тексты
        <f>-scrtext_s = '...'. "тексты
        <f>-emphasize = 'C210'. "цвет
    ENDCASE.
  ENDLOOP.

**************************************
  gs_layout_fm-cwidth_opt = 'X'.
  gs_layout_fm-zebra = 'X'.
  g_variant-report  = sy-repid.
  g_variant-variant = variant.
  
  
**************************************
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc            = gs_layout_fm
      I_CALLBACK_PROGRAM       = sy-cprog
      I_CALLBACK_PF_STATUS_SET = 'SETPF'
      I_CALLBACK_USER_COMMAND  = 'UCOMM'
      I_GRID_SETTINGS          = glay
      IT_FIELDCAT_LVC          = fcat
      i_save                   = g_save
      is_variant               = g_variant
    TABLES
      T_OUTTAB                 = it_...
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
  FORM UCOMM USING r_ucomm LIKE sy-ucomm
     rs_selfield TYPE slis_selfield.
     rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN '&IC1'.
      DATA: ls_rep LIKE LINE OF it_rep.
      READ TABLE it_rep INTO ls_rep INDEX rs_selfield-tabindex.
      ...
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM SETPF USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM ssc_output.
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
ENDFORM.

*&---------------------------------------------------------------------*
FORM F4_layout.
  g_save = 'A'.
  CLEAR g_variant.
  g_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      variant = gx_variant-variant.
    ENDIF.
  ENDIF.
ENDFORM.
```

---
**Исходный код:**
- [ZFI_ALV_FM_template.abap](../90%20Source%20code/ZFI_ALV_FM_template.abap)
- [ALV_grid_templ1.abap](../90%20Source%20code/ALV_grid_templ1.abap)
