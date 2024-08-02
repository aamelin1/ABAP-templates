# Working with dates in ABAP

How to get a last day of month:
```abap
CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
  EXPORTING
    day_in            = so_datum-low
  IMPORTING
    last_day_of_month = <res>
  EXCEPTIONS
    day_in_no_date    = 1
    OTHERS            = 2.
```

Convert date to internal/external format:
``` abap
DATA : lw_date_ext TYPE char10, 
       lw_date TYPE datum. 

CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL' 
  EXPORTING 
    date_external = lw_date_ext " ==> 10.10.2017 
  IMPORTING 
	date_internal = lw_date " ==> 20171010 
  EXCEPTIONS 
	date_external_is_invalid = 1.
```

``` abap
CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL' 
  EXPORTING  
	DATE_INTERNAL = SY-DATUM "internal date formatting  
  IMPORTING  
	DATE_EXTERNAL =  "external date formatting  
  EXCEPTIONS  
	DATE_INTERNAL_IS_INVALID = 1
```


Inline conversion:

``` abap
DATA(d) = |The date is { cl_abap_context_info=>get_system_date( ) DATE = USER }.|. 
"The date is 15.01.2024.
```

> **💡 Note**
> Parameter "DATE =" may be: USER, RAW, ISO, ENVIRONMENT


Same for the time:
``` abap
DATA(tm) = |The time is { cl_abap_context_info=>get_system_time( ) TIME = ISO }.|. 
"The time is 14:37:24.
```
And for timestamp:
``` abap
DATA(ts) = |{ utclong_current( ) TIMESTAMP = SPACE }|. 
"2024-01-01 14:39:50.4069170
```
