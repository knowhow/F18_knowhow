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

STATIC s_cUtilName := "f18_editor"
STATIC s_cDirF18Util  // e.g. /home/hernad/F18/F18_util/f18_editor/
STATIC s_cProg // windows: f18_editor.cmd, darwin: f18_editor

#ifdef __PLATFORM__WINDOWS
STATIC s_cSHA256sum := "eeed90cba345e78863bbf106e10153e92dacb2598d71e762a14b48f65b027cf6"
#endif

#ifdef __PLATFORM__DARWIN
STATIC s_cSHA256sum := "d2d97c8800fde9ce85bf569d9f4df6b1e0530e37ab90ef3beb0003da32e42753"
#endif



FUNCTION f18_editor( cTxt )

   LOCAL cCmd

   check_prog_download()

   IF is_linux()
      cCmd := "f18_editor"
   ELSE
      cCmd := s_cDirF18Util + s_cUtilName + SLASH + s_cProg + " " + cTxt
   ENDIF

   IF ! File( s_cDirF18Util + s_cUtilName + SLASH + s_cProg )
      MsgBeep( "Error NO CMD: " + s_cDirF18Util + s_cUtilName + SLASH + s_cProg + "!? STOP" )
      RETURN ""
   ENDIF


   // DirChange( s_cDirF18Util + s_cUtilName )
   // f18_run( cCmd, @hOutput )

   RETURN f18_run( cCmd, NIL, NIL, .T. )



STATIC FUNCTION check_prog_download()

   LOCAL cPlatform
   LOCAL cUrl
   LOCAL cZip
   LOCAL cVersion := F18_UTIL_VER
   LOCAL cMySum
   LOCAL lDownload := .F.
   LOCAL cDownloadRazlog := "FILE"

   IF is_linux()
      RETURN .T.
   ENDIF

   IF s_cDirF18Util == NIL
      s_cDirF18Util := ExePath() + "F18_util" + SLASH
      s_cProg := s_cUtilName + iif( is_windows(), ".cmd", "" )
   ENDIF

   DO CASE
   CASE is_windows()
      cPlatform := "windows_386"
   CASE is_mac()
      cPlatform := "darwin_amd64"
   CASE is_linux()
      cPlatform := "linux_386"
   ENDCASE

   cUrl := F18_UTIL_URL_BASE
   cUrl += cVersion + "/" + s_cUtilName + "_" + cPlatform + ".zip"

   IF DirChange( s_cDirF18Util ) != 0
      IF MakeDir( s_cDirF18Util ) != 0
         MsgBeep( "Kreiranje dir: " + s_cDirF18Util + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

   lDownload :=  !File( s_cDirF18Util + s_cUtilName + SLASH + s_cProg )
   IF !lDownload
      cMySum := sha256sum( s_cDirF18Util + s_cUtilName + SLASH + s_cProg )
      IF ( cMySum !=  s_cSHA256sum )
         MsgBeep( "f18_edit sha256sum " + s_cDirF18Util + s_cUtilName + SLASH + s_cProg + "## local:" + cMySum + "## remote:" + s_cSHA256sum )
         lDownload := .T.
         cDownloadRazlog := "SUM"
      ENDIF
   ENDIF

   IF lDownload
      IF cDownloadRazlog == "SUM" .AND. Pitanje(, "Downloadovati " + s_cProg + " novu verzija?", "D" ) == "N"
         lDownload := .F.
      ENDIF

      IF lDownload
         cZip := download_file( cUrl, NIL )
         IF !Empty( cZip )
            unzip_files( cZip, "", s_cDirF18Util, {}, .T. )
         ELSE
            MsgBeep( "Error download " + s_cProg + "##" + cUrl )
         ENDIF
      ENDIF
   ENDIF

   IF lDownload .AND. sha256sum( s_cDirF18Util + s_cUtilName + SLASH + s_cProg ) != s_cSHA256sum
      MsgBeep( "ERROR sha256sum: " + s_cDirF18Util + s_cUtilName + SLASH + s_cProg  + "##" + s_cSHA256sum )
      RETURN .F.
   ENDIF

   RETURN .T.