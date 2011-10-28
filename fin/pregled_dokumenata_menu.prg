#include "fin.ch"


function MnuPregledDokumenata()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. kontrola zbira datoteka                     ")
AADD(opcexe, {|| KontrZb()})

AADD(opc, "2. stampanje azuriranog dokumenta")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","MNUSTAMPAAZURNALOGA"))
	AADD(opcexe, {|| MnuStampaAzurNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. stampa liste dokumenata")
AADD(opcexe, {|| StDatN()})

AADD(opc, "4. kontrola zbira datoteka za period - BETA")
AADD(opcexe, {|| KontrZb(.t.)})

Menu_SC("pgl")

return

