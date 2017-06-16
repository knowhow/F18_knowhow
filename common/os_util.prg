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

FUNCTION is_mac_osx()

#ifdef __PLATFORM__DARWIN
   RETURN .T.
#else

   RETURN .F.
#endif


PROCEDURE OutMsg( hFile, cMsg )

   IF hFile == 1
      OutStd( cMsg )
   ELSEIF hFile == 2
      OutErr( cMsg )
   ELSE
      FWrite( hFile, cMsg )
   ENDIF

   RETURN



// ------------------------------------
// vraca putanju exe fajlova
// ------------------------------------
FUNCTION GetExePath( cPath )

   LOCAL cRet := ""
   LOCAL i
   LOCAL nBr := 0
   LOCAL cTmp

   FOR i := 1 TO Len( cPath )

      cTmp := SubStr( cPath, i, 1 )

      IF cTmp == SLASH
         nBr += 1
      ENDIF

      cRet += cTmp

      IF nBr == 2
         EXIT
      ENDIF

   NEXT

   RETURN cRet


/* FilePath(cFile)
 *      Extract the full path name from a filename
 *  \return cFilePath
 */

FUNCTION My_FilePath( cFile )

   LOCAL nPos, cFilePath

   nPos := RAt( SLASH, cFile )
   IF ( nPos != 0 )
      cFilePath := SubStr( cFile, 1, nPos )
   ELSE
      cFilePath := ""
   ENDIF

   RETURN cFilePath

FUNCTION ExFileName( cFile )

   LOCAL nPos, cFileName

   IF ( nPos := RAt( SLASH, cFile ) ) != 0
      cFileName := SubStr( cFile, nPos + 1 )
   ELSE
      cFileName := cFile
   ENDIF

   RETURN cFileName

FUNCTION AddBS( cPath )

   IF Right( cPath, 1 ) <> SLASH
      cPath := cPath + SLASH
   ENDIF






/* file ChangeEXT(cImeF,cExt, cExtNew, fBezAdd)
 *    Promjeni ekstenziju
 *
 *  param:s cImeF   ime fajla
 *  param:s cExt    polazna extenzija (obavezno 3 slova)
 *  param:s cExtNew nova extenzija
 *  param:s fBezAdd ako je .t. onda ce fajlu koji nema cExt dodati cExtNew
 *
 * \code
 *
 * ChangeEXT("SUBAN", "DBF", "CDX", .t.)
 * suban     -> suban.CDX
 *
 * ChangeEXT("SUBAN", "DBF", "CDX", .f.)
 * SUBAN     -> SUBAN
 *
 *
 * ChangeEXT("SUBAN.DBF", "DBF", "CDX", .t.)
 * SUBAN.DBF  -> SUBAN.CDX
 *
 *
 */

FUNCTION ChangeEXT( cImeF, cExt, cExtNew, fBezAdd )

   LOCAL cTacka

   IF fBezAdd == NIL
      fBezAdd := .T.
   ENDIF

   IF Empty( cExtNew )
      cTacka := ""
   ELSE
      cTacka := "."
   ENDIF
   cImeF := ToUnix( cImeF )

   cImeF := Trim( StrTran( cImeF, "." + cEXT, cTacka + cExtNew ) )
   IF !Empty( cTacka ) .AND.  Right( cImeF, 4 ) <> cTacka + cExtNew
      cImeF := cImeF + cTacka + cExtNew
   ENDIF

   RETURN  cImeF


FUNCTION IsDirectory( cDir1 )

   LOCAL cDirTek
   LOCAL lExists

   cDir1 := ToUnix( cDir1 )

   cDirTek := DirName()

   IF DirChange( cDir1 ) <> 0
      lExists := .F.
   ELSE
      lExists := .T.
   ENDIF

   DirChange( cDirTek )

   RETURN lExists


/* BrisiSFajlove(cDir)
  *    Brisi fajlove starije od 45 dana
  *
  * \code
  *
  * npr:  cDir ->  c:\tops\prenos\
  *
  * brisi sve fajlove u direktoriju
  * starije od 45 dana
  *
  * \endcode
  */

FUNCTION BrisiSFajlove( cDir, nDana )

   LOCAL cFile

   IF nDana == nil
      nDana := D_STAROST_DANA
   ENDIF

   cDir := ToUnix( Trim( cdir ) )
   cFile := FileSeek( Trim( cDir ) + "*.*" )
   DO WHILE !Empty( cFile )
      IF Date() - FileDate() > nDana
         FileDelete( cdir + cfile )
      ENDIF
      cfile := FileSeek()
   ENDDO

   RETURN NIL

FUNCTION ToUnix( cFileName )
   RETURN cFileName


#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapifs.h"

HB_FUNC( FILEBASE )
{
   const char * szPath = hb_parc( 1 );
   if( szPath )
   {
      PHB_FNAME pFileName = hb_fsFNameSplit( szPath );
      hb_retc( pFileName->szName );
      hb_xfree( pFileName );
   }
   else
      hb_retc_null();
}

/* FileExt( <cFile> ) --> cFileExt
*/
HB_FUNC( FILEEXT )
{
   const char * szPath = hb_parc( 1 );
   if( szPath )
   {
      PHB_FNAME pFileName = hb_fsFNameSplit( szPath );
      if( pFileName->szExtension != NULL )
         hb_retc( pFileName->szExtension + 1 ); /* Skip the dot */
      else
         hb_retc_null();
      hb_xfree( pFileName );
   }
   else
      hb_retc_null();
}

#pragma ENDDUMP


#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapierr.h"
#include "hbapigt.h"
#include "hbapiitm.h"
#include "hbapifs.h"

/* TOFIX: The screen buffer handling is not right for all platforms (Windows)
          The output of the launched (MS-DOS?) app is not visible. */

HB_FUNC( __RUN_SYSTEM )
{
   const char * pszCommand = hb_parc( 1 );
   int iResult;

   if( pszCommand && hb_gtSuspend() == HB_SUCCESS )
   {
      char * pszFree = NULL;

      iResult = system( hb_osEncodeCP( pszCommand, &pszFree, NULL ) );

      hb_retni(iResult);

      if( pszFree )
         hb_xfree( pszFree );

      if( hb_gtResume() != HB_SUCCESS )
      {
         /* an error should be generated here !! Something like */
         /* hb_errRT_BASE_Ext1( EG_GTRESUME, 6002, NULL, HB_ERR_FUNCNAME, 0, EF_CANDEFAULT ); */
      }


   }
}

#pragma ENDDUMP



FUNCTION f18_run( cCommand, hOutput, lAlwaysOk, lAsync )

   LOCAL nRet
   LOCAL cStdOut := "", cStdErr := ""
   LOCAL cPrefixCmd
   LOCAL _msg

   IF lAlwaysOk == NIL
      lAlwaysOk := .F.
   ENDIF

   IF lAsync == NIL
      lAsync := .F. // najcesce zelimo da okinemo eksternu komandu i nastavimo rad
   ENDIF

   IF  lAsync .AND. ( is_linux() .OR. is_mac() )
      nRet := __run_system( cCommand + "&" )
   ELSE
      nRet := hb_processRun( cCommand, NIL, @cStdOut, @cStdErr, lAsync )
   ENDIF

   ?E cCommand, nRet, "stdout:", cStdOut, "stderr:", cStdErr

   IF nRet == 0
      info_bar( "run1", cCommand + " : " + cStdOut + " : " + cStdErr )
   ELSE
      error_bar( "run1", cCommand + cStdOut + " : " + cStdErr )

      cPrefixCmd := get_run_prefix_cmd( cCommand )

#ifdef __PLATFORM__LINUX
      IF lAsync
         nRet := __run_system( cPrefixCmd + cCommand + "&" )
      ELSE
         nRet := hb_processRun( cPrefixCmd + cCommand, NIL, @cStdOut, @cStdErr )
      ENDIF
#else
      nRet := hb_processRun( cPrefixCmd + cCommand, NIL, @cStdOut, @cStdErr, lAsync )
#endif
      ?E cCommand, nRet, "stdout:", cStdOut, "stderr:", cStdErr


      IF nRet == 0
         info_bar( "run2", cPrefixCmd + cCommand + " : " + cStdOut + " : " + cStdErr )
      ELSE
         error_bar( "run2", cPrefixCmd + cCommand + " : " + cStdOut + " : " + cStdErr )

         nRet := __run_system( cCommand )  // npr. copy komanda trazi system run a ne hbprocess run
         ?E cCommand, nRet, "stdout:", cStdOut, "stderr:", cStdErr
         IF nRet <> 0 .AND. !lAlwaysOk

            error_bar( "run3", cCommand + " : " + cStdOut + " : " + cStdErr )
            _msg := "ERR run cmd: "  + cCommand + " : " + cStdOut + " : " + cStdErr
            log_write( _msg, 2 )
         ELSE
            info_bar( "run3", cCommand + " : " + cStdOut + " : " + cStdErr )

         ENDIF

      ENDIF

   ENDIF

   IF ValType( hOutput ) == "H"
      hOutput[ "stdout" ] := cStdOut // hash matrica
      hOutput[ "stderr" ] := cStdErr
   ENDIF

   RETURN nRet


FUNCTION get_run_prefix_cmd( cCommand )

   LOCAL cPrefix

   IF is_windows()
      // cPrefix := "cmd /c "
      cPrefix := "start "
   ELSE
      IF is_mac()
         cPrefix := "open "
      ELSE
         cPrefix := "xdg-open "
      ENDIF
   ENDIF

   IF cCommand != NIL .AND. Left( cCommand, 4 ) == "java"
      cPrefix := "" // if java ..., ne treba start
   ENDIF

   IF cCommand != NIL .AND. Left( cCommand, 10 ) == "f18_editor"
      IF is_linux() .OR. is_mac()  // if f18_editor ..., samo windows sa prefix start
         cPrefix := ""
      ENDIF
   ENDIF

   RETURN cPrefix


/*
    run_cmd_with_prefix( "f18_editor test.txt" ) => "f18_editor.cmd test.txt"
*/
FUNCTION run_cmd_with_prefix( cCommand )

   LOCAL cCmdWithPrefix := get_run_prefix_cmd( cCommand ) + cCommand

   //IF is_windows()
   //     cCmdWithPrefix := StrTran( cCmdWithPrefix, "start f18_editor", "f18_editor.cmd" )
   //ENDIF

   RETURN cCmdWithPrefix


FUNCTION f18_open_document( cDocument )

   LOCAL cPrefixCmd
   LOCAL _msg

   cPrefixCmd := get_run_prefix_cmd()

#ifdef __PLATFORM__WINDOWS
   cDocument := '"' + cDocument + '"'
#endif

   RETURN f18_run( cPrefixCmd + cDocument, NIL, NIL, .T. )



FUNCTION open_folder( cFolder )

   LOCAL cCmd

   cFolder := file_path_quote( cFolder )

   RETURN f18_open_document( cFolder )



FUNCTION f18_open_mime_document( cDocument )

   LOCAL cCmd := "", nError, cPrefixCmd

   // IF Pitanje(, "Otvoriti " + AllTrim( cDocument ) + " ?", "D" ) == "N"
   // RETURN .F.
   // ENDIF
/*
#ifdef __PLATFORM__UNIX

#ifdef __PLATFORM__DARWIN
   cCmd += "open " + cDocument
#else
   cCmd += "xdg-open " + cDocument + " &"
#endif

#else __PLATFORM__WINDOWS

   cCmd += "cmd /c " + cDocument

#endif
*/


   cDocument := file_path_quote( cDocument )

   cPrefixCmd := get_run_prefix_cmd()
   cCmd += cPrefixCmd + cDocument + iif( is_windows(), "", "& ")

   nError := f18_run( cCmd )

   IF nError <> 0
      MsgBeep( "Problem sa otvaranjem dokumenta !#Greška: " + AllTrim( Str( nError ) ) )
      RETURN .F.
   ENDIF

   RETURN .T.
