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

#include "fmk.ch"
#include "fileio.ch"
#include "f18_ver.ch"

STATIC __xml_file
STATIC __output_odt
STATIC __output_pdf
STATIC __template
STATIC __jod_converter := "jodconverter-cli.jar"
STATIC __jod_reports := "jodreports-cli.jar"
STATIC __java_run_cmd := "java -Xmx128m -jar"
STATIC __util_path
STATIC __current_odt

// -------------------------------------------------------------------
// generisanje odt reporta putem jodreports
//
// - template - naziv template fajla (npr. f_01.odt)
// - xml_file - putanja + naziv fajla (npr. c:/data.xml)
// - output_file - putanja + naziv fajla (npr. c:/out.odt)
// - test_mode - testiranje opcije, samo za windows
//
// -------------------------------------------------------------------
FUNCTION f18_odt_generate( template, xml_file, output_file, test_mode )

   LOCAL lRet := .F.
   LOCAL _ok := .F.
   LOCAL _template
   LOCAL _screen
   LOCAL _cmd
   LOCAL _error
   LOCAL _util_path
   LOCAL _jod_full_path
   LOCAL cErr := ""

   IF ( xml_file == NIL )
      __xml_file := my_home() + DATA_XML_FILE
   ELSE
      __xml_file := xml_file
   ENDIF

   IF ( output_file == NIL )
      __output_odt := my_home() + gen_random_odt_name()
   ELSE
      __output_odt := output_file
   ENDIF

   __current_odt := __output_odt

   IF ( test_mode == NIL )
      test_mode := .F.
   ENDIF

   _ok := _copy_odt_template( template )

   IF !_ok
      RETURN _ok
   ENDIF

   delete_odt_files()

   log_write( "ODT report gen: pobrisao fajl " + __output_odt, 7 )

   _template := my_home() + template

   __util_path := get_util_path()
   _jod_full_path := __util_path + __jod_reports

   IF !File( AllTrim( _jod_full_path ) )
      log_write( "ODT report gen: " + __jod_reports + " ne postoji na lokaciji !", 7 )
      MsgBeep( "Aplikacija " + __jod_reports + " ne postoji !" )
      RETURN lRet
   ENDIF

#ifdef __PLATFORM__WINDOWS
   _template := '"' + _template + '"'
   __xml_file := '"' + __xml_file + '"'
   __output_odt := '"' + __output_odt + '"'
   _jod_full_path := '"' + _jod_full_path + '"'
#endif

   __template := _template

   _cmd := __java_run_cmd + " " + _jod_full_path + " "
   _cmd += _template + " "
   _cmd += __xml_file + " "
   _cmd += __output_odt

   log_write( "ODT report gen, cmd: " + _cmd, 7 )

   SAVE SCREEN TO _screen
   CLEAR SCREEN

   ? "Generisanje ODT reporta u toku ...  fajl: ..." + Right( __current_odt, 20 )

   _error := f18_run( _cmd, NIL, NIL, .F. )
   RESTORE SCREEN FROM _screen

   IF _error <> 0

      log_write( "ODT report gen: greška - " + AllTrim( Str( _error ) ), 7 )

      cErr := "Došlo je do greške prilikom generisanja reporta ! #" + "Greška: " + AllTrim( Str( _error ) )

      MsgBeep( cErr )

      IF fetch_metric( "bug_report_email", my_user(), "A" ) $ "D#A"
         odt_na_email_podrska( cErr )
      ENDIF

      RETURN lRet

   ENDIF

   lRet := .T.

   RETURN lRet



// ---------------------------------------------------------
// generise random odt out file name
// ---------------------------------------------------------
STATIC FUNCTION gen_random_odt_name()

   LOCAL _i
   LOCAL _tmp := "out.odt"

   FOR _i := 1 TO 1000
      _tmp := "out_" + PadL( AllTrim( Str( _i ) ), 4, "0" ) + ".odt"
      IF !File( my_home() + _tmp )
         EXIT
      ENDIF
   NEXT

   RETURN _tmp




// -----------------------------------------------------------------
// brise odt fajlove
// -----------------------------------------------------------------
STATIC FUNCTION delete_odt_files()

   LOCAL _tmp
   LOCAL _f_path

   _f_path := my_home()
   _tmp := "out_*.odt"

   // lock fajl izgleda ovako
   // .~lock.out_0001.odt#

   AEval( Directory( _f_path + _tmp ), {| aFile | ;
      if( ;
      File( _f_path + ".~lock." + AllTrim( aFile[ 1 ] ) + "#" ), ;
      .T., ;
      FErase( _f_path + AllTrim( aFile[ 1 ] ) ) ;
      ) ;
      } )

   Sleep( 1 )

   RETURN




// ------------------------------------------------------------------
// vraca util path po operativnom sistemu
// ------------------------------------------------------------------
STATIC FUNCTION get_util_path()

   LOCAL _path := ""

#ifdef __PLATFORM__WINDOWS

   _path := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
   _path := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

   RETURN _path



// -----------------------------------------------------------------
// kopiranje odt template fajla
// -----------------------------------------------------------------
STATIC FUNCTION _copy_odt_template( template )

   LOCAL _ret := .F.
   LOCAL _a_source, _a_template
   LOCAL _src_size, _src_date, _src_time
   LOCAL _temp_size, _temp_date, _temp_time
   LOCAL _copy := .F.

   IF !File( my_home() + template )
      _copy := .T.
   ELSE
	
      _a_source := Directory( my_home() + template )
      _a_template := Directory( F18_TEMPLATE_LOCATION + template )

      _src_size := AllTrim( Str( _a_source[ 1, 2 ] ) )
      _src_date := DToS( _a_source[ 1, 3 ] )
      _src_time := _a_source[ 1, 4 ]

      _temp_size := AllTrim( Str( _a_template[ 1, 2 ] ) )
      _temp_date := DToS( _a_template[ 1, 3 ] )
      _temp_time := _a_template[ 1, 4 ]

      IF _temp_date + _temp_time > _src_date + _src_time
         _copy := .T.
      ENDIF

   ENDIF

   IF _copy
      IF File( F18_TEMPLATE_LOCATION + template )
         FileCopy( F18_TEMPLATE_LOCATION + template, my_home() + template )
      ELSE
         MsgBeep( "Fajl " + F18_TEMPLATE_LOCATION + template + " ne postoji !???" )
         RETURN _ret
      ENDIF
   ENDIF

   _ret := .T.

   RETURN _ret


// ------------------------------------------------------------
// kopiraj fajl na lokaciju
// ------------------------------------------------------------
FUNCTION f18_odt_copy( output_file, destination_file )

   LOCAL _ok := .F.

   IF ( output_file == NIL )
      __output_odt := __current_odt
   ELSE
      __output_odt := output_file
   ENDIF

   FileCopy( __output_odt, destination_file )

   RETURN




// -------------------------------------------------------------------
// stampanje odt fajla
//
// - output_file - naziv fajla za prikaz (npr. c:/out.odt)
// - from_params - .t. ili .f. pokreni odt report na osnovu parametara
// - test_mode - .t. ili .f., testiranje komande - samo windows
// -------------------------------------------------------------------
FUNCTION f18_odt_print( output_file, from_params, test_mode )

   LOCAL _ok := .F.
   LOCAL _screen, _error := 0

   IF ( output_file == NIL )
      __output_odt := __current_odt
   ELSE
      __output_odt := output_file
   ENDIF

   IF ( from_params == NIL )
      from_params := .F.
   ENDIF

   IF ( test_mode == NIL )
      test_mode := .F.
   ENDIF

   IF !File( __output_odt )
      MsgBeep( "Nema fajla za prikaz !!!!" )
      RETURN _ok
   ENDIF

#ifdef __PLATFORM__WINDOWS
   __output_odt := '"' + __output_odt + '"'
#endif

   SAVE SCREEN TO _screen
   CLEAR SCREEN

   ? "Prikaz odt fajla u toku ...   fajl: ..." + Right( __current_odt, 20 )

#ifndef TEST
   _error := f18_open_document( __output_odt )
#endif

   RESTORE SCREEN FROM _screen

   IF _error <> 0
      MsgBeep( "Problem sa pokretanjem odt reporta !!!!#Greska: " + AllTrim( Str( _error ) ) )
      RETURN _error
   ENDIF

   _ok := .T.

   RETURN _ok



/*
   Opis: šalje odt fajlove prema bring.out podršci

   Usage: odt_na_email_podrska( error_text )

   Params:
     - error_text - ukoliko je prolijeđena poruka greške prikazuje se u tijelu emaila

   Returns:
     - email na f18@bring.out.ba
     - u attachmentu: template.odt
                      data.xml
                      izlazni_fajl.odt
*/

STATIC FUNCTION odt_na_email_podrska( error_text )

   LOCAL _mail_params, _body, _subject, _attachment

   _subject := "Uzorak ODT izvještaja, F18 " + F18_VER
   _subject += ", " + my_server_params()["database"] + "/" + ALLTRIM( f18_user() ) 
   _subject += ", " + DTOC( DATE() ) + " " + PADR( TIME(), 8 ) 

   _body := ""

   IF error_text <> NIL 
      _body += error_text + ". "
   ENDIF

   _body += "U prilogu fajlovi neophodni za generisanje ODT izvještaja."

   _attachment := {}
   AADD( _attachment, __output_odt )
   AADD( _attachment, __template )
   AADD( _attachment, __xml_file )

   _mail_params := email_hash_za_podrska_bring_out( _subject, _body )

   MsgO( "Slanje email-a u toku ..." )
  
   f18_email_send( _mail_params, _attachment )

   MsgC()

   RETURN



// ------------------------------------------------------
// otvaranje dokumenta na osnovu ekstenzije
// ------------------------------------------------------
FUNCTION f18_open_mime_document( document )

   LOCAL _cmd := ""

   IF Pitanje(, "Otvoriti " + AllTrim( document ) + " ?", "D" ) == "N"
      RETURN 0
   ENDIF

#ifdef __PLATFORM__UNIX

#ifdef __PLATFORM__DARWIN
   _cmd += "open " + document
#else
   _cmd += "xdg-open " + document + " &"
#endif

#else __PLATFORM__WINDOWS

   document := '"' + document + '"'
   _cmd += "c:\knowhowERP\util\start.exe /m " + document

#endif

   _error := f18_run( _cmd )

   IF _error <> 0
      MsgBeep( "Problem sa otvaranjem dokumenta !!!!#Greska: " + AllTrim( Str( _error ) ) )
      RETURN _error
   ENDIF

   RETURN 0



// ------------------------------------------------------------------
// konvertovanje odt fajla u pdf
//
// koristi se jodreports util: jodconverter-cli.jar
// java -jar jodconverter-cli.jar input_file_odt output_file_pdf
// ------------------------------------------------------------------
FUNCTION f18_convert_odt_to_pdf( input_file, output_file, overwrite_file )

   LOCAL _ret := .F.
   LOCAL _jod_full_path, _util_path
   LOCAL _cmd
   LOCAL _screen, _error

   IF ( input_file == NIL )
      __output_odt := __current_odt
   ELSE
      __output_odt := input_file
   ENDIF

   IF ( output_file == NIL )
      __output_pdf := StrTran( __current_odt, ".odt", ".pdf" )
   ELSE
      __output_pdf := output_file
   ENDIF

   IF ( overwrite_file == NIL )
      overwrite_file := .T.
   ENDIF

#ifdef __PLATFORM__WINDOWS
   __output_odt := '"' + __output_odt + '"'
   __output_pdf := '"' + __output_pdf + '"'
#endif

   _ret := _check_out_pdf( @__output_pdf, overwrite_file )
   IF !_ret
      RETURN _ret
   ENDIF

   _util_path := get_util_path()
   _jod_full_path := _util_path + __jod_converter

   IF !File( AllTrim( _jod_full_path ) )
      log_write( "ODT report conv: " + __jod_converter + " ne postoji na lokaciji !", 7 )
      MsgBeep( "Aplikacija " + __jod_converter + " ne postoji !" )
      RETURN _ret
   ENDIF

   log_write( "ODT report convert start", 9 )

#ifdef __PLATFORM__WINDOWS
   _jod_full_path := '"' + _jod_full_path + '"'
#endif

   _cmd := __java_run_cmd + " " + _jod_full_path + " "
   _cmd += __output_odt + " "
   _cmd += __output_pdf

   log_write( "ODT report convert, cmd: " + _cmd, 7 )

   SAVE SCREEN TO _screen
   CLEAR SCREEN

   ? "Konvertovanje ODT dokumenta u toku..."

   _error := f18_run( _cmd )

   RESTORE SCREEN FROM _screen

   IF _error <> 0
      log_write( "ODT report convert: greška - " + AllTrim( Str( _error ) ), 7 )
      MsgBeep( "Doslo je do greske prilikom konvertovanja dokumenta... !!!#" + "Greska: " + AllTrim( Str( _error ) ) )
      RETURN _ret
   ENDIF

   _ret := .T.

   RETURN _ret



// ----------------------------------------------------------------
// provjera izlaznog fajla
// ----------------------------------------------------------------
STATIC FUNCTION _check_out_pdf( out_file, overwrite )

   LOCAL _ret := .F.
   LOCAL _i, _ext, _tmp, _wo_ext

   IF ( overwrite == NIL )
      overwrite := .T.
   ENDIF

   IF overwrite
      FErase( out_file )
      _ret := .T.
      RETURN _ret
   ENDIF

   _ext := Right( AllTrim( out_file ), 4 )

   _wo_ext := Left( AllTrim( out_file ), Len( AllTrim( out_file ) ) - Len( _ext ) )

   FOR _i := 1 TO 99
	
      _tmp := _wo_ext + PadL( AllTrim( Str( _i ) ), 2, "0" ) + _ext

      IF !File( _tmp )
         out_file := _tmp

         EXIT

      ENDIF

   NEXT

   RETURN _ret
