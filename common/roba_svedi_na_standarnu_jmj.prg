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


STATIC s_cRobaTraziPoSifradob := NIL



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

   IF is_roba_trazi_po_sifradob()

      nTmpLen := Len( roba->sifradob )
      IF Len( AllTrim( cSifra ) ) < 5 // dodaj prefiks ako je ukucano manje od 5
         cSifra := PadR( PadL( AllTrim( cSifra ), nLen, cFill ), nTmpLen )
      ENDIF
   ENDIF

   RETURN .T.


FUNCTION roba_trazi_po_sifradob( cSet )

   IF s_cRobaTraziPoSifradob == NIL
      s_cRobaTraziPoSifradob := fetch_metric( "roba_trazi_po_sifradob", NIL, Space( 20 ) )
   ENDIF

   IF cSet != NIL
      s_cRobaTraziPoSifradob  := cSet
      set_metric( "roba_trazi_po_sifradob", NIL, cSet )
   ENDIF

   RETURN Trim( s_cRobaTraziPoSifradob )


FUNCTION is_roba_trazi_po_sifradob()

   IF roba_trazi_po_sifradob() == "SIFRADOB"
      RETURN .T.
   ENDIF

   RETURN .F.




// ----------------------------------
// svedi na standardnu jedinicu mjere
// ( npr. KOM->LIT ili KOM->KG )
// ----------------------------------

FUNCTION svedi_na_jedinicu_mjere( nKol, cIdRoba, cJMJ )

   LOCAL nVrati := 0, nArr := Select(), aNaz := {}, cKar := "SJMJ", nKO := 1, n_Pos := 0
   LOCAL cSvedi

   cSvedi := IzSifk( "ROBA", "SJMJ", cIdRoba, .F. )

   IF !Empty( cSvedi )
      AAdd( aNaz, cSvedi )
   ENDIF


   IF Len( aNaz ) > 0

      n_Pos := At( "_", aNaz[ 1 ] ) // slijedi preracunavanje 0.1_KG
      cPom   := AllTrim( SubStr( aNaz[ 1 ], n_Pos + 1 ) )
      nKO    := &cPom
      nVrati := nKol * nKO
      cJMJ   := AllTrim( Left( aNaz[ 1 ], n_Pos - 1 ) )
   ELSE

      nVrati := nKol // artikal je vec u osnovnoj JMJ
   ENDIF

   SELECT ( nArr )

   RETURN nVrati
