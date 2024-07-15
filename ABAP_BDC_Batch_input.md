

'''abap
*   Macro to fill the necessary BDC data
FIELD-SYMBOLS:
      <ls_bdc> TYPE bdcdata.
DEFINE add_bdc.
  APPEND INITIAL LINE TO lt_bdc ASSIGNING <ls_bdc>.
  <ls_bdc>-fnam = &1.
  <ls_bdc>-fval = &2.
  <ls_bdc>-program  = &3.
  <ls_bdc>-dynpro   = &4.
  <ls_bdc>-dynbegin = &5.
END-OF-DEFINITION.
'''
