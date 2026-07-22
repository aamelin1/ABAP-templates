# Source code — исходники ABAP

Соглашение об именах: `Z<модуль>_...` (`ZFI_` — финансы, `ZBC_` — Basis, `ZR2R_` — проект миграции ОС). Классические отчёты разбиты на инклюды: основной + `_TOP` (данные) + `_F01`/`_FORMS` (формы).

## FI — отчёты и утилиты
- Корреспонденция счетов: `ZFIJ_3RKORRREP` (+ `TOP`, `_FORMS`, структура `_ALV_ITEM`)
- Сравнение планов счетов между системами: `ZFI_COA_COMP`
- Сравнение регистров: `ZFI_COMP_LEDGERS` (+ структура SE11)
- Позиции ГК (IDA на CDS): `ZFI_GLREP_ITEMS (IDA...)`
- Курсы валют: `ZFI_UPLOAD_EXCHANGE_RATES_BR`, `ZFI_DOWNLOAD_CUR` (+ `_TOP/_SSCR/_EVENTS`), `ZFI_SHOW_CURR`
- Accrual Engine / налоговый отчёт: `ZFI_RBP_TAX_REP` (+ `_TOP/_F01`, структура)

## FI-AA — проект R2R
- Миграция ОС: `ZR2R_AA_MIGRATION` (+ `_F01`), `ZSR2R_MIGRATION_MAP`, таблица `ZTR2R_AA_MIGRCUS` + ведение `ZVR2R_AA_MIGRCUS`
- Массовое выбытие: `ZR2R_AA_MASS_RET`
- Амортизация по дням (BAdI): `IF_EX_FAA_DC_CUSTOMER~SET_PARAMETER`, `~DEFINE_USE_OF_MAX_PERIODS`, `IF_EX_FAA_EE_CUSTOMER~SET_PERCENT_AMOUNT`

## ABAP — шаблоны
- Классический ALV: `ZFI_ALV_FM_template`, `ALV_grid_templ1`
- OO / SALV: `ZFI_SALV_TEMPLATE`, `OO_ALV_template`
- IDA / CDS: `ZFI_IDA_template`, `ALV_IDA_CDS`, `ALV_IDA_template(SSCR_ALV)`, `ALV_IDA_template (with SSCR on same page)`
- Линейное программирование (симплекс): `ZFI_SIMP_LP_DEMO`, `ZFI_SIMP_LP_DEMO2`

## Basis / инструменты
- Пользователи ↔ роли: `ZBC_USERS_ROLES` (+ `_TOP/_F01`)
- Проверка транспортных запросов: `ZTRC`
- Переключение языка SAP Logon: `ZBC_LANG_EN`
