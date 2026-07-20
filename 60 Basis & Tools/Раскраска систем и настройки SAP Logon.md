В SAP Logon есть возможность раскрасить разные системы/манданты в разные цвета. Это может быть удобно при работе с несколькими системами, чтобы случайно что то не сделать не в той системе. Например можно покрасить DEV систему в синий цвет, QAS в зеленый, PRD в красный итд.

Как это делается:
Зайти в настройки в SAP Logon

<img width="636" alt="image" src="https://github.com/aamelin1/SAP-FI-notes/assets/37226181/0cb1ae2a-33f4-400f-b5dc-9d1b9b9ca8d5">

Далее выбрать нужный цвет для системы в целом (вверху) или для системы+ мандант (внизу)

<img width="793" alt="image" src="https://github.com/aamelin1/SAP-FI-notes/assets/37226181/d74bdd40-29b1-4875-9fef-2ef7cf9a8fb5">

Применить настройки и перезапустить SAP Logon.

Еще полезные настройки:

Показывать ключ в раскрывающихся списках, например так:

<img width="203" alt="image" src="https://github.com/aamelin1/SAP-FI-notes/assets/37226181/0690cf8e-f4e0-4ade-bfa6-bf6b7329ea3a">

Настраивается тут:

![image](https://github.com/aamelin1/SAP-FI-notes/assets/37226181/cf164109-627e-445f-b1f7-d79f1093a0a2)

Для SAP Logon 760 можно вернуть кнопки в меню как были раньше, делается тут:

![image](https://github.com/aamelin1/SAP-FI-notes/assets/37226181/089fdb25-fcbf-4796-8741-76efd45e5c5e)

Так же можно активировать автозаполнение (по пробелу) значений в полях для длинных полей, делается тут:

![image](https://github.com/aamelin1/SAP-FI-notes/assets/37226181/0051aa71-6960-4099-bf55-f36f49503243)

Начиная с версии 750 в SAP Logon нет возможности сохранять логин+пароль (если у вас нет SSO), но можно сделать ярлыки (для WIN) вида:

`"C:\Program Files (x86)\SAP\FrontEnd\SAPgui\sapshcut.exe" XXX.XXX.XXX.XXX -user=USERNAME -pw=PASSWORD -system=SYS -Client=YYY -language=EN`
