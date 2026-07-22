**itab lines count:**

``` abap
DATA(strtab) = VALUE string_table( ( `aaa` ) ( `bbb` ) ( `ccc` ) ( `ddd` ) ( `eee` ) ).
DATA(lines1) = lines( strtab ). "5
```

**String length:**

``` abap
DATA(strlen1) = strlen( 'abc   ' ).  " -> 3
DATA(strlen2) = strlen( `abc   ` ).  " -> 6

"numofchar
len_c   = numofchar( 'abc   ' ). " -> 3
len_str = numofchar( `abc   ` ). " -> 3
``` 

**String concatenation:**

``` abap
DATA(str3) = str1 && ` ` && str2. "Concat with space
" or:
str3 = |{ str1 }| && ` ` && |{ str2 }|. "Concat with space
" or:
CONCATENATE str1 str2 INTO str3 SEPARATED BY ` `. "Concat with space
```

**String concatenation from itab:**

``` abap
DATA(stringtable) = VALUE string_table( ( `a` ) ( `b` ) ( `c` ) ). 
DATA(con1) = concat_lines_of( table = stringtable ). "abc
DATA(con2) = concat_lines_of( table = stringtable sep = ` ` ). "a b c

```

**Absolute value:**

```abap
DATA(abs2) = abs( -4 ). "4
```

**Value sign:**

```abap
"----------- sign: Evaluating the sign ----------- 
"-1 if negative, 0 if 0, 1 if positive
DATA(sign1) = sign( -789 ). "-1
```

**Rounding:**

```abap
"Rounding to decimal places
DATA(round1) = round( val = CONV decfloat34( '1.2374' ) dec = 2 ). "1.24
```
