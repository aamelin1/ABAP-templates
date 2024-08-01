# RWIN Interface

In simple terms, the RWIN interface is a list of functional modules and the sequence of their calls when creating FI documents. When creating any FI related document in the SAP system, FMs (functional modules) are called, linked to events (technically, these are PROCESS and EVENT) in a certain order. The set and order of calls is the RWIN interface

A table with a list of FMs called when forming an FI document (essentially the RWIN interface itself) - **TRWPR**:

(For example, a list of functions when checking an FI document):

![Table TRWPR at se16n](IMG/252351570-176c4a8e-8695-4d7f-9140-5addfbd25abc.png)

It is important to understand that only those FMs (FM name in the TRWPR-FUNCTION field) are called for the component (TRWPR-COMPONENT) for which the activation label is set in the system.

Table with components is (and activation status) - **TRWCA**:

![Table TRWCA at se16n](IMG/252350971-f5ae1b87-d512-47d9-9b6a-32dc7ae109f1.png)

Maintained via tcode **SM30**

The processes (**TRWPR-PROCESS**) and events (**TRWPR-EVENT**) themselves are predefined by SAP and are usually simply hardcoded, for example, in the **AC_DOCUMENT_CREATE** FM it looks like this:

![FM AC_DOCUMENT_CREATE](IMG/252352981-73362ea1-4bf3-4da6-a318-808ee6f3aca6.png)

and then comes the call of FMs from the TRWPR table taking into account the active components (**TRWCA**)

![Include LRWCLF01](IMG/252353300-18e2cb2c-03b6-43fc-a0e7-4f12f631a9a6.png)
