# FI. Validations & substitutions

- `GGB1` - Substitution Maintenance
- `GGB0` - Validation Maintenance
- `OBBH` - Assign Substitution to Company code and activation status
- `GCX2` - Assign program to Substitution/Validation
- Program `RGUGBR00` - regenerate Substitution and Validation
- Table `GB01` + view `VWTYGB01` - available fields to be substitute
- `GS01`, `GS02`, `GS03` - FI sets

SAP provide two programs that should be used to implement these user exits. These are `RGGBS000` and `RGGBR000` (for substitutions and rules respectively). The relevant program should be copied to a Z version of the program, `ZRGGBR000` for example.

To add own form, you need to specify form name as:

```
   EXITS-NAME  = 'U100'.
   EXITS-PARAM = C_EXIT_PARAM_NONE.  "Complete data used in exit.
   EXITS-TITLE = TEXT-101.           "text
   APPEND EXITS.
```

| EXITS-PARAM | Comments |
| --- | --- |
| C_EXIT_PARAM_NONE | This constant means that no parameters are defined for this user exit. In truth, there is one parameter defined and that is a boolean flag that is used to specify whether there is an error in the data or not. A value of false for this parameter means that the data is valid(!) and a value of true means that there is an error. This parameter is valid for rules, validations and substitutions. |
| C_EXIT_PARAM_FIELD | This constant is valid for substitutions only and means that one parameter can be defined for the user exit which is the field to be substituted |
| C_EXIT_PARAM_CLASS | valid for Rules, Validations and Substitutions, this parameter signifies that all the data (BKPF and BSEG data) will be passed as one parameter to the user exit. You will be passed a table containing all the relevant information |

How to activate trace:

![image.png](IMGs/FI%20Validations%20&%20substitutions/image.png)