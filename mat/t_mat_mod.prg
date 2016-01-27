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
CLASS TMatMod FROM TAppMod

   METHOD NEW
   METHOD setGVars
   METHOD mMenu
   METHOD mMenuStandard
   METHOD initdb

END CLASS

// -----------------------------------------------
// -----------------------------------------------
METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self


// -----------------------------------------------
// -----------------------------------------------
METHOD initdb()

   ::oDatabase := TDbMat():new()

   RETURN NIL



// -----------------------------------------------
// -----------------------------------------------
METHOD mMenu()

   set_hot_keys()

   @ 1, 2 SAY PadC( gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL



// -----------------------------------------------
// -----------------------------------------------
METHOD mMenuStandard()

   PRIVATE Izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. unos/ispravka dokumenata                       " )
   AAdd( opcexe, {|| mat_knjizenje_naloga() } )
   AAdd( opc, "2. izvještaji" )
   AAdd( opcexe, {|| mat_izvjestaji() } )
   AAdd( opc, "3. kontrola zbira datoteka" )
   AAdd( opcexe, {|| mat_kzb() } )
   AAdd( opc, "4. štampa datoteke naloga" )
   AAdd( opcexe, {|| mat_dnevnik_naloga() } )
   AAdd( opc, "5. štampa proknjizenih naloga" )
   AAdd( opcexe, {|| mat_stampa_naloga() } )
   AAdd( opc, "6. inventura" )
   AAdd( opcexe, {|| mat_inventura() } )
   AAdd( opc, "F. prenos fakt->mat" )
   AAdd( opcexe, {|| mat_prenos_fakmat() } )
   AAdd( opc, "G. generacija dokumenta pocetnog stanja" )
   AAdd( opcexe, {|| mat_prenos_podataka() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "S. sifrarnici" )
   AAdd( opcexe, {|| mat_sifrarnik() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "P. povrat naloga u pripremu" )
   AAdd( opcexe, {|| mat_povrat_naloga() } )
   AAdd( opc, "9. administracija baze podataka" )
   AAdd( opcexe, {|| mat_admin_menu() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "X. parametri" )
   AAdd( opcexe, {|| mat_parametri() } )

   Menu_SC( "gmat", .T. )

   RETURN




// -----------------------------------------------
// -----------------------------------------------
METHOD setGVars()

   set_global_vars()
   set_roba_global_vars()

   PUBLIC gModul
   PUBLIC gTema
   PUBLIC gGlBaza

   PUBLIC gDirPor := ""
   PUBLIC gNalPr := "41#42"
   PUBLIC gCijena := "2"
   PUBLIC gKonto := "D"
   PUBLIC KursLis := "1"
   PUBLIC gpicdem := "9999999.99"
   PUBLIC gpicdin := "999999999.99"
   PUBLIC gPicKol := "999999.999"
   PUBLIC g2Valute := "N"
   PUBLIC gPotpis := "N"
   PUBLIC gDatNal := "D"
   PUBLIC gKupZad := "D"
   PUBLIC gSekS := "N"

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !!!"

   // read server params...
   gDirPor := fetch_metric( "mat_dir_kalk", my_user(), gDirPor  )
   g2Valute := fetch_metric( "mat_dvovalutni_rpt", NIL, g2Valute )
   gNalPr := fetch_metric( "mat_real_prod", NIL, gNalPr )
   gCijena := fetch_metric( "mat_tip_cijene", NIL, gCijena )
   gPicDem := AllTrim( fetch_metric( "mat_pict_dem", NIL, gPicDem ) )
   gPicDin := AllTrim( fetch_metric( "mat_pict_din", NIL, gPicDin ) )
   gPicKol := AllTrim( fetch_metric( "mat_pict_kol", NIL, gPicKol ) )
   gDatNal := fetch_metric( "mat_datum_naloga", NIL, gDatNal )
   gSekS := fetch_metric( "mat_sekretarski_sistem", NIL, gSekS )
   gKupZad := fetch_metric( "mat_polje_partner", NIL, gKupZad )
   gKonto := fetch_metric( "mat_vezni_konto", NIL, gKonto )
   gPotpis := fetch_metric( "mat_rpt_potpis", my_user(), gPotpis )

   gModul := "MAT"
   gTema := "OSN_MENI"
   gGlBaza := "SUBAN.DBF"

   RETURN
