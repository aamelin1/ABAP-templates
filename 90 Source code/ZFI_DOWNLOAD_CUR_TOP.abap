*&---------------------------------------------------------------------*
*&  Include           ZFI_DOWNLOAD_CUR_TOP
*&---------------------------------------------------------------------*
tables: tcurr.

types: begin of l_cur,
        numcode  type string,
        charcode type string,
        nominal  type string,
        name     type string,
        value    type string,
        end of l_cur.

data: wa_tcur TYPE TABLE OF l_cur WITH HEADER LINE.
