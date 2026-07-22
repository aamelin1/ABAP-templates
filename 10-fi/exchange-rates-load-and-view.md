---
title: "Курсы валют — загрузка и просмотр (TCURR)"
keywords: TCURR, exchange rates, курсы валют, загрузка курсов, ЦБ Бразилии, BCB, BAPI1093_0, просмотр курсов
status: draft
summary: "Набор утилит: загрузка курсов ЦБ Бразилии, выгрузка и просмотр TCURR — код есть, описание дописать"
source:
  - 90-source-code/zfi_upload_exchange_rates_br.abap
  - 90-source-code/zfi_download_cur.abap
  - 90-source-code/zfi_download_cur_top.abap
  - 90-source-code/zfi_download_cur_sscr.abap
  - 90-source-code/zfi_download_cur_events.abap
  - 90-source-code/zfi_show_curr.abap
---

# Курсы валют — загрузка и просмотр (TCURR)

Набор утилит по курсам валют (таблица **TCURR**): загрузка курсов из внешних источников (напр. ЦБ Бразилии), скачивание и просмотр курсов.

**Исходный код:**
- [ZFI_UPLOAD_EXCHANGE_RATES_BR.abap](../90-source-code/zfi_upload_exchange_rates_br.abap) — загрузка курсов ЦБ Бразилии
- [ZFI_DOWNLOAD_CUR.abap](../90-source-code/zfi_download_cur.abap) (+ [TOP](../90-source-code/zfi_download_cur_top.abap), [SSCR](../90-source-code/zfi_download_cur_sscr.abap), [EVENTS](../90-source-code/zfi_download_cur_events.abap))
- [ZFI_SHOW_CURR.abap](../90-source-code/zfi_show_curr.abap) — просмотр курсов
