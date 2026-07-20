@AbapCatalog.sqlViewName: 'ZFI_ACD3_V'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ACDOCA с доп.данными'
define view ZFI_ACDOCA_ADD3 
//with parameters st_date:abap.dats
as 
select from acdoca 
    association [1..1] to skat
        on acdoca.racct = skat.saknr
        and skat.spras = $session.system_language
    association [1..1] to fagl_011zc as BS
        on acdoca.racct between BS.vonkt and BS.biskt
        and BS.versn = '1001'
    association [1..1] to fagl_011zc as PL
        on acdoca.racct between PL.vonkt and PL.biskt
        and PL.versn = '1002'
    association [1..1] to but000
        on acdoca.zzpartner = but000.partner
    association [1..1] to ztredm_card
        on acdoca.zzcontract = ztredm_card.zuonr
        and acdoca.rbukrs = ztredm_card.bukrs
    association [1..1] to acac_objects
        on acdoca.zzrbpobj = acac_objects.acac_objnumber
        and acdoca.rbukrs = acac_objects.bukrs
    association [1..1] to anla
        on acdoca.rbukrs = anla.bukrs
        and acdoca.zzanln1 = anla.anln1
    association [1..1] to cskt
        on acdoca.rcntr = cskt.kostl
        and cskt.spras = $session.system_language
    association [1..1] to aufk
        on acdoca.aufnr = aufk.aufnr
    association [1..1] to cepct
        on acdoca.prctr = cepct.prctr
        and cepct.spras = $session.system_language
{
  acdoca.rbukrs,
  acdoca.rldnr, 
//Счет ГК
  acdoca.racct,
  skat.txt50,
  BS.ergsl as BS,
  PL.ergsl as PL,
//ДП
  acdoca.zzpartner,
//  but000.type,
  case  but000.type
    when '2' then 
    concat( but000.name_org1, concat( but000.name_org2, concat( but000.name_org3, but000.name_org4 ) ) )
    when '1' then CONCAT_WITH_SPACE( but000.name_last, CONCAT_WITH_SPACE( but000.name_first, but000.namemiddle, 1 ), 1 )
    else ''
  end 
  as bpname,
//Договор
  acdoca.zzcontract,
  ztredm_card.fundscenter,
  ztredm_card.kurator,
  ztredm_card.bkurator,
  ztredm_card.pfundscenter,
  ztredm_card.pkurator,
  ztredm_card.recnbeg,
  ztredm_card.recnendabs,
  ztredm_card.recntxt,
  ztredm_card.recnnrext,
  ztredm_card.cardclass,
//РБП
  acdoca.zzrbpobj,
  acac_objects.text,
//ОС
  acdoca.zzanln1,
  anla.anlkl,
  anla.txt50 as ostxt, 
//  ANKT.txk50,
//данные документа
  acdoca.blart,
  acdoca.gjahr, 
  acdoca.poper,
  acdoca.belnr, 
  acdoca.buzei,
  acdoca.budat,
  acdoca.bldat, 
  case acdoca.drcrk
    when 'S' then 'Дт'
    when 'H' then 'Кт'
  end as DTCR,
  acdoca.hsl,  
  acdoca.rhcur,
  acdoca.xreversing, 
  acdoca.xreversed,
//МВЗ
  acdoca.rcntr,
  cskt.ltext,
//Заказ
  acdoca.aufnr,
  aufk.ktext,
//МВП
  acdoca.prctr,
  cepct.ktext as pctxt,
//Ссылочные ключи  

//ФП, ПФМ

//Прочее
  acdoca.sgtxt,
  acdoca.bstat
} 
 where acdoca.rrcty = '0' 
    and acdoca.bstat <> 'C'  
 
