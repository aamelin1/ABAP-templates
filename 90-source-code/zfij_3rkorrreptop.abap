***INCLUDE J_3RKORRREPTOP .

TYPE-POOLS: slis.

TABLES:
    bkpf,
    bseg,
    t001,
    skat,
*    ska1,
    skb1,
    j_3rk_corr_items,
    j_3rkkr0,
    kna1,
    lfa1,
    bhdgd,
    addr1_val.

DATA: line3(255)     TYPE c.
* for Drill-Down
DATA: ghkont LIKE bseg-hkont,
      ghsber LIKE glt0-rbusa,
      gsberk LIKE glt0-rbusa,
      gsberd LIKE glt0-rbusa,
*      gdk ,
      gkredit LIKE bseg-hkont,
      gdebet  LIKE bseg-hkont,
      gkside  TYPE c.
RANGES: gsdlifnr FOR bseg-lifnr,
        gsdkunnr  FOR bseg-kunnr,
        gsklifnr  FOR bseg-lifnr,
        gskkunnr FOR bseg-kunnr.
DATA:
    bdl LIKE sy-datum,
    bdh LIKE sy-datum,
    mnl LIKE bkpf-monat,
    mnh LIKE bkpf-monat.

DATA: zgo, zgk.

* tables of accounts and balances
DATA: BEGIN OF ss OCCURS 0,
      saknr    LIKE skat-saknr,
      sakan    LIKE ska1-sakan,
      gsber    LIKE bseg-gsber,
      txt50    LIKE skat-txt50,
      saldo_01 LIKE glt0-hslvt,  " beginning balance
      saldo_31 LIKE glt0-hslvt,  " ending balance
      turn_s   LIKE glt0-hslvt,  " debit turnover
      turn_h   LIKE glt0-hslvt,  " credit turnover
      END   OF ss.
DATA : ss1 LIKE TABLE OF ss WITH HEADER LINE.

* tables of grouped accounts and balances
DATA: BEGIN OF ssg OCCURS 0,
      saknr    LIKE skat-saknr,
      gsber    LIKE bseg-gsber,
      txt50    LIKE skat-txt50,
      saldo_01 LIKE glt0-hslvt,  " beginning balance
      saldo_31 LIKE glt0-hslvt,  " ending balance
      turn_s   LIKE glt0-hslvt,  " debit turnover
      turn_h   LIKE glt0-hslvt,  " credit turnover
      END   OF ssg.

* account correspondence table
DATA: BEGIN OF z OCCURS 0,
  bukrs LIKE j_3rk_corr_items-bukrs,
  belnr LIKE j_3rk_corr_items-belnr,
  gjahr LIKE j_3rk_corr_items-gjahr,
  buzeid LIKE j_3rk_corr_items-buzeid,
  buzeik LIKE j_3rk_corr_items-buzeik,
  addd LIKE j_3rk_corr_items-addd,
  addk LIKE j_3rk_corr_items-addk,
  npddi LIKE j_3rk_corr_items-npddi,
  npdki LIKE j_3rk_corr_items-npdki,
  blart LIKE j_3rk_corr_items-blart,
  budat LIKE j_3rk_corr_items-budat,
  monat LIKE j_3rk_corr_items-monat,
  xblnr LIKE j_3rk_corr_items-xblnr,
  koartd LIKE j_3rk_corr_items-koartd,
  debet LIKE j_3rk_corr_items-debet,
  xnegpd LIKE j_3rk_corr_items-xnegpd,
  koartk LIKE j_3rk_corr_items-koartk,
  kredit LIKE j_3rk_corr_items-kredit,
  xnegpk LIKE j_3rk_corr_items-xnegpk,
  dmbtr LIKE glt0-hslvt,
  hwaer LIKE j_3rk_corr_items-hwaer,
  wrbtr LIKE glt0-hslvt,
  waers LIKE j_3rk_corr_items-waers,
  dmbe2 LIKE glt0-hslvt,
  hwae2 LIKE j_3rk_corr_items-hwae2,
  dmbe3 LIKE glt0-hslvt,
  hwae3 LIKE j_3rk_corr_items-hwae3,
  itype LIKE j_3rk_corr_items-itype,
  usnam LIKE j_3rk_corr_items-usnam,
  cpudt LIKE j_3rk_corr_items-cpudt,
  cputm LIKE j_3rk_corr_items-cputm,
  codepos LIKE j_3rk_corr_items-codepos,
  gsberd LIKE j_3rk_corr_items-gsberd,
  gsberk LIKE j_3rk_corr_items-gsberk.
data: END   OF Z.

* grouped account correspondence table
DATA: BEGIN OF zg OCCURS 0,
       belnr  LIKE j_3rk_corr_items-belnr,
       budat  LIKE j_3rk_corr_items-budat,
       hkont  LIKE bseg-hkont,
       saknr  LIKE ska1-saknr,
       gsber  LIKE bseg-gsber,
*         kredit LIKE j_3rk_corr_items-kredit,
       shkzg  LIKE bseg-shkzg,
       buzeid LIKE j_3rk_corr_items-buzeid,
       buzeik LIKE j_3rk_corr_items-buzeik,
       koartd LIKE j_3rk_corr_items-koartd,
       koartk LIKE j_3rk_corr_items-koartk,
       dlifnr LIKE bseg-lifnr,
       dkunnr LIKE bseg-kunnr,
       klifnr LIKE bseg-lifnr,
       kkunnr LIKE bseg-kunnr,
       dmbtr  LIKE glt0-hslvt,
       hwaer  LIKE j_3rk_corr_items-hwaer,
      END   OF zg.

DATA:
 begtm       LIKE sy-uzeit,
 endtm       LIKE sy-uzeit,
 begdat      LIKE j_3rk_corr_items-budat,
 enddat      LIKE sy-datum,
 begdt       LIKE j_3rk_corr_items-budat,
 enddt       LIKE sy-datum,
 begmn       LIKE j_3rk_corr_items-monat,
 endmn       LIKE j_3rk_corr_items-monat,
 mn          LIKE j_3rk_corr_items-monat,
 gjahr       TYPE bkpf-gjahr,
 gjahr_h     TYPE bkpf-gjahr,
 poper       TYPE t009b-poper,
 saldo       LIKE glt0-hslvt,
 xsaldo      LIKE glt0-hslvt,
 dsaldo      LIKE glt0-hslvt,
 ksaldo      LIKE glt0-hslvt,

* debit turnovers
 do01_n      LIKE glt0-hslvt,
 don_k       LIKE glt0-hslvt,
 dok_31      LIKE glt0-hslvt,

* credit turnovers
 ko01_n      LIKE glt0-hslvt,
 kon_k       LIKE glt0-hslvt,
 kok_31      LIKE glt0-hslvt,

 period      TYPE i VALUE 0,
 nosc        TYPE i,
 i           TYPE i.

DATA:
 xdeb LIKE j_3rk_corr_items-debet,
 xkre LIKE j_3rk_corr_items-kredit.

DATA:
 no_auth_saknr_cnt TYPE i VALUE 0.

DATA: BEGIN OF gt_header OCCURS 0.
        INCLUDE STRUCTURE j_3rkorrrep_alv_header.
DATA:   acc_text LIKE skat-txt20,
        acc_longtext LIKE skat-txt50,
      END OF gt_header,

      BEGIN OF gt_item OCCURS 0.
        INCLUDE STRUCTURE zfij_3rkorrrep_alv_item.
DATA:   kside TYPE c,
      END OF gt_item.

DATA: g_repid LIKE sy-repid,
      g_tt(2) TYPE c,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_fieldcat TYPE slis_fieldcat_alv,
      gt_events   TYPE slis_t_event,          " Events
      gs_keyinfo  TYPE slis_keyinfo_alv,       " Key info
      gs_sort     TYPE slis_sortinfo_alv,
      gt_sort     TYPE slis_t_sortinfo_alv,
      g_sakln     LIKE t004-sakln.

DATA: rtcode   TYPE n.
DATA: g_not_found TYPE c,
      g_so_osnsc TYPE RANGE OF skat-saknr,
      gs_osnsc LIKE LINE OF g_so_osnsc,
      g_so_korsc TYPE RANGE OF skat-saknr.
DATA: g_so_osnsc2 TYPE RANGE OF skat-saknr,
      g_so_korsc2 TYPE RANGE OF skat-saknr.

DATA: g_current_vendor LIKE lfa1-lifnr,
      g_current_vname LIKE  lfa1-name1,
      g_current_customer LIKE kna1-kunnr,
      g_current_cname LIKE  kna1-name1.
TYPES: BEGIN OF t_vendors,
  lifnr LIKE lfa1-lifnr,
  name1 LIKE lfa1-name1,
END OF  t_vendors.

TYPES: BEGIN OF t_customers,
  kunnr LIKE kna1-kunnr,
  name1 LIKE kna1-name1,
END OF  t_customers.
DATA it_vendors TYPE SORTED TABLE OF t_vendors
      WITH NON-UNIQUE KEY lifnr
      WITH HEADER LINE.
DATA it_customers TYPE SORTED TABLE OF t_customers
      WITH NON-UNIQUE KEY kunnr
      WITH HEADER LINE.
*New GL
DATA: gv_rldnr TYPE fagl_rldnr,
      gv_periv TYPE periv,
      gs_org_info TYPE glx_org_info.

DATA: gv_diff type j_3rk_beg_balance. "1874952

data: gv_langu like sy-langu. "note 1886074

data: gv_saknr_tmp TYPE char10. "2050745


DATA: go_control TYPE REF TO i_oi_container_control,
      go_document1 TYPE REF TO i_oi_document_proxy,
      go_container TYPE REF TO cl_gui_custom_container,
      go_spreadsheet TYPE REF TO i_oi_spreadsheet.
DATA: document_handle TYPE CNTL_HANDLE.
" OLE
DATA: g_excel          TYPE ole2_object,
      sheet TYPE ole2_object,
      CELL1 TYPE ole2_object,
      CELL2 TYPE ole2_object,
      CELLRANGE TYPE ole2_object,
      interior TYPE ole2_object,
      font     TYPE ole2_object,
      gs_activewindow TYPE  ole2_object.
