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



FUNCTION zip_files( output_path, output_file_name, files, relative_path )

   LOCAL _error

   IF ( relative_path == NIL )
      relative_path := .F.
   ENDIF

   IF ( files == NIL ) .OR. Len( files ) == 0
      RETURN MsgBeep( "Nema fajlova za arhiviranje ?!???" )
   ENDIF

   _error := __zip( output_path, output_file_name, files, relative_path )

   RETURN _error



FUNCTION unzip_files( zip_path, zip_file_name, extract_destination, files, overwrite_file )

   LOCAL _error

   _error := __unzip( zip_path, zip_file_name, extract_destination, files, overwrite_file )

   RETURN _error



STATIC FUNCTION __zip( zf_path, zf_name, files, relative_path )

   LOCAL _h_zip
   LOCAL _file
   LOCAL _error := 0
   LOCAL _cnt := 0
   LOCAL _zip_file := zf_path + zf_name
   LOCAL __file_path, __file_ext, __file_name
   LOCAL _a_file, _a_dir

   // otvori fajl
   _h_zip := hb_zipOpen( _zip_file )

   IF !Empty( _h_zip )

      Box(, 2, 65 )

      @ m_x + 1, m_y + 2 SAY "Kompresujem fajl: ..." + PadL( AllTrim( _zip_file ), 40 )

      FOR EACH _file IN files
         IF !Empty( _file )

            // odvoji mi lokaciju fajlova i nazive
            hb_FNameSplit( _file, @__file_path, @__file_name, @__file_ext )

            _a_dir := hb_DirScan( __file_path, __file_name + __file_ext )

            FOR EACH _a_file IN _a_dir
               IF ! ( __file_path + _a_file[ 1 ] == _zip_file )

                  ++ _cnt

                  @ m_x + 2, m_y + 2 SAY PadL( AllTrim( Str( _cnt ) ), 3 ) + ") ..." + PadR( AllTrim( _a_file[ 1 ] ), 40 )

                  IF relative_path
                     _error := hb_zipStoreFile( _h_zip, __file_path + _a_file[ 1 ], __file_path + _a_file[ 1 ], nil )
                  ELSE
                     _error := hb_zipStoreFile( _h_zip, _a_file[ 1 ], _a_file[ 1 ], nil )
                  ENDIF

                  IF ( _error <> 0 )
                     __zip_error( _error, "operacija: kompresovanje fajla" )
                     // RETURN -99
                  ENDIF

               ENDIF
            NEXT

         ENDIF
      NEXT

      _error := hb_zipClose( _h_zip, "" )

      BoxC()

   ENDIF

   IF ( _error <> 0 )
      __zip_error( _error, "operacija: zatvaranje zip fajla" )
   ENDIF

   RETURN _error


// -----------------------------------
// obrada gresaka
// -----------------------------------
STATIC FUNCTION __zip_error( err, descr )

   LOCAL _add_msg := ""

   IF ( err <> 0 )

      IF descr == NIL
         descr := ""
      ENDIF

      IF !Empty( descr )
         _add_msg := "#" + descr
      ENDIF

      MsgBeep( "Imamo gresku ?!???" + AllTrim( Str( err ) ) + _add_msg )
   ENDIF

   RETURN



STATIC FUNCTION __unzip( zf_path, zf_name, zf_destination, files, overwrite_file )

   LOCAL _h_zip
   LOCAL _file
   LOCAL _error := 0
   LOCAL _cnt := 0
   LOCAL _extract := .T.
   LOCAL _scan
   LOCAL _file_in_zip
   LOCAL _zip_file := zf_path + zf_name
   LOCAL __file, __date, __time, __size

   // paterni fajlova za ekstrakt
   IF ( files == NIL )
      files := {}
   ENDIF

   IF ( zf_destination == NIL )
      zf_destination := ""
   ENDIF

   IF ( overwrite_file == NIL )
      overwrite_file := .T.
   ENDIF

   // otvori zip fajl
   _h_zip := hb_unzipOpen( _zip_file )

   IF !Empty( _h_zip )

      Box(, 2, 65 )

      @ m_x + 1, m_y + 2 SAY "Dekompresujem fajl: ..." + PadL( AllTrim( _zip_file ), 30 )

      IF !Empty( zf_destination )
         // skoci u direktorij za raspakivanje ...
         DirChange( zf_destination )
      ENDIF

      _error := hb_unzipFileFirst( _h_zip )

      DO WHILE _error == 0

         hb_unzipFileInfo( _h_zip, @__file, @__date, @__time, , , , @__size )

         IF ( __file == NIL ) .OR. Empty( __file )
            _error := hb_unzipFileNext( _h_zip )
         ENDIF

         // da li imamo kakve paterne ?
         IF Len( files ) > 0
            // daj info o zip fajlu...
            _scan := AScan( files, {| pattern | hb_WildMatch( pattern, __file, .T. ) } )
            IF _scan == 0
               _extract := .F.
            ENDIF

         ENDIF

         // prvo provjeri postoji li fajl, ako je u overwrite modu
         IF overwrite_file
            IF File( __file )
               FErase( __file )
            ENDIF
         ENDIF

         IF _extract

            ++ _cnt

            @ m_x + 2, m_y + 2 SAY PadL( AllTrim( Str( _cnt ) ), 3 ) + ") ... " + PadL( AllTrim( __file ), 38 )

            _error := hb_unzipExtractCurrentFile( _h_zip, NIL, NIL )

            IF ( _error <> 0 )
               __zip_error( _error, "operacija: dekompresovanje fajla" )
               // RETURN -99
            ENDIF

         ENDIF

         // ovdje ne treba obrada error-a
         // zato sto je kraj arhive greska = -100
         _error := hb_unzipFileNext( _h_zip )

      ENDDO

      _error := hb_unzipClose( _h_zip, "" )

      BoxC()

   ENDIF

   IF ( _error <> 0 )
      __zip_error( _error, "operacija: zatvaranje zip fajla" )
   ENDIF

   RETURN _error
