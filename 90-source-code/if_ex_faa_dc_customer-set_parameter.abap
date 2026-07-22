  METHOD if_ex_faa_dc_customer~set_parameter.

    TYPES: BEGIN OF ty_s_amort,
             dep_area  TYPE faa_dc_s_hlpseg-area,
             dep_key   TYPE faa_dc_s_hlpseg-depr_key,
             dep_start TYPE faa_dc_s_hlpseg-start_date,
           END OF ty_s_amort.

    DATA: lt_amort TYPE STANDARD TABLE OF ty_s_amort WITH EMPTY KEY.

    CLEAR zcl_r2r_amortizat_zday=>ms_amort.
*    zcl_r2r_amortizat_zday=>ms_amort-plret_date = io_handle->mo_assetdata->ms_basic-plret_date.
    DATA(ls_data) = io_handle->mo_assetdata->get_master_data_mngr( )->get_data( ).
    zcl_r2r_amortizat_zday=>ms_amort-plret_date = ls_data-plret_date.
    LOOP AT its_hlpseg ASSIGNING FIELD-SYMBOL(<ls_hlpseg>).
      APPEND VALUE #( dep_area = <ls_hlpseg>-area
                      dep_key  = <ls_hlpseg>-depr_key
                      dep_start = <ls_hlpseg>-start_date ) TO zcl_r2r_amortizat_zday=>ms_amort-tab_amort.
    ENDLOOP.
  ENDMETHOD.
