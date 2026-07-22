*&---------------------------------------------------------------------*
*& Report ZR2R_AA_MASS_RET
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr2r_aa_mass_ret.

PARAMETERS p_file TYPE localfile OBLIGATORY.

DATA : file    TYPE rlgrap-filename,
       lt_file TYPE TABLE OF alsmex_tabline WITH HEADER LINE.

DATA: fcat         TYPE lvc_t_fcat,
      hcat         TYPE lvc_s_fcat,
      glay         TYPE lvc_s_glay,
      gs_layout_fm TYPE lvc_s_layo,
      events       TYPE slis_t_event,
      event        TYPE slis_alv_event.
DATA: lt_rep TYPE STANDARD TABLE OF zsr2r_aa_mass_ret.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      static        = 'X'
    CHANGING
      file_name     = p_file
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


START-OF-SELECTION.
  PERFORM get_file TABLES lt_file..
  PERFORM show_alv.
*&---------------------------------------------------------------------*
*& Form get_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_file TABLES p_lt_file STRUCTURE alsmex_tabline..

  CLEAR p_lt_file[].
  file = p_file.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = file
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '7'
      i_end_row               = '1000'
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
  DATA: ls_rep LIKE LINE OF lt_rep.
  LOOP AT p_lt_file ASSIGNING FIELD-SYMBOL(<fs_f>).
    CASE <fs_f>-col.
      WHEN 1. ls_rep-bukrs = <fs_f>-value.
      WHEN 2.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_f>-value
          IMPORTING
            output = ls_rep-EQUIPMENT.
      WHEN 3.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_f>-value
          IMPORTING
            output = ls_rep-anln1.

      WHEN 4.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_f>-value
          IMPORTING
            output = ls_rep-anln2.
      WHEN 5. ls_rep-bwasl = <fs_f>-value.
      WHEN 6.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external            = <fs_f>-value
            accept_initial_date      = abap_true
          IMPORTING
            date_internal            = ls_rep-budat
          EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.
      WHEN 7. ls_rep-anbtr = <fs_f>-value.
      WHEN 8. ls_rep-prozs = <fs_f>-value.
      WHEN OTHERS.
    ENDCASE.
    AT END OF row.
      SELECT SINGLE anlkl, txt50
        FROM anla
        WHERE bukrs = @ls_rep-bukrs
          AND anln1 = @ls_rep-anln1
          AND anln2 = @ls_rep-anln2
        INTO (@ls_rep-anlkl, @ls_rep-txt50).
      IF sy-subrc <> 0.
        ls_rep-txt50 = 'ОС не найден!'.
      ENDIF.
      IF ls_rep-EQUIPMENT IS NOT INITIAL.
        SELECT SINGLE EQKTX
          FROM EQKT
          WHERE EQUNR = @ls_rep-EQUIPMENT
            AND SPRAS = @sy-langu
          INTO @ls_rep-EQKTX.
        IF sy-subrc <> 0.
          ls_rep-EQKTX = 'ЕО не найдена!'.
        ENDIF.
      ENDIF.
      APPEND ls_rep TO lt_rep.
      CLEAR ls_rep.
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
      i_structure_name       = 'ZSR2R_AA_MASS_RET'
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
  .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc            = gs_layout_fm
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'SETPF'
      i_callback_user_command  = 'UCOMM'
      i_grid_settings          = glay
      it_fieldcat_lvc          = fcat
    TABLES
      t_outtab                 = lt_rep
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
      DATA: ls_rep LIKE LINE OF lt_rep.
      READ TABLE lt_rep INTO ls_rep INDEX rs_selfield-tabindex.
      CHECK ls_rep-anln1 IS NOT INITIAL.
      SET PARAMETER ID 'BUK' FIELD ls_rep-bukrs.
      SET PARAMETER ID 'AN1' FIELD ls_rep-anln1.
      SET PARAMETER ID 'AN2' FIELD ls_rep-anln2.
      CALL TRANSACTION 'AW01N'.
    WHEN 'POST'.
      PERFORM call_bapi USING abap_false.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_bapi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ABAP_TRUE
*&---------------------------------------------------------------------*
FORM call_bapi  USING    p_test.
  LOOP AT lt_rep ASSIGNING FIELD-SYMBOL(<fs_rep>).
    "Сформируем документ выбытия ОС
    DATA: ls_post TYPE bapifapo_gen_info.
    ls_post-doc_date = <fs_rep>-budat.
    ls_post-pstng_date = <fs_rep>-budat.
    ls_post-trans_date = <fs_rep>-budat.
    ls_post-comp_code = <fs_rep>-bukrs.
    ls_post-assetmaino = <fs_rep>-anln1.
    ls_post-ASSETSUBNO = <fs_rep>-anln2.
    ls_post-ASSETTRTYP = <fs_rep>-bwasl.
    DATA: ls_ret TYPE bapifapo_ret.
    ls_ret-compl_ret = abap_false.
    ls_ret-amount = <fs_rep>-anbtr.
    ls_ret-currency = 'RUB'.
    ls_ret-perc_rate = <fs_rep>-prozs.
    ls_ret-valuedate = <fs_rep>-budat.

    DATA: ls_doc    TYPE bapifapo_doc_ref,
          ls_return TYPE bapiret2.
    CALL FUNCTION 'BAPI_ASSET_RETIREMENT_POST'
      EXPORTING
        generalpostingdata = ls_post
        retirementdata     = ls_ret
      IMPORTING
        documentreference  = ls_doc
        return             = ls_return.
    <fs_rep>-docno = ls_doc-obj_key.

    CLEAR: ls_post, ls_ret, ls_doc, ls_return.
    "Удалим ссылку ЕО-ОС
    DATA: ls_gen TYPE BAPI_ITOB,
          ls_genx TYPE BAPI_ITOBX,
          ls_spec TYPE BAPI_ITOB_EQ_ONLY,
          ls_specx TYPE BAPI_ITOB_EQ_ONLYX,
          ls_ret2 TYPE BAPIRET2.
    CLEAR: ls_gen-ASSET_NO, ls_gen-SUB_NUMBER.
    ls_genx-ASSET_NO = ls_genx-SUB_NUMBER  = 'X'.
    CALL FUNCTION 'BAPI_EQUI_CHANGE'
      EXPORTING
        equipment               = <fs_rep>-EQUIPMENT
        data_general            = ls_gen
        data_generalx           = ls_genx
        data_specific           = ls_spec
        data_specificx          = ls_specx
*       DATA_FLEET              =
*       DATA_FLEETX             =
*       VALID_DATE              = SY-DATUM
*       VALID_TIME              = SY-UZEIT
     IMPORTING
*       DATA_GENERAL_EXP        =
*       DATA_SPECIFIC_EXP       =
*       DATA_FLEET_EXP          =
       RETURN                  = ls_ret2.
    <fs_rep>-return2 = ls_ret2-message.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    CLEAR: ls_gen, ls_genx, ls_spec, ls_specx, ls_ret2.
  ENDLOOP.
ENDFORM.
