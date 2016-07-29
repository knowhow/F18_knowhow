/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// ----------------------------------
// svedi na standardnu jedinicu mjere
// ( npr. KOM->LIT ili KOM->KG )
// ----------------------------------

FUNCTION SJMJ( nKol, cIdRoba, cJMJ )

   LOCAL nVrati := 0, nArr := Select(), aNaz := {}, cKar := "SJMJ", nKO := 1, n_Pos := 0

   SELECT SIFV; SET ORDER TO TAG "ID"
   HSEEK "ROBA    " + cKar + PadR( cIdRoba, 15 )
   DO WHILE !Eof() .AND. id + oznaka + idsif == "ROBA    " + cKar + PadR( cIdRoba, 15 )
      IF !Empty( naz )
         AAdd( aNaz, naz )
      ENDIF
      SKIP 1
   ENDDO
   IF Len( aNaz ) > 0
      // slijedi preracunavanje
      // ----------------------
      n_Pos := At( "_", aNaz[ 1 ] )
      cPom   := AllTrim( SubStr( aNaz[ 1 ], n_Pos + 1 ) )
      nKO    := &cPom
      nVrati := nKol * nKO
      cJMJ   := AllTrim( Left( aNaz[ 1 ], n_Pos - 1 ) )
   ELSE
      // valjda je ve� u osnovnoj JMJ
      // ----------------------------
      nVrati := nKol
   ENDIF
   SELECT ( nArr )

   RETURN nVrati



// ----------------------------------------------------------
// sredi sifru dobavljaca, poravnanje i popunjavanje
// ako je sifra manja od LEN(5) popuni na LEN(8) sa "0"
//
// cSifra - sifra dobavljaca
// nLen - na koliko provjeravati
// cFill - cime popuniti
// ----------------------------------------------------------
FUNCTION fix_sifradob( cSifra, nLen, cFill )

   LOCAL nTmpLen

   IF gArtCDX = "SIFRADOB"

      nTmpLen := Len( roba->sifradob )


      IF Len( AllTrim( cSifra ) ) < 5 // dodaj prefiks ako je ukucano manje od 5
         cSifra := PadR( PadL( AllTrim( cSifra ), nLen, cFill ), nTmpLen )
      ENDIF
   ENDIF

   RETURN .T.
