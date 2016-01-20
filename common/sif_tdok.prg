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

FUNCTION browse_tdok( cId, dx, dy )

   LOCAL nTArea
   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   nTArea := Select()
   O_TDOK

   AAdd( ImeKol, { "ID",    {|| PadR( ToStrU( field->id), 2 ) },  "id", {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( ImeKol, { "Naziv", {|| PadR( ToStrU( field->naz ), 35 ) }, "naz" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nTArea )

   RETURN p_sifra( F_TDOK, 1, Max( maxrows() - 20, 10 ), Max( maxcols() - 30, 35 ), "OsnPod: Vrste dokumenata", @cId, dx, dy )


FUNCTION P_TipDok( cId, dx, dy )
   RETURN browse_tdok( @cId, dx, dy )
