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


#include "fmk.ch"


FUNCTION VidiFajl( cImeF, aLinFiks, aKolFiks )

   f18_run( "gedit" + cImeF )


FUNCTION SljedLin( cFajl, nPocetak )

   LOCAL cPom, nPom

   cPom := FileStr( cFajl, 400, nPocetak )
   nPom := At( NRED, cPom )
   IF nPom == 0; nPom := Len( cPom ) + 1; ENDIF

   RETURN { Left( cPom, nPom - 1 ), nPocetak + nPom + 1 }  // {cLinija,nPocetakSljedece}


FUNCTION PrethLin( cFajl, nKraj )

   LOCAL nKor := 400, cPom, nPom

   IF nKraj - nKor - 2 < 0
      nKor := nKraj - 2
   ENDIF

   cPom := FileStr( cFajl, nKor, nKraj - nKor - 2 )
   nPom := RAt( NRED,cPom )

   RETURN IF( nPom == 0, { cPom, 0 }, { SubStr( cPom, nPom + 2 ), nKraj - nKor + nPom - 1 } )
// {cLinija,nNjenPocetak}

   RETURN


FUNCTION BrLinFajla( cImeF )

   LOCAL nOfset := 0
   LOCAL nSlobMem := 0
   LOCAL cPom := ""
   LOCAL nVrati := 0

   IF FileStr( cImeF, 2, VelFajla( cImeF ) -2 ) != NRED
      nVrati := 1
   ENDIF
   DO WHILE Len( cPom ) >= nSlobMem
      nSlobMem := Memory( 1 ) * 1024 -100
      cPom := FileStr( cImeF, nSlobMem, nOfset )
      nOfset = nOfset + nSlobMem - 1
      nVrati = nVrati + NumAt( NRED, cPom )
   ENDDO

   RETURN nVrati

// -------------------------------------
// -------------------------------------
FUNCTION VelFajla( cImeF, cAttr )

   LOCAL aPom := Directory( cImeF, cAttr )

   RETURN IF ( !Empty( aPom ), aPom[ 1, 2 ], 0 )
