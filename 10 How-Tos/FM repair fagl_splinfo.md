Repair tables `fagl_splinfo` and `fagl_splinfo_val` (like simulate splitting for posted docs):
``` abap
*** activate trace mode
    CALL FUNCTION 'G_TRACE_START'
      EXCEPTIONS
        trace_already_on = 1
        OTHERS           = 2.
    IF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*    CALL METHOD cl_fins_sif_services=>subseq_post_init.
    CALL METHOD cl_fins_sif_services=>subseq_post_set. " to avoid ML (and AA) relevat dump at repost process
*** submit FAGL_SUBSEQ_POSTING in trace mode
    CALL FUNCTION 'FAGL_SUBSEQ_POSTING'
      EXPORTING
        it_compcode_range   = r_bukrs[]
        it_fiscyear_range   = r_gjahr[]
        it_docnr_range      = r_belnr[]
        it_target_ledger    = lt_rldnr[]
        ib_process_splitter = abap_true
        ib_check_records    = abap_false
*** simulation!!
        ib_test             = abap_true
      EXCEPTIONS
        error_message       = 1
        OTHERS              = 2.
*** import GLU1 contents from memory
    IMPORT t_glu1 FROM MEMORY ID 'T_GLU1'.
*** import FAGL_SPLINFO/-_VAL data from memory
    CALL METHOD cl_fagl_oi_read=>get_splinfo_data_ext
      IMPORTING
        gt_out_splinfo     = t_splinfo
        gt_out_splinfo_val = t_val.
    READ TABLE t_splinfo ASSIGNING FIELD-SYMBOL(<check>) INDEX 1.
    IF <check> IS ASSIGNED.
      CHECK <check>-belnr = <bkpf>-belnr.
      UNASSIGN <check>.
    ENDIF.
    APPEND LINES OF t_splinfo TO lt_splinfo_sim.
    APPEND LINES OF t_val TO lt_val_sim.
*** free buffer
    CALL FUNCTION 'G_TRACE_STOP'
      EXCEPTIONS
        is_already_off = 1
        OTHERS         = 2.
    IF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
```
