# Upload Exchange Rates (Argentina)

Argentina Central Bank API for Exchange rates - [https://api.bcra.gob.ar/estadisticascambiarias/v1.0/Cotizaciones?fecha=](https://api.bcra.gob.ar/estadisticascambiarias/v1.0/Cotizaciones?fecha=)YYYY-MM-DD

JSON structure:

```json
{
  "status": 200,
  "results": {
    "fecha": "2025-06-03",
    "detalle": [
      {
        "codigoMoneda": "ARS",
        "descripcion": "PESO",
        "tipoPase": 0.000845,
        "tipoCotizacion": 0
      },
      {
        "codigoMoneda": "AUD",
        "descripcion": "DOLAR AUSTRALIA",
        "tipoPase": 0.6467,
        "tipoCotizacion": 765.6928
      },
      {
        "codigoMoneda": "AWG",
        "descripcion": "FLORIN (ANTILLAS HOLANDESAS)",
        "tipoPase": 0.558659,
        "tipoCotizacion": 661.452514
      },
      ...
```

ABAP program for updating Exchange rates:

```abap
*&---------------------------------------------------------------------*
*& Report ZFI_UPDATE_BCRA_RATES
*&---------------------------------------------------------------------*
*& Amelin A. June 2025
*& Get exchange rates from Argentina Central Bank
*&---------------------------------------------------------------------*
REPORT zfi_update_bcra_rates.
**********************************************************************
TABLES: TCURR.
"Types
TYPES: BEGIN OF ty_bcra_rate,
         codigoMoneda   TYPE string,
         descripcion    TYPE string,
         tipoPase       TYPE decfloat34,
         tipoCotizacion TYPE decfloat34,
       END OF ty_bcra_rate,
       tt_bcra_rate TYPE STANDARD TABLE OF ty_bcra_rate WITH NON-UNIQUE DEFAULT KEY,
       BEGIN OF ty_days,
         fecha   TYPE string,
         detalle TYPE tt_bcra_rate,
       END OF ty_days,
       BEGIN OF ty_json,
         status  TYPE string,
         results TYPE ty_days,
       END OF ty_json.
**********************************************************************
"Variables
DATA: lv_raw      TYPE ty_json,
      lv_url      TYPE string,
      lo_client   TYPE REF TO if_http_client,
      lv_response TYPE string.
DATA: MO_LOG TYPE REF TO ZCLDEV_LOG.
**********************************************************************
"Selection screen
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
  PARAMETERS:     lv_date TYPE dats DEFAULT sy-datum OBLIGATORY,
                  p_url   TYPE string DEFAULT 'https://api.bcra.gob.ar/estadisticascambiarias/v1.0/Cotizaciones?fecha=' OBLIGATORY,
                  p_test  AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
  PARAMETERS:     p_rtyp TYPE KURST_CURR DEFAULT 'M' OBLIGATORY,
                  p_tocur TYPE TCURR_CURR DEFAULT 'ARS' OBLIGATORY.
  SELECT-OPTIONS: so_from FOR TCURR-FCURR NO INTERVALS.
SELECTION-SCREEN END OF BLOCK bl2.

**********************************************************************
INITIALIZATION.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'USD' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'AUD' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'BRL' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'CAD' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'CHF' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'CNY' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'EUR' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'GBP' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'JPY' ) TO so_from.
  APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'RUB' ) TO so_from.

**********************************************************************
START-OF-SELECTION.
  mo_log = NEW #( iv_object    = 'ZFI'
                  iv_subobject = 'ARG_BCRA'
                  iv_extnumber = CONV #( lv_date ) ).
  " 1. generate URL
  DATA lv_d(10).
  lv_d = lv_date+0(4) && '-' && lv_date+4(2) && '-' && lv_date+6(2).
  lv_url = p_url && |{ lv_d }|.

  "2. HTTP-req
  DATA: lv_SSL_ID	TYPE ssfapplssl.
  lv_SSL_ID = 'ANONYM'. "SSL cert

  MESSAGE s005(zfi_arg) WITH lv_url INTO zcldev_message=>mcv_dummy.
  mo_log->msg_add( ).
  WRITE: / |{ 'URL:' && lv_url }|.

  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url                = lv_url
      ssl_id             = lv_SSL_ID
    IMPORTING
      client             = lo_client
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    MESSAGE e001(zfi_arg) WITH 'HTTP error' INTO zcldev_message=>mcv_dummy.
    mo_log->msg_add( ).
    WRITE: / 'HTTP error'.
  ENDIF.

  lo_client->request->set_method( 'GET' ).
  lo_client->request->set_header_field( name = 'Content-Length' value = '0' ).
  lo_client->request->set_header_field( name = 'Accept' value = 'application/json' ).
  lo_client->send(
    EXCEPTIONS
     http_communication_failure = 1
     http_invalid_state         = 2 ).
  lo_client->receive(
    EXCEPTIONS http_communication_failure = 1
     http_invalid_state         = 2
     http_processing_failed     = 3 ).
  IF sy-subrc NE 0.
    DATA : lv_err_string TYPE string,
           lv_ret_code   TYPE sy-subrc.
    lo_client->response->get_status(
      IMPORTING
        code   = lv_ret_code
        reason = lv_err_string ).
    MESSAGE e006(zfi_arg) WITH lv_ret_code lv_err_string INTO zcldev_message=>mcv_dummy.
    mo_log->msg_add( ).
    WRITE: / |{ lv_ret_code && '|' && lv_err_string }|.
  ENDIF.
  lv_response = lo_client->response->get_cdata( ). "get JSON
  lo_client->close( ).

  MESSAGE s007(zfi_arg) WITH lv_response INTO zcldev_message=>mcv_dummy.
  mo_log->msg_add( ).
  WRITE: / lv_response.

  "3. Parse JSON
  /ui2/cl_json=>deserialize(
     EXPORTING
        json             = lv_response
        pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
     CHANGING
       data             = lv_raw ).

  IF lv_raw-status <> '200'.
    MESSAGE e002(zfi_arg) WITH 'Error, status:' lv_raw-status INTO zcldev_message=>mcv_dummy.
    mo_log->msg_add( ).
    WRITE: / |{ 'Error, status:' && lv_raw-status }|.
  ENDIF.

  "4. Call BAPI to update ExRate
  LOOP AT lv_raw-results-detalle ASSIGNING FIELD-SYMBOL(<fs_exrt>) WHERE codigoMoneda in so_from.
     MESSAGE s008(zfi_arg) WITH <fs_exrt>-codigoMoneda <fs_exrt>-descripcion <fs_exrt>-tipoPase <fs_exrt>-tipoCotizacion INTO zcldev_message=>mcv_dummy.
     mo_log->msg_add( ).
    WRITE: / |{ <fs_exrt>-codigoMoneda && '|' && <fs_exrt>-descripcion && '|' && <fs_exrt>-tipoPase && '|' && <fs_exrt>-tipoCotizacion }|.
  ENDLOOP.

  IF p_test NE 'X'. "Update ExRates
    DATA: lt_bapi_exchrate TYPE TABLE OF bapi1093_0,
          ls_exchrate      TYPE bapi1093_0,
          lt_return        TYPE TABLE OF bapiret2.
    LOOP AT lv_raw-results-detalle ASSIGNING FIELD-SYMBOL(<fs_inp>) WHERE codigoMoneda in so_from.
      IF <fs_inp>-tipoCotizacion IS INITIAL OR <fs_inp>-codigoMoneda IS INITIAL.
        CONTINUE.
      ENDIF.
      CLEAR ls_exchrate.
      ls_exchrate-rate_type     = p_rtyp.
      ls_exchrate-from_curr     = <fs_inp>-codigoMoneda.
      ls_exchrate-TO_CURRNCY    = p_tocur.
      ls_exchrate-valid_from    = lv_date + 1. "Set ExRates for next day
      ls_exchrate-exch_rate     = <fs_inp>-tipoCotizacion.
      ls_exchrate-from_factor   = '1'.
      ls_exchrate-to_factor     = '1'.
      APPEND ls_exchrate TO lt_bapi_exchrate.
    ENDLOOP.

    CALL FUNCTION 'BAPI_EXCHRATE_CREATEMULTIPLE'
      EXPORTING
        upd_allow     = 'X'
      TABLES
        exchrate_list = lt_bapi_exchrate
        return        = lt_return.
    " Results
    mo_log->msgtab_add( it_msg_bapiret2 = lt_return ).
    LOOP AT lt_return INTO DATA(ls_ret).
      WRITE: / |{ ls_ret-type && '|' && ls_ret-message }|.
    ENDLOOP.
    mo_log->db_save( i_save_all = abap_true ).
    " Commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    CLEAR: lt_bapi_exchrate, lt_bapi_exchrate[], lt_return, lt_return[].
  ENDIF.
```