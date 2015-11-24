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
STATIC __template_filename
STATIC __jod_converter := "jodconverter-cli.jar"
STATIC __jod_reports := "jodreports-cli.jar"
STATIC __java_run_cmd := "java -Xmx128m -jar"
STATIC __util_path
STATIC __current_odt


/*
   Opis: generisanja odt dokumenta na osnovu XML fajla i ODT template-a putem jodreports

   Usage: generisi_odt_iz_xml( cTemplate, cXml_file, cOutput_file, lBezPitanja )

   Params:
       cTemplate - naziv tempate fajla (template ODT)
                 // fajl će se pretražiti u template lokaciji pa će se kopirati u home direktorij
       cXml_file - lokacija + naziv xml fajla
       cOutput_file - lokacija + naziv izlaznog ODT fajla koji će se generisati
       lBezPitanja - generiši odt report bez ikakvih pitanja da li želite

   Returns:
      .T. - ukoliko je operacija uspješna
      .F. - ukoliko je neuspješna
*/
FUNCTION generisi_odt_iz_xml( cTemplate, cXml_file, cOutput_file, lBezPitanja )

   LOCAL lRet := .F.
   LOCAL _ok := .F.
   LOCAL _template
   LOCAL _screen
   LOCAL _cmd
   LOCAL _error
   LOCAL _util_path
   LOCAL _jod_full_path
   LOCAL cErr := ""
   LOCAL cOdgovor := "D"

   IF lBezPitanja == NIL
      lBezPitanja := .F.
   ENDIF

   IF !lBezPitanja
      cOdgovor := pitanje_prikazi_odt()
   ENDIF

   IF cOdgovor == "N"
      RETURN lRet
   ENDIF

   IF ( cXml_file == NIL )
      __xml_file := my_home() + DATA_XML_FILE
   ELSE
      __xml_file := cXml_file
   ENDIF

   IF ( cOutput_file == NIL )
      __output_odt := my_home() + naziv_izlaznog_odt_fajla()
   ELSE
      __output_odt := cOutput_file
   ENDIF

   __current_odt := __output_odt

   _ok := kopiraj_odt_template_u_home_path( cTemplate )

   IF !_ok
      RETURN _ok
   ENDIF

   brisi_odt_fajlove_iz_home_path()

   log_write( "ODT report gen: pobrisao fajl " + __output_odt, 7 )

   _template := my_home() + cTemplate

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
   __template_filename := cTemplate

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

   IF cOdgovor == "P"
      odt_na_email_podrska()
      RETURN lRet
   ENDIF

   lRet := .T.

   RETURN lRet



STATIC FUNCTION samo_naziv_fajla( cFajl )

   LOCAL cNaziv := ""
   LOCAL aTmp

   IF EMPTY( cFajl )
      RETURN cNaziv
   ENDIF

   aTmp := TokToNiz( cFajl, SLASH )

   cNaziv := aTmp[ LEN( aTmp ) ]
   cNaziv := STRTRAN( cNaziv, '"', '' )

   RETURN cNaziv



/*
   Opis: generiše naziv izlaznog ODT fajla po inkrementalnom brojaču
         koristi se radi poziva ODT štampe više puta

         Ispituje postojanje out fajla u home folderu, pa ako postoji generiše sljedeći redni broj

         out_0001.odt
         out_0002.odt
         itd...
*/

STATIC FUNCTION naziv_izlaznog_odt_fajla()

   LOCAL _i
   LOCAL _tmp := "out.odt"

   FOR _i := 1 TO 1000
      _tmp := "out_" + PadL( AllTrim( Str( _i ) ), 4, "0" ) + ".odt"
      IF !File( my_home() + _tmp )
         EXIT
      ENDIF
   NEXT

   RETURN _tmp




STATIC FUNCTION brisi_odt_fajlove_iz_home_path()

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




STATIC FUNCTION get_util_path()

   LOCAL _path := ""

   #ifdef __PLATFORM__WINDOWS
      _path := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
   #else
      _path := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
   #endif

   RETURN _path



/*
   Opis: kopira template sa lokacije /knowhowERP/templates => home path
*/

STATIC FUNCTION kopiraj_odt_template_u_home_path( cTemplate )

   LOCAL _ret := .F.
   LOCAL _a_source, _a_template
   LOCAL _src_size, _src_date, _src_time
   LOCAL _temp_size, _temp_date, _temp_time
   LOCAL _copy := .F.

   IF !File( my_home() + cTemplate )
      _copy := .T.
   ELSE

      _a_source := Directory( my_home() + cTemplate )
      _a_template := Directory( F18_TEMPLATE_LOCATION + cTemplate )

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
      IF File( F18_TEMPLATE_LOCATION + cTemplate )
         FileCopy( F18_TEMPLATE_LOCATION + cTemplate, my_home() + cTemplate )
      ELSE
         MsgBeep( "Fajl " + F18_TEMPLATE_LOCATION + cTemplate + " ne postoji !???" )
         RETURN _ret
      ENDIF
   ENDIF

   _ret := .T.

   RETURN _ret




FUNCTION f18_odt_copy( cOutput_file, cDestination_file )

   LOCAL _ok := .F.

   IF ( cOutput_file == NIL )
      __output_odt := __current_odt
   ELSE
      __output_odt := cOutput_file
   ENDIF

   FileCopy( __output_odt, cDestination_file )

   RETURN



/*
   Opis: otvara i prikazuje ODT fajl

   Usage: pokreni_odt( cOutput_file )

   Params:
     cOutput_file - izlazni fajl za prikaz (path + filename)

   Napomene:
     Ukoliko nije zadat parametar cOutput_file, štampa se zadnji generisani ODT dokuement koji je smješten
     u statičku varijablu __current_odt
*/

FUNCTION prikazi_odt( cOutput_file )

   LOCAL lOk := .F.
   LOCAL cScreen, nError := 0
   LOCAL cOdgovor

   IF ( cOutput_file == NIL )
      __output_odt := __current_odt
   ELSE
      __output_odt := cOutput_file
   ENDIF

   IF !File( __output_odt )
      MsgBeep( "Nema fajla za prikaz !" )
      RETURN lOk
   ENDIF

   #ifdef __PLATFORM__WINDOWS
      __output_odt := '"' + __output_odt + '"'
   #endif

   SAVE SCREEN TO cScreen
   CLEAR SCREEN

   ? "Prikaz odt fajla u toku ... fajl: ..." + Right( __current_odt, 20 )

   #ifndef TEST
       nError := f18_open_document( __output_odt )
   #endif

   RESTORE SCREEN FROM cScreen

   IF nError <> 0
      MsgBeep( "Problem sa pokretanjem odt dokumenta !#Greška: " + AllTrim( Str( nError ) ) )
      RETURN lOk
   ENDIF

   lOk := .T.

   RETURN lOk



STATIC FUNCTION pitanje_prikazi_odt()

   LOCAL cRet := "D"
   PRIVATE getList := {}

   SET CONFIRM OFF
   SET CURSOR ON

   Box(, 1, 50 )
   @ m_x + 1, m_y + 2 SAY8 "Prikazati Libre Office izvještaj (D/N/P) ?" GET cRet PICT "@!" VALID cRet $ "DNP"
   READ
   BoxC()

   SET CONFIRM ON

   IF LastKey() == K_ESC
      cRet := "N"
   ENDIF

   RETURN cRet


/*
   Opis: šalje odt fajlove prema bring.out podršci

   Usage: odt_na_email_podrska( error_text )

   Params:
     - error_text - ukoliko je prolijeđena poruka greške prikazuje se u tijelu emaila

   Returns:
     - email na f18@bring.out.ba
     - u attachmentu: template.odt
                      data.xml
*/

STATIC FUNCTION odt_na_email_podrska( cErrorTxt )

   LOCAL hMailParams, cBody, cSubject, aAttachment, cZipFile
   LOCAL lIzlazniOdt := .T.

   IF cErrorTxt <> NIL
      lIzlazniOdt := .F.
   ENDIF

   cSubject := "Uzorak ODT izvještaja, F18 " + F18_VER
   cSubject += ", " + my_server_params()["database"] + "/" + ALLTRIM( f18_user() )
   cSubject += ", " + DTOC( DATE() ) + " " + PADR( TIME(), 8 )

   cBody := ""

   IF cErrorTxt <> NIL .AND. !EMPTY( cErrorTxt )
      cBody += cErrorTxt + ". "
   ENDIF

   cBody += "U prilogu fajlovi neophodni za generisanje ODT izvještaja."

   cZipFile := odt_email_attachment( lIzlazniOdt )

   aAttachment := {}
   IF !EMPTY( cZipFile )
      AADD( aAttachment, cZipFile )
   ENDIF

   DirChange( my_home() )

   hMailParams := email_hash_za_podrska_bring_out( cSubject, cBody )

   MsgO( "Slanje email-a u toku ..." )

   f18_email_send( hMailParams, aAttachment )

   FErase( my_home() + cZipFile )

   MsgC()

   RETURN



STATIC FUNCTION odt_email_attachment( lIzlazniOdt )

   LOCAL aFiles := {}
   LOCAL cPath := my_home()
   LOCAL cServer := my_server_params()
   LOCAL cZipFile

   cZipFile := ALLTRIM( cServer["database"] )
   cZipFile += "_" + ALLTRIM( f18_user() )
   cZipFile += "_" + DTOS( DATE() )
   cZipFile += "_" + STRTRAN( TIME(), ":", "" )
   cZipFile += ".zip"

   DirChange( my_home() )

   AADD( aFiles, samo_naziv_fajla( __xml_file ) )
   AADD( aFiles, __template_filename )

   IF lIzlazniOdt
      AADD( aFiles, samo_naziv_fajla( __current_odt ) )
   ENDIF

   _err := zip_files( cPath, cZipFile, aFiles )

   RETURN cZipFile



FUNCTION f18_open_mime_document( cDocument )

   LOCAL _cmd := ""

   IF Pitanje(, "Otvoriti " + AllTrim( cDocument ) + " ?", "D" ) == "N"
      RETURN 0
   ENDIF

   #ifdef __PLATFORM__UNIX

      #ifdef __PLATFORM__DARWIN
         _cmd += "open " + cDocument
      #else
         _cmd += "xdg-open " + cDocument + " &"
      #endif

   #else __PLATFORM__WINDOWS

      cDocument := '"' + cDocument + '"'
      _cmd += "c:\knowhowERP\util\start.exe /m " + cDocument

   #endif

   _error := f18_run( _cmd )

   IF _error <> 0
      MsgBeep( "Problem sa otvaranjem dokumenta !#Greška: " + AllTrim( Str( _error ) ) )
      RETURN _error
   ENDIF

   RETURN 0



/*
   Opis: konvertuje ODT fajl u PDF putem java aplikacije jod-convert

   Usage: konvertuj_odt_u_pdf( cInput_file, cOutput_file, lOwerwrite_file )

   Params:

     - cInput_file - ulazni ODT fajl (lokacija + naziv)
     - cOutput_file - izlazni PDF fajl (lokacija + naziv)
     - lOwerwrite_file - .T. - briši uvijek postojeći, .F. - daj novi broj PDF dokumenta inkrementalnim brojačem
*/

FUNCTION konvertuj_odt_u_pdf( cInput_file, cOutput_file, lOverwrite_file )

   LOCAL _ret := .F.
   LOCAL _jod_full_path, _util_path
   LOCAL _cmd
   LOCAL _screen, _error

   IF ( cInput_file == NIL )
      __output_odt := __current_odt
   ELSE
      __output_odt := cInput_file
   ENDIF

   IF ( cOutput_file == NIL )
      __output_pdf := StrTran( __current_odt, ".odt", ".pdf" )
   ELSE
      __output_pdf := cOutput_file
   ENDIF

   IF lOverwrite_file == NIL
      lOverwrite_file := .T.
   ENDIF

   #ifdef __PLATFORM__WINDOWS
      __output_odt := '"' + __output_odt + '"'
      __output_pdf := '"' + __output_pdf + '"'
   #endif

   _ret := naziv_izlaznog_pdf_fajla( @__output_pdf, lOverwrite_file )

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
      MsgBeep( "Došlo je do greške prilikom konvertovanja dokumenta !#" + "Greška: " + AllTrim( Str( _error ) ) )
      RETURN _ret
   ENDIF

   _ret := .T.

   RETURN _ret



STATIC FUNCTION naziv_izlaznog_pdf_fajla( cOut_file, lOverwrite )

   LOCAL _ret := .F.
   LOCAL _i, _ext, _tmp, _wo_ext

   IF lOverwrite == NIL
      lOverwrite := .T.
   ENDIF

   IF lOverwrite
      FErase( cOut_file )
      _ret := .T.
      RETURN _ret
   ENDIF

   _ext := Right( AllTrim( cOut_file ), 4 )

   _wo_ext := Left( AllTrim( cOut_file ), Len( AllTrim( cOut_file ) ) - Len( _ext ) )

   FOR _i := 1 TO 99

      _tmp := _wo_ext + PadL( AllTrim( Str( _i ) ), 2, "0" ) + _ext

      IF !File( _tmp )
         cOut_file := _tmp
         EXIT
      ENDIF

   NEXT

   RETURN _ret
