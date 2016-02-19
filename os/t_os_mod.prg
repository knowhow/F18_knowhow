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



CLASS TOsMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD mMenu
   METHOD mMenuStandard

ENDCLASS



METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self


// -----------------------------------------------
// -----------------------------------------------
METHOD mMenu()

   LOCAL _tmp

   _tmp := fetch_metric( "os_set_epoch", NIL, 0 )
   // nPom := VAL( IzFmkIni( "SET", "Epoch", "1945", KUMPATH ) )

   IF _tmp > 0
      SET EPOCH TO ( _tmp )
   ENDIF

   PUBLIC gSQL := "N"
   PUBLIC gCentOn := fetch_metric( "os_set_century_on", NIL, "N" )
   // IzFmkIni( "SET", "CenturyOn", "N", KUMPATH )

   IF gCentOn == "D"
      SET CENTURY ON
   ELSE
      SET CENTURY OFF
   ENDIF

   os_set_datum_obrade()
   set_os_info()
   set_hot_keys()

   @ 1, 2 SAY PadC( gTS + ": " + gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL



METHOD mMenuStandard

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   AAdd( _opc, "1. unos promjena na postojecem sredstvu                     " )
   AAdd( _opcexe, {|| unos_osnovnih_sredstava() } )
   AAdd( _opc, "2. obracuni" )
   AAdd( _opcexe, {|| os_obracuni() } )
   AAdd( _opc, "3. izvjestaji" )
   AAdd( _opcexe, {|| os_izvjestaji() } )
   AAdd( _opc, "------------------------------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "5. sifrarnici" )
   AAdd( _opcexe, {|| os_sifrarnici() } )
   AAdd( _opc, "6. parametri" )
   AAdd( _opcexe, {|| os_parametri() } )
   AAdd( _opc, "------------------------------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "8. prenos pocetnog stanja " )
   AAdd( _opcexe, {|| os_generacija_pocetnog_stanja() } )

   f18_menu( "gos", .F., _izbor, _opc, _opcexe )

   RETURN


METHOD set_module_gvars()



   // ostali parametri
   PUBLIC gDatObr := Date()
   PUBLIC gRJ := "00"
   PUBLIC gValuta := "KM "
   PUBLIC gPicI := "99999999.99"
   PUBLIC gPickol := "99999.99"
   PUBLIC gVObracun := "2"
   PUBLIC gIBJ := "D"
   PUBLIC gDrugaVal := "N"
   PUBLIC gVarDio := "N"
   PUBLIC gDatDio := CToD( "01.01.1999" )
   PUBLIC gGlBaza := "OS.DBF"
   PUBLIC gMetodObr := "1"
   PUBLIC gOsSii := "O"

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

   RETURN
