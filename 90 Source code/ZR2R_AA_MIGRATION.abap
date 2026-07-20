*&---------------------------------------------------------------------*
*& Report ZR2R_AA_MIGRATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZR2R_AA_MIGRATION.
PARAMETERS p_file TYPE localfile OBLIGATORY.

DATA : file     TYPE rlgrap-filename,
       lt_file  TYPE TABLE OF alsmex_tabline WITH HEADER LINE,
       lt_cust  TYPE STANDARD TABLE OF ZVR2R_AA_MIGRCUS,
       lt_rep   TYPE STANDARD TABLE OF ZSR2R_MIGRATION_MAP,
       lt_repx  TYPE STANDARD TABLE OF ZSR2R_MIGRATION_MAPX.

DATA: fcat TYPE lvc_t_fcat,
      hcat TYPE lvc_s_fcat,
      glay TYPE lvc_s_glay,
      gs_layout_fm   TYPE lvc_s_layo,
      events TYPE slis_t_event,
      event TYPE slis_alv_event.

DATA: lt_rep_v TYPE STANDARD TABLE OF ZSR2R_MIGRATION_ALV.

**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
 EXPORTING
   static              = 'X'
  CHANGING
   file_name           = p_file
 EXCEPTIONS
   mask_too_long       = 1
   OTHERS              = 2.
IF sy-subrc <> 0.
 MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.


**********************************************************************
START-OF-SELECTION.
PERFORM get_cust TABLES lt_cust.
PERFORM get_file TABLES lt_file.
PERFORM prep_alv TABLES lt_cust lt_file lt_rep lt_repx.
PERFORM show_alv.


INCLUDE ZR2R_AA_MIGRATION_f01.
