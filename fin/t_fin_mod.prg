/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

#include "hbclass.ch"

CLASS TFinMod FROM TAppMod
	method New
	method dummy
	method setGVars
	method mMenu
	method mMenuStandard
	method initdb
END CLASS


// ----------------------------------------------------
// ----------------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)

::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)

return self


// ----------------------------------------
// ----------------------------------------
method initdb()

::oDatabase:=TDbFin():new()

return nil


// ----------------------------------------
// ----------------------------------------
method dummy()
return


// ----------------------------------------
// ----------------------------------------
method mMenu()

set_hot_keys()

O_NALOG
select NALOG
use

// ? ne znam zasto ovo
OKumul(F_SUBAN, KUMPATH, "SUBAN", 5, "D")
OKumul(F_ANAL, KUMPATH, "ANAL", 2, "D")
OKumul(F_SINT, KUMPATH, "SINT", 2, "D")
OKumul(F_NALOG, KUMPATH, "NALOG", 2, "D")

auto_kzb()

close all

@ 1,2 SAY padc(gTS + ": " + gNFirma, 50, "*")
@ 4,5 SAY ""

::mMenuStandard()

return nil


method mMenuStandard()
local _izbor :=1
local _opc:={}
local _opcexe:={}
local oDb_lock := F18_DB_LOCK():New()
local _locked := oDb_lock:is_locked()

AADD(_opc, "1. unos/ispravka dokumenta                   ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "KNJIZNALOGA")) .or. !_locked
	AADD(_opcexe, {|| fin_unos_naloga() })
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif

AADD(_opc, "2. izvjestaji")
AADD(_opcexe, {|| Izvjestaji()})

AADD(_opc, "3. pregled dokumenata")
AADD(_opcexe, {|| MnuPregledDokumenata()})

AADD(_opc, "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK")) .or. !_locked
	AADD(_opcexe, {|| MnuGenDok()})
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif

AADD(_opc, "5. moduli - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA")) .or. !_locked
	AADD(_opcexe, {|| MnuRazmjenaPodataka()})
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif

AADD(_opc, "6. ostale operacije nad dokumentima")
AADD(_opcexe, {|| MnuOstOperacije()})

AADD(_opc, "7. udaljene lokacije - razmjena podataka ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","UDLOKRAZMJENA")) .or. !_locked
	AADD(_opcexe, {|| fin_udaljena_razmjena_podataka()})
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif

AADD(_opc, "------------------------------------")
AADD(_opcexe, {|| nil})

AADD(_opc, "8. sifrarnici")
AADD(_opcexe, {|| MnuSifrarnik()})

AADD(_opc, "9. administracija baze podataka")

if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN")) .or. !_locked
	AADD(_opcexe, {|| MnuAdminDB()})
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif

AADD(_opc, "------------------------------------")
AADD(_opcexe, {|| nil})

AADD(_opc, "K. kontrola zbira datoteka")
AADD(_opcexe, {|| KontrZb()})

AADD(_opc, "P. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDatabase:cName, "UT", "POVRATNALOGA")) .or. !_locked
	AADD(_opcexe, {|| povrat_fin_naloga()})
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif

AADD(_opc, "------------------------------------")
AADD(_opcexe, {|| nil})

AADD(_opc, "X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(_opcexe, {|| mnu_fin_params()})
else
	AADD(_opcexe, {|| oDb_lock:warrning() })
endif


f18_menu("gfin", .t., _izbor, _opc, _opcexe )

return



method setGVars()

set_global_vars()
set_roba_global_vars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gRavnot := "D"
public gDatNal := "N"
public gSAKrIz := "N"
public gBezVracanja := "N"  
public gBuIz := "N"  
public gPicDEM := "9999999.99"
public gPicBHD := "999999999999.99"
public gVar1 := "1"
public gRj := "N"
public gTroskovi := "N"
public gnRazRed := 3
public gVSubOp := "N"
public gnLMONI := 120
public gKtoLimit := "N"
public gnKtoLimit := 3
public gDUFRJ:="N"
public gBrojac:="1"
public gDatVal:="D"
public gnLOSt:=0
public gPotpis:="N"
public gnKZBDana:=0
public gOAsDuPartn:="N"
public gAzurTimeOut := 120
public g_knjiz_help := "N"
public gMjRj := "N"
public aRuleCols := g_rule_cols_fin()
public bRuleBlock := g_rule_block_fin()

::super:setTGVars()

// procitaj parametre fin modula
fin_read_params()

public gModul
public gTema
public gGlBaza

gModul := "FIN"
gTema := "OSN_MENI"
gGlBaza := "SUBAN.DBF"

public cZabrana := "Opcija nedostupna za ovaj nivo !!!"

fin_params(.t.)

return


