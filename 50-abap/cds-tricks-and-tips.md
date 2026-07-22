
Session variables:
```abap
$session.user             // current_user,
$session.client           // current_client,
$session.system_language  // current_language,
$session.system_date      // current_date
```

Concatenate field values via **CONCAT**. By default, you can only concatenate two fields at a time. To concatenate more than two fields, you need to perform concatenation multiple times.
```abap
concat(concat(vkorg, spart), 'additional_text') as concatenated_field
```

The **LTRIM** function removes leading spaces or specific leading characters from a string.
```abap
ltrim(vkorg, '0') as vkorg,
```

The **RTRIM** function removes trailing spaces or specific trailing characters from a string.
```abap
rtrim(vkorg, '0') as vkorg_trimmed
```

You can combine both **LTRIM** and **RTRIM** functions to clean up a string by removing leading and trailing characters.
```abap
ltrim(rtrim(vbeln, '0'), '0') as cleaned_vbeln
```

The **INSTR** function is used to find the position of a substring within a string.
```abap
instr('Text to search', 'to') as position_of_substring
```

The **LEFT** function extracts a specified number of characters from the beginning of a string.
```abap
left('SAP ABAP HANA', 3) as left_substring,
```

The **RPAD** (Right Pad) function pads a string on the right side with a specified character until the string reaches a desired length.
```abap
rpad('ABAP team', 10, '0') as padded_string
```

The **REPLACE** function replaces all occurrences of a specified substring within a string with another substring
```abap
replace('SAP xxx', 'xxx', 'CDS') as updated_name
```

The **SUBSTRING** function extracts a specific portion of a string, starting from a given position and optionally for a specified length.
```abap
 substring(erdat, 5, 2) as month,
```
