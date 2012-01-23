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


#include "virm.ch"
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TVirmMod FROM TAppMod
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
::oDatabase:=TDbVirm():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()

private Izbor
private lPodBugom

public gSQL:="N"

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

::mMenuStandard()

return nil


// ----------------------------------------
// ----------------------------------------
method mMenuStandard
private opc:={}
private opcexe:={}

AADD(opc,   "1. priprema virmana                 ")
AADD(opcexe, {|| unos_virmana()} )
AADD(opc,   "2. izvjestaji")
AADD(opcexe, {|| nil})
AADD(opc,   "3. moduli - razmjena podataka")
AADD(opcexe, {|| virm_razmjena_podataka()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "4. sifrarnici")
AADD(opcexe, {|| virm_sifrarnici()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "X. parametri")
AADD(opcexe, {|| virm_parametri()})

private Izbor := 1

Menu_SC( "gvir", .t. )

return


// ----------------------------------------
// ----------------------------------------
method setGVars()
O_PARAMS

set_global_vars()
//set_global_roba_vars()

public gDatum := DATE()
public gFirma := SPACE(6)
public gMjesto := SPACE(16)
public gOrgJed := SPACE(17)
public gNFirma := SPACE(20)
public gINulu:="N"
public gPici:="9,999,999,999,999,999.99"
public gIDU:="D"

O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

Rpar("Pi",@gPici)
RPar("bn",@gINulu)
Rpar("da",@gDatum)
Rpar("fi",@gFirma)
Rpar("fn",@gNFirma)
Rpar("mj",@gMjesto)
Rpar("oj",@gOrgJed)
RPar("du",@gIDU)

select params
use
release cSection,cHistory,aHistory
return



