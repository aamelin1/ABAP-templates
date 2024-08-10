*&---------------------------------------------------------------------*
*& Report ZFI_UPLOAD_EXCHANGE_RATES_BR
*&---------------------------------------------------------------------*
*&Amelin A. Upload ExRates from Brazil central bank
*&---------------------------------------------------------------------*
REPORT zfi_upload_exchange_rates_br.
TABLES: tcurr.
PARAMETERS: lc_url TYPE string DEFAULT 'https://www4.bcb.gov.br/Download/fechamento/[YYYYMMDD].csv' LOWER CASE .
**********************************************************************
PARAMETERS: p_date TYPE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECT-OPTIONS so_FCURR FOR tcurr-fcurr.
PARAMETERS p_to_c TYPE tcurr_curr DEFAULT 'BRL' OBLIGATORY.
SELECT-OPTIONS so_KURS1 for tcurr-KURST no INTERVALS. "DEFAULT 'P'.
SELECT-OPTIONS so_KURS2 for tcurr-kurst no INTERVALS. "DEFAULT 'M'.
SELECTION-SCREEN SKIP.
PARAMETERS: p_upd  RADIOBUTTON GROUP gr1 DEFAULT 'X',
            p_show RADIOBUTTON GROUP gr1.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS so_uname FOR sy-uname  NO INTERVALS. "DEFAULT sy-uname.
**********************************************************************
DATA: lt_response         TYPE STANDARD TABLE OF x255,
      lt_response_headers TYPE STANDARD TABLE OF char255.
DATA: lt_rates TYPE STANDARD TABLE OF zfi_exrates_br,
      ls_rates LIKE LINE OF lt_rates.
DATA: lt_ExRt  TYPE STANDARD TABLE OF bapi1093_0,
      ls_ExRt  LIKE LINE OF lt_ExRt,
      lt_ret   TYPE STANDARD TABLE OF bapiret2,
      lt_tcurr TYPE STANDARD TABLE OF tcurr.
DATA: lv_url(1000),
      status_code(1),
      stext(128),
      l_err TYPE string.
* To store the data of mail body containt
DATA: t_mail_body TYPE STANDARD TABLE OF solisti1,
      w_mail_body TYPE  solisti1.
**********************************************************************
INITIALIZATION.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'USD' ) TO so_FCURR.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'EUR' ) TO so_FCURR.

  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'P' ) TO so_kurs1.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'M' ) TO so_kurs2.


  LOOP AT SCREEN.
    IF screen-name = 'LC_URL' OR screen-name = 'P_TO_C'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.
  PERFORM prechecks.
  PERFORM get_exrates.
  PERFORM checks.
  PERFORM parse.
  PERFORM update_rates.
  PERFORM check_tcurr.
  PERFORM send_logs.
**********************************************************************

FORM prechecks .
* Check if date entered is valid and not in the future
  IF p_date > sy-datum .
    WRITE: / 'Date cannot be in the future'.
    MESSAGE 'Date cannot be in the future' TYPE 'E'.
  ENDIF.
ENDFORM.

FORM get_exrates .
* Build the URL for downloading the exchange rate file
  lv_url = lc_url.
  REPLACE '[YYYYMMDD]' IN lv_url WITH p_date.

  CALL FUNCTION 'HTTP_GET'
    EXPORTING
      absolute_uri          = lv_url
    IMPORTING
      status_code           = status_code
      status_text           = stext
    TABLES
      response_entity_body  = lt_response
      response_headers      = lt_response_headers
    EXCEPTIONS
      connect_failed        = 1
      timeout               = 2
      internal_error        = 3
      tcpip_error           = 4
      data_error            = 5
      system_failure        = 6
      communication_failure = 7
      OTHERS                = 8.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. l_err = 'connect_failed'.
      WHEN 2. l_err = 'timeout'.
      WHEN 3. l_err = 'internal_error'.
      WHEN 4. l_err = 'tcpip_error'.
      WHEN 5. l_err = 'data_error'.
      WHEN 6. l_err = 'system_failure'.
      WHEN 7. l_err = 'communication_failure'.
      WHEN 8. l_err = 'OTHERS'.
    ENDCASE.
    CONCATENATE TEXT-e00 l_err INTO l_err SEPARATED BY space.
*    MESSAGE e000(cl) WITH l_err.

  ENDIF.
ENDFORM.

FORM checks .
  READ TABLE lt_response_headers ASSIGNING FIELD-SYMBOL(<fs_http>) INDEX 1.
  IF status_code <> '2'.
    CLEAR: lt_response[].
  ENDIF.
ENDFORM.

FORM parse .
  DATA: lv_string TYPE string,
        lv_xstr   TYPE xstring.

  LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<fs>).
    lv_xstr = lv_xstr && <fs>.
  ENDLOOP.
  TRY.
      cl_bcs_convert=>xstring_to_string(
              EXPORTING
                iv_xstr   = lv_xstr
                iv_cp     =  1100                " SAP character set identification
              RECEIVING
                rv_string = lv_string ).
    CATCH cx_bcs.
  ENDTRY.
  DATA: lt_exr TYPE STANDARD TABLE OF string.
  SPLIT lv_string AT cl_abap_char_utilities=>newline INTO: TABLE lt_exr .
  LOOP AT lt_exr ASSIGNING FIELD-SYMBOL(<exr>).
    SPLIT <exr> AT ';' INTO ls_rates-date ls_rates-cyrtp ls_rates-ratetp ls_rates-cur ls_rates-rate1 ls_rates-rate2 ls_rates-rate3 ls_rates-rate4.
    DATA: t_d(10).
    CLEAR t_d.
    t_d = ls_rates-date.
    REPLACE ALL OCCURRENCES OF '/'  IN t_d WITH '.'.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = t_d
      IMPORTING
        date_internal            = ls_rates-c_date
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.

    ls_rates-c_cur = ls_rates-cur.
    PERFORM  conv_str_to_dec USING ls_rates-rate1 CHANGING ls_rates-c_rate1.
    PERFORM  conv_str_to_dec USING ls_rates-rate2 CHANGING ls_rates-c_rate2.
    PERFORM  conv_str_to_dec USING ls_rates-rate3 CHANGING ls_rates-c_rate3.
    PERFORM  conv_str_to_dec USING ls_rates-rate4 CHANGING ls_rates-c_rate4.
    IF ls_rates-cyrtp IS NOT INITIAL AND ls_rates-cur IN so_FCURR.
      APPEND ls_rates TO lt_rates.
**********************************************************************
*1st ExRate
      LOOP AT so_kurs1.
        ls_ExRt-rate_type = so_KURS1-low.
        ls_ExRt-from_curr = ls_rates-cur.
        ls_ExRt-to_currncy = p_to_c.
        ls_ExRt-valid_from = ls_rates-c_date.
        ls_ExRt-exch_rate = ls_rates-c_rate1.
        ls_ExRt-from_factor = '1'.
        ls_ExRt-to_factor = '1'.
*      ls_ExRt-exch_rate_v = ''.
*      ls_ExRt-from_factor_v = ''.
*      ls_ExRt-to_factor_v = ''.
        APPEND ls_ExRt TO lt_ExRt.
      ENDLOOP.
*2nd ExRate
      LOOP AT so_kurs2.
        ls_ExRt-rate_type = so_KURS2-low.
        ls_ExRt-from_curr = ls_rates-cur.
        ls_ExRt-to_currncy = p_to_c.
        ls_ExRt-valid_from = ls_rates-c_date.
        ls_ExRt-exch_rate = ls_rates-c_rate2.
        ls_ExRt-from_factor = '1'.
        ls_ExRt-to_factor = '1'.
*      ls_ExRt-exch_rate_v = ''.
*      ls_ExRt-from_factor_v = ''.
*      ls_ExRt-to_factor_v = ''.
        APPEND ls_ExRt TO lt_ExRt.
      ENDLOOP.
**********************************************************************
      IF p_upd = 'X'.

      ENDIF.
    ENDIF.
    CLEAR ls_rates.
  ENDLOOP.
ENDFORM.

FORM update_rates .
  CASE 'X'.
    WHEN p_upd.

* Update ExRates via BAPI
      CALL FUNCTION 'BAPI_EXCHRATE_CREATEMULTIPLE'
        EXPORTING
          upd_allow     = 'X'
        TABLES
          exchrate_list = lt_ExRt
          return        = lt_ret.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

    WHEN p_show.
***********************************************************************
      DATA: r_table     TYPE REF TO cl_salv_table.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = r_table
        CHANGING
          t_table      = lt_rates.
      CALL METHOD r_table->display.
    WHEN OTHERS.
  ENDCASE.
**********************************************************************
ENDFORM.

FORM check_tcurr .
  DATA: lv_GDATU TYPE tcurr-gdatu.
  DATA(l_date) = |{ p_date DATE = USER }|.
  CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
    EXPORTING
      input  = l_date
    IMPORTING
      output = lv_GDATU.

  CLEAR lt_tcurr[].
  SELECT *
    FROM tcurr
    INTO TABLE @lt_tcurr
    WHERE ( kurst in @so_KURS1 OR kurst in @so_KURS2 )
      AND fcurr IN @so_FCURR
      AND tcurr = @p_to_c
      AND gdatu = @lv_GDATU.

ENDFORM.

FORM conv_str_to_dec USING t CHANGING d.
  CALL FUNCTION 'HRCM_STRING_TO_AMOUNT_CONVERT'
    EXPORTING
      string            = t
      decimal_separator = ','
    IMPORTING
      betrg             = d
    EXCEPTIONS
      convert_error     = 1
      OTHERS            = 2.
ENDFORM.

FORM send_logs .
* To store data about Mail containts
  DATA: t_pack_list TYPE STANDARD TABLE OF sopcklsti1,
        w_pack_list TYPE sopcklsti1.
* Receiver list
  DATA: t_reclist TYPE STANDARD TABLE OF somlreci1,
        w_reclist TYPE somlreci1.
* Mail Header Info
  DATA: w_mail_header TYPE sodocchgi1.
* Variable to store the line in mail body
  DATA: v_tab_lines LIKE sy-tabix.
**********************************************************************

* Header
  DATA text(255).
  text = sy-uname && ` ` && sy-tcode && ` ` && sy-datum && ` ` && sy-uzeit.
  PERFORM add_line USING text.

  text = status_code && ` ` && stext.
  PERFORM add_line USING text.

  text = '__________________________________________________________________________'.
  PERFORM add_line USING text.

  text = l_err.
  PERFORM add_line USING text.


  w_mail_body-line = '<p><code>'.
  APPEND w_mail_body TO t_mail_body.

  LOOP AT lt_response_headers ASSIGNING FIELD-SYMBOL(<head>).
    text = <head>.
    PERFORM add_line USING text.
  ENDLOOP.

  w_mail_body-line = '</p></code>'.
  APPEND w_mail_body TO t_mail_body.

  text = '__________________________________________________________________________'.
  PERFORM add_line USING text.

* Bank Data
  LOOP AT lt_rates INTO ls_rates.
    text = ls_rates-date && '|' &&  ls_rates-cyrtp && '|' && ls_rates-ratetp && '|' && ls_rates-cur && '|' && ls_rates-rate1 && '|' && ls_rates-rate2 && '|' && ls_rates-rate3 && '|' && ls_rates-rate4.
    PERFORM add_line USING text.
  ENDLOOP.

  text = '__________________________________________________________________________'.
  PERFORM add_line USING text.

* BAPI logs
  text = 'BAPI Logs:'.
  PERFORM add_line USING text.

  LOOP AT lt_ret ASSIGNING FIELD-SYMBOL(<ret>).
    text = <ret>-type && ` ` &&  <ret>-id && ` ` &&  <ret>-number && ` ` &&  <ret>-message.
    PERFORM add_line USING text.
    text = <ret>-log_no && ` ` &&  <ret>-log_msg_no && ` ` &&  <ret>-message_v1 && ` ` &&  <ret>-message_v2 && ` ` &&  <ret>-message_v3 && ` ` &&  <ret>-message_v4.
    PERFORM add_line USING text.
    text = <ret>-parameter && ` ` &&  <ret>-row && ` ` &&  <ret>-field && ` ` &&  <ret>-system.
    PERFORM add_line USING text.
  ENDLOOP.


  text = '__________________________________________________________________________'.
  PERFORM add_line USING text.


* TCURR results
  text = 'Results (TCURR table):'.
  PERFORM add_line USING text.

  LOOP AT lt_tcurr ASSIGNING FIELD-SYMBOL(<tcurr>).
    text = <tcurr>-kurst && '|' && <tcurr>-fcurr && '|' && <tcurr>-tcurr && '|' && <tcurr>-gdatu && '|' && <tcurr>-ukurs && '|' && <tcurr>-ffact && '|' && <tcurr>-tfact.
    PERFORM add_line USING text.
  ENDLOOP.

  text = '__________________________________________________________________________'.
  PERFORM add_line USING text.

**********************************************************************
  CHECK so_uname[] IS NOT INITIAL.

  IF lt_rates[] IS NOT INITIAL.
    w_mail_header-obj_name = 'OK: Exchange rates has been uploaded'.
    w_mail_header-obj_descr = 'OK: Exchange rates has been uploaded'.
  ELSE.
    w_mail_header-obj_name = 'Error: Exchange rates hasn`t been uploaded'.
    w_mail_header-obj_descr = 'Error: Exchange rates hasn`t been uploaded'.
  ENDIF.

* Setting the size of mail document
  DESCRIBE TABLE t_mail_body LINES v_tab_lines.
  READ TABLE t_mail_body INTO w_mail_body INDEX v_tab_lines.
  w_mail_header-doc_size = ( v_tab_lines - 1 ) * 255 + strlen( w_mail_body-line ).
  CLEAR w_pack_list-transf_bin.
  w_pack_list-head_start = 1.
  w_pack_list-head_num   = 0.
  w_pack_list-body_start = 1.
  w_pack_list-body_num   = v_tab_lines.

* Document HTML to view the Hyperlink
  w_pack_list-doc_type   = 'HTM'.
  APPEND w_pack_list TO t_pack_list.

* Receiver
  LOOP AT so_uname.
    w_reclist-receiver = so_uname-low.
    w_reclist-rec_type = 'B'.
    APPEND w_reclist TO t_reclist.
  ENDLOOP.

  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = w_mail_header
      put_in_outbox              = 'X'
      commit_work                = 'X'
    TABLES
      packing_list               = t_pack_list
      contents_txt               = t_mail_body
      receivers                  = t_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      operation_no_authorization = 4
      OTHERS                     = 99.
  CASE sy-subrc.
    WHEN 0.
      WRITE: / 'Mail sent successfully'.
    WHEN OTHERS.
      WRITE: / 'Error occurred during sending !'.

  ENDCASE.
ENDFORM.

FORM add_line USING text.
  WRITE: / text.
  w_mail_body-line = text && '<br>'.
  APPEND w_mail_body TO t_mail_body.
ENDFORM.