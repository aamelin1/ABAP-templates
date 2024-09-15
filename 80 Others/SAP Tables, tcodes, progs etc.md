# Tcodes, table names, ABAP programs, BAdIs, BAPIs, SAP notes etc
**Table of contents:**

- [ABAP](#ABAP)
- [General (Users, Logs, Monitors, Basis, some tech stuff etc)](#general-users-logs-monitors-basis-some-tech-stuff-etc)
- [FI: Finance](#FI)
- [FI-AA: Fixed Asset](#FI-AA)
- [CO: Controlling](#CO)
- [ML: Material Ledger](#ML)
- [MM: Material Management](#MM)
- [SD: Sales and Distribution](#SD)
- [TM: Transportation Management](#TM)

---

## ABAP

### ABAP developer tools

**SAP dev tcodes:**

| Tcode          | Description                       |
| -------------- |:--------------------------------- |
| `SE38`         | ABAP Editor                       |
| `SE11`         | ABAP Dictionary Maintenance       |
| `SE24`         | ABAP Class Builder                |
| `SE80`         | Object Navigator                  |
| `SE14`         | Utilities for Dictionary Tables   |
| `SE18`         | Business Add-Ins: Definitions     |
| `SE19`         | Business Add-Ins: Implementations |
| `SMOD`         | User-Exits                        |
| `CMOD`         | User-Exit implementation          |
| `SE30`or `SAT` | Runtime Analysis                  |
| `SE37`         | ABAP Function Modules             |
| `SE41`         | Menu Painter                      |
| `SE51`         | Screen Painter                    |
| `SE54`         | Generate table view               |
| `SE91`         | Message Maintenance               |
| `SE93`         | Maintain Transaction Codes        |
| `SE95`         | Modification Browser              |
| `ICON`         | Display Icons                     |
| `DWDM`         | Development Workbench Demos       |

Also Eclipse (with ADT) and VS code IDE may be used for ABAP development.

**SAP table data display functionality:**

- `SE16` - Data Browser
- `SE16n` - General Table Display
- `SE16h` - General Table Display (HANA)
- Program `RFPIVB_SINGLETAB_VAL` - to display any table in PIVB like view

>💡How to change table values directly (it's a bad idea to do this):
>
> - In `SE16n` put a `&sap_edit` in a tcode field. This feature can be deactivated (see program `RKSE16N_EDIT`). 
> - Other way - go to debugger at first screen of `se16n` via `/h`and change a variable `GD-EDIT`and `GD-SAP_EDIT` to `X`.
> - Or use a FM `SE16N_INTERFACE`
> 
> Logs of direct table edited entries are stored at table `SE16N_CD_KEY` and can be showed via program `RKSE16N_CD_DISPLAY`

**Some tables:**

- `TRESE` - Reserved names
- `TADIR`, `TRDIR` - Repository

#### Transport requests:

- Tcode `SE03` - Transport Organizer Tools (incl. search TRs by including objects)
- Tcode `SE10` - Transport Organizer
- Tcode `STMS` and `STMS_IMPORT` - Transport Management System
- Tcode `STMS_QA` - TMS Quality Assurance
- Tables `E070`,`E071`,`E07T` - for TRs info
- [How to use a transport of copies](../10%20How-Tos/BC%20Transport%20of%20copies.md)
- [TRC Transport request checker](../60%20ABAP%20reports%20and%20tools/TRC%20Transport%20request%20checker.md)

### Some ABAP snippets

#### ALV

Templates to show data via ALV:
- [Show ALV via FM](../01%20ABAP%20templates/ALV_01%20FM%20REUSE_ALV_GRID_DISPLAY_LVC.md)
- [OO based ALV (SALV)](../01%20ABAP%20templates/ALV_02%20OO%20Simple%20SALV.md)
- [IDA (aka ALV on HANA)](../01%20ABAP%20templates/ALV_04%20IDA.md)
- [PIVB](../01%20ABAP%20templates/ALV_05%20PIVB.md)

#### Internal tables

##### itab declaration 

The inline declaration in a SELECT statement produces a standard table with empty key
```abap
SELECT * FROM zdemo_abap_flsch INTO TABLE @DATA(itab).
```

Sorted itab with key:
```abap
"Sorted tables: both UNIQUE and NON-UNIQUE possible
DATA itab1 TYPE SORTED TABLE OF zdemo_abap_flsch WITH UNIQUE KEY carrid connid.
DATA itab2 TYPE SORTED TABLE OF zdemo_abap_flsch WITH NON-UNIQUE KEY carrid connid cityfrom.

"The following examples demonstrate secondary table keys that are
"possible for all table categories.
DATA itab3 TYPE TABLE OF zdemo_abap_flsch                   "standard table
  WITH NON-UNIQUE KEY carrid connid                         "primary table key
  WITH UNIQUE SORTED KEY cities COMPONENTS cityfrom cityto. "secondary table key
```

Declare locally based itab:
```abap
"Internal table creation steps based on a locally declared structure
"1. Defining line type locally
TYPES: BEGIN OF ls_loc,
          key_field TYPE i,
          char1     TYPE c LENGTH 10,
          char2     TYPE c LENGTH 10,
          num1      TYPE i,
          num2      TYPE i,
        END OF ls_loc.

"2. Defining internal table types
TYPES:  tt_std    TYPE TABLE OF ls_loc WITH EMPTY KEY,
        tt_sorted TYPE SORTED TABLE OF ls_loc WITH NON-UNIQUE KEY key_field,
        tt_hashed TYPE HASHED TABLE OF ls_loc WITH UNIQUE KEY key_field.

"3. Creating internal tables from locally defined table types
DATA: itab_st TYPE tt_std,
      itab_so TYPE tt_sorted,
      itab_hs TYPE tt_hashed.
```

##### Appending lines to itab

using `VALUE`:
```abap
APPEND VALUE #( comp1 = a comp2 = b ... ) TO itab.
```

From structure:
```abap
APPEND struc TO itab.
```

Adding all lines from another internal table
```abap
APPEND LINES OF itab2 TO itab.
```

Creating an internal table by inline declaration and adding lines with a constructor expression
```abap
"Internal table type
TYPES it_type LIKE itab.

"Inline declaration
"The # character would not be possible here since the line type
"cannot be derived from the context.
DATA(it_in) = VALUE it_type( ( comp1 = a comp2 = b ... )
                             ( comp1 = c comp2 = d ...  ) ).
                         
 "Not providing any table lines means the table is initial
DATA(itab) = VALUE tt_std( ).
```

Inline creating a string tables
```abap
DATA(str_tab_a) = VALUE string_table( ( `Hello` ) ( `World` ) ).
```

Adding new lines without deleting existing content (`BASE`)
```abap
itab = VALUE #( BASE itab ( comp1 = a comp2 = b ... )
                          ( comp1 = c comp2 = d ... ) ).
```

Copying the content of another internal table
```abap
itab = CORRESPONDING #( itab3 ). " init itab
itab = CORRESPONDING #( BASE ( itab ) itab3 ). "keep existing lines in itab
```

Copying the content of another internal table with conditions:
```abap
"Note: The source table must have at least one sorted or hashed key.
DATA(f1) = FILTER #( itab1 WHERE num >= 3 ).
```

##### Reading Single Lines from Internal Tables

```abap
READ TABLE itab ASSIGNING FIELD-SYMBOL(<fs2>) ...   "The field symbol is created inline.
```

```abap
line = it[ b = 2 ].

"Note: Table keys are specified with the ... WITH TABLE KEY ... addition, 
"free keys with ... WITH KEY ....
READ TABLE it INTO wa WITH KEY b = 2.
```

itab line count:
```abap
DATA(number_of_lines) = lines( itab ).
```


##### itab looping
```abap
LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs>).
  ...
ENDLOOP.
```


##### Modifying Internal Table Content

##### Deleting Internal Table Content
```abap
DELETE TABLE itab WITH TABLE KEY a = 1.
DELETE str_table WHERE table_line CP `Z*`.
```

Duplicates:
```abap
"Implicitly using the primary table key
DELETE ADJACENT DUPLICATES FROM it.

"Deletion respecting the values of the entire line
DELETE ADJACENT DUPLICATES FROM it COMPARING ALL FIELDS.

"Only lines are deleted with matching content in specific fields
DELETE ADJACENT DUPLICATES FROM it COMPARING a c.
```

Deleting the Entire Internal Table Content
```abap
CLEAR itab. "the memory space initially requested remains allocated
FREE itab. "This statement additionally releases memory space.
```

> 💡 [SAP itab cheat sheet](https://github.com/SAP-samples/abap-cheat-sheets/blob/main/01_Internal_Tables.md)

#### BuiltIn ABAP inline functions

itab lines count: 
``` abap 
DATA(lv_lines_count) = lines( strtab ).
```
String length: 
``` abap 
DATA(lv_strlen) = strlen( 'abc   ' ).  " -> 3
```
Number of chars: 
``` abap
DATA(lv_count_chars) = numofchar( `abc   ` ). " -> 3
```
String concatenation: 
``` abap
DATA(lv_res_str) = str1 && ` ` && str2.
DATA(lv_res_str) = |{ str1 }| && ` ` && |{ str2 }|.
CONCATENATE str1 str2 INTO DATA(lv_res_str) SEPARATED BY ` `. "Concat with space
```
String concatenation from itab: 
``` abap
DATA(lv_res_str) = concat_lines_of( table = itab sep = ` ` ).
```
Absolute value: 
```abap
DATA(lv_abs) = abs( -4 ). "4
```
Value sign (-1 if negative, 0 if 0, 1 if positive):  
```abap
DATA(sign1) = sign( -789 ). "-1
```
Rounding
```abap
DATA(lv_round) = round( val = CONV decfloat34( '1.2374' ) dec = 2 ). "1.24
```
> 💡 more details here: [ABAP BuiltIn inline functions](../01%20ABAP%20templates/ABAP%20BuiltIn%20inline%20functions.md)

#### CDS functions

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

> 💡 [CDS tricks&tips](../01%20ABAP%20templates/CDS%20tricks&tips.md)

#### Working with files

- Class `cl_gui_frontend_services=>file_open_dialog` - File open dialog
- Class `CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD` - Upload file
- FM `ALSM_EXCEL_TO_INTERNAL_TABLE` - Upload MS Excel file to SAP

#### Number ranges

- Tcode `SNUM` or `SNRO` - Number Range Object
- FM `NUMBER_GET_NEXT`
- FM `NUMBER_RANGE_ENQUEUE`, `NUMBER_RANGE_DEQUEUE`


#### Read variables from callstack

``` abap
CONSTANTS: lco_migo_vgart_path TYPE string VALUE '(SAPLMIGO)LCL_MIGO_GLOBALS=>KERNEL->S_CONTROL-VGART'.
FIELD-SYMBOLS: <migo_vgart> TYPE any.
DATA: lv_vgart TYPE vgart.

ASSIGN (lco_migo_vgart_path) to <migo_vgart>.
IF sy-subrc = 0.
    lv_vgart = <migo_vgart>.
ENDIF.
```

  - Class `xco_cp=>current->call_stack->full( )` - Get current callstack

>💡 In the example below, a line pattern is created (method that starts with a specific pattern). The extracting should go up to the last occurrence of this pattern. It is started at position 1.
``` abap
DATA(line_pattern) = xco_cp_call_stack=>line_pattern->method(
  )->where_class_name_starts_with( 'CL_REST' ).
DATA(extracted_call_stack_as_text) = call_stack->from->position( 1
  )->to->last_occurrence_of( line_pattern )->as_text( format ).
```  

  - [Read VARs from callstack](../01%20ABAP%20templates/Read%20VARs%20from%20callstack.md)

#### Memory IDs

- `TPARA` - Memory ID 

```abap
EXPORT objn TO MEMORY ID 'ZID'.
IMPORT objn FROM MEMORY ID 'ZID'.

FREE MEMORY ID 'ZID'.
```

#### Selection screen

Select-option field feature:
- `NO-DISPLAY`
- `NO-EXTENSION`
- `NO INTERVALS`
- `DEFAULT 4 TO 8 OPTION NB SIGN I`

Texts:
```abap
SELECTION-SCREEN COMMENT /5(10) t1.
```


Add a blank line(s)
```abap
SELECTION-SCREEN SKIP 5. "5 blank lines
```


Checkbox:
``` abap
PARAMETERS pu AS CHECKBOX USER-COMMAND cmd.
```


Radiobuttons:
```abap
PARAMETERS: prb1 RADIOBUTTON GROUP rbgr,
            prb2 RADIOBUTTON GROUP rbgr,       
            prb3 RADIOBUTTON GROUP rbgr DEFAULT 'X'.  "Select this radiobutton by default
```

- [Selection screen](../01%20ABAP%20templates/Selection%20screen.md)

#### Ranges

```abap
Declaring a ranges table
DATA rangestab TYPE RANGE OF i.

"Populating a ranges table using VALUE
rangestab = VALUE #( sign   = 'I'
                     option = 'BT' ( low = 1  high = 3 )
                                   ( low = 6  high = 8 )
                                   ( low = 12 high = 15 )
                     option = 'GE' ( low = 18 ) ).
```

- [Working with ranges](../01%20ABAP%20templates/Working%20with%20ranges.md)

#### Call BAPIs

- BAPI `BAPI_TRANSACTION_ROLLBACK` - Rollback
- BAPI `BAPI_TRANSACTION_COMMIT` - Commit

#### Batch input

- [BDC Batch input macro](../01%20ABAP%20templates/BDC%20Batch%20input%20macro.md)

#### Pop up messages 

- [Pop up windows](../01%20ABAP%20templates/Pop%20up%20windows.md)
- [Progress_indicator](../01%20ABAP%20templates/Progress_indicator.md)

#### Logs

 `C14ALD_BAPIRET2_SHOW` - FM to show BAPI return messages

#### Dynamic SQL

- [Dynamic SQL](../01%20ABAP%20templates/Dynamic%20SQL.md)
- FM `F4_CONV_SELOPT_TO_WHERECLAUSE` - Convert WHERE conditions

#### Other dynamic techniques

- Class `XCO_CP_GENERATION` - Generate repositary objects

```abap
DATA(some_type) = 'STRING'.
DATA dataref TYPE REF TO data.

"Creating an internal table using a CREATE DATA statement
"by specifying the type name dynamically.
"In the example, a standard table with elementary line type
"and standard key is created.
CREATE DATA dataref TYPE TABLE OF (some_type).

TYPES: BEGIN OF demo_struc,
          comp1 TYPE c LENGTH 10,
          comp2 TYPE i,
          comp3 TYPE i,
        END OF demo_struc.

"Internal table with structured line type and empty key.
CREATE DATA dataref TYPE TABLE OF ('DEMO_STRUC') WITH EMPTY KEY.
```

#### Get data from other SAP system via RFC

- FM `RFC_READ_TABLE DESTINATION <dest>` - Read data from other system

#### Others

- [More ABAP templates here](../01%20ABAP%20templates/00_ABAP_Index.md)


## General (Users, Logs, Monitors, Basis, some tech stuff etc)

### Users and Roles

- tcode `SUIM` - User/Role main tcode
- tcode `PFCG` - Maintain SAP Roles
- tcode `SU01`, `SU01d` - Maintain user
- Program `PFCG_MASS_TRANSPORT` - Add roles to TR
- `USR01` - User master record
- `AGR_USERS` - User-Roles assigments
- `AGR_TEXTS` - Role texts
- `SMEN_BUFFC` - User favorites 
- `USR05` - Memory ID values by users 
- BAPI `BAPI_USER_GET_DETAIL` - Get user details
- [BC Users vs Roles](../60%20ABAP%20reports%20and%20tools/BC%20Users%20vs%20Roles.md)

### Logs

| Type of logs | Tcode  |SAP objects |
|---|---|---|
| Table content | `SCU3`- tcode to Table History display | `DBTABLOG` - table for change logs |
| Change document | `RSSCD100` - tcode to Change documents display |`CDHDR` + `CDPOS` Tables of Change documents <br>`CHANGEDOCUMENT_DISPLAY` - FM to Show change documents |
| Standard logging | `SLGx` - tcodes of Application Log |`CL_BALI_LOG` - Class  Working with SLGx Logs  | 
| Direct SAP tables updates | `RKSE16N_CD_DISPLAY` - program to show logs of `&sap_edit`| `SE16N_CD_KEY` -  Logs of `&sap_edit` <br>  |
| System logs | `SM21` | |

> 💡 `C14ALD_BAPIRET2_SHOW` - FM to show BAPI return messages

### Monitors, Trace etc

- `ST05` -  Performance Trace
- `SAT` - ABAP Trace
- `SM36` + `SM37` - BackGround Jobs
- `SM50` - Work Processes
- `SM51` - Started AS Instances
- `STAD` - Statistics display
- `DBACOCKPIT` or `DB02` - DBA Cockpit
- `SM59` - RFC Destinations
- `SM12` - Display and Delete Locks
- `AL11` - Display SAP Directories
- `SXI_MONITOR` - XI: Message Monitoring 

### Others

- `T100` + `T100C` + `T100S` - Message control
- Tcode `OBA5` - Message controls
- Class `CL_EXITHANDLER`  method `GET_INSTANCE` - Put breakpoint here and run tcode to get BAdIs names. See [ABAP Find BAdIs](../10%20How-Tos/ABAP%20Find%20BAdIs.md)


## FI

### FI enhancements:

#### Substitutions and Validations

- Tcode `GGB1` - Substitution Maintenance
- Tcode `GGB0` - Validation Maintenance
- Tcode `OBBH` - Assign Substitution to Company code and activation status
- Tcode `GCX2` - Assign program to Substitution/Validation
- Program `RGUGBR00` - regenerate Substitution and Validation
- Table `GB01` + view `VWTYGB01` - fields for Substitute

<details><summary><b>More details</b></summary>

SAP provide two programs that should be used to implement these user exits. These are `RGGBS000` and `RGGBR000` (for substitutions and rules respectively). The relevant program should be copied to a Z version of the program, `ZRGGBR000` for example.

To add own form, you need to specify form name as:

``` abap
   EXITS-NAME  = 'U100'.  
   EXITS-PARAM = C_EXIT_PARAM_NONE.        "Complete data used in exit.  
   EXITS-TITLE = TEXT-101.                 "Posting date check  
   APPEND EXITS.
```


| EXITS-PARAM        | Comments         |
|:------------------ | ---------------- |
| C_EXIT_PARAM_NONE  | This constant means that no parameters are defined for this user exit. In truth, there is one parameter defined and that is a boolean flag that is used to specify whether there is an error in the data or not. A value of false for this parameter means that the data is valid(!) and a value of true means that there is an error. This parameter is valid for rules, validations and substitutions. |
| C_EXIT_PARAM_FIELD | This constant is valid for substitutions only and means that one parameter can be defined for the user exit which is the field to be substituted    |
| C_EXIT_PARAM_CLASS | valid for Rules, Validations and Substitutions, this parameter signifies that all the data (BKPF and BSEG data) will be passed as one parameter to the user exit. You will be passed a table containing all the relevant information       |

> 💡 More details here [FI Substitutions&Validations](../10%20How-Tos/FI%20Substitutions&Validations.md)
</details>

#### Open FI (BTE)

- Tcode `FIBF` - Maintenance transaction BTE

> 💡 More details here [FI FIBF OpenFI](../10%20How-Tos/FI%20FIBF%20OpenFI.md)

#### BAdIs, User-Exits, Enhancements

- `AC_DOCUMENT` - Change the Accounting Document
- `BADI_ACC_DOCUMENT` - FI doc
- `I_TRANS_DATE_DERIVE` - Change currency conversion
- `FAGL_LIB` - FI Line Item Browsers enhancements
- `BADI_GVTR_DERIVE_FIELDS` - BCF (FAGLGVTR)
- Table `TRWPR` - RWIN processes (list of FMs)
- Table `TRWCA` - RWIN components
- [FI RWIN interface](../10%20How-Tos/FI%20RWIN%20interface.md)


### FI BAPIs and FMs

- `BAPI_ACC_DOCUMENT_POST` - post FI doc
- `BAPI_ACC_DOCUMENT_REV_POST` - reverse FI doc
- `G_SET_GET_ID_FROM_NAME` - Get Set ID (`GS0x`)
- `G_SET_GET_ALL_VALUES` -  Read All Values in a Set Hierarchy
- `CALCULATE_TAX_FROM_GROSSAMOUNT` - calculate the tax amount and to get the correct tax account
- `CALCULATE_TAX_FROM_NET_AMOUNT`
- `DATE_TO_PERIOD_CONVERT` - get FI period by date
- `FI_PERIOD_DETERMINE` - Find the period for a date
- `FI_PERIOD_CHECK` - check if the period is opened or closed
- `CONVERT_TO_LOCAL_CURRENCY` - Translate foreign currency amount to local currency
- `GET_CLEARED_ITEMS` - Get cleared items
- `BAPI_GL_GETGLACCBALANCE` - Closing balance of G/L account for chosen year.
- `BAPI_GL_GETGLACCCURRENTBALANCE` - Closing balance of G/L account for current year
- `BAPI_GL_GETGLACCPERIODBALANCES` - Posting period balances for each G/L account

### Company code

- `T001` - Company codes
- `T001z` - Additional parameter for Company code
- `T001-ADRNR` -> `ADRC-ADDRNUMBER` - Long text + Addess
- `T001B`, tcode `OB52` - FI open periods 
-  Tcode `OB72` - Global Company code customising

### Ledgers, AccPrinciples + Currencies 

- Tcode `finsc_ledger` - Ledgers/currencies customizing
- Tcode `FINS_CUST_CONS_CHK` - checks for all company codes and ledgers
- Tcode `FINS_CUST_CONS_CHK_P` - checks for a single company code and ledger group
- `FINSC_CURTYPE` + `FINSC_CURTYPET` - Currency type
- `FINSC_LEDGER` + `FINSC_LEDGER_T` - FI ledgers
- `FAGL_TLDGRP` + `FAGL_TLDGRPT` - Ledger Group
- `TACC_PRINCIPLE` + `TACC_PRINCIPLET` - Accounting Principle
- `TACC_TRGT_LDGR` - Accounting Principle to Ledger group
- `FAGL_TLDGRP_MAP` - Assignment of Ledgers to Ledger Groups
- `FINSC_LD_CMP` - Ledger/Company code/Currencies


### Account determination

- Tcode `OBA1` -Exchange rate differences
- `T030H` + `T030HB` - Exchange rate differences cust
- Tcode `OBYC' - Materials Management postings (MM)
- `T030` - Account determination 
- `T030U` - Account Determ.for Balance Sheet Transfer Postings

### Chart of accounts

- `T004` + `T004T` - Chart of account
- `SKA1` + `SKAT` +`SKB1` - G/L Account Master
- `T011` + `T011T` - FSV (**OB58**)
- `FAGL_011ZC` - FSV: GL account assigment (**OB58**)
- Tcode `FAGLACC_CHECK` - Check Inconsistency for G/L Account

### Business partners (Vendors + Customers)

- `BUT000` - BP general data
- `BUT020` - BP addresses
- `BP00x` - BP data
- `DFKKBPTAXNUM` - Tax Numbers for Business Partner
- `LFA1` + `LFB1` - Supplier Master
- `LFBK` - Supplier bank data
- `KNA1` + `KNB1` - Customer Master
- `KNBK` - Customer bank data
- `T880` - Global Company Data (link to `LFA1-VBUND`, `KNA1-VBUND` and `BP001-VBUND`)
- `BAPI_BUPA_FS_CREATE_FROM_DATA2` - 
- `BAPI_BUPA_TAX_ADD` - 
- `BAPI_BUPA_ROLE_ADD_2` -
- `BAPI_BUPA_ROLE_REMOVE` - Delete BP role
- `BAPI_BUPA_BANKDETAIL_ADD`
- `VMD_EI_API=>MAINTAIN_BAPI`
- `cmd_ei_api=>maintain_bapi`


### FI-BL, Banks, Own banks + own bank accounts

- `BNKA` - Bank master record (**FI03**)
- Tcode `BAUP` for mass upload bank master data (customising in tcode **BA01**)
- Program `SAPF023` to reset bank master data
- `T012` + `T012T` - Own Banks (**FI12**)
- `T012K`, `V_T012K_BAM`, `FCLM_BAM_DISTINCT_HBA` - Own Bank Accounts
- Program `RFEBKA96` to detele bank statments

### FM and splitting

- `fagl_splinfo` - Splittling Information of Open Items
- `fagl_splinfo_val` - Splitting Information of Open Item Values (curr)
- `FM01` + `FM01T` - Financial Management Areas
- `FMCI` + `FMCIT` - Commitment items master data
- `FMFXPO` - Commitment item, internal and external number (conversion)
- `FMFCTR` + `FMFCTRT` - Funds Center Master Record
- Tcode `FMDERIVE` + `FMDERIVER` - FM derivation
- `T8G17` - Splitting GL account types
- Tcode `FAGL_CHECK_ACCOUNT` - Check GL account split settings
- [FM repair fagl_splinfo](../10%20How-Tos/FM%20repair%20fagl_splinfo.md) - How to repair tables `fagl_splinfo` and `fagl_splinfo_val` (like simulate splitting for posted docs) 

### ACE and POAC objects

- Tcode `POACTREE03` - Edit Accrual Objects
- Tcode `POAC_MM2ACE_TRANSFER` - Transfer MM Purchase Order to ACE
- Tcode `ACEPOSTINGRUN` - Periodic Posting Run
- BAdI `BADI_POAC_MMPO_2_ACE_TRANSFER` - Transfer MM purchase order data to accrual engine
- BAdI `BADI_ACE_DOCUMENT_SCHEMA_CUST` - Manage calculated posting schema

### FI Documents

- `BKPF` - Accounting Document Header
- `BSEG` - Accounting Document Segment (Entry View)
- `BSEG_ADD` - Entry View of Accounting Document for Additional Ledgers
- `ACDOCA` - Universal Journal Entry Line Items

### Others

- `T003` + `T003T` - Document types
- `TBSL` + `TBSLT` - Posting keys
- `T074` + `T074U` + `T074T` - SGL indicators
- `TTYP` + `TTYPT` - Object type (AWTYP)
- `FINSTS_SLALITTY` + `FINSTS_SLALITTYT` - Subledger-Specific Line Item Types (SLALITTYPE)
- - `T008` + `T008T` - Blocking Reasons (for AP) 
- Tcode `OB41` - Maintain Accounting Configuration : Posting Keys  
- Tcode `OBC4` - Maintain Field Status Group. The group can be assigned to account.
- FM `FI_FIELD_SELECTION_DETERMINE` - get field status

#### Brazil localization:

- `J_1BNFDOC` - Nota Fiscal Header

#### HANA reports (fagll03h, fblXh etc):
- to show archived data - implement BAdI `FAGL_LIB`, as an example you may use a  `FAGL_LIB_ARCHIVE_VIA_INDEX`. 
- `HDBVIEWS` - tcode to add/customise FI reports
- `HDBC` - ERP Accelerators: Settings
- [SAP Blog. How to extend FAGLL03h](https://blogs.sap.com/2020/12/20/how-to-extend-transaction-fagll03h-with-custom-fields/)
- OSS `2180685` - "FI Line Item Browsers and Archived Data"
- OSS `2408083` - "FAQ: Data Model of S/4 HANA Finance Data"
- OSS `2321684` - "FI Line Item Browsers: Add master data fields to generated views"

## FI-AA

- Tcode `ORFA` - IMG for FI-AA
- Tcode `AO90` - Accounts determination
- Tcode `FAA_CMP`, `FAA_CMP_LDT` - FI-AA Legacy Data Transfer Settings
- Tcode `FAA_CLOSE_FISC_YEARS` - Close Fiscal Years in FI-AA
- Tcode `ABLDT_OI` - Migration. to post the open items for an AuC with line item processing
- Program `RAFAB_COPY_AREA` and BAdI `FAA_AA_COPY_AREA` - copying Depreciation Areas 
- `ANKA` + `ANKT` - Asset classes
- `T096` + `T096T` - Chart of depreciation
- `T093` + `T093T` - Depreciation areas
- `TABW` + `TABWT` - Asset transaction types
- `TABWA` - Transaction types/dep. areas (at S/4HANA only for `AR29n`, groups `81/82/89`)
- `ANLA` - Asset Master Record Segment
- `ANLB` - Depreciation terms
- `ANLZ` - Time-Dependent Asset Allocations
- `ANLI` - Link table for investment measure -> AuC
- `ANLK` - Asset Origin by Cost Element
- `FAAT_DOC_IT` - Statistical Line Item in Asset Accounting
- `FAAT_PLAN_VALUES` - Planned Depreciations and Revaluations
- `TABA` - Depreciation posting documents
- `T499S` - FA Locations (via  `SPRO->Enterprise Structure->Definition->Logistics - General->Define Location`)

> 💡 Actual values from tables `ANEP`, `ANEA`, `ANLP`, `ANLC` are saved in table `ACDOCA` in new Asset Accounting. 
> 
> The values from table `ANEK` are saved in tables `BKPF` and `ACDOCA` in new Asset Accounting.
> Statistical values from tables `ANEP`, `ANEA`, `ANLP` and `ANLC`, are saved in new Asset Accounting in table `FAAT_DOC_IT`.
> 
> Planned values from tables `ANLP` and `ANLC` are saved in table `FAAT_PLAN_VALUES` in new Asset Accounting.
> 
> As of release **SAP S/4HANA 1809**, the `BSEG` table will **no longer be updated** with the depreciation run.


### FI-AA BAdIs and user-exits:

- `FAA_DC_CUSTOMER` - Customer-Specific SAP Standard Enhancements
- `FAA_EE_CUSTOMER` - BAdI for Customer-Specific Enhancements
- `BADI_FIAA_DOCLINES` (obsolete) - Change of Line Items in Asset Document
- `FAA_DOCLINES_CUSTOMER` - Customer-specific change of Line Items in Asset Document
- `FAA_AA_COPY_AREA` - Subsequent Implementation of a Depreciation Area
- User exit `AISA0001`  - Assign Inventory Number
- User exit `AIST0002`  - Customer fields in asset master

| Report                    | Structure             | Customizing Include |
| ------------------------- | --------------------- | ------------------- |
| Asset Balances            | `FIAA_SALVTAB_RABEST` | `CI_REPRABEST`      |
| Asset History Sheet       | `FIAA_SALVTAB_RAGITT` | `CI_REPRAGIT`       |
| Asset Transaction List    | `FIAA_SALVTAB_RABEWG` | `CI_REPRABEWG`      |
| Planned Depreciation List | `FIAA_SALVTAB_RAHAFA` | `CI_REPRAHAFA`      |

### FI-AA BAPIs:

- `BAPI_FIXEDASSET_OVRTAKE_CREATE` - Legacy data transfer
- `BAPI_ASSET_ACQUISITION_CHECK` - Asset Acquisition 
- `BAPI_ASSET_ACQUISITION_POST` - AssetAcquisition 
- `BAPI_ASSET_RETIREMENT_CHECK` - AssetRetirement
- `BAPI_ASSET_RETIREMENT_POST` - Asset Retirement
- `BAPI_ASSET_POSTCAP_CHECK` - Asset Post-Capitalization
- `BAPI_ASSET_POSTCAP_POST` - Asset Post-Capitalization
- `BAPI_ASSET_REVERSAL_CHECK` - Asset Document Reversal 
- `BAPI_ASSET_REVERSAL_POST` - Asset Document Reversal 
- `BAPI_FIXEDASSET_CHANGE` - Change fixed asset

For segment reporting, the business function FI-AA, Segment Reports on Fixed Assets (`FIN_AA_SEGMENT_REPORTING`) is available

## CO

- Tcode `OKP1` - Maintain CO Period Lock
- `TKA01` - Controlling Areas
- `TKA02` - Controlling area assignment
- `CSKA` + `CSKU` - Cost Elements 
- `CSKS` + `CSKT` - Cost Center Master Record
- `CEPC` + `CEPCT` - Profit Center Master Data Table

## ML

- Tcode `FCMLHELP` - ML Helpdesk
- `CKMLHD` - Material Ledger: Header Record
- `ACDOCA_M_EXTRACT` -ACDOCA Extract Table for Material Ledger
- `MLDOC` - Material Ledger Document
- `MLDOCCCS` - Material Ledger Document Cost Component Split
- Tcode `OKTZ` - Cost components
- `TCKH4` + `TCKH5` - Cost componentsstructure
- `TCKH3` + `TCKH1` - Cost Components
- `TCKH2` - Assigment of Cost Components to GL account
- tcode `CKMLQS` - show BOM 
- FM `CKML_MGV_BOM_READ` - get BOM by material (`CKMLMV001` to get kalnr by material, not `ckmlhd`)
- `V_ML4H_CDS_MV003` - CDS to find BOM

## PS

- `BAPI_PS_INITIALIZATION` + `BAPI_BUS2054_CREATE_MULTI`- Create WBS

## MM

- `T001W` - Plants/Branches
-  `T001K` - Valuation area
- `T001L` - Storage Locations
- `MARA` + `MAKT` - General Material Data (tcode `MM03`)
- `ASMD` + `ASMDT` - Service Master Data (tcode `AC03`)
- `T148` + `T148T` - Special Stock Indicator
- `T156HT` - Main Text for Movement Type
- `T157E` - Text Table: Reason for Movement
- `MCH1` - Batches (if Batch Management Cross-Plant)
- Material and Batch characteristics  [MM Material and Batch classification](../10%20How-Tos/MM%20Material%20and%20Batch%20classification.md) Tables `inob`, `ausp`, `cabn`, `cawn`, `cawnt`
- `T16FS` + `T16FT` - Release Strategies
- `T16FD` - Description of Release Codes


### BAPIs

- `BAPI_PO_CHANGE` - BAPI  Purchase Order
- `BAPI_PR_CHANGE` - Purchase Requisition BAPI

### Enhancements, BADIs, User-Exits

- `ME_PROCESS_PO_CUST` - Enhancements for Purchase Order Processing

## SD

- `VBAK` - Sales Document: Header Data
- `VBAP` - Sales Document: Item Data
- `VBKD` - Sales Document: Business Data
- `VBFA` - Sales Document Flow
- `VBFA` - Sales Document: Partner
- `VBRK` - Billing Document: Header Data
- `VBRP` - Billing Document: Item Data
- `LIKP` - SD Document: Delivery Header Data
- `LIPS` - SD document: Delivery: Item data
- `PRCD_ELEMENTS` - Pricing Elements
- `TVAK` + `TVAKT` - Sales Document Types
- `TVKO` + `TVKOT` - Organizational Unit: Sales Organizations
- `TVTW` + `TVTWT` - Organizational Unit: Distribution Channels
- `TSPA` + `TSPAT` - Organizational Unit: Sales Divisions
- `TVGRT` - Organizational Unit: Sales Groups: Texts
- `TVKBT` - Organizational Unit: Sales Offices: Texts
- `TINC` + `TINCT` - Incoterms
- `TVLK` + `TVLKT` - Delivery Types
- `TVAP` + `TVAPT` - Sales Document: Item Categories
- FM `VC_I_GET_CONFIGURATION` - Read configuration (by `CUOBJ`)

## TM

- `WBRK` - Settlement Management Document Header
- `WBRP` - Settlement Management Document Item
- `/scmtms/d_torrot` - TM doc link to delivery

How to find TM flow based on delivery number
1. Find order key 
Select PARENT_KEY  
From `/SCMTMS/D_TORDRF`  
Where BTD_ID = <Delivery#>
2. Fiend order number  
Select TOR_ID  
From `/SCMTMS/D_TORROT`  
Where DB_KEY = PARENT_KEY (from p.1) and LIFECYCLE <> ‘10’ (Canceled) and TOR_CAT = “TO” or “BO”

FSD document:
1. From order to FSD
 `/SCMTMS/TOR>BO_SFIR_ROOT` ( BO `/SCMTMS/SUPPFREIGHTINVREQ`)
2. Delete lines `/SCMTMS/SUPPFREIGHTINVREQ> Root -Lifecycle = ‘06’` (Canceled)  
3. `/SCMTMS/SUPPFREIGHTINVREQ> ROOT – SFIR_ID`

