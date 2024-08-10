*&---------------------------------------------------------------------*
*& Report ZBC_USERS_ROLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBC_USERS_ROLES.
INCLUDE ZBC_USERS_ROLES_TOP.
INCLUDE ZBC_USERS_ROLES_F01.

INITIALIZATION.

START-OF-SELECTION.
  PERFORM get_all_Y_roles.
  PERFORM get_data.
  PERFORM prep_alv.
  PERFORM show_alv.