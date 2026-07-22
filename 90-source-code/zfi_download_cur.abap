*&---------------------------------------------------------------------*
*& Report ZFI_DOWNLOAD_CUR
*&---------------------------------------------------------------------*
*&
REPORT  ZFI_DOWNLOAD_CUR.
INCLUDE ZFI_DOWNLOAD_CUR_TOP.
INCLUDE ZFI_DOWNLOAD_CUR_SSCR.
INCLUDE ZFI_DOWNLOAD_CUR_EVENTS.
**************************************************************
*convert download data from site to table format
**************************************************************
  data: xml type ref to cl_xml_document,
        xml2 type ref to cl_xml_document,
        w_subrc like sy-subrc,
        l_node type ref to if_ixml_node,
        gt_xmltree type   swxmltree,
        gs_xmltree like wa_tcur,
        val_node type string,
        l_node_root type ref to if_ixml_node,
        children type ref to if_ixml_node_list.

  data: iter type ref to if_ixml_node_iterator.

  create object xml.

  call method xml->create_with_table
    EXPORTING
      table   = response[]
      size    = rlength
    RECEIVING
      retcode = w_subrc.

  if w_subrc ne 0.
    write / 'error: unable to create xml'.
  endif.

  call method xml->find_node
    EXPORTING
      name = 'ValCurs'
    RECEIVING
      node = l_node.

  data:       date     type string,
              name     type string.
  field-symbols <i> like line of wa_tcur.
  data: attr type ref to if_ixml_named_node_map.
  data: date_node type ref to if_ixml_node.
  data: l_name type string.
  call method l_node->get_attributes
    RECEIVING
      rval = attr.

  call method attr->get_named_item
    EXPORTING
      name = 'Date'
    RECEIVING
      rval = date_node.

  l_name = date_node->get_value( ).
  children = l_node->get_children( ).
  iter = children->create_iterator( ).
  iter->reset( ).

  do.
    l_node_root = iter->get_next( ).
    if not l_node_root is bound.
      exit.
    endif.

    l_node = xml->find_node( name = 'NumCode' root = l_node_root ).
    check  l_node is bound.
    append initial line to wa_tcur assigning <i>.
    <i>-numcode = l_node->get_value( ).

    l_node = xml->find_node( name = 'CharCode' root = l_node_root ).
    check  l_node is bound.
    <i>-charcode = l_node->get_value( ).

    l_node = xml->find_node( name = 'Nominal' root = l_node_root ).
    check  l_node is bound.
    <i>-nominal = l_node->get_value( ).

    l_node = xml->find_node( name = 'Name' root = l_node_root ).
    check  l_node is bound.
    <i>-name = l_node->get_value( ).

    l_node = xml->find_node( name = 'Value' root = l_node_root ).
    check  l_node is bound.
    <i>-value = l_node->get_value( ).
  enddo.

**************************************************************
*Place data form table to TCURR
**************************************************************
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EXC_IN) TYPE  STRING
*"     VALUE(DCURR_IN) TYPE  STRING
*"     VALUE(SCURR_IN) TYPE  STRING
*"  TABLES
*"      EXCH_RATE_LIST STRUCTURE  BAPI1093_0 OPTIONAL
*"----------------------------------------------------------------------
*
  data: exch_rate  like bapi1093_0   occurs 1 with header line,
        rettab       like bapiret2   occurs 1 with header line,
        ret2         like bapiret2   occurs 1 with header line,
        ret3         like bapiret2   occurs 1 with header line,
        exch_rate_list like bapi1093_0   occurs 1 with header line.

  data:
       i_from_curr_range type table of bapi1093_3 with header line,
       i_to_currncy_range type table of bapi1093_3 with header line.

  write: 'Курсы валют на дату: '.  write: p_date.

  loop at wa_tcur WHERE
    charcode = 'CHF' or
    charcode = 'USD' or
    charcode = 'EUR' or
    charcode = 'GBP' or
    charcode = 'BYN'.
    replace ',' with '.' into wa_tcur-value.
    if wa_tcur-charcode = 'BYN'.
      wa_tcur-charcode = 'BYR'.
    ENDIF.
      exch_rate-rate_type   = 'M'.
      exch_rate-from_curr   = wa_tcur-charcode.
      exch_rate-to_currncy  = 'RUB'.
      exch_rate-valid_from  = p_date.
      exch_rate-exch_rate   = wa_tcur-value.
      exch_rate-from_factor = wa_tcur-nominal.
      exch_rate-to_factor   = wa_tcur-nominal.
      append exch_rate.

      call function 'BAPI_EXCHANGERATE_CREATE'
        EXPORTING
          exch_rate = exch_rate
        IMPORTING
          return    = rettab.

      write: / exch_rate-from_curr, ' = ', wa_tcur-value.
*      PERFORM print_protocol.
      clear exch_rate[].
    IF wa_tcur-charcode = 'USD'.
      exch_rate-rate_type   = 'M'.
      exch_rate-from_curr   = 'RUD'.
      exch_rate-to_currncy  = 'RUB'.
      exch_rate-valid_from  = p_date.
      exch_rate-exch_rate   = wa_tcur-value.
      exch_rate-from_factor = wa_tcur-nominal.
      exch_rate-to_factor   = wa_tcur-nominal.
      append exch_rate.
      call function 'BAPI_EXCHANGERATE_CREATE'
        EXPORTING
          exch_rate = exch_rate
        IMPORTING
          return    = rettab.
      write: / exch_rate-from_curr, ' = ', wa_tcur-value.
      clear exch_rate[].
    ELSEIF wa_tcur-charcode = 'EUR'.
      exch_rate-rate_type   = 'M'.
      exch_rate-from_curr   = 'RUE'.
      exch_rate-to_currncy  = 'RUB'.
      exch_rate-valid_from  = p_date.
      exch_rate-exch_rate   = wa_tcur-value.
      exch_rate-from_factor = wa_tcur-nominal.
      exch_rate-to_factor   = wa_tcur-nominal.
      append exch_rate.
      call function 'BAPI_EXCHANGERATE_CREATE'
        EXPORTING
          exch_rate = exch_rate
        IMPORTING
          return    = rettab.
      write: / exch_rate-from_curr, ' = ', wa_tcur-value.
      clear exch_rate[].
    ENDIF.
  endloop.

  call function 'BAPI_TRANSACTION_COMMIT'
    IMPORTING
      return = ret2.

  if ret2 is not initial.
    write / 'Ошибка при обновлении курсов'.
  endif.

*&---------------------------------------------------------------------*
*&      Form  print_protocol
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM print_protocol.
  if rettab is not initial and p_coment is not initial.
    write: / 'protocol:'.
    write: / rettab-ID.
    write: / rettab-MESSAGE.
    write: / rettab-MESSAGE_V1.
    write: / rettab-MESSAGE_V2.
    write: / rettab-MESSAGE_V3.
    write: / rettab-MESSAGE_V4.
    write: / '---------------------------------------'.
  endif.
  ENDFORM.
