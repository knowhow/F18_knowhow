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


FUNCTION browse_tnal( cId, dx, dy )

   LOCAL nTArea
   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   nTArea := Select()

   o_tnal()

   AAdd( ImeKol, { "ID", {|| field->id }, "id", {|| .T. }, {|| valid_sifarnik_id_postoji( wId ) } } )
   AAdd( ImeKol, { "Naziv", {|| PadR( field->naz , 30 ) }, "naz" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nTArea )

   RETURN p_sifra( F_TNAL, 1, Max( maxrows() - 20, 10 ), Max( maxcols() - 30, 50 ), "OsnPod: Vrste naloga", @cId, dx, dy )



FUNCTION P_VN( cId, dx, dy )

   RETURN browse_tnal( @cId, dx, dy )
