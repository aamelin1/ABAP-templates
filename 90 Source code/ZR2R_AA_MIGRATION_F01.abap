*&---------------------------------------------------------------------*
*& Include          ZR2R_AA_MIGRATION_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form get_cust
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_CUST
*&---------------------------------------------------------------------*
FORM get_cust  TABLES p_lt_cust STRUCTURE zvr2r_aa_migrcus.
  CLEAR p_lt_cust[].
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @p_lt_cust
    FROM ztr2r_aa_migrcus
    LEFT OUTER JOIN dd03l
    ON dd03l~tabname  = ztr2r_aa_migrcus~strname
    AND dd03l~fieldname	=	ztr2r_aa_migrcus~fieldname
    LEFT OUTER JOIN dd01l
    ON dd01l~domname  = dd03l~domname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FILE
*&---------------------------------------------------------------------*
FORM get_file  TABLES p_lt_file STRUCTURE alsmex_tabline.

  CLEAR p_lt_file[].
  file = p_file.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = file
      i_begin_col             = '1'
      i_begin_row             = '4'
      i_end_col               = '200'
      i_end_row               = '10000'
    TABLES
      intern                  = p_lt_file
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form prep_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CUST
*&      --> LT_FILE
*&      --> LT_REP
*&---------------------------------------------------------------------*
FORM prep_alv  TABLES   p_lt_cust STRUCTURE zvr2r_aa_migrcus
                        p_lt_file STRUCTURE alsmex_tabline
                        p_lt_rep LIKE lt_rep
                        p_lt_repX LIKE lt_repX.
  CLEAR p_lt_rep[].
  SORT p_lt_file BY row col.
  LOOP AT p_lt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
    DATA: ls_rep  LIKE LINE OF p_lt_rep,
          ls_repx LIKE LINE OF p_lt_repx.
    READ TABLE p_lt_cust WITH KEY numpp = <fs_file>-col ASSIGNING FIELD-SYMBOL(<fs_cust>).
    IF <fs_cust> IS ASSIGNED.
      DATA name(50).
      IF <fs_cust>-afabe IS INITIAL.
        name = <fs_cust>-strname && '-' && <fs_cust>-fieldname.
      ELSE.
        name = <fs_cust>-afabe && '_' && <fs_cust>-strname && '-' && <fs_cust>-fieldname.
      ENDIF.
      ASSIGN COMPONENT name OF STRUCTURE ls_rep TO FIELD-SYMBOL(<val>).
      IF <fs_cust>-convexit IS NOT INITIAL. "CONVEXIT
        DATA: convname TYPE rs38l_fnam.
        convname = 'CONVERSION_EXIT_' && <fs_cust>-convexit && '_INPUT'.
        CALL FUNCTION convname
          EXPORTING
            input  = <fs_file>-value
          IMPORTING
            output = <val>.
        CLEAR convname.
      ELSEIF <fs_cust>-inttype = 'D'.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external            = <fs_file>-value
            accept_initial_date      = abap_true
          IMPORTING
            date_internal            = <val>
          EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.
        IF sy-subrc <> 0.
*         Implement suitable error handling here
        ENDIF.
      ELSEIF <fs_cust>-datatype = 'NUMC' or <fs_cust>-datatype = 'QUAN'.
        PERFORM conv_str_to_amount USING <fs_file>-value CHANGING <val>.
      ELSEIF  <fs_cust>-datatype = 'DEC'.
        PERFORM conv_str_to_dec USING <fs_file>-value CHANGING <val>.
      ELSE.
        <val> = <fs_file>-value.
      ENDIF.
      IF <fs_cust>-strname <> 'BAPI1022_KEY' AND name+12(6) <> 'CUMVAL'.
        ASSIGN COMPONENT name OF STRUCTURE ls_repx TO FIELD-SYMBOL(<valx>).
        IF <fs_cust>-fieldname = 'AREA'.
          <valx> = <fs_file>-value.
        ELSE.
          <valx> = abap_true.
        ENDIF.
      ENDIF.
      CLEAR name.
      UNASSIGN: <val>, <valx>.
    ENDIF.
    UNASSIGN <fs_cust>.
    AT END OF row.
      ls_rep-rownn = ls_repx-rownn = <fs_file>-row.
      APPEND ls_rep TO p_lt_rep.
      APPEND ls_repx TO p_lt_repx.
      CLEAR: ls_rep, ls_repx.
    ENDAT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZSR2R_MIGRATION_ALV'
    CHANGING
      ct_fieldcat            = fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
  ENDIF.

**************************************
  gs_layout_fm-cwidth_opt = 'X'.
  gs_layout_fm-zebra = 'X'.


**************************************
*Костыли для отображения вложенных структур в АЛВ
  CLEAR lt_rep_v[].
  lt_rep_v[] = lt_rep[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc            = gs_layout_fm
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'SETPF'
      i_callback_user_command  = 'UCOMM'
      i_grid_settings          = glay
      it_fieldcat_lvc          = fcat
    TABLES
      t_outtab                 = lt_rep_v
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
FORM setpf USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM ucomm USING r_ucomm LIKE sy-ucomm
   rs_selfield TYPE slis_selfield.
  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN '&IC1'.
      DATA: ls_rep LIKE LINE OF lt_rep_v.
      READ TABLE lt_rep_v INTO ls_rep INDEX rs_selfield-tabindex.
      CHECK ls_rep-anln1 IS NOT INITIAL.
      SET PARAMETER ID 'BUK' FIELD ls_rep-bukrs.
      SET PARAMETER ID 'AN1' FIELD ls_rep-anln1.
      SET PARAMETER ID 'AN2' FIELD ls_rep-anln2.
      CALL TRANSACTION 'AW01N'.
    WHEN 'CHECK'.
      PERFORM call_bapi USING abap_true.
    WHEN 'POST'.
      PERFORM call_bapi USING abap_false.
    WHEN 'CUST'.
      CALL TRANSACTION 'FAA_CMP_LDT'.
    WHEN 'MAPP'.
      CALL TRANSACTION 'ZR2R_AA_MIGMAPP'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form post
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_bapi USING p_mode .
  DATA: ls_key                 TYPE bapi1022_key,
        lv_testrun             TYPE bapi1022_misc-testrun,
        ls_GENERALDATA         TYPE bapi1022_feglg001,
        ls_GENERALDATAX        TYPE bapi1022_feglg001x,
        ls_INVENTORY           TYPE bapi1022_feglg011,
        ls_INVENTORYX          TYPE bapi1022_feglg011x,
        ls_POSTINGINFORMATION  TYPE bapi1022_feglg002,
        ls_POSTINGINFORMATIONX TYPE bapi1022_feglg002x,
        ls_TIMEDEPENDENTDATA   TYPE bapi1022_feglg003,
        ls_TIMEDEPENDENTDATAX  TYPE bapi1022_feglg003x,
        ls_ALLOCATIONS         TYPE bapi1022_feglg004,
        ls_ALLOCATIONSX        TYPE bapi1022_feglg004x,
        ls_ORIGIN              TYPE bapi1022_feglg009,
        ls_ORIGINX             TYPE bapi1022_feglg009x,
        ls_GLO_RUS_GEN         TYPE bapi1022_glo_rus_gen,
        ls_GLO_RUS_GENX        TYPE bapi1022_glo_rus_genx,
        ls_GLO_RUS_PTX         TYPE bapi1022_glo_rus_ptx,
        ls_GLO_RUS_PTXX        TYPE bapi1022_glo_rus_ptxx,
        ls_GLO_RUS_TTX         TYPE bapi1022_glo_rus_ttx,
        ls_GLO_RUS_TTXX        TYPE bapi1022_glo_rus_ttxx,
        ls_GLO_TIME_DEP        TYPE bapi1022_glo_time_dep,
        ls_GLO_RUS_GENTD       TYPE bapi1022_glo_rus_gentd,
        ls_GLO_RUS_GENTDX      TYPE bapi1022_glo_rus_gentdx,
        ls_GLO_RUS_PTXTD       TYPE bapi1022_glo_rus_ptxtd,
        ls_GLO_RUS_PTXTDX      TYPE bapi1022_glo_rus_ptxtdx,
        ls_GLO_RUS_TTXTD       TYPE bapi1022_glo_rus_ttxtd,
        ls_GLO_RUS_TTXTDX      TYPE bapi1022_glo_rus_ttxtdx,
        lv_e_bukrs             TYPE bapi1022_1-comp_code,
        lv_e_anln1             TYPE bapi1022_1-assetmaino,
        lv_e_anln2             TYPE bapi1022_1-assetsubno,
        lv_e_ref               TYPE bapi1022_reference,
        lt_return              TYPE STANDARD TABLE OF bapiret2.


  lv_TESTRUN = p_mode.
  LOOP AT lt_rep ASSIGNING FIELD-SYMBOL(<fs_repp>).
    cl_progress_indicator=>progress_indicate(
      i_text = |Processing:  { sy-tabix }/{ lines( lt_rep ) }|
      i_output_immediately = abap_true ).
    READ TABLE lt_repx WITH KEY rownn = <fs_repp>-rownn ASSIGNING FIELD-SYMBOL(<fs_reppx>).
    CHECK <fs_reppx> IS ASSIGNED.
    ls_key = <fs_repp>-bapi1022_key.
    ls_GENERALDATA = <fs_repp>-generaldata.
    ls_INVENTORY = <fs_repp>-inventory.
    ls_POSTINGINFORMATION = <fs_repp>-postinginformation.
    ls_TIMEDEPENDENTDATA = <fs_repp>-timedependentdata.
    ls_ALLOCATIONS = <fs_repp>-allocations.
    ls_ORIGIN = <fs_repp>-bapi1022_feglg009.
    ls_GLO_RUS_GEN = <fs_repp>-bapi1022_glo_rus_gen.
    ls_GLO_RUS_PTX = <fs_repp>-bapi1022_glo_rus_ptx.
    ls_GLO_RUS_TTX = <fs_repp>-bapi1022_glo_rus_ttx.
    ls_GLO_RUS_GENTD = <fs_repp>-bapi1022_glo_rus_gentd.
    ls_GLO_RUS_PTXTD = <fs_repp>-bapi1022_glo_rus_ptxtd.
    ls_GLO_RUS_TTXTD = <fs_repp>-bapi1022_glo_rus_ttxtd.

    ls_GENERALDATAX = <fs_reppx>-generaldata.
    ls_INVENTORYX = <fs_reppx>-inventory.
    ls_POSTINGINFORMATIONX = <fs_reppx>-postinginformation.
    ls_TIMEDEPENDENTDATAX = <fs_reppx>-timedependentdata.
    ls_ALLOCATIONSX = <fs_reppx>-allocations.
    ls_ORIGINX = <fs_reppx>-bapi1022_feglg009.
    ls_GLO_RUS_GENX = <fs_reppx>-bapi1022_glo_rus_gen.
    ls_GLO_RUS_PTXX = <fs_reppx>-bapi1022_glo_rus_ptx.
    ls_GLO_RUS_TTXX = <fs_reppx>-bapi1022_glo_rus_ttx.
    ls_GLO_RUS_GENTDX = <fs_reppx>-bapi1022_glo_rus_gentd.
    ls_GLO_RUS_PTXTDX = <fs_reppx>-bapi1022_glo_rus_ptxtd.
    ls_GLO_RUS_TTXTDX = <fs_reppx>-bapi1022_glo_rus_ttxtd.

*Проверим какие области активны у класса
    DATA: lt_ankb TYPE STANDARD TABLE OF ankb,
          ls_ankb LIKE LINE OF lt_ankb.
    SELECT *
      FROM ankb
      INTO CORRESPONDING FIELDS OF TABLE lt_ankb
      WHERE afapl = '1000'
        AND anlkl = ls_GENERALDATA-assetclass.


    DATA: lt_deparea  TYPE STANDARD TABLE OF bapi1022_dep_areas,
          lt_depareax TYPE STANDARD TABLE OF bapi1022_dep_areasx,
          ls_deparea  LIKE LINE OF lt_deparea,
          ls_depareax LIKE LINE OF lt_depareax.
    CLEAR: lt_deparea[], lt_depareax[], ls_deparea, ls_depareax.
    DATA: lt_val TYPE STANDARD TABLE OF bapi1022_cumval,
          ls_val LIKE LINE OF lt_val.
    CLEAR: lt_val[], ls_val.

    READ TABLE lt_ankb INTO ls_ankb WITH KEY afabe = '01'.
    IF ls_ankb-xafbe NE 'X'.
      ls_deparea = <fs_repp>-01_bapi1022_dep_areas.
      ls_depareax = <fs_reppx>-01_bapi1022_dep_areas.
      IF <fs_repp>-01_bapi1022_dep_areas-ulife_yrs = '000' AND <fs_repp>-01_bapi1022_dep_areas-ulife_prds = '000' AND <fs_repp>-01_bapi1022_dep_areas-DEP_KEY IS INITIAL.
        ls_deparea-deactivate = abap_true.
        ls_depareax-deactivate = abap_true.
      ELSE.
        ls_val = <fs_repp>-01_bapi1022_cumval.
        ls_val-ord_dep = ls_val-ord_dep * -1.
        ls_val-spe_dep = ls_val-spe_dep * -1.
        APPEND ls_val TO lt_val.
      ENDIF.
      APPEND ls_deparea TO lt_deparea.
      APPEND ls_depareax TO lt_depareax.
    ENDIF.

    READ TABLE lt_ankb INTO ls_ankb WITH KEY afabe = '03'.
    IF ls_ankb-xafbe NE 'X'.
      ls_deparea = <fs_repp>-03_bapi1022_dep_areas.
      ls_depareax = <fs_reppx>-03_bapi1022_dep_areas.
      IF <fs_repp>-03_bapi1022_dep_areas-ulife_yrs = '000' AND <fs_repp>-03_bapi1022_dep_areas-ulife_prds = '000' AND <fs_repp>-03_bapi1022_dep_areas-DEP_KEY IS INITIAL.
        ls_deparea-deactivate = abap_true.
        ls_depareax-deactivate = abap_true.
      ELSE.
        ls_val = <fs_repp>-03_bapi1022_cumval.
        ls_val-ord_dep = ls_val-ord_dep * -1.
        ls_val-spe_dep = ls_val-spe_dep * -1.
        APPEND ls_val TO lt_val.
      ENDIF.
      APPEND ls_deparea TO lt_deparea.
      APPEND ls_depareax TO lt_depareax.
    ENDIF.

    READ TABLE lt_ankb INTO ls_ankb WITH KEY afabe = '10'.
    IF ls_ankb-xafbe NE 'X'.
      ls_deparea = <fs_repp>-10_bapi1022_dep_areas.
      ls_depareax = <fs_reppx>-10_bapi1022_dep_areas.
      IF <fs_repp>-10_bapi1022_dep_areas-ulife_yrs = '000' AND <fs_repp>-10_bapi1022_dep_areas-ulife_prds = '000' AND <fs_repp>-10_bapi1022_dep_areas-DEP_KEY IS INITIAL.
        ls_deparea-deactivate = abap_true.
        ls_depareax-deactivate = abap_true.
      ELSE.
        ls_val = <fs_repp>-10_bapi1022_cumval.
        ls_val-ord_dep = ls_val-ord_dep * -1.
        ls_val-spe_dep = ls_val-spe_dep * -1.
        APPEND ls_val TO lt_val.
      ENDIF.
      APPEND ls_deparea TO lt_deparea.
      APPEND ls_depareax TO lt_depareax.
    ENDIF.

    READ TABLE lt_ankb INTO ls_ankb WITH KEY afabe = '30'.
    IF ls_ankb-xafbe NE 'X'.
      ls_deparea = <fs_repp>-30_bapi1022_dep_areas.
      ls_depareax = <fs_reppx>-30_bapi1022_dep_areas.
      IF <fs_repp>-30_bapi1022_dep_areas-ulife_yrs = '000' AND <fs_repp>-30_bapi1022_dep_areas-ulife_prds = '000' AND <fs_repp>-30_bapi1022_dep_areas-DEP_KEY IS INITIAL.
        ls_deparea-deactivate = abap_true.
        ls_depareax-deactivate = abap_true.
      ELSE.
        ls_val = <fs_repp>-30_bapi1022_cumval.
        ls_val-ord_dep = ls_val-ord_dep * -1.
        ls_val-spe_dep = ls_val-spe_dep * -1.
        APPEND ls_val TO lt_val.
      ENDIF.
      APPEND ls_deparea TO lt_deparea.
      APPEND ls_depareax TO lt_depareax.
    ENDIF.

    READ TABLE lt_ankb INTO ls_ankb WITH KEY afabe = '31'.
    IF ls_ankb-xafbe NE 'X'.
      ls_deparea = <fs_repp>-31_bapi1022_dep_areas.
      ls_depareax = <fs_reppx>-31_bapi1022_dep_areas.
      IF <fs_repp>-31_bapi1022_dep_areas-ulife_yrs = '000' AND <fs_repp>-31_bapi1022_dep_areas-ulife_prds = '000' AND <fs_repp>-31_bapi1022_dep_areas-DEP_KEY IS INITIAL.
        ls_deparea-deactivate = abap_true.
        ls_depareax-deactivate = abap_true.
      ELSE.
        ls_val = <fs_repp>-31_bapi1022_cumval.
        ls_val-ord_dep = ls_val-ord_dep * -1.
        ls_val-spe_dep = ls_val-spe_dep * -1.
        APPEND ls_val TO lt_val.
      ENDIF.
      APPEND ls_deparea TO lt_deparea.
      APPEND ls_depareax TO lt_depareax.
    ENDIF.


    CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
      EXPORTING
        key                 = ls_key
        testrun             = lv_TESTRUN
        generaldata         = ls_GENERALDATA
        generaldatax        = ls_GENERALDATAX
        inventory           = ls_INVENTORY
        inventoryx          = ls_INVENTORYX
        postinginformation  = ls_POSTINGINFORMATION
        postinginformationx = ls_POSTINGINFORMATIONX
        timedependentdata   = ls_TIMEDEPENDENTDATA
        timedependentdatax  = ls_TIMEDEPENDENTDATAX
        allocations         = ls_ALLOCATIONS
        allocationsx        = ls_ALLOCATIONSX
        origin              = ls_ORIGIN
        originx             = ls_ORIGINX
*       INVESTACCTASSIGNMNT =
*       INVESTACCTASSIGNMNTX       =
*       NETWORTHVALUATION   =
*       NETWORTHVALUATIONX  =
*       REALESTATE          =
*       REALESTATEX         =
*       INSURANCE           =
*       INSURANCEX          =
*       LEASING             =
*       LEASINGX            =
        glo_rus_gen         = ls_GLO_RUS_GEN
        glo_rus_genx        = ls_GLO_RUS_GENX
        glo_rus_ptx         = ls_GLO_RUS_PTX
        glo_rus_ptxx        = ls_GLO_RUS_PTXX
        glo_rus_ttx         = ls_GLO_RUS_TTX
        glo_rus_ttxx        = ls_GLO_RUS_TTXX
        glo_time_dep        = ls_GLO_TIME_DEP
        glo_rus_gentd       = ls_GLO_RUS_GENTD
        glo_rus_gentdx      = ls_GLO_RUS_GENTDX
        glo_rus_ptxtd       = ls_GLO_RUS_PTXTD
        glo_rus_ptxtdx      = ls_GLO_RUS_PTXTDX
        glo_rus_ttxtd       = ls_GLO_RUS_TTXTD
        glo_rus_ttxtdx      = ls_GLO_RUS_TTXTDX
      IMPORTING
        companycode         = lv_e_bukrs
        asset               = lv_e_anln1
        subnumber           = lv_e_anln2
        assetcreated        = lv_e_ref
      TABLES
        depreciationareas   = lt_deparea
        depreciationareasx  = lt_depareax
*       INVESTMENT_SUPPORT  =
*       EXTENSIONIN         =
        cumulatedvalues     = lt_val
*       POSTEDVALUES        =
*       TRANSACTIONS        =
*       PROPORTIONALVALUES  =
        return              = lt_return
*       POSTINGHEADERS      =
      .

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    READ TABLE lt_rep_v WITH KEY rownn = <fs_repp>-rownn ASSIGNING FIELD-SYMBOL(<fs_res>).
    IF <fs_res> IS ASSIGNED.
      <fs_res>-bukrs = lv_e_bukrs.
      <fs_res>-anln1 = lv_e_anln1.
      <fs_res>-anln2 = lv_e_anln2.
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>) INDEX 1.
      MOVE-CORRESPONDING <fs_ret> TO <fs_res>.
    ENDIF.
    CLEAR: lt_return, lt_return[].
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form conv_str_to_amount
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_FILE>_VALUE
*&      <-- <VAL>
*&---------------------------------------------------------------------*
FORM conv_str_to_amount  USING    input
                         CHANGING output.
  REPLACE ALL OCCURRENCES OF ',' IN input WITH '.'.
  CONDENSE input NO-GAPS.
  output = input.

ENDFORM.

FORM conv_str_to_dec  USING    input
                         CHANGING output.
  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = input
    IMPORTING
      num             = output
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
