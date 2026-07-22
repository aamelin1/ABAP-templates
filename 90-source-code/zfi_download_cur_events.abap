*&---------------------------------------------------------------------*
*&  Include           ZFI_DOWNLOAD_CUR_EVENTS
*&---------------------------------------------------------------------*
start-of-selection.
*------------------------------------------------------
*download data from www.cbr.ru
  types: begin of text,
         line(120),
         end of text.

  data: l_url(264) type c,
        cur_date(10) type c,
        status(3) type c,
        statustext(128) type c,
        dest like rfcdes-rfcdest,
        rlength type i,
*        response type standard table of text,
        response type standard table of text with header line,
        response_headers type table of text with header line,
        btocrlf type c.

  btocrlf = 'Y'.
  write p_date to cur_date dd/mm/yyyy.
  replace all occurrences of '.' in cur_date with '/'.

*l_url = 'http://www.cbr.ru/scripts/XML_daily.asp?date_req=10/10/2008'.
*l_url = 'http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=10/10/2008&date_req2=12/10/2008&VAL_NM_RQ=R01235'.
  l_url = 'http://www.cbr.ru/scripts/XML_daily.asp?date_req='.
  concatenate l_url cur_date into l_url.

  call function 'HTTP_GET'
    exporting
      absolute_uri                = l_url
      rfc_destination             = dest
*    user                        = user
*    password                    = pwd
      blankstocrlf                = btocrlf
    importing
      status_code                 = status
      status_text                 = statustext
      response_entity_body_length = rlength
    tables
      response_entity_body        = response
      response_headers            = response_headers
    exceptions
      CONNECT_FAILED                    = 1
      TIMEOUT                           = 2
      INTERNAL_ERROR                    = 3
      TCPIP_ERROR                       = 4
      DATA_ERROR                        = 5
      SYSTEM_FAILURE                    = 6
      COMMUNICATION_FAILURE             = 7
      OTHERS                            = 8
    .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  call function 'RFC_CONNECTION_CLOSE'
    EXPORTING
      destination = dest
    EXCEPTIONS
      others      = 0.
