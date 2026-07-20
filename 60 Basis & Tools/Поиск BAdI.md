Простой способ как найти вызываемые BAdI в любой транзакции.

Перед вызовом любой BAdI (даже без реализации) в системе вызывается метод **GET_INSTANCE** класса **CL_EXITHANDLER**.

Процедура поиска:
1. Открываем **SE24** и указываем класс **CL_EXITHANDLER**

<img width="428" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/3675a629-fadc-4fc5-970b-d0132f366741">

2. Нажимаем "Просмотр"

<img width="796" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/f7e49002-05f1-44f1-bc18-44ed42301b33">

3. Проваливаемся по даблклику в метод **GET_INSTANCE** и ставим точку прерывания на первой исполняемой строке

<img width="463" alt="Screenshot 2023-05-19 at 11 37 29" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/bc38b6a4-bf65-4d87-a4bb-c6b9a90de632">

4. Выходим из **SE24** или открываем новое окно и запускаем транзакцию в которой хотим найти точки расширения (BAdI)
Например **FB03**:

<img width="143" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/6b44524e-c50d-4b71-845b-2afccd981fff">

И при вызове любого BAdI попадаем в отладчик:

<img width="1108" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/e53d2ab8-3531-4c99-8bc9-98b9f1b24bff">

В переменной **EXIT_NAME** будет лежать имя BAdI.
В нашем случае это FI_AUTHORITY_ITEM. Далее по F8 можно найти другие вызываемые BAdI


Определение BAdI можно посмотреть в тр. **SE18**

<img width="437" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/a75775b3-3434-42ff-90f2-bbdf1510c821">

Там же можно посмотреть все реализации этого BAdI через меню:

<img width="171" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/7c782ad9-ab02-4d3b-84c1-33e858edc4ad">

<img width="791" alt="image" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/51c776d8-fee5-4bc2-8d58-0f4d35400ec5">

Реализации BAdI можно посмотреть в тр. **SE19**


