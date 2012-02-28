/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "ld.ch"


function ld_sifrarnici()

private opc:={}
private opcexe:={}
private Izbor:=1

OSifre()

AADD(opc,"1. opci sifrarnici                     ")
AADD(opcexe, {|| MnuOpSif()})
AADD(opc,"2. specijalni sifrarnici")
AADD(opcexe, {|| MnuSpSif()})

Menu_SC("sif")
return



function MnuOpSif()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, lokal("1. radnici                            "))
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIF","EDITRADN"))
	AADD(opcexe, {|| P_Radn()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc, lokal("5. radne jedinice"))
AADD(opcexe, {|| P_LD_RJ()})
AADD(opc, lokal("6. opstine"))
AADD(opcexe, {|| P_Ops()})
AADD(opc, lokal("9. vrste posla"))
AADD(opcexe, {|| P_VPosla()})
AADD(opc, lokal("B. strucne spreme"))
AADD(opcexe, {|| P_StrSpr()})
AADD(opc, lokal("C. kreditori"))
AADD(opcexe, {|| P_Kred()})
AADD(opc, lokal("F. banke"))
AADD(opcexe, {|| P_Banke()})
AADD(opc, lokal("G. sifk"))
AADD(opcexe, {|| P_SifK()})

if (IsRamaGlas())
	AADD(opc, lokal("H. radni nalozi") )
	AADD(opcexe, {|| P_RNal()})
endif

gLokal:=ALLTRIM(gLokal)
if gLokal <> "0"
	AADD(opc, lokal("L. lokalizacija") )
	AADD(opcexe, {|| P_Lokal()})
endif
Menu_SC("op")
return



function MnuSpSif()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. parametri obracuna                  ")
AADD(opcexe, {|| P_ParObr()})

AADD(opc,"2. tipovi primanja")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIF","EDITTIPPR"))
	AADD(opcexe, {|| P_TipPr()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if lViseObr
	AADD(opc,"3. tipovi primanja za obracun 2")
	if (ImaPravoPristupa(goModul:oDatabase:cName,"SIF","EDITTIPPR2"))
		AADD(opcexe, {|| P_TipPr2()})
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
endif

AADD(opc,"4. porezi")
AADD(opcexe, {|| P_Por()})
AADD(opc,"5. doprinosi")
AADD(opcexe, {|| P_Dopr()})
AADD(opc,"6. koef.benef.rst")
AADD(opcexe, {|| P_KBenef()})

if gSihtarica=="D"
	AADD(opc,"7. tipovi primanja u sihtarici")
	AADD(opcexe, {|| P_TprSiht()})
	AADD(opc,"8. norme radova u sihtarici   ")
	AADD(opcexe, {|| P_NorSiht()})
endif

if gSihtGroup == "D"
	AADD(opc,"8. lista konta   ")
	AADD(opcexe, {|| p_konto()})
endif

Menu_SC("spc")
return

function OSifre()

O_SIFK
O_SIFV
O_BANKE

if gSihtarica=="D"
	O_TPRSIHT
  	O_NORSIHT
endif

O_RADN
O_PAROBR
O_TIPPR
O_LD_RJ
O_POR
O_DOPR
O_STRSPR
O_KBENEF
O_VPOSLA
O_OPS
O_KRED

if lViseObr
	O_TIPPR2
endif

if (IsRamaGlas())
	O_RNAL
endif

return



