---
title: "Post FI document via BAPI_ACC_DOCUMENT_POST (with extension fields)"
keywords: BAPI_ACC_DOCUMENT_POST, BAPI_ACC_DOCUMENT_REV_POST, BADI_ACC_DOCUMENT, EXTENSION2, BAPIPAREX, ACCIT, BAPIACHE09, BUPLA, разноска документа, post document, сторно, reversal
status: draft
summary: "Заполнение header/GL/AP/currency, передача доп. полей через EXTENSION2 + BADI_ACC_DOCUMENT~CHANGE, разноска сторно"
---

# Post FI document via BAPI_ACC_DOCUMENT_POST (with extension fields)

Example how to post FI doc via BAPI (with additional fields at `extension` section)

```abap
   DATA:  ls_BAPI_header        TYPE bapiache09,
          it_BAPI_item_gl       TYPE STANDARD TABLE OF bapiacgl09,
          ls_BAPI_item_gl       TYPE bapiacgl09,
          it_BAPI_item_ap       TYPE STANDARD TABLE OF bapiacap09,
          ls_BAPI_item_ap       TYPE bapiacap09,
          it_BAPI_item_currency TYPE STANDARD TABLE OF bapiaccr09,
          ls_BAPI_item_currency TYPE bapiaccr09,
          it_extension2         TYPE STANDARD TABLE OF bapiparex,
          ls_extension2         LIKE LINE OF t_extension2,
          it_return             TYPE STANDARD TABLE OF bapiret2.
          
    CLEAR: ls_BAPI_header, it_BAPI_item_gl[], it_BAPI_item_ap[], it_BAPI_item_currency[], it_return[].
**********************************************************************
*    Header
    ls_BAPI_header-doc_date   = ls_header-bldat.
    ls_BAPI_header-doc_type   = ls_header-blart.
    ls_BAPI_header-comp_code  = ls_header-bukrs.
    ls_BAPI_header-pstng_date = ls_header-budat.
    ls_BAPI_header-ref_doc_no = ls_header-xblnr.
    ls_BAPI_header-header_txt = ls_header-doc_id.
    ls_BAPI_header-username = sy-uname.
    ls_BAPI_header-glo_ref1_hd = ls_header-msgid.
**********************************************************************
*   GL item
    ls_BAPI_item_gl-itemno_acc    = <fs_i>-msgit.
    ls_BAPI_item_gl-bus_area      = <fs_i>-gsber.
    ls_BAPI_item_gl-alloc_nmbr    = <fs_i>-zuonr.
    ls_BAPI_item_gl-gl_account    = <fs_i>-newko.
    ls_BAPI_item_gl-costcenter    = <fs_i>-kostl.
    ls_BAPI_item_gl-ITEM_TEXT = <fs_i>-sgtxt.
    ls_BAPI_item_gl-ref_key_1 = <fs_i>-newko. 
    ls_BAPI_item_gl-ref_key_2 = ls_header-stcd1. 
    ls_BAPI_item_gl-ref_key_3 = ls_header-stcd2. 
    APPEND:   ls_BAPI_item_gl TO it_BAPI_item_gl.
*   Amount GL
    ls_BAPI_item_currency-itemno_acc = <fs_i>-msgit.
    ls_BAPI_item_currency-amt_doccur = <fs_i>-wrbtr.
    ls_BAPI_item_currency-currency_iso  = ls_header-waers.
    APPEND:   ls_BAPI_item_currency TO it_BAPI_item_currency.
*   Extensions (additional fields)
    ls_extension2-structure  = 'BUPLA'.
    ls_extension2-valuepart1 = <fs_i>-msgit.
    ls_extension2-valuepart2 = <fs_i>-bupla.
    APPEND ls_extension2 TO it_extension2.
**********************************************************************     
*   AP item
    ls_BAPI_item_ap-itemno_acc   = <fs_i>-msgit.
    ls_BAPI_item_ap-vendor_no = me->Find_lifnr_by_cpf( <fs_i>-newko ).
    ls_BAPI_item_ap-pmnttrms = <fs_i>-zterm.
    ls_BAPI_item_ap-bus_area = <fs_i>-gsber.
    ls_BAPI_item_ap-pmnttrms = <fs_i>-zterm.
    ls_BAPI_item_ap-PYMT_METH = <fs_i>-ZLSCH.
    ls_BAPI_item_ap-bline_date = <fs_i>-zfbdt.
    ls_BAPI_item_ap-pmnt_block = <fs_i>-zlspr.
    ls_BAPI_item_ap-ITEM_TEXT = <fs_i>-sgtxt.
    ls_BAPI_item_ap-alloc_nmbr = <fs_i>-zuonr.
    ls_BAPI_item_ap-ref_key_1 = <fs_i>-newko. 
    ls_BAPI_item_ap-ref_key_2 = ls_header-stcd1. 
    ls_BAPI_item_ap-ref_key_3 = ls_header-stcd2. 
    APPEND:   ls_BAPI_item_ap TO it_BAPI_item_ap.
*   Amount AP
    ls_BAPI_item_currency-itemno_acc = <fs_i>-msgit.
    ls_BAPI_item_currency-amt_doccur = <fs_i>-wrbtr.
    ls_BAPI_item_currency-currency_iso  = ls_header-waers.
    APPEND:   ls_BAPI_item_currency TO it_BAPI_item_currency.
*   Extensions (additional fields)
    ls_extension2-structure  = 'BUPLA'.
    ls_extension2-valuepart1 = <fs_i>-msgit.
    ls_extension2-valuepart2 = <fs_i>-bupla.
    APPEND ls_extension2 TO it_extension2.
**********************************************************************   
*   Call BAPI to post doc
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = ls_BAPI_header
      IMPORTING
        obj_key        = OBJKEY
      TABLES
        accountgl      = it_BAPI_item_gl
        accountpayable = it_BAPI_item_ap
        currencyamount = it_BAPI_item_currency
        extension2     = it_extension2
        return         = it_return.
```

<aside>

 `ls_extension2-valuepart1` should be filled with doc item number!

</aside>

**To make extension works:**

1. Create implementation of BAdI `BADI_ACC_DOCUMENT` via `se18`/`se19`
2. Add custom logic to method `CHANGE`, like this:

```abap
METHOD if_ex_acc_document~change .
  DATA: wa_extension   TYPE bapiparex,
        wa_accit       TYPE accit,
        l_ref          TYPE REF TO data.
  FIELD-SYMBOLS: <l_struc> TYPE ANY,
                 <l_field> TYPE ANY.

  SORT c_extension2 BY structure.

  LOOP AT c_extension2 INTO wa_extension.
    AT NEW structure.
      CHECK wa_extension-structure IS NOT INITIAL.
      CREATE DATA l_ref TYPE (wa_extension-structure).
      ASSIGN l_ref->* TO <l_struc>.
      CHECK <l_struc> IS ASSIGNED.
    ENDAT.
    DATA: lv_posnr LIKE wa_accit-posnr.
    lv_posnr = WA_EXTENSION-VALUEPART1.
    CHECK lv_posnr IS NOT INITIAL.
    <l_struc> = wa_extension-valuepart2.
    READ TABLE c_accit WITH KEY posnr = lv_posnr INTO wa_accit.
    IF sy-subrc IS INITIAL.
      ASSIGN COMPONENT wa_extension-structure OF STRUCTURE wa_accit TO <l_field>.
      CHECK <l_field> IS ASSIGNED.
      <l_field> = <l_struc>.
      MODIFY c_accit FROM wa_accit INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
ENDMETHOD.                    "IF_EX_ACC_DOCUMENT~CHANGE
```

To post reversal:

```abap
DATA: rev TYPE bapiacrev.

SELECT SINGLE awtyp, awkey, awsys, awkey
      FROM bkpf
      INTO ( @rev-obj_type, @rev-obj_key, @rev-obj_sys , @rev-obj_key_r )
      WHERE belnr = @g_rep-pr_posted_doc
        AND bukrs = @g_rep-rbukrs
        AND gjahr = @g_rep-pr_posted_docj.

    rev-reason_rev = p_REASON_REV.
    rev-pstng_date = <fs_date>.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
      EXPORTING
        reversal = rev
        bus_act  = gv_GLVOR
      IMPORTING
        obj_type = l_type
        obj_key  = l_key
        obj_sys  = l_sys
      TABLES
        return   = it_return.
```