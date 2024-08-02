*&---------------------------------------------------------------------*
*& Report ZBC_LANG_EN
*&---------------------------------------------------------------------*
*&Z Lang swotcher (Amelin A)
*&---------------------------------------------------------------------*
REPORT ZBC_LANG_EN.
CASE sy-tcode.
  WHEN 'ZEN'. SET LOCALE LANGUAGE 'E'.
  WHEN 'ZRU'. SET LOCALE LANGUAGE 'R'.
  WHEN 'ZPT'. SET LOCALE LANGUAGE 'P'.
  WHEN OTHERS.
    exit.
ENDCASE.

CALL FUNCTION 'ABAP4_CALL_TRANSACTION' STARTING NEW TASK 'LANGUAGE'
  EXPORTING
    tcode = 'SESSION_MANAGER'.