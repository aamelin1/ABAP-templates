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
