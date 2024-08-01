
Create range and fill data:
``` abap
TYPES: tt_BUKRS   TYPE RANGE OF bukrs.
DATA:  rg_BUKRS   TYPE tt_BUKRS,
APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'XXXX' ) TO rg_BUKRS.
```

Same, but inline:
``` abap
DATA(so_xxxx) = VALUE rsdsselopt_t( sign = 'I' option = 'BT' ( low = 'XXX' high = 'YYY' ).
```

To fill select-option (at INITIALIZATION event):
``` abap
APPEND VALUE #( sign = 'I' option = 'EQ'  low = 'XXX' high = 'YYY') TO so_....
```
