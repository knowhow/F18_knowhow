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

// --------------------------------------------------
// prikazi info 99 - otvori sifrarnik
// --------------------------------------------------
FUNCTION info_0_sif( nPadR )

   LOCAL cTxt := "/ 0 - otvori sifrarnik /"

   show_it( cTxt, nPadR )

   RETURN


// --------------------------------------------------
// prikazi info 99 - otvori sifrarnik
// --------------------------------------------------
FUNCTION info_99_sif( nPadR )

   LOCAL cTxt := "/ 99 - otvori sifrarnik /"
   show_it( cTxt, nPadR )

   RETURN


// --------------------------------------------------
// prikazi pay types
// --------------------------------------------------
FUNCTION info_pay( nPadR )

   LOCAL cTxt := "/ 1 - z.racun / 2 - gotovina /"
   show_it( cTxt, nPadR )

   RETURN


// --------------------------------------------------
// prikazi prioritet
// --------------------------------------------------
FUNCTION info_priority( nPadR )

   LOCAL cTxt := "/ 1 - high / 2 - normal / 3 - low /"

   show_it( cTxt, nPadR )

   RETURN




// --------------------------------------------------
// vraca broj stakala za artikal...
// --------------------------------------------------
FUNCTION broj_stakala( arr, qtty )

   LOCAL _count := 0
   LOCAL nI
   LOCAL _gr_name

   IF arr == NIL .OR. Len( arr ) == 0
      RETURN _count
   ENDIF

   // arr
   // { nElNo, cGrValCode, cGrVal, cAttJoker, cAttValCode, cAttVal }

   FOR nI := 1 TO Len( arr )
      _gr_name := AllTrim( arr[ nI, 4 ] )
      IF _gr_name == "<GL_TYPE>"
         ++ _count
      ENDIF
   NEXT

   IF _count > 0 .AND. qtty <> 0
      _count := _count * qtty
   ENDIF

   RETURN _count
