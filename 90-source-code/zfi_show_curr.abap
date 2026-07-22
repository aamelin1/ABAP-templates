*&---------------------------------------------------------------------*
*& Report ZFI_SHOW_CURR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_SHOW_CURR.
TABLES: tcurr.
SELECT-OPTIONS: p_KURST FOR tcurr-KURST no INTERVALS OBLIGATORY DEFAULT 'M'.
SELECT-OPTIONS: p_TCURR FOR tcurr-TCURR no INTERVALS OBLIGATORY DEFAULT 'RUB'.
SELECT-OPTIONS: p_GDATU FOR tcurr-GDATU no INTERVALS.


INITIALIZATION.

START-OF-SELECTION.

DATA: lt_curr TYPE STANDARD TABLE OF tcurr.
DATA: fcat TYPE lvc_t_fcat,
      hcat TYPE lvc_s_fcat,
      glay TYPE lvc_s_glay.



SELECT *
  FROM tcurr
  INTO TABLE lt_curr
  WHERE KURST in p_KURST
    AND GDATU in p_GDATU.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'TCURR'
    CHANGING
      CT_FIELDCAT            = fcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
  ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM       = sy-cprog
      I_CALLBACK_PF_STATUS_SET = 'SETPF'
      IT_FIELDCAT_LVC          = fcat
    TABLES
      T_OUTTAB                 = lt_curr
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

FORM SETPF USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.
