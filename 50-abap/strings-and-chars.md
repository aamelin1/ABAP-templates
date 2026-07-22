# Strings and chars

**String length:**

```abap
DATA(strlen1) = strlen( 'abc   ' ).  " -> 3
DATA(strlen2) = strlen( `abc   ` ).  " -> 6
len_c         = numofchar( 'abc   ' ). " -> 3
len_str       = numofchar( `abc   ` ). " -> 3
```

**String concatenation:**

```abap
DATA(str3) = str1 && ` ` && str2. "Concat with space
str3 = |{ str1 }| && ` ` && |{ str2 }|. "Concat with space
CONCATENATE str1 str2 INTO str3 SEPARATED BY ` `. "Concat with space
```

**String concatenation from itab:**

```abap
DATA(stringtable) = VALUE string_table( ( `a` ) ( `b` ) ( `c` ) ).
DATA(con1) = concat_lines_of( table = stringtable ). "abc
DATA(con2) = concat_lines_of( table = stringtable sep = ` ` ). "a b c

```