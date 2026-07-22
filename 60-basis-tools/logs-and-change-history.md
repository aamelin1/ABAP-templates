---
title: "Logs and change history in SAP"
keywords: SCU3, DBTABLOG, RSSCD100, CDHDR, CDPOS, CHANGEDOCUMENT_DISPLAY, SLG1, CL_BALI_LOG, SE16N_CD_KEY, RKSE16N_CD_DISPLAY, SM21, /SDF/BAL_READ, C14ALD_BAPIRET2_SHOW, история изменений, change documents
status: draft
---

# Logs and change history in SAP

| Type of logs | Tcode | SAP objects |
| --- | --- | --- |
| Table content | `SCU3`- tcode to Table History display | `DBTABLOG` - table for change logs |
| Change document | `RSSCD100` - tcode to Change documents display | `CDHDR` + `CDPOS` Tables of Change documents `CHANGEDOCUMENT_DISPLAY` - FM to Show change documents |
| Standard logging | `SLGx` - tcodes of Application Log | `CL_BALI_LOG` - Class Working with SLGx Logs |
| Direct SAP tables updates | `RKSE16N_CD_DISPLAY` - program to show logs of `&sap_edit` | `SE16N_CD_KEY` - Logs of `&sap_edit` |
| System logs | `SM21` |  |
- `C14ALD_BAPIRET2_SHOW` - FM to show BAPI return messages
- se38 -> `/SDF/BAL_READ` - show logs in mass