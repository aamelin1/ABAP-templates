# Происхождение и пересечения источников

Как собрана `SAP notes2` и какие решения приняты. Исходные репозитории/вики не тронуты — при необходимости всё можно пересобрать.

## Источники
- **A** = `aamelin1/ABAP-templates` (= локальная `SAP FI/Untitled/`) — EN, причёсанная.
- **B** = `aamelin1/SAP-FI-notes` → папка `ABAP temp/` — сырой ABAP-код.
- **C** = `aamelin1/SAP-FI-notes.wiki` — 17 русских статей (основная проза).
- **D** = выгрузка из **Notion** (`ExportBlock-…`) — ✅ пришла: 37 заметок (EN) + 44 картинки. Самый свежий и полный срез.

## Что откуда взято
- **Проза заметок** — из **C** (русские статьи вики), это канонические версии.
- **Уникальный код** (корреспонденция, сравнение регистров/ПС, курсы, налоговый/accrual отчёт, миграция ОС R2R, BAdI амортизации) — из **B**, разложен в `90 Source code/`, к нему написаны короткие заметки-черновики.
- **EN-заметки, которых нет в C** (загрузка ЖЭ Fiori, repair fagl_splinfo, revaluation areas, MM-классификация, ALV OO/Others, CDS tips, сниппеты, большой справочник) — из **A**, перенесены как есть, помечены **(перевести)**.
- **Блог и часть шаблонного кода** — из **A**.

## Дубли: канон C (RU), EN-версия из A НЕ копировалась
Эти темы есть и в A (EN), и в C (RU) — взята русская версия из C; EN-оригинал остаётся в репозитории A:
- Поиск BAdI (A: `ABAP Find BAdIs`)
- Перенос запросов копиями ToC (A: `BC Transport of copies`)
- RWIN интерфейс (A: `FI RWIN interface`)
- Шаблон классического ALV (A: `ALV_01 …LVC`)
- Создание CDS / IDA (A: `ALV_04 IDA`)
- Отчёты ALV PIVB (A: `ALV_05 PIVB` — там была заглушка)
- Отчёт пользователи/роли (A: `BC Users vs Roles` — заглушка)
- Отчёт по транспортным запросам (A: `TRC …` — заглушка)

## Нужно свести при переводе (в A есть РУССКАЯ версия, возможно с уникальными деталями)
Сравнить с канонической версией из C и добить недостающее:
- `A: FI CoA Transport` (RU) ↔ **Перенос счетов ГК между системами**
- `A: FI Offsetting accounts` (RU) ↔ **Корреспонденция счетов**
- `A: FI_FAGL_FCV add BP` (RU) ↔ **Обогащение аналитикой FAGL_FCV**
- `A: SAPGUI Tips` (EN) ↔ **Раскраска систем и настройки SAP Logon**
- `A: Working with ranges`, `BDC Batch input macro` (EN) ↔ разделы в **ABAP шаблоны**
- ~~`70 Reference`: большой EN-справочник ↔ краткий RU~~ — ✅ сведены в один файл `Справочник — таблицы, транзакции, программы, BAdI.md` (внутренние ссылки перепривязаны на структуру SAP notes2); осталось перевести на RU.

## Прочее
- Дубль кода `ZBC_USERS_ROLES` в B (в т.ч. lowercase) не копировался — взята версия из A.
- Картинки статей C ссылаются на GitHub-вложения по URL (`…/assets/…`) — отображаются, при желании локализуем в `IMGs/` (нужно скачивание — по запросу).
- Два битых якоря `/_edit#` в «Корреспонденции счетов» исправлены на внутридокументные ссылки.

## Notion (D) — что влито
Добавлены как EN-заметки **(перевести)** темы, которых НЕ было в сборке (новые + заполнены прежние «to do»):
- 10 FI: Validations & substitutions, Mass FRBA (reset clearing), Post doc via BAPI, Upload Exchange Rates (Argentina)
- 30 CO-ML: Split COGS account by CC
- 50 ABAP: Read variables from callstack, Read table from other SAP system, Strings and chars, Drilldown to display, Popup with ALV
- 60 Basis & Tools: Logs and changes history, Statistic report (Docs count)

**Дубли из Notion (EN-версия ЕСТЬ, но не копировалась — уже покрыто в сборке):** ALV FM/IDA/OO SALV/Other features/PIVB, BDC macro, CDS functions, Dates conversion, Dynamic SQL, FI Add BP FAGL_FCV, FI CoA Transport, FI RWIN interface, Find BAdI, GUI Language Switcher, SAPGUI Tips, Transport of copies, Users vs Roles, TRC, MM classification, Progress bar, Popup (text editor), Graphs FI T-view, LP Simplex, Upload Exchange Rates (Brazil), Tcodes reference.
> ⚠️ Notion — самый свежий срез. При переводе для КАЖДОЙ темы выбирать лучшую из версий {вики RU · Notion EN · repo A EN}; возможно, для части тем Notion-версия полнее и должна заменить текущую.

## Блог (80 Blog posts)
Собран из приложенных `.docx` (6 файлов, папка `Desktop/SAP Blog`) — конвертация в markdown с картинками. Источник-первоисточник — посты SAP Community (ссылки проставлены в заметках).

## Осталось
- Перевести всё, помеченное **(перевести)**, и дооформить черновики.
- Свести дубли (см. выше) — по одной лучшей версии на тему.
- FI-AA темы без содержания, CO-ML/CCS — дописать (частично поможет чтение программ из SAP DEV).
- Проверить подключение к **SAP DEV** и добавить несколько программ (по запросу пользователя).
