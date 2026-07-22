*&---------------------------------------------------------------------*
*& Report ZFI_template
*&---------------------------------------------------------------------*
*& ALV FM templaate (Amelin A.)
*&---------------------------------------------------------------------*
REPORT ZFI_.
TABLES: ...

*&---------------------------------------------------------------------*
PARAMETERS p_bukrs TYPE bukrs DEFAULT 'XXXX'.
SELECT-OPTIONS so_... FOR ...-....

*&---------------------------------------------------------------------*
DATA: it_... TYPE STANDARD TABLE OF ZFI_....
DATA: fcat TYPE lvc_t_fcat,
      hcat TYPE lvc_s_fcat,
      glay TYPE lvc_s_glay,
      gs_layout_fm   TYPE lvc_s_layo,
      events TYPE slis_t_event,
      event TYPE slis_alv_event.

*&---------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  PERFORM show_alv.

*&---------------------------------------------------------------------*
FORM GET_DATA .
  ...
ENDFORM.
*&---------------------------------------------------------------------*


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
  
**************************************
  gs_layout_fm-cwidth_opt = 'X'.
  gs_layout_fm-zebra = 'X'.
  
  
**************************************
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc            = gs_layout_fm
      I_CALLBACK_PROGRAM       = sy-cprog
      I_CALLBACK_PF_STATUS_SET = 'SETPF'
      I_CALLBACK_USER_COMMAND  = 'UCOMM'
      I_GRID_SETTINGS          = glay
      IT_FIELDCAT_LVC          = fcat
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