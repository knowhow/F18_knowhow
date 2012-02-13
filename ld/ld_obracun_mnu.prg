/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "ld.ch"


function ld_obracun()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "1. unos                              ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","UNOS"))
	AADD(_opcexe, {|| ld_unos_obracuna()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "2. administracija obracuna           ")
AADD(_opcexe, {|| ld_obracun_mnu_admin()})

f18_menu( "obr", .f., _izbor, _opc, _opcexe )

return


// administrativni menij obracuna plate
function ld_obracun_mnu_admin()
local _radni_sati := fetch_metric("ld_radni_sati", NIL, "N" ) 
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "1. otvori / zakljuci obracun                     ")
if gZastitaObracuna=="D"
	AADD(_opcexe, {|| DlgZakljucenje()})
else
	AADD(_opcexe, {|| MsgBeep("Opcija nije dostupna !")})
endif

AADD(_opc, "2. preuzmi podatke iz obracuna       ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","UZMIOBR"))
	AADD(_opcexe, {|| ld_preuzmi_obracun()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "3. prenos obracuna u smece           ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","LDSMECE"))
	AADD(_opcexe, {|| ld_prenos_u_smece()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "4. povrat obracuna iz smeca          ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","SMECELD"))
	AADD(_opcexe, {|| ld_prenos_iz_smeca()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "5. uklanjanje obracuna iz smeca      ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISISMECE"))
	AADD(_opcexe, {|| ld_brisi_smece()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "6. uzmi obracun iz ClipBoarda (sif0) ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","OBRIZCLIP"))
	AADD(_opcexe, {|| ld_obracun_iz_clipboarda()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "7. radnici obradjeni vise puta za isti mjesec")
AADD(_opcexe, {|| ld_obracun_napravljen_vise_puta()})

AADD(_opc, "8. promjeni varijantu obracuna za obracun")
AADD(_opcexe, {|| ld_promjeni_varijantu_obracuna()})

if gVarObracun == "2"
	AADD(_opc, "9. unos datuma isplate placa")
	AADD(_opcexe, {|| unos_datuma_isplate_place()})
endif

if gSihtGroup == "D"
	AADD(_opc, "S. obrada sihtarica")
	AADD(_opcexe, {|| siht_obr()})
endif

if _radni_sati == "D"
	AADD(_opc, "R. pregled/ispravka radnih sati radnika")
	AADD(_opcexe, {|| edRadniSati()})
endif

f18_menu( "ao", .f., _izbor, _opc, _opcexe )

return

// ------------------------------------------------
// obrada sihtarica
// ------------------------------------------------
function siht_obr()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "1. unos/ispravka                ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","UNOS"))
	AADD(_opcexe, {|| def_siht()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "2. pregled unesenih sihtarica")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","PRINT"))
	AADD(_opcexe, {|| get_siht()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "3. pregled ukupnih sati po siht.")
if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","PRINT"))
	AADD(_opcexe, {|| get_siht2()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "4. brisanje sihtarice ")

if (ImaPravoPristupa(goModul:oDatabase:cName,"SIHT","BRISANJE"))
	AADD(_opcexe, {|| del_siht()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

f18_menu( "sobr", .f., _izbor, _opc, _opcexe )

return

