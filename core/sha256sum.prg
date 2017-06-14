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

STATIC s_cDirF18Util
STATIC s_cProg


FUNCTION sha256sum( cFile )

   LOCAL cCmd
   LOCAL hOutput := hb_Hash()

   check_exe_download()
   cCmd := s_cDirF18Util + s_cProg + " " + cFile

   IF ! File(  s_cDirF18Util + s_cProg )
      MsgBeep( "Error NO EXEC: " + s_cDirF18Util + s_cProg + "!? STOP" )
      RETURN ""
   ENDIF

   f18_run( cCmd, @hOutput )

   RETURN hOutput[ "stdout" ]



STATIC FUNCTION check_exe_download()

   LOCAL cPlatform
   LOCAL cUrl
   LOCAL cZip
   LOCAL cVersion := "1.0.0"

   IF s_cDirF18Util == NIL
      s_cDirF18Util := ExePath() + "F18_util" + SLASH
      s_cProg := "F18_sha256sum" + iif( is_windows(), ".exe", "" )
   ENDIF

   DO CASE
   CASE is_windows()
      cPlatform := "windows_386"
   CASE is_mac()
      cPlatform := "darwin_amd64"
   CASE is_linux()
      cPlatform := "linux_386"
   ENDCASE

   cUrl := "https://github.com/hernad/F18_util/releases/download/"
   cUrl += cVersion + "/F18_sha256sum_" + cPlatform + ".zip"

   IF DirChange( s_cDirF18Util ) != 0
      IF ! MakeDir( s_cDirF18Util )
         MsgBeep( "Kreiranje dir: " + s_cDirF18Util + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

   IF !File( s_cDirF18Util + s_cProg )
      cZip := download_file( cUrl, NIL )
      IF !Empty( cZip )
         unzip_files( cZip, "", s_cDirF18Util, { s_cProg }, .T. )
      ELSE
         MsgBeep( "Error download " + s_cProg )
      ENDIF
   ENDIF

   RETURN .T.
