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

FUNCTION P_Konto( cId, dx, dy )

   LOCAL lRet

   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   PushWA()
   O_KONTO_NOT_USED

   AAdd( ImeKol, { PadC( "ID", 7 ), {|| id }, "id", {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( ImeKol, { "Naziv", {|| naz }, "naz" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   lRet := PostojiSifra( F_KONTO, 1, MAXROWS() - 15, MAXCOLS() - 20, "LKT: Lista: Konta", @cId, dx, dy )

   PopWa()

   RETURN lRet


/*
   Funkcija vraca vrijednost polja naziv po zadatom idkonto
*/
FUNCTION GetNameFromKonto( cIdKonto )

   LOCAL nArr

   nArr := Select()
   SELECT konto
   hseek cIdKonto
   cRet := AllTrim( field->naz )
   SELECT ( nArr )

   RETURN cRet
