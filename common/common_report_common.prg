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


/*! \fn DokNovaStrana(nColumn, nStr, nSlijediRedovaZajedno)
 *  \brief Prelazak na novu stranicu
 *  \param nColumn - kolona na kojoj se stampa "Str: XXX"
 *  \param nStr  - stranica
 *  \param nSlijediRedovaZajedno - koliko nakon ove funkcije redova zelimo odstampati, nakon preloma se treba zajedno odstmpati "nSlijediRedova"; za vrijednost -1 stampa bez obzira na trenutnu poziciju (koristiti za stampu na prvoj strani)
 */

FUNCTION DokNovaStrana( nColumn, nStr, nSlijediRedovaZajedno )

   IF ( nSlijediRedovaZajedno == nil )
      nSlijediRedovaZajedno := 1
   ENDIF

   IF ( nSlijediRedovaZajedno == -1 ) .OR. ( PRow() > ( 59 + gPStranica - nSlijediRedovaZajedno ) )

      IF ( nSlijediRedovaZajedno <> -1 )
         FF
      ENDIF

      @ PRow(), nColumn SAY "Str:" + Str( ++nStr, 3 )

   ENDIF

   RETURN




FUNCTION NovaStrana( bZagl, nOdstampatiStrana )

   IF ( nOdstampatiStrana == NIL )
      nOdstampatiStrana := 1
   ENDIF

   IF PRow() > ( ( RPT_PAGE_LEN + gPStranica ) - nOdstampatiStrana )
      FF
      IF ( bZagl <> NIL )
         Eval( bZagl )
      ENDIF
   ENDIF

   RETURN




FUNCTION PrnClanoviKomisije()

   ?
   P_10CPI
   ? PadL( "Clanovi komisije: 1. ___________________", 75 )
   ? PadL( "2. ___________________", 75 )
   ? PadL( "3. ___________________", 75 )
   ?

   RETURN




/*! \fn FSvaki2()
 *  \brief
 */

FUNCTION FSvaki2()

   RETURN



/*! \fn IspisFirme(cIdRj)
 *  \brief Ispisuje naziv fime
 *  \param cIdRj  - Oznaka radne jedinice
 */

FUNCTION IspisFirme( cIdRj )

   LOCAL nOArr := Select()

   ?? "Firma: "
   B_ON
   ?? gNFirma
   B_OFF
   IF !Empty( cidrj )
      SELECT rj
      hseek cidrj
      Select( nOArr )
      ?? "  RJ", rj->naz
   ENDIF

   RETURN

FUNCTION IspisNaDan( nEmptySpace )

   ?? Replicate( " ", nEmptySpace ) + " Na dan: " + DToC( Date() )

   RETURN
