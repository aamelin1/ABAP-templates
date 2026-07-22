*&---------------------------------------------------------------------*
*& Report ZFI_COMP_LEDGERS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_comp_ledgers.

TABLES: acdoca, but000.

*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS so_bukrs FOR acdoca-rbukrs NO INTERVALS NO-EXTENSION MEMORY ID buk OBLIGATORY.
  SELECT-OPTIONS so_gjahr FOR acdoca-gjahr NO INTERVALS NO-EXTENSION DEFAULT sy-datum+0(4) OBLIGATORY.
  SELECT-OPTIONS so_poper FOR acdoca-poper NO INTERVALS NO-EXTENSION DEFAULT sy-datum+4(2).
  SELECT-OPTIONS sh_poper FOR acdoca-poper NO-EXTENSION DEFAULT sy-datum+4(2).
  SELECT-OPTIONS so_racct FOR acdoca-racct.
  PARAMETERS p_kokrs TYPE kokrs DEFAULT 'ACEC' NO-DISPLAY.

  PARAMETERS r_bs RADIOBUTTON GROUP gr1  USER-COMMAND cmd DEFAULT 'X'.
  PARAMETERS r_pl RADIOBUTTON GROUP gr1.
  PARAMETERS r_osv RADIOBUTTON GROUP gr1 .
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl11 WITH FRAME TITLE TEXT-011.
  PARAMETERS p_racct AS CHECKBOX DEFAULT 'X'.
  PARAMETERS p_ALTKT AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_BILKT AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_koart AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_anlkl AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_anln1 AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_bp    AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_vbund AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_co    AS CHECKBOX DEFAULT ' '.
  PARAMETERS p_ml    AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK bl11.

SELECTION-SCREEN BEGIN OF BLOCK bl10 WITH FRAME TITLE TEXT-010.
  PARAMETERS p_zero AS CHECKBOX DEFAULT 'X'.
  SELECT-OPTIONS so_koart FOR acdoca-koart.
  SELECT-OPTIONS so_acct FOR acdoca-glaccount_type.
  SELECTION-SCREEN ULINE.
  SELECT-OPTIONS so_bp FOR but000-partner.
  SELECT-OPTIONS so_RASSC FOR acdoca-RASSC.
  SELECTION-SCREEN ULINE.
  SELECT-OPTIONS so_anlkl FOR acdoca-anlkl.
  SELECT-OPTIONS so_anln1 FOR acdoca-anln1.
  SELECTION-SCREEN ULINE.
  SELECT-OPTIONS accasty FOR acdoca-accasty.
  SELECT-OPTIONS so_accas FOR acdoca-accas.
  SELECTION-SCREEN ULINE.
  SELECT-OPTIONS so_kalnr FOR acdoca-kalnr.
  SELECT-OPTIONS so_matnr FOR acdoca-matnr.
  SELECT-OPTIONS so_bwtar FOR acdoca-bwtar.
  SELECT-OPTIONS so_BWKEY FOR acdoca-bwkey.
  SELECT-OPTIONS so_SOBKZ FOR acdoca-sobkz.
  SELECT-OPTIONS so_PSPNR FOR acdoca-mat_pspnr.
SELECTION-SCREEN END OF BLOCK bl10.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS s1_rldnr FOR acdoca-rldnr NO INTERVALS NO-EXTENSION DEFAULT '0L' OBLIGATORY.
  SELECT-OPTIONS s2_rldnr FOR acdoca-rldnr NO INTERVALS NO-EXTENSION DEFAULT '2L'.
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-003.
  PARAMETERS p_brl AS CHECKBOX DEFAULT abap_true.
  PARAMETERS p_usd AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK bl3.

SELECTION-SCREEN BEGIN OF BLOCK bl4 WITH FRAME TITLE TEXT-004.
  PARAMETERS: variant LIKE disvariant-variant.
  PARAMETERS p_langu LIKE sy-langu DEFAULT sy-langu OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl4.

*&---------------------------------------------------------------------*
TYPES: rg_BUKRS   TYPE RANGE OF bukrs,
       rg_RACCT   TYPE RANGE OF racct,
       rg_ANLKL   TYPE RANGE OF anlkl,
       rg_ANLN1   TYPE RANGE OF anln1,
       rg_ANLN2   TYPE RANGE OF anln2,
       rg_RASSC   TYPE RANGE OF rcomp_d,
       rg_PARTNER TYPE RANGE OF bu_partner,
       rg_accasty TYPE RANGE OF j_obart,
       BEGIN OF tt_Accas,
         accas   TYPE accas,
         accasty TYPE j_obart,
         co_name TYPE zco_accas_name,
       END OF tt_Accas.
*&---------------------------------------------------------------------*
DATA: fcat         TYPE lvc_t_fcat,
      hcat         TYPE lvc_s_fcat,
      glay         TYPE lvc_s_glay,
      gs_layout_fm TYPE lvc_s_layo,
      events       TYPE slis_t_event,
      event        TYPE slis_alv_event,
      g_save       TYPE c VALUE 'X',
      g_variant    TYPE disvariant,
      gx_variant   TYPE disvariant,
      g_exit       TYPE c,
      it_rep_temp  TYPE SORTED TABLE OF zfi_comp_ledgers WITH NON-UNIQUE KEY rbukrs gjahr racct,
      it_rep       TYPE STANDARD TABLE OF zfi_comp_ledgers,
      ls_rep       LIKE LINE OF it_rep.
*Dynamic selection
DATA: lv_dyn_sel TYPE string,
      lv_dyn_grb TYPE string,
      lv_dyn_whr TYPE string.
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
  PERFORM check_input.
  PERFORM get_data.
  PERFORM show_alv.

*&---------------------------------------------------------------------*
FORM ssc_output.
  IF r_bs = 'X'.
    LOOP AT SCREEN.
      IF screen-name CS 'SH_POPER'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
      IF screen-name CS 'SO_POPER'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN .
      IF screen-name CS 'SO_POPER'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
      IF screen-name CS 'SH_POPER'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.                .
    ENDLOOP.
  ENDIF.

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

*&---------------------------------------------------------------------*
FORM check_input.
  IF sh_poper-high IS INITIAL AND r_bs NE 'X'.
    sh_poper-high = sh_poper-low.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
FORM get_data.
*Presel ML data
  IF ( so_matnr[] IS NOT INITIAL OR so_bwtar[] IS NOT INITIAL OR so_BWKEY[] IS NOT INITIAL OR so_SOBKZ[] IS NOT INITIAL OR so_PSPNR[] IS NOT INITIAL OR  so_kalnr[] IS NOT INITIAL ) OR p_ml = 'X'.
    SELECT DISTINCT kalnr, matnr, bwtar, bwkey, sobkz, mat_pspnr
      FROM acdoca
      INTO TABLE @DATA(it_kalnr)
      WHERE matnr IN @so_matnr
        AND bwtar IN @so_bwtar
        AND bwkey IN @so_BWKEY
        AND sobkz IN @so_SOBKZ
        AND mat_pspnr IN @so_PSPNR
        AND kalnr IN @so_kalnr.
    CHECK it_kalnr[] IS NOT INITIAL.
    LOOP AT it_kalnr ASSIGNING FIELD-SYMBOL(<fs_kalnr>).
      so_kalnr-sign = 'I'.
      so_kalnr-option = 'EQ'.
      so_kalnr-low = <fs_kalnr>-kalnr.
      APPEND so_kalnr.
    ENDLOOP.
  ENDIF.
*Dynamic selection
  CLEAR: lv_dyn_sel,
        lv_dyn_grb.
  lv_dyn_sel = 'RLDNR, RBUKRS, GJAHR'.
  IF p_racct = 'X' OR p_ALTKT = 'X' OR  p_BILKT = 'X'.
    lv_dyn_sel =  lv_dyn_sel && ', RACCT'.
  ENDIF.
  lv_dyn_sel =  lv_dyn_sel && ', sum( HSL ) as 01_HSL, RHCUR as 01_RHCUR, sum( KSL ) as 01_KSL, RKCUR as 01_RKCUR'.
  lv_dyn_grb = 'RLDNR, RBUKRS, GJAHR'.
  IF p_racct = 'X' OR p_ALTKT = 'X' OR  p_BILKT = 'X'.
    lv_dyn_grb = lv_dyn_grb && ', RACCT'.
  ENDIF.
  lv_dyn_grb = lv_dyn_grb && ', RHCUR, RKCUR'.
  lv_dyn_whr = 'rbukrs IN @so_bukrs'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND gjahr IN @so_gjahr'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND ( rldnr IN @s1_rldnr OR rldnr IN @s2_rldnr )'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND racct IN @so_racct'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND koart IN @so_koart'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND glaccount_type IN @so_acct'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND anlkl IN @so_anlkl'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND anln1 IN @so_anln1'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND RASSC IN @so_RASSC'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND ( lifnr IN @so_bp OR  kunnr IN @so_bp OR vptnr IN @so_bp )'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND accasty IN @accasty'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND accas IN @so_accas'.
  lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND kalnr IN @so_kalnr'.
  IF r_osv = 'X'.
    PERFORM add_dyn_fields USING 'POPER'.
    PERFORM add_dyn_fields USING 'DRCRK'.
  ENDIF.
**********************************************************************
  IF p_koart = 'X'.
    PERFORM add_dyn_fields USING 'GLACCOUNT_TYPE'.
    PERFORM add_dyn_fields USING 'KOART'.
  ENDIF.
  IF p_anlkl = 'X'.
    PERFORM add_dyn_fields USING 'ANLKL'.
  ENDIF.
  IF p_anln1 = 'X'.
    PERFORM add_dyn_fields USING 'ANLN1'.
    PERFORM add_dyn_fields USING 'ANLN2'.
  ENDIF.
  IF p_bp = 'X'.
    IF p_koart <> 'X'.
      PERFORM add_dyn_fields USING 'KOART'.
    ENDIF.
    PERFORM add_dyn_fields USING 'LIFNR'.
    PERFORM add_dyn_fields USING 'KUNNR'.
    PERFORM add_dyn_fields USING 'VPTNR'.
  ENDIF.
  IF p_vbund = 'X'.
    PERFORM add_dyn_fields USING 'RASSC'.
  ENDIF.
  IF p_co = 'X'.
    PERFORM add_dyn_fields USING 'ACCASTY'.
    PERFORM add_dyn_fields USING 'ACCAS'.
  ENDIF.
  IF p_ml = 'X'.
    PERFORM add_dyn_fields USING 'KALNR'.
  ENDIF.
**********************************************************************
* ACDOCA selection
  CASE 'X'.
    WHEN r_bs.
      lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND poper <= @so_poper-low'.
      SELECT (lv_dyn_sel)
      FROM acdoca
        INTO CORRESPONDING FIELDS OF TABLE @it_rep_temp
        WHERE (lv_dyn_whr)
      GROUP BY (lv_dyn_grb).
    WHEN r_pl.
      lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND poper IN @sh_poper'.
      SELECT (lv_dyn_sel)
      FROM acdoca
        INTO CORRESPONDING FIELDS OF TABLE @it_rep_temp
        WHERE (lv_dyn_whr)
      GROUP BY (lv_dyn_grb).
    WHEN r_osv.
*      St End Balances + Turnovers
      lv_dyn_whr =   lv_dyn_whr && ` ` && 'AND poper <= @sh_poper-high'.
      SELECT (lv_dyn_sel)
      FROM acdoca
        INTO CORRESPONDING FIELDS OF TABLE @it_rep_temp
        WHERE (lv_dyn_whr)
      GROUP BY (lv_dyn_grb).
    WHEN OTHERS.
  ENDCASE.

  IF p_zero = 'X'.
    DELETE it_rep_temp WHERE 01_hsl = 0 AND 01_ksl = 0.
  ENDIF.

**********************************************************************
* Preselect texts (declare ranges)
  DATA: rg_BUKRS   TYPE rg_BUKRS,
        wa_BUKRS   TYPE LINE OF rg_BUKRS,
        rg_RACCT   TYPE rg_RACCT,
        wa_RACCT   TYPE LINE OF rg_RACCT,
        rg_ANLKL   TYPE rg_ANLKL,
        wa_ANLKL   TYPE LINE OF rg_ANLKL,
        rg_ANLN1   TYPE rg_ANLN1,
        wa_ANLN1   TYPE LINE OF rg_ANLN1,
        rg_ANLN2   TYPE rg_ANLN2,
        wa_ANLN2   TYPE LINE OF rg_ANLN2,
        rg_RASSC   TYPE rg_RASSC,
        wa_RASSC   TYPE LINE OF rg_RASSC,
        rg_PARTNER TYPE rg_PARTNER,
        wa_PARTNER TYPE LINE OF rg_PARTNER,
        rg_accasty TYPE rg_accasty,
        wa_accasty TYPE LINE OF rg_accasty,
        it_accas   TYPE STANDARD TABLE OF tt_accas.

**********************************************************************
  LOOP AT it_rep_temp ASSIGNING FIELD-SYMBOL(<fs_rep_temp>).
    CLEAR: ls_rep.
    ls_rep-rbukrs = <fs_rep_temp>-rbukrs.
    ls_rep-gjahr = <fs_rep_temp>-gjahr.
    ls_rep-racct = <fs_rep_temp>-racct.
    ls_rep-01_rhcur = ls_rep-02_rhcur = ls_rep-12_rhcur = <fs_rep_temp>-01_rhcur.
    ls_rep-01_rkcur = ls_rep-02_rkcur = ls_rep-12_rkcur = <fs_rep_temp>-01_rkcur.
    ls_rep-glaccount_type = <fs_rep_temp>-glaccount_type.
    ls_rep-koart = <fs_rep_temp>-koart.
    ls_rep-anlkl = <fs_rep_temp>-anlkl.
    ls_rep-anln1 = <fs_rep_temp>-anln1.
    ls_rep-anln2 = <fs_rep_temp>-anln2.
    CASE ls_rep-koart.
      WHEN 'K'.
        ls_rep-partner = <fs_rep_temp>-lifnr.
        <fs_rep_temp>-partner = <fs_rep_temp>-lifnr.
      WHEN 'D'.
        ls_rep-partner = <fs_rep_temp>-kunnr.
        <fs_rep_temp>-partner = <fs_rep_temp>-kunnr.
      WHEN OTHERS.
        IF <fs_rep_temp>-vptnr IS NOT INITIAL.
          ls_rep-partner = <fs_rep_temp>-vptnr.
          <fs_rep_temp>-partner = <fs_rep_temp>-vptnr.
        ELSEIF <fs_rep_temp>-lifnr IS NOT INITIAL.
          ls_rep-partner = <fs_rep_temp>-lifnr.
          <fs_rep_temp>-partner = <fs_rep_temp>-lifnr.
        ELSEIF <fs_rep_temp>-kunnr IS NOT INITIAL.
          ls_rep-partner = <fs_rep_temp>-kunnr.
          <fs_rep_temp>-partner = <fs_rep_temp>-kunnr.
        ENDIF.
    ENDCASE.
    ls_rep-RASSC = <fs_rep_temp>-RASSC.
    ls_rep-accasty = <fs_rep_temp>-accasty.
    ls_rep-accas = <fs_rep_temp>-accas.
    ls_rep-kalnr = <fs_rep_temp>-kalnr.

****Fill ranges for preselect texts****
    APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-rbukrs ) TO rg_BUKRS.
    IF ls_rep-racct IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-racct  ) TO rg_racct.
    ENDIF.
    IF ls_rep-anlkl IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-anlkl  ) TO rg_anlkl.
    ENDIF.
    IF ls_rep-anln1 IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-anln1  ) TO rg_anln1.
    ENDIF.
    IF ls_rep-anln2 IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-anln2  ) TO rg_anln2.
    ENDIF.
    IF ls_rep-RASSC IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-RASSC  ) TO rg_RASSC.
    ENDIF.
    IF ls_rep-partner IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-partner ) TO rg_PARTNER.
    ENDIF.
    IF ls_rep-accasty IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ'  low = ls_rep-accasty ) TO rg_accasty.
    ENDIF.

    IF ls_rep-accas IS NOT INITIAL.
      DATA: ls_accas LIKE LINE OF it_accas.
      ls_accas-accas = ls_rep-accas.
      ls_accas-accasty = ls_rep-accasty.
      APPEND ls_accas TO it_accas.
      CLEAR ls_accas.
    ENDIF.
**********************************************************************
    IF <fs_rep_temp>-rldnr = s1_rldnr-low.
      ls_rep-01_hsl = ls_rep-01_hsl + <fs_rep_temp>-01_hsl.
      ls_rep-01_ksl = ls_rep-01_ksl + <fs_rep_temp>-01_ksl.
      IF r_osv IS NOT INITIAL.
        IF <fs_rep_temp>-poper NOT IN sh_poper.
          ls_rep-01_hsls = ls_rep-01_hsls + <fs_rep_temp>-01_hsl.
          ls_rep-01_ksls = ls_rep-01_ksls + <fs_rep_temp>-01_ksl.
        ELSEIF <fs_rep_temp>-poper IN sh_poper AND <fs_rep_temp>-drcrk = 'S'.
          ls_rep-01_hsld = ls_rep-01_hsld + <fs_rep_temp>-01_hsl.
          ls_rep-01_ksld = ls_rep-01_ksld + <fs_rep_temp>-01_ksl.
        ELSEIF <fs_rep_temp>-poper IN sh_poper AND <fs_rep_temp>-drcrk = 'H'.
          ls_rep-01_hslc = ls_rep-01_hslc + <fs_rep_temp>-01_hsl.
          ls_rep-01_kslc = ls_rep-01_kslc + <fs_rep_temp>-01_ksl.
        ENDIF.
      ENDIF.
    ELSEIF <fs_rep_temp>-rldnr = s2_rldnr-low.
      ls_rep-02_hsl = ls_rep-02_hsl + <fs_rep_temp>-01_hsl.
      ls_rep-02_ksl = ls_rep-02_ksl + <fs_rep_temp>-01_ksl.
      IF r_osv IS NOT INITIAL.
        IF <fs_rep_temp>-poper NOT IN sh_poper.
          ls_rep-02_hsls = ls_rep-02_hsls + <fs_rep_temp>-01_hsl.
          ls_rep-02_ksls = ls_rep-02_ksls + <fs_rep_temp>-01_ksl.
        ELSEIF <fs_rep_temp>-poper IN sh_poper AND <fs_rep_temp>-drcrk = 'S'.
          ls_rep-02_hsld = ls_rep-02_hsld + <fs_rep_temp>-01_hsl.
          ls_rep-02_ksld = ls_rep-02_ksld + <fs_rep_temp>-01_ksl.
        ELSEIF <fs_rep_temp>-poper IN sh_poper AND <fs_rep_temp>-drcrk = 'H'.
          ls_rep-02_hslc = ls_rep-02_hslc + <fs_rep_temp>-01_hsl.
          ls_rep-02_kslc = ls_rep-02_kslc + <fs_rep_temp>-01_ksl.
        ENDIF.
      ENDIF.
    ENDIF.
    COLLECT ls_rep INTO it_rep.
  ENDLOOP.

**********************************************************************
*Preselect texts
  SORT: rg_bukrs, rg_racct, rg_anlkl, rg_anln1, rg_anln2, rg_RASSC, rg_PARTNER, rg_accasty, it_accas.
  DELETE ADJACENT DUPLICATES FROM rg_BUKRS.
  DELETE ADJACENT DUPLICATES FROM rg_RACCT.
  DELETE ADJACENT DUPLICATES FROM rg_anlkl.
  DELETE ADJACENT DUPLICATES FROM rg_anln1.
  DELETE ADJACENT DUPLICATES FROM rg_anln2.
  DELETE ADJACENT DUPLICATES FROM rg_RASSC.
  DELETE ADJACENT DUPLICATES FROM rg_partner.
  DELETE ADJACENT DUPLICATES FROM rg_accasty.
  DELETE ADJACENT DUPLICATES FROM it_accas.

**********************************************************************
*GL account texts
  TYPES: BEGIN OF tt_skat,
           bukrs TYPE bukrs,
           saknr TYPE racct,
           txt50 TYPE txt50_skat,
         END OF tt_skat.
  DATA: it_skat TYPE SORTED TABLE OF tt_skat WITH UNIQUE KEY bukrs saknr.

  SELECT t001~bukrs, skat~saknr, txt50
    FROM skat
    INNER JOIN t001 ON skat~ktopl EQ t001~ktopl
    INTO TABLE @it_skat
    WHERE t001~bukrs IN @rg_bukrs
      AND skat~saknr IN @rg_racct
      AND skat~spras = @p_langu.
**********************************************************************
*Global BCS accounts and texts
  TYPES: BEGIN OF tt_BCS_skat,
           bukrs  TYPE bukrs,
           saknr  TYPE racct,
           bilkt  TYPE bilkt,
           bl_txt TYPE zfi_bl_txt50_skat,
         END OF tt_bcs_skat.
  DATA: it_bcs_skat TYPE SORTED TABLE OF tt_bcs_skat WITH UNIQUE KEY bukrs saknr.

  IF p_bilkt = 'X'.
    SELECT t001~bukrs, ska1~saknr, ska1~bilkt, skat~txt50
      FROM ska1
      INNER JOIN t001 ON ska1~ktopl EQ t001~ktopl
      INNER JOIN t004 ON t001~ktopl EQ t004~ktopl
      INNER JOIN skat ON skat~saknr EQ ska1~bilkt
                     AND SKAt~ktopl = t004~kktpl
      INTO TABLE @it_bcs_skat
      WHERE t001~bukrs IN @rg_bukrs
        AND ska1~saknr IN @rg_racct
        AND skat~spras = 'E'.
  ENDIF.
**********************************************************************
  IF p_altkt = 'X'.
    TYPES: BEGIN OF tt_alt_skat,
             bukrs  TYPE bukrs,
             saknr  TYPE racct,
             altkt  TYPE altkt_skb1,
             al_txt TYPE zfi_alt_txt50_skat,
           END OF tt_alt_skat.
    DATA: it_alt_skat TYPE SORTED TABLE OF tt_alt_skat WITH UNIQUE KEY bukrs saknr.
    SELECT  skb1~bukrs, skb1~saknr, altkt, txt50 AS al_txt
      FROM skb1
      INNER JOIN t001 ON skb1~bukrs EQ t001~bukrs
      INNER JOIN skat ON skb1~altkt EQ skat~saknr
                     AND t001~ktop2 EQ skat~ktopl
      INTO TABLE @it_alt_skat
      WHERE t001~bukrs IN @rg_bukrs
        AND skb1~saknr IN @rg_racct
        AND skat~spras = @p_langu.
  ENDIF.
**********************************************************************
*FA class text
  TYPES: BEGIN OF tt_ankt,
           anlkl TYPE anlkl,
           txk50 TYPE txt50_ankt,
         END OF tt_ankt.
  DATA: it_ankt TYPE SORTED TABLE OF tt_ankt WITH UNIQUE KEY anlkl.

  IF p_anlkl = 'X'.
    SELECT anlkl, txk50
      FROM ankt
      INTO TABLE @it_ankt
      WHERE anlkl IN @rg_anlkl
        AND spras = @p_langu.
  ENDIF.
**********************************************************************
*FA text
  TYPES: BEGIN OF tt_anla,
           bukrs TYPE bukrs,
           anln1 TYPE anln1,
           anln2 TYPE anln2,
           txt50 TYPE txa50_anlt,
         END OF tt_anla.
  DATA: it_anla TYPE SORTED TABLE OF tt_anla WITH UNIQUE KEY bukrs anln1 anln2.
  IF p_anln1 = 'X'.
    SELECT bukrs, anln1, anln2, txt50
      FROM anla
      INTO TABLE @it_anla
      WHERE bukrs IN @rg_bukrs
        AND anln1 IN @rg_anln1
        AND anln2 IN @rg_anln2.
  ENDIF.
**********************************************************************
*Traid partner
  TYPES: BEGIN OF tt_RASSC,
           RASSC   TYPE rcomp_d,
           r_name1 TYPE name_1,
         END OF tt_RASSC.
  DATA: it_RASSC TYPE SORTED TABLE OF tt_RASSC WITH UNIQUE KEY RASSC.
  IF p_vbund = 'X'.
    SELECT rcomp, name1 AS R_name1
      FROM t880
      INTO TABLE @it_RASSC
      WHERE rcomp IN @rg_RASSC.
  ENDIF.
**********************************************************************
*BP name
  TYPES: BEGIN OF tt_bp,
           partner  TYPE bu_partner,
           mc_name1 TYPE bu_mcname1,
         END OF tt_bp.
  DATA: it_bp TYPE SORTED TABLE OF tt_bp WITH UNIQUE KEY partner.
  IF p_bp = 'X'.
    SELECT partner, mc_name1
      FROM but000
      INTO TABLE @it_bp
      WHERE partner IN @rg_partner.
  ENDIF.
**********************************************************************
*Accas/ty name
  TYPES: BEGIN OF tt_Accasty,
           accasty TYPE j_obart,
           txt60   TYPE j_text60,
         END OF tt_Accasty.
  DATA: it_accasty TYPE SORTED TABLE OF tt_accasty WITH UNIQUE KEY accasty.

  IF p_co = 'X'.
    SELECT obart AS accasty, txt60
      FROM tbo01
      INTO TABLE @it_accasty
      WHERE obart IN @rg_accasty
        AND spras = @p_langu.
    LOOP AT it_accas ASSIGNING FIELD-SYMBOL(<fs_accas>).
      CASE <fs_accas>-accasty.
        WHEN 'AO'." Reconciliation Object
          <fs_accas>-co_name = ''.
        WHEN 'KL'." Cost Center/Activity Type
          SPLIT <fs_accas>-accas AT '/' INTO DATA(ls_kostl) DATA(ls_LSTAR).
          SELECT SINGLE ltext
            FROM cskt
            INTO @<fs_accas>-co_name
            WHERE spras = @p_langu
              AND kostl = @ls_kostl
              AND kokrs = @p_kokrs
              AND datbi = '99991231'.
          SELECT SINGLE ltext
            FROM cslt
            INTO @DATA(ls_lstar_t)
            WHERE spras = @p_langu
              AND lstar = @ls_lstar
              AND kokrs = @p_kokrs
              AND datbi = '99991231'.
          <fs_accas>-co_name = <fs_accas>-co_name && '/' && ls_lstar_t.
        WHEN 'KS'." Cost Center
          SELECT SINGLE ltext
            FROM cskt
            INTO @<fs_accas>-co_name
            WHERE spras = @p_langu
              AND kostl = @<fs_accas>-accas
              AND kokrs = @p_kokrs
              AND datbi = '99991231'.
        WHEN 'OR'." Order
          SELECT SINGLE ktext
            FROM aufk
            INTO @<fs_accas>-co_name
            WHERE aufnr = @<fs_accas>-accas.
        WHEN 'PR'." WBS element..
          SELECT SINGLE post1
            FROM prps
            INTO @<fs_accas>-co_name
            WHERE posid = @<fs_accas>-accas.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDIF.
**********************************************************************

  LOOP AT it_rep ASSIGNING FIELD-SYMBOL(<fs_rep>).
*Delta
    <fs_rep>-12_hsl = <fs_rep>-01_hsl - <fs_rep>-02_hsl.
    IF r_osv IS NOT INITIAL.
      <fs_rep>-12_hsls = <fs_rep>-01_hsls - <fs_rep>-02_hsls.
      <fs_rep>-12_hsld = <fs_rep>-01_hsld - <fs_rep>-02_hsld.
      <fs_rep>-12_hslc = <fs_rep>-01_hslc - <fs_rep>-02_hslc.
    ENDIF.
    <fs_rep>-12_rhcur = <fs_rep>-01_rhcur.
    <fs_rep>-12_ksl = <fs_rep>-01_ksl - <fs_rep>-02_ksl.
    IF r_osv IS NOT INITIAL.
      <fs_rep>-12_ksls = <fs_rep>-01_ksls - <fs_rep>-02_ksls.
      <fs_rep>-12_ksld = <fs_rep>-01_ksld - <fs_rep>-02_ksld.
      <fs_rep>-12_kslc = <fs_rep>-01_kslc - <fs_rep>-02_kslc.
    ENDIF.
    <fs_rep>-12_rkcur = <fs_rep>-01_rkcur.
**********************************************************************
*Alt account and text
    IF p_altkt = 'X'.
      READ TABLE it_alt_skat ASSIGNING FIELD-SYMBOL(<fs_alt_skat>) WITH KEY bukrs = <fs_rep>-rbukrs saknr = <fs_rep>-racct.
      IF <fs_alt_skat> IS ASSIGNED.
        <fs_rep>-altkt = <fs_alt_skat>-altkt.
        <fs_rep>-al_txt = <fs_alt_skat>-al_txt.
        UNASSIGN <fs_alt_skat>.
      ELSE.
        <fs_rep>-altkt = 'N/A'.
        <fs_rep>-al_txt = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*GL account texts
    READ TABLE it_skat ASSIGNING FIELD-SYMBOL(<fs_skat>) WITH KEY bukrs = <fs_rep>-rbukrs saknr = <fs_rep>-racct.
    IF <fs_skat> IS ASSIGNED.
      <fs_rep>-txt50 = <fs_skat>-txt50.
      UNASSIGN <fs_skat>.
    ELSE.
      <fs_rep>-txt50 = 'Not found'.
    ENDIF.
**********************************************************************
*Global BCS account and text
    IF p_bilkt = 'X'.
      READ TABLE it_bcs_skat ASSIGNING FIELD-SYMBOL(<fs_bcs_skat>) WITH KEY bukrs = <fs_rep>-rbukrs saknr = <fs_rep>-racct.
      IF <fs_bcs_skat> IS ASSIGNED.
        <fs_rep>-bilkt = <fs_bcs_skat>-bilkt.
        <fs_rep>-bl_txt = <fs_bcs_skat>-bl_txt.
        UNASSIGN <fs_bcs_skat>.
      ELSE.
        <fs_rep>-bilkt = 'N/A'.
        <fs_rep>-bl_txt = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*FA class text
    IF p_anlkl = 'X' AND <fs_rep>-anlkl IS NOT INITIAL.
      READ TABLE it_ankt ASSIGNING FIELD-SYMBOL(<fs_ankt>) WITH KEY anlkl = <fs_rep>-anlkl .
      IF <fs_ankt> IS ASSIGNED.
        <fs_rep>-txk50 = <fs_ankt>-txk50.
        UNASSIGN <fs_ankt>.
      ELSE.
        <fs_rep>-txk50 = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*FA text
    IF p_anln1 = 'X' AND <fs_rep>-anln1 IS NOT INITIAL.
      READ TABLE it_anla ASSIGNING FIELD-SYMBOL(<fs_anla>) WITH KEY bukrs = <fs_rep>-rbukrs anln1 = <fs_rep>-anln1 anln2 = <fs_rep>-anln2.
      IF <fs_anla> IS ASSIGNED.
        <fs_rep>-aa_txt50 = <fs_anla>-txt50.
        UNASSIGN <fs_anla>.
      ELSE.
        <fs_rep>-aa_txt50 = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*Traiding partnr RASSC name
    IF p_vbund = 'X' AND <fs_rep>-RASSC IS NOT INITIAL.
      READ TABLE it_RASSC ASSIGNING FIELD-SYMBOL(<fs_RASSC>) WITH KEY RASSC = <fs_rep>-RASSC .
      IF <fs_RASSC> IS ASSIGNED.
        <fs_rep>-r_name1 = <fs_RASSC>-r_NAME1.
        UNASSIGN <fs_RASSC>.
      ELSE.
        <fs_rep>-r_name1 = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*BP name
    IF p_bp = 'X' AND <fs_rep>-partner IS NOT INITIAL.
      READ TABLE it_bp ASSIGNING FIELD-SYMBOL(<fs_bp>) WITH KEY partner = <fs_rep>-partner .
      IF <fs_bp> IS ASSIGNED.
        <fs_rep>-mc_name1 = <fs_bp>-mc_name1.
        UNASSIGN <fs_bp>.
      ELSE.
        <fs_rep>-mc_name1 = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*Accasty name
    IF p_co = 'X' AND <fs_rep>-accasty IS NOT INITIAL.
      READ TABLE it_accasty ASSIGNING FIELD-SYMBOL(<fs_accasty>) WITH KEY accasty = <fs_rep>-accasty .
      IF <fs_accasty> IS ASSIGNED.
        <fs_rep>-txt60 = <fs_accasty>-txt60.
        UNASSIGN <fs_accasty>.
      ELSE.
        <fs_rep>-txt60 = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*Accas name
    IF p_co = 'X' AND <fs_rep>-accas IS NOT INITIAL.
      READ TABLE it_accas ASSIGNING FIELD-SYMBOL(<fs_accas_n>) WITH KEY accas = <fs_rep>-accas accasty = <fs_rep>-accasty.
      IF <fs_accas_n> IS ASSIGNED.
        <fs_rep>-co_name = <fs_accas_n>-co_name.
        UNASSIGN <fs_accas_n>.
      ELSE.
        <fs_rep>-co_name = 'Not found'.
      ENDIF.
    ENDIF.
**********************************************************************
*ML/MM data
    IF p_ml = 'X' AND <fs_rep>-kalnr IS NOT INITIAL.
      SORT it_kalnr BY kalnr.
      READ TABLE it_kalnr ASSIGNING FIELD-SYMBOL(<fs_kalnr_n>) WITH KEY kalnr = <fs_rep>-kalnr BINARY SEARCH.
      IF <fs_kalnr_n> IS ASSIGNED.
        <fs_rep>-matnr = <fs_kalnr_n>-matnr.
        <fs_rep>-bwtar = <fs_kalnr_n>-bwtar.
        <fs_rep>-bwkey = <fs_kalnr_n>-bwkey.
        <fs_rep>-sobkz = <fs_kalnr_n>-sobkz.
        <fs_rep>-mat_pspnr = <fs_kalnr_n>-mat_pspnr.
        UNASSIGN <fs_kalnr_n>.
      ELSE.
        <fs_rep>-matnr = 'Not found'.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
FORM show_alv .
**************************************
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZFI_COMP_LEDGERS'
    CHANGING
      ct_fieldcat            = fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
  ENDIF.

  LOOP AT fcat ASSIGNING FIELD-SYMBOL(<f>).
    CASE <f>-fieldname.
      WHEN 'RLDNR'. <f>-tech = abap_true.
      WHEN 'RBUKRS'. <f>-no_out = abap_true.
      WHEN 'GJAHR'. <f>-no_out = abap_true.
      WHEN 'POPER'. <f>-tech = abap_true.
      WHEN 'DRCRK'. <f>-tech = abap_true.
****(Dynamic fields)****
      WHEN 'RACCT'.           IF p_racct <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'TXT50'.           IF p_racct <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'ALTKT'.           IF p_altkt <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'AL_TXT'.          IF p_altkt <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'BILKT'.           IF p_bilkt <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'BL_TXT'.          IF p_bilkt <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'GLACCOUNT_TYPE'.  IF p_koart <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'KOART'.           IF p_koart <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'ANLKL'.           IF p_anlkl <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'TXK50'.           IF p_anlkl <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'ANLN1'.           IF p_anln1 <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'ANLN2'.           IF p_anln1 <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'AA_TXT50'.        IF p_anln1 <> 'X'. <f>-tech = abap_true. ENDIF.


      WHEN 'LIFNR'.           <f>-tech = abap_true.
      WHEN 'KUNNR'.           <f>-tech = abap_true.
      WHEN 'VPTNR'.           <f>-tech = abap_true.
      WHEN 'PARTNER'.         IF p_bp <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'MC_NAME1'.        IF p_bp <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'RASSC'.           IF p_vbund <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'R_NAME1'.         IF p_vbund <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'ACCASTY'.         IF p_co <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'ACCAS'.           IF p_co <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'TXT60'.           IF p_co <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'CO_NAME'.         IF p_co <> 'X'. <f>-tech = abap_true. ENDIF.

      WHEN 'KALNR'.           IF p_ml <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'MATNR'.           IF p_ml <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'BWTAR'.           IF p_ml <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'BWKEY'.           IF p_ml <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'SOBKZ'.           IF p_ml <> 'X'. <f>-tech = abap_true. ENDIF.
      WHEN 'MAT_PSPNR'.       IF p_ml <> 'X'. <f>-tech = abap_true. ENDIF.
****(Dynamic fields)****
      WHEN OTHERS.
        CASE <f>-fieldname+0(3).
          WHEN '01_'.
            <f>-emphasize = 'C210'.
            <f>-coltext   = s1_rldnr-low  && <f>-coltext.
            <f>-scrtext_l = s1_rldnr-low  && <f>-scrtext_l.
            <f>-scrtext_m = s1_rldnr-low  && <f>-scrtext_m.
            <f>-scrtext_s = s1_rldnr-low  && <f>-scrtext_s.
          WHEN '02_'.
            <f>-emphasize = 'C410'.
            <f>-coltext   = s2_rldnr-low  && <f>-coltext.
            <f>-scrtext_l = s2_rldnr-low  && <f>-scrtext_l.
            <f>-scrtext_m = s2_rldnr-low  && <f>-scrtext_m.
            <f>-scrtext_s = s2_rldnr-low  && <f>-scrtext_s.
          WHEN '12_'.
            <f>-emphasize = 'C510'.
            <f>-coltext   = 'Δ'  && <f>-coltext.
            <f>-scrtext_l = 'Δ'  && <f>-scrtext_l.
            <f>-scrtext_m = 'Δ'  && <f>-scrtext_m.
            <f>-scrtext_s = 'Δ'  && <f>-scrtext_s.
          WHEN OTHERS.
        ENDCASE.
        IF <f>-fieldname+4(2) = 'SL'. <f>-do_sum = abap_true. ENDIF.
        IF ( <f>-fieldname+3(3) = 'HSL' OR <f>-fieldname+3(3) = 'RHC' ) AND p_brl = abap_false.
          <f>-tech = abap_true.
        ENDIF.
        IF ( <f>-fieldname+3(3) = 'KSL' OR <f>-fieldname+3(3) = 'RKC' ) AND p_usd = abap_false.
          <f>-tech = abap_true.
        ENDIF.
        IF <f>-fieldname+2(1) = '_' AND ( <f>-fieldname+6(1) = 'S' OR <f>-fieldname+6(1) = 'D' OR <f>-fieldname+6(1) = 'C' ).
          IF r_osv IS NOT INITIAL.
            CASE  <f>-fieldname+6(1).
              WHEN 'S'.
                <f>-coltext   = 'SB' && ':' && <f>-coltext.
                <f>-scrtext_l = 'SB' && ':' && <f>-scrtext_l.
                <f>-scrtext_m = 'SB' && ':' && <f>-scrtext_m.
                <f>-scrtext_s = 'SB' && ':' && <f>-scrtext_s.
              WHEN 'D'.
                <f>-coltext   = 'Dr' && ':' && <f>-coltext.
                <f>-scrtext_l = 'Dr' && ':' && <f>-scrtext_l.
                <f>-scrtext_m = 'Dr' && ':' && <f>-scrtext_m.
                <f>-scrtext_s = 'Dr' && ':' && <f>-scrtext_s.
                <f>-emphasize+2(1) = '0'.
              WHEN 'C'.
                <f>-coltext   = 'Cr' && ':' && <f>-coltext.
                <f>-scrtext_l = 'Cr' && ':' && <f>-scrtext_l.
                <f>-scrtext_m = 'Cr' && ':' && <f>-scrtext_m.
                <f>-scrtext_s = 'Cr' && ':' && <f>-scrtext_s.
                <f>-emphasize+2(1) = '0'.
              WHEN OTHERS.
                <f>-coltext   = 'EB' && ':' && <f>-coltext.
                <f>-scrtext_l = 'EB' && ':' && <f>-scrtext_l.
                <f>-scrtext_m = 'EB' && ':' && <f>-scrtext_m.
                <f>-scrtext_s = 'EB' && ':' && <f>-scrtext_s.
            ENDCASE.
          ELSE.
            <f>-tech = abap_true.
          ENDIF.
        ENDIF.
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
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'SETPF'
      i_callback_user_command  = 'UCOMM'
      i_grid_settings          = glay
      it_fieldcat_lvc          = fcat
      i_save                   = g_save
      is_variant               = g_variant
    TABLES
      t_outtab                 = it_rep
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM ucomm USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.
  rs_selfield-refresh = 'X'.
  rs_selfield-col_stable = 'X'.
  rs_selfield-row_stable = 'X'.
  CASE r_ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN '&IC1'.
      DATA: ls_rep LIKE LINE OF it_rep.
      DATA ldg(2).
      READ TABLE it_rep INTO ls_rep INDEX rs_selfield-tabindex.
      CHECK ls_rep-racct IS NOT INITIAL.
      DATA(so_rac) = VALUE rsdsselopt_t( sign = 'I' option = 'EQ' ( low = ls_rep-racct ) ).
      CASE  rs_selfield-sel_tab_field+2(3).
        WHEN '01_'. ldg = s1_rldnr-low.
        WHEN '02_'. ldg = s2_rldnr-low.
        WHEN OTHERS.
          CASE rs_selfield-fieldname.
            WHEN 'RACCT'.
              CHECK ls_rep-racct IS NOT INITIAL.
              SET PARAMETER ID 'SAK' FIELD ls_rep-racct.
              SET PARAMETER ID 'BUK' FIELD ls_rep-rbukrs.
              CALL TRANSACTION 'FS00'.
            WHEN 'ALTKT'.
              CHECK ls_rep-altkt IS NOT INITIAL.
              SET PARAMETER ID 'SAK' FIELD ls_rep-altkt.
              SET PARAMETER ID 'KPL' FIELD 'CABR'.
              CALL TRANSACTION 'FSP0'.
            WHEN 'BILKT'.
              CHECK ls_rep-bilkt IS NOT INITIAL.
              SET PARAMETER ID 'SAK' FIELD ls_rep-bilkt.
              SET PARAMETER ID 'KPL' FIELD 'ZBCS'.
              CALL TRANSACTION 'FSP0'.
            WHEN 'ANLN1'.
              CHECK ls_rep-anln1 IS NOT INITIAL.
              SET PARAMETER ID 'BUK' FIELD ls_rep-rbukrs.
              SET PARAMETER ID 'AN1' FIELD ls_rep-anln1.
              SET PARAMETER ID 'AN2' FIELD ls_rep-anln2.
              CALL TRANSACTION 'AW01n'.
            WHEN 'PARTNER'.
              CHECK ls_rep-partner IS NOT INITIAL.
            WHEN 'KALNR'.
              CHECK ls_rep-kalnr IS NOT INITIAL.
            WHEN OTHERS. EXIT.
          ENDCASE.
          EXIT.
      ENDCASE.
      CASE 'X'.
        WHEN r_bs.
          DATA(so_per) = VALUE rsdsselopt_t( sign = 'I' option = 'LE' ( low = so_gjahr-low && so_poper-low ) ).
        WHEN r_pl.
          so_per  = VALUE rsdsselopt_t( sign = 'I' option = 'BT' ( low = so_gjahr-low && sh_poper-low high = so_gjahr-low && sh_poper-high ) ).
        WHEN r_osv.
          CASE  rs_selfield-sel_tab_field+8(1).
            WHEN 'S'.     so_per = VALUE rsdsselopt_t( sign = 'I' option = 'LT' ( low = so_gjahr-low && sh_poper-low ) ).
            WHEN ''.      so_per = VALUE rsdsselopt_t( sign = 'I' option = 'LE' ( low = so_gjahr-low && sh_poper-high ) ).
            WHEN OTHERS.  so_per = VALUE rsdsselopt_t( sign = 'I' option = 'BT' ( low = so_gjahr-low && sh_poper-low high = so_gjahr-low && sh_poper-high ) ).
          ENDCASE.
        WHEN OTHERS.
      ENDCASE.
      CHECK ldg IS NOT INITIAL.
      SUBMIT fagl_account_items_gl
          WITH x_opsel  EQ abap_false
          WITH x_aisel  EQ abap_true
          WITH rldnr    EQ ldg
          WITH so_yrper IN so_per
          WITH sd_saknr IN so_rac
          WITH sd_bukrs IN so_bukrs
        AND RETURN.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM setpf USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.
*&---------------------------------------------------------------------*
FORM add_dyn_fields USING f TYPE string.
  lv_dyn_sel = lv_dyn_sel && ',' && ` ` && f.
  lv_dyn_grb = lv_dyn_grb && ',' && ` ` && f.
ENDFORM.
