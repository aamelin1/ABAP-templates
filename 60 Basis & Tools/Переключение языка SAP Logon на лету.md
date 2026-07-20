Иногда удобно иметь возможность на лету переключить язык входа в SAP систему в SAP Logon.

Концепция:

Установить язык через 

```abap
SET LOCALE LANGUAGE 'E'.
```

Вызвать новую сессию через

```abap
CALL FUNCTION 'ABAP4_CALL_TRANSACTION' STARTING NEW TASK 'LANGUAGE'
```

и закрыть текущую сессию.

Пример реализации:
1) Создаем программу, например **ZBC_LANG**

```abap
REPORT ZBC_LANG.
CASE sy-tcode.
  WHEN 'ZEN'. SET LOCALE LANGUAGE 'E'.
  WHEN 'ZRU'. SET LOCALE LANGUAGE 'R'.
  WHEN 'ZPT'. SET LOCALE LANGUAGE 'P'.
* WHEN 'Zxx'. SET LOCALE LANGUAGE 'x'.
  WHEN OTHERS.
    exit.
ENDCASE.

CALL FUNCTION 'ABAP4_CALL_TRANSACTION' STARTING NEW TASK 'LANGUAGE'
  EXPORTING
    tcode = 'SESSION_MANAGER'.
```

2) Создаем N транзакций вида Z<язык>, например **ZEN**, **ZPT**, **ZRU** итд. В них прописывем вызов программы **ZBC_LANG**

3) Для переключения языка в окне транзакций запускаем **/nZ<язык>**, например **/nzEN, /nzRU**...

До:

<img width="356" alt="Screenshot 2023-05-17 at 16 36 39" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/0f16a970-24de-4698-94a0-b295a3bdabc3">

После:

<img width="336" alt="Screenshot 2023-05-17 at 16 37 12" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/32d0e7bc-9138-414b-87af-05ef27336680">


---
**Исходный код:**
- [ZBC_LANG_EN.abap](../90%20Source%20code/ZBC_LANG_EN.abap)
