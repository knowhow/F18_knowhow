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

function ld_rekalkulacija()
private opc:={}
private opcexe:={}
private izbor:=1

if GetObrStatus(gRj,gGodina,gMjesec)$"ZX"
	MsgBeep("Obracun zakljucen! Ne mozete vrsiti ispravku podataka!!!")
	return
elseif GetObrStatus(gRj,gGodina,gMjesec)=="N"
	MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(gMjesec))+"."+ALLTRIM(STR(gGodina)))
	return
endif

AADD(opc, "1. rekalkulacija satnica i primanja               ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKPRIMANJA"))
	AADD(opcexe, {|| RekalkPrimanja()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. ponovo izracunaj neto sati/neto iznos/odbici")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKSVE"))
	AADD(opcexe, {|| RekalkSve()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. rekalkulacija odredjenog primanja za procenat")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKPROCENAT"))
	AADD(opcexe, {|| RekalkProcenat()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. rekalkulacija odredjenog primanja po formuli")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKFORMULA"))
	AADD(opcexe, {|| RekalkFormula()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("rklk")

return
*}

