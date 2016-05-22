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


// ------------------------------------------------------
// Pregled liste exportovanih dokumenata te odabir
// zeljenog fajla z import
// - param cFilter - filter naziva dokumenta
// - param cPath - putanja do exportovanih dokumenata
// ------------------------------------------------------
FUNCTION get_file_list( cFilter, cPath, cImpFile )

   OpcF := {}


   aFiles := Directory( cPath + cFilter )  // cFilter := "*.txt"


   IF Len( aFiles ) == 0 // da li postoje fajlovi
      MsgBeep( "U direktoriju za prenos nema podataka!##" + cPath + cFilter )
      RETURN 0
   ENDIF

   // sortiraj po datumu
   ASort( aFiles,,, {| x, y| x[ 3 ] > y[ 3 ] } )
   AEval( aFiles, {| elem| AAdd( OpcF, PadR( elem[ 1 ], 15 ) + " " + DToC( elem[ 3 ] ) ) }, 1 )
   // sortiraj listu po datumu
   ASort( OpcF,,, {| x, y| Right( x, 10 ) > Right( y, 10 ) } )

   h := Array( Len( OpcF ) )
   FOR i := 1 TO Len( h )
      h[ i ] := ""
   NEXT

   // selekcija fajla
   IzbF := 1
   lRet := .F.
   DO WHILE .T. .AND. LastKey() != K_ESC
      IzbF := Menu( "imp", OpcF, IzbF, .F. )
      IF IzbF == 0
         EXIT
      ELSE
         cImpFile := Trim( cPath ) + Trim( Left( OpcF[ IzbF ], 15 ) )
         IF Pitanje( , "Želite li izvrsiti import fajla ?", "D" ) == "D"
            IzbF := 0
            lRet := .T.
         ENDIF
      ENDIF
   ENDDO
   IF lRet
      RETURN 1
   ELSE
      RETURN 0
   ENDIF

   RETURN 1





// -----------------------------------------------------
// puni matricu sa redom csv formatiranog
// -----------------------------------------------------
FUNCTION csvrow2arr( cRow, cDelimiter )

   LOCAL aArr := {}
   LOCAL i
   LOCAL cTmp := ""
   LOCAL cWord := ""
   LOCAL nStart := 1

   FOR i := 1 TO Len( cRow )

      cTmp := SubStr( cRow, nStart, 1 )

      // ako je cTmp = ";" ili je iscurio niz - kraj stringa
      IF cTmp == cDelimiter .OR. i == Len( cRow )

         // ako je iscurio - dodaj i zadnji karakter u word
         IF i == Len( cRow )
            cWord += cTmp
         ENDIF

         // dodaj u matricu
         AAdd( aArr, cWord )
         cWord := ""

      ELSE
         cWord += cTmp
      ENDIF

      ++ nStart

   NEXT

   RETURN aArr


// ----------------------------------------------
// vraca numerik na osnovu txt polja
// ----------------------------------------------
FUNCTION _g_num( cVal )

   cVal := StrTran( cVal, ",", "." )

   RETURN Val( cVal )
