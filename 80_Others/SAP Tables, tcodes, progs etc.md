
# Tcodes, table names, ABAP programs, BAdIs, BAPIs, SAP notes etc

 - [General (ABAP, Basis, tech etc)](#General-(ABAP,-Basis,-tech-etc))
- [FI: Financial](#FI)
- [FI-AA: Fixed Asset](#FI-AA)
- [CO: Controlling](#CO)
- [ML: Material Ledger](#ML)
- [MM: Material Management](#MM)
- [SD: Sales and Distribution](#SD)
- [TM: Transportation Management](#TM)

## General (ABAP, Basis, tech etc)

### SAP Tables:

| Table name | Comment |
| --- | --- |
| `AGR_USERS` | User-Roles assigments |
| `SMEN_BUFFC` | User favorites |
| `TPARA` | Memory ID |
| `USR05` | Memory ID values by users |
| `DBTABLOG` | table change logs |
| `SE16N_CD_KEY` | Logs of sap_edit (+ program RKSE16N_CD_DISPLAY) |
| `E070`,`E071`,`E07T` | TRs |
| `TADIR` | Repository |
| `TRWPR` | RWIN processes (list of FMs) |
| `TRWCA` | RWIN components |
| `TRESE` | Reserved names |

### Tcodes:

| Tcode | Comment |
| --- | --- |
| `ST05` | Performance Trace | 
| `SM12` | Display and Delete Locks |
| `SXI_MONITOR` | XI: Message Monitoring |
| `SLGx` | Application Log |
| `AL11` | Display SAP Directories |
| `SM36` + `SM37` | BackGround Jobs |
| `SM50` | Work Processes |
| `SM51` | Started AS Instances |
| `SAT`| ABAP Trace |
| `STAD` | Statistics display |
| `DBACOCKPIT` or `DB02` | DBA Cockpit |
| `SNUM` or `SNRO` | Number Range Object |
| `SM59`| RFC Destinations |
| `WE20`| Partner Profiles |
| `OB72`| Global Company codes |
| `ICON`| Display Icons |
| `SCU3`| Table History |
| `DWDM`| Development Workbench Demos |

### FMs, Classes, BAdI, BAPI:

| Type | Object | Comment |
| --- | --- | --- |
| Class | `CL_EXITHANDLER` | Method `GET_INSTANCE` to get BAdIs |
| Class | `xco_cp=>current->call_stack->full( )` | Get current callstack |
| Class | `CL_BALI_LOG` | Logs |
| Class| `XCO_CP_GENERATION` | Generate repositary objects |


### BuiltIn Functions

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


**Check callstack:**

Extracting the call stack based on specifications. You can specify the extractions using from/to and further detailing out the kinds of extractions such as the position or the first/last occurrence of a specific line pattern.
In the example, a line pattern is created (method that starts with a specific pattern). The extracting should go up to the last occurrence of this pattern. It is started at position 1.

``` abap
DATA(line_pattern) = xco_cp_call_stack=>line_pattern->method(
  )->where_class_name_starts_with( 'CL_REST' ).
DATA(extracted_call_stack_as_text) = call_stack->from->position( 1
  )->to->last_occurrence_of( line_pattern )->as_text( format ).
```  

---

## FI

- `T003` + `T003T` - Document types
- `TBSL` + `TBSLT` - Posting keys
- `T074` + `T074U` + `T074T` - SGL indicators
- `TTYP` + `TTYPT` - Object type (AWTYP)
- `FINSTS_SLALITTY` + `FINSTS_SLALITTYT` - Subledger-Specific Line Item Types (SLALITTYPE)
- - `T008` + `T008T` - Blocking Reasons (for AP)
- Program `RGUGBR00` - regenerate Substitution and Validation
- `GB01` + view `VWTYGB01` - fields for Substitute

### Company code

- `T001` - Company codes
- `T001z` - Additional parameter for Company code
- `T001-ADRNR` -> `ADRC-ADDRNUMBER` - Long text + Addess
- `T001B` - FI open periods (**OB52**)
-  Tcode `OB72` - Global Company code customising

### Ledgers, AccPrinciples + Currencies 

### Chart of accounts

- `T004` + `T004T` - Chart of account
- `SKA1` + `SKAT` +`SKB1` - G/L Account Master
- `T011` + `T011T` - FSV (**OB58**)
- `FAGL_011ZC` - FSV: GL account assigment (**OB58**)

### Business partners (Vendors + Customers)

- `BUT000` - BP general data
- `BUT020` - BP addresses
- `DFKKBPTAXNUM` - Tax Numbers for Business Partner
- `LFA1` + `LFB1` - Supplier Master
- `LFBK` - Supplier bank data
- `KNA1` + `KNB1` - Customer Master
- `KNBK` - Customer bank data
- T881 

### Banks

- `BNKA` - Bank master record (**FI03**)
- Tcode `BAUP` for mass upload bank master data (customising in tcode **BA01**)
- Program `SAPF023` to reset bank master data

### Own banks + own bank accounts

- `T012` + `T012T` - Own Banks (**FI12**)
- `T012K`, `V_T012K_BAM`, `FCLM_BAM_DISTINCT_HBA` - Own Bank Accounts

### ACE and POAC objects

acac_objects

### FI-BL

Program `RFEBKA96` to detele bank statments

### Documents


### Others

#### HANA reports (fagll03h, fblXh etc):
- to show archived data - implement BAdI **FAGL_LIB**, as an example you may use a  **FAGL_LIB_ARCHIVE_VIA_INDEX**. 
- **HDBVIEWS** - tcode to add/customise FI reports
- **HDBC** - 
- [SAP Blog. How to extend FAGLL03h](https://blogs.sap.com/2020/12/20/how-to-extend-transaction-fagll03h-with-custom-fields/)

#### Some helpful FI OSS Notes:

- 2180685 – “FI Line Item Browsers and Archived Data”.
- 2408083 – “FAQ: Data Model of S/4 HANA Finance Data”.
- 2321684 - FI Line Item Browsers: Add master data fields to generated views

#### Other FI links

- 

## FI-AA

ORFA


## CO
cepct

## ML

## MM

## SD

## TM


