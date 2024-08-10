
CDS for material classification:

``` abap cds
@AbapCatalog.sqlViewName: 'ZVMM_MAT_CLASS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Classification CDS View'
define view zvmm_material_classification as 
select from mara as ma
  inner join inob as in on in.objek = ma.matnr
  inner join ausp as au on in.cuobj = au.objek
             and in.klart = au.klart
  left outer join cabn as cb on au.atinn = cb.atinn
             and au.adzhl = cb.adzhl
  left outer join cawn as ca on au.atinn = ca.atinn
             and au.atwrt = ca.atwrt
  left outer join cawnt as ct on au.atinn = ct.atinn
             and ca.atzhl = ct.atzhl
             and au.adzhl = ct.adzhl
             and ct.spras = $session.system_language  
{
  key ma.matnr as material,     //Material Number
  key cb.atnam as code,         //Material Classification Segment
  au.atwrt as value1,           //UnConverted Value of Code
  ct.atwtb as value2,           //Converted Value of Code
  au.atflv as alt_value         //Alternate Value of Code
}
where in.klart = '001'
and  in.obtab = 'MARA'
and  au.mafid = 'O'
```

CDS for batch classification:

``` abap cds
@AbapCatalog.sqlViewName: 'ZVMM_BAT_CLASS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'batch_classification'
define view zvmm_batch_classification as
select from mch1 as mc
  inner join inob as in 
             on  mc.matnr = left(in.objek,18)
             and  mc.charg = right(in.objek, 10)
  inner join ausp as au on in.cuobj = au.objek
             and in.klart = au.klart
  left outer join cabn as cb on au.atinn = cb.atinn
             and au.adzhl = cb.adzhl
  left outer join cawn as ca on au.atinn = ca.atinn
             and au.atwrt = ca.atwrt
  left outer join cawnt as ct on au.atinn = ct.atinn
             and ca.atzhl = ct.atzhl
             and au.adzhl = ct.adzhl
             and ct.spras = $session.system_language  
{
  key mc.matnr as material,     //Material Number
  key mc.charg as batch,        //Batch Number
  key cb.atnam as code,         //Material Classification Segment
  au.atwrt as value1,           //UnConverted Value of Code
  ct.atwtb as value2,           //Converted Value of Code
  au.atflv as alt_value        //Alternate Value of Code
}
where in.klart = '023'
and  in.obtab = 'MCH1'
and  au.mafid = 'O'

```