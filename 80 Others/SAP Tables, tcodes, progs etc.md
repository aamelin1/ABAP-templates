
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
| Class | `cl_gui_frontend_services=>file_open_dialog` | File open dialog | 
| Class | `CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD` | Upload file | 
| FM | `ALSM_EXCEL_TO_INTERNAL_TABLE` | Upload MS Excel file | 
| FM | `C14ALD_BAPIRET2_SHOW` | Show BAPI return messages | 
| FM | `F4_CONV_SELOPT_TO_WHERECLAUSE` | Convert WHERE conditions |
| FM | `RFC_READ_TABLE DESTINATION <dest>`  | Read data from other system|

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
- Tcode `GCX2` - Assign program to Substitution/Validation
- Program `RGUGBR00` - regenerate Substitution and Validation
- `GB01` + view `VWTYGB01` - fields for Substitute

SAP provide two programs that should be used to implement these user exits. These are `RGGBS000` and `RGGBR000` (for substitutions and rules respectively). The relevant program should be copied to a Z version of the program, `ZRGGBR000` for example.

To add own form, you need to specify form name as:

``` abap
   EXITS-NAME  = 'U100'.  
   EXITS-PARAM = C_EXIT_PARAM_NONE.        "Complete data used in exit.  
   EXITS-TITLE = TEXT-101.                 "Posting date check  
   APPEND EXITS.
```


| EXITS-PARAM | Comments |
|---|---|
| C_EXIT_PARAM_NONE | This constant means that no parameters are defined for this user exit. In truth, there is one parameter defined and that is a boolean flag that is used to specify whether there is an error in the data or not. A value of false for this parameter means that the data is valid(!) and a value of true means that there is an error. This parameter is valid for rules, validations and substitutions. |  
| C_EXIT_PARAM_FIELD | This constant is valid for substitutions only and means that one parameter can be defined for the user exit which is the field to be sustituted |   
| C_EXIT_PARAM_CLASS | valid for Rules, Validations and Substitutions, this parameter signifies that all the data (BKPF and BSEG data) will be passed as one parameter to the user exit. You will be passed a table containing all the relevant information | 
  


> 💡 More details here [FI Substitutions&Validations](../10%20How-Tos/FI%20Substitutions&Validations.md)

#### Open FI (BTE)

- Tcode `FIBF` - Maintenance transaction BTE

> 💡 More details here [FI FIBF OpenFI](../10%20How-Tos/FI%20FIBF%20OpenFI.md)

#### BAdIs, User-Exits, Enhancements

- `AC_DOCUMENT` - Change the Accounting Document
- `BADI_ACC_DOCUMENT` - FI doc
- `I_TRANS_DATE_DERIVE` - Change currency conversion
- `FAGL_LIB` - FI Line Item Browsers enhancements
- `BADI_GVTR_DERIVE_FIELDS` - BCF (FAGLGVTR)

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

- `fagl_splinfo`
- `fagl_splinfo_val`

Repair tables `fagl_splinfo` and `fagl_splinfo_val`:
``` abap
*** activate trace mode
    CALL FUNCTION 'G_TRACE_START'
      EXCEPTIONS
        trace_already_on = 1
        OTHERS           = 2.
    IF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*    CALL METHOD cl_fins_sif_services=>subseq_post_init.
    CALL METHOD cl_fins_sif_services=>subseq_post_set. " to avoid ML (and AA) relevat dump at repost process
*** submit FAGL_SUBSEQ_POSTING in trace mode
    CALL FUNCTION 'FAGL_SUBSEQ_POSTING'
      EXPORTING
        it_compcode_range   = r_bukrs[]
        it_fiscyear_range   = r_gjahr[]
        it_docnr_range      = r_belnr[]
        it_target_ledger    = lt_rldnr[]
        ib_process_splitter = abap_true
        ib_check_records    = abap_false
*** simulation!!
        ib_test             = abap_true
      EXCEPTIONS
        error_message       = 1
        OTHERS              = 2.
*** import GLU1 contents from memory
    IMPORT t_glu1 FROM MEMORY ID 'T_GLU1'.
*** import FAGL_SPLINFO/-_VAL data from memory
    CALL METHOD cl_fagl_oi_read=>get_splinfo_data_ext
      IMPORTING
        gt_out_splinfo     = t_splinfo
        gt_out_splinfo_val = t_val.
    READ TABLE t_splinfo ASSIGNING FIELD-SYMBOL(<check>) INDEX 1.
    IF <check> IS ASSIGNED.
      CHECK <check>-belnr = <bkpf>-belnr.
      UNASSIGN <check>.
    ENDIF.
    APPEND LINES OF t_splinfo TO lt_splinfo_sim.
    APPEND LINES OF t_val TO lt_val_sim.
*** free buffer
    CALL FUNCTION 'G_TRACE_STOP'
      EXCEPTIONS
        is_already_off = 1
        OTHERS         = 2.
    IF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
```



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
- Tcode `OB41` - Maintain Accounting Configuration : Posting Keys  
- Tcode `OBC4` - Maintain Field Status Group. The group can be assigned to account.
- FM `FI_FIELD_SELECTION_DETERMINE` - get field status

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

| Report | Structure | Customizing Include |
|---|---|---|
| Asset Balances | `FIAA_SALVTAB_RABEST` | `CI_REPRABEST` | 
| Asset History Sheet | `FIAA_SALVTAB_RAGITT` | `CI_REPRAGIT` | 
| Asset Transaction List | `FIAA_SALVTAB_RABEWG` | `CI_REPRABEWG` | 
| Planned Depreciation List | `FIAA_SALVTAB_RAHAFA` | `CI_REPRAHAFA` | 

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

## PS

BAPI_PS_INITIALIZATION
BAPI_BUS2054_CREATE_MULTI


## MM

BAPI_PO_CHANGE
BAPI_PR_CHANGE

ME_PROCESS_PO_CUST

## SD

## TM

How to find TM flow based on delivery number
1. Find order key 
Select PARENT_KEY  
From /SCMTMS/D_TORDRF  
Where BTD_ID = <Delivery#>
2. Fiend order number  
Select TOR_ID  
From /SCMTMS/D_TORROT  
Where DB_KEY = PARENT_KEY (from p.1) and LIFECYCLE <> ‘10’ (Canceled) and TOR_CAT = “TO” or “BO”

FSD document:
1. Зная ключ заказа найти номер ДРФ  
Перейти по ассоциации  /SCMTMS/TOR> BO_SFIR_ROOT _(__Работаем_ _с_ _БО_ _/SCMTMS/SUPPFREIGHTINVREQ)_
2. Удалить из внутренней таблицы записи где /SCMTMS/SUPPFREIGHTINVREQ> Root -Lifecycle = ‘06’ (Canceled)  
3. Взять значение оставшихся /SCMTMS/SUPPFREIGHTINVREQ> ROOT – SFIR_ID


