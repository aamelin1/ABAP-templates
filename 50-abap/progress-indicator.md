---
title: "Progress indicator (CL_PROGRESS_INDICATOR)"
keywords: CL_PROGRESS_INDICATOR, progress_indicate, индикатор прогресса, progress bar, статусная строка
status: draft
---

# Progress indicator (CL_PROGRESS_INDICATOR)

Show loop iterations as a message, like a progress bar

``` abap
cl_progress_indicator=>progress_indicate(
        i_text = |Processing: { sy-tabix }/{ lines( it_... ) }|
        i_output_immediately = abap_true ).
```
or:
``` abap
  DATA(lv_lines_count) = lines( it_... ).
  LOOP AT it_...
    lv_current_index = sy-tabix.
    cl_progress_indicator=>progress_indicate( 
      EXPORTING 
        i_text       = 'Processing...'
        i_processed  = lv_current_index
        i_total      = lv_lines_count
        i_output_immediately   = ' ' ).
  ENDLOOP.
```
