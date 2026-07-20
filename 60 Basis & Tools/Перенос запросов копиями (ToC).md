Чтобы не деблокировать транспортные запросы для переноса в тестовую систему (QAS), можно воспользоватся функционалом Transport of copies

**Как это работает:**
1. Заходим в **SE10** или подобную транзакцию, создаем запрос, выбираем "Transport of copies"

<img width="512" alt="Screenshot 2023-05-17 at 15 46 20" src="https://github.com/aamelin1/SAP-FI-notes/assets/37226181/a126378d-ede5-4355-afe0-36d3744dcad3">

2. Заполняем целевую систему (систему + мандант)

<img width="663" alt="Screenshot 2023-05-17 at 15 46 59" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/6bfcd5eb-9190-4af7-91c5-dd55f8574cf5">

Сохраняем. Запрос появится в ветке "Transport of copies"

<img width="454" alt="Screenshot 2023-05-17 at 15 49 57" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/5c4a9b50-fbce-4cb2-9cef-84cd978514c4">

3. Ставим курсов на созданный запрос переноса копий и нажимаем "включить обьекты" (ctrl+F11)

<img width="588" alt="Screenshot 2023-05-17 at 15 51 02" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/9f946123-4b47-4984-ac8f-a6d6da9e0716">

4. Указываем запрос который нужно перенести

<img width="622" alt="Screenshot 2023-05-17 at 15 52 55" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/0ebf00e1-3e2f-4a4b-9845-c3dece8f3982">

В запрос переноса копий добавятся объекты из целевого запроса:

<img width="440" alt="Screenshot 2023-05-17 at 15 53 32" src="https://github.com/aamelin1/ABAP-templates/assets/37226181/5710f1f6-fb33-4f49-8f27-446a0f2b6f28">

5. Деблокируем запрос (F9) и переносим, при необходимости, в нужную систему (STMS, STMS_IMPORT итд)


