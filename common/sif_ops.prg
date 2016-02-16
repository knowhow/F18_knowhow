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


FUNCTION P_Ops( cId, dx, dy )

   LOCAL _i, hWorkArea, xRet
   PRIVATE ImeKol
   PRIVATE Kol


   hWorkArea := PushWA()

   IF !hWorkArea[ 'sql' ] .AND. cId != NIL
      // ako je SQL tabela onda je cId UTF8 string
      cId := hb_StrToUTF8( cId )
   ENDIF

   O_OPS

   ImeKol := {}
   Kol := {}

   AAdd( ImeKol, { PadR( "Id", 4 ),  {|| PadrU( field->id, 4 ) }, "id", {|| .T. }, {|| sifra_postoji( wid ) } } )
   AAdd( ImeKol, { PadR( "IDJ", 3 ), {|| idj }, "idj" } )
   AAdd( ImeKol, { PadR( "Kan", 3 ), {|| idkan }, "idkan" } )
   AAdd( ImeKol, { PadR( "N0", 3 ),  {|| idN0 }, "idN0" } )
   AAdd( ImeKol, { PadR( "Naziv", 25 ), {|| PadR( ToStrU( naz ), 25 ) }, "naz" } )
   AAdd( ImeKol, { PadR( "Reg", 3 ), {|| reg }, "reg" } )

   FOR _i := 1 TO Len( ImeKol )
      AAdd( Kol, _i )
   NEXT

   xRet := p_sifra( F_OPS, 1, MAXROWS() - 15, MAXCOLS() - 10, "MP: Lista općina", @cId, dx, dy )

   hWorkArea := PopWA()

   IF !hWorkArea[ 'sql' ]
      // ako smo na pocetku uradili konverziju moramo napraviti novu obrnutu konverziju
      cId := hb_UTF8ToStr( cId )
   ENDIF

   RETURN xRet



FUNCTION P_Banke( cId, dx, dy )

   LOCAL _arr, _i
   PRIVATE ImeKol
   PRIVATE Kol

   _arr := Select()
   O_BANKE

   ImeKol := {}
   AAdd( ImeKol, { PadR( "Id", 2 ), {|| id }, "id", {|| .T. }, {|| sifra_postoji( wId ) } } )
   AAdd( ImeKol, { PadR( "Naziv", 35 ), {|| PadR( ToStrU( naz ), 35 ) }, "naz" } )
   AAdd( ImeKol, { "Mjesto", {|| mjesto }, "mjesto" } )
   AAdd( ImeKol, { "Adresa", {|| adresa }, "adresa" } )

   Kol := {}
   FOR _i := 1 TO Len( ImeKol )
      AAdd( Kol, _i )
   NEXT

   SELECT ( _arr )

   RETURN p_sifra( F_BANKE, 1, MAXROWS() -15, MAXCOLS() -10, "MatPod: Lista banaka", @cId, dx, dy )
