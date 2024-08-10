*&---------------------------------------------------------------------*
*& Include          ZBC_USERS_ROLES_TOP
*&---------------------------------------------------------------------*
TABLES: AGR_USERS.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
  PARAMETERS p_dats TYPE dats DEFAULT sy-datum.
  SELECT-OPTIONS so_role FOR AGR_USERS-AGR_NAME.
  SELECT-OPTIONS so_user FOR AGR_USERS-UNAME.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
  PARAMETERS rb_tech RADIOBUTTON GROUP gr1.
  PARAMETERS rb_text RADIOBUTTON GROUP gr1 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl2.

**********************************************************************
DATA: fcat         TYPE lvc_t_fcat,
      hcat         TYPE lvc_s_fcat,
      glay         TYPE lvc_s_glay,
      gs_layout_fm TYPE lvc_s_layo.

DATA: w_tab         TYPE STANDARD TABLE OF abap_compdescr,
      w_tab_wa      TYPE abap_compdescr,
      w_typ         TYPE REF TO cl_abap_elemdescr,
      lt_tot_comp   TYPE cl_abap_structdescr=>component_table,
      lt_comp       TYPE cl_abap_structdescr=>component_table,
      la_comp       LIKE LINE OF lt_comp,
      lo_new_type   TYPE REF TO cl_abap_structdescr,
      lo_table_type TYPE REF TO cl_abap_tabledescr,
      w_tref        TYPE REF TO data,
      w_dy_line     TYPE REF TO data.

TYPES: BEGIN OF tt_mapp,
         col  TYPE abap_compname,
         role TYPE AGR_NAME,
       END OF tt_mapp.
DATA: it_mapp TYPE SORTED TABLE OF tt_mapp WITH UNIQUE key col,
      count TYPE string.

FIELD-SYMBOLS: <dyn_tab> TYPE ANY TABLE ,
               <dyn_wa>,
               <dyn_field>.