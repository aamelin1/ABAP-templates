* Report of accounts' correspondence
REPORT j_3rkorrrep
    NO STANDARD PAGE HEADING
    MESSAGE-ID /ccis/cciscorresp
    LINE-COUNT 65(1)
    LINE-SIZE 132.

INCLUDE ZFIJ_3RKORRREPTOP.
INCLUDE EXCEL__C.
*INCLUDE j_3rkorrreptop.
* --------------------------------
* Corrections
* --------------------------------
* LAB1  Output diagnostics. Close output.
* LAB2  11.06.2003  Lebedev Alexey SAP CISB
*       Wrong aggregation for any level of Correspondence account
*       Customer message 0002771493 2003
*-------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK date_a WITH FRAME TITLE text-020.
SELECT-OPTIONS: osnsc FOR bseg-hkont      " Main account
    MEMORY ID sak MATCHCODE OBJECT sako,
    osber FOR bseg-gsber no-display MEMORY ID gsb .   " Main BusSphera
PARAMETERS ugos TYPE j_3rk_group_level.   " Main Acct Grouping Level
SELECTION-SCREEN END OF BLOCK date_a.

SELECTION-SCREEN BEGIN OF BLOCK date_b WITH FRAME TITLE text-021.
SELECT-OPTIONS:
    korsc FOR bseg-hkont                  " Correspondence assount
          MATCHCODE OBJECT sako,
    kober FOR bseg-gsber no-display MEMORY ID gsb.   " Correspondence BusSphera
.
PARAMETERS ugks TYPE j_3rk_group_level." Corr. Acct Grouping Level
SELECTION-SCREEN END OF BLOCK date_b.

SELECTION-SCREEN BEGIN OF BLOCK date WITH FRAME TITLE text-022.
SELECT-OPTIONS:
    so_gjahr for bkpf-gjahr no-EXTENSION, "note 1880674
    monat FOR bkpf-monat NO-EXTENSION OBLIGATORY,  " Period
    budat FOR bkpf-budat NO-EXTENSION OBLIGATORY.  " Post date
SELECT-OPTIONS:
    belnr FOR bseg-belnr,                  " Documents number
    blart FOR bkpf-blart.                  " Documents type
PARAMETERS:
    bukrs   LIKE bkpf-bukrs MEMORY ID buk OBLIGATORY.  " CoCd
SELECTION-SCREEN END OF BLOCK date.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN END  OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE text-099.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT   1(30) text-011 FOR FIELD gksc.
PARAMETERS gksc AS CHECKBOX DEFAULT 'X'. " Group by Corr. Account
SELECTION-SCREEN COMMENT  36(21)  text-012 FOR FIELD gdat.            "ACC30
PARAMETERS gdat    AS CHECKBOX.   " Group by Date
SELECTION-SCREEN COMMENT  62(25) text-013 FOR FIELD gdoc.             "ACC30
PARAMETERS gdoc    AS CHECKBOX.  " Group by Document
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT   1(30) text-014 FOR FIELD gcustven.
PARAMETERS gcustven  TYPE j_3rk_cust_vend_group AS CHECKBOX.
SELECTION-SCREEN END OF LINE.

PARAMETERS:
  invo     TYPE j_3rk_internal_turnovers
           AS CHECKBOX DEFAULT 'X',       " Display with internal turnovers
  zeroline TYPE j_3rk_zero_documents
           AS CHECKBOX,        " Display documents with zero lines
  gsbergrp TYPE j_3rk_hide_business_area  NO-DISPLAY.
PARAMETERS nozero  AS CHECKBOX.
PARAMETERS:
    p_altkt  LIKE rfpdo1-allgaltk NO-DISPLAY.   "alternative account number
SELECTION-SCREEN END OF BLOCK blk3.


SELECTION-SCREEN BEGIN OF BLOCK blk4 WITH FRAME TITLE text-001.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(30) text-002 FOR FIELD tpos.
PARAMETERS tpos AS CHECKBOX.
SELECTION-SCREEN COMMENT 36(21) text-003 FOR FIELD pros.
PARAMETERS pros    AS CHECKBOX.
SELECTION-SCREEN COMMENT 62(25) text-004 FOR FIELD dkos.
PARAMETERS
    dkos AS CHECKBOX.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(30) text-005 FOR FIELD tpks.
PARAMETERS tpks AS CHECKBOX.
SELECTION-SCREEN COMMENT 36(21) text-006 FOR FIELD prks.
PARAMETERS prks AS CHECKBOX.
SELECTION-SCREEN COMMENT 62(25) text-007 FOR FIELD dkks.
PARAMETERS
   dkks AS CHECKBOX.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT  1(30) text-008 FOR FIELD nmks.
PARAMETERS nmks AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 36(21) text-009 FOR FIELD zdoc.
PARAMETERS zdoc  AS CHECKBOX.
SELECTION-SCREEN END   OF LINE.
PARAMETERS p_prn_sl AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK blk4.




*----------------------------------------------------------------
INITIALIZATION.
  g_repid = sy-repid.
  GET PARAMETER ID 'J3RK_BDTL' FIELD bdl.
  GET PARAMETER ID 'J3RK_BDTH' FIELD bdh.

  IF bdl IS INITIAL.
    budat-high      = sy-datum.
    budat-high+6(2) = '01'.
    budat-high      = budat-high - 1.
    budat-low       = budat-high.
    budat-low+6(2)  = '01'.
  ELSE.
    budat-low       = bdl.
    budat-high      = bdh.
  ENDIF.
  APPEND budat.

  GET PARAMETER ID 'J3RK_MNL' FIELD mnl.
  GET PARAMETER ID 'J3RK_MNH' FIELD mnh.

  IF mnl IS INITIAL.
    GET PARAMETER ID 'BUK' FIELD bukrs.
    IF NOT bukrs IS INITIAL.
* Adjust periods according to ledger settings
      call function 'J3RK_CUSTOMIZING_GET_LEDGER'
        EXPORTING
          iv_bukrs  = bukrs
        importing
          ev_ledger = gv_rldnr.
      IF NOT budat-low IS INITIAL.
        CALL FUNCTION 'FI_PERIOD_DETERMINE'
          EXPORTING
            i_budat = budat-low
            i_bukrs = bukrs
            i_rldnr = GV_RLDNR
          IMPORTING
            e_monat = monat-low.
      ENDIF.
      IF NOT budat-high IS INITIAL.
        CALL FUNCTION 'FI_PERIOD_DETERMINE'
          EXPORTING
            i_budat = budat-high
            i_bukrs = bukrs
            i_rldnr = GV_RLDNR
          IMPORTING
            e_monat = monat-high.
        IF monat-high = monat-low.
          CLEAR monat-high.
        ENDIF.
      ENDIF.
    ELSE.
      monat-low = budat-low+4(2).
      IF monat-low <> budat-high+4(2).
        monat-high = budat-high+4(2).
      ENDIF.
    ENDIF.

  ELSE.
    monat-low  = mnl.
    IF mnh <> mnl.
      monat-high = mnh.
    ENDIF.
  ENDIF.
  APPEND monat.

  GET PARAMETER ID 'J3RK_ZGO' FIELD zgo.
  GET PARAMETER ID 'J3RK_ZGK' FIELD zgk.

  IF zgo IS INITIAL AND zgk IS INITIAL.
    zgo = '5'.
    zgk = '5'.
  ENDIF.
  ugos = zgo.
  IF ugos = '0'.
    ugos = ' '.
  ENDIF.
  ugks = zgk.
  IF ugks = '0'.
    ugks = ' '.
  ENDIF.

*-------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  IF gdoc = 'X'.
    gksc = ' '.
    gdat = ' '.
  ENDIF.
*-------------------------------------------------------------------
AT SELECTION-SCREEN ON bukrs.
  SELECT SINGLE * FROM t001
      WHERE bukrs = bukrs.

  IF sy-subrc = 0.
    AUTHORITY-CHECK
        OBJECT 'F_BKPF_BUK'
            ID 'BUKRS' FIELD bukrs
            ID 'ACTVT' FIELD '03'.    " '03' - ïðîñìîòð ???
    IF sy-subrc <> 0.
      MESSAGE e001 WITH bukrs.
    ENDIF.
  ELSE.
    MESSAGE e002 WITH bukrs.
  ENDIF.

*-------------------------------------------------------------------
AT SELECTION-SCREEN.
  SELECT SINGLE * FROM t001
      WHERE bukrs = bukrs.

  call function 'J3RK_CUSTOMIZING_GET_LEDGER'
    exporting
      iv_bukrs  = bukrs
    importing
      ev_ledger = gv_rldnr.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = budat-low
      i_bukrs        = bukrs
      i_rldnr        = GV_RLDNR
    IMPORTING
      e_gjahr        = gjahr
      e_monat        = begmn
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = budat-high
      i_bukrs        = bukrs
      i_rldnr        = GV_RLDNR
    IMPORTING
      e_gjahr        = gjahr_h
      e_monat        = endmn
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF gjahr <> gjahr_h.
    MESSAGE e007.
  ENDIF.
  IF monat-low BETWEEN 13 AND 16.
    IF begmn <> 12 OR endmn <> 12.
      MESSAGE e006.
    ENDIF.
  ELSE.
    IF monat-high IS INITIAL.
      IF begmn <> monat-low
          OR endmn <> monat-low.
        MESSAGE e005 WITH monat-low budat-low.
      ENDIF.
    ELSE.
      IF begmn < monat-low
          OR endmn > monat-high.
        MESSAGE e005 WITH monat-low budat-low.
      ENDIF.
    ENDIF.
  ENDIF.
  IF p_altkt = 'X'.
    t001-ktopl = t001-ktop2.
    gs_osnsc-sign = 'I'.
    gs_osnsc-option = 'EQ'.
    IF NOT osnsc IS INITIAL.
      SELECT saknr INTO gs_osnsc-low FROM skb1        "#EC CI_SGLSELECT
                   WHERE bukrs = bukrs AND              "#EC CI_GENBUFF
                         altkt IN osnsc.
        COLLECT gs_osnsc INTO g_so_osnsc.
      ENDSELECT.
    ENDIF.
    IF NOT korsc IS INITIAL.
      SELECT saknr INTO gs_osnsc-low FROM skb1        "#EC CI_SGLSELECT
                   WHERE bukrs = bukrs AND              "#EC CI_GENBUFF
                         altkt IN korsc.
        COLLECT gs_osnsc INTO g_so_korsc.
      ENDSELECT.
    ENDIF.

    " if both accounts are not found then generate an error          " 1177094
    IF ( g_so_osnsc IS INITIAL ) AND ( g_so_korsc IS INITIAL ).
      IF NOT osnsc IS INITIAL.
        MESSAGE e031 WITH osnsc-low t001-ktopl.
      ENDIF.
      IF NOT korsc IS INITIAL.
        MESSAGE e031 WITH korsc-low t001-ktopl.
      ENDIF.
    ENDIF.

    " if a user sets operative account then use it for the filter   " 1177094
    IF ( g_so_osnsc IS INITIAL ) AND ( NOT osnsc IS INITIAL ).
      g_so_osnsc[] = osnsc[].
    ENDIF.
    IF ( g_so_korsc IS INITIAL ) AND ( NOT korsc IS INITIAL ).
      g_so_korsc[] = korsc[].
    ENDIF.

  ELSE.
    g_so_osnsc[] = osnsc[].
    g_so_korsc[] = korsc[].
  ENDIF.

  gv_langu = sy-langu. "note 1886074
  "check with logon language
  SELECT * FROM skat                                    "#EC CI_GENBUFF
      WHERE spras =  gv_langu "note 1886074
        AND ktopl = t001-ktopl
        AND saknr IN osnsc.                           "#EC CI_SGLSELECT
    EXIT.
  ENDSELECT.
  IF NOT sy-subrc IS INITIAL.
    "<note 1886074>
    "check with maintenance language
    SELECT SINGLE dspra FROM t004 INTO gv_langu
       WHERE ktopl = t001-ktopl
    .
    SELECT * FROM skat                                  "#EC CI_GENBUFF
      WHERE spras =  gv_langu "note 1886074
        AND ktopl = t001-ktopl
        AND saknr IN osnsc.                           "#EC CI_SGLSELECT
      EXIT.
    ENDSELECT.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e004 WITH osnsc-low t001-ktopl.
    ENDIF.
    "</note 1886074>
  ENDIF.

  IF gksc IS INITIAL AND gdat IS INITIAL AND gdoc IS INITIAL.
    gksc = 'X'.                        " Ãðóïïèðîâêà ïî ÊîððÑ÷åòó
  ENDIF.

  SET PARAMETER ID 'J3RK_ZGO' FIELD ugos.
  SET PARAMETER ID 'J3RK_ZGK' FIELD ugks.
  SET PARAMETER ID 'J3RK_BDTL' FIELD budat-low.
  SET PARAMETER ID 'J3RK_BDTH' FIELD budat-high.
  SET PARAMETER ID 'J3RK_MNL' FIELD monat-low.
  SET PARAMETER ID 'J3RK_MNH' FIELD monat-high.

*------------------------------------------------------------------
START-OF-SELECTION.
  SELECT SINGLE sakln INTO (g_sakln) FROM t004 WHERE ktopl = t001-ktopl.
  g_sakln = 10 - g_sakln.

  FORMAT RESET.
  GET TIME FIELD begtm.

  IF gdoc = 'X'.
    gksc = ' '.
    gdat = ' '.
  ENDIF.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = budat-low
      i_bukrs        = bukrs
      i_rldnr        = GV_RLDNR
    IMPORTING
      e_gjahr        = gjahr
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'J_3RK_CHECK_MIGRATION'
    EXPORTING
      IV_BUKRS = bukrs
      IV_GJAHR = gjahr.

* If ending period is not given than
* ending period = beginning period
  READ TABLE monat INDEX 1.
  IF monat-high IS INITIAL.
    monat-option = 'BT'.
    monat-high   = monat-low.
    MODIFY monat INDEX 1.
  ENDIF.
  IF NOT GV_RLDNR IS INITIAL.
    CALL FUNCTION 'G_GET_ORGANIZATIONAL_DATA'
      EXPORTING
        i_rldnr             = GV_RLDNR
        i_orgunit           = bukrs
      IMPORTING
        ORGANIZATIONAL_INFO = GS_ORG_INFO
      EXCEPTIONS
        NO_INFO_FOUND       = 1
        ERROR_IN_SETUP      = 2
        ERROR_IN_DEPLD      = 3
        OTHERS              = 4.
    IF sy-subrc EQ 0 AND NOT GS_ORG_INFO-PERIV IS INITIAL.
      GV_PERIV = GS_ORG_INFO-PERIV.
    ENDIF.
  ENDIF.
  IF GV_PERIV IS INITIAL.
    GV_PERIV = t001-periv.
  ENDIF.
* Determination of the first date of the beginning month and last date
* of the ending month
  poper = monat-low.
  CALL FUNCTION 'FIRST_DAY_IN_PERIOD_GET'
    EXPORTING
      i_gjahr        = gjahr
      i_periv        = GV_PERIV
      i_poper        = poper
    IMPORTING
      e_date         = begdt
    EXCEPTIONS
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  poper = monat-high.
  CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
    EXPORTING
      i_gjahr        = gjahr
      i_periv        = GV_PERIV
      i_poper        = poper
    IMPORTING
      e_date         = enddt
    EXCEPTIONS
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF ( belnr IS INITIAL )
       AND ( blart IS INITIAL )
       AND gdoc = ' '
       AND gdat = ' '
       AND gcustven IS INITIAL.
* Period validation
    PERFORM prov_period.
  ENDIF.

* Account selection
  nosc = 0.
  SELECT * FROM skat                                    "#EC CI_GENBUFF
      WHERE spras =  gv_langu
        AND ktopl = t001-ktopl
        AND saknr IN osnsc.                           "#EC CI_SGLSELECT

    SELECT SINGLE *
       FROM skb1
       WHERE bukrs =  bukrs
         AND saknr = skat-saknr.

    AUTHORITY-CHECK
        OBJECT 'F_BKPF_BES'
            ID 'BRGRU' FIELD skb1-begru
            ID 'ACTVT' FIELD '03'.    " '03' - ïðîñìîòð ???
    IF sy-subrc <> 0 AND NOT skb1-begru IS INITIAL.
      IF no_auth_saknr_cnt = 0.
        WRITE: /
       'No authorization for processing with selected account'(108)
        COLOR COL_GROUP.
        WRITE / '' NO-GAP.
      ENDIF.

      no_auth_saknr_cnt = no_auth_saknr_cnt + 1.
      i = no_auth_saknr_cnt MOD 8.
      WRITE  (10) skat-saknr .
      IF i = 0.
        WRITE / '' NO-GAP.
      ENDIF.
    ELSE.

      READ TABLE ss WITH KEY saknr = skat-saknr.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
* Balance calculation
      IF p_altkt IS INITIAL.
        PERFORM calc_saldo.
      ELSE.
        PERFORM calc_alt_saldo.
      ENDIF.

      LOOP AT ss1.
        MOVE-CORRESPONDING skat TO ss1.                     "#EC ENHOK
        IF P_ALTKT is INITIAL.
          APPEND ss1 TO ss.
        ELSE.
          COLLECT ss1 INTO ss.
        ENDIF.

* Account type selection
        SELECT SINGLE sakan FROM ska1 INTO ss1-sakan WHERE
             ktopl = t001-ktopl AND saknr = ss1-saknr.
        ss1-saknr = ss1-sakan.

* Sumarization
        IF ugos > 0.
          WRITE '*         ' TO ss1-saknr+ugos.
          CONDENSE ss-saknr NO-GAPS.
          ss1-txt50 = space.
        ENDIF.

        CLEAR ssg.
        MOVE-CORRESPONDING ss1 TO ssg.
        COLLECT ssg.
        nosc = nosc + 1.
      ENDLOOP.

    ENDIF.
  ENDSELECT.                           " Êîíåö âûáîðêè ÎÑ÷.

  IF nosc = 0.
    IF no_auth_saknr_cnt > 0.
      MESSAGE i010.
      "ELSE.
      " commented, because the report can contain only correspondence without documents
      "  MESSAGE i009.
      "ENDIF.
*    leave to transaction sy-tcode.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

  IF LINES( g_so_osnsc ) > 500 OR LINES( g_so_korsc ) > 500.
    g_so_osnsc2[] = g_so_osnsc[].
    g_so_korsc2[] = g_so_korsc[].
    REFRESH: g_so_osnsc, g_so_korsc.
  ENDIF.

* Correspondence selection
  IF period = 0.
    SELECT * FROM j_3rk_corr_items
        WHERE bukrs = bukrs
          AND (
                ( debet IN g_so_osnsc AND kredit IN g_so_korsc AND
                  gsberd IN osber AND gsberk IN kober )
             OR ( debet IN g_so_korsc AND kredit IN g_so_osnsc AND
                  gsberd IN kober AND gsberk IN osber )
              )
          AND budat >= begdt
          AND budat <= enddt
          and gjahr in so_gjahr "note 1886074
*          and gjahr = gjahr
          AND monat IN monat
          AND belnr IN belnr
          AND blart IN blart.
      CHECK ( j_3rk_corr_items-debet IN g_so_osnsc2 AND j_3rk_corr_items-kredit IN g_so_korsc2 AND
              j_3rk_corr_items-gsberd IN osber AND j_3rk_corr_items-gsberk IN kober )
           OR ( j_3rk_corr_items-debet IN g_so_korsc2 AND j_3rk_corr_items-kredit IN g_so_osnsc2 AND
                j_3rk_corr_items-gsberd IN kober AND j_3rk_corr_items-gsberk IN osber ).

      CALL FUNCTION 'FI_GSBER_AUTH_CHECK'
        EXPORTING
          i_gsber  = j_3rk_corr_items-gsberd
          i_aktvt  = '03'
        IMPORTING
          e_rtcode = rtcode.
      CHECK rtcode = 0.
      CALL FUNCTION 'FI_GSBER_AUTH_CHECK'
        EXPORTING
          i_gsber  = j_3rk_corr_items-gsberk
          i_aktvt  = '03'
        IMPORTING
          e_rtcode = rtcode.
      CHECK rtcode = 0.
      IF p_altkt = 'X'.
        CALL FUNCTION 'READ_SACHKONTO_ALTKT'
          EXPORTING
            bukrs           = j_3rk_corr_items-bukrs
            saknr           = j_3rk_corr_items-debet
          IMPORTING
            altkt           = j_3rk_corr_items-debet
            altkt_not_found = g_not_found
          EXCEPTIONS
            saknr_not_found = 1.
        IF g_not_found = 'X' OR sy-subrc <> 0.
          j_3rk_corr_items-debet = text-030.
        ENDIF.
        CALL FUNCTION 'READ_SACHKONTO_ALTKT'
          EXPORTING
            bukrs           = j_3rk_corr_items-bukrs
            saknr           = j_3rk_corr_items-kredit
          IMPORTING
            altkt           = j_3rk_corr_items-kredit
            altkt_not_found = g_not_found
          EXCEPTIONS
            saknr_not_found = 1.
        IF g_not_found = 'X' OR sy-subrc <> 0.
          j_3rk_corr_items-kredit = text-030.
        ENDIF.
      ENDIF.

      xdeb = j_3rk_corr_items-debet.
* Select account type
      SELECT SINGLE sakan
          FROM ska1
          INTO xdeb
          WHERE ktopl = t001-ktopl AND saknr = xdeb.
      xkre = j_3rk_corr_items-kredit.
* Select account type
      SELECT SINGLE sakan
          FROM ska1
          INTO xkre
          WHERE ktopl = t001-ktopl AND saknr = xkre.
      IF ugos > 0 AND invo <> 'X'
          AND xdeb IN osnsc AND xkre IN osnsc.
* Suppress internal turnovers
        WRITE '          ' TO xdeb+ugos.
        WRITE '          ' TO xkre+ugos.
      ENDIF.

      IF invo = 'X' OR xdeb <> xkre.
        MOVE-CORRESPONDING j_3rk_corr_items TO z.
        APPEND z.
      ENDIF.
    ENDSELECT.
  ELSE.
* For report for entire period selection from total table
    SELECT *
        FROM j_3rkkr0
        WHERE bukrs = bukrs
         AND (
               ( debet IN g_so_osnsc AND kredit IN g_so_korsc AND
                 gsberd IN osber AND gsberk IN kober )
         OR    ( debet IN g_so_korsc AND kredit IN g_so_osnsc AND
                 gsberd IN kober AND gsberk IN osber )
             )
         AND gjahr = gjahr.
      CHECK ( j_3rkkr0-debet IN g_so_osnsc2 AND j_3rkkr0-kredit IN g_so_korsc2 AND
              j_3rkkr0-gsberd IN osber AND j_3rkkr0-gsberk IN kober )
           OR ( j_3rkkr0-debet IN g_so_korsc2 AND j_3rkkr0-kredit IN g_so_osnsc2 AND
                j_3rkkr0-gsberd IN kober AND j_3rkkr0-gsberk IN osber ).

      CALL FUNCTION 'FI_GSBER_AUTH_CHECK'
        EXPORTING
          i_gsber  = j_3rkkr0-gsberd
          i_aktvt  = '03'
        IMPORTING
          e_rtcode = rtcode.
      CHECK rtcode = 0.
      CALL FUNCTION 'FI_GSBER_AUTH_CHECK'
        EXPORTING
          i_gsber  = j_3rkkr0-gsberk
          i_aktvt  = '03'
        IMPORTING
          e_rtcode = rtcode.
      CHECK rtcode = 0.
      IF p_altkt = 'X'.
        CALL FUNCTION 'READ_SACHKONTO_ALTKT'
          EXPORTING
            bukrs           = j_3rkkr0-bukrs
            saknr           = j_3rkkr0-debet
          IMPORTING
            altkt           = j_3rkkr0-debet
            altkt_not_found = g_not_found
          EXCEPTIONS
            saknr_not_found = 1.
        IF g_not_found = 'X' OR sy-subrc <> 0.
          j_3rkkr0-debet = text-030.
        ENDIF.
        CALL FUNCTION 'READ_SACHKONTO_ALTKT'
          EXPORTING
            bukrs           = j_3rkkr0-bukrs
            saknr           = j_3rkkr0-kredit
          IMPORTING
            altkt           = j_3rkkr0-kredit
            altkt_not_found = g_not_found
          EXCEPTIONS
            saknr_not_found = 1.
        IF g_not_found = 'X' OR sy-subrc <> 0.
          j_3rkkr0-kredit = text-030.
        ENDIF.
      ENDIF.

      xdeb = j_3rkkr0-debet.
* Select account type
      SELECT SINGLE sakan
          FROM ska1
          INTO xdeb
          WHERE ktopl = t001-ktopl AND saknr = xdeb.

      xkre = j_3rkkr0-kredit.
* Select account type
      SELECT SINGLE sakan
          FROM ska1
          INTO xkre
          WHERE ktopl = t001-ktopl AND saknr = xkre.

      IF ugos > 0 AND invo <> 'X'
          AND xdeb IN osnsc AND xkre IN osnsc.
* Suppress internal turnovers
        WRITE '          ' TO xdeb+ugos.
        WRITE '          ' TO xkre+ugos.
      ENDIF.

      IF invo = 'X' OR xdeb <> xkre.
        MOVE-CORRESPONDING j_3rkkr0 TO z.                   "#EC ENHOK
        WHILE sy-index <= monat-high
            VARY xsaldo FROM j_3rkkr0-hsl01 NEXT j_3rkkr0-hsl02.
          IF sy-index >= monat-low.
            IF xsaldo <> 0.
              z-dmbtr = xsaldo.
              IF sy-index <> endmn.
                IF sy-index <> monat-high.
                  mn = sy-index.
                  IF mn > 12. mn = 12. ENDIF.
*                  CONCATENATE gjahr mn '01' INTO z-budat.
                  DATA lv_poper TYPE poper.                 "N2331374
                  lv_poper = mn.
                  CALL FUNCTION 'FIRST_DAY_IN_PERIOD_GET' "N2331374
                    EXPORTING
                      i_gjahr        = gjahr
                      i_periv        = gv_periv
                      i_poper        = lv_poper
                    IMPORTING
                      e_date         = z-budat
                    EXCEPTIONS
                      input_false    = 1
                      t009_notfound  = 2
                      t009b_notfound = 3
                      OTHERS         = 4.
                ELSE.
                  z-budat = enddat.
                ENDIF.
              ELSE.
                z-budat = budat-high.
              ENDIF.
              APPEND z.
            ENDIF.
          ENDIF.
        ENDWHILE.
      ENDIF.
    ENDSELECT.
  ENDIF.

  DESCRIBE TABLE z LINES i.
  IF i = 0.
*    MESSAGE i013.
*    SET SCREEN 0.
*    LEAVE SCREEN.
  ENDIF.

* PERFORM write_header.

  IF nozero = 'X'.
    DELETE ssg WHERE saldo_01 = 0 AND
                     saldo_31 = 0 AND
                     turn_s = 0 AND
                     turn_h = 0.
  ENDIF.

  SORT ssg BY saknr gsber.
  LOOP AT ssg.                         " Ïî âñåì óêðóïíåííûì ÎÑ÷
    ON CHANGE OF ssg-saknr OR ssg-gsber.
      PERFORM wr_tit.                  " Âûâîä çàãîëîâêà
    ENDON.

    do01_n = 0.
    ko01_n = 0.
    IF g_sakln = 0.
      LOOP AT ss WHERE saknr CP ssg-saknr and gsber = ssg-gsber. "N2339321
        LOOP AT z WHERE budat < budat-low.
          IF z-debet = ss-saknr AND z-gsberd = ss-gsber.    "N2328553
            do01_n = do01_n + z-dmbtr.
          ENDIF.
          IF z-kredit = ss-saknr AND z-gsberk = ss-gsber.   "N2328553
            ko01_n = ko01_n + z-dmbtr.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ELSEIF g_sakln ge 10.
      LOOP AT ss.
        CLEAR gv_saknr_tmp.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = ss-saknr
          IMPORTING
            OUTPUT = gv_saknr_tmp.

        CHECK gv_saknr_tmp CP ssg-saknr and ss-gsber = ssg-gsber. "N2339321
        LOOP AT z WHERE budat < budat-low.
          IF z-debet = ss-saknr AND z-gsberd = ss-gsber.    "N2339321
            do01_n = do01_n + z-dmbtr.
          ENDIF.
          IF z-kredit = ss-saknr AND z-gsberk = ss-gsber.   "N2339321
            ko01_n = ko01_n + z-dmbtr.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      LOOP AT ss.
        CHECK ss-saknr+g_sakln CP ssg-saknr and ss-gsber = ssg-gsber. "N2339321
        LOOP AT z WHERE budat < budat-low.
          IF z-debet = ss-saknr AND z-gsberd = ss-gsber.    "N2339321.
            do01_n = do01_n + z-dmbtr.
          ENDIF.
          IF z-kredit = ss-saknr AND z-gsberk = ss-gsber.   "N2339321
            ko01_n = ko01_n + z-dmbtr.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

* Debit turnovers
    don_k  = 0.
    dok_31 = 0.
    kon_k  = 0.
    kok_31 = 0.
    REFRESH zg.
    CLEAR zg.
*    loop at ss where saknr cp ssg-saknr.
    LOOP AT ss.
* Select account type
      SELECT SINGLE sakan
          FROM ska1
          INTO ss-sakan
          WHERE ktopl = t001-ktopl AND saknr = ss-saknr.
      IF ss-sakan CP ssg-saknr AND ss-gsber = ssg-gsber.
        LOOP AT z WHERE  ( debet = ss-saknr AND gsberd = ss-gsber )
            AND budat >= budat-low.
* Summarization
          PERFORM od_coll_zg.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT ss.
* Select account type
      SELECT SINGLE sakan
          FROM ska1
          INTO ss-sakan
          WHERE ktopl = t001-ktopl AND saknr = ss-saknr.
      IF ss-sakan CP ssg-saknr AND ss-gsber = ssg-gsber.
        LOOP AT z WHERE ( kredit = ss-saknr AND gsberk = ss-gsber )
            AND budat >= budat-low.
* Credit turnovers and summarization
          PERFORM ok_coll_zg.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF NOT korsc[] IS INITIAL.
      LOOP AT zg.
        g_not_found = 'X'.
        SELECT sakan FROM ska1 INTO xdeb WHERE saknr IN korsc[]. "#EC CI_SGLSELECT
          IF xdeb CP zg-hkont.
            CLEAR g_not_found.
            EXIT.
          ENDIF.
        ENDSELECT.
        IF g_not_found = 'X'.
          DELETE zg.
        ENDIF.
      ENDLOOP.
    ENDIF.

    PERFORM wr_od.                     " Output of debit turnovers

    PERFORM wr_ok.                     " Output of credit turnovers

    PERFORM wr_odk_saldo.      " Output of totals and balances

  ENDLOOP.


  GET TIME FIELD endtm.
  begtm = endtm - begtm.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_structure_name       = 'ZFIJ_3RKORRREP_ALV_ITEM'
      i_internal_tabname     = 'GT_ITEM'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



  DATA total_text_len_hd TYPE i.
  CLEAR total_text_len_hd.
  PERFORM hide_some_items_fields CHANGING total_text_len_hd.
  PERFORM eventtab_build CHANGING gt_events[].


**********************************************************************

  FIELD-SYMBOLS <fs_item> like LINE OF gt_item.
  LOOP AT gt_item ASSIGNING <fs_item>.
    <fs_item>-DUMMY = '2'.
  ENDLOOP.

  DATA: sn TYPE J_3RK_BEG_BALANCE,
        ob_d TYPE J_3RK_BEG_BALANCE,
        ob_k TYPE J_3RK_BEG_BALANCE,
        sk TYPE J_3RK_BEG_BALANCE.
  CLEAR: sn, ob_d, ob_k, sk.
  FIELD-SYMBOLS: <fs_head> like line of gt_header.
  LOOP AT gt_header ASSIGNING <fs_head>.
    DATA: ls_item LIKE LINE OF gt_item.
    MOVE-CORRESPONDING <fs_head> TO ls_item.
    CASE ls_item-DUMMY.
      WHEN ' '.
        sn = sn + <fs_head>-BEG_BAL - <fs_head>-END_BAL.
        ls_item-DUMMY = '1'.
        ls_item-GTEXT = 'Сальдо начальное'.
        SELECT SINGLE TXT50
          FROM SKAT
          INTO ls_item-NOTE1
          WHERE SAKNR = ls_item-DEBIT
            AND KTOPL = '1000'
            AND SPRAS = sy-langu.
        ls_item-COLOR = 'C110'.
      WHEN '1'.
        ob_d = ob_d + <fs_head>-BEG_BAL.
        ob_k = ob_k + <fs_head>-END_BAL.
        ls_item-DUMMY = '3'.
        ls_item-GTEXT = 'Обороты'.
        SELECT SINGLE TXT50
          FROM SKAT
          INTO ls_item-NOTE1
          WHERE SAKNR = ls_item-DEBIT
            AND KTOPL = '1000'
            AND SPRAS = sy-langu.
        ls_item-COLOR = 'C300'.
      When '2'.
        sk = sk + <fs_head>-BEG_BAL - <fs_head>-END_BAL.
        ls_item-DUMMY = '4'.
        ls_item-GTEXT = 'Сальдо конечное'.
        SELECT SINGLE TXT50
          FROM SKAT
          INTO ls_item-NOTE1
          WHERE SAKNR = ls_item-DEBIT
            AND KTOPL = '1000'
            AND SPRAS = sy-langu.
        ls_item-COLOR = 'C510'.
      WHEN OTHERS.
    ENDCASE.
    APPEND ls_item TO gt_item.
  ENDLOOP.

  CLEAR: ls_item.
  IF sn > 0.
    ls_item-BEG_BAL = sn.
  ELSE.
    ls_item-END_BAL = sn * -1.
  ENDIF.
  ls_item-DUMMY = '0'.
  ls_item-GTEXT = 'Сальдо начальное'.
  ls_item-COLOR = 'C710'.
  APPEND ls_item TO gt_item.
  CLEAR: ls_item.
  ls_item-BEG_BAL = ob_d.
  ls_item-END_BAL = ob_k.
  ls_item-DEBIT = 'ZZZZZZZZZZ'.
  ls_item-DUMMY = '5'.
  ls_item-GTEXT = 'Обороты'.
  ls_item-COLOR = 'C710'.
  APPEND ls_item TO gt_item.
  CLEAR: ls_item.
  IF sk > 0.
    ls_item-BEG_BAL = sk.
  ELSE.
    ls_item-END_BAL = sk * -1.
  ENDIF.
  ls_item-DEBIT = 'ZZZZZZZZZZ'.
  ls_item-DUMMY = '6'.
  ls_item-GTEXT = 'Сальдо конечное'.
  ls_item-COLOR = 'C710'.
  APPEND ls_item TO gt_item.

  SORT gt_item by DEBIT DUMMY.

  FIELD-SYMBOLS: <fs_i> like LINE OF gt_item.
  LOOP AT gt_item ASSIGNING <fs_i> WHERE DEBIT+0(2) = '51' or DEBIT+0(2) = '52'.
     DATA: lv_BKONT   TYPE t012k-BKONT,
              lv_BANKN   TYPE t012k-BANKN,
              lv_hkont_b TYPE bseg-hkont.
        CLEAR: lv_bkont, lv_bankn, lv_hkont_b.
        CONCATENATE <fs_i>-DEBIT+0(8) '00' INTO lv_hkont_b.
        SELECT SINGLE BKONT BANKN
          FROM T012k
          INTO (lv_BKONT, lv_BANKN)
          WHERE HKONT = lv_hkont_b
           AND BUKRS = bukrs.
        CONCATENATE lv_BKONT lv_BANKN INTO <fs_i>-ZFI_BANK_ACC.
  ENDLOOP.


  DATA: ls_lya TYPE SLIS_LAYOUT_ALV.
  ls_lya-info_fieldname = 'COLOR'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      I_CALLBACK_PROGRAM = g_repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      IS_LAYOUT          = ls_lya
      IT_FIELDCAT        = gt_fieldcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
      IT_SORT            = gt_sort
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
      I_SAVE             = 'A'
*     IS_VARIANT         =
      IT_EVENTS          = gt_events
*     IT_EVENT_EXIT      =
*     IS_PRINT           =
*     IS_REPREP_ID       =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  = 0
*     I_HTML_HEIGHT_END  = 0
*     IT_ALV_GRAPHICS    =
*     IT_HYPERLINK       =
*     IT_ADD_FIELDCAT    =
*     IT_EXCEPT_QINFO    =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB           = gt_item
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


*&--------------------------------------------------------------------*
*&      Form  write_footer
*&--------------------------------------------------------------------*
*       Output of the report footer
*---------------------------------------------------------------------*
FORM write_footer.                                          "#EC CALLED

ENDFORM.                    "write_footer

*&--------------------------------------------------------------------*
*&      Form  user_command
*&--------------------------------------------------------------------*
*       Dirll-down to basic document list
*---------------------------------------------------------------------*
*      -->R_UCOMM    text
*      -->RS_SELFIELDtext
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm               "#EC *
                        rs_selfield TYPE slis_selfield.

  rs_selfield-refresh = 'X'.
  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.
  CASE r_ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN '&IC1'. "проваливание по 2 клику
      DATA p_chkgsb TYPE c.                                 " 1238063
      CHECK rs_selfield-tabname = 'GT_ITEM'.
      READ TABLE gt_item INDEX rs_selfield-tabindex.
      IF ( rs_selfield-fieldname  = 'BEG_BAL' AND gt_item-kside = 'X' ) OR
         ( rs_selfield-fieldname  = 'END_BAL' AND gt_item-kside IS INITIAL ).
        EXIT.
      ENDIF.
      gdebet = gt_item-debit.
      gkredit = gt_item-credit.

      RANGES s_hkont FOR bseg-hkont.
      RANGES k_hkont FOR bseg-hkont.
      RANGES t_hkont FOR bseg-hkont.
      RANGES l_budat FOR bkpf-budat.
      CLEAR: k_hkont, k_hkont[], s_hkont, s_hkont[].
      CHECK NOT gdebet IS INITIAL AND NOT gkredit IS INITIAL.
      gdebet = gt_item-debit.
      gkredit = gt_item-credit.
      REFRESH: gsdlifnr, gsdkunnr, gsklifnr, gskkunnr.
      PERFORM fill_range_vendor  TABLES gsdlifnr
                                 USING gt_item-dlifnr.
      PERFORM fill_range_customer TABLES gsdkunnr
                                  USING gt_item-dkunnr.

      PERFORM fill_range_vendor TABLES gsklifnr
                                USING gt_item-klifnr.
      PERFORM fill_range_customer TABLES gskkunnr
                                  USING gt_item-kkunnr.
      s_hkont-sign = 'I'.
      s_hkont-option = 'EQ'.

      SELECT saknr INTO s_hkont-low FROM skb1 WHERE ( saknr IN osnsc OR "#EC CI_GENBUFF
                                                    saknr IN korsc ) AND
                                                  bukrs = bukrs. "#EC CI_SGLSELECT
        CHECK s_hkont-low IN osnsc.
        SELECT SINGLE sakan FROM ska1 INTO xdeb
                                      WHERE ktopl = t001-ktopl AND
                                            saknr = s_hkont-low.
        IF xdeb CP gdebet.
          APPEND s_hkont.
        ENDIF.
      ENDSELECT.

      k_hkont-sign = 'I'.
      k_hkont-option = 'EQ'.

      SELECT saknr INTO k_hkont-low FROM skb1 WHERE ( saknr IN korsc OR "#EC CI_GENBUFF
                                                      saknr IN osnsc ) AND
                                                    bukrs = bukrs. "#EC CI_SGLSELECT
        CHECK k_hkont-low IN korsc.
        SELECT SINGLE sakan FROM ska1 INTO xkre
                                      WHERE ktopl = t001-ktopl AND
                                            saknr = k_hkont-low.
        IF xkre CP gkredit.
          APPEND k_hkont.
        ENDIF.
      ENDSELECT.
      IF gdat = 'X' AND NOT gt_item-budat IS INITIAL.
        REFRESH l_budat.
        l_budat-sign = 'I'.
        l_budat-option = 'EQ'.
        l_budat-low = gt_item-budat.
        APPEND l_budat.
      ELSE.
        l_budat[] = budat[].
      ENDIF.
      gkside = gt_item-kside .
      p_chkgsb = ' '.
      IF gsbergrp EQ 'X'.
        p_chkgsb = 'X'.
      ENDIF.

      SUBMIT j_3rkldk
              WITH osnsc IN s_hkont
              WITH osber = gsberd
              with gjahr in so_gjahr
              WITH monat IN monat
              WITH budat IN l_budat
              WITH belnr IN belnr
              WITH korsc IN k_hkont
              WITH kober = gsberk
              WITH bukrs =  bukrs
              WITH kside = gkside
              WITH p_altkt = p_altkt
              WITH gcustven = gcustven
              WITH sdlifnr IN gsdlifnr
              WITH sdkunnr IN gsdkunnr
              WITH sklifnr IN gsklifnr
              WITH skkunnr IN gskkunnr
              WITH chkgsb = p_chkgsb " exact match of business area
              WITH osberran = osber[]                       "1722257
              WITH koberran = kober[]                       "1722257
              WITH p_extrep = 'X'                           "2051823
              with p_invo = invo "note 2297987
             AND RETURN.
      CLEAR: gdebet, gkredit, gsberd, gsberk.
    WHEN 'ZEXCEL'.
      IF go_control IS NOT INITIAL.
        PERFORM reopen_document.
        MESSAGE 'Формуляр открыт'(033) TYPE 'S'.
        EXIT.
      ENDIF.
      PERFORM init_doi.
      PERFORM fill_excel.
      MESSAGE 'Выгрузка завершена' TYPE 'S'.
  ENDCASE.
ENDFORM.                    "user_command

*&--------------------------------------------------------------------*
*&      Form  calc_saldo
*&--------------------------------------------------------------------*
*       Balances calculation
*---------------------------------------------------------------------*
FORM calc_saldo.
  DATA: notfound LIKE sy-tabix.

* Balances table
  DATA: BEGIN OF sld OCCURS 0,
          racct LIKE glt0-racct,        " Account number
          rbusa LIKE glt0-rbusa,        " Bussines Sphera
          hslvt LIKE glt0-hslvt,
          hsl01 LIKE glt0-hsl01,
          hsl02 LIKE glt0-hsl02,
          hsl03 LIKE glt0-hsl03,
          hsl04 LIKE glt0-hsl04,
          hsl05 LIKE glt0-hsl05,
          hsl06 LIKE glt0-hsl06,
          hsl07 LIKE glt0-hsl07,
          hsl08 LIKE glt0-hsl08,
          hsl09 LIKE glt0-hsl09,
          hsl10 LIKE glt0-hsl10,
          hsl11 LIKE glt0-hsl11,
          hsl12 LIKE glt0-hsl12,
          hsl13 LIKE glt0-hsl13,
          hsl14 LIKE glt0-hsl14,
          hsl15 LIKE glt0-hsl15,
          hsl16 LIKE glt0-hsl16,
        END   OF sld,
        lt_glt0 LIKE STANDARD TABLE OF glt0 WITH HEADER LINE,
        l_ryear TYPE ryear.
  DATA: LV_RLDNR TYPE FAGL_RLDNR.

  REFRESH sld.
  CLEAR   sld.
  REFRESH ss1.
  CLEAR   ss1.
  CALL FUNCTION 'J3RK_CUSTOMIZING_GET_LEDGER'
    EXPORTING
      iv_bukrs  = bukrs
    IMPORTING
      EV_LEDGER = LV_RLDNR.
* If no turnovers on current account nothing will be selected
  l_ryear = gjahr.
  CALL FUNCTION 'FAGL_GET_GLT0'
    EXPORTING
      i_glt0_rldnr  = '00'
      i_rldnr       = LV_RLDNR
      i_rrcty       = '0'
      i_rvers       = '001'
      i_bukrs       = bukrs
      i_ryear       = l_ryear
      i_racct       = skat-saknr
      i_drcrk       = 'S'
      i_rpmax       = '016'
      i_range_rbusa = osber[]
    IMPORTING
      et_glt0       = lt_glt0[]
    EXCEPTIONS
      OTHERS        = 0.
  LOOP AT lt_glt0.
    CALL FUNCTION 'FI_GSBER_AUTH_CHECK'
      EXPORTING
        i_gsber  = lt_glt0-rbusa
        i_aktvt  = '03'
      IMPORTING
        e_rtcode = rtcode.
    CHECK rtcode = 0.
    MOVE-CORRESPONDING lt_glt0 TO sld.                      "#EC ENHOK
    COLLECT sld.
  ENDLOOP.

  LOOP AT sld.
*  READ TABLE sld INDEX 1.
    ss1-saldo_01 = sld-hslvt.
    ss1-saldo_31 = sld-hslvt.
    CLEAR: ss1-turn_s, ss1-turn_h.
    WHILE sy-index <= monat-high
     VARY saldo FROM sld-hsl01 NEXT sld-hsl02.

      IF sy-index < monat-low.
        ss1-saldo_01 = ss1-saldo_01 + saldo.
        ss1-saldo_31 = ss1-saldo_01.
      ELSE.
        ss1-saldo_31 = ss1-saldo_31 + saldo.
        ss1-turn_s = ss1-turn_s + saldo.
      ENDIF.
    ENDWHILE.
    ss1-saknr = skat-saknr.
    ss1-gsber = sld-rbusa.
    COLLECT ss1.

  ENDLOOP.

* Credit balance addition
  REFRESH sld.
  CLEAR   sld.
  l_ryear = gjahr.
  CALL FUNCTION 'FAGL_GET_GLT0'
    EXPORTING
      i_glt0_rldnr  = '00'
      i_rldnr       = LV_RLDNR
      i_rrcty       = '0'
      i_rvers       = '001'
      i_bukrs       = bukrs
      i_ryear       = l_ryear
      i_racct       = skat-saknr
      i_drcrk       = 'H'
      i_rpmax       = '016'
      i_range_rbusa = osber[]
    IMPORTING
      et_glt0       = lt_glt0[]
    EXCEPTIONS
      OTHERS        = 0.
  LOOP AT lt_glt0.
    CALL FUNCTION 'FI_GSBER_AUTH_CHECK'
      EXPORTING
        i_gsber  = lt_glt0-rbusa
        i_aktvt  = '03'
      IMPORTING
        e_rtcode = rtcode.
    CHECK rtcode = 0.
    MOVE-CORRESPONDING lt_glt0 TO sld.                      "#EC ENHOK
    COLLECT sld.
  ENDLOOP.

  CLEAR notfound.
  LOOP AT sld.
*  READ TABLE sld INDEX 1.
    READ TABLE ss1 WITH KEY saknr = skat-saknr gsber = sld-rbusa.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: ss1, notfound.
    ELSE.
      notfound = sy-tabix.
    ENDIF.
    ss1-saldo_01 = ss1-saldo_01 + sld-hslvt.
    ss1-saldo_31 = ss1-saldo_31 + sld-hslvt.
    WHILE sy-index <= monat-high
     VARY saldo FROM sld-hsl01 NEXT sld-hsl02.
      IF sy-index < monat-low.
        ss1-saldo_01 = ss1-saldo_01 + saldo.
        ss1-saldo_31 = ss1-saldo_31 + saldo.
      ELSE.
        ss1-saldo_31 = ss1-saldo_31 + saldo.
        ss1-turn_h = ss1-turn_h + saldo.
      ENDIF.
    ENDWHILE.
    IF NOT notfound IS INITIAL.
      MODIFY ss1 INDEX notfound.
    ELSE.
      ss1-saknr = skat-saknr.
      ss1-gsber = sld-rbusa.
      COLLECT ss1.

    ENDIF.
  ENDLOOP.
ENDFORM.                    "CALC_SALDO

*---------------------------------------------------------------------*
*       FORM WR_TIT                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM wr_tit.
*  Saving for drill down.
  ghkont = ssg-saknr.
  ghsber = ssg-gsber.
ENDFORM.                    "WR_TIT

*---------------------------------------------------------------------*
*       FORM OD_COLL_ZG                                               *
*---------------------------------------------------------------------*
*       Turnovers summarization
*---------------------------------------------------------------------*
FORM od_coll_zg.
  IF z-budat <= budat-high.       " and z-budat >= budat-low - óæå åñòü
*    IF z-debet = ss-saknr.
    IF z-xnegpd IS INITIAL.
      don_k = don_k + z-dmbtr.
    ELSE.
      kon_k = kon_k - z-dmbtr.
    ENDIF.
    PERFORM coll_zgd.
  ENDIF.

  IF z-budat > budat-high.
*     IF z-debet = ss-saknr.
    IF z-xnegpd IS INITIAL.
      dok_31 = dok_31 + z-dmbtr.
    ELSE.
      kok_31 = kok_31 - z-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    "OD_COLL_ZG

*---------------------------------------------------------------------*
*       FORM COLL_ZGD                                                 *
*---------------------------------------------------------------------*
FORM coll_zgd.

  MOVE-CORRESPONDING z TO zg.                               "#EC ENHOK
  zg-shkzg = 'S'.
  zg-hkont = z-kredit.
  zg-saknr = z-kredit.
  zg-gsber = z-gsberk.
  IF z-xnegpd EQ 'X'.
    zg-shkzg = 'H'.
    zg-dmbtr  = -1 * z-dmbtr.
  ENDIF.

  SELECT SINGLE sakan FROM ska1 INTO zg-hkont WHERE
         ktopl = t001-ktopl AND saknr = zg-hkont.

  IF ugks > 0.
    WRITE '*         ' TO zg-hkont+ugks.
*------------------- Start insert LAB2
    CLEAR zg-saknr.
*------------------- End insert LAB2
  ENDIF.
  CLEAR: zg-dlifnr, zg-dkunnr, zg-klifnr, zg-kkunnr .
* Customer and vendor data (Debit and Credit sides)
  IF gcustven = 'X'.
    IF z-koartd = 'D' OR z-koartd = 'K'.
      PERFORM get_customer_and_vendor USING z-bukrs
                                            z-belnr
                                            z-gjahr
                                            z-buzeid
                                  CHANGING  zg-dlifnr zg-dkunnr.
    ENDIF.
  ENDIF.

  IF gksc = 'X' AND gdat = ' '.
* Summarization by corresponding account
    zg-belnr  = space.
    zg-budat  = space.
    zg-buzeid = space.
    zg-buzeik = space.
    zg-koartd = space.
    zg-koartk = space.
  ENDIF.

  IF gdat = 'X'.
* Summarization by date.
    zg-belnr = space.
    zg-buzeid = space.
    zg-buzeik = space.
    zg-koartd = space.
    zg-koartk = space.
  ENDIF.

  IF gcustven IS INITIAL.                                   "<N1909378>
    zg-kkunnr = space.
    zg-dkunnr = space.
    "<note 2259802>
    zg-klifnr = space.
    zg-dlifnr = space.
    "</note 2259802>
  ENDIF.                  "</N1909378>

  COLLECT zg.
ENDFORM.                    "COLL_ZGD

*---------------------------------------------------------------------*
*       FORM WR_OD                                                    *
*---------------------------------------------------------------------*
FORM wr_od.

  DATA: l_saknr LIKE ska1-saknr.
  xsaldo = ssg-saldo_01 + do01_n - ko01_n.
  dsaldo = 0.
  IF gcustven = 'X'.
    IF gksc = 'X' AND gdat = ' '.
      SORT zg BY shkzg hkont gsber dlifnr dkunnr klifnr kkunnr.
    ENDIF.
    IF gdat = 'X' AND gksc = ' '.
      SORT zg BY budat dlifnr dkunnr klifnr kkunnr.
    ENDIF.
    IF gdat = 'X' AND gksc = 'X'.
      SORT zg BY budat hkont dlifnr dkunnr klifnr kkunnr.
    ENDIF.
    IF gdoc = 'X'.
      SORT zg BY belnr budat hkont dlifnr dkunnr klifnr kkunnr.
    ENDIF.
  ELSE.
    IF gksc = 'X' AND gdat = ' '.
      SORT zg BY shkzg hkont gsber.
    ENDIF.
    IF gdat = 'X' AND gksc = ' '.
      SORT zg BY budat.
    ENDIF.
    IF gdat = 'X' AND gksc = 'X'.
      SORT zg BY budat hkont.
    ENDIF.
    IF gdoc = 'X'.
      SORT zg BY belnr budat hkont.
    ENDIF.
  ENDIF.

  gt_header-debit = ghkont.

  SELECT SINGLE saknr INTO l_saknr FROM ska1            "#EC CI_GENBUFF
                      WHERE sakan = ghkont. "#EC CI_NOORDER "#EC CI_SORTED
  SELECT SINGLE txt20 INTO gt_header-acc_text FROM skat
                      WHERE spras = gv_langu AND
                            ktopl = t001-ktopl AND
                            saknr = l_saknr.
  SELECT SINGLE txt50 INTO gt_header-acc_longtext FROM skat
                      WHERE SPRAS = sy-langu AND
                            KTOPL = t001-ktopl AND
                            SAKNR = l_saknr.
  IF gsbergrp = 'X'.                                        "1722257
    gt_header-gsber = ''.
  ELSE.
    gt_header-gsber = ghsber.
  ENDIF.

  gt_header-text = text-136.
  IF xsaldo > 0.
    gt_header-beg_bal = ABS( xsaldo ).
    gt_header-end_bal = 0.
  ELSE.
    gt_header-beg_bal = 0.
    gt_header-end_bal = ABS( xsaldo ).
  ENDIF.
  CLEAR: gt_header-dummy.
  gt_header-waers = t001-waers.

  COLLECT gt_header.

  gt_item-debit = ghkont.
*  IF gsbergrp = 'X'. "1722257
*    gt_item-gsber = ''.
*  ELSE.
*    gt_item-gsber = ghsber.
*  ENDIF.

  LOOP AT zg WHERE shkzg = 'S'.
    gt_item-credit = zg-hkont.
*    IF gsbergrp = 'X'. "1722257
*      gt_item-gsberk = ''.
*    ELSE.
*      gt_item-gsberk = zg-gsber.
*    ENDIF.

    gt_item-dlifnr = zg-dlifnr.
    gt_item-dkunnr = zg-dkunnr.
    gt_item-klifnr = zg-klifnr.
    gt_item-kkunnr = zg-kkunnr.
    gt_item-budat = zg-budat.
    gt_item-belnr = zg-belnr.
    CLEAR: gt_item-dlname, gt_item-klname, gt_item-dkname, gt_item-kkname.
    IF NOT gt_item-dlifnr IS INITIAL.
      PERFORM fill_vendor_name USING gt_item-dlifnr
                             CHANGING  gt_item-dlname.
    ENDIF.
    IF NOT gt_item-klifnr IS INITIAL.
      PERFORM fill_vendor_name USING gt_item-klifnr
                               CHANGING  gt_item-klname.
    ENDIF.
    IF NOT gt_item-dkunnr IS INITIAL.
      PERFORM fill_customer_name USING gt_item-dkunnr
                             CHANGING  gt_item-dkname.
    ENDIF.
    IF NOT gt_item-kkunnr IS INITIAL.
      PERFORM fill_customer_name USING gt_item-kkunnr
                               CHANGING  gt_item-kkname.
    ENDIF.

    gt_item-beg_bal = zg-dmbtr.
    gt_item-end_bal = 0.
    gt_item-waers = zg-hwaer.
    gkredit = zg-hkont.
    IF gsbergrp = 'X'.                                      "1722257
      gsberk  = ''.
    ELSE.
      gsberk  = zg-gsber.
    ENDIF.

    dsaldo = dsaldo + zg-dmbtr.
    PERFORM wr_prim_d CHANGING gt_item-note1 gt_item-note2.
    CLEAR gt_item-kside.

    COLLECT gt_item.

  ENDLOOP.
ENDFORM.                    "WR_OD

*---------------------------------------------------------------------*
*       FORM WR_PRIM_D                                                *
*---------------------------------------------------------------------*
FORM wr_prim_d CHANGING p_note1 LIKE j_3rkorrrep_alv_item-note1
                        p_note2 LIKE j_3rkorrrep_alv_item-note2.

  DATA:
    nl       TYPE i,
    ok_bsegd TYPE i VALUE 0,
    ok_bsegk TYPE i VALUE 0.
  DATA: LV_RLDNR TYPE FAGL_RLDNR,
        LV_GJAHR TYPE GJAHR,
        LT_BSEG  TYPE FAGL_T_BSEG,
        LV_BELNR TYPE BELNR_D.                              "N2063712

  nl = 0.
  CLEAR: p_note1, p_note2.
  CALL FUNCTION 'J3RK_CUSTOMIZING_GET_LEDGER'
    EXPORTING
      iv_bukrs  = bukrs
    IMPORTING
      EV_LEDGER = LV_RLDNR.
  IF NOT LV_RLDNR IS INITIAL.
    CALL FUNCTION 'J3RK_DOCNR_RYEAR_TO_GJAHR'
      EXPORTING
        iv_belnr  = zg-belnr
        iv_ryear  = gjahr
        iv_bukrs  = bukrs
        iv_rldnr  = LV_RLDNR
      IMPORTING
        EV_GJAHR  = LV_GJAHR
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
* No document found
    ENDIF.
  ENDIF.
  IF LV_GJAHR IS INITIAL.
    LV_GJAHR = gjahr.
  ENDIF.
  IF gksc = 'X' AND nmks = 'X' AND ugks = 0.
    SELECT SINGLE * FROM skat
     WHERE spras =  gv_langu
       AND ktopl = t001-ktopl
       AND saknr = zg-saknr.

    IF sy-subrc = 0 AND NOT skat-txt50 IS INITIAL.
      p_note1 = skat-txt50.
    ENDIF.
  ENDIF.

  IF gdoc = 'X'.
    IF tpos = 'X'.
      IF LV_RLDNR IS INITIAL.
        SELECT SINGLE * FROM bseg
         WHERE bukrs = bukrs
           AND belnr = zg-belnr
           AND gjahr = gjahr
           AND buzei = zg-buzeid.
      ELSE.
        CALL FUNCTION 'FAGL_GET_GL_DOCUMENT_BY_DOCNR'     "N2063712
          EXPORTING
            i_rldnr   = LV_RLDNR
            i_bukrs   = bukrs
            i_docnr   = zg-belnr
            i_ryear   = gjahr
          IMPORTING
            ET_BSEG   = LT_BSEG
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF sy-subrc EQ 0.
          READ TABLE LT_BSEG INTO BSEG INDEX 1.
        ENDIF.
      ENDIF.
      IF sy-subrc = 0.
        ok_bsegd = 1.
        IF NOT bseg-sgtxt IS INITIAL.
          CONCATENATE  'TPOS' bseg-sgtxt INTO p_note1
                        SEPARATED BY space.
          nl      = 1.
        ENDIF.
      ELSE.
        ok_bsegd = -1.
      ENDIF.
    ENDIF.

    IF pros = 'X'.
      IF ok_bsegd = 0.
        IF LV_RLDNR IS INITIAL.
          SELECT SINGLE * FROM bseg
           WHERE bukrs = bukrs
             AND belnr = zg-belnr
             AND gjahr = gjahr
             AND buzei = zg-buzeid.
        ELSE.
          REFRESH LT_BSEG.
          CALL FUNCTION 'FAGL_GET_GL_DOCUMENT_BY_DOCNR'     "N2063712
            EXPORTING
              i_rldnr   = LV_RLDNR
              i_bukrs   = bukrs
              i_docnr   = zg-belnr
              i_ryear   = gjahr
            IMPORTING
              ET_BSEG   = LT_BSEG
            EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
          IF sy-subrc EQ 0.
            READ TABLE LT_BSEG INTO BSEG INDEX 1.
          ENDIF.
        ENDIF.
        IF sy-subrc = 0.
          ok_bsegd = 1.
        ELSE.
          ok_bsegd = -1.
        ENDIF.
      ENDIF.
      IF ok_bsegd = 1.
        IF NOT bseg-zuonr IS INITIAL.
          IF nl > 0 .
            CONCATENATE  'PROS' bseg-zuonr INTO p_note2
                                SEPARATED BY space.
          ELSE.
            CONCATENATE  'PROS' bseg-zuonr INTO p_note1
                                SEPARATED BY space.
            nl = 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF dkos = 'X'.
      IF ok_bsegd = 0.
        IF LV_RLDNR IS INITIAL.
          SELECT SINGLE * FROM bseg
           WHERE bukrs = bukrs
             AND belnr = zg-belnr
             AND gjahr = gjahr
             AND buzei = zg-buzeid.
        ELSE.
          REFRESH LT_BSEG.
          CALL FUNCTION 'FAGL_GET_GL_DOCUMENT_BY_DOCNR'     "N2063712
            EXPORTING
              i_rldnr   = LV_RLDNR
              i_bukrs   = bukrs
              i_docnr   = zg-belnr
              i_ryear   = gjahr
            IMPORTING
              ET_BSEG   = LT_BSEG
            EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
          IF sy-subrc EQ 0.
            READ TABLE LT_BSEG INTO BSEG INDEX 1.
          ENDIF.
        ENDIF.
        IF sy-subrc = 0.
          ok_bsegd = 1.
        ELSE.
          ok_bsegd = -1.
        ENDIF.
      ENDIF.
      IF ok_bsegd = 1.
        IF NOT bseg-lifnr IS INITIAL.
          SELECT SINGLE * FROM lfa1
           WHERE lifnr = bseg-lifnr.
          IF sy-subrc = 0.
            IF cl_iav_mapping_util=>is_iav_active( ) EQ abap_true.  "IAV
              CALL METHOD cl_iav_mapping_util=>get_address_as_lfa1
                EXPORTING
                  iv_adrnr                 = lfa1-adrnr
                  iv_application_component = 'FI_AP'
                CHANGING
                  cs_lfa1                  = lfa1.
            endif.
            IF  NOT lfa1-lifnr IS INITIAL
             OR NOT lfa1-name1 IS INITIAL.
              IF nl > 0 .
                CONCATENATE  'DKOS' lfa1-lifnr lfa1-name1 INTO p_note2
                                    SEPARATED BY space.
              ELSE.
                CONCATENATE  'DKOS' lfa1-lifnr lfa1-name1 INTO p_note1
                                    SEPARATED BY space.
                nl = 1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        IF NOT bseg-kunnr IS INITIAL.
          SELECT SINGLE * FROM kna1
           WHERE kunnr = bseg-kunnr.
          IF sy-subrc = 0.
            IF cl_iav_mapping_util=>is_iav_active( ) EQ abap_true.  "IAV
              CALL METHOD cl_iav_mapping_util=>get_address_as_kna1
                EXPORTING
                  iv_adrnr                 = kna1-adrnr
                  iv_application_component = 'FI_AR'
                CHANGING
                  cs_kna1                  = kna1.
            endif.
            IF  NOT kna1-kunnr IS INITIAL
             OR NOT kna1-name1 IS INITIAL.
              IF nl > 0 .
                CONCATENATE  'DKOS' kna1-kunnr kna1-name1 INTO p_note2
                                    SEPARATED BY space.
              ELSE.
                CONCATENATE  'DKOS' kna1-kunnr kna1-name1 INTO p_note1 "N2063712
                                    SEPARATED BY space.
                nl = 1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF tpks = 'X'.
      IF LV_RLDNR IS INITIAL.
        SELECT SINGLE * FROM bseg
         WHERE bukrs = bukrs
           AND belnr = zg-belnr
           AND gjahr = gjahr
           AND buzei = zg-buzeik.
      ELSE.
        REFRESH LT_BSEG.
        CALL FUNCTION 'FAGL_GET_GL_DOCUMENT_BY_DOCNR'     "N2063712
          EXPORTING
            i_rldnr   = LV_RLDNR
            i_bukrs   = bukrs
            i_docnr   = zg-belnr
            i_ryear   = gjahr
          IMPORTING
            ET_BSEG   = LT_BSEG
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF sy-subrc EQ 0.
          READ TABLE LT_BSEG INTO BSEG INDEX 1.
        ENDIF.
      ENDIF.
      IF sy-subrc = 0.
        ok_bsegk = 1.
        IF NOT bseg-sgtxt IS INITIAL.
          IF nl > 0 .
            CONCATENATE  'TRKS' bseg-sgtxt INTO p_note2
                                SEPARATED BY space.
          ELSE.
            CONCATENATE  'TRKS' bseg-sgtxt INTO p_note1
                                SEPARATED BY space.
            nl = 1.
          ENDIF.
        ENDIF.
      ELSE.
        ok_bsegk = -1.
      ENDIF.
    ENDIF.

    IF prks = 'X'.
      IF ok_bsegk = 0.
        IF LV_RLDNR IS INITIAL.
          SELECT SINGLE * FROM bseg
           WHERE bukrs = bukrs
             AND belnr = zg-belnr
             AND gjahr = gjahr
             AND buzei = zg-buzeik.
        ELSE.
          REFRESH LT_BSEG.
          CALL FUNCTION 'FAGL_GET_GL_DOCUMENT_BY_DOCNR'     "N2063712
            EXPORTING
              i_rldnr   = LV_RLDNR
              i_bukrs   = bukrs
              i_docnr   = zg-belnr
              i_ryear   = gjahr
            IMPORTING
              ET_BSEG   = LT_BSEG
            EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
          IF sy-subrc EQ 0.
            READ TABLE LT_BSEG INTO BSEG INDEX 1.
          ENDIF.
        ENDIF.
        IF sy-subrc = 0.
          ok_bsegk = 1.
        ELSE.
          ok_bsegk = -1.
        ENDIF.
      ENDIF.
      IF ok_bsegk = 1.
        IF NOT bseg-zuonr IS INITIAL.
          IF nl > 0 .
            CONCATENATE  'PRKS' bseg-zuonr INTO p_note2
                                SEPARATED BY space.
          ELSE.
            CONCATENATE  'PRKS' bseg-zuonr INTO p_note1
                                SEPARATED BY space.
            nl = 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF dkks = 'X'.
      IF ok_bsegk = 0.
        IF LV_RLDNR IS INITIAL.
          SELECT SINGLE * FROM bseg
           WHERE bukrs = bukrs
             AND belnr = zg-belnr
             AND gjahr = gjahr
             AND buzei = zg-buzeik.
        ELSE.
          REFRESH LT_BSEG.
          CALL FUNCTION 'FAGL_GET_GL_DOCUMENT_BY_DOCNR'     "N2063712
            EXPORTING
              i_rldnr   = LV_RLDNR
              i_bukrs   = bukrs
              i_docnr   = zg-belnr
              i_ryear   = gjahr
            IMPORTING
              ET_BSEG   = LT_BSEG
            EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
          IF sy-subrc EQ 0.
            READ TABLE LT_BSEG INTO BSEG INDEX 1.
          ENDIF.
        ENDIF.
        IF sy-subrc = 0.
          ok_bsegk = 1.
        ELSE.
          ok_bsegk = -1.
        ENDIF.
      ENDIF.
      IF ok_bsegk = 1.
        IF NOT bseg-kunnr IS INITIAL.
          SELECT SINGLE * FROM kna1
           WHERE kunnr = bseg-kunnr.
          IF sy-subrc = 0.
            IF cl_iav_mapping_util=>is_iav_active( ) EQ abap_true.  "IAV
              CALL METHOD cl_iav_mapping_util=>get_address_as_kna1
                EXPORTING
                  iv_adrnr                 = kna1-adrnr
                  iv_application_component = 'FI_AR'
                CHANGING
                  cs_kna1                  = kna1.
            endif.
            IF  NOT kna1-kunnr IS INITIAL
             OR NOT kna1-name1 IS INITIAL.
              IF nl > 0 .
                CONCATENATE  'DKKS' kna1-kunnr kna1-name1 INTO p_note2
                                    SEPARATED BY space.
              ELSE.
                CONCATENATE  'DKKS' kna1-kunnr kna1-name1 INTO p_note1 "N2063712
                                    SEPARATED BY space.
                nl = 1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF NOT bseg-lifnr IS INITIAL.
          SELECT SINGLE * FROM lfa1
           WHERE lifnr = bseg-lifnr.
          IF sy-subrc = 0.
            IF cl_iav_mapping_util=>is_iav_active( ) EQ abap_true.  "IAV
              CALL METHOD cl_iav_mapping_util=>get_address_as_lfa1
                EXPORTING
                  iv_adrnr                 = lfa1-adrnr
                  iv_application_component = 'FI_AP'
                CHANGING
                  cs_lfa1                  = lfa1.
            endif.
            IF  NOT lfa1-lifnr IS INITIAL
             OR NOT lfa1-name1 IS INITIAL.
              IF nl > 0 .
                CONCATENATE  'DKKS' lfa1-lifnr lfa1-name1 INTO p_note2
                                    SEPARATED BY space.
              ELSE.
                CONCATENATE  'DKKS' lfa1-lifnr lfa1-name1 INTO p_note1
                                    SEPARATED BY space.
                nl = 1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF zdoc = 'X'.
      lv_belnr = zg-belnr.                                  "<N2063712>
      if lv_rldnr is not initial.
        call function 'FAGL_GET_BELNR_FROM_DOCNR'
          exporting
            i_rldnr   = lv_rldnr
            i_bukrs   = bukrs
            i_docnr   = zg-belnr
            i_ryear   = lv_gjahr
          importing
            e_belnr   = lv_belnr
          exceptions
            not_found = 1.
      endif.                            "</N2063712>

      SELECT SINGLE * FROM bkpf
       WHERE bukrs = bukrs
         AND belnr = lv_belnr                               "N2063712
         AND gjahr = lv_gjahr.

      IF sy-subrc = 0 AND NOT bkpf-bktxt IS INITIAL.
        IF nl > 0 .
          CONCATENATE  'ZDOC' bkpf-bktxt INTO p_note2
                              SEPARATED BY space.
        ELSE.
          CONCATENATE  'ZDOC' bkpf-bktxt INTO p_note1
                              SEPARATED BY space.
          nl = 1.
        ENDIF.
      ENDIF.
    ENDIF.

    IF nmks = 'X'.
      SELECT SINGLE * FROM skat                             "N2063712
       WHERE spras =  gv_langu
         AND ktopl = t001-ktopl
         AND saknr = zg-saknr.

      IF sy-subrc = 0 AND NOT skat-txt50 IS INITIAL.
        IF nl > 0 .
          CONCATENATE  'NMKS' skat-txt50 INTO p_note2
                              SEPARATED BY space.
        ELSE.
          CONCATENATE  'NMKS' skat-txt50 INTO p_note1
                              SEPARATED BY space.
          nl = 1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "WR_PRIM_D

*---------------------------------------------------------------------*
*       FORM OK_COLL_ZG                                               *
*---------------------------------------------------------------------*
*       Summarization                                                 *
*---------------------------------------------------------------------*
FORM ok_coll_zg.
  IF  z-budat <= budat-high.           " and z-budat >= budat-low
*     IF z-kredit = ss-saknr.
    IF z-xnegpk IS INITIAL.
      kon_k = kon_k + z-dmbtr.
    ELSE.
      don_k = don_k - z-dmbtr.
    ENDIF.
    PERFORM coll_zgk.
  ENDIF.

  IF z-budat > budat-high.
*     IF z-kredit = ss-saknr.
    IF z-xnegpk IS INITIAL.
      kok_31 = kok_31 + z-dmbtr.
    ELSE.
      dok_31 = dok_31 - z-dmbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    "OK_COLL_ZG

*---------------------------------------------------------------------*
*       FORM COLL_ZGK                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM coll_zgk.
* Z-KREDIT = ÎÑ÷, èçìåíÿåòñÿ Z-DEBET = ÊÑ÷.

  MOVE-CORRESPONDING z TO zg.                               "#EC ENHOK
  zg-shkzg = 'H'.
  zg-hkont = z-debet.
  zg-saknr = z-debet.
  zg-gsber = z-gsberd.
*   IF z-kredit NE ss-saknr.
  IF NOT z-xnegpk IS INITIAL.
    zg-shkzg = 'S'.
    zg-dmbtr  = -1 * z-dmbtr.
  ENDIF.
  SELECT SINGLE sakan FROM ska1 INTO zg-hkont WHERE
         ktopl = t001-ktopl AND saknr = zg-hkont.
  IF ugks > 0.
    WRITE '*         ' TO zg-hkont+ugks.
*------------------- Start insert LAB2
    CLEAR zg-saknr.
*------------------- End insert LAB2
  ENDIF.
  CLEAR: zg-dlifnr, zg-dkunnr, zg-klifnr, zg-kkunnr .
  IF z-koartk = 'D' OR z-koartk = 'K'.
    PERFORM get_customer_and_vendor USING z-bukrs
                                          z-belnr
                                          z-gjahr
                                          z-buzeik
                                CHANGING  zg-klifnr zg-kkunnr.
  ENDIF.
  IF gksc = 'X' AND gdat = ' '.
* grouping of correspondence account
    zg-belnr = space.
    zg-budat = space.
    zg-buzeid = space.
    zg-buzeik = space.
    zg-koartd = space.
    zg-koartk = space.
  ENDIF.

  IF gdat = 'X'.
* grouping of post date
    zg-belnr = space.
    zg-buzeid = space.
    zg-buzeik = space.
    zg-koartd = space.
    zg-koartk = space.
  ENDIF.

  IF gcustven IS INITIAL.                                   "<N1909378>
    zg-kkunnr = space.
    zg-dkunnr = space.
    "<note 2259802>
    zg-klifnr = space.
    zg-dlifnr = space.
    "</note 2259802>
  ENDIF.                  "</N1909378>

  COLLECT zg.
ENDFORM.                    "COLL_ZGK

*---------------------------------------------------------------------*
*       FORM WR_OK                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM wr_ok.
  ksaldo = 0.
  xsaldo = ssg-saldo_01 + do01_n - ko01_n.

*  gt_header-debit = ghkont.
*  gt_header-gsber = ghsber.
*  gt_header-text = text-136.
*  gt_header-beg_bal = ABS( xsaldo ).
*  CLEAR gt_header-end_bal.
*  gt_header-waers = t001-waers.
*  APPEND gt_header.

  gt_item-debit = ghkont.
*    IF gsbergrp = 'X'. "1722257
*    gt_item-gsber = ''.
*  ELSE.
*    gt_item-gsber = ghsber.
*  ENDIF.

  LOOP AT zg WHERE shkzg = 'H'.
    gt_item-credit = zg-hkont.
*    IF gsbergrp = 'X'. "1722257
*      gt_item-gsberk = ''.
*    ELSE.
*      gt_item-gsberk = zg-gsber.
*    ENDIF.

    gt_item-dlifnr = zg-dlifnr.
    gt_item-dkunnr = zg-dkunnr.
    gt_item-klifnr = zg-klifnr.
    gt_item-kkunnr = zg-kkunnr.
    gt_item-budat = zg-budat.
    gt_item-belnr = zg-belnr.
    CLEAR: gt_item-dlname, gt_item-klname, gt_item-dkname, gt_item-kkname.
    IF NOT gt_item-dlifnr IS INITIAL.
      PERFORM fill_vendor_name USING gt_item-dlifnr
                             CHANGING  gt_item-dlname.
    ENDIF.
    IF NOT gt_item-klifnr IS INITIAL.
      PERFORM fill_vendor_name USING gt_item-klifnr
                               CHANGING  gt_item-klname.
    ENDIF.
    IF NOT gt_item-dkunnr IS INITIAL.
      PERFORM fill_customer_name USING gt_item-dkunnr
                             CHANGING  gt_item-dkname.
    ENDIF.
    IF NOT gt_item-kkunnr IS INITIAL.
      PERFORM fill_customer_name USING gt_item-kkunnr
                               CHANGING  gt_item-kkname.
    ENDIF.
    gt_item-beg_bal = 0.
    gt_item-end_bal = zg-dmbtr.
    gt_item-waers = zg-hwaer.
*    gt_item-
    gkredit = zg-hkont.
    IF gsbergrp = 'X'. "
      gsberk  = ''.
    ELSE.
      gsberk  = zg-gsber.
    ENDIF.

    ksaldo = ksaldo + zg-dmbtr.
    PERFORM wr_prim_d CHANGING gt_item-note1 gt_item-note2.
    gt_item-kside = 'X'.

    COLLECT gt_item.

  ENDLOOP.

ENDFORM.                    "WR_OK


*---------------------------------------------------------------------*
*       FORM WR_ODK_SALDO                                             *
*---------------------------------------------------------------------*
* Printout of total and outgoing balances
*---------------------------------------------------------------------*
FORM wr_odk_saldo.
*  DATA delta LIKE xsaldo.

* Outgoing balance
  gt_header-text = text-146.
  gt_header-beg_bal = dsaldo.
  gt_header-end_bal = ksaldo.
  gt_header-dummy = 1.

  COLLECT gt_header.
  xsaldo = ssg-saldo_01 + do01_n - ko01_n + dsaldo - ksaldo.
  gt_header-debit = ghkont.
  IF gsbergrp = 'X'.                                        "1722257
    gt_header-gsber = ''.
  ELSE.
    gt_header-gsber = ghsber.
  ENDIF.

  gt_header-text = text-144.
  IF xsaldo > 0.
    gt_header-beg_bal = ABS( xsaldo ).
    gt_header-end_bal = 0.
  ELSE.
    gt_header-beg_bal = 0.
    gt_header-end_bal = ABS( xsaldo ).
  ENDIF.

  xsaldo = ssg-saldo_01 + do01_n - ko01_n
         + don_k - kon_k + dok_31 - kok_31.
  gt_header-dummy = 2.

  COLLECT gt_header.
ENDFORM.                    "WR_ODK_SALDO

*---------------------------------------------------------------------*
*       FORM PROV_PERIOD                                              *
*---------------------------------------------------------------------*
*    Period validation
*---------------------------------------------------------------------*
FORM prov_period.
  DATA: l_gjahr_low  LIKE bkpf-gjahr,
        l_poper_low  TYPE poper,
        l_gjahr_high LIKE bkpf-gjahr,
        l_poper_high TYPE poper.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = budat-low
      i_bukrs        = bukrs
      i_rldnr        = GV_RLDNR
    IMPORTING
      e_gjahr        = l_gjahr_low
      e_monat        = begmn
      e_poper        = l_poper_low
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = budat-high
      i_bukrs        = bukrs
      i_rldnr        = GV_RLDNR
    IMPORTING
      e_gjahr        = l_gjahr_high
      e_monat        = endmn
      e_poper        = l_poper_high
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL FUNCTION 'FIRST_DAY_IN_PERIOD_GET'
    EXPORTING
      i_gjahr        = l_gjahr_low
      i_periv        = gv_periv
      i_poper        = l_poper_low
    IMPORTING
      e_date         = begdat
    EXCEPTIONS
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
    EXPORTING
      i_gjahr        = l_gjahr_high
      i_periv        = gv_periv
      i_poper        = l_poper_high
    IMPORTING
      e_date         = enddat
    EXCEPTIONS
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF budat-low = begdt AND budat-high = enddt.
    period = 1.
    IF monat-low = begmn AND monat-high = endmn.
      period = 2.
    ENDIF.
  ENDIF.
ENDFORM.                    "PROV_PERIOD
********************************************************************
FORM write_header.
  data: t_header  type slis_t_listheader,
        wa_header type slis_listheader.
  wa_header-typ = 'H'.

  CONCATENATE 'Анализ счета' '' INTO wa_header-info SEPARATED BY space.
*  IF OSNSC-HIGH IS NOT INITIAL.
*    CONCATENATE 'Анализ счета:' OSNSC-LOW '-' OSNSC-HIGH INTO wa_header-info SEPARATED BY space.
*  ELSE.
*    CONCATENATE 'Анализ счета:' OSNSC-LOW INTO wa_header-info SEPARATED BY space.
*  ENDIF.                                                    "#EC CALLED
  append wa_header to t_header.

  clear: wa_header.
  wa_header-typ = 'S'.
  CONCATENATE 'За период с:'  monat-low 'по' monat-high INTO wa_header-info SEPARATED BY space.
  append wa_header to t_header.
  clear: wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
ENDFORM.                    "WRITE_HEADER

*---------------------------------------------------------------------*
*       FORM EVENTTAB_BUILD                                           *
*---------------------------------------------------------------------*
*       Adds TOP_OF_PAGE event processing to evens list               *
*---------------------------------------------------------------------*
*  -->  E03_LT_EVENTS  - events list                                  *
*---------------------------------------------------------------------*
FORM eventtab_build CHANGING pt_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
* Get full list of events
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = pt_events.
  READ TABLE pt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'WRITE_HEADER' TO ls_event-form.
    APPEND ls_event TO pt_events.
  ENDIF.

  READ TABLE pt_events WITH KEY name = slis_ev_pf_status_set
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'SET_STATUS' TO ls_event-form.
    APPEND ls_event TO pt_events.
  ENDIF.


  READ TABLE pt_events WITH KEY name = slis_ev_user_command
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'USER_COMMAND' TO ls_event-form.
    APPEND ls_event TO pt_events.
  ENDIF.


ENDFORM.                    "eventtab_build

FORM set_status USING extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD_FULLSCREEN2'.
  REFRESH extab[].
ENDFORM.                    "SET_STATUS
*---------------------------------------------------------------------*
*       FORM CALC_ALT_SALDO                                           *
*---------------------------------------------------------------------*
*       Calculate balance for alternative account                     *
*---------------------------------------------------------------------*
FORM calc_alt_saldo.
  DATA: l_saknr LIKE skat-saknr,
        l_ss1   LIKE ss1 OCCURS 0 WITH HEADER LINE.
  l_saknr = skat-saknr.
  SELECT saknr INTO skat-saknr FROM skb1              "#EC CI_SGLSELECT
               WHERE bukrs = bukrs AND                  "#EC CI_GENBUFF
                     altkt = l_saknr.
    CLEAR ss1[].
    PERFORM calc_saldo.
    LOOP AT ss1.
      l_ss1 = ss1.
      COLLECT l_ss1.
    ENDLOOP.
  ENDSELECT.
  skat-saknr = l_saknr.
  ss1[] = l_ss1[].
ENDFORM.                    "CALC_ALT_SALDO

INCLUDE ZFIJ_3RKORRREP_FORMS.
