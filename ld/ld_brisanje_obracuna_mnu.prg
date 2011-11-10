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

function ld_brisanje_obr()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. brisanje obracuna za jednog radnika       ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISIRADNIKA"))
	AADD(opcexe, {|| BrisiRadnika()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. brisanje obracuna za jedan mjesec   ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISIMJESEC"))
	AADD(opcexe, {|| BrisiMjesec()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. brisanje nepotrebnih sezona         ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","PRENOSLD"))
	AADD(opcexe, {|| PrenosLD()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. totalno brisanje radnika iz evidencije")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","TOTBRISRADN"))
	AADD(opcexe, {|| TotBrisRadn()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("bris")

return


