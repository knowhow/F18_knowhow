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



FUNCTION P_RJ( cId, nDeltaX, nDeltaY )

   LOCAL nTArea, nI

   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   nTArea := Select()

   o_rj()

   AAdd( ImeKol, { PadR( "Id",  2 ),       {|| id },   "id",     {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( ImeKol, { PadR( "Naziv", 35 ),    {|| PadR( naz, 35 ) },  "naz" } )
   AAdd( ImeKol, { PadR( "Tip cij.", 10 ), {|| tip },    "tip" } )
   AAdd( ImeKol, { PadR( "Konto", 10 ),    {|| konto },  "konto" } )

   FOR nI := 1 TO Len( ImeKol )
      AAdd( Kol, nI )
   NEXT

   SELECT ( nTArea )

   RETURN p_sifra( F_RJ, 1, MAXROWS() - 15, MAXCOLS() - 30,"MatPod: Lista radnih jedinica", @cId, nDeltaX, nDeltaY )
