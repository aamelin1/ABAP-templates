In simple terms, the RWIN interface is a list of functional modules and the sequence of their calls when creating FI documents. When creating any FI related document in the system, FMs (functional modules) are called, linked to events (technically, these are PROCESS and EVENT) in a certain order. The set and order of calls is the RWIN interface

A table with a list of FMs called when forming an FI document (essentially the RWIN interface itself) - **TRWPR**:

(For example, a list of functions when checking an FI document):
![[Pasted image 20240801142320.png]]

It is important to understand that only those FMs (FM name in the TRWPR-FUNCTION field) are called for the component (TRWPR-COMPONENT) for which the activation label is set in the system.

Table with components is (and activation status) - **TRWCA**:
![[Pasted image 20240801142347.png]]

Maintained via tcode **SM30**

The processes (**TRWPR-PROCESS**) and events (**TRWPR-EVENT**) themselves are predefined by SAP and are usually simply hardcoded, for example, in the **AC_DOCUMENT_CREATE** FM it looks like this:

![[Pasted image 20240801143122.png]]

and then comes the call of FMs from the TRWPR table taking into account the active components (**TRWCA**)

![[Pasted image 20240801143131.png]]