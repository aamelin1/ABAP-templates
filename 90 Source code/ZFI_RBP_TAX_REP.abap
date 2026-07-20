*&---------------------------------------------------------------------*
*& Report ZFI_RBP_TAX_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_RBP_TAX_REP.
INCLUDE ZFI_RBP_TAX_REP_TOP.
INCLUDE ZFI_RBP_TAX_REP_F01.


INITIALIZATION.

  DATA: lt_acc TYPE STANDARD TABLE OF ACEAED1000004.
  FIELD-SYMBOLS <fs_acc> like LINE OF lt_acc.
  SELECT *
    FROM ACEAED1000004
    INTO TABLE lt_acc.
    LOOP AT lt_acc ASSIGNING <fs_acc>.
      so_racct-sign = 'I'.
      so_racct-option = 'EQ'.
      so_racct-low = <fs_acc>-TARGET2.
      APPEND so_racct.
    ENDLOOP.


START-OF-SELECTION.

  PERFORM get_data.
  PERFORM show_alv.
