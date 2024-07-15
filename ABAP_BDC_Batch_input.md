
Macro
``` abap
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
```
Call transaction
``` abap
DATA: lt_bdc TYPE TABLE OF bdcdata,
      it_msg type standard table of bdcmsgcoll.
      CLEAR: lt_bdc[], it_msg, it_msg[].
      
      add_bdc: ' ' ' '  'saplaist' '0100' 'x',
               'bdc_okcode'  '=entedel' '' '' '',
               'anla-anln1'  <fs_anla>-anln1 '' '' ''.
*   Call transaction with the batch input data
      CALL TRANSACTION 'XXXX'
        USING lt_bdc
        MODE 'E'
        UPDATE 'S'
        MESSAGES INTO it_msg.
      COMMIT WORK AND WAIT.
```
