
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

### FMs:

| FM | Comment |
| --- | --- |

### Tcodes:

| Tcode | Comment |
| --- | --- |

### Programs:

| Program | Comment |
| --- | --- |


## FI

- `T003` + `T003T` - Document types
- `TBSL` + `TBSLT` - Posting keys
- `T074` + `T074U` + `T074T` - SGL indicators
- `TTYP` + `TTYPT` - Object type (AWTYP)
- `FINSTS_SLALITTY` + `FINSTS_SLALITTYT` - Subledger-Specific Line Item Types (SLALITTYPE)
- - `T008` + `T008T` - Blocking Reasons (for AP)

### Company code

- `T001` - Company codes
- `T001z` - Additional parameter for Company code
- `T001-ADRNR` -> `ADRC-ADDRNUMBER` - Long text + Addess
- `T001B` - FI open periods (**OB52**)

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

### Documents


### Others

#### HANA reports (fagll03h, fblXh etc):
- to show archived data - implement BAdI **FAGL_LIB**, as an example you may use a  **FAGL_LIB_ARCHIVE_VIA_INDEX**. 
- **HDBVIEWS** - tcode to add/customise FI reports
- **HDBC** - 
- - [SAP Blog. How to extend FAGLL03h](https://blogs.sap.com/2020/12/20/how-to-extend-transaction-fagll03h-with-custom-fields/)

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


