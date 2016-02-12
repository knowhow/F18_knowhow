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


#include "hbclass.ch"


CLASS TReportsMod FROM TAppMod

   METHOD NEW
   METHOD setGVars

   METHOD mMenu
   METHOD mMenuStandard

END CLASS



METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self




// -----------------------------------------------
// -----------------------------------------------
METHOD mMenu()

   CLOSE ALL

   @ 1, 2 SAY PadC( gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL



// -----------------------------------------------
// -----------------------------------------------
METHOD mMenuStandard()

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. finansijski izvještaji                                  " )
   AAdd( opcexe, {|| fin_suban_izvjestaji() } )
   AAdd( opc, "2. robni izvjestaji      " )
   AAdd( opcexe, {|| NIL } )


   Menu_SC( "grep", .T., .F. )

   RETURN



// ---------------------------------------------
// ---------------------------------------------
METHOD setGVars()

   set_global_vars()
   set_roba_global_vars()

   PUBLIC gModul
   PUBLIC gTema
   PUBLIC gGlBaza

   gModul := "REPORTS"
   gTema := "OSN_MENI"
   gGlBaza := ""

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !!!"

   RETURN
