For example, a numeric data object can be assigned the result of a
calculation:


> **💡 Note**<br>
> For checking out the code snippets in [ABAP Cloud](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm?file=abenabap_cloud_glosry.htm), you can use the interface `if_oo_adt_classrun` in a class by implementing the method `if_oo_adt_classrun~main`.

``` abap
DATA num TYPE i.

num = 2 * 3 * 5 * 53 * 2267.

cl_demo_output=>display( num ).
```

After this assignment, the data object `num` contains the
calculated value 3604530, which is also displayed accordingly with a
type-compliant output as, for example,
`cl_demo_output=>display`. And of course the same can be seen
in the display of the variable in the ABAP Debugger when setting a
breakpoint at the last statement.
