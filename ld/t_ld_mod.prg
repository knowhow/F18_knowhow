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
	method chk_db
	method srv
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
method chk_db()
local cModStru:=""
// provjeri postojanje specificnih polja LD.DBF
// HIREDFROM
O_RADN
select radn
if radn->(FieldPOS("HIREDFROM")) == 0
	// obavjesti za modifikaciju
	cModStru += "DP.CHS, "
endif

// provjeri nadogradnje 2009
if radn->(FieldPOS("KLO")) == 0
	cModStru += "LD.CHS (zakon.promj.2009), "
endif

// provjeri KRED->FIL polje
O_KRED
select kred
if kred->(FieldPos("FIL")) == 0
	cModStru += "KRED.CHS, "
endif

if !EMPTY(cModStru)
	MsgBeep("Upozorenje!##Odraditi modifikacije struktura:#" + cModStru)
endif

return


// ------------------------------------------------
// ------------------------------------------------
method mMenu()

private Izbor

set_hot_keys()

Izbor:=1

::chk_db()
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
private opc:={}
private opcexe:={}

AADD(opc,   Lokal("1. obracun (unos, ispravka...)              "))
AADD(opcexe, {|| ld_obracun()} )

AADD(opc,   Lokal("2. brisanje"))
AADD(opcexe, {|| ld_brisanje_obr()})

AADD(opc,   Lokal("3. rekalkulacija"))
AADD(opcexe, {|| ld_rekalkulacija()})

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
method srv()
? "Pokrecem LD aplikacijski server"
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif
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
public gZaok:=2
public gZaok2:=2
public gValuta:="KM "
public gPicI:="99999999.99"
public gPicS:="99999999"
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
public gZastitaObracuna := IzFmkIni( "LD", "ZastitaObr", "N", KUMPATH )

// bazni parametri obracuna...
// globalni parametri
gVarObracun := fetch_metric( "ld_varijanta_obracuna", NIL, "2" )
lViseObr := fetch_metric( "ld_vise_obracuna", NIL, lViseObr )
// parametri po korisinicima
gGodina := fetch_metric( "ld_godina", my_user(), gGodina )
gRJ := fetch_metric( "ld_rj", my_user(), gRj )
gMjesec := fetch_metric( "ld_mjesec", my_user(), gMjesec )
gObracun := fetch_metric( "ld_obracun", my_user(), gObracun )

// ostali parametri...

gSihtarica := fetch_metric( "ld_obrada_sihtarica", NIL, gSihtarica )
gSihtGroup := fetch_metric( "ld_obrada_sihtarica_po_grupama", NIL, gSihtGroup )

// bazna opcija sihtarica mora biti iskljucena
if gSihtGroup == "D"
	gSihtarica := "N"
endif


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
RPar("pi",@gPicI)
RPar("po",@gPotp)      // potpis na listicu
RPar("ps",@gPicS)
RPar("rk",@gReKrOs)
Rpar("to",@gTipObr)
Rpar("vo",@cVarPorOl)
gFURsati := fetch_metric( "ld_formula_ukupni_sati", nil, gFURsati )
Rpar("uS",@gFUSati)
Rpar("uB",@gBFForm)
RPar("um",@gUNMjesec)
Rpar("up",@gFUPrim)
Rpar("ur",@gFURaz)
Rpar("va",@gValuta)
Rpar("vs",@gVarSpec)
Rpar("z2",@gZaok2)
Rpar("zo",@gZaok)
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

//definisano u SC_CLIB-u
gGlBaza:="LD.DBF"

return


function RadnikJeProizvodni()
private cPom
cPom:=IzFmkIni("ProizvodniRadnik","Formula",'"P"$RADN->K4',KUMPATH)
return (&cPom)


