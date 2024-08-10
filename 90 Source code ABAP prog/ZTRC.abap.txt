*&---------------------------------------------------------------------*
*& Report ZTRC
*&---------------------------------------------------------------------*
*& Inspired by https://github.com/nghaonan/trchecker/blob/master/ztrc
*&---------------------------------------------------------------------*
REPORT ztrc.
*Data declaration
TABLES: e070.
TYPE-POOLS: icon.

*Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME.
  PARAMETERS p_cust AS CHECKBOX DEFAULT 'X'.
  PARAMETERS p_abap AS CHECKBOX DEFAULT 'X'.
  SELECT-OPTIONS: s_tr FOR e070-trkorr,
                  s_func FOR e070-TRFUNCTION no-DISPLAY,
                  s_usr FOR e070-AS4USER DEFAULT sy-uname,
                  s_date FOR e070-AS4DATE.
SELECTION-SCREEN END OF BLOCK bl1.
PARAMETERS: variant LIKE disvariant-variant.

DATA: IT_rep TYPE STANDARD TABLE OF ZTRC.

DATA: fcat         TYPE lvc_t_fcat,
      hcat         TYPE lvc_s_fcat,
      glay         TYPE lvc_s_glay,
      gs_layout_fm TYPE lvc_s_layo,
      g_save       TYPE c VALUE 'X',
      g_variant    TYPE disvariant,
      gx_variant   TYPE disvariant,
      g_exit       TYPE c.

**********************************************************************
INITIALIZATION.

AT SELECTION-SCREEN OUTPUT .
  PERFORM ssc_output.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  PERFORM f4_layout.

START-OF-SELECTION.
  PERFORM det_data.
  PERFORM show_alv.

*&---------------------------------------------------------------------*
*&      Form  F_GET_TR_LIST
*&---------------------------------------------------------------------*
*& Get a TR list
*----------------------------------------------------------------------*
FORM det_data.
  IF p_abap = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'K' ) TO s_func.
  ENDIF.
  IF p_cust = 'X'.
    APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'W' ) TO s_func.
  ENDIF.
  SELECT e070~trkorr
         e07t~as4text
         e070~AS4USER
         e070~TRFUNCTION
  FROM e070 AS e070
  INNER JOIN e07t AS e07t
  ON e070~trkorr = e07t~trkorr
  INTO CORRESPONDING FIELDS OF TABLE it_rep
  WHERE e070~trkorr IN s_tr
    AND TRFUNCTION IN s_func
    AND AS4USER IN s_usr
    AND AS4DATE IN s_date.
  SORT it_rep BY trkorr.

  LOOP AT it_rep ASSIGNING FIELD-SYMBOL(<fs_rep>).
    DATA: ls_settings TYPE  ctslg_settings,
          ls_cofile   TYPE ctslg_cofile,
          ls_system   TYPE ctslg_system.
    ls_settings-detailed_depiction = 'X'.
    CALL FUNCTION 'TR_READ_GLOBAL_INFO_OF_REQUEST'
      EXPORTING
        iv_trkorr   = <fs_rep>-trkorr
        is_settings = ls_settings
      IMPORTING
        es_cofile   = ls_cofile.
    <fs_rep>-DEV =  <fs_rep>-QAS =  <fs_rep>-PRD = ICON_INCOMPLETE.
    IF ls_cofile IS NOT INITIAL.
      LOOP AT LS_COFILE-SYSTEMS ASSIGNING FIELD-SYMBOL(<fs_sys>).
        CASE <fs_sys>-SYSTEMID.
          WHEN 'DEV'.
            SORT <FS_SYS>-STEPS by RC DESCENDING.
            LOOP AT <FS_SYS>-STEPS ASSIGNING FIELD-SYMBOL(<fs_steps>) WHERE stepid = '!'.
              CASE <fs_steps>-RC.
                WHEN 8. <fs_rep>-DEV = ICON_RED_LIGHT.
                WHEN 4. <fs_rep>-DEV = ICON_YELLOW_LIGHT.
                WHEN OTHERS. <fs_rep>-DEV = ICON_GREEN_LIGHT.
              ENDCASE.
            ENDLOOP.
          WHEN 'QAS'.
            SORT <FS_SYS>-STEPS by RC DESCENDING.
            LOOP AT <FS_SYS>-STEPS ASSIGNING <fs_steps> WHERE stepid = '!'.
              CASE <fs_steps>-RC.
                WHEN 8. <fs_rep>-QAS = ICON_RED_LIGHT.
                WHEN 4. <fs_rep>-QAS = ICON_YELLOW_LIGHT.
                WHEN OTHERS. <fs_rep>-QAS = ICON_GREEN_LIGHT.
              ENDCASE.
            ENDLOOP.
          WHEN 'PRD'.
            SORT <FS_SYS>-STEPS by RC DESCENDING.
            LOOP AT <FS_SYS>-STEPS ASSIGNING <fs_steps> WHERE stepid = '!'.
              CASE <fs_steps>-RC.
                WHEN 8. <fs_rep>-PRD = ICON_RED_LIGHT.
                WHEN 4. <fs_rep>-PRD = ICON_YELLOW_LIGHT.
                WHEN OTHERS. <fs_rep>-PRD = ICON_GREEN_LIGHT.
              ENDCASE.
            ENDLOOP.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ELSE.
       <fs_rep>-DEV =  <fs_rep>-QAS =  <fs_rep>-PRD = ICON_INCOMPLETE.
    ENDIF.
  ENDLOOP.
ENDFORM.




*&---------------------------------------------------------------------*
FORM SHOW_ALV .
**************************************
CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZTRC'
    CHANGING
      CT_FIELDCAT            = fcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
  ENDIF.

  LOOP AT fcat ASSIGNING FIELD-SYMBOL(<f>).
    CASE <f>-fieldname.
      WHEN 'DEV'. <f>-coltext = <f>-scrtext_l = <f>-scrtext_m = <f>-scrtext_s = 'DEV'.
      WHEN 'QAS'. <f>-coltext = <f>-scrtext_l = <f>-scrtext_m = <f>-scrtext_s = 'QAS'.
      WHEN 'PRD'. <f>-coltext = <f>-scrtext_l = <f>-scrtext_m = <f>-scrtext_s = 'PRD'.
    ENDCASE.
  ENDLOOP.

**************************************
  gs_layout_fm-cwidth_opt = 'X'.
  gs_layout_fm-zebra = 'X'.
  g_variant-report  = sy-repid.
  g_variant-variant = variant.


**************************************
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      is_layout_lvc            = gs_layout_fm
      I_CALLBACK_PROGRAM       = sy-cprog
      I_CALLBACK_PF_STATUS_SET = 'SETPF'
      I_CALLBACK_USER_COMMAND  = 'UCOMM'
      I_GRID_SETTINGS          = glay
      IT_FIELDCAT_LVC          = fcat
      i_save                   = g_save
      is_variant               = g_variant
    TABLES
      T_OUTTAB                 = it_rep
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
  FORM UCOMM USING r_ucomm LIKE sy-ucomm
     rs_selfield TYPE slis_selfield.
     rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN '&IC1'.
      DATA: ls_rep LIKE LINE OF it_rep.
      READ TABLE it_rep INTO ls_rep INDEX rs_selfield-tabindex.
      set parameter id 'KOR' field ls_rep-trkorr. "
      CALL TRANSACTION 'SE01' AND SKIP FIRST SCREEN.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM SETPF USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM ssc_output.
  CHECK variant IS INITIAL.
  gx_variant-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    variant = gx_variant-variant.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
FORM F4_layout.
  g_save = 'A'.
  CLEAR g_variant.
  g_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      variant = gx_variant-variant.
    ENDIF.
  ENDIF.
ENDFORM.