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

MEMVAR ImeKol, Kol

FIELD id, naz
MEMVAR wId


FUNCTION P_Konto( cId, dx, dy )

   LOCAL lRet, nI

   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   PushWA()

   IF cId != NIL .AND. !Empty( cId )
      select_o_konto( "XXXXXXX" ) // cId je zadan, otvoriti samo dummy tabelu sa 0 zapisa
   ELSE
      select_o_konto()
   ENDIF


   AAdd( ImeKol, { PadC( "ID", 7 ), {|| id }, "id", {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( ImeKol, { "Naziv", {|| naz }, "naz" } )

   FOR nI := 1 TO Len( ImeKol )
      AAdd( Kol, nI )
   NEXT

   lRet := p_sifra( F_KONTO, 1, MAXROWS() -15, MAXCOLS() - 20, "LKT: Lista: Konta", @cId, dx, dy )

   PopWa()

   RETURN lRet
