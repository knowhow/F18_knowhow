#include "fin.ch"


function MnuAdminDB()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. install db-a                            ")
AADD(opcexe, {|| goModul:oDatabase:install()})

AADD(opc, "2. security")
AADD(opcexe, {|| MnuSecMain()})

AADD(opc, "3. pregled datumskih gresaka u nalozima")
AADD(opcexe, {|| daterr_rpt() })

AADD(opc, "4. regeneracija broja naloga u kumulativu")
AADD(opcexe, {|| regen_tbl() })


if is_fmkrules()
	AADD(opc, "R. fmk pravila - rules ")
	AADD(opcexe, {|| p_fmkrules(,,, aRuleCols, bRuleBlock ) })
endif

Menu_SC("adm")

return


