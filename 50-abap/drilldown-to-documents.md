# Drilldown to display…

FI document - `FB03`

```abap
SET PARAMETER ID 'BLN' FIELD <fs_belnr>.
SET PARAMETER ID 'BUK' FIELD <fbukrs>.
SET PARAMETER ID 'GJR' FIELD <fs_gjahr>.
CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
```

Material document - `MIGO`

```abap
CALL FUNCTION 'MIGO_DIALOG'
       EXPORTING
         I_ACTION                  = 'A04'
         I_REFDOC                  = 'R02'
         I_NOTREE                  = 'X'
         I_SKIP_FIRST_SCREEN       = 'X'
         I_MBLNR                   = <fs_MBLNR>
         I_MJAHR                   = <fs_MJAHR>
       EXCEPTIONS
         ILLEGAL_COMBINATION       = 1
         OTHERS                    = 2.
      IF sy-subrc <> 0.
      ENDIF.
```

Business Partner - `BP`

```abap
DATA: lv_partner TYPE bu_partner,
      lo_request TYPE REF TO cl_bupa_navigation_request,
      lo_options TYPE REF TO cl_bupa_dialog_joel_options.
      
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_bp>
        IMPORTING
          output = lv_partner.
          
      CREATE OBJECT lo_request.
      CALL METHOD lo_request->set_partner_number( lv_partner ).
      CALL METHOD lo_request->set_maintenance_id
        EXPORTING
          iv_value = lo_request->gc_maintenance_id_partner.
      CALL METHOD lo_request->set_bupa_activity
        EXPORTING
          iv_value = lo_request->gc_activity_display.
      CREATE OBJECT lo_options.
      CALL METHOD lo_options->set_locator_visible( space ).
      CALL METHOD cl_bupa_dialog_joel=>start_with_navigation
        EXPORTING
          iv_request              = lo_request
          iv_options              = lo_options
          iv_in_new_internal_mode = abap_false
          iv_in_new_window        = abap_false
        EXCEPTIONS
          already_started         = 1
          not_allowed             = 2
          OTHERS                  = 3.
```

Purchase Order - `ME23n`

```abap
SET PARAMETER ID 'BES' FIELD <fs_val>.
CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
```

Sales Order - `VA03`

```abap

SET PARAMETER ID 'AUN' FIELD <fs_val>.
CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
```

Outbound delivery - `VL03n`

```abap
SET PARAMETER ID 'VL' FIELD <fs_any>.
CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
```

Inbound Delivery - `VL33n`

```abap
SET PARAMETER ID 'VLM' FIELD <fs_val>.
CALL TRANSACTION 'VL33N' AND SKIP FIRST SCREEN.
```

Fixed Asset - `AW01n`

```abap
SET PARAMETER ID 'BUK' FIELD <fs_bukrs>.
SET PARAMETER ID 'AN1' FIELD <fs_anln1>.
SET PARAMETER ID 'AN2' FIELD <fs_anln2>.
CALL TRANSACTION 'AW01n'.
```

GL account/Company code level- `FS00`

```abap
SET PARAMETER ID 'SAK' FIELD <fs_saknr>.
SET PARAMETER ID 'BUK' FIELD <fs_bukrs>.
CALL TRANSACTION 'FS00'.
```

GL account - `FSP0`

```abap
SET PARAMETER ID 'SAK' FIELD <fs_saknr>.
SET PARAMETER ID 'KPL' FIELD <fs_ktopl>.
CALL TRANSACTION 'FSP0'.
```

ABD document - `WZR3`

```abap
SET PARAMETER ID 'WLZ' FIELD <fs_val>.
CALL TRANSACTION 'WZR3' AND SKIP FIRST SCREEN.
```

Nota Fiscal (Brazil specific)

```abap
      DATA gf_nfobjn TYPE j_1binterf-nfobjn.
      CALL FUNCTION 'J_1B_NF_DOC_READ_INTO_OBJECT'
        EXPORTING
          doc_number         = <fs_nf>
        IMPORTING
          obj_number         = gf_nfobjn
        EXCEPTIONS
          document_not_found = 1
          docum_lock         = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
      ENDIF.
      
      CALL FUNCTION 'J_1B_NF_OBJECT_DISPLAY'
        EXPORTING
          obj_number         = gf_nfobjn
          writer             = abap_true
        EXCEPTIONS
          object_not_found   = 1
          scr_ctrl_not_found = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
      ENDIF.
```