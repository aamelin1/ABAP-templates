
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
| `T100` + `T100C` + `T100S` | Message control |

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
| `OBA5` | Message controls

### FMs, Classes, BAdI, BAPI:

| Type | Object | Comment |
| --- | --- | --- |
| Class | `CL_EXITHANDLER` | Method `GET_INSTANCE`. Put breakpoint here and run tcode to get BAdIs names |
| Class | `xco_cp=>current->call_stack->full( )` | Get current callstack |
| Class | `CL_BALI_LOG` | Logs |
| Class | `XCO_CP_GENERATION` | Generate repositary objects |
| BAPI | `BAPI_TRANSACTION_ROLLBACK` | Rollback |
| BAPI | `BAPI_TRANSACTION_COMMIT` | Commit |


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

### FI enhancements:

#### Substitutions and Validations:

- Tcode `GGB1` - Substitution Maintenance
- Tcode `GGB0` - Validation Maintenance
- Tcode `OBBH` - Assign Substitution to Company code and activation status
- Program `RGUGBR00` - regenerate Substitution and Validation
- `GB01` + view `VWTYGB01` - fields for Substitute

> 💡 More details here [FI Substitutions&Validations](../10_How-Tos/FI%20Substitutions&Validations.md)

#### Open FI (BTE)

- Tcode `FIBF` - Maintenance transaction BTE

> 💡 More details here [FI FIBF OpenFI](../10_How-Tos/FI%20FIBF%20OpenFI.md)

#### BAdIs, User-Exits, Enhancements

- `AC_DOCUMENT` - Change the Accounting Document
- `BADI_ACC_DOCUMENT` - FI doc
- `I_TRANS_DATE_DERIVE` - Change currency conversion
- `FAGL_LIB` - FI Line Item Browsers enhancements
- `BADI_GVTR_DERIVE_FIELDS` - BCF (FAGLGVTR)

### FI BAPIs and FMs

- `BAPI_ACC_DOCUMENT_POST` - post FI doc
- `BAPI_ACC_DOCUMENT_REV_POST` - reverse FI doc

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

### FI-BL, Banks, Own banks + own bank accounts

- `BNKA` - Bank master record (**FI03**)
- Tcode `BAUP` for mass upload bank master data (customising in tcode **BA01**)
- Program `SAPF023` to reset bank master data
- `T012` + `T012T` - Own Banks (**FI12**)
- `T012K`, `V_T012K_BAM`, `FCLM_BAM_DISTINCT_HBA` - Own Bank Accounts
- Program `RFEBKA96` to detele bank statments

### ACE and POAC objects

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

- Tcode `ORFA` - SPRO for FI-AA
- Tcode `FAA_CMP`, `FAA_CMP_LDT` - FI-AA Legacy Data Transfer Settings


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

## MM

## SD

## TM


