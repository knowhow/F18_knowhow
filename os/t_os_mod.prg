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


#include "f18.ch"
#include "hbclass.ch"

// -----------------------------------------------
// -----------------------------------------------
CLASS TOsMod FROM TAppMod
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
::oDatabase:=TDbOs():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()
local _tmp

_tmp := fetch_metric( "os_set_epoch", NIL, 0 )
//nPom := VAL( IzFmkIni( "SET", "Epoch", "1945", KUMPATH ) )

IF _tmp > 0 
    SET EPOCH TO ( _tmp )
ENDIF

PUBLIC gSQL := "N"
PUBLIC gCentOn := fetch_metric( "os_set_century_on", NIL, "N" ) 
                    //IzFmkIni( "SET", "CenturyOn", "N", KUMPATH )

IF gCentOn == "D"
    SET CENTURY ON
ELSE
    SET CENTURY OFF
ENDIF

os_set_datum_obrade()
set_os_info()
set_hot_keys()

@ 1,2 SAY padc( gTS + ": " + gNFirma, 50, "*" )
@ 4,5 SAY ""

::mMenuStandard()

return nil


// --------------------------------------------
// --------------------------------------------
method mMenuStandard
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD(_opc, "1. unos promjena na postojecem sredstvu                     ")
AADD(_opcexe, {|| unos_osnovnih_sredstava()})
AADD(_opc, "2. obracuni")
AADD(_opcexe, {|| os_obracuni() })
AADD(_opc, "3. izvjestaji")
AADD(_opcexe, {|| os_izvjestaji() })
AADD(_opc, "------------------------------------------------------------")
AADD(_opcexe, {|| nil })
AADD(_opc, "5. sifrarnici")
AADD(_opcexe, {|| os_sifrarnici()})
AADD(_opc, "6. parametri")
AADD(_opcexe, {|| os_parametri()})
AADD(_opc, "------------------------------------------------------------")
AADD(_opcexe, {|| nil })
AADD(_opc, "8. prenos pocetnog stanja ")
AADD(_opcexe, {|| os_generacija_pocetnog_stanja() })

f18_menu( "gos", .f., _izbor, _opc, _opcexe )

return


// -------------------------------------------------
// -------------------------------------------------
method setGVars()

set_global_vars()

// ostali parametri
public gDatObr := DATE()
public gRJ := "00"
public gValuta := "KM "
public gPicI := "99999999.99"
public gPickol := "99999.99"
public gVObracun := "2"
public gIBJ := "D"
public gDrugaVal :="N"
public gVarDio := "N"
public gDatDio := CTOD("01.01.1999")
public gGlBaza := "OS.DBF"
public gMetodObr := "1"
public gOsSii := "O"

// procitaj iz sql/db
gRJ := fetch_metric( "os_radna_jedinica", nil, gRJ )
gOsSii := fetch_metric( "os_sii_modul", my_user(), gOsSii )
gDatObr := fetch_metric( "os_datum_obrade", my_user(), gDatObr )
gPicI := fetch_metric( "os_prikaz_iznosa", nil, gPicI )
gMetodObr := fetch_metric( "os_metoda_obracuna", nil, gMetodObr )
gIBJ := fetch_metric( "os_id_broj_je_unikatan", nil, gIBJ )
gDrugaVal := fetch_metric( "os_prikaz_u_dvije_valute", nil, gDrugaVal )
gVObracun := fetch_metric( "os_varijanta_obracuna", nil, gVObracun )
gVarDio := fetch_metric( "os_pocetak_obracuna", nil, gVarDio )
gDatDio := fetch_metric( "os_pocetak_obracuna_datum", nil, gDatDio )

return




