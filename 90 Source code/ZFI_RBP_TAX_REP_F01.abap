*&---------------------------------------------------------------------*
*& Include          ZFI_RBP_TAX_REP_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
****************надо бы переписать этот кусок
  n = 0. lv_j = so_budat-low+0(4). lv_i = so_budat-low+4(2).
  DO 13 TIMES.
    n = n + 1.
    IF lv_i = 13.
      lv_i = 1.
      lv_j = lv_j + 1.
    ENDIF.
    IF lv_i < 10.
      i = '0' && lv_i.
    ELSE.
      i = lv_i.
    ENDIF.
    lv_per = lv_j && i.
    lv_i = lv_i + 1.
    CASE n.
      WHEN 1. m1 = lv_per.
      WHEN 2. m2 = lv_per.
      WHEN 3. m3 = lv_per.
      WHEN 4. m4 = lv_per.
      WHEN 5. m5 = lv_per.
      WHEN 6. m6 = lv_per.
      WHEN 7. m7 = lv_per.
      WHEN 8. m8 = lv_per.
      WHEN 9. m9 = lv_per.
      WHEN 10. m10 = lv_per.
      WHEN 11. m11 = lv_per.
      WHEN 12. m12 = lv_per.
      WHEN 13. m13 = lv_per.
      WHEN OTHERS.
    ENDCASE.
  ENDDO.
*******************
  SELECT *
    FROM ACAC_OBJECTS as a INNER JOIN ACEOBJ as b
    on a~REF_KEY eq b~REF_KEY
    INNER JOIN ACEDSOI as c
    on b~OBJID eq c~OBJID
    INNER JOIN ACEDSOH as d
    on d~OBJID eq c~OBJID
    INTO CORRESPONDING FIELDS OF TABLE it_rep
    WHERE a~ACAC_OBJTYPE in so_objt
      AND a~ACAC_OBJNUMBER in so_numb
      AND a~BUKRS = p_bukrs
      AND b~OBJSTATUS = 'P'
      AND b~BUKRS = p_bukrs
      AND c~DATE_TO = '99991231'
      AND d~DATE_TO = '99991231'.
*    AND d~VALITY_FROM = ( select max( VALITY_FROM )
*      FROM ACEDSOH
*      WHERE OBJID = b~OBJID
*      AND VALITY_FROM <= so_budat-high ).

  DELETE it_rep WHERE VALITY_FROM >= so_budat-high.
  DELETE it_rep WHERE VALITY_TO <= so_budat-low.

**********************************************************************
*Выберем все док-ты ACE в диапазоне дат
  TYPES: BEGIN OF tt_ace_rw,
           belnr   TYPE bkpf-belnr,
           OBJID   TYPE ACEDSOI-OBJID,
           ACCRULE TYPE ACEDSOI-ACCRULE,
           TSL     TYPE acdoca-tsl,
           POPER   TYPE acdoca-POPER,
           gjahr   TYPE acdoca-gjahr,
         END OF tt_ace_rw.
  DATA: lt_ace_rw TYPE STANDARD TABLE OF tt_ace_rw.


  SELECT *
    FROM ACDOCA as a
    INNER JOIN bkpf as b
    on a~rbukrs eq b~bukrs
      AND a~belnr eq b~belnr
      AND a~gjahr eq b~gjahr
    INNER JOIN ACEPSOIT as c
    ON b~AWKEY eq c~awkey
    INTO CORRESPONDING FIELDS OF TABLE lt_ace_rw
    WHERE a~rbukrs = p_bukrs
      AND a~AWTYP = 'ACE'
      AND a~budat in so_budat
      AND c~TRANSTYPE = 'P'
      AND a~racct in so_racct.


  FIELD-SYMBOLS: <fs_rep> like line of it_rep.
  LOOP AT it_rep ASSIGNING <fs_rep> WHERE ACCRULE <> 'ВР'.
***
* Доп: МВЗ
    SELECT SINGLE COSTCENTER
      FROM ACEDSASSGMT
      INTO <fs_rep>-KOSTL
      WHERE COMP = 'ACAC'
        AND BUKRS = p_bukrs
        AND OBJID = <fs_rep>-OBJID
        AND DATE_TO = '99991231'.
    IF <fs_rep>-KOSTL is NOT INITIAL.
      SELECT SINGLE LTEXT
        FROM CSKT
        INTO <fs_rep>-LTEXT
        WHERE SPRAS = sy-langu
          AND KOKRS = '1000'
          AND KOSTL = <fs_rep>-KOSTL
          AND DATBI = '99991231'.
    ENDIF.


***
    FIELD-SYMBOLS <ace> like LINE OF lt_ace_rw.
    LOOP AT lt_ace_rw ASSIGNING <ace> WHERE OBJID = <fs_rep>-objid AND ACCRULE = <fs_rep>-ACCRULE.
      DATA: lv_pop(6).
      lv_pop = <ace>-gjahr && <ace>-POPER+1(2).
      CASE lv_pop.
        WHEN m1. <fs_rep>-HSL01 = <fs_rep>-HSL01 + <ace>-tsl.
        WHEN m2. <fs_rep>-HSL02 = <fs_rep>-HSL02 + <ace>-tsl.
        WHEN m3. <fs_rep>-HSL03 = <fs_rep>-HSL03 + <ace>-tsl.
        WHEN m4. <fs_rep>-HSL04 = <fs_rep>-HSL04 + <ace>-tsl.
        WHEN m5. <fs_rep>-HSL05 = <fs_rep>-HSL05 + <ace>-tsl.
        WHEN m6. <fs_rep>-HSL06 = <fs_rep>-HSL06 + <ace>-tsl.
        WHEN m7. <fs_rep>-HSL07 = <fs_rep>-HSL07 + <ace>-tsl.
        WHEN m8. <fs_rep>-HSL08 = <fs_rep>-HSL08 + <ace>-tsl.
        WHEN m9. <fs_rep>-HSL09 = <fs_rep>-HSL09 + <ace>-tsl.
        WHEN m10. <fs_rep>-HSL10 = <fs_rep>-HSL10 + <ace>-tsl.
        WHEN m11. <fs_rep>-HSL11 = <fs_rep>-HSL11 + <ace>-tsl.
        WHEN m12. <fs_rep>-HSL12 = <fs_rep>-HSL12 + <ace>-tsl.
        WHEN m13. <fs_rep>-HSL13 = <fs_rep>-HSL13 + <ace>-tsl.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
    SELECT SINGLE CONTENT
      FROM ACEDSOP
      INTO <fs_rep>-content
      WHERE BUKRS = p_bukrs
        AND OBJID = <fs_rep>-OBJID
        AND DATE_TO = '99991231'
        AND PARAM_NAME = 'ZZOBJNO'.
    FIELD-SYMBOLS: <fs_vr> like LINE OF it_rep.
    READ TABLE it_rep ASSIGNING <fs_vr> WITH KEY content = <fs_rep>-content ACCRULE = 'ВР'.
    IF <fs_vr> IS ASSIGNED.
      IF <fs_rep>-ACCRULE = 'RAS'.
        <fs_vr>-AMOUNT = <fs_vr>-AMOUNT + <fs_rep>-AMOUNT .
        <fs_vr>-HSL01 = <fs_vr>-HSL01 + <fs_rep>-HSL01 .
        <fs_vr>-HSL02 = <fs_vr>-HSL02 + <fs_rep>-HSL02 .
        <fs_vr>-HSL03 = <fs_vr>-HSL03 + <fs_rep>-HSL03 .
        <fs_vr>-HSL04 = <fs_vr>-HSL04 + <fs_rep>-HSL04 .
        <fs_vr>-HSL05 = <fs_vr>-HSL05 + <fs_rep>-HSL05 .
        <fs_vr>-HSL06 = <fs_vr>-HSL06 + <fs_rep>-HSL06 .
        <fs_vr>-HSL07 = <fs_vr>-HSL07 + <fs_rep>-HSL07 .
        <fs_vr>-HSL08 = <fs_vr>-HSL08 + <fs_rep>-HSL08 .
        <fs_vr>-HSL09 = <fs_vr>-HSL09 + <fs_rep>-HSL09 .
        <fs_vr>-HSL10 = <fs_vr>-HSL10 + <fs_rep>-HSL10 .
        <fs_vr>-HSL11 = <fs_vr>-HSL11 + <fs_rep>-HSL11 .
        <fs_vr>-HSL12 = <fs_vr>-HSL12 + <fs_rep>-HSL12 .
        <fs_vr>-HSL13 = <fs_vr>-HSL13 + <fs_rep>-HSL13 .
      ELSEIF <fs_rep>-ACCRULE = 'PTA'.
        <fs_vr>-AMOUNT = <fs_vr>-AMOUNT - <fs_rep>-AMOUNT .
        <fs_vr>-HSL01 = <fs_vr>-HSL01 - <fs_rep>-HSL01 .
        <fs_vr>-HSL02 = <fs_vr>-HSL02 - <fs_rep>-HSL02 .
        <fs_vr>-HSL03 = <fs_vr>-HSL03 - <fs_rep>-HSL03 .
        <fs_vr>-HSL04 = <fs_vr>-HSL04 - <fs_rep>-HSL04 .
        <fs_vr>-HSL05 = <fs_vr>-HSL05 - <fs_rep>-HSL05 .
        <fs_vr>-HSL06 = <fs_vr>-HSL06 - <fs_rep>-HSL06 .
        <fs_vr>-HSL07 = <fs_vr>-HSL07 - <fs_rep>-HSL07 .
        <fs_vr>-HSL08 = <fs_vr>-HSL08 - <fs_rep>-HSL08 .
        <fs_vr>-HSL09 = <fs_vr>-HSL09 - <fs_rep>-HSL09 .
        <fs_vr>-HSL10 = <fs_vr>-HSL10 - <fs_rep>-HSL10 .
        <fs_vr>-HSL11 = <fs_vr>-HSL11 - <fs_rep>-HSL11 .
        <fs_vr>-HSL12 = <fs_vr>-HSL12 - <fs_rep>-HSL12 .
        <fs_vr>-HSL13 = <fs_vr>-HSL13 - <fs_rep>-HSL13 .
      ENDIF.
      UNASSIGN <fs_vr>.
    ELSE.
      DATA: ls_vr LIKE LINE OF it_rep.
      MOVE-CORRESPONDING <fs_rep> TO ls_vr.
      CLEAR:
        ls_vr-ACAC_OBJTYPE,
        ls_vr-ACAC_OBJNUMBER,
        ls_vr-OBJID,
        ls_vr-TEXT,
        ls_vr-VALITY_FROM,
        ls_vr-VALITY_TO.
      ls_vr-ACCRULE = 'ВР'.
      IF <fs_rep>-ACCRULE = 'PTA'.
        ls_vr-AMOUNT =  - <fs_rep>-AMOUNT .
        ls_vr-HSL01 =  - <fs_rep>-HSL01 .
        ls_vr-HSL02 =  - <fs_rep>-HSL02 .
        ls_vr-HSL03 =  - <fs_rep>-HSL03 .
        ls_vr-HSL04 =  - <fs_rep>-HSL04 .
        ls_vr-HSL05 =  - <fs_rep>-HSL05 .
        ls_vr-HSL06 =  - <fs_rep>-HSL06 .
        ls_vr-HSL07 =  - <fs_rep>-HSL07 .
        ls_vr-HSL08 =  - <fs_rep>-HSL08 .
        ls_vr-HSL09 =  - <fs_rep>-HSL09 .
        ls_vr-HSL10 =  - <fs_rep>-HSL10 .
        ls_vr-HSL11 =  - <fs_rep>-HSL11 .
        ls_vr-HSL12 =  - <fs_rep>-HSL12 .
        ls_vr-HSL13 =  - <fs_rep>-HSL13 .
      ENdif.
      APPEND ls_vr TO it_rep.
      CLEAR: ls_vr.
    ENDIF.
  ENDLOOP.

  IF p_empt = 'X'.
    DELETE it_rep WHERE CONTENT is INITIAL.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SHOW_ALV .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZFI_RBP_TAX'
    CHANGING
      CT_FIELDCAT            = fcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
  ENDIF.
  FIELD-SYMBOLS: <fs_fcat> like LINE OF fcat.
  LOOP AT fcat ASSIGNING <fs_fcat>.
    CASE <fs_fcat>-FIELDNAME.
      WHEN 'HSL01'.
        <fs_fcat>-COLTEXT = m1+4(2) && '.' && m1+0(4).
      WHEN 'HSL02'.
        <fs_fcat>-COLTEXT = m2+4(2) && '.' && m2+0(4).
      WHEN 'HSL03'.
        <fs_fcat>-COLTEXT = m3+4(2) && '.' && m3+0(4).
      WHEN 'HSL04'.
        <fs_fcat>-COLTEXT = m4+4(2) && '.' && m4+0(4).
      WHEN 'HSL05'.
        <fs_fcat>-COLTEXT = m5+4(2) && '.' && m5+0(4).
      WHEN 'HSL06'.
        <fs_fcat>-COLTEXT = m6+4(2) && '.' && m6+0(4).
      WHEN 'HSL07'.
        <fs_fcat>-COLTEXT = m7+4(2) && '.' && m7+0(4).
      WHEN 'HSL08'.
        <fs_fcat>-COLTEXT = m8+4(2) && '.' && m8+0(4).
      WHEN 'HSL09'.
        <fs_fcat>-COLTEXT = m9+4(2) && '.' && m9+0(4).
      WHEN 'HSL10'.
        <fs_fcat>-COLTEXT = m10+4(2) && '.' && m10+0(4).
      WHEN 'HSL11'.
        <fs_fcat>-COLTEXT = m11+4(2) && '.' && m11+0(4).
      WHEN 'HSL12'.
        <fs_fcat>-COLTEXT = m12+4(2) && '.' && m12+0(4).
      WHEN 'HSL13'.
        <fs_fcat>-COLTEXT = m13+4(2) && '.' && m13+0(4).
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.


  gs_layout_fm-cwidth_opt = 'X'.
  gs_layout_fm-zebra = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc            = gs_layout_fm
      I_CALLBACK_PROGRAM       = sy-cprog
      I_CALLBACK_PF_STATUS_SET = 'SETPF'
      I_CALLBACK_USER_COMMAND  = 'UCOMM'
      I_GRID_SETTINGS          = glay
      IT_FIELDCAT_LVC          = fcat
    TABLES
      T_OUTTAB                 = it_rep
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.



FORM SETPF USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.


FORM UCOMM USING r_ucomm LIKE sy-ucomm
     rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&IC1'.
      DATA: ls_rep LIKE LINE OF it_rep.
      READ TABLE it_rep INTO ls_rep INDEX rs_selfield-tabindex.
      CALL FUNCTION 'ACE_DISPLAY_SINGLE_ACE_OBJECT'
        EXPORTING
          ID_COMP    = 'ACAC'
          ID_BUKRS   = p_bukrs
          ID_OBJID   = ls_rep-objid
          ID_SUBID   = '00001'
          ID_KEYDATE = sy-datum
*         ID_MODE    = '03'
*         ID_DISPLAY_TREE        =
*         ID_TREE_VARIANT        =
*       EXCEPTIONS
*         NOT_FOUND  = 1
*         NO_AUTHORIZATION       = 2
*         ERROR_OCCURRED         = 3
*         OTHERS     = 4
        .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
    WHEN 'EXCEL'.
      PERFORM crea_xls.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREA_XLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREA_XLS .
*****Сформируем итоговую таблицу
****  FIELD-SYMBOLS: <fs_all> like LINE OF it_rep,
****                 <fs_tot> like LINE OF it_rep.
****  DATA: ls_tot LIKE LINE OF it_rep.
****  DATA: it_tot TYPE STANDARD TABLE OF ZFI_RBP_TAX.
****  LOOP AT it_rep ASSIGNING <fs_all>.
****    READ TABLE it_tot ASSIGNING <fs_tot> WITH KEY
****      content = <fs_all>-content ACCRULE = <fs_all>-ACCRULE.
****    IF <fs_tot> is ASSIGNED.
****        <fs_tot>-AMOUNT = <fs_tot>-AMOUNT + <fs_all>-AMOUNT .
****        <fs_tot>-HSL01 = <fs_tot>-HSL01 + <fs_all>-HSL01 .
****        <fs_tot>-HSL02 = <fs_tot>-HSL02 + <fs_all>-HSL02 .
****        <fs_tot>-HSL03 = <fs_tot>-HSL03 + <fs_all>-HSL03 .
****        <fs_tot>-HSL04 = <fs_tot>-HSL04 + <fs_all>-HSL04 .
****        <fs_tot>-HSL05 = <fs_tot>-HSL05 + <fs_all>-HSL05 .
****        <fs_tot>-HSL06 = <fs_tot>-HSL06 + <fs_all>-HSL06 .
****        <fs_tot>-HSL07 = <fs_tot>-HSL07 + <fs_all>-HSL07 .
****        <fs_tot>-HSL08 = <fs_tot>-HSL08 + <fs_all>-HSL08 .
****        <fs_tot>-HSL09 = <fs_tot>-HSL09 + <fs_all>-HSL09 .
****        <fs_tot>-HSL10 = <fs_tot>-HSL10 + <fs_all>-HSL10 .
****        <fs_tot>-HSL11 = <fs_tot>-HSL11 + <fs_all>-HSL11 .
****        <fs_tot>-HSL12 = <fs_tot>-HSL12 + <fs_all>-HSL12 .
****        <fs_tot>-HSL13 = <fs_tot>-HSL13 + <fs_all>-HSL13 .
****      UNASSIGN <fs_tot>.
****    ELSE.
****      MOVE-CORRESPONDING <fs_all> TO ls_tot.
****      append ls_tot TO it_tot.
****      CLEAR ls_tot.
****    ENDIF.
****  ENDLOOP.
  DATA: lt_contr TYPE STANDARD TABLE OF ZFI_RBP_TAX,
        tmp      TYPE i.
*Перевернем знак у списаний на затраты
  FIELD-SYMBOLS: <fs_neg_rep> like LINE OF it_rep.
  LOOP AT it_rep ASSIGNING <fs_neg_rep>.
    <fs_neg_rep>-HSL01 =  -1 * <fs_neg_rep>-HSL01.
    <fs_neg_rep>-HSL02 =  -1 * <fs_neg_rep>-HSL02.
    <fs_neg_rep>-HSL03 =  -1 * <fs_neg_rep>-HSL03.
    <fs_neg_rep>-HSL04 =  -1 * <fs_neg_rep>-HSL04.
    <fs_neg_rep>-HSL05 =  -1 * <fs_neg_rep>-HSL05.
    <fs_neg_rep>-HSL06 =  -1 * <fs_neg_rep>-HSL06.
    <fs_neg_rep>-HSL07 =  -1 * <fs_neg_rep>-HSL07.
    <fs_neg_rep>-HSL08 =  -1 * <fs_neg_rep>-HSL08.
    <fs_neg_rep>-HSL09 =  -1 * <fs_neg_rep>-HSL09.
    <fs_neg_rep>-HSL10 =  -1 * <fs_neg_rep>-HSL10.
    <fs_neg_rep>-HSL11 =  -1 * <fs_neg_rep>-HSL11.
    <fs_neg_rep>-HSL12 =  -1 * <fs_neg_rep>-HSL12.
    <fs_neg_rep>-HSL13 =  -1 * <fs_neg_rep>-HSL13.
  ENDLOOP.


  DATA: lv_am_lines TYPE i.
  CLEAR lv_am_lines.

  lt_contr[] = it_rep[].
  SORT lt_contr by content.
  DELETE ADJACENT DUPLICATES FROM lt_contr COMPARING content.
  SORT it_rep by content ACCRULE VALITY_FROM.
**********************************************************************
*Открываем файл
  IF go_control IS NOT INITIAL.
    PERFORM reopen_document.
    MESSAGE 'Формуляр открыт' TYPE 'S'.
    EXIT.
  ENDIF.
  PERFORM init_doi.
**********************************************************************
*Цикл по каждому объекту (один объект - один лист в экселе)
  DATA: ls_cont LIKE LINE OF lt_contr.
  DATA: sh_no TYPE i.
  sh_no = 0.
  LOOP AT lt_contr INTO ls_cont.
    sh_no = sh_no + 1.
**********************************************************************
*Создаем новый лист
    IF GO_SPREADSHEET IS INITIAL.
      MESSAGE 'Ошибка открытия Excel' TYPE 'S'.
      EXIT.
    ENDIF.
    IF sy-tabix = 1.
      CALL METHOD GO_SPREADSHEET->SET_SHEET_NAME
        EXPORTING
          NEWNAME  = ls_cont-content+0(25)
*         OLDNAME  = ''
          NO_FLUSH = ' '
*  IMPORTING
*         ERROR    =
*         RETCODE  =
        .
    ELSE.
      CALL METHOD GO_SPREADSHEET->ADD_SHEET
        EXPORTING
          NAME = ls_cont-content.
    ENDIF.
    TYPES: BEGIN OF tt_thead
             , t1(200)
      , END OF tt_thead.
    DATA: lt_thead TYPE STANDARD TABLE OF tt_thead WITH HEADER LINE.

    CLEAR lt_thead[].
    lt_thead-t1 = 'Регистр учета расходов по страхованию'.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = 'Налогоплательщик: Общество с ограниченной ответственностью "Аэроэкспресс"'.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = 'Идентификационный номер налогоплательщика: 5047066172 / 504701001'.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = ''.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = 'Период:' && so_budat-low+4(2) && '.' && so_budat-low+0(4)
      && ' - ' && so_budat-high+4(2) && '.' && so_budat-high+0(4).
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = ''.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = 'НАИМЕНОВАНИЕ РБП: ' && ls_cont-content.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = ''.
    APPEND lt_thead. CLEAR lt_thead.

    CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = 10
      #2 = 1.
    CALL METHOD OF cell1 'Font' = font.
    SET PROPERTY OF font 'Bold' = 1.
    SET PROPERTY OF font 'Size' = 14.

    DATA: h_r(6), b_r(6), n_r(6), v_r(6), f_r(6), b_rh(6), n_rh(6), v_rh(6).
    h_r = 'head' && sy-tabix.
    b_r = 'ras' && sy-tabix.
    b_rh = 'rash' && sy-tabix.
    n_r = 'pta' && sy-tabix.
    n_rh = 'ptah' && sy-tabix.
    v_r = 'vr' && sy-tabix.
    v_rh = 'vrh' && sy-tabix.
    f_r = 'foot' && sy-tabix.

    DATA: bu_r TYPE i, nu_r TYPE i, vr_r TYPE i, ft_r TYPE i.



*создаем заголовок
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = h_r
        left     = 1
        top      = 4
        rows     = 8
        columns  = 1
        updating = 0.
    CALL METHOD go_spreadsheet->set_font
      EXPORTING
        rangename = h_r
        family    = ''
        size      = 11
        bold      = -1
        italic    = -1
        align     = -1
        no_flush  = ' '.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = h_r
        typ       = 0
        currency  = ''
        no_flush  = ' '.



    DATA lt_fields_table TYPE soi_fields_table.
    CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
      TABLES
        data   = lt_thead[]
        fields = lt_fields_table[].
    "вставляем заголовок
    CALL METHOD go_spreadsheet->insert_one_table
      EXPORTING
        data_table   = lt_thead[]
        fields_table = lt_fields_table[]
        rangename    = h_r
        wholetable   = ' '
        no_flush     = ' '.
    CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = 4
      #2 = 1.
    CALL METHOD OF cell1 'Font' = font.
    SET PROPERTY OF font 'Bold' = 1.
    SET PROPERTY OF font 'Size' = 16.


    lv_am_lines = 16.

**********************************************************************
    FIELD-SYMBOLS <fs_prep> like LINE OF it_rep.
*БУ
    bu_r = 14.
    TYPES: BEGIN OF tt_tab
      , t1(200)
      , t2(25)
      , t3(200)
      , t4(200)
      , t5(20)
      , t6(20)
      , t7(20)
      , t8(20)
      , t9(20)
      , t10(20)
      , t11(20)
      , t12(20)
      , t13(20)
      , t14(20)
      , t15(20)
      , t16(20)
      , t17(20)
      , t18(20)
      , END OF tt_tab.


    DATA: s   TYPE acdoca-hsl,
          s1  TYPE acdoca-hsl,
          s2  TYPE acdoca-hsl,
          s3  TYPE acdoca-hsl,
          s4  TYPE acdoca-hsl,
          s5  TYPE acdoca-hsl,
          s6  TYPE acdoca-hsl,
          s7  TYPE acdoca-hsl,
          s8  TYPE acdoca-hsl,
          s9  TYPE acdoca-hsl,
          s10 TYPE acdoca-hsl,
          s11 TYPE acdoca-hsl,
          s12 TYPE acdoca-hsl,
          s13 TYPE acdoca-hsl.
    CLEAR: s, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13.



    DATA: bu_tab  TYPE STANDARD TABLE OF tt_tab,
          bu_line LIKE LINE OF bu_tab.
    CLEAR: bu_line, bu_tab[].
    bu_line-t1 = '№ объекта'.
    bu_line-t2 = 'Общаяя сумма'.
    bu_line-t3 = 'Действует с'.
    bu_line-t4 = 'Действует по'.
    bu_line-t5 = 'Дней'.
    bu_line-t6 =  m1+4(2) && '.' && m1+0(4).
    bu_line-t7 =  m2+4(2) && '.' && m2+0(4).
    bu_line-t8 =  m3+4(2) && '.' && m3+0(4).
    bu_line-t9 =  m4+4(2) && '.' && m4+0(4).
    bu_line-t10 =  m5+4(2) && '.' && m5+0(4).
    bu_line-t11 =  m6+4(2) && '.' && m6+0(4).
    bu_line-t12 =  m7+4(2) && '.' && m7+0(4).
    bu_line-t13 =  m8+4(2) && '.' && m8+0(4).
    bu_line-t14 =  m9+4(2) && '.' && m9+0(4).
    bu_line-t15 =  m10+4(2) && '.' && m10+0(4).
    bu_line-t16 =  m11+4(2) && '.' && m11+0(4).
    bu_line-t17 =  m12+4(2) && '.' && m12+0(4).
    bu_line-t18 =  m13+4(2) && '.' && m13+0(4).
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
    bu_line-t1 = 'Кол-во дней в периоде'.
    bu_line-t2 = ''.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    PERFORM get_days USING '19000101' '99991231' m1 CHANGING bu_line-t6.
    PERFORM get_days USING '19000101' '99991231' m2 CHANGING bu_line-t7.
    PERFORM get_days USING '19000101' '99991231' m3 CHANGING bu_line-t8.
    PERFORM get_days USING '19000101' '99991231' m4 CHANGING bu_line-t9.
    PERFORM get_days USING '19000101' '99991231' m5 CHANGING bu_line-t10.
    PERFORM get_days USING '19000101' '99991231' m6 CHANGING bu_line-t11.
    PERFORM get_days USING '19000101' '99991231' m7 CHANGING bu_line-t12.
    PERFORM get_days USING '19000101' '99991231' m8 CHANGING bu_line-t13.
    PERFORM get_days USING '19000101' '99991231' m9 CHANGING bu_line-t14.
    PERFORM get_days USING '19000101' '99991231' m10 CHANGING bu_line-t15.
    PERFORM get_days USING '19000101' '99991231' m11 CHANGING bu_line-t16.
    PERFORM get_days USING '19000101' '99991231' m12 CHANGING bu_line-t17.
    PERFORM get_days USING '19000101' '99991231' m13 CHANGING bu_line-t18.
    APPEND bu_line TO bu_tab.
    LOOP AT it_rep ASSIGNING <fs_prep> WHERE content = ls_cont-content AND ACCRULE = 'RAS'.
      s = s + <fs_prep>-AMOUNT.
      s1 = s1 + <fs_prep>-HSL01.
      s2 = s2 + <fs_prep>-HSL02.
      s3 = s3 + <fs_prep>-HSL03.
      s4 = s4 + <fs_prep>-HSL04.
      s5 = s5 + <fs_prep>-HSL05.
      s6 = s6 + <fs_prep>-HSL06.
      s7 = s7 + <fs_prep>-HSL07.
      s8 = s8 + <fs_prep>-HSL08.
      s9 = s9 + <fs_prep>-HSL09.
      s10 = s10 + <fs_prep>-HSL10.
      s11 = s11 + <fs_prep>-HSL11.
      s12 = s12 + <fs_prep>-HSL12.
      s13 = s13 + <fs_prep>-HSL13.
      bu_line-t1 = 'Кол-во дней действия'.
      bu_line-t2 = ''.
      bu_line-t3 = ''.
      bu_line-t4 = ''.
      bu_line-t5 = ''.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m1 CHANGING bu_line-t6.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m2 CHANGING bu_line-t7.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m3 CHANGING bu_line-t8.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m4 CHANGING bu_line-t9.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m5 CHANGING bu_line-t10.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m6 CHANGING bu_line-t11.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m7 CHANGING bu_line-t12.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m8 CHANGING bu_line-t13.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m9 CHANGING bu_line-t14.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m10 CHANGING bu_line-t15.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m11 CHANGING bu_line-t16.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m12 CHANGING bu_line-t17.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m13 CHANGING bu_line-t18.
      APPEND bu_line TO bu_tab.
      CLEAR bu_line.
      lv_am_lines = lv_am_lines + 1.
      bu_line-t1 = <fs_prep>-ACAC_OBJNUMBER.
*      bu_line-t2 = <fs_prep>-AMOUNT.
      IF <fs_prep>-AMOUNT < 0.
        <fs_prep>-AMOUNT = abs( <fs_prep>-AMOUNT ).
        bu_line-t2 = '-' && <fs_prep>-AMOUNT.
      ELSE.
        bu_line-t2 = <fs_prep>-AMOUNT.
      ENDIF.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          DATE_INTERNAL            = <fs_prep>-VALITY_FROM
        IMPORTING
          DATE_EXTERNAL            = bu_line-t3
        EXCEPTIONS
          DATE_INTERNAL_IS_INVALID = 1
          OTHERS                   = 2.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          DATE_INTERNAL            = <fs_prep>-VALITY_TO
        IMPORTING
          DATE_EXTERNAL            = bu_line-t4
        EXCEPTIONS
          DATE_INTERNAL_IS_INVALID = 1
          OTHERS                   = 2.
      bu_line-t5 =  <fs_prep>-VALITY_TO - <fs_prep>-VALITY_FROM + 1.
      IF <fs_prep>-HSL01 < 0.
        <fs_prep>-HSL01 = abs( <fs_prep>-HSL01 ).
        bu_line-t6 = '-' && <fs_prep>-HSL01.
      ELSE.
        bu_line-t6 = <fs_prep>-HSL01.
      ENDIF.
      IF <fs_prep>-HSL02 < 0.
        <fs_prep>-HSL02 = abs( <fs_prep>-HSL02 ).
        bu_line-t7 = '-' && <fs_prep>-HSL02 .
      ELSE.
        bu_line-t7 = <fs_prep>-HSL02.
      ENDIF.
      IF <fs_prep>-HSL03 < 0.
        <fs_prep>-HSL03 = abs( <fs_prep>-HSL03 ).
        bu_line-t8 = '-' && <fs_prep>-HSL03 .
      ELSE.
        bu_line-t8 = <fs_prep>-HSL03.
      ENDIF.
      IF <fs_prep>-HSL04 < 0.
        <fs_prep>-HSL04 = abs( <fs_prep>-HSL04 ).
        bu_line-t9 = '-' && <fs_prep>-HSL04 .
      ELSE.
        bu_line-t9 = <fs_prep>-HSL04.
      ENDIF.
      IF <fs_prep>-HSL05 < 0.
        <fs_prep>-HSL05 = abs( <fs_prep>-HSL05 ).
        bu_line-t10 = '-' && <fs_prep>-HSL05 .
      ELSE.
        bu_line-t10 = <fs_prep>-HSL05.
      ENDIF.
      IF <fs_prep>-HSL06 < 0.
        <fs_prep>-HSL06 = abs( <fs_prep>-HSL06 ).
        bu_line-t11 = '-' && <fs_prep>-HSL06 .
      ELSE.
        bu_line-t11 = <fs_prep>-HSL06.
      ENDIF.
      IF <fs_prep>-HSL07 < 0.
        <fs_prep>-HSL07 = abs( <fs_prep>-HSL07 ).
        bu_line-t12 = '-' &&  <fs_prep>-HSL07 .
      ELSE.
        bu_line-t12 = <fs_prep>-HSL07.
      ENDIF.
      IF <fs_prep>-HSL08 < 0.
        <fs_prep>-HSL08 = abs( <fs_prep>-HSL08 ).
        bu_line-t13 = '-' &&  <fs_prep>-HSL08 .
      ELSE.
        bu_line-t13 = <fs_prep>-HSL08.
      ENDIF.
      IF <fs_prep>-HSL09 < 0.
        <fs_prep>-HSL09 = abs( <fs_prep>-HSL09 ).
        bu_line-t14 = '-' &&  <fs_prep>-HSL09 .
      ELSE.
        bu_line-t14 = <fs_prep>-HSL09.
      ENDIF.
      IF <fs_prep>-HSL10 < 0.
        <fs_prep>-HSL10 = abs( <fs_prep>-HSL10 ).
        bu_line-t15 = '-' &&  <fs_prep>-HSL10 .
      ELSE.
        bu_line-t15 = <fs_prep>-HSL10.
      ENDIF.
      IF <fs_prep>-HSL11 < 0.
        <fs_prep>-HSL11 = abs( <fs_prep>-HSL11 ).
        bu_line-t16 = '-' &&  <fs_prep>-HSL11 .
      ELSE.
        bu_line-t16 = <fs_prep>-HSL11.
      ENDIF.
      IF <fs_prep>-HSL12 < 0.
        <fs_prep>-HSL12 = abs( <fs_prep>-HSL12 ).
        bu_line-t17 = '-' && <fs_prep>-HSL12 .
      ELSE.
        bu_line-t17 = <fs_prep>-HSL12.
      ENDIF.
      IF <fs_prep>-HSL13 < 0.
        <fs_prep>-HSL13 = abs( <fs_prep>-HSL13 ).
        bu_line-t18 = '-' && <fs_prep>-HSL13 .
      ELSE.
        bu_line-t18 = <fs_prep>-HSL13.
      ENDIF.
**********************************************************************
      CALL METHOD go_spreadsheet->insert_range_dim
        EXPORTING
          no_flush = ' '
          name     = 'amount'
          left     = 6
          top      = lv_am_lines
          rows     = 1
          columns  = 13
          updating = 0.
      CALL METHOD go_spreadsheet->set_format
        EXPORTING
          rangename = 'amount'
          typ       = 1
          currency  = ''
          decimals  = 2
          no_flush  = ' '.
      CALL METHOD go_spreadsheet->insert_range_dim
        EXPORTING
          no_flush = ' '
          name     = 'amount2'
          left     = 2
          top      = lv_am_lines
          rows     = 1
          columns  = 1
          updating = 0.
      CALL METHOD go_spreadsheet->set_format
        EXPORTING
          rangename = 'amount2'
          typ       = 1
          currency  = ''
          decimals  = 2
          no_flush  = ' '.
      lv_am_lines = lv_am_lines + 1.
**********************************************************************
      APPEND bu_line TO bu_tab.
      CLEAR bu_line.
    ENDLOOP.
    bu_line-t1 = 'Итого'.
    bu_line-t2 = s.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    bu_line-t6 =  s1.
    bu_line-t7 =  s2.
    bu_line-t8 =  s3.
    bu_line-t9 =  s4.
    bu_line-t10 =  s5.
    bu_line-t11 =  s6.
    bu_line-t12 =  s7.
    bu_line-t13 =  s8.
    bu_line-t14 =  s9.
    bu_line-t15 =  s10.
    bu_line-t16 =  s11.
    bu_line-t17 =  s12.
    bu_line-t18 =  s13.
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
**********************************************************************
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount'
        left     = 6
        top      = lv_am_lines
        rows     = 1
        columns  = 13
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount2'
        left     = 2
        top      = lv_am_lines
        rows     = 1
        columns  = 1
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount2'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    lv_am_lines = lv_am_lines + 1.
**********************************************************************
    bu_line-t1 = 'Итого НИт'.
    bu_line-t2 = s.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    bu_line-t6 =  s1.
    IF s2 = 0.
      bu_line-t7 = 0.
    ELSE.
      bu_line-t7 =  s1 + s2.
    ENDIF.
    IF s3 = 0.
      bu_line-t8 = 0.
    ELSE.
      bu_line-t8 =  s1 + s2 + s3.
    ENDIF.
    IF s4 = 0.
      bu_line-t9 = 0.
    ELSE.
      bu_line-t9 =  s1 + s2 + s3 + s4.
    ENDIF.
    IF s5 = 0.
      bu_line-t10 = 0.
    ELSE.
      bu_line-t10 =  s1 + s2 + s3 + s4 + s5.
    ENDIF.
    IF s6 = 0.
      bu_line-t11 = 0.
    ELSE.
      bu_line-t11 =  s1 + s2 + s3 + s4 + s5 + s6.
    ENDIF.
    IF s7 = 0.
      bu_line-t12 = 0.
    ELSE.
      bu_line-t12 =  s1 + s2 + s3 + s4 + s5 + s6 + s7.
    ENDIF.
    IF s8 = 0.
      bu_line-t13 = 0.
    ELSE.
      bu_line-t13 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8.
    ENDIF.
    IF s9 = 0.
      bu_line-t14 = 0.
    ELSE.
      bu_line-t14 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9.
    ENDIF.
    IF s10 = 0.
      bu_line-t15 = 0.
    ELSE.
      bu_line-t15 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10.
    ENDIF.
    IF s11 = 0.
      bu_line-t16 = 0.
    ELSE.
      bu_line-t16 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11.
    ENDIF.
    IF s12 = 0.
      bu_line-t17 = 0.
    ELSE.
      bu_line-t17 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12.
    ENDIF.
    IF s13 = 0.
      bu_line-t18 = 0.
    ELSE.
      bu_line-t18 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12 + s13.
    ENDIF.

    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
**********************************************************************
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount'
        left     = 6
        top      = lv_am_lines
        rows     = 1
        columns  = 13
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount2'
        left     = 2
        top      = lv_am_lines
        rows     = 1
        columns  = 1
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount2'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    lv_am_lines = lv_am_lines + 1.
**********************************************************************

    DESCRIBE TABLE bu_tab LINES nu_r.
    CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
      TABLES
        data   = bu_tab[]
        fields = lt_fields_table[].
    "вставляем БУ
    tmp = bu_r - 1.
    CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = tmp
      #2 = 1.
    SET PROPERTY OF cell1 'Value' = 'Бухгалтерский учет'.
    CALL METHOD OF cell1 'Font' = font.
*      SET PROPERTY OF font 'ColorIndex' = 3.
    SET PROPERTY OF font 'Bold' = 1.
    SET PROPERTY OF font 'Size' = 18.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = b_r
        left     = 1
        top      = bu_r
        rows     = nu_r
        columns  = 18
        updating = 0.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = b_rh
        left     = 1
        top      = bu_r
        rows     = 1
        columns  = 18
        updating = 0.



    FIELD-SYMBOLS <tab> like LINE OF bu_tab .
    LOOP AT bu_tab ASSIGNING <tab> WHERE t1 ne '№ объекта'.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t2 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t6 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t7 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t8 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t9 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t10 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t11 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t12 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t13 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t14 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t15 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t16 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t17 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t18 WITH ','.
    ENDLOOP.

    CALL METHOD go_spreadsheet->insert_one_table
      EXPORTING
        data_table   = bu_tab[]
        fields_table = lt_fields_table[]
        rangename    = b_r
        wholetable   = ' '
        no_flush     = ' '.
    tmp = bu_r + 1.
    PERFORM width USING 1 15.
    PERFORM width USING 2 14.
    PERFORM width USING 3 11.
    PERFORM width USING 4 11.
    PERFORM width USING 5 7.
    PERFORM width USING 6 11.
    PERFORM width USING 7 11.
    PERFORM width USING 8 11.
    PERFORM width USING 9 11.
    PERFORM width USING 10 11.
    PERFORM width USING 11 11.
    PERFORM width USING 12 11.
    PERFORM width USING 13 11.
    PERFORM width USING 14 11.
    PERFORM width USING 15 11.
    PERFORM width USING 16 11.
    PERFORM width USING 17 11.
    PERFORM width USING 18 11.
    PERFORM merge USING tmp 1 tmp 4.
    tmp = bu_r + 2.
    PERFORM merge USING tmp 1 tmp 4.

    "рамка у таблицы
    DATA l_typ TYPE i.
    l_typ = 191.                                            " 10111111
    CALL METHOD go_spreadsheet->set_frame
      EXPORTING
        rangename = b_r
        typ       = l_typ
        color     = 1.


    " выравнивание по центру у шапки таблицы
    CALL METHOD go_spreadsheet->set_font
      EXPORTING
        rangename = b_rh
        family    = ''
        size      = -1
        bold      = 1
        italic    = -1
        align     = 1
        no_flush  = 'X'.


**********************************************************************
*НУ
    lv_am_lines = bu_r + nu_r + 4.
    CLEAR: s, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13.
    CLEAR: bu_line, bu_tab[].
    bu_line-t1 = '№ объекта'.
    bu_line-t2 = 'Общаяя сумма'.
    bu_line-t3 = 'Действует с'.
    bu_line-t4 = 'Действует по'.
    bu_line-t5 = 'Дней'.
    bu_line-t6 =  m1+4(2) && '.' && m1+0(4).
    bu_line-t7 =  m2+4(2) && '.' && m2+0(4).
    bu_line-t8 =  m3+4(2) && '.' && m3+0(4).
    bu_line-t9 =  m4+4(2) && '.' && m4+0(4).
    bu_line-t10 =  m5+4(2) && '.' && m5+0(4).
    bu_line-t11 =  m6+4(2) && '.' && m6+0(4).
    bu_line-t12 =  m7+4(2) && '.' && m7+0(4).
    bu_line-t13 =  m8+4(2) && '.' && m8+0(4).
    bu_line-t14 =  m9+4(2) && '.' && m9+0(4).
    bu_line-t15 =  m10+4(2) && '.' && m10+0(4).
    bu_line-t16 =  m11+4(2) && '.' && m11+0(4).
    bu_line-t17 =  m12+4(2) && '.' && m12+0(4).
    bu_line-t18 =  m13+4(2) && '.' && m13+0(4).
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
    bu_line-t1 = 'Кол-во дней в периоде'.
    bu_line-t2 = ''.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    PERFORM get_days USING '19000101' '99991231' m1 CHANGING bu_line-t6.
    PERFORM get_days USING '19000101' '99991231' m2 CHANGING bu_line-t7.
    PERFORM get_days USING '19000101' '99991231' m3 CHANGING bu_line-t8.
    PERFORM get_days USING '19000101' '99991231' m4 CHANGING bu_line-t9.
    PERFORM get_days USING '19000101' '99991231' m5 CHANGING bu_line-t10.
    PERFORM get_days USING '19000101' '99991231' m6 CHANGING bu_line-t11.
    PERFORM get_days USING '19000101' '99991231' m7 CHANGING bu_line-t12.
    PERFORM get_days USING '19000101' '99991231' m8 CHANGING bu_line-t13.
    PERFORM get_days USING '19000101' '99991231' m9 CHANGING bu_line-t14.
    PERFORM get_days USING '19000101' '99991231' m10 CHANGING bu_line-t15.
    PERFORM get_days USING '19000101' '99991231' m11 CHANGING bu_line-t16.
    PERFORM get_days USING '19000101' '99991231' m12 CHANGING bu_line-t17.
    PERFORM get_days USING '19000101' '99991231' m13 CHANGING bu_line-t18.
    APPEND bu_line TO bu_tab.
    LOOP AT it_rep ASSIGNING <fs_prep> WHERE content = ls_cont-content AND ACCRULE = 'PTA'.
      s = s + <fs_prep>-AMOUNT.
      s1 = s1 + <fs_prep>-HSL01.
      s2 = s2 + <fs_prep>-HSL02.
      s3 = s3 + <fs_prep>-HSL03.
      s4 = s4 + <fs_prep>-HSL04.
      s5 = s5 + <fs_prep>-HSL05.
      s6 = s6 + <fs_prep>-HSL06.
      s7 = s7 + <fs_prep>-HSL07.
      s8 = s8 + <fs_prep>-HSL08.
      s9 = s9 + <fs_prep>-HSL09.
      s10 = s10 + <fs_prep>-HSL10.
      s11 = s11 + <fs_prep>-HSL11.
      s12 = s12 + <fs_prep>-HSL12.
      s13 = s13 + <fs_prep>-HSL13.
      bu_line-t1 = 'Кол-во дней действия'.
      bu_line-t2 = ''.
      bu_line-t3 = ''.
      bu_line-t4 = ''.
      bu_line-t5 = ''.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m1 CHANGING bu_line-t6.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m2 CHANGING bu_line-t7.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m3 CHANGING bu_line-t8.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m4 CHANGING bu_line-t9.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m5 CHANGING bu_line-t10.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m6 CHANGING bu_line-t11.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m7 CHANGING bu_line-t12.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m8 CHANGING bu_line-t13.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m9 CHANGING bu_line-t14.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m10 CHANGING bu_line-t15.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m11 CHANGING bu_line-t16.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m12 CHANGING bu_line-t17.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m13 CHANGING bu_line-t18.
      APPEND bu_line TO bu_tab.
      CLEAR bu_line.
      lv_am_lines = lv_am_lines + 1.
      bu_line-t1 = <fs_prep>-ACAC_OBJNUMBER.
*      bu_line-t2 = <fs_prep>-AMOUNT.
      IF <fs_prep>-AMOUNT < 0.
        <fs_prep>-amount = abs( <fs_prep>-AMOUNT ).
        bu_line-t2 = '-' && <fs_prep>-AMOUNT.
      ELSE.
        bu_line-t2 = <fs_prep>-AMOUNT.
      ENDIF.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          DATE_INTERNAL            = <fs_prep>-VALITY_FROM
        IMPORTING
          DATE_EXTERNAL            = bu_line-t3
        EXCEPTIONS
          DATE_INTERNAL_IS_INVALID = 1
          OTHERS                   = 2.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          DATE_INTERNAL            = <fs_prep>-VALITY_TO
        IMPORTING
          DATE_EXTERNAL            = bu_line-t4
        EXCEPTIONS
          DATE_INTERNAL_IS_INVALID = 1
          OTHERS                   = 2.
      bu_line-t5 =  <fs_prep>-VALITY_TO - <fs_prep>-VALITY_FROM + 1.
      IF <fs_prep>-HSL01 < 0.
        <fs_prep>-HSL01 = abs( <fs_prep>-HSL01 ).
        bu_line-t6 = '-' && <fs_prep>-HSL01.
      ELSE.
        bu_line-t6 = <fs_prep>-HSL01.
      ENDIF.
      IF <fs_prep>-HSL02 < 0.
        <fs_prep>-HSL02 = abs( <fs_prep>-HSL02 ).
        bu_line-t7 = '-' && <fs_prep>-HSL02 .
      ELSE.
        bu_line-t7 = <fs_prep>-HSL02.
      ENDIF.
      IF <fs_prep>-HSL03 < 0.
        <fs_prep>-HSL03 = abs( <fs_prep>-HSL03 ).
        bu_line-t8 = '-' && <fs_prep>-HSL03 .
      ELSE.
        bu_line-t8 = <fs_prep>-HSL03.
      ENDIF.
      IF <fs_prep>-HSL04 < 0.
        <fs_prep>-HSL04 = abs( <fs_prep>-HSL04 ).
        bu_line-t9 = '-' && <fs_prep>-HSL04 .
      ELSE.
        bu_line-t9 = <fs_prep>-HSL04.
      ENDIF.
      IF <fs_prep>-HSL05 < 0.
        <fs_prep>-HSL05 = abs( <fs_prep>-HSL05 ).
        bu_line-t10 = '-' && <fs_prep>-HSL05 .
      ELSE.
        bu_line-t10 = <fs_prep>-HSL05.
      ENDIF.
      IF <fs_prep>-HSL06 < 0.
        <fs_prep>-HSL06 = abs( <fs_prep>-HSL06 ).
        bu_line-t11 = '-' && <fs_prep>-HSL06 .
      ELSE.
        bu_line-t11 = <fs_prep>-HSL06.
      ENDIF.
      IF <fs_prep>-HSL07 < 0.
        <fs_prep>-HSL07 = abs( <fs_prep>-HSL07 ).
        bu_line-t12 = '-' &&  <fs_prep>-HSL07 .
      ELSE.
        bu_line-t12 = <fs_prep>-HSL07.
      ENDIF.
      IF <fs_prep>-HSL08 < 0.
        <fs_prep>-HSL08 = abs( <fs_prep>-HSL08 ).
        bu_line-t13 = '-' &&  <fs_prep>-HSL08 .
      ELSE.
        bu_line-t13 = <fs_prep>-HSL08.
      ENDIF.
      IF <fs_prep>-HSL09 < 0.
        <fs_prep>-HSL09 = abs( <fs_prep>-HSL09 ).
        bu_line-t14 = '-' &&  <fs_prep>-HSL09 .
      ELSE.
        bu_line-t14 = <fs_prep>-HSL09.
      ENDIF.
      IF <fs_prep>-HSL10 < 0.
        <fs_prep>-HSL10 = abs( <fs_prep>-HSL10 ).
        bu_line-t15 = '-' &&  <fs_prep>-HSL10 .
      ELSE.
        bu_line-t15 = <fs_prep>-HSL10.
      ENDIF.
      IF <fs_prep>-HSL11 < 0.
        <fs_prep>-HSL11 = abs( <fs_prep>-HSL11 ).
        bu_line-t16 = '-' &&  <fs_prep>-HSL11 .
      ELSE.
        bu_line-t16 = <fs_prep>-HSL11.
      ENDIF.
      IF <fs_prep>-HSL12 < 0.
        <fs_prep>-HSL12 = abs( <fs_prep>-HSL12 ).
        bu_line-t17 = '-' && <fs_prep>-HSL12 .
      ELSE.
        bu_line-t17 = <fs_prep>-HSL12.
      ENDIF.
      IF <fs_prep>-HSL13 < 0.
        <fs_prep>-HSL13 = abs( <fs_prep>-HSL13 ).
        bu_line-t18 = '-' && <fs_prep>-HSL13 .
      ELSE.
        bu_line-t18 = <fs_prep>-HSL13.
      ENDIF.
      APPEND bu_line TO bu_tab.
      CLEAR bu_line.
**********************************************************************
      CALL METHOD go_spreadsheet->insert_range_dim
        EXPORTING
          no_flush = ' '
          name     = 'amount'
          left     = 6
          top      = lv_am_lines
          rows     = 1
          columns  = 13
          updating = 0.
      CALL METHOD go_spreadsheet->set_format
        EXPORTING
          rangename = 'amount'
          typ       = 1
          currency  = ''
          decimals  = 2
          no_flush  = ' '.
      CALL METHOD go_spreadsheet->insert_range_dim
        EXPORTING
          no_flush = ' '
          name     = 'amount2'
          left     = 2
          top      = lv_am_lines
          rows     = 1
          columns  = 1
          updating = 0.
      CALL METHOD go_spreadsheet->set_format
        EXPORTING
          rangename = 'amount2'
          typ       = 1
          currency  = ''
          decimals  = 2
          no_flush  = ' '.
      lv_am_lines = lv_am_lines + 1.
**********************************************************************
    ENDLOOP.
    bu_line-t1 = 'Итого'.
    bu_line-t2 = s.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    bu_line-t6 =  s1.
    bu_line-t7 =  s2.
    bu_line-t8 =  s3.
    bu_line-t9 =  s4.
    bu_line-t10 =  s5.
    bu_line-t11 =  s6.
    bu_line-t12 =  s7.
    bu_line-t13 =  s8.
    bu_line-t14 =  s9.
    bu_line-t15 =  s10.
    bu_line-t16 =  s11.
    bu_line-t17 =  s12.
    bu_line-t18 =  s13.
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
**********************************************************************
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount'
        left     = 6
        top      = lv_am_lines
        rows     = 1
        columns  = 13
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount2'
        left     = 2
        top      = lv_am_lines
        rows     = 1
        columns  = 1
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount2'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    lv_am_lines = lv_am_lines + 1.
**********************************************************************
    bu_line-t1 = 'Итого НИт'.
    bu_line-t2 = s.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    bu_line-t6 =  s1.
    IF s2 = 0.
      bu_line-t7 = 0.
    ELSE.
      bu_line-t7 =  s1 + s2.
    ENDIF.
    IF s3 = 0.
      bu_line-t8 = 0.
    ELSE.
      bu_line-t8 =  s1 + s2 + s3.
    ENDIF.
    IF s4 = 0.
      bu_line-t9 = 0.
    ELSE.
      bu_line-t9 =  s1 + s2 + s3 + s4.
    ENDIF.
    IF s5 = 0.
      bu_line-t10 = 0.
    ELSE.
      bu_line-t10 =  s1 + s2 + s3 + s4 + s5.
    ENDIF.
    IF s6 = 0.
      bu_line-t11 = 0.
    ELSE.
      bu_line-t11 =  s1 + s2 + s3 + s4 + s5 + s6.
    ENDIF.
    IF s7 = 0.
      bu_line-t12 = 0.
    ELSE.
      bu_line-t12 =  s1 + s2 + s3 + s4 + s5 + s6 + s7.
    ENDIF.
    IF s8 = 0.
      bu_line-t13 = 0.
    ELSE.
      bu_line-t13 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8.
    ENDIF.
    IF s9 = 0.
      bu_line-t14 = 0.
    ELSE.
      bu_line-t14 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9.
    ENDIF.
    IF s10 = 0.
      bu_line-t15 = 0.
    ELSE.
      bu_line-t15 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10.
    ENDIF.
    IF s11 = 0.
      bu_line-t16 = 0.
    ELSE.
      bu_line-t16 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11.
    ENDIF.
    IF s12 = 0.
      bu_line-t17 = 0.
    ELSE.
      bu_line-t17 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12.
    ENDIF.
    IF s13 = 0.
      bu_line-t18 = 0.
    ELSE.
      bu_line-t18 =  s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12 + s13.
    ENDIF.
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
**********************************************************************
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount'
        left     = 6
        top      = lv_am_lines
        rows     = 1
        columns  = 13
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount2'
        left     = 2
        top      = lv_am_lines
        rows     = 1
        columns  = 1
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount2'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    lv_am_lines = lv_am_lines + 1.
**********************************************************************
    DESCRIBE TABLE bu_tab LINES vr_r.
    CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
      TABLES
        data   = bu_tab[]
        fields = lt_fields_table[].
    tmp = bu_r + nu_r + 1.
    CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = tmp
      #2 = 1.
    SET PROPERTY OF cell1 'Value' = 'Налоговый учет'.
    CALL METHOD OF cell1 'Font' = font.
*      SET PROPERTY OF font 'ColorIndex' = 3.
    SET PROPERTY OF font 'Bold' = 1.
    SET PROPERTY OF font 'Size' = 18.
    tmp = tmp + 1.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = n_r
        left     = 1
        top      = tmp
        rows     = vr_r
        columns  = 18
        updating = 0.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = n_rh
        left     = 1
        top      = tmp
        rows     = 1
        columns  = 18
        updating = 0.
    LOOP AT bu_tab ASSIGNING <tab> WHERE t1 ne '№ объекта'.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t2 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t6 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t7 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t8 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t9 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t10 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t11 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t12 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t13 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t14 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t15 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t16 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t17 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t18 WITH ','.
    ENDLOOP.
    CALL METHOD go_spreadsheet->insert_one_table
      EXPORTING
        data_table   = bu_tab[]
        fields_table = lt_fields_table[]
        rangename    = n_r
        wholetable   = ' '
        no_flush     = ' '.
    tmp = tmp + 1.
    PERFORM merge USING tmp 1 tmp 4.
    tmp = tmp + 1.
    PERFORM merge USING tmp 1 tmp 4.

    "рамка у таблицы
    l_typ = 191.                                            " 10111111
    CALL METHOD go_spreadsheet->set_frame
      EXPORTING
        rangename = n_r
        typ       = l_typ
        color     = 1.


    " выравнивание по центру у шапки таблицы
    CALL METHOD go_spreadsheet->set_font
      EXPORTING
        rangename = n_rh
        family    = ''
        size      = -1
        bold      = 1
        italic    = -1
        align     = 1
        no_flush  = 'X'.


**********************************************************************
*ВР
    CLEAR: s, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13.
    CLEAR: bu_line, bu_tab[].
    bu_line-t1 = '№ объекта'.
    bu_line-t2 = 'Общаяя сумма'.
    bu_line-t3 = 'Действует с'.
    bu_line-t4 = 'Действует по'.
    bu_line-t5 = 'Дней'.
    bu_line-t6 =  m1+4(2) && '.' && m1+0(4).
    bu_line-t7 =  m2+4(2) && '.' && m2+0(4).
    bu_line-t8 =  m3+4(2) && '.' && m3+0(4).
    bu_line-t9 =  m4+4(2) && '.' && m4+0(4).
    bu_line-t10 =  m5+4(2) && '.' && m5+0(4).
    bu_line-t11 =  m6+4(2) && '.' && m6+0(4).
    bu_line-t12 =  m7+4(2) && '.' && m7+0(4).
    bu_line-t13 =  m8+4(2) && '.' && m8+0(4).
    bu_line-t14 =  m9+4(2) && '.' && m9+0(4).
    bu_line-t15 =  m10+4(2) && '.' && m10+0(4).
    bu_line-t16 =  m11+4(2) && '.' && m11+0(4).
    bu_line-t17 =  m12+4(2) && '.' && m12+0(4).
    bu_line-t18 =  m13+4(2) && '.' && m13+0(4).
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
    bu_line-t1 = 'Кол-во дней в периоде'.
    bu_line-t2 = ''.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    PERFORM get_days USING '19000101' '99991231' m1 CHANGING bu_line-t6.
    PERFORM get_days USING '19000101' '99991231' m2 CHANGING bu_line-t7.
    PERFORM get_days USING '19000101' '99991231' m3 CHANGING bu_line-t8.
    PERFORM get_days USING '19000101' '99991231' m4 CHANGING bu_line-t9.
    PERFORM get_days USING '19000101' '99991231' m5 CHANGING bu_line-t10.
    PERFORM get_days USING '19000101' '99991231' m6 CHANGING bu_line-t11.
    PERFORM get_days USING '19000101' '99991231' m7 CHANGING bu_line-t12.
    PERFORM get_days USING '19000101' '99991231' m8 CHANGING bu_line-t13.
    PERFORM get_days USING '19000101' '99991231' m9 CHANGING bu_line-t14.
    PERFORM get_days USING '19000101' '99991231' m10 CHANGING bu_line-t15.
    PERFORM get_days USING '19000101' '99991231' m11 CHANGING bu_line-t16.
    PERFORM get_days USING '19000101' '99991231' m12 CHANGING bu_line-t17.
    PERFORM get_days USING '19000101' '99991231' m13 CHANGING bu_line-t18.
    APPEND bu_line TO bu_tab.
    LOOP AT it_rep ASSIGNING <fs_prep> WHERE content = ls_cont-content AND ACCRULE = 'ВР'.
      s = s + <fs_prep>-AMOUNT.
      s1 = s1 + <fs_prep>-HSL01.
      s2 = s2 + <fs_prep>-HSL02.
      s3 = s3 + <fs_prep>-HSL03.
      s4 = s4 + <fs_prep>-HSL04.
      s5 = s5 + <fs_prep>-HSL05.
      s6 = s6 + <fs_prep>-HSL06.
      s7 = s7 + <fs_prep>-HSL07.
      s8 = s8 + <fs_prep>-HSL08.
      s9 = s9 + <fs_prep>-HSL09.
      s10 = s10 + <fs_prep>-HSL10.
      s11 = s11 + <fs_prep>-HSL11.
      s12 = s12 + <fs_prep>-HSL12.
      s13 = s13 + <fs_prep>-HSL13.
      bu_line-t1 = 'Кол-во дней действия'.
      bu_line-t2 = ''.
      bu_line-t3 = ''.
      bu_line-t4 = ''.
      bu_line-t5 = ''.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m1 CHANGING bu_line-t6.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m2 CHANGING bu_line-t7.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m3 CHANGING bu_line-t8.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m4 CHANGING bu_line-t9.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m5 CHANGING bu_line-t10.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m6 CHANGING bu_line-t11.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m7 CHANGING bu_line-t12.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m8 CHANGING bu_line-t13.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m9 CHANGING bu_line-t14.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m10 CHANGING bu_line-t15.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m11 CHANGING bu_line-t16.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m12 CHANGING bu_line-t17.
      PERFORM get_days USING <fs_prep>-VALITY_FROM <fs_prep>-VALITY_TO m13 CHANGING bu_line-t18.
      APPEND bu_line TO bu_tab.
      CLEAR bu_line.
      bu_line-t1 = <fs_prep>-ACAC_OBJNUMBER.
*      bu_line-t2 = <fs_prep>-AMOUNT.
      IF <fs_prep>-AMOUNT < 0.
        <fs_prep>-AMOUNT = abs( <fs_prep>-AMOUNT ).
        bu_line-t2 = '-' && <fs_prep>-AMOUNT .
      ELSE.
        bu_line-t2 = <fs_prep>-AMOUNT.
      ENDIF.
      bu_line-t3 = bu_line-t4 = bu_line-t5 = ''.
      IF <fs_prep>-HSL01 < 0.
        <fs_prep>-HSL01 = abs( <fs_prep>-HSL01 ).
        bu_line-t6 = '-' && <fs_prep>-HSL01.
      ELSE.
        bu_line-t6 = <fs_prep>-HSL01.
      ENDIF.
      IF <fs_prep>-HSL02 < 0.
        <fs_prep>-HSL02 = abs( <fs_prep>-HSL02 ).
        bu_line-t7 = '-' && <fs_prep>-HSL02 .
      ELSE.
        bu_line-t7 = <fs_prep>-HSL02.
      ENDIF.
      IF <fs_prep>-HSL03 < 0.
        <fs_prep>-HSL03 = abs( <fs_prep>-HSL03 ).
        bu_line-t8 = '-' && <fs_prep>-HSL03 .
      ELSE.
        bu_line-t8 = <fs_prep>-HSL03.
      ENDIF.
      IF <fs_prep>-HSL04 < 0.
        <fs_prep>-HSL04 = abs( <fs_prep>-HSL04 ).
        bu_line-t9 = '-' && <fs_prep>-HSL04 .
      ELSE.
        bu_line-t9 = <fs_prep>-HSL04.
      ENDIF.
      IF <fs_prep>-HSL05 < 0.
        <fs_prep>-HSL05 = abs( <fs_prep>-HSL05 ).
        bu_line-t10 = '-' && <fs_prep>-HSL05 .
      ELSE.
        bu_line-t10 = <fs_prep>-HSL05.
      ENDIF.
      IF <fs_prep>-HSL06 < 0.
        <fs_prep>-HSL06 = abs( <fs_prep>-HSL06 ).
        bu_line-t11 = '-' && <fs_prep>-HSL06 .
      ELSE.
        bu_line-t11 = <fs_prep>-HSL06.
      ENDIF.
      IF <fs_prep>-HSL07 < 0.
        <fs_prep>-HSL07 = abs( <fs_prep>-HSL07 ).
        bu_line-t12 = '-' &&  <fs_prep>-HSL07 .
      ELSE.
        bu_line-t12 = <fs_prep>-HSL07.
      ENDIF.
      IF <fs_prep>-HSL08 < 0.
        <fs_prep>-HSL08 = abs( <fs_prep>-HSL08 ).
        bu_line-t13 = '-' &&  <fs_prep>-HSL08 .
      ELSE.
        bu_line-t13 = <fs_prep>-HSL08.
      ENDIF.
      IF <fs_prep>-HSL09 < 0.
        <fs_prep>-HSL09 = abs( <fs_prep>-HSL09 ).
        bu_line-t14 = '-' &&  <fs_prep>-HSL09 .
      ELSE.
        bu_line-t14 = <fs_prep>-HSL09.
      ENDIF.
      IF <fs_prep>-HSL10 < 0.
        <fs_prep>-HSL10 = abs( <fs_prep>-HSL10 ).
        bu_line-t15 = '-' &&  <fs_prep>-HSL10 .
      ELSE.
        bu_line-t15 = <fs_prep>-HSL10.
      ENDIF.
      IF <fs_prep>-HSL11 < 0.
        <fs_prep>-HSL11 = abs( <fs_prep>-HSL11 ).
        bu_line-t16 = '-' &&  <fs_prep>-HSL11 .
      ELSE.
        bu_line-t16 = <fs_prep>-HSL11.
      ENDIF.
      IF <fs_prep>-HSL12 < 0.
        <fs_prep>-HSL12 = abs( <fs_prep>-HSL12 ).
        bu_line-t17 = '-' && <fs_prep>-HSL12 .
      ELSE.
        bu_line-t17 = <fs_prep>-HSL12.
      ENDIF.
      IF <fs_prep>-HSL13 < 0.
        <fs_prep>-HSL13 = abs( <fs_prep>-HSL13 ).
        bu_line-t18 = '-' && <fs_prep>-HSL13 .
      ELSE.
        bu_line-t18 = <fs_prep>-HSL13.
      ENDIF.
      APPEND bu_line TO bu_tab.
      CLEAR bu_line.
    ENDLOOP.
    bu_line-t1 = 'Итого НИт'.
*    bu_line-t2 = s.
    IF s < 0.
      s = abs( s ).
      bu_line-t2 = '-' && s.
    ELSE.
      bu_line-t2 = s.
    ENDIF.
    bu_line-t3 = ''.
    bu_line-t4 = ''.
    bu_line-t5 = ''.
    IF s2 <> 0.
      s2 = s1 + s2.
    ENDIF.
    IF s3 <> 0.
      s3 = s2 + s3.
    ENDIF.
    IF s4 <> 0.
      s4 = s3 + s4.
    ENDIF.
    IF s5 <> 0.
      s5 = s4 + s5.
    ENDIF.
    IF s6 <> 0.
      s6 = s5 + s6.
    ENDIF.
    IF s7 <> 0.
      s7 = s6 + s7.
    ENDIF.
    IF s8 <> 0.
      s8 = s7 + s8.
    ENDIF.
    IF s9 <> 0.
      s9 = s8 + s9.
    ENDIF.
    IF s10 <> 0.
      s10 = s9 + s10.
    ENDIF.
    IF s11 <> 0.
      s11 = s10 + s11.
    ENDIF.
    IF s12 <> 0.
      s12 = s11 + s12.
    ENDIF.
    IF s13 <> 0.
      s13 = s12 + s13.
    ENDIF.

    IF s1 < 0.
      s1 = abs( s1 ).
      bu_line-t6 = '-' && s1.
    ELSE.
      bu_line-t6 = s1.
    ENDIF.
    IF s2 < 0.
      s2 = abs( s2 ).
      bu_line-t7 = '-' && s2 .
    ELSE.
      bu_line-t7 = s2.
    ENDIF.
    IF s3 < 0.
      s3 = abs( s3 ).
      bu_line-t8 = '-' && s3 .
    ELSE.
      bu_line-t8 = s3.
    ENDIF.
    IF s4 < 0.
      s4 = abs( s4 ).
      bu_line-t9 = '-' && s4 .
    ELSE.
      bu_line-t9 = s4.
    ENDIF.
    IF s5 < 0.
      s5 = abs( s5 ).
      bu_line-t10 = '-' && s5 .
    ELSE.
      bu_line-t10 = s5.
    ENDIF.
    IF s6 < 0.
      s6 = abs( s6 ).
      bu_line-t11 = '-' && s6 .
    ELSE.
      bu_line-t11 = s6.
    ENDIF.
    IF s7 < 0.
      s7 = abs( s7 ).
      bu_line-t12 = '-' &&  s7 .
    ELSE.
      bu_line-t12 = s7.
    ENDIF.
    IF s8 < 0.
      s8 = abs( s8 ).
      bu_line-t13 = '-' &&  s8 .
    ELSE.
      bu_line-t13 = s8.
    ENDIF.
    IF s9 < 0.
      s9 = abs( s9 ).
      bu_line-t14 = '-' &&  s9 .
    ELSE.
      bu_line-t14 = s9.
    ENDIF.
    IF s10 < 0.
      s10 = abs( s10 ).
      bu_line-t15 = '-' &&  s10 .
    ELSE.
      bu_line-t15 = s10.
    ENDIF.
    IF s11 < 0.
      s11 = abs( s11 ).
      bu_line-t16 = '-' &&  s11 .
    ELSE.
      bu_line-t16 = s11.
    ENDIF.
    IF s12 < 0.
      s12 = abs( s12 ).
      bu_line-t17 = '-' && s12 .
    ELSE.
      bu_line-t17 = s12.
    ENDIF.
    IF s13 < 0.
      s13 = abs( s13 ).
      bu_line-t18 = '-' && s13 .
    ELSE.
      bu_line-t18 = s13.
    ENDIF.

    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
    DATA: tmp2 TYPE i.
    DESCRIBE TABLE bu_tab LINES tmp2.
    CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
      TABLES
        data   = bu_tab[]
        fields = lt_fields_table[].
    tmp = bu_r + nu_r + vr_r + 3.
    CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = tmp
      #2 = 1.
    SET PROPERTY OF cell1 'Value' = 'Временная разница'.
    CALL METHOD OF cell1 'Font' = font.
*      SET PROPERTY OF font 'ColorIndex' = 3.
    SET PROPERTY OF font 'Bold' = 1.
    SET PROPERTY OF font 'Size' = 18.
    tmp = tmp + 1.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = v_r
        left     = 1
        top      = tmp
        rows     = tmp2
        columns  = 18
        updating = 0.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = v_rh
        left     = 1
        top      = tmp
        rows     = 1
        columns  = 18
        updating = 0.
    LOOP AT bu_tab ASSIGNING <tab> WHERE t1 ne '№ объекта'.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t2 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t6 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t7 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t8 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t9 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t10 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t11 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t12 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t13 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t14 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t15 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t16 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t17 WITH ','.
      REPLACE ALL OCCURRENCES OF '.' in <tab>-t18 WITH ','.
    ENDLOOP.

    CALL METHOD go_spreadsheet->insert_one_table
      EXPORTING
        data_table   = bu_tab[]
        fields_table = lt_fields_table[]
        rangename    = v_r
        wholetable   = ' '
        no_flush     = ' '.
    tmp = tmp + 1.
    PERFORM merge USING tmp 1 tmp 4.
    tmp = tmp + 1.
    PERFORM merge USING tmp 1 tmp 4.

    "рамка у таблицы
    l_typ = 191.                                            " 10111111
    CALL METHOD go_spreadsheet->set_frame
      EXPORTING
        rangename = v_r
        typ       = l_typ
        color     = 1.


    " выравнивание по центру у шапки таблицы
    CALL METHOD go_spreadsheet->set_font
      EXPORTING
        rangename = v_rh
        family    = ''
        size      = -1
        bold      = 1
        italic    = -1
        align     = 1
        no_flush  = ' '.
**********************************************************************
    ft_r = tmp + tmp2.


    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = f_r
        left     = 1
        top      = ft_r
        rows     = 2
        columns  = 1
        updating = 0.
**********************************************************************
    lv_am_lines = ft_r - 4.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount'
        left     = 6
        top      = lv_am_lines
        rows     = 2
        columns  = 13
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
    CALL METHOD go_spreadsheet->insert_range_dim
      EXPORTING
        no_flush = ' '
        name     = 'amount2'
        left     = 2
        top      = lv_am_lines
        rows     = 2
        columns  = 1
        updating = 0.
    CALL METHOD go_spreadsheet->set_format
      EXPORTING
        rangename = 'amount2'
        typ       = 1
        currency  = ''
        decimals  = 2
        no_flush  = ' '.
**********************************************************************

    CLEAR: lt_thead[].
    lt_thead-t1 = 'Ответственный за составление регистра:   _______________   ______________________'.
    APPEND lt_thead. CLEAR lt_thead.
    lt_thead-t1 = '                                                                                      (подпись)                (расшифровка подписи)'.
    APPEND lt_thead. CLEAR lt_thead.

    CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
      TABLES
        data   = lt_thead[]
        fields = lt_fields_table[].
    "вставляем заголовок
    CALL METHOD go_spreadsheet->insert_one_table
      EXPORTING
        data_table   = lt_thead[]
        fields_table = lt_fields_table[]
        rangename    = f_r
        wholetable   = ' '
        no_flush     = ' '.

    CALL METHOD go_spreadsheet->set_font
      EXPORTING
        rangename = f_r
        family    = ''
        bold      = 0
        italic    = 0
        align     = 0
        size      = 10
        no_flush  = ' '.


    GET PROPERTY OF g_excel
    'ActiveWindow' = gs_activewindow.
    SET PROPERTY OF gs_activewindow 'WindowState' = xlmaximized.
*** Lanscape = 2    or     Portrait =  1
**    get property of g_excel 'ActiveSheet' = sheet .
**    set property of sheet 'Orientation' = '2'.
    PERFORM merge USING 1 14 2 18.
    CALL METHOD OF g_excel 'CELLS' = cell1
          EXPORTING
          #1 = 1
          #2 = 14.
    SET PROPERTY OF cell1 'Value' = 'к п. 35 Приложение № 1 К положению об учетной политике для целей налогового учета ООО «Аэроэкспресс»'.
    SET PROPERTY OF cell1 'WrapText' = 'True'.

    CALL METHOD GO_SPREADSHEET->SET_SHEET_NAME
      EXPORTING
        NEWNAME  = ls_cont-content+0(25)
*       OLDNAME  = ''
        NO_FLUSH = ' '.
    CALL METHOD cl_gui_cfw=>flush.
  ENDLOOP.
**********************************************************************

*  SET PROPERTY OF g_excel 'VISIBLE' = 1.
*  FREE OBJECT: cellrange, cell1, cell2, sheet, g_excel.
*  MESSAGE 'Выгрузка завершена'(034) TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REOPEN_DOCUMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REOPEN_DOCUMENT .
  CALL METHOD go_document1->reopen_document
*    EXPORTING
*      do_save       = 'X'
*      no_flush      = ' '
*      open_inplace  = ' '
*      open_readonly = ' '
*      onsave_macro  = ' '
*      startup_macro = ''
*    IMPORTING
*      error         =
*      has_changed   =
*      retcode       =
    .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DOI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DOI .

  CALL METHOD c_oi_container_control_creator=>get_container_control
    IMPORTING
      control = go_control.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'GR_CONTAINER'.

  CALL METHOD go_control->init_control
    EXPORTING
      no_flush             = 'X'
      r3_application_name  = 'S/4 application'
      parent               = go_container
    EXCEPTIONS
      javabeannotsupported = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD go_control->get_document_proxy
    EXPORTING
      document_type      = 'Excel.Sheet.8'
      no_flush           = ' '
      register_container = 'X'
    IMPORTING
      document_proxy     = go_document1.

  CALL METHOD go_document1->create_document
    EXPORTING
      document_title = 'РБП: Налоговый регистр'
      no_flush       = ' '
      open_inplace   = ''.

  CALL METHOD go_document1->get_spreadsheet_interface
    EXPORTING
      no_flush        = ' '
    IMPORTING
*     error           =
      sheet_interface = go_spreadsheet
*     retcode         =
    .

  " OLE
  "получим ссылку на создваемый документ
  go_document1->get_document_handle(
    EXPORTING
      no_flush = ' '
    IMPORTING
      handle   = document_handle ).

  GET PROPERTY  OF document_handle-obj 'Application' = g_excel  .
*  SET PROPERTY OF g_excel 'VISIBLE' = 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DAYS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_<FS_PREP>_VALITY_FROM  text
*      -->P_M1  text
*      <--P_DAYS  text
*&---------------------------------------------------------------------*
FORM GET_DAYS  USING    P_VALITY_FROM
                        P_VALITY_TO
                        P_MX
               CHANGING P_DAYS.

  DATA: lv_PERIO   TYPE CEST1-PERIO,
        lv_periv   TYPE TKEL-PERIV,
        lv_date    TYPE dats,
        lv_st_date TYPE dats.

  lv_st_date = p_mx+0(4) && p_mx+4(2) && '01'.
  lv_periv = 'K4'.
  lv_PERIO =  p_mx+0(4) && '0'  && p_mx+4(2).

  IF P_VALITY_TO+0(6) = p_mx+0(4) && p_mx+4(2).
    lv_date = P_VALITY_TO.
  ELSE.
    CALL FUNCTION 'RKE_GET_LAST_DAY_IN_PERIOD'
      EXPORTING
*       PERFLAG           = '1'
        PERIO             = lv_PERIO
        PERIV             = lv_periv
      IMPORTING
        DATE              = lv_date
      EXCEPTIONS
        I_ERROR           = 1
        I_PERFLAG_INVALID = 2
        I_PERIV_NOTEDITED = 3
        I_PERIV_NOTFOUND  = 4
        OTHERS            = 5.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
  DATA: d1 TYPE i, d2 TYPE i, d3 TYPE i.
  IF P_VALITY_FROM+0(6) = lv_st_date+0(6).
    d1 = P_VALITY_FROM+6(2).
*    P_DAYS = P_VALITY_FROM - lv_st_date.
  ELSE.
    d1 = '01'.
*    P_DAYS = lv_date - lv_st_date.
  ENDIF.
  d2 = lv_date+6(2).
  d3 = d2 - d1 + 1.
  P_DAYS = d3.
  IF lv_st_date+0(6) < P_VALITY_FROM+0(6) .
    P_DAYS = '0'.
  ENDIF.
  IF p_mx+0(4) && p_mx+4(2) > P_VALITY_TO+0(6) .
    P_DAYS = '0'.
  ENDIF.
ENDFORM.


FORM merge  USING  c1 TYPE i
                   c2 TYPE i
                   c3 TYPE i
                   c4 TYPE i.
  CALL METHOD OF g_excel 'CELLS' = cell1 NO FLUSH
    EXPORTING
    #1 = c1
    #2 = c2.
  CALL METHOD OF g_excel 'CELLS' = cell2 NO FLUSH
    EXPORTING
    #1 = c3
    #2 = c4.
  CALL METHOD OF g_excel 'Range' = cellrange NO FLUSH
    EXPORTING
    #1 = cell1
    #2 = cell2.
  CALL METHOD OF cellrange 'Merge' .
ENDFORM.                    " MERGE

FORM width  USING    c1 TYPE i
                     c2 TYPE i.
  CALL METHOD OF g_excel 'CELLS' = cell1
    EXPORTING
    #1 = 1
    #2 = c1.
  SET PROPERTY OF cell1 'ColumnWidth' = c2.
ENDFORM.                    " WIDTH
