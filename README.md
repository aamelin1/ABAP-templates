# ABAP templates and SAP notes

Личная база знаний SAP-консультанта (FI): ABAP-шаблоны, how-to заметки по FI/FI-AA/CO-ML/MM,
утилиты Basis, справочники и архив блог-постов SAP Community. Заметки — обычные Markdown-файлы
(частью на русском, частью на английском), исходники ABAP лежат в [`90-source-code/`](90-source-code/).

## Как устроено

- Разделы по модулям/назначению: `10-fi` … `80-blog`; картинки — в `img/` внутри раздела.
- У каждой заметки YAML-frontmatter (`title`, `keywords`, `status`, `summary`, `source`) —
  правила в [docs/NOTE-TEMPLATE.md](docs/NOTE-TEMPLATE.md), архитектура — в [docs/KB-ARCHITECTURE.md](docs/KB-ARCHITECTURE.md).
- Для ИИ-ассистентов есть индекс [llms.txt](llms.txt) с raw-ссылками и keywords.
- Пометка *(черновик)* — заметка полезна, но не дописана или ждёт перевода.

## Оглавление

### 10 FI — Финансы (GL / AP / AR)

- [Сравнение регистров (леджеров) в ACDOCA](10-fi/compare-ledgers.md): Отчёт сверки сумм между ведущим и параллельными регистрами — код есть, описание дописать *(черновик)*
- [Курсы валют — загрузка и просмотр (TCURR)](10-fi/exchange-rates-load-and-view.md): Набор утилит: загрузка курсов ЦБ Бразилии, выгрузка и просмотр TCURR — код есть, описание дописать *(черновик)*
- [FAGL_FCV — обогащение документов переоценки аналитикой контрагента (VPTNR, RASSC)](10-fi/fagl-fcv-add-bp.md)
- [Отчёты FAGLL03H, FBL1/3/5H (PIVB) в S/4HANA — инструкция](10-fi/fagll03h-fblxh-pivb-reports.md)
- [Перенос счетов ГК между системами — транспортом и через IDoc (BD18)](10-fi/gl-accounts-transfer-between-systems.md)
- [Mass reset clearing (FBRA) — batch input report](10-fi/mass-fbra-reset-clearing.md): Z-report ZFI_MASS_FBRA: массовый сброс выравнивания через BDC по выборке из BKPF, с обработкой попапа курсовых разниц (KDF) *(черновик)*
- [Корреспонденция счетов — GKONT, локализация РФ (J3RF), разделение в ACDOCA](10-fi/offsetting-accounts-gkont-j3rf-acdoca.md): Три решения: GKONT без локализации, новая ПКС S/4HANA (сплит позиций в ACDOCA), старое J3RF-решение — настройки, таблицы, доработки FB03/FAGLL03H
- [Post FI document via BAPI_ACC_DOCUMENT_POST (with extension fields)](10-fi/post-fi-document-via-bapi.md): Заполнение header/GL/AP/currency, передача доп. полей через EXTENSION2 + BADI_ACC_DOCUMENT~CHANGE, разноска сторно *(черновик)*
- [Repair FAGL_SPLINFO — simulate document splitting for posted docs](10-fi/repair-fagl-splinfo.md) *(черновик)*
- [RWIN интерфейс — как SAP вызывает ФМ при проводке FI документов](10-fi/rwin-interface.md)
- [Upload exchange rates from Argentina Central Bank (BCRA API)](10-fi/upload-exchange-rates-argentina.md) *(черновик)*
- [Upload journal entries via Fiori app (F2548)](10-fi/upload-journal-entries-fiori.md) *(черновик)*
- [FI validations and substitutions (GGB0/GGB1)](10-fi/validations-and-substitutions.md) *(черновик)*

### 20 FI-AA — Основные средства

- [Массовое выбытие ОС из файла (BAPI_ASSET_RETIREMENT_POST)](20-fi-aa/asset-mass-retirement.md): Z-отчёт ZR2R_AA_MASS_RET: выбытие/списание ОС списком из Excel-файла с превью в ALV и отвязкой единиц оборудования *(черновик)*
- [Миграция ОС — начальная загрузка остатков из файла (BAPI_FIXEDASSET_OVRTAKE_CREATE)](20-fi-aa/asset-migration-initial-load.md): Комплект ZR2R_AA_MIGRATION: загрузка остатков по ОС из Excel через BAPI1022-структуры, маппинг колонок настраивается таблицей без правки кода *(черновик)*
- [FI-AA revaluation areas (AR29N)](20-fi-aa/revaluation-areas.md): Указатель на SAP Note 2332517 по областям переоценки — заметку дополнить *(черновик)*

### 30 CO-ML — Контроллинг / Material Ledger

- [Split COGS account by cost components (ML)](30-co-ml/split-cogs-by-cost-components.md) *(черновик)*

### 40 MM — Управление запасами

- [Material and batch classification via CDS (INOB/AUSP)](40-mm/material-batch-classification.md) *(черновик)*

### 50 ABAP — шаблоны и приёмы

- [ALV via OO SALV (CL_SALV_TABLE) — template](50-abap/alv-oo-salv.md) *(черновик)*
- [ALV features — colors and selection mode](50-abap/alv-other-features.md) *(черновик)*
- [Отчёты ALV PIVB — свой pivot-отчёт на CDS](50-abap/alv-pivb-reports.md)
- [BDC batch input macro](50-abap/bdc-batch-input-macro.md) *(черновик)*
- [ABAP built-in functions — lines, strlen, concat, abs, sign, round](50-abap/builtin-functions.md) *(черновик)*
- [Создание CDS и отчёты IDA (ALV on HANA)](50-abap/cds-and-ida-reports.md)
- [CDS tricks & tips — session variables and string functions](50-abap/cds-tricks-and-tips.md) *(черновик)*
- [Шаблон классического ALV (REUSE_ALV_GRID_DISPLAY_LVC)](50-abap/classic-alv-template.md)
- [Working with dates in ABAP](50-abap/dates-conversion.md) *(черновик)*
- [Drilldown to display documents (FB03, MIGO, BP, ME23N…)](50-abap/drilldown-to-documents.md) *(черновик)*
- [Dynamic SQL select in ABAP](50-abap/dynamic-sql.md) *(черновик)*
- [Graphs in SAP via Graphviz (HTML)](50-abap/graphs-graphviz-html.md): Заготовка: что такое граф и Graphviz; раздел «как показать граф в SAP» не дописан — см. блог-пост 02 *(черновик)*
- [ABAP шаблоны — макрос BDC, ranges, прогресс-индикатор, popup](50-abap/macros-ranges-counter.md)
- [Popup windows — ALV grid and text editor](50-abap/popup-windows.md) *(черновик)*
- [Popup with ALV (CL_RECA_GUI_F4_POPUP)](50-abap/popup-with-alv.md) *(черновик)*
- [Progress indicator (CL_PROGRESS_INDICATOR)](50-abap/progress-indicator.md) *(черновик)*
- [Read table from another SAP system via RFC_READ_TABLE](50-abap/read-table-from-other-system.md) *(черновик)*
- [Read variables from callstack](50-abap/read-variables-from-callstack.md) *(черновик)*
- [Strings and chars in ABAP](50-abap/strings-and-chars.md) *(черновик)*
- [Working with ranges](50-abap/working-with-ranges.md) *(черновик)*

### 60 Basis & Tools — администрирование и утилиты

- [Поиск BAdI в любой транзакции](60-basis-tools/find-badi.md)
- [Logs and change history in SAP](60-basis-tools/logs-and-change-history.md) *(черновик)*
- [Раскраска систем и настройки SAP Logon](60-basis-tools/sap-logon-colors-and-settings.md)
- [Переключение языка SAP Logon на лету](60-basis-tools/sap-logon-language-switcher.md)
- [SAPGUI / SAP Logon tips — colors, settings, shortcuts](60-basis-tools/sapgui-tips.md) *(черновик)*
- [Statistic report — documents count by customizable rules](60-basis-tools/statistic-report-docs-count.md): Z-report ZFI_STAT_REP: считает документы по правилам из Z-таблицы (таблица/поле/дата), день-за-днём или на дату, drill-down в список документов *(черновик)*
- [Перенос запросов копиями (Transport of Copies)](60-basis-tools/transport-of-copies.md)
- [Отчёт по транспортным запросам — статус переноса по ландшафту](60-basis-tools/transport-requests-status-report.md)
- [Отчёт «пользователи ↔ роли» — матрица полномочий](60-basis-tools/users-roles-matrix-report.md)

### 70 Reference — справочники

- [Справочник SAP — таблицы, транзакции, программы, BAdI по модулям](70-reference/sap-tables-tcodes-programs-badi.md): Большой справочник по модулям: транзакции, таблицы, программы, ФМ/BAPI, BAdI и полезные ноты *(черновик)*

### 80 Blog — архив постов SAP Community

- [Blog: Create a simple CDS view and show data as an IDA report (ALV on HANA)](80-blog/01-cds-view-ida-report.md)
- [Blog: Graphs — another way to show SAP ERP data](80-blog/02-graphs-show-sap-erp-data.md)
- [Blog: Custom PIVB ALV report based on a CDS with parameters](80-blog/03-pivb-alv-report-cds-parameters.md)
- [Blog: SAP Logon online language switcher](80-blog/04-sap-logon-language-switcher.md)
- [Blog: Linear programming in ABAP — Simplex method, find optimized BOM](80-blog/05-linear-programming-simplex-bom.md)
- [Блог (черновик RU): Formulador — линейное программирование в ABAP](80-blog/05-ru-formulador-draft.md) *(черновик)*

## Полезные ссылки

- [GitHub SAP-samples: ABAP cheat sheets](https://github.com/SAP-samples/abap-cheat-sheets)
- [FIORI apps library](https://fioriappslibrary.hana.ondemand.com/sap/fix/externalViewer/#/home)

---

*Author: Andrei Amelin, SAP FI consultant. License: [MIT](LICENSE).*
