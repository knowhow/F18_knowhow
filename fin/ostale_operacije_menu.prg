#include "fin.ch"

function MnuOstOperacije()

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. povrat dokumenta u pripremu          ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","POVRATNALOGA"))
	AADD(opcexe, {|| PovratNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. preknjizenje     ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREKNJIZENJE"))
	AADD(opcexe, {|| Preknjizenje()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. prebacivanje kartica")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREBKARTICA"))
	AADD(opcexe, {|| PrebKartica()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. ima u suban nema u nalog")
AADD(opcexe, {|| ImaUSubanNemaUNalog()})

AADD(opc, "5. otvorene stavke")
AADD(opcexe, {|| OStav()})

Menu_SC("oop")

return

