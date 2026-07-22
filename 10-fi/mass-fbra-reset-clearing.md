---
title: "Mass reset clearing (FBRA) — batch input report"
keywords: FBRA, reset clearing, сброс выравнивания, массовая обработка, mass processing, BDC, batch input, SAPMF05R, STGRD, BKPF, KDF, exchange rate difference popup
status: draft
summary: "Z-report ZFI_MASS_FBRA: массовый сброс выравнивания через BDC по выборке из BKPF, с обработкой попапа курсовых разниц (KDF)"
---

# Mass reset clearing (FBRA) — batch input report

```abap
*&---------------------------------------------------------------------*
*& Report ZFI_MASS_FBRA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_MASS_FBRA.
TABLES: BKPF.
*   Macro to fill the necessary BDC data
FIELD-SYMBOLS: <ls_bdc> TYPE bdcdata.
DEFINE add_bdc.
  APPEND INITIAL LINE TO lt_bdc ASSIGNING <ls_bdc>.
  <ls_bdc>-fnam = &1.
  <ls_bdc>-fval = &2.
  <ls_bdc>-program  = &3.
  <ls_bdc>-dynpro   = &4.
  <ls_bdc>-dynbegin = &5.
END-OF-DEFINITION.

SELECT-OPTIONS: so_bukrs FOR bkpf-bukrs,
                so_gjahr FOR bkpf-gjahr,
                so_belnr FOR bkpf-belnr.
PARAMETERS:     p_STGRD  TYPE STGRD DEFAULT '01'.

START-OF-SELECTION.

  SELECT *
    FROM BKPF
    WHERE bukrs in @so_bukrs
      AND belnr in @so_belnr
      AND gjahr in @so_gjahr
      AND STBLG IS INITIAL
    INTO TABLE @data(lt_bkpf).

  SORT lt_bkpf  by CPUDT CPUTM DESCENDING.

  LOOP AT lt_bkpf ASSIGNING FIELD-SYMBOL(<bkpf>).
    DATA: lt_bdc TYPE TABLE OF bdcdata,
          ls_opt TYPE  CTU_PARAMS,
      it_msg type standard table of bdcmsgcoll.
      CLEAR: lt_bdc[], it_msg, it_msg[].
      ls_opt-DISMODE = 'E'.
      ls_opt-UPDMODE = 'S'.
      ls_opt-NOBINPT = 'X'.
      ls_opt-NOBIEND = 'X'.
      ls_opt-DEFSIZE = ''.

      add_bdc: ' ' ' '  'SAPMF05R' '0100' 'x',
               'bdc_okcode'  '=RAGL' '' '' '',
               'RF05R-AUGBL'  <bkpf>-belnr '' '' '',
               'RF05R-BUKRS'  <bkpf>-bukrs '' '' '',
               'RF05R-GJAHR'  <bkpf>-gjahr '' '' ''.
      SELECT SINGLE ktosl
        FROM bseg
        WHERE ktosl = 'KDF'
          AND bukrs = @<bkpf>-bukrs
          and belnr = @<bkpf>-belnr
          AND gjahr = @<bkpf>-gjahr
        INTO @data(ls_ktosl).

  IF ls_ktosl = 'KDF'.
     add_bdc:   ' ' ' '  'SAPLSPO1' '0300' 'x',
               'bdc_okcode'  '=YES' '' '' ''.
  else.
    add_bdc:   ' ' ' '  'SAPLSPO2' '0100' 'x',
               'bdc_okcode'  '=OPT2' '' '' ''.
  ENDIF.
  CLEAR ls_ktosl.

    add_bdc:           ' ' ' '  'SAPMF05R' '0300' 'x',
               'bdc_okcode'  '=ENTR' '' '' '',
               'RF05R-STGRD'  p_STGRD '' '' '',

               ' ' ' '  'SAPMF05R' '0100' 'x',
               'bdc_okcode'  '/EEEND' '' '' ''.

*   Call transaction with the batch input data
      CALL TRANSACTION 'FBRA'
        USING lt_bdc
        OPTIONS FROM ls_opt
        MESSAGES INTO it_msg.
      COMMIT WORK AND WAIT.

      CLEAR: lt_bdc, lt_bdc[], it_msg, it_msg[].
  ENDLOOP.
```