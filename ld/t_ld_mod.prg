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
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TLdMod FROM TAppMod
	method New
	method setGVars
	method mMenu
	method mMenuStandard
	method initdb
END CLASS

// -----------------------------------------------
// -----------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
return self


// -----------------------------------------------
// -----------------------------------------------
method initdb()
::oDatabase:=TDbLd():new()
return nil


// ------------------------------------------------
// ------------------------------------------------
method mMenu()

private Izbor

set_hot_keys()

Izbor:=1

close all

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

ParObracun()

::mMenuStandard()

return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard
local _priv_pr := f18_privgranted( "ld_pregled_podataka" )
local oDb_lock := F18_DB_LOCK():New()
local _db_locked := oDb_lock:is_locked()
private opc:={}
private opcexe:={}

AADD(opc,   Lokal("1. obracun (unos, ispravka...)              "))
if !_db_locked
    AADD(opcexe, {|| ld_obracun()} )
else
    AADD(opcexe, {|| oDb_lock:warrning() } )
endif

AADD(opc,   Lokal("2. brisanje"))
if !_db_locked
    AADD(opcexe, {|| ld_brisanje_obr()})
else
    AADD(opcexe, {|| oDb_lock:warrning() } )
endif

AADD(opc,   Lokal("3. rekalkulacija"))
if !_db_locked
    AADD(opcexe, {|| ld_rekalkulacija()})
else
    AADD(opcexe, {|| oDb_lock:warrning() } )
endif

AADD(opc,   Lokal("4. izvjestaji"))
AADD(opcexe, {|| ld_izvjestaji()})

AADD(opc,   Lokal("5. krediti"))
AADD(opcexe, {|| ld_krediti()})

AADD(opc,   Lokal("6. export podataka za banke "))
AADD(opcexe, {|| ld_export_banke() })

AADD(opc,"------------------------------------")
AADD(opcexe, nil)

AADD(opc,   Lokal("7. sifrarnici"))
AADD(opcexe, {|| ld_sifrarnici()})

AADD(opc,   Lokal("9. administriranje baze podataka")) 
AADD(opcexe, {|| ld_administracija()})

AADD(opc,"------------------------------------")
AADD(opcexe, nil)

// najcesece koristenje opcije
AADD(opc,   Lokal("A. rekapitulacija"))
if _priv_pr
    if gVarObracun == "2"
	    AADD(opcexe, {|| Rekap2(.t.)})
    else
	    AADD(opcexe, {|| Rekap(.t.)})
    endif
else
    AADD( opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

AADD(opc,   Lokal("B. kartica plate")) 
if _priv_pr
    AADD(opcexe, {|| KartPl()})
else
    AADD( opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

AADD(opc,   Lokal("V. generisanje virmana ")) 
AADD(opcexe, {|| ld_gen_virm() })

AADD(opc,"------------------------------------")
AADD(opcexe, nil)

AADD(opc,   Lokal("X. parametri     "))
AADD(opcexe, {|| ld_parametri()})

private Izbor:=1

Menu_SC( "gld", .t. )

return




// -------------------------------------------------------
// -------------------------------------------------------
method setGVars()

set_global_vars()

public cFormula := ""
public gRJ := "01"
public gnHelpObr := 0
public gMjesec := 1
public gObracun := "1"
// varijanta obracuna u skladu sa zak.promjenama
public gVarObracun := "2"
// default vrijednost osnovnog licnog odbitka 
public gOsnLOdb := 300

// filter po polju aktivan u tabeli RADN
public gRadnFilter := "D"

// trosak kod ugovora o djelu
public gUgTrosk := 20
// trosak kod autorskog honorara
public gAhTrosk := 30

public gIzdanje := SPACE(10)
public gGodina := YEAR( DATE() )
public gZaok := 2
public gZaok2 := 2
public gValuta := "KM "
public gPicI := "99999999.99"
public gPicS := "99999999"
public gTipObr:="1"
public gVarSpec:="1"
public cVarPorOl:="1"
public gSihtarica := "N"
public gSihtGroup := "N"
public gFUPrim := PADR("UNETO+I24+I25",50)
public gBFForm := PADR("",100)
public gFURaz := PADR("",60)
public gFUSati := PADR("USATI",50)
public gFURSati := PADR("",50)
public gFUGod:=PADR("I06",40)
public gUNMjesec := "N"
public gMRM := 0.6
public gMRZ := 0.6
public gPDLimit := 0
public gSetForm := "1"
public gPrBruto := "D"
public gMinR := "%"
public gPotp := "D"
public gBodK := "1"
public gDaPorol := "N" // pri obracunu uzeti u obzir poreske olaksice
public gFSpec := PADR("SPEC.TXT",12)
public gReKrOs := "X"
public gReKrKP := "2"
public gVarPP := "1"
public gKarSDop := "N"
public gPotpRpt := "N"
public gPotp1 := PADR("PADL('Potpis:',70)",150)
public gPotp2 := PADR("PADL('_________________',70)",150)
public _LR_:=6
public _LK_:=6
public lViseObr := .t.
public lVOBrisiCDX := .f.
public cLdPolja := 40
public gZastitaObracuna := "N"

// ucitaj parametre
ld_get_params()

LDPoljaINI()

gGlBaza := "LD.DBF"

return


function RadnikJeProizvodni()
private cPom
cPom:=IzFmkIni("ProizvodniRadnik","Formula",'"P"$RADN->K4',KUMPATH)
return (&cPom)


