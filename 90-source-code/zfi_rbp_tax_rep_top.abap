*&---------------------------------------------------------------------*
*& Include          ZFI_RBP_TAX_REP_TOP
*&---------------------------------------------------------------------*
TABLES: ACAC_OBJECTS, BKPF, acdoca.

INCLUDE EXCEL__C.

PARAMETERS p_bukrs TYPE BKPF-BUKRS DEFAULT '1000'.
SELECT-OPTIONS so_OBJT FOR ACAC_OBJECTS-ACAC_OBJTYPE.
SELECT-OPTIONS so_NUMB FOR ACAC_OBJECTS-ACAC_OBJNUMBER.
SELECT-OPTIONS so_budat FOR BKPF-BUDAT OBLIGATORY.
PARAMETERS p_empt AS CHECKBOX DEFAULT 'X'.
SELECT-OPTIONS so_racct FOR acdoca-racct NO-DISPLAY.


DATA: it_rep TYPE STANDARD TABLE OF ZFI_RBP_TAX.

DATA: fcat TYPE lvc_t_fcat,
      hcat TYPE lvc_s_fcat,
      glay TYPE lvc_s_glay,
      gs_layout_fm   TYPE lvc_s_layo.


"----- Объявления для DOI -----
DATA: go_control TYPE REF TO i_oi_container_control,
      go_document1 TYPE REF TO i_oi_document_proxy,
      go_container TYPE REF TO cl_gui_custom_container,
      go_spreadsheet TYPE REF TO i_oi_spreadsheet.
DATA: document_handle TYPE CNTL_HANDLE.
" OLE
DATA: g_excel          TYPE ole2_object,
      sheet TYPE ole2_object,
      CELL1 TYPE ole2_object,
      CELL2 TYPE ole2_object,
      CELLRANGE TYPE ole2_object,
      interior TYPE ole2_object,
      font     TYPE ole2_object,
      gs_activewindow TYPE  ole2_object.

  DATA: m1(6), m2(6), m3(6), m4(6), m5(6), m6(6), m7(6), m8(6), m9(6), m10(6),
        m11(6), m12(6), m13(6), lv_per(6), lv_i TYPE i, n TYPE i, lv_j TYPE i, i(2).
