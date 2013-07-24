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
O_PARAMS

set_global_vars()

public cSection:="1"
public cHistory:=" "
public aHistory:={}
public cFormula:=""
public gRJ:="01"
public gnHelpObr:=0
public gMjesec:=1
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
public gUNMjesec:="N"
public gMRM:=0
public gMRZ:=0
public gPDLimit:=0
public gSetForm:="1"
public gPrBruto:="D"
public gMinR:="%"
public gPotp:="D"
public gBodK:="1"
public gDaPorol:="N" // pri obracunu uzeti u obzir poreske olaksice
public gFSpec:=PADR("SPEC.TXT",12)
public gReKrOs:="X"
public gReKrKP:="1"
public gVarPP:="1"
public gKarSDop:="N"
public gPotpRpt:="N"
public gPotp1:=PADR("PADL('Potpis:',70)",150)
public gPotp2:=PADR("PADL('_________________',70)",150)
public _LR_:=6
public _LK_:=6
public lViseObr := .t.
public lVOBrisiCDX := .f.
public cLdPolja := 40
public gZastitaObracuna := "N"

// bazni parametri obracuna...
// globalni parametri
gVarObracun := fetch_metric( "ld_varijanta_obracuna", NIL, "2" )
lViseObr := fetch_metric( "ld_vise_obracuna", NIL, lViseObr )
// parametri po korisinicima
gGodina := fetch_metric( "ld_godina", my_user(), gGodina )
gRJ := fetch_metric( "ld_rj", my_user(), gRj )
gMjesec := fetch_metric( "ld_mjesec", my_user(), gMjesec )
gObracun := fetch_metric( "ld_obracun", my_user(), gObracun )

// zastita obracuna / otkljucavanje zakljucavanje
gZastitaObracuna := fetch_metric( "ld_zastita_obracuna", NIL, gZastitaObracuna )

// ostali parametri...

gSihtarica := fetch_metric( "ld_obrada_sihtarica", NIL, gSihtarica )
gSihtGroup := fetch_metric( "ld_obrada_sihtarica_po_grupama", NIL, gSihtGroup )

// bazna opcija sihtarica mora biti iskljucena
if gSihtGroup == "D"
	gSihtarica := "N"
endif

gPicI := fetch_metric( "ld_pic_iznos", NIL, gPicI )
gPicS := fetch_metric( "ld_pic_sati", NIL, gPicS )
gValuta := fetch_metric( "ld_valuta", NIL, gValuta )
gZaok2 := fetch_metric( "ld_zaok_por_dopr", NIL, gZaok2 )
gZaok := fetch_metric( "ld_zaok_prim", NIL, gZaok )
gFURsati := fetch_metric( "ld_formula_ukupni_sati", nil, gFURsati )


O_PARAMS
select (F_PARAMS)

RPar("bk",@gBodK)      // opisno: 1-"bodovi" ili 2-"koeficijenti"
RPar("fo",@gSetForm)   // set formula
Rpar("gd",@gFUGod)
Rpar("kp",@gReKrKP)
Rpar("pp",@gVarPP)
RPar("m1",@gMRM)
RPar("m2",@gMRZ)
RPar("dl",@gPDLimit)
RPar("mr",@gMinR)      // min rad %, Bodovi
RPar("os",@gFSpec)     // fajl-obrazac specifikacije
RPar("p9",@gDaPorOl)   // praviti poresku olaksicu D/N
RPar("pb",@gPrBruto)   // set formula
RPar("po",@gPotp)      // potpis na listicu
RPar("rk",@gReKrOs)
Rpar("to",@gTipObr)
Rpar("vo",@cVarPorOl)
Rpar("uS",@gFUSati)
Rpar("uB",@gBFForm)
RPar("um",@gUNMjesec)
Rpar("up",@gFUPrim)
Rpar("ur",@gFURaz)
Rpar("vs",@gVarSpec)
Rpar("lo",@gOsnLOdb)
Rpar("pr",@gPotpRpt)
Rpar("P1",@gPotp1)
Rpar("P2",@gPotp2)
Rpar("t1",@gUgTrosk)
Rpar("t2",@gAhTrosk)
Rpar("ks",@gKarSDop)
Rpar("rf",@gRadnFilter)

select (F_PARAMS)
use

LDPoljaINI()

gGlBaza := "LD.DBF"

return


function RadnikJeProizvodni()
private cPom
cPom:=IzFmkIni("ProizvodniRadnik","Formula",'"P"$RADN->K4',KUMPATH)
return (&cPom)


