---
title: "Upload journal entries via Fiori app (F2548)"
keywords: F2548, Upload General Journal Entries, Fiori, загрузка проводок, journal entry upload, FAC_GL_DOCUMENT_POST_SRV, /UI2/FLP, /IWFND/MAINT_SERVICE, OData, Excel template, шаблон загрузки
status: draft
---

# Upload journal entries via Fiori app (F2548)

## Step by step guide:

1. Run FIORI launchpad (via link or tcode `/n/ui2/flp`)
2. Find tile/app “Upload General Journal Entries” (tech ID **F2548**) and run it

![IMG1](img/upload-je-1.png)

3. Download template for uploading journal items:

![IMG2](img/upload-je-2.png)

[Template](img/upload-journal-entries-template.xlsx)

4. Fill the template with postings info, save file
5. Upload filled template to FIORI app

![IMG3](img/upload-je-3.png)

6. Click “Post”

a. If everything is or – you’ll see the message like this:

![IMG4](img/upload-je-4.png)

And here you can find a list of posted documents:

![IMG5](img/upload-je-5.png)

b. In case of errors – you’ll see this message:

![IMG6](img/upload-je-6.png)

List of errors available at log:

![IMG7](img/upload-je-7.png)

## Tech info:

- [FIORI app (App ID **F2548**)](https://fioriappslibrary.hana.ondemand.com/sap/fix/externalViewer/#/detail/Apps('F2548')/S26OP)
- odata service `FAC_GL_DOCUMENT_POST_SRV` via tcode `/N/IWFND/MAINT_SERVICE`