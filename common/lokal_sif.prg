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


FUNCTION P_Lokal( cId, dx, dy )

   LOCAL cHeader := lokal( "Lista: Lokalizacija" )
   LOCAL nArea := F_LOKAL
   PRIVATE Kol
   PRIVATE ImeKol

   SELECT ( nArea )

   O_LOKAL

   set_a_kol( @Kol, @ImeKol )

   RETURN p_sifra( nArea, 1, 10, 75, cHeader, ;
      @cId, dx, dy, ;
      {| Ch| k_handler( Ch ) } )


// --------------------------------------
// --------------------------------------
STATIC FUNCTION set_a_kol( aKol, aImeKol )

   LOCAL i

   aImeKol := {}

   AAdd( aImeKol, { "ID", {|| id }, "id", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "ID#STR", {|| id_str }, "id_str", {|| .T. }, {|| .T. } } )
   AAdd( aImeKol, { "Naziv", {|| Left( naz, 55 ) + ".." }, "naz", {|| .T. }, {|| .T. } } )

   aKol := {}
   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN




// ------------------------------------
// gen shema kif keyboard handler
// ------------------------------------
STATIC FUNCTION k_handler( Ch )

   LOCAL nOrder
   LOCAL nTekRec
   LOCAL nRet

   DO CASE
   CASE Chr( Ch ) $ "tT"
      DO WHILE .T.
         nTekRec := RecNo()
         add_prevod()
         aZabIsp := {}
         nOrder := IndexOrd()
         nRet := EditSifItem( Ch, nOrder, aZabIsp )
         IF nRet <> 1
            EXIT
         ENDIF
         GO ( nTekRec )

         SKIP

      ENDDO

      RETURN DE_REFRESH
   OTHERWISE
      RETURN DE_CONT
   ENDCASE

   // --------------------------
   // --------------------------

STATIC FUNCTION add_prevod()

   Scatter()
   _id := gLokal
   SELECT lokal

   // idlokala=hr + id_str=100
   SEEK PadR( gLokal, 2 ) + Str( _id_str, 6, 0 )
   IF !Found()
      APPEND BLANK
      // id lokala je tekuci globalni id
      _id := PadR( gLokal, 2 )
      Gather()
   ENDIF

   RETURN
