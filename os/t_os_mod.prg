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


#include "os.ch"
#include "hbclass.ch"

// -----------------------------------------------
// -----------------------------------------------
CLASS TOsMod FROM TAppMod
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
::oDatabase:=TDbOs():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()
private Izbor

nPom:=VAL(IzFmkIni("SET","Epoch","1945",KUMPATH))

IF nPom>0
  SET EPOCH TO (nPom)
ENDIF

PUBLIC gSQL:="N"
PUBLIC gCentOn:=IzFmkIni("SET","CenturyOn","N",KUMPATH)
IF gCentOn=="D"
  SET CENTURY ON
ELSE
  SET CENTURY OFF
ENDIF

os_set_datum_obrade()

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

CheckROnly(KUMPATH + "\OS.DBF")

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

::mMenuStandard()

return nil


// --------------------------------------------
// --------------------------------------------
method srv()
? "Pokrecem OS aplikacijski server"
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
// modifikacija struktura
if (MPar37("/MODSTRU", goModul))
	if LEFT(self:cP5,3)=="/S="
		cSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cSez)
		endif
	endif
	cMsFile:=goModul:oDataBase:cName
	if LEFT(self:cP6,3)=="/M="
		cMSFile:=SUBSTR(self:cP6,4)
	endif
	AppModS(cMsFile)
	goModul:quit(.f.)
endif

return



// --------------------------------------------
// --------------------------------------------
method mMenuStandard

private opc:={}
private opcexe:={}

AADD(opc, "1. unos promjena na postojecem sredstvu                     ")
AADD(opcexe, {|| unos_osnovnih_sredstava()})
AADD(opc, "2. obracuni")
AADD(opcexe, {|| os_obracuni()})
AADD(opc, "3. izvjestaji")
AADD(opcexe, {|| os_izvjestaji()})
AADD(opc, "--------------")
AADD(opcexe, {|| RazdvojiDupleInvBr()})
//4. inventura"
AADD(opc, "5. sifrarnici")
AADD(opcexe, {|| os_sifrarnici()})
AADD(opc, "6. parametri")
AADD(opcexe, {|| os_parametri()})
AADD(opc, "7. zavrsio unose u sezonskom podrucju, prenesi u tekucu")
AADD(opcexe, {|| PrenosPodatakaUTekucePodrucje()})
AADD(opc, "8. generacija podataka za novu sezonu")
AADD(opcexe, {|| GenerisanjePodatakaZaNovuSezonu()})
AADD(opc, "9. regeneracija poc.stanja (nabavna i otpisana vrijednost)")
AADD(opcexe, {|| RegenerisanjePocStanja()})

private Izbor:=1

Menu_SC("gos", .t. )

return


// -------------------------------------------------
// -------------------------------------------------
method setGVars()
O_PARAMS

set_global_vars()
//set_roba_global_vars()

O_PARAMS

private cSection:="1",cHistory:=" "; aHistory:={}
public gFirma:="10", gTS:="Preduzece"
public gNFirma:=space(20)  // naziv firme
public gNW:="D"  // new vawe
public gRJ:="00"
public gDatObr:=date()
public gValuta:="KM "
public gPicI:="99999999.99"
public gPickol:="99999.99"
public gVObracun:="2"
public gIBJ:="D", gDrugaVal:="N"
public gVarDio:="N", gDatDio:=CTOD("01.01.1999")
public gGlBaza:="OS.DBF"
public gMetodObr:="1"

Rpar("ff",@gFirma)
Rpar("ts",@gTS)
Rpar("fn",@gNFirma)
Rpar("ib",@gIBJ)
Rpar("dv",@gDrugaVal)
Rpar("nw",@gNW)
Rpar("rj",@gRj)
Rpar("do",@gDatObr)
Rpar("va",@gValuta)
Rpar("pi",@gPicI)
Rpar("vd",@gVarDio)
Rpar("dd",@gDatDio)
Rpar("mo",@gMetodObr)

return




