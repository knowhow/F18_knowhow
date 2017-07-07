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


// -------------------------------------------------------
// import barcode terminal data
// -------------------------------------------------------
FUNCTION import_BTerm_data( cI_File )

   LOCAL cPath := ""
   LOCAL aError := {}
   LOCAL cFilter := "p*.txt"

   cI_File := ""

   IF !get_export_path( @cPath )
      RETURN 0
   ENDIF

   IF get_file_list( cFilter, cPath, @cI_File ) = 0
      RETURN 0
   ENDIF

   bterm_txt_to_tbl( cI_File )

   aError := check_barkod_import()

   IF Len( aError ) > 0
      RETURN 0
   ENDIF

   RETURN 1


// -----------------------------------------------------
// Vraca podesenje putanje do exportovanih fajlova
// -----------------------------------------------------
STATIC FUNCTION get_export_path( PATH )

   LOCAL _path

#ifdef __PLATFORM__WINDOWS

   _path := "c:" + SLASH + "import" + SLASH
#else
   _path := SLASH + "home" + SLASH + my_user() + SLASH + "import" + SLASH
#endif

   _path := PadR( fetch_metric( "bterm_imp_exp_path", my_user(), AllTrim( _path ) ), 500 )

   Box(, 2, 70 )
   @ m_x + 1, m_y + 2 SAY "Import / export lokacija:"
   @ m_x + 2, m_y + 2 SAY "lokacija:" GET _path PICT "@S50"
   READ
   BoxC()

   IF LastKey() == K_ESC
      PATH := NIL
      RETURN .F.
   ENDIF

   PATH := AllTrim( _path )
   set_metric( "bterm_imp_exp_path", my_user(), PATH )

   RETURN .T.




// ---------------------------------------
// provjeri barkod
// ---------------------------------------
STATIC FUNCTION check_barkod_import()

   LOCAL aErr := {}
   LOCAL nScan
   LOCAL i
   LOCAL nCnt

   SELECT TEMP
   SET ORDER TO TAG "3"
   GO TOP

   DO WHILE !Eof() .AND. field->STATUS = 0

      cTmp := field->barkod

      nScan := AScan( aErr, {| xVal | xVal[ 1 ] == cTmp } )

      IF nScan = 0
         AAdd( aErr, { field->barkod, field->kolicina } )
      ENDIF

      SKIP
   ENDDO

   IF Len( aErr ) = 0
      RETURN aErr
   ENDIF

   start_print_editor()

   ?
   ?U "Lista nepostojećih artikala:"
   ? "--------------------------------------------------------------"
   nCnt := 0
   FOR i := 1 TO Len( aErr )
      ? PadL( AllTrim( Str( ++nCnt ) ), 3 ) + "."
      @ PRow(), PCol() + 1 SAY "barkod: " + aErr[ i, 1 ]
      @ PRow(), PCol() + 1 SAY "_________________________________"
   NEXT

   end_print_editor()

   RETURN aErr



// ------------------------------------------------
// generise txt fajl sa artiklima za terminal...
// ------------------------------------------------
FUNCTION export_BTerm_data()

   LOCAL aStruct := get_article_tbl_struct()
   LOCAL nTArea := Select()
   LOCAL cSeparator := ";"
   LOCAL aData := {}
   LOCAL lTrimData := .T.
   LOCAL lLastSeparator := .F.
   LOCAL cFileName := ""
   LOCAL cFilePath := ""
   LOCAL nScan
   LOCAL cBK
   LOCAL nCnt := 0

   // aData
   // [1] barkod
   // [2] naziv
   // [3] kolicina
   // [4] cijena

   IF !get_export_path( @cFilePath )
      RETURN 0
   ENDIF

   cre_tmp()

   o_r_export()
   INDEX ON barkod TAG "ID"

   o_roba()
   SET ORDER TO TAG "BARKOD"
   GO TOP

   DO WHILE !Eof()

      cBK := PadR( field->barkod, 20 )

      IF Empty( cBK )
         SKIP
         LOOP
      ENDIF

      SELECT r_export
      GO TOP
      SEEK cBK

      IF !Found()

         APPEND BLANK
         REPLACE field->barkod WITH roba->barkod
         REPLACE field->naz WITH roba->naz
         REPLACE field->tk WITH 0
         REPLACE field->tc WITH roba->vpc

         ++nCnt
      ENDIF

      SELECT roba
      SKIP
   ENDDO

   cFileName := "ARTIKLI.TXT"

   SELECT r_export
   USE

   _dbf_to_file( cFilePath, cFileName, aStruct, "r_export.dbf", cSeparator, lTrimData, lLastSeparator )

   MsgBeep( "Exportovao " + AllTrim( Str( nCnt ) ) + " zapisa robe !" )

   SELECT ( 249 )
   USE

   SELECT ( nTArea )

   RETURN 1



// ----------------------------------------
// artikli.txt struktura txt fajla
// ----------------------------------------
STATIC FUNCTION get_article_tbl_struct()

   LOCAL aRet := {}

   // BARKOD
   AAdd( aRet, { "C", 20, 0 } )
   // NAZIV
   AAdd( aRet, { "C", 40, 0 } )
   // TRENUTNA KOLICINA
   AAdd( aRet, { "N", 8, 2 } )
   // TRENUTNA CIJENA
   AAdd( aRet, { "N", 8, 2 } )

   RETURN aRet


// -------------------------------------------
// kreiraj pomocnu tabelu
// -------------------------------------------
STATIC FUNCTION cre_tmp()

   LOCAL aFields := {}

   AAdd( aFields, { "barkod", "C", 20, 0 } )
   AAdd( aFields, { "naz", "C", 40, 0 } )
   AAdd( aFields, { "tk", "N", 8, 2 } )
   AAdd( aFields, { "tc", "N", 8, 2 } )

   IF !create_dbf_r_export( aFields )
      RETURN .F.
   ENDIF

   RETURN .T.
