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

STATIC s_cF18UtilPath

STATIC s_cXmlFile
STATIC s_cOutOdtFile
STATIC s_cOutputPdf
STATIC __template
STATIC __template_filename
STATIC __jod_converter := "jodconverter-cli.jar"
STATIC s_cJodReportsJar := "jodreports-cli.jar"
STATIC cKnowhowUtilPath
STATIC __current_odt


/*
   Opis: generisanja odt dokumenta na osnovu XML fajla i ODT template-a putem jodreports

   Usage: generisi_odt_iz_xml( cTemplate, cXml_file, cOutOdtFile, lBezPitanja )

   Params:
       cTemplate - naziv tempate fajla (template ODT)
                 // fajl će se pretražiti u template lokaciji pa će se kopirati u home direktorij
       cXml_file - lokacija + naziv xml fajla
       cOutOdtFile - lokacija + naziv izlaznog ODT fajla koji će se generisati
       lBezPitanja - generiši odt report bez ikakvih pitanja da li želite

   Returns:
      .T. - ukoliko je operacija uspješna
      .F. - ukoliko je neuspješna
*/
FUNCTION generisi_odt_iz_xml( cTemplate, cXml_file, cOutOdtFile, lBezPitanja )

   LOCAL lRet := .F.
   LOCAL lOk := .F.
   LOCAL _template
   LOCAL cScreen
   LOCAL cCommand
   LOCAL nError
   LOCAL cUtilPath
   LOCAL cJodReportsFullPath
   LOCAL cErr := ""
   LOCAL cOdgovor := "D"
   LOCAL hJava

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
      s_cXmlFile := my_home() + DATA_XML_FILE
   ELSE
      s_cXmlFile := cXml_file
   ENDIF

   IF ( cOutOdtFile == NIL )
      s_cOutOdtFile := my_home() + naziv_izlaznog_odt_fajla()
   ELSE
      s_cOutOdtFile := cOutOdtFile
   ENDIF

   __current_odt := s_cOutOdtFile

   lOk := f18_template_copy_to_my_home( cTemplate )

   IF !lOk
      RETURN lOk
   ENDIF

   brisi_odt_fajlove_iz_home_path()

   ?E "ODT report gen: pobrisao fajl " + s_cOutOdtFile

   _template := my_home() + cTemplate

   cKnowhowUtilPath := get_knowhow_util_path()
   cJodReportsFullPath := cKnowhowUtilPath + s_cJodReportsJar

   IF !File( AllTrim( cJodReportsFullPath ) )
      log_write( "ODT report gen: " + s_cJodReportsJar + " ne postoji na lokaciji !", 7 )
      MsgBeep( "java jar: " + s_cJodReportsJar + " ne postoji !" )
      RETURN lRet
   ENDIF

/* run_invisible.vbs pretvara sve u shortpath
#ifdef __PLATFORM__WINDOWS
   _template := '"' + _template + '"'
   s_cXmlFile := '"' + s_cXmlFile + '"'
   s_cOutOdtFile := '"' + s_cOutOdtFile + '"'
   cJodReportsFullPath := '"' + cJodReportsFullPath + '"'
#endif
*/

   __template := _template
   __template_filename := cTemplate

   cCommand := java_cmd() + " -jar " + cJodReportsFullPath + " "
   cCommand += _template + " "
   cCommand += s_cXmlFile + " "
   cCommand += s_cOutOdtFile

   log_write( "JOD report gen, cmd: " + cCommand, 7 )

   SAVE SCREEN TO cScreen
   CLEAR SCREEN

   hJava := java_version()
   ? "GEN JOD/" + hJava[ "name" ] + "(" + hJava[ "version" ] + ") > " + + Right( __current_odt, 20 )

   nError := f18_run( cCommand )
   RESTORE SCREEN FROM cScreen

   IF nError <> 0

      log_write( "JOD report gen: greška - " + AllTrim( Str( nError ) ), 7 )
      cErr := "Došlo je do greške prilikom generisanja reporta ! #" + "Greška: " + AllTrim( Str( nError ) )

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

   IF Empty( cFajl )
      RETURN cNaziv
   ENDIF

   aTmp := TokToNiz( cFajl, SLASH )

   cNaziv := aTmp[ Len( aTmp ) ]
   cNaziv := StrTran( cNaziv, '"', '' )

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

   LOCAL nI
   LOCAL _tmp := "out.odt"

   FOR nI := 1 TO 1000
      _tmp := "out_" + PadL( AllTrim( Str( nI ) ), 4, "0" ) + ".odt"
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
      iif( ;
      File( _f_path + ".~lock." + AllTrim( aFile[ 1 ] ) + "#" ), ;
      .T., ;
      FErase( _f_path + AllTrim( aFile[ 1 ] ) ) ;
      ) ;
      } )

   Sleep( 1 )

   RETURN .T.



STATIC FUNCTION get_knowhow_util_path()

   LOCAL aFiles, cPath := ""

   IF is_windows()
      cPath := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
   ELSE
      cPath := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
   ENDIF

   IF s_cF18UtilPath != NIL
      RETURN s_cF18UtilPath
   ENDIF

   aFiles := hb_vfDirectory( cPath )

   IF Len( aFiles ) > 0
      s_cF18UtilPath := cPath
      info_bar( "f18_core", "util path: " + cPath )
      RETURN cPath
   ENDIF

   cPath :=  "." + SLASH + "util" + SLASH // ./util
   aFiles := hb_vfDirectory( cPath )
   IF Len( aFiles ) > 0
      s_cF18UtilPath := cPath
      info_bar( "f18_core", "util path: " + cPath )
      RETURN cPath
   ENDIF

   cPath := "." + SLASH // current dir ./
   aFiles := hb_vfDirectory()
   IF Len( aFiles ) > 0
      s_cF18UtilPath := cPath
      info_bar( "f18_core", "util path: " + cPath )
   ENDIF

   RETURN cPath




FUNCTION f18_odt_copy( cOutOdtFile, cDestination_file )

   LOCAL lOk := .F.

   IF ( cOutOdtFile == NIL )
      s_cOutOdtFile := __current_odt
   ELSE
      s_cOutOdtFile := cOutOdtFile
   ENDIF

   FileCopy( s_cOutOdtFile, cDestination_file )

   RETURN .T.



/*
   Opis: otvara i prikazuje ODT fajl

   Usage: pokreni_odt( cOutOdtFile )

   Params:
     cOutOdtFile - izlazni fajl za prikaz (path + filename)

   Napomene:
     Ukoliko nije zadat parametar cOutOdtFile, štampa se zadnji generisani ODT dokuement koji je smješten
     u statičku varijablu __current_odt
*/

FUNCTION prikazi_odt( cOutOdtFile )

   LOCAL lOk := .F.
   LOCAL cScreen, nError := 0
   LOCAL cOdgovor

   IF ( cOutOdtFile == NIL )
      s_cOutOdtFile := __current_odt
   ELSE
      s_cOutOdtFile := cOutOdtFile
   ENDIF

   IF !File( s_cOutOdtFile )
      MsgBeep( "Nema fajla" + s_cOutOdtFile + "za prikaz !" )
      RETURN lOk
   ENDIF


   SAVE SCREEN TO cScreen
   CLEAR SCREEN

   ? "Prikaz odt fajla u toku ... fajl: ..." + Right( __current_odt, 20 )

#ifndef TEST
   nError := LO_open_dokument( s_cOutOdtFile )
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

   cSubject := "Uzorak ODT izvještaja, F18 " + f18_ver()
   cSubject += ", " + my_server_params()[ "database" ] + "/" + AllTrim( f18_user() )
   cSubject += ", " + DToC( Date() ) + " " + PadR( Time(), 8 )

   cBody := ""

   IF cErrorTxt <> NIL .AND. !Empty( cErrorTxt )
      cBody += cErrorTxt + ". "
   ENDIF

   cBody += "U prilogu fajlovi neophodni za generisanje ODT izvještaja."

   cZipFile := odt_email_attachment( lIzlazniOdt )

   aAttachment := {}
   IF !Empty( cZipFile )
      AAdd( aAttachment, cZipFile )
   ENDIF

   DirChange( my_home() )

   hMailParams := email_hash_za_podrska_bring_out( cSubject, cBody )

   MsgO( "Slanje email-a u toku ..." )

   f18_email_send( hMailParams, aAttachment )

   FErase( my_home() + cZipFile )

   MsgC()

   RETURN .T.



STATIC FUNCTION odt_email_attachment( lIzlazniOdt )

   LOCAL aFiles := {}
   LOCAL cPath := my_home()
   LOCAL cServer := my_server_params()
   LOCAL cZipFile

   cZipFile := AllTrim( cServer[ "database" ] )
   cZipFile += "_" + AllTrim( f18_user() )
   cZipFile += "_" + DToS( Date() )
   cZipFile += "_" + StrTran( Time(), ":", "" )
   cZipFile += ".zip"

   DirChange( my_home() )

   AAdd( aFiles, samo_naziv_fajla( s_cXmlFile ) )
   AAdd( aFiles, __template_filename )

   IF lIzlazniOdt
      AAdd( aFiles, samo_naziv_fajla( __current_odt ) )
   ENDIF

   _err := zip_files( cPath, cZipFile, aFiles )

   RETURN cZipFile





/*
   Opis: konvertuje ODT fajl u PDF putem java aplikacije jod-convert

   Usage: konvertuj_odt_u_pdf( cInput_file, cOutOdtFile, lOwerwrite_file )

   Params:

     - cInput_file - ulazni ODT fajl (lokacija + naziv)
     - cOutOdtFile - izlazni PDF fajl (lokacija + naziv)
     - lOwerwrite_file - .T. - briši uvijek postojeći, .F. - daj novi broj PDF dokumenta inkrementalnim brojačem
*/

FUNCTION konvertuj_odt_u_pdf( cInput_file, cOutOdtFile, lOverwrite_file )

   LOCAL _ret := .F.
   LOCAL cJodReportsFullPath, cUtilPath
   LOCAL cCommand
   LOCAL cScreen, nError

   IF ( cInput_file == NIL )
      s_cOutOdtFile := __current_odt
   ELSE
      s_cOutOdtFile := cInput_file
   ENDIF

   IF ( cOutOdtFile == NIL )
      s_cOutputPdf := StrTran( __current_odt, ".odt", ".pdf" )
   ELSE
      s_cOutputPdf := cOutOdtFile
   ENDIF

   IF lOverwrite_file == NIL
      lOverwrite_file := .T.
   ENDIF

#ifdef __PLATFORM__WINDOWS
   s_cOutOdtFile := '"' + s_cOutOdtFile + '"'
   s_cOutputPdf := '"' + s_cOutputPdf + '"'
#endif

   _ret := naziv_izlaznog_pdf_fajla( @s_cOutputPdf, lOverwrite_file )

   IF !_ret
      RETURN _ret
   ENDIF

   cUtilPath := get_knowhow_util_path()
   cJodReportsFullPath := cUtilPath + __jod_converter

   IF !File( AllTrim( cJodReportsFullPath ) )
      log_write( "ODT report conv: " + __jod_converter + " ne postoji na lokaciji !", 7 )
      MsgBeep( "Aplikacija " + __jod_converter + " ne postoji !" )
      RETURN _ret
   ENDIF

   log_write( "ODT report convert start", 9 )

// #ifdef __PLATFORM__WINDOWS
// cJodReportsFullPath := '"' + cJodReportsFullPath + '"'
// #endif

   cCommand := java_cmd() + " -jar " + cJodReportsFullPath + " "
   cCommand += s_cOutOdtFile + " "
   cCommand += s_cOutputPdf

   log_write( "ODT report convert, cmd: " + cCommand, 7 )

   SAVE SCREEN TO cScreen
   CLEAR SCREEN

   ? "Konvertovanje ODT dokumenta u toku..."

   nError := f18_run( cCommand )

   RESTORE SCREEN FROM cScreen

   IF nError <> 0
      log_write( "ODT report convert: greška - " + AllTrim( Str( nError ) ), 7 )
      MsgBeep( "Došlo je do greške prilikom konvertovanja dokumenta !#" + "Greška: " + AllTrim( Str( nError ) ) )
      RETURN _ret
   ENDIF

   _ret := .T.

   RETURN _ret



STATIC FUNCTION naziv_izlaznog_pdf_fajla( cOut_file, lOverwrite )

   LOCAL _ret := .F.
   LOCAL nI, _ext, _tmp, _wo_ext

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

   FOR nI := 1 TO 99

      _tmp := _wo_ext + PadL( AllTrim( Str( nI ) ), 2, "0" ) + _ext

      IF !File( _tmp )
         cOut_file := _tmp
         EXIT
      ENDIF

   NEXT

   RETURN _ret
