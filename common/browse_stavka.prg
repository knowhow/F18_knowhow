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

MEMVAR ImeKol

FUNCTION browse_stavka_formiraj_getlist( cVariableName, GetList, lZabIsp, aZabIsp, lShowGrup, Ch, nGet, nI, nTekRed )

   LOCAL bWhen, bValid, cPic
   LOCAL nRed, nKolona
   LOCAL cWhenSifk, cValidSifk
   LOCAL _when_block, _valid_block
   LOCAL bVariableEval := MemVarBlock( cVariableName )
   LOCAL cFieldName
   LOCAL tmpRec
   LOCAL aFieldLen, nFieldWidth

   // uzmi when, valid kodne blokove
   IF ( Ch == K_F2 .AND. lZabIsp .AND. AScan( aZabIsp, Upper( ImeKol[ nI, 3 ] ) ) > 0 )
      bWhen := {|| .F. }
   ELSEIF ( Len( ImeKol[ nI ] ) < 4 .OR. ImeKol[ nI, 4 ] == NIL )
      bWhen := {|| .T. }
   ELSE
      bWhen := Imekol[ nI, 4 ]
   ENDIF

   IF ( Len( ImeKol[ nI ] ) < 5 .OR. ImeKol[ nI, 5 ] == NIL )
      bValid := {|| .T. }
   ELSE
      bValid := Imekol[ nI, 5 ]
   ENDIF

   bVariableEval := MemVarBlock( cVariableName )

   IF bVariableEval == NIL
      MsgBeep( "Varijabla nedefinisana :" + cVariableName )
   ENDIF

   cFieldName := SubStr( cVariableName, 2 ) // wID -> ID
   cPic := get_field_get_picture_code( Alias(), cFieldName )
   aFieldLen := get_field_len( Alias(), cFieldName )
   IF aFieldLen != NIL .AND. aFieldLen[ 1 ] == "C"
      nFieldWidth := aFieldLen[ 2 ] // char polje sirina
   ENDIF

   IF cPic ==  "@S50" .OR. Len( ToStr( Eval( bVariableEval ) ) ) > 50
      cPic :=  "@S50"
      @ m_x + nTekRed + 1, m_y + 67 SAY Chr( 16 )
   ENDIF

   IF Len( ImeKol[ nI ] ) >= 7 .AND. ImeKol[ nI, 7 ] <> NIL // picture kod zadan u ImeKol
      cPic := ImeKol[ nI, 7 ]
   ENDIF

   nRed := 1
   nKolona := 1

   IF Len( ImeKol[ nI ] ) >= 10 .AND. Imekol[ nI, 10 ] <> NIL
      nKolona := ImeKol[ nI, 10 ] + 1
      nRed := 0
   ENDIF

   IF nKolona == 1
      nTekRed++
   ENDIF

   IF lShowPGroup
      nXP := nTekRed
      nYP := nKolona
   ENDIF


   IF lShowPGroup  // stampaj grupu za stavku "GRUP"
      p_gr( &cVariableName, m_x + nXP, m_y + nYP + 1 )
   ENDIF

   IF "wSifk_" $ cVariableName

      IzSifKWV( Alias(), SubStr( cVariableName, 7 ), @cWhenSifk, @cValidSifk )

      IF !Empty( cWhenSifk )
         _when_block := & ( "{|| " + cWhenSifk + "}" )
      ELSE
         _when_block := bWhen
      ENDIF

      IF !Empty( cValidSifk )
         _valid_block := & ( "{|| " + cValidSifk + "}" )
      ELSE
         _valid_block := bValid
      ENDIF
   ELSE
      _when_block := bWhen
      _valid_block := bValid
   ENDIF

   @ m_x + nTekRed, m_y + nKolona SAY  iif( nKolona > 1, "  " + AllTrim( ImeKol[ nI, 1 ] ), PadL( AllTrim( ImeKol[ nI, 1 ] ), 15 ) )  + " "

   IF &cVariableName == NIL
      tmpRec = RecNo()
      GO BOTTOM
      SKIP
      &cVariableName := Eval( ImeKol[ nI, 2 ] )
      GO tmpRec
   ENDIF

   IF ValType( &cVariableName ) == "C"
      IF nFieldWidth != NIL // znamo koja je potrebna sirina polja
         // ovo je potrebno radi char varying polja koje vrate trimovan string, npr "abc", za edit treba full width string Padr( "abc", 250 )
         &cVariableName = PadR( &cVariableName, nFieldWidth )
      ENDIF
   ENDIF

   IF ValType( &cVariableName ) == "C" .AND. F18_SQL_ENCODING == "UTF8" // samo ako sql vraca UTF8 stringove izvrsitiŽŽŽ ovu konverziju
      &cVariableName = hb_UTF8ToStr( &cVariableName ) // F18 SQL ENCODING UTF8
   ENDIF



   AAdd( GetList, _GET_( &cVariableName, cVariableName,  cPic, _valid_block, _when_block ) ) ;;
      ATail( GetList ):display()

   RETURN .T.





FUNCTION get_field_get_picture_code( cAlias, cField )

   LOCAL aFieldLen := get_field_len( cAlias, Lower( cField ) )

   IF aFieldLen == NIL
      RETURN ""
   ENDIF

   IF aFieldLen[ 1 ] == "C"
      IF aFieldLen[ 2 ] > 50
         RETURN "@S50"
      ENDIF
      RETURN Replicate( "X", aFieldLen[ 2 ] )
   ENDIF

   IF ( aFieldLen[ 1 ] $ "NBY" )
      RETURN Replicate( "9", aFieldLen[ 2 ] - aFieldLen[ 3 ] - 1 ) + "." + Replicate( "9", aFieldLen[ 3 ] ) // numeric 999999999.99999999
   ENDIF

   RETURN "" // nije numeric ni char



FUNCTION get_field_len( cAlias, cField )

   LOCAL hDbfRec := get_a_dbf_rec( cAlias ), hLens

   IF !hb_HHasKey( hDbfRec, "dbf_fields_len" ) .OR. hDbfRec[ "dbf_fields_len" ] == NIL
      RETURN NIL
   ENDIF

   hLens := hDbfRec[ "dbf_fields_len" ]
   IF !hb_HHasKey( hLens, Lower( cField ) ) // to hibridna polaj sifk_gr1, sifk_gr2 itd.
      // Alert( "tabela " + cAlias + " ne sadrzi polje: " + cField + " ?!" )
      RETURN NIL
   ENDIF

   RETURN hDbfRec[ "dbf_fields_len" ][ Lower( cField ) ] // { "B", 18, 8} ili NIL
