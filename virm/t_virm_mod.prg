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
CLASS TVirmMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD mMenu
   METHOD mMenuStandard

END CLASS


METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self


METHOD mMenu()

   PRIVATE Izbor
   PRIVATE lPodBugom

   PUBLIC gSQL := "N"

   set_hot_keys()

   Izbor := 1

   @ 1, 2 SAY PadC( gTS + ": " + gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL


// ----------------------------------------
// ----------------------------------------
METHOD mMenuStandard

   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc,   "1. priprema virmana                         " )
   AAdd( opcexe, {|| unos_virmana() } )
   AAdd( opc,   "2. izvjestaji" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc,   "3. moduli - razmjena podataka " )
   AAdd( opcexe, {|| virm_razmjena_podataka() } )
   AAdd( opc,   "4. export podataka za banku" )
   AAdd( opcexe, {|| virm_export_banke() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc,   "S. sifrarnici" )
   AAdd( opcexe, {|| virm_sifrarnici() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc,   "X. parametri" )
   AAdd( opcexe, {|| virm_parametri() } )

   PRIVATE Izbor := 1

   Menu_SC( "gvir", .T. )

   RETURN


METHOD set_module_gvars()

   virm_set_global_vars()

   RETURN .T.



FUNCTION virm_set_global_vars()

   PUBLIC gDatum := Date()
   PUBLIC gMjesto := Space( 16 )
   PUBLIC gOrgJed := Space( 17 )
   PUBLIC gINulu := "N"
   PUBLIC gPici := "9,999,999,999,999,999.99"
   PUBLIC gIDU := "D"
   PUBLIC gVirmFirma

   gMjesto := fetch_metric( "virm_mjesto_uplate", nil, PadR( "Sarajevo", 100 ) )
   gOrgJed := fetch_metric( "virm_org_jedinica", nil, PadR( "--", 17 ) )
   gPici := fetch_metric( "virm_iznos_pict", nil, gPici )
   gINulu := fetch_metric( "virm_stampati_nule", nil, gINulu )
   gIDU := fetch_metric( "virm_sys_datum_uplate", nil, gIDU )
   gDatum := fetch_metric( "virm_init_datum_uplate", nil, gDatum )
   gVirmFirma := PadR( fetch_metric( "virm_org_id", nil, "" ), 6 )

   RETURN .T.
