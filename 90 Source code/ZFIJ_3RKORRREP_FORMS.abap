*----------------------------------------------------------------------*
***INCLUDE J_3RKORRREP_FORMS .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_customer_and_vendor
*&---------------------------------------------------------------------*
*       Get customer and vendor numbers from FI-document position
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_BELNR  text
*      -->P_BUZEI  text
*      <--V_LIFNR  text
*      <--V_KUNNR  text
*----------------------------------------------------------------------*
FORM get_customer_and_vendor  USING    p_bukrs
                                       p_belnr
                                       p_gjahr
                                       p_buzei
                              CHANGING v_lifnr
                                       v_kunnr.
  DATA: LV_RLDNR TYPE FAGL_RLDNR,
        LV_GJAHR TYPE GJAHR,
        LT_BSEG  TYPE FAGL_T_BSEG.

  CALL FUNCTION 'J3RK_CUSTOMIZING_GET_LEDGER'
    EXPORTING
      iv_bukrs  = p_bukrs
    IMPORTING
      EV_LEDGER = LV_RLDNR.
  IF LV_RLDNR IS INITIAL.
    SELECT SINGLE lifnr kunnr FROM bseg
    INTO (v_lifnr, v_kunnr)
     WHERE   bukrs = p_bukrs AND
             belnr = p_belnr AND
             gjahr = p_gjahr AND
             buzei = p_buzei.
  ELSE.
    CALL FUNCTION 'J3RK_DOCNR_RYEAR_TO_GJAHR'
      EXPORTING
        iv_belnr  = p_belnr
        iv_ryear  = p_gjahr
        iv_bukrs  = p_bukrs
        iv_rldnr  = LV_RLDNR
      IMPORTING
        EV_GJAHR  = LV_GJAHR
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
      EXPORTING
        i_rldnr   = LV_RLDNR
        i_bukrs   = p_bukrs
        i_belnr   = p_belnr
        i_gjahr   = lv_gjahr
        i_buzei   = p_buzei
      IMPORTING
        ET_BSEG   = LT_BSEG
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF sy-subrc EQ 0.
      READ TABLE LT_BSEG INTO BSEG INDEX 1.
      v_lifnr = bseg-lifnr.
      v_kunnr = bseg-kunnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_customer_and_vendor
*&---------------------------------------------------------------------*
*&      Form  fill_vendor_name
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ITEM_KLIFNR  text
*      <--P_GT_ITEM_KLNAME  text
*----------------------------------------------------------------------*
FORM fill_vendor_name  USING    p_lifnr
                       CHANGING v_name.
  CLEAR v_name.
  IF p_lifnr = g_current_vendor.
    v_name = g_current_vname.
  ELSE.
    READ TABLE it_vendors WITH TABLE KEY lifnr = p_lifnr.
    IF sy-subrc = 0.
      v_name =  it_vendors-name1.
    ELSE.
      PERFORM get_vendor_address USING p_lifnr
                                 CHANGING v_name.
    ENDIF.
  ENDIF.
ENDFORM.                    " fill_vendor_name
*&---------------------------------------------------------------------*
*&      Form  fill_customer_name
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ITEM_DKUNNR  text
*      <--P_GT_ITEM_DKNAME  text
*----------------------------------------------------------------------*
FORM fill_customer_name  USING    p_kunnr
                         CHANGING c_name.
  CLEAR c_name.
  IF p_kunnr = g_current_customer.
    c_name = g_current_cname.
  ELSE.
    READ TABLE it_customers WITH TABLE KEY kunnr = p_kunnr.
    IF sy-subrc = 0.
      c_name =  it_customers-name1.
    ELSE.
      PERFORM get_customer_address USING p_kunnr
                                 CHANGING c_name.
    ENDIF.
  ENDIF.
ENDFORM.                    " fill_customer_name
*&---------------------------------------------------------------------*
*&      Form  get_vendor_address
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_LIFNR  text
*----------------------------------------------------------------------*
FORM get_vendor_address  USING    p_lifnr
                         CHANGING v_name.
  CLEAR v_name.
  DATA l_adrnr LIKE lfa1-adrnr.
  DATA sel LIKE addr1_sel.
  SELECT SINGLE adrnr name1
  INTO (l_adrnr, v_name)
    FROM lfa1
    WHERE lifnr = p_lifnr.
  CHECK sy-subrc = 0.

  sel-addrnumber = l_adrnr.
  sel-nation = 'R'.
  CLEAR addr1_val.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = sel
    IMPORTING
      address_value     = addr1_val
    EXCEPTIONS
      parameter_error   = 1
      address_not_exist = 2
      version_not_exist = 3
      internal_error    = 4
      OTHERS            = 5.
  IF sy-subrc NE 0 or addr1_val-name1 is INITIAL.
    CLEAR sel-nation.
    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = sel
      IMPORTING
        address_value     = addr1_val
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.
  ENDIF.
  IF sy-subrc EQ 0 and not addr1_val-name1 is initial.
    v_name = addr1_val-name1.
  ENDIF.

  clear it_vendors.
  it_vendors-lifnr = g_current_vendor = p_lifnr.
  it_vendors-name1 = g_current_vname =  v_name..
  insert TABLE it_vendors.

ENDFORM.                    " get_vendor_address
*&---------------------------------------------------------------------*
*&      Form  get_customer_address
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_KUNNR  text
*      <--P_C_NAME  text
*----------------------------------------------------------------------*
form get_customer_address  using    p_kunnr
                           changing c_name.
  CLEAR c_name.
  DATA l_adrnr LIKE kna1-adrnr.
  DATA sel LIKE addr1_sel.
  SELECT SINGLE adrnr name1
  INTO (l_adrnr, c_name)
    FROM kna1
    WHERE kunnr = p_kunnr.
  CHECK sy-subrc = 0.

  sel-addrnumber = l_adrnr.
  sel-nation = 'R'.
  CLEAR addr1_val.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = sel
    IMPORTING
      address_value     = addr1_val
    EXCEPTIONS
      parameter_error   = 1
      address_not_exist = 2
      version_not_exist = 3
      internal_error    = 4
      OTHERS            = 5.
  IF sy-subrc NE 0 or addr1_val-name1 is INITIAL.
    CLEAR sel-nation.
    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = sel
      IMPORTING
        address_value     = addr1_val
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.
  ENDIF.
  IF sy-subrc EQ 0 and not addr1_val-name1 is initial.
    c_name = addr1_val-name1.
  ENDIF.

  clear it_customers.
  it_customers-kunnr = g_current_customer = p_kunnr.
  it_customers-name1 = g_current_cname = c_name.
  insert TABLE it_customers.

endform.                    " get_customer_address
*&---------------------------------------------------------------------*
*&      Form  hide_some_items_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form hide_some_items_fields changing total_text_length.
  clear total_text_length.
  data first_0 type i.
  first_0 = 0.
  loop at gt_fieldcat into ls_fieldcat
    where tabname = 'GT_ITEM' .
    CASE  ls_fieldcat-fieldname.
      WHEN 'CREDIT' or 'GSBERK' or 'BELNR' or 'BUDAT' or 'DLIFNR' or
           'DLNAME' or 'DKUNNR' or 'DKNAME' or 'KLIFNR' or 'KLNAME' or
           'KKUNNR' or 'KKNAME'.
        if not ls_fieldcat-outputlen is INITIAL.
          total_text_length = total_text_length + ls_fieldcat-outputlen + first_0.
        else.
          total_text_length = total_text_length + ls_fieldcat-ddic_outputlen + first_0.
        endif.
        first_0 = 1.
    ENDCASE.
  endloop.
  if gdat ne 'X'.
    PERFORM do_not_show_the_field using 'BUDAT'
                                  CHANGING total_text_length.
  endif.
  if gdoc ne 'X'.
    PERFORM do_not_show_the_field using 'BELNR'
                                CHANGING total_text_length.
  endif.
  if gcustven ne 'X'.
    PERFORM do_not_show_the_field using 'DLIFNR'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'DLNAME'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'DKUNNR'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'DKNAME'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'KLIFNR'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'KLNAME'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'KKUNNR'
                                  CHANGING total_text_length.
    PERFORM do_not_show_the_field using 'KKNAME'
                                  CHANGING total_text_length.
  endif.
endform.                    " hide_some_items_fields
*&---------------------------------------------------------------------*
*&      Form  do_not_show_the_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0409   text
*----------------------------------------------------------------------*
form do_not_show_the_field  using    p_fieldname
                             changing v_length.
  ls_fieldcat-no_out = 'X'.
  modify gt_fieldcat from ls_fieldcat TRANSPORTING no_out
      where tabname = 'GT_ITEM'  and
            fieldname = p_fieldname.
  loop at gt_fieldcat into ls_fieldcat
    where tabname = 'GT_ITEM'  and
            fieldname = p_fieldname.
    if not ls_fieldcat-outputlen is INITIAL.
      v_length = v_length - ls_fieldcat-outputlen - 1.
    else.
      v_length = v_length - ls_fieldcat-ddic_outputlen - 1.
    endif.
  endloop.
endform.                    " do_not_show_the_field
*&---------------------------------------------------------------------*
*&      Form  change_text_len_in_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TOTAL_TEXT_LEN_HD  text
*----------------------------------------------------------------------*
form change_text_len_in_header  using    p_length.
*ls_fieldcat-outputlen = p_length.
*modify gt_fieldcat from ls_fieldcat TRANSPORTING outputlen
*    where tabname = 'GT_HEADER'  and
*          fieldname = 'TEXT'.
endform.                    " change_text_len_in_header
*&---------------------------------------------------------------------*
*&      Form  fill_range_vendor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ITEM_DLIFNR  text
*      <--P_GSDLIFNR  text
*----------------------------------------------------------------------*
FORM fill_range_vendor  TABLES rlifnr structure gsdlifnr
                        USING    p_lifnr.

  REFRESH rlifnr.
  CHECK not p_lifnr is INITIAL.
  rlifnr-sign = 'I'.
  rlifnr-option = 'EQ'.
  rlifnr-low = p_lifnr.
  APPEND rlifnr.
ENDFORM.                    " fill_range_vendor
*&---------------------------------------------------------------------*
*&      Form  fill_range_customer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ITEM_DKUNNR  text
*      <--P_GSDKUNNR  text
*----------------------------------------------------------------------*
FORM fill_range_customer  TABLES rkunnr structure gsdkunnr
                          USING    p_kunnr.
  REFRESH rkunnr.
  CHECK not  p_kunnr is INITIAL.
  rkunnr-sign = 'I'.
  rkunnr-option = 'EQ'.
  rkunnr-low = p_kunnr.
  APPEND rkunnr.
ENDFORM.                    " fill_range_customer
*&---------------------------------------------------------------------*
*& Form REOPEN_DOCUMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REOPEN_DOCUMENT .
  CALL METHOD go_document1->reopen_document.
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
      r3_application_name  = 'R/3 application'
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
      no_flush           = 'X'
      register_container = 'X'
    IMPORTING
      document_proxy     = go_document1.

  CALL METHOD go_document1->create_document
    EXPORTING
      document_title = 'Анализ счета'
      no_flush       = 'X'
      open_inplace   = ''.

  CALL METHOD go_document1->get_spreadsheet_interface
    EXPORTING
      no_flush        = 'X'
    IMPORTING
*     error           =
      sheet_interface = go_spreadsheet
*     retcode         =
    .

  " OLE
  "получим ссылку на создваемый документ
  go_document1->get_document_handle(
    EXPORTING
      no_flush = 'X'
    IMPORTING
      handle   = document_handle ).

  GET PROPERTY  OF document_handle-obj 'Application' = g_excel  .
  Set property of g_excel 'DisplayAlerts' = 0.
*  SET PROPERTY OF g_excel 'VISIBLE' = 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILL_EXCEL .

  CALL METHOD GO_SPREADSHEET->SET_SHEET_NAME
    EXPORTING
      NEWNAME  = 'Анализ счета'
*     OLDNAME  = ''
      NO_FLUSH = ' '.
  TYPES: BEGIN OF tt_thead
             , t1(200)
      , END OF tt_thead.
  DATA: lt_thead TYPE STANDARD TABLE OF tt_thead WITH HEADER LINE.

  CLEAR lt_thead[].
  lt_thead-t1 = 'Общество с ограниченной ответственностью "Аэроэкспресс"'.
  APPEND lt_thead. CLEAR lt_thead.
  DATA: st_dt(10), fn_dt(10).
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = budat-low
    IMPORTING
      date_external            = st_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = budat-high
    IMPORTING
      date_external            = fn_dt
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.


  DATA: lv_accs(110),
        BEGIN OF lt_acc OCCURS 0.
      INCLUDE STRUCTURE zfij_3rkorrrep_alv_item.
  DATA: kside TYPE c,
        END OF lt_acc.
  lt_acc[] = gt_item[].
  SORT lt_acc by debit.
  DELETE ADJACENT DUPLICATES FROM lt_acc[] COMPARING debit.
  FIELD-SYMBOLS: <fs_acc> like LINE OF lt_acc.
  LOOP AT lt_acc ASSIGNING <fs_acc> WHERE debit ne 'ZZZZZZZZZZ'.
    CONCATENATE <fs_acc>-debit ',' lv_accs   INTO lv_accs.
  ENDLOOP.
  CONCATENATE 'Анализ счета:' lv_accs 'за период с:'  st_dt 'по' fn_dt INTO lt_thead-t1 SEPARATED BY space.

  APPEND lt_thead. CLEAR lt_thead.
  lt_thead-t1 = 'Единица измерения: рубль (код по ОКЕИ 383)'.
  APPEND lt_thead. CLEAR lt_thead.

  CALL METHOD go_spreadsheet->insert_range_dim
    EXPORTING
      no_flush = ' '
      name     = 'head'
      left     = 1
      top      = 2
      rows     = 3
      columns  = 1
      updating = 0.

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
      rangename    = 'head'
      wholetable   = ' '
      no_flush     = ' '.

  CALL METHOD OF g_excel 'CELLS' = cell1
        EXPORTING
        #1 = 2
        #2 = 1.
  CALL METHOD OF cell1 'Font' = font.
  SET PROPERTY OF font 'Bold' = 1.
  SET PROPERTY OF font 'Size' = 12.
  CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = 3
      #2 = 1.

  CALL METHOD OF cell1 'Font' = font.
  SET PROPERTY OF font 'Bold' = 1.
  SET PROPERTY OF font 'Size' = 14.
  PERFORM merge USING  3 1 3 4.
  SET PROPERTY OF cell1 'WrapText' = 'True'.
  CALL METHOD OF g_excel 'CELLS' = cell1
      EXPORTING
      #1 = 4
      #2 = 1.

  CALL METHOD OF cell1 'Font' = font.
  SET PROPERTY OF font 'Bold' = 1.
  SET PROPERTY OF font 'Size' = 8.


**********************************************************************

  TYPES: BEGIN OF tt_tab
        , t1(200)
        , t2(200)
        , t3(25)
        , t4(25)
        , END OF tt_tab.
  DATA: bu_tab  TYPE STANDARD TABLE OF tt_tab,
        bu_line LIKE LINE OF bu_tab.

  CLEAR: bu_line, bu_tab[].
  bu_line-t1 = 'Счет, наименование'.
  bu_line-t2 = 'Кор. счет, наименование'.
  bu_line-t3 = 'Дебет'.
  bu_line-t4 = 'Кредит'.
  APPEND bu_line TO bu_tab.
  CLEAR bu_line.
**********************************************************************
*Формируем таблицу для вывода
  FIELD-SYMBOLS: <fs_i> like line of gt_item.
  DATA: lv_sc_grp TYPE i.
  lv_sc_grp = 6.
  LOOP AT gt_item ASSIGNING <fs_i>.
**********************************************************************
    DATA: lv_txt TYPE skat-TXT50.
    SELECT SINGLE TXT50
      FROM skat
      INTO lv_txt
      WHERE saknr = <fs_i>-DEBIT
        AND ktopl = '1000'
        AND spras = sy-langu.
    bu_line-t1 = <fs_i>-DEBIT && '-' && lv_txt.
**********************************************************************
    IF <fs_i>-GTEXT IS NOT INITIAL.
      bu_line-t2 = <fs_i>-GTEXT.
    ELSE.
      bu_line-t2 = <fs_i>-CREDIT && '-' && <fs_i>-NOTE1.
    ENDIF.
**********************************************************************
    IF <fs_i>-BEG_BAL < 0.
      <fs_i>-BEG_BAL = abs( <fs_i>-BEG_BAL ).
      bu_line-t3 = '-' &&  <fs_i>-BEG_BAL .
    ELSE.
      bu_line-t3 = <fs_i>-BEG_BAL.
    ENDIF.
    REPLACE ALL OCCURRENCES OF '.' in bu_line-t3 WITH ','.
    IF <fs_i>-END_BAL < 0.
      <fs_i>-END_BAL = abs( <fs_i>-END_BAL ).
      bu_line-t4 = '-' &&  <fs_i>-END_BAL .
    ELSE.
      bu_line-t4 = <fs_i>-END_BAL.
    ENDIF.
    REPLACE ALL OCCURRENCES OF '.' in bu_line-t4 WITH ','.
    APPEND bu_line TO bu_tab.
    CLEAR bu_line.
  ENDLOOP.

*Кол-во строк в таблице
  DATA: lv_lines     TYPE i,
        lv_lines_all TYPE i.
  DESCRIBE TABLE bu_tab LINES lv_lines.
  lv_lines_all = lv_lines.
**********************************************************************

  PERFORM width USING 1 20.
  PERFORM width USING 2 25.
  PERFORM width USING 3 16.
  PERFORM width USING 4 16.

  CALL METHOD go_spreadsheet->insert_range_dim
    EXPORTING
      no_flush = ' '
      name     = 'tab_h'
      left     = 1
      top      = 5
      rows     = 1
      columns  = 4
      updating = 0.
  " выравнивание по центру у шапки таблицы
  CALL METHOD go_spreadsheet->set_font
    EXPORTING
      rangename = 'tab_h'
      family    = ''
      size      = -1
      bold      = 1
      italic    = -1
      align     = 1
      no_flush  = 'X'.


  CALL METHOD go_spreadsheet->insert_range_dim
    EXPORTING
      no_flush = ' '
      name     = 'tab'
      left     = 1
      top      = 5
      rows     = lv_lines_all
      columns  = 4
      updating = 0.

  "рамка у таблицы
  DATA l_typ TYPE i.
  l_typ = 191.                                              " 10111111
  CALL METHOD go_spreadsheet->set_frame
    EXPORTING
      rangename = 'tab'
      typ       = l_typ
      color     = 1.


  CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
    TABLES
      data   = bu_tab[]
      fields = lt_fields_table[].
  CALL METHOD go_spreadsheet->insert_one_table
    EXPORTING
      data_table   = bu_tab[]
      fields_table = lt_fields_table[]
      rangename    = 'tab'
      wholetable   = ' '
      no_flush     = ' '.

  CALL METHOD go_spreadsheet->insert_range_dim
    EXPORTING
      no_flush = ' '
      name     = 'amount'
      left     = 3
      top      = 6
      rows     = lv_lines
      columns  = 2
      updating = 0.
  CALL METHOD go_spreadsheet->set_format
    EXPORTING
      rangename = 'amount'
      typ       = 1
      currency  = ''
      decimals  = 2
      no_flush  = ' '.


  data ttt TYPE i.
  ttt = 5.
  LOOP AT gt_item ASSIGNING <fs_i>.
    ttt = ttt + 1.
    CALL METHOD OF g_excel 'CELLS' = cell2
          EXPORTING
          #1 = ttt
          #2 = 2.
    SET PROPERTY OF cell2 'WrapText' = 'True'.
  ENDLOOP.

  LOOP AT gt_item ASSIGNING <fs_i>.
    AT END OF debit.
      DATA: lv_tmp TYPE i.
      lv_tmp = sy-tabix + 5.
      PERFORM merge USING  lv_sc_grp 1 lv_tmp 1.
      CALL METHOD OF g_excel 'CELLS' = cell1
          EXPORTING
          #1 = lv_sc_grp
          #2 = 1.
      SET PROPERTY OF cell1 'WrapText' = 'True'.
      SET PROPERTY OF cell1 'VerticalAlignment' = 1."-4108 .

      DATA: lv_tt TYPE i.
      lv_tt = lv_tmp - 1.
      CASE <fs_i>-DEBIT.
        WHEN ''.
        WHEN 'ZZZZZZZZZZ'.
        WHEN OTHERS.

          PERFORM color USING lv_sc_grp 2.
          PERFORM color USING lv_tt 2.
          PERFORM color USING lv_tmp 2.
          PERFORM color USING lv_sc_grp 3.
          PERFORM color USING lv_tt 3.
          PERFORM color USING lv_tmp 3.
          PERFORM color USING lv_sc_grp 4.
          PERFORM color USING lv_tt 4.
          PERFORM color USING lv_tmp 4.
      ENDCASE.
      lv_sc_grp = lv_tmp + 1.
    ENDAT.
  ENDLOOP.
**********************************************************************
  lv_lines = lv_lines + 9.
  CLEAR: lt_thead[], lt_thead.
  DATA: address TYPE BAPIADDR3,
        lt_ret  TYPE STANDARD TABLE OF BAPIRET2.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      USERNAME = sy-uname
    IMPORTING
      ADDRESS  = address
    TABLES
      RETURN   = lt_ret.
  CONCATENATE 'Испольнитель:' ADDRESS-LASTNAME ADDRESS-FIRSTNAME INTO lt_thead-t1 SEPARATED BY space .
  APPEND lt_thead. CLEAR lt_thead.
  CALL METHOD go_spreadsheet->insert_range_dim
    EXPORTING
      no_flush = ' '
      name     = 'foot'
      left     = 1
      top      = lv_lines
      rows     = 1
      columns  = 1
      updating = 0.
  CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
    TABLES
      data   = lt_thead[]
      fields = lt_fields_table[].
  CALL METHOD go_spreadsheet->insert_one_table
    EXPORTING
      data_table   = lt_thead[]
      fields_table = lt_fields_table[]
      rangename    = 'foot'
      wholetable   = ' '
      no_flush     = ' '.

  GET PROPERTY OF g_excel
      'ActiveWindow' = gs_activewindow.
  SET PROPERTY OF gs_activewindow 'WindowState' = xlmaximized.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form WIDTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_1      text
*      -->P_15     text
*&---------------------------------------------------------------------*
FORM width  USING    c1 TYPE i
                     c2 TYPE i.
  CALL METHOD OF g_excel 'CELLS' = cell1
    EXPORTING
    #1 = 1
    #2 = c1.
  SET PROPERTY OF cell1 'ColumnWidth' = c2.
ENDFORM.                    " WIDTH


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
*&---------------------------------------------------------------------*
*& Form COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LV_SC_GR  text
*      -->P_2      text
*&---------------------------------------------------------------------*
FORM COLOR  USING    P_1
                     P_2.
  DATA: w_cell      TYPE ole2_object.
  DATA: w_interior TYPE ole2_object.

  CALL METHOD OF g_excel  'Cells' = w_cell
  EXPORTING     #1 = p_1
                #2 = P_2.                "you need to change the row and column as per your requirement


  GET PROPERTY OF w_cell 'Interior' = w_interior .
  SET PROPERTY OF w_interior 'ColorIndex' = 15.
ENDFORM.
