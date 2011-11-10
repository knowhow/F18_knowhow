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


function ld_krediti()
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. novi kredit                        ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"KREDIT","NOVIKREDIT"))
	AADD(opcexe, {|| NoviKredit()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. pregled/ispravka kredita")
if (ImaPravoPristupa(goModul:oDatabase:cName,"KREDIT","EDITKREDIT"))
	AADD(opcexe, {|| EditKredit()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. lista kredita za jednog kreditora")
AADD(opcexe, {|| ListaKredita()})

AADD(opc, "4. brisanje kredita")
if (ImaPravoPristupa(goModul:oDatabase:cName,"KREDIT","BRISIKREDIT"))
	AADD(opcexe, {|| BrisiKredit()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. specifikacija kredita po kreditorima")
AADD(opcexe, {|| sp_kredita()})

Menu_SC("kred")

return

*}




