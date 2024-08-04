
# Tcodes, table names, ABAP programs, BAdIs, BAPIs, SAP notes etc

## General

| Table | Comment |
| --- | --- |
| `AGR_USERS` | User-Roles assigments |
| `DBTABLOG` | table change logs |
| `E070`,`E071`,`E07T` | TRs |
| `TADIR` | Repository |
| `TRWPR` | RWIN processes (list of FMs) |
| `TRWCA` | RWIN components |
| `TRESE` | Reserved names |
| `SMEN_BUFFC` | User favorites |
| `TPARA` | Memory ID |
| `USR05` | Memory ID values by users |
| `SE16N_CD_KEY` | Logs of sap_edit (+ program RKSE16N_CD_DISPLAY) |

## FI

Main SAP tables:

### Company code
| Table | Comment |
| --- | --- |
| `Table` | Name |
T001
T001z

### Ledgers, AccPrinciples + Currencies 

### Chart of accounts
SKA1
SKAT
SKB1

### Business partners (Vendors + Customers)
BUT000
*BP*tax*
LFA1
LFB1
LFBK
KNA1
KNB1

### Banks

### Own banks + own bank accounts

### Documents




- to show archived data - implement BAdI **FAGL_LIB**, as an example you may use a  **FAGL_LIB_ARCHIVE_VIA_INDEX**. 
- **HDBVIEWS** - tcode to add/customise FI reports
- **HDBC** - 

Some helpful OSS Notes:

- 2180685 – “FI Line Item Browsers and Archived Data”.
- 2408083 – “FAQ: Data Model of S/4 HANA Finance Data”.
- 2321684 - FI Line Item Browsers: Add master data fields to generated views
- [SAP Blog. How to extend FAGLL03h](https://blogs.sap.com/2020/12/20/how-to-extend-transaction-fagll03h-with-custom-fields/)

## FI-AA

## CO

## MM

## SD

## TM


