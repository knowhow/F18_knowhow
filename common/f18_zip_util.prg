/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION zip_files( cOutputDir, cFileNameOutput, aFiles )

   LOCAL nError


   IF ( aFiles == NIL ) .OR. Len( aFiles ) == 0
      RETURN MsgBeep( "Nema fajlova za arhiviranje ?!" )
   ENDIF

   nError := __zip( cOutputDir, cFileNameOutput, aFiles )

   RETURN nError



FUNCTION unzip_files( cZipFileDir, cZipFileName, cExtractDir, aFiles, lOverwriteFiles )

   LOCAL nError

   nError := __unzip( cZipFileDir, cZipFileName, cExtractDir, aFiles, lOverwriteFiles )

   RETURN nError



STATIC FUNCTION __zip( cZipFileDir, cZipFileName, aFiles )

   LOCAL cZipFileHandle
   LOCAL _file
   LOCAL nError := 0
   LOCAL _cnt := 0
   LOCAL cZipFileFullName := cZipFileDir + cZipFileName
   LOCAL cFilePath, cFileExt, cFileName
   LOCAL _a_file, aFajlovi


   cZipFileHandle := hb_zipOpen( cZipFileFullName ) // otvori fajl

   IF !Empty( cZipFileHandle )

      Box(, 3, 65 )
      @ m_x + 1, m_y + 2 SAY cZipFileHandle
      @ m_x + 2, m_y + 2 SAY "Kompresujem fajl: " + PadL( AllTrim( cZipFileFullName ), 40 )

      FOR EACH _file IN aFiles
         IF !Empty( _file )

            hb_FNameSplit( _file, @cFilePath, @cFileName, @cFileExt ) // odvoji lokaciju fajlova i nazive

            aFajlovi := hb_DirScan( cFilePath, cFileName + cFileExt )

            FOR EACH _a_file IN aFajlovi
               IF ! ( cFilePath + _a_file[ 1 ] == cZipFileFullName )

                  ++ _cnt
                  @ m_x + 2, m_y + 2 SAY PadL( AllTrim( Str( _cnt ) ), 3 ) + ") ..." + PadR( AllTrim( _a_file[ 1 ] ), 40 )

                  //IF relative_path
                  //   nError := hb_zipStoreFile( cZipFileHandle, cFilePath + _a_file[ 1 ], cFilePath + _a_file[ 1 ], nil )
                  //ELSE
                     nError := hb_zipStoreFile( cZipFileHandle, _a_file[ 1 ], _a_file[ 1 ], nil )
                  //ENDIF

                  IF ( nError <> 0 )
                     __zip_error( nError, "operacija: kompresovanje fajla" )
                     // RETURN -99
                  ENDIF

               ENDIF
            NEXT

         ENDIF
      NEXT

      nError := hb_zipClose( cZipFileHandle, "" )

      BoxC()

   ENDIF

   IF ( nError <> 0 )
      __zip_error( nError, "operacija: zatvaranje zip fajla" )
   ENDIF

   RETURN nError



STATIC FUNCTION __zip_error( err, descr )

   LOCAL _add_msg := ""

   IF ( err <> 0 )

      IF descr == NIL
         descr := ""
      ENDIF

      IF !Empty( descr )
         _add_msg := "#" + descr
      ENDIF

      MsgBeep( "Greška pri kompresovanju ?!" + AllTrim( Str( err ) ) + _add_msg )
   ENDIF

   RETURN .F.



STATIC FUNCTION __unzip( cZipFileDir, cZipFileName, zf_destination, aFiles, lOverwriteFiles )

   LOCAL cZipFileHandle
   LOCAL _file
   LOCAL nError := 0
   LOCAL _cnt := 0
   LOCAL _extract := .T.
   LOCAL _scan
   LOCAL _file_in_zip
   LOCAL cZipFileFullName := cZipFileDir + cZipFileName
   LOCAL __file, __date, __time, __size

   // paterni fajlova za ekstrakt
   IF ( aFiles == NIL )
      aFiles := {}
   ENDIF

   IF ( zf_destination == NIL )
      zf_destination := ""
   ENDIF

   IF ( lOverwriteFiles == NIL )
      lOverwriteFiles := .T.
   ENDIF

   // otvori zip fajl
   cZipFileHandle := hb_unzipOpen( cZipFileFullName )

   IF !Empty( cZipFileHandle )

      Box(, 2, 65 )

      @ m_x + 1, m_y + 2 SAY "Dekompresujem fajl: ..." + PadL( AllTrim( cZipFileFullName ), 30 )

      IF !Empty( zf_destination )
         // skoci u direktorij za raspakivanje ...
         DirChange( zf_destination )
      ENDIF

      nError := hb_unzipFileFirst( cZipFileHandle )

      DO WHILE nError == 0

         hb_unzipFileInfo( cZipFileHandle, @__file, @__date, @__time, , , , @__size )

         IF ( __file == NIL ) .OR. Empty( __file )
            nError := hb_unzipFileNext( cZipFileHandle )
         ENDIF

         // da li imamo kakve paterne ?
         IF Len( aFiles ) > 0
            // daj info o zip fajlu...
            _scan := AScan( aFiles, {| pattern | hb_WildMatch( pattern, __file, .T. ) } )
            IF _scan == 0
               _extract := .F.
            ENDIF

         ENDIF

         // prvo provjeri postoji li fajl, ako je u overwrite modu
         IF lOverwriteFiles
            IF File( __file )
               FErase( __file )
            ENDIF
         ENDIF

         IF _extract

            ++ _cnt

            @ m_x + 2, m_y + 2 SAY PadL( AllTrim( Str( _cnt ) ), 3 ) + ") ... " + PadL( AllTrim( __file ), 38 )

            nError := hb_unzipExtractCurrentFile( cZipFileHandle, NIL, NIL )

            IF ( nError <> 0 )
               __zip_error( nError, "operacija: dekompresovanje fajla" )
               // RETURN -99
            ENDIF

         ENDIF

         // ovdje ne treba obrada error-a
         // zato sto je kraj arhive greska = -100
         nError := hb_unzipFileNext( cZipFileHandle )

      ENDDO

      nError := hb_unzipClose( cZipFileHandle, "" )

      BoxC()

   ENDIF

   IF ( nError <> 0 )
      __zip_error( nError, "operacija: zatvaranje zip fajla" )
   ENDIF

   RETURN nError
