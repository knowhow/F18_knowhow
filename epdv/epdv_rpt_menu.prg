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


// ------------------------------
// ------------------------------
FUNCTION epdv_izvjestaji()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. kuf lista dokumenata " )
   AAdd( opcexe, {|| r_lista( "KUF" ) } )
   AAdd( opc, "2. kuf" )
   AAdd( opcexe, {|| rpt_kuf() } )

   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )


   AAdd( opc, "3. kif lista dokumenata " )
   AAdd( opcexe, {|| r_lista( "KIF" ) } )
   AAdd( opc, "4. kif" )
   AAdd( opcexe, {|| rpt_kif() } )

   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "5. prijava pdv-a" )
   AAdd( opcexe, {|| rpt_p_pdv() } )

   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )


   Menu_SC( "rpt" )

   RETURN
