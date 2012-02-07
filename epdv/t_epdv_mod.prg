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


#include "epdv.ch"
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TEpdvMod FROM TAppMod
	method New
	method setGVars
	method mMenu
	method mMenuStandard
	method initdb
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
::oDatabase:=TDbEpdv():new()
return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenu()

close all

SETKEY(K_SH_F1,{|| Calc()})

CheckROnly(KUMPATH + "\PDV.DBF")

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

epdv_set_params()

::mMenuStandard()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. KUF unos/ispravka           ")

if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","EDIT"))
	AADD(opcexe, {|| ed_kuf()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. KIF unos/ispravka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","EDIT"))
	AADD(opcexe, {|| ed_kif()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "3. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe, {|| epdv_generisanje()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. izvjestaji")
AADD(opcexe, {|| epdv_izvjestaji()})


AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "S. sifrarnici")
AADD(opcexe, {|| epdv_sifrarnici()})

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "9. administracija baze podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DB", "ADMIN"))
	AADD(opcexe, {|| epdv_admin_menu()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})


AADD(opc, "X. parametri")

if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","ALL"))
	AADD(opcexe, {|| epdv_parametri()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("gpdv",.t., .f.)

return

// ---------------------------------------------
// ---------------------------------------------
method srv()
return


// ---------------------------------------------
// ---------------------------------------------
method setGVars()

set_global_vars()
set_roba_global_vars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}
public gPicVrijednost := "9999999.99"
public gL_kto_dob := PADR("541;", 100)
public gL_kto_kup := PADR("211;", 100)
public gKt_updv := PADR("260;", 100)
public gKt_ipdv := PADR("560;", 100)

//::super:setTGVars()

O_PARAMS
Rpar("p1",@gPicVrijednost)

select (F_PARAMS)
use

public gModul
public gTema
public gGlBaza

gModul:="EPDV"
gTema:="OSN_MENI"
gGlBaza:="PDV.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

return





