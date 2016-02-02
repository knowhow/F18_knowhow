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


// -------------------------------------------
// -------------------------------------------
FUNCTION epdv_admin_menu()

   // {
   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1


   AAdd( opc, "1. renumeracija g_r_br KUF" )
   AAdd( opcexe, {|| rn_gr( "KUF" ) } )
   AAdd( opc, "2. renumeracija g_r_br KIF" )
   AAdd( opcexe, {|| rn_gr( "KIF" ) } )

   Menu_SC( "adm" )

   RETURN
// }

// ---------------------------------
// ---------------------------------
STATIC FUNCTION rn_gr( cTblName )

   IF Pitanje(, "Izvrsiti renumeriranje ? " + cTblName, "N" ) == "D"
      IF SigmaSif( "RNGR" )
         rn_g_r_br( cTblName )
      ELSE
         MsgBeep( "Pogresna lozinka, nista od posla ..." )
      ENDIF
   ENDIF

   RETURN
