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


#include "fmk.ch"

// -------------------------------------------------------
// Setuj matricu sa poljima tabele dokumenata TERM
// -------------------------------------------------------
STATIC FUNCTION _sTblTerm( aDbf )

   AAdd( aDbf, { "barkod",  "C", 13, 0 } )
   AAdd( aDbf, { "idroba",  "C", 10, 0 } )
   AAdd( aDbf, { "kolicina", "N", 15, 5 } )
   AAdd( aDbf, { "status", "N", 2, 0 } )

   // status
   // 0 - nema robe u sifrarniku
   // 1 - roba je tu

   RETURN


// --------------------------------------------------------
// Kreiranje temp tabele, te prenos zapisa iz text fajla
// "cTextFile" u tabelu
// - param cTxtFile - txt fajl za import
// --------------------------------------------------------
FUNCTION Txt2TTerm( cTxtFile )

   LOCAL cDelimiter := ";"
   LOCAL aDbf := {}
   LOCAL _o_file

   cTxtFile := AllTrim( cTxtFile )

   // prvo kreiraj tabelu temp
   my_close_all_dbf()

   // polja tabele TEMP.DBF
   _sTblTerm( @aDbf )

   // kreiraj tabelu
   _creTemp( aDbf, .T. )

   IF !File( my_home() + "temp.dbf" )
      MsgBeep( "Ne mogu kreirati fajl TEMP.DBF!" )
      RETURN
   ENDIF

   // otvori tabele
   O_ROBA

   SELECT ( F_TMP_1 )
   USE
   my_use_temp( "temp", my_home() + "temp.dbf" )

   // zatim iscitaj fajl i ubaci podatke u tabelu

   _o_file := TFileRead():New( cTxtFile )
   _o_file:Open()

   IF _o_file:Error()
      MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
      RETURN
   ENDIF

   // prodji kroz svaku liniju i insertuj zapise u temp.dbf

   WHILE _o_file:MoreToRead()
	
      // uzmi u cText liniju fajla
      cVar := hb_StrToUTF8( _o_file:ReadLine() )

      IF Empty( cVar )
         LOOP
      ENDIF

      aRow := csvrow2arr( cVar, cDelimiter )
	
      // struktura podataka u txt-u je
      // [1] - barkod
      // [2] - kolicina
	
      // pa uzimamo samo sta nam treba
      cTmp := PadR( AllTrim( aRow[ 1 ] ), 13 )
      nTmp := Val ( AllTrim( aRow[ 2 ] ) )
	
      SELECT roba
      SET ORDER TO TAG "BARKOD"
      GO TOP
      SEEK cTmp

      IF Found()
         cRoba_id := field->id
         nStatus := 1
      ELSE
         cRoba_id := ""
         nStatus := 0
      ENDIF

      // selektuj temp tabelu
      SELECT temp
      // dodaj novi zapis
      APPEND BLANK

      REPLACE barkod WITH cTmp
      REPLACE idroba WITH cRoba_id
      REPLACE kolicina WITH nTmp
      REPLACE status WITH nStatus

   ENDDO

   _o_file:Close()

   SELECT temp

   MsgBeep( "Import txt => temp - OK" )

   RETURN


// ----------------------------------------------------------------
// Kreira tabelu PRIVPATH\TEMP.DBF prema definiciji polja iz aDbf
// ----------------------------------------------------------------
STATIC FUNCTION _creTemp( aDbf, lIndex )

   LOCAL _table := "temp"

   IF lIndex == NIL
      lIndex := .T.
   ENDIF

   FErase( my_home() + "temp.dbf" )

   dbCreate( my_home() + _table, aDbf )

   IF lIndex

      SELECT ( F_TMP_1 )
      USE

      my_use_temp( "temp", my_home() + "temp.dbf" )

      INDEX ON barkod TAG "1"
      INDEX ON idroba TAG "2"
      INDEX ON Str( status ) TAG "3"

      SELECT ( F_TMP_1 )
      USE

   ENDIF

   RETURN
