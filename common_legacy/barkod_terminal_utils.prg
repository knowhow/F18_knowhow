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
FUNCTION _gFList( cFilter, cPath, cImpFile )

   OpcF := {}

   // cFilter := "*.txt"
   aFiles := Directory( cPath + cFilter )

   // da li postoje fajlovi
   IF Len( aFiles ) == 0
      MsgBeep( "U direktoriju za prenos nema podataka" )
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


/* TxtErase(cTxtFile, lErase)
 *     Brisanje fajla cTxtFile
 *   param: cTxtFile - fajl za brisanje
 *   param: lErase - .t. ili .f. - brisati ili ne brisati fajl txt nakon importa
 */
FUNCTION TxtErase( cTxtFile, lErase )

   IF lErase == nil
      lErase := .F.
   ENDIF

   // postavi pitanje za brisanje fajla
   IF lErase .AND. Pitanje(, "Pobrisati txt fajl (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   IF FErase( cTxtFile ) == -1
      MsgBeep( "Ne mogu izbrisati " + cTxtFile )

   ENDIF

   RETURN .T.


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


// -------------------------------------------------------------
// Provjera da li postoje sifre artikla u sifraniku FMK
//
// lSifraDob - pretraga po sifri dobavljaca
// -------------------------------------------------------------
FUNCTION TempArtExist( lSifraDob )

   IF lSifraDob == nil
      lSifraDob := .F.
   ENDIF

   O_ROBA
   SELECT temp
   GO TOP

   aRet := {}

   DO WHILE !Eof()

      IF lSifraDob == .T.
         cTmpRoba := PadL( AllTrim( temp->idroba ), 5, "0" )
      ELSE
         cTmpRoba := AllTrim( temp->idroba )
      ENDIF

      cNazRoba := ""

      // ako u temp postoji "NAZROBA"
      IF temp->( FieldPos( "nazroba" ) ) <> 0
         cNazRoba := AllTrim( temp->nazroba )
      ENDIF

      SELECT roba

      IF lSifraDob == .T.
         SET ORDER TO TAG "ID_VSD"
      ENDIF

      GO TOP
      SEEK cTmpRoba

      // ako nisi nasao dodaj robu u matricu
      IF !Found()
         nRes := AScan( aRet, {| aVal| aVal[ 1 ] == cTmpRoba } )
         IF nRes == 0
            AAdd( aRet, { cTmpRoba, cNazRoba } )
         ENDIF
      ENDIF

      SELECT temp
      SKIP
   ENDDO

   RETURN aRet
