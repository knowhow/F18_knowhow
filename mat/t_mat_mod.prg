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


#include "mat.ch"
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TMatMod FROM TAppMod
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
::oDatabase:=TDbMat():new()
return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenu()

set_hot_keys()

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

::mMenuStandard()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. unos/ispravka dokumenata               ")

if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","EDIT"))
    AADD(opcexe, {|| mat_knjizenje_naloga()})
else
    AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. izvjestaji")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RPT","MNU"))
    AADD(opcexe, {|| mat_izvjestaji()})
else
    AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "3. kontrola zbira datoteka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","KZB"))
    AADD(opcexe, {|| mat_kzb()})
else
    AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. stampa datoteke naloga")
AADD(opcexe, {|| mat_dnevnik_naloga()})

AADD(opc, "5. stampa proknjizenih naloga")
AADD(opcexe, {|| mat_stampa_naloga()})

AADD(opc, "6. inventura")
AADD(opcexe, {|| mat_inventura()})

AADD(opc, "F. prenos fakt->mat")
AADD(opcexe, {|| mat_prenos_fakmat()})

AADD(opc, "G. generacija dokumenta pocetnog stanja")
AADD(opcexe, {|| mat_prenos_podataka()})


AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "S. sifrarnici")
AADD(opcexe, {|| mat_sifrarnik()})

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "P. povrat naloga u pripremu")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DB", "POVRAT"))
    AADD(opcexe, {|| mat_povrat_naloga()})
else
    AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "9. administracija baze podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName, "DB", "ADMIN"))
    AADD(opcexe, {|| mat_admin_menu()})
else
    AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})


AADD(opc, "X. parametri")

if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","ALL"))
    AADD(opcexe, {|| mat_parametri()})
else
    AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("gmat", .t. )

return




// -----------------------------------------------
// -----------------------------------------------
method setGVars()

set_global_vars()
set_roba_global_vars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gDirPor:=""
public gNalPr:="41#42"
public gCijena:=" "
public gKonto:="N"
public KursLis:="1"
public gpicdem:="9999999.99"
public gpicdin:="999999999999"
public gPicKol:="999999.999"
public g2Valute:="D"
public gPotpis:="N"

O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gDatNal:="N"
public gKupZad:="N"
public gSekS:="N"

RPar("dp",@gDirPor)
Rpar("2v",@g2Valute)
RPar("np",@gNalPr)
RPar("ci",@gCijena)
RPar("pe",@gpicdem)
RPar("pd",@gpicdin)
RPar("pk",@gpickol)
Rpar("dn",@gDatNal)
Rpar("ss",@gSekS)
RPar("kd",@gKupZad)
RPar("ko",@gKonto)

if empty(gDirPor)
    gDirPor:=strtran(cDirPriv,"MAT","KALK")+"\"
    WPar("dp",gDirPor)
endif

select params
use

public gModul
public gTema
public gGlBaza

gModul:="MAT"
gTema:="OSN_MENI"
gGlBaza:="SUBAN.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

return



