*&---------------------------------------------------------------------*
*& Include          ZBC_USERS_ROLES_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_ALL_Y_ROLES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ALL_Y_ROLES .
  DATA: IT_YROLES TYPE STANDARD TABLE OF AGR_USERS.
  SELECT DISTINCT AGR_NAME
    FROM AGR_USERS
    INTO CORRESPONDING FIELDS OF TABLE IT_YROLES
    WHERE AGR_NAME in so_role
      AND FROM_DAT <= p_dats
      AND TO_DAT >= p_dats
      AND uname in so_user.

  count = lines( IT_YROLES ).
  cl_progress_indicator=>progress_indicate(
    EXPORTING
      i_text       = 'Reading data, total:' && count
      i_output_immediately   = 'X' ).

  CLEAR w_tab_wa.
  w_tab_wa-name      = 'UNAME'.
  w_tab_wa-type_kind = 'C'.
  w_tab_wa-length    = '12'.
  APPEND w_tab_wa TO w_tab.
  CLEAR w_tab_wa.
  w_tab_wa-name      = 'FULLNAME'.
  w_tab_wa-type_kind = 'C'.
  w_tab_wa-length    = '80'.
  APPEND w_tab_wa TO w_tab.
  CLEAR w_tab_wa.
  w_tab_wa-name      = 'DEPARTMENT'.
  w_tab_wa-type_kind = 'C'.
  w_tab_wa-length    = '40'.
  APPEND w_tab_wa TO w_tab.
  CLEAR w_tab_wa.
  w_tab_wa-name      = 'FUNCTION'.
  w_tab_wa-type_kind = 'C'.
  w_tab_wa-length    = '40'.
  APPEND w_tab_wa TO w_tab.


  DATA: i TYPE i VALUE 1.
  LOOP AT IT_YROLES ASSIGNING FIELD-SYMBOL(<fs_yrole>).
    CLEAR w_tab_wa.
*    w_tab_wa-name      = <fs_yrole>-AGR_NAME.
    w_tab_wa-name = 'T_'&& i.
    i += 1.
    w_tab_wa-type_kind = 'C'.
    w_tab_wa-length    = '1'.
    APPEND w_tab_wa TO w_tab.
    DATA: ls_mapp Like LINE OF it_mapp.
    ls_mapp-role = <fs_yrole>-AGR_NAME.
    ls_mapp-col = w_tab_wa-name.
    INSERT ls_mapp into TABLE it_mapp.
  ENDLOOP.

  LOOP AT w_tab INTO w_tab_wa.
    CASE w_tab_wa-type_kind.
      WHEN 'STRING'.  w_typ = cl_abap_elemdescr=>get_string( ).
      WHEN 'XSTRING'. w_typ = cl_abap_elemdescr=>get_xstring( ).
      WHEN 'I'.       w_typ = cl_abap_elemdescr=>get_i( ).
      WHEN 'F'.       w_typ = cl_abap_elemdescr=>get_f( ).
      WHEN 'D'.       w_typ = cl_abap_elemdescr=>get_d( ).
      WHEN 'T'.       w_typ = cl_abap_elemdescr=>get_t(  ).
      WHEN 'C'.       w_typ = cl_abap_elemdescr=>get_c( p_length = w_tab_wa-length ).
      WHEN 'N'.       w_typ = cl_abap_elemdescr=>get_n( p_length = w_tab_wa-length ).
      WHEN 'X'.       w_typ = cl_abap_elemdescr=>get_x( p_length = w_tab_wa-length ).
      WHEN 'P'.       w_typ = cl_abap_elemdescr=>get_p( p_length = w_tab_wa-length p_decimals = w_tab_wa-decimals ).
    ENDCASE.
    CLEAR la_comp.
    la_comp-type = w_typ.
    la_comp-name = w_tab_wa-name.
    APPEND la_comp TO lt_tot_comp.
  ENDLOOP.
  lo_new_type = cl_abap_structdescr=>create( lt_tot_comp ).
  data: key TYPE abap_keydescr_tab,
        ls_key like LINE OF key .
  ls_key-name = 'UNAME'.
  APPEND ls_key to key.
  lo_table_type = cl_abap_tabledescr=>create( p_line_type = lo_new_type
              p_table_kind = cl_abap_tabledescr=>tablekind_sorted
              p_unique     = abap_true
              p_key        = key ).
  CREATE DATA w_tref TYPE HANDLE lo_table_type.
  ASSIGN w_tref->* TO <dyn_tab>.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  DATA: IT_ALL TYPE sorted TABLE OF AGR_USERS WITH NON-UNIQUE KEY uname.
  SELECT *
    FROM AGR_USERS
    INTO CORRESPONDING FIELDS OF TABLE IT_ALL
    WHERE AGR_NAME in so_role
      AND FROM_DAT <= p_dats
      AND TO_DAT >= p_dats
      AND uname in so_user.
  DELETE ADJACENT DUPLICATES FROM it_all COMPARING uname AGR_NAME.

  count = lines( IT_ALL ).
  cl_progress_indicator=>progress_indicate(
    EXPORTING
      i_text       = 'Reading data, total:' && count
      i_output_immediately   = 'X' ).

  DATA field_key(100).
  field_key = 'UNAME'.
  LOOP AT it_all ASSIGNING FIELD-SYMBOL(<fs_all>).
     DATA(lv_idx3) = sy-tabix.
     cl_progress_indicator=>progress_indicate(
      EXPORTING
        i_text       = 'Calculating...' && lv_idx3 && '/' && count
        i_processed  = lv_idx3
        i_total      = lines( IT_ALL )
        i_output_immediately   = ' ' ).

    READ TABLE <dyn_tab> ASSIGNING FIELD-SYMBOL(<wa>) WITH TABLE KEY (field_key) = <fs_all>-uname.
    IF sy-subrc <> 0.
      DATA l_dyn TYPE REF TO DATA.
      CREATE DATA l_dyn LIKE LINE OF <dyn_tab>.
      ASSIGN l_dyn->* TO FIELD-SYMBOL(<fsn_dyn>).
      ASSIGN COMPONENT 'UNAME' OF STRUCTURE <fsn_dyn> TO FIELD-SYMBOL(<fs_name>).
      <fs_name> = <fs_all>-uname.
**********************************************************************
      DATA: ls_address TYPE BAPIADDR3,
            lt_ret     TYPE STANDARD TABLE OF BAPIRET2.
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          USERNAME      = <fs_all>-uname
          CACHE_RESULTS = 'X'
        IMPORTING
          ADDRESS       = ls_address
        TABLES
          RETURN        = lt_ret.
      ASSIGN COMPONENT 'FULLNAME' OF STRUCTURE <fsn_dyn> TO <fs_name>.
      <fs_name> = ls_address-FULLNAME.
      ASSIGN COMPONENT 'DEPARTMENT' OF STRUCTURE <fsn_dyn> TO <fs_name>.
      <fs_name> = ls_address-DEPARTMENT.
      ASSIGN COMPONENT 'FUNCTION' OF STRUCTURE <fsn_dyn> TO <fs_name>.
      <fs_name> = ls_address-FUNCTION.
**********************************************************************
      READ TABLE it_mapp ASSIGNING FIELD-SYMBOL(<fs_mapp>) WITH KEY role = <fs_all>-AGR_NAME.
      ASSIGN COMPONENT <fs_mapp>-col OF STRUCTURE <fsn_dyn> TO FIELD-SYMBOL(<fs_value>).
      <fs_value> = abap_true.
      INSERT <fsn_dyn> into table <dyn_tab>.
      UNASSIGN: <wa>, <fs_mapp>.
    ELSE.
      READ TABLE it_mapp ASSIGNING <fs_mapp> WITH KEY role = <fs_all>-AGR_NAME.
      ASSIGN COMPONENT <fs_mapp>-col OF STRUCTURE <wa> TO FIELD-SYMBOL(<fs_value_m>).
      <fs_value_m> = abap_true.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREP_ALV .
   cl_progress_indicator=>progress_indicate(
    EXPORTING
      i_text       = 'Preparing ALV'
      i_output_immediately   = 'X' ).
  LOOP AT w_tab INTO w_tab_wa.
    DATA: ls_fcat TYPE LVC_S_FCAT.
    CLEAR ls_fcat.
    ls_fcat-FIELDNAME = w_tab_wa-name.
    ls_fcat-DATATYPE = w_tab_wa-type_kind.
    ls_fcat-INTLEN = w_tab_wa-length.
    CASE w_tab_wa-name.
      WHEN 'FULLNAME' .
        ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = 'Name'.
        ls_fcat-OUTPUTLEN = 15.
      WHEN 'DEPARTMENT' .
        ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = 'Department'.
        ls_fcat-OUTPUTLEN = 21.
      WHEN 'FUNCTION'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = 'UserFunc'.
        ls_fcat-OUTPUTLEN = 13.
      WHEN 'UNAME'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = 'Login'.
        ls_fcat-OUTPUTLEN = 15.
        ls_fcat-key = abap_true.
      WHEN OTHERS.
        ls_fcat-CHECKBOX = abap_true.
        CASE 'X'.
          WHEN rb_tech.
            READ TABLE it_mapp ASSIGNING FIELD-SYMBOL(<fs_mapp>) WITH KEY col = w_tab_wa-name.
            ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = <fs_mapp>-role.
          WHEN rb_text.
            DATA: lv_text TYPE AGR_TEXTS-TEXT.
            READ TABLE it_mapp ASSIGNING <fs_mapp> WITH KEY col = w_tab_wa-name.
            SELECT SINGLE TEXT
              FROM AGR_TEXTS
              INTO lv_text
              WHERE AGR_NAME = <fs_mapp>-role
                AND SPRAS = sy-langu.
            IF lv_text IS NOT INITIAL.
              ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = lv_text.
              CLEAR lv_text.
            ELSE.
              READ TABLE it_mapp ASSIGNING <fs_mapp> WITH KEY col = w_tab_wa-name.
              ls_fcat-scrtext_s = ls_fcat-scrtext_m = ls_fcat-scrtext_l = ls_fcat-coltext = <fs_mapp>-role.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
    ENDCASE.
    APPEND ls_fcat to fcat.
  ENDLOOP.
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
*  gs_layout_fm-cwidth_opt = 'X'.
  gs_layout_fm-zebra = 'X'.

  FIELD-SYMBOLS <rep> TYPE STANDARD TABLE.
  lo_table_type = cl_abap_tabledescr=>create( p_line_type = lo_new_type ).
  CREATE DATA w_tref TYPE HANDLE lo_table_type.
  ASSIGN w_tref->* TO <rep>.
  <rep> = <dyn_tab>.
  FREE <dyn_tab>.
  UNASSIGN <dyn_tab>.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc      = gs_layout_fm
      i_callback_program = sy-cprog
*     i_callback_pf_status_set = 'SETPF'
*     i_callback_user_command  = 'UCOMM'
      i_grid_settings    = glay
      it_fieldcat_lvc    = fcat
    TABLES
      t_outtab           = <rep>
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.