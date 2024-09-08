# Tcodes, table names, ABAP programs, BAdIs, BAPIs, SAP notes etc

- [General (ABAP, Basis, tech etc)](#General-(ABAP,-Basis,-tech-etc))
- [FI: Finance](#FI)
- [FI-AA: Fixed Asset](#FI-AA)
- [CO: Controlling](#CO)
- [ML: Material Ledger](#ML)
- [MM: Material Management](#MM)
- [SD: Sales and Distribution](#SD)
- [TM: Transportation Management](#TM)

## General (ABAP, Basis, tech etc)

<details><summary><b>Users and Roles</b></summary>

- `USR01` - User master record
- `AGR_USERS` - User-Roles assigments
- `AGR_TEXTS` - Role texts
- `SMEN_BUFFC` - User favorites 
- `USR05` - Memory ID values by users 
- BAPI `BAPI_USER_GET_DETAIL` - Get user details
- [Custom report: Users vs Roles](../60%20ABAP%20reports%20and%20tools/BC%20Users%20vs%20Roles.md)

</details>


<details><summary><b>Logs</b></summary>

| Type of logs | SAP objects |
|---|---|
| Table content | `SCU3`- tcode to Table History display <br>`DBTABLOG` - table for change logs |
| Change documents | `RSSCD100` - tcode to Change documents display <br>`CDHDR` + `CDPOS` Tables of Change documents <br>`CHANGEDOCUMENT_DISPLAY` - FM to Show change documents |
| Direct SAP tables updates | `SE16N_CD_KEY` -  Logs of `&sap_edit` <br> `RKSE16N_CD_DISPLAY` - program to show logs of `&sap_edit` |
| Standard logging | `SLGx` - tcodes of Application Log <br>`CL_BALI_LOG` - Class  Working with SLGx Logs  | 

> 💡 `C14ALD_BAPIRET2_SHOW` - FM to show BAPI return messages

</details>


<details><summary><b>Monitors, Trace etc</b></summary>

- Tcode `SXI_MONITOR` - XI: Message Monitoring 
- Tcode `ST05` -  Performance Trace
- Tcode `SM36` + `SM37` - BackGround Jobs
- Tcode `SM50` - Work Processes
- Tcode `SM51` - Started AS Instances
- Tcode `STAD` - Statistics display
- Tcode `DBACOCKPIT` or `DB02` - DBA Cockpit
- Tcode `SM59` - RFC Destinations
- Tcode `SM12` - Display and Delete Locks
- Tcode `AL11` - Display SAP Directories
- Tcode `WE20` - Partner Profiles

</details>

<details><summary><b>ABAP Dev tools</b></summary>

- `TPARA` - Memory ID 
- `E070`,`E071`,`E07T` - TRs 
- `TADIR` - Repository
- `TRESE` - Reserved names
- Tcode `SAT` - ABAP Trace
- Tcode `ICON` - Display Icons
- Tcode `DWDM` - Development Workbench Demos
- Tcode `SNUM` or `SNRO` - Number Range Object
- Class `cl_gui_frontend_services=>file_open_dialog` - File open dialog
- Class `CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD` - Upload file
- FM `ALSM_EXCEL_TO_INTERNAL_TABLE` - Upload MS Excel file
- FM `F4_CONV_SELOPT_TO_WHERECLAUSE` - Convert WHERE conditions
- FM `RFC_READ_TABLE DESTINATION <dest>` - Read data from other system
- Class `XCO_CP_GENERATION` - Generate repositary objects
- Class `xco_cp=>current->call_stack->full( )` - Get current callstack

💡 In the example, a line pattern is created (method that starts with a specific pattern). The extracting should go up to the last occurrence of this pattern. It is started at position 1.
``` abap
DATA(line_pattern) = xco_cp_call_stack=>line_pattern->method(
  )->where_class_name_starts_with( 'CL_REST' ).
DATA(extracted_call_stack_as_text) = call_stack->from->position( 1
  )->to->last_occurrence_of( line_pattern )->as_text( format ).
```  

</details>


<details><summary><b>BuiltIn ABAP inline functions</b></summary>

- itab lines count: `DATA(lv_lines_count) = lines( strtab ).`
- String length: `DATA(lv_strlen) = strlen( 'abc   ' ).  " -> 3`
- numofchar `DATA(lv_count_chars) = numofchar( `abc   ` ). " -> 3`
- String concatenation: `DATA(lv_res_str) = str1 && ` ` && str2.`
- or String concatenation: `DATA(lv_res_str) = |{ str1 }| && ` ` && |{ str2 }|.`
- or: String concatenation `CONCATENATE str1 str2 INTO DATA(lv_res_str) SEPARATED BY ` `. "Concat with space`
- String concatenation from itab: `DATA(lv_res_str) = concat_lines_of( table = itab sep = ` ` ).`
- Absolute value: `DATA(lv_abs) = abs( -4 ). "4`
- Value sign (-1 if negative, 0 if 0, 1 if positive):  `DATA(sign1) = sign( -789 ). "-1`
- Rounding: `DATA(lv_round) = round( val = CONV decfloat34( '1.2374' ) dec = 2 ). "1.24`
- more details here: [ABAP BuiltIn inline functions](../01%20ABAP%20templates/ABAP%20BuiltIn%20inline%20functions.md)

</details>

<details><summary><b>Others</b></summary>

- `T100` + `T100C` + `T100S` - Message control
- Tcode `OBA5` - Message controls
- Class `CL_EXITHANDLER`  method `GET_INSTANCE` - Put breakpoint here and run tcode to get BAdIs names. See [ABAP Find BAdIs](../10%20How-Tos/ABAP%20Find%20BAdIs.md)
- BAPI `BAPI_TRANSACTION_ROLLBACK` - Rollback
- BAPI `BAPI_TRANSACTION_COMMIT` - Commit

</details>

---

## FI

### FI enhancements:

<details><summary><b>Substitutions and Validations</b></summary>

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


| EXITS-PARAM        | Comments                                                                                                                                                                                                                                                                                                                                                                                                 |
|:------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C_EXIT_PARAM_NONE  | This constant means that no parameters are defined for this user exit. In truth, there is one parameter defined and that is a boolean flag that is used to specify whether there is an error in the data or not. A value of false for this parameter means that the data is valid(!) and a value of true means that there is an error. This parameter is valid for rules, validations and substitutions. |
| C_EXIT_PARAM_FIELD | This constant is valid for substitutions only and means that one parameter can be defined for the user exit which is the field to be sustituted                                                                                                                                                                                                                                                          |
| C_EXIT_PARAM_CLASS | valid for Rules, Validations and Substitutions, this parameter signifies that all the data (BKPF and BSEG data) will be passed as one parameter to the user exit. You will be passed a table containing all the relevant information                                                                                                                                                                     |
  


> 💡 More details here [FI Substitutions&Validations](../10%20How-Tos/FI%20Substitutions&Validations.md)
</details>

<details><summary><b>Open FI (BTE)</b></summary>

- Tcode `FIBF` - Maintenance transaction BTE

> 💡 More details here [FI FIBF OpenFI](../10%20How-Tos/FI%20FIBF%20OpenFI.md)

<details><summary><b>BAdIs, User-Exits, Enhancements</b></summary>

- `AC_DOCUMENT` - Change the Accounting Document
- `BADI_ACC_DOCUMENT` - FI doc
- `I_TRANS_DATE_DERIVE` - Change currency conversion
- `FAGL_LIB` - FI Line Item Browsers enhancements
- `BADI_GVTR_DERIVE_FIELDS` - BCF (FAGLGVTR)
- `TRWPR` - RWIN processes (list of FMs)
- `TRWCA` - RWIN components
- [FI RWIN interface](../10%20How-Tos/FI%20RWIN%20interface.md)

</details>

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

