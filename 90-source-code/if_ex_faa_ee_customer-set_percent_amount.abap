  METHOD if_ex_faa_ee_customer~set_percent_amount.

    DATA: lv_amort TYPE afasl VALUE 'ZDAY',
          ls_calcdata TYPE FAA_EE_S_CALCDATA.

    LOOP AT zcl_r2r_amortizat_zday=>ms_amort-tab_amort ASSIGNING FIELD-SYMBOL(<ls_amort>)
          WHERE dep_key = lv_amort AND dep_area = isx_cdata-s_segment-area.
      DATA(lv_total_days) = zcl_r2r_amortizat_zday=>ms_amort-plret_date - <ls_amort>-dep_start + 1.
      CHECK lv_total_days <> 0.
      MOVE-CORRESPONDING isx_cdata-s_segment-ref_calcdata->* TO ls_calcdata.

      IF ( ls_calcdata-period_to+2(2) = <ls_amort>-dep_start+4(2) AND ls_calcdata-fyear = <ls_amort>-dep_start+0(4) ) OR
        ( ( ls_calcdata-period_to+2(2) > zcl_r2r_amortizat_zday=>ms_amort-plret_date+4(2) AND ls_calcdata-fyear = zcl_r2r_amortizat_zday=>ms_amort-plret_date+0(4) ) OR
        ls_calcdata-fyear > zcl_r2r_amortizat_zday=>ms_amort-plret_date+0(4) ).
        DATA(lv_count_days_per) = zcl_r2r_amortizat_zday=>last_day_per( iv_per = ls_calcdata-period_to iv_year = ls_calcdata-fyear ) - <ls_amort>-dep_start.
      ELSEIF ( ( ls_calcdata-period_to+2(2) < <ls_amort>-dep_start+4(2) AND ls_calcdata-fyear = <ls_amort>-dep_start+0(4) ) OR ls_calcdata-fyear < <ls_amort>-dep_start+0(4) )
        AND
        ( ls_calcdata-period_to+2(2) = zcl_r2r_amortizat_zday=>ms_amort-plret_date+4(2) AND ls_calcdata-fyear = zcl_r2r_amortizat_zday=>ms_amort-plret_date+0(4) ).
        lv_count_days_per = zcl_r2r_amortizat_zday=>ms_amort-plret_date - zcl_r2r_amortizat_zday=>first_day_per( iv_per = ls_calcdata-period_to iv_year = ls_calcdata-fyear ).
      ELSEIF ( ls_calcdata-period_to+2(2) = zcl_r2r_amortizat_zday=>ms_amort-plret_date+4(2) AND ls_calcdata-fyear = zcl_r2r_amortizat_zday=>ms_amort-plret_date+0(4) ) AND
        ( ls_calcdata-period_to+2(2) = <ls_amort>-dep_start+4(2) AND ls_calcdata-fyear = <ls_amort>-dep_start+0(4) ).
        lv_count_days_per = zcl_r2r_amortizat_zday=>ms_amort-plret_date - <ls_amort>-dep_start.
      ELSE.
        lv_count_days_per = zcl_r2r_amortizat_zday=>last_day_per( iv_per = ls_calcdata-period_to iv_year = ls_calcdata-fyear ) -
            zcl_r2r_amortizat_zday=>first_day_per( iv_per = ls_calcdata-period_to iv_year = ls_calcdata-fyear ).
      ENDIF.
*      ls_calcdata-amount = ls_calcdata-basevalue * lv_count_days_per / lv_total_days.
*      cs_calcdata-amount = ls_calcdata-netvalue * lv_count_days_per / lv_total_days.
      add 1 to lv_count_days_per.
      cs_calcdata-amount = ls_calcdata-sum_apc * lv_count_days_per / lv_total_days.
      cs_calcdata-perfactor = 1.
*      cs_calcdata-amount_prev = ls_calcdata-netvalue * lv_count_days_per / lv_total_days.
      RETURN.
    ENDLOOP.
  ENDMETHOD.
