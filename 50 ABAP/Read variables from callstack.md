# Read variables from callstack

**Read variables from callstack**

Simple way:

```abap
CONSTANTS: lco_migo_vgart_path TYPE string 
						VALUE '(SAPLMIGO)LCL_MIGO_GLOBALS=>KERNEL->S_CONTROL-VGART'.
FIELD-SYMBOLS: <migo_vgart> TYPE any.
DATA: lv_vgart TYPE vgart.

ASSIGN (lco_migo_vgart_path) to <migo_vgart>.
IF <migo_vgart> is assigned.
    lv_vgart = <migo_vgart>.
ENDIF.
```

To get current callstack use class `xco_cp=>current->call_stack->full( )` 

In the example below, a line pattern is created (method that starts with a specific pattern). The extracting should go up to the last occurrence of this pattern. It is started at position 1.

```abap
DATA(line_pattern) = xco_cp_call_stack=>line_pattern->method(
  )->where_class_name_starts_with( 'CL_REST' ).
DATA(extracted_call_stack_as_text) = call_stack->from->position( 1
  )->to->last_occurrence_of( line_pattern )->as_text( format ).
```