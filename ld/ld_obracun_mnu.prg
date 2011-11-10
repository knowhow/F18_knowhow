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

function ld_obracun()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. unos                              ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","UNOS"))
	AADD(opcexe, {|| ld_unos_obracuna()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. administracija obracuna           ")
AADD(opcexe, {|| MnuAdmObr()})

Menu_SC("obr")

return



function MnuAdmObr()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. otvori / zakljuci obracun                     ")
if gZastitaObracuna=="D"
	AADD(opcexe, {|| DlgZakljucenje()})
else
	AADD(opcexe, {|| MsgBeep("Opcija nije dostupna !")})
endif

if lViseObr
	AADD(opc, "2. preuzmi podatke iz obracuna       ")
	if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","UZMIOBR"))
		AADD(opcexe, {|| UzmiObr()})
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
else
	AADD(opc, "2. --------------------              ")
	AADD(opcexe, {|| nil})
endif

AADD(opc, "3. prenos obracuna u smece           ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","LDSMECE"))
	AADD(opcexe, {|| LdSmece()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. povrat obracuna iz smeca          ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","SMECELD"))
	AADD(opcexe, {|| SmeceLd()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. uklanjanje obracuna iz smeca      ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISISMECE"))
	AADD(opcexe, {|| BrisiSmece()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "6. uzmi obracun iz ClipBoarda (sif0) ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","OBRIZCLIP"))
	AADD(opcexe, {|| ObrIzClip()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "7. radnici obradjeni vise puta za isti mjesec")
AADD(opcexe, {|| VisePuta()})

AADD(opc, "8. promjeni varijantu obracuna za obracun")
AADD(opcexe, {|| chVarObracun()})

if gVarObracun == "2"
	AADD(opc, "9. unos datuma isplate placa")
	AADD(opcexe, {|| unos_disp()})
endif

if gSihtGroup == "D"
	AADD(opc, "S. obrada sihtarica")
	AADD(opcexe, {|| siht_obr()})
endif

if IzFmkIni("LD","RadniSati","N",KUMPATH) == "D"
	AADD(opc, "R. pregled/ispravka radnih sati radnika")
	AADD(opcexe, {|| edRadniSati()})
endif

Menu_SC("ao")

return


// ------------------------------------------------
// obrada sihtarica
// ------------------------------------------------
function siht_obr()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. unos/ispravka                ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","UNOS"))
	AADD(opcexe, {|| def_siht()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. pregled unesenih sihtarica")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","PRINT"))
	AADD(opcexe, {|| get_siht()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. pregled ukupnih sati po siht.")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","PRINT"))
	AADD(opcexe, {|| get_siht2()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. brisanje sihtarice ")

if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","BRISANJE"))
	AADD(opcexe, {|| del_siht()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("sobr")

return

