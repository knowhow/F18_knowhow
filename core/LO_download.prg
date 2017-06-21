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

STATIC s_cUtilName := "LO"
STATIC s_cDirF18Util  // e.g. /home/hernad/F18/F18_util/LO/
STATIC s_cProg // windows: lo.cmd, darwin: lo

#ifdef __PLATFORM__WINDOWS
STATIC s_cSHA256sum := "f5187c5e0b091bd11ee67a4209cb3075e92eb1881a788fa003a8cbe8891972ed"  // LO/lo.cmd (004 verzija - with SYSTEM/vcredist_x86.exe)
#endif

#ifdef __PLATFORM__LINUX
STATIC s_cSHA256sum := "a02233dba2c09f88a54107d7605b6e0888f2a9a68558af9a223230e600b02c8e" // LO/lo
#endif

STATIC s_cDownloadF18LO


FUNCTION LO_open_dokument( cFile )

   LOCAL lAsync := .F.
   LOCAL cCmd, nRet, lUseLibreofficeSystem := .F.
   LOCAL cOdgovor

   IF s_cDownloadF18LO == NIL
      s_cDownloadF18LO := fetch_metric( "F18_LO", NIL, "N" )
   ENDIF

   IF is_mac()
      lUseLibreofficeSystem := .T.
   ELSE
      IF s_cDownloadF18LO == "0" // ne pitaj korisnika da li da ucitava
         lUseLibreofficeSystem := .T.
      ELSEIF s_cDownloadF18LO == "N"
         cOdgovor := Pitanje( , "Instalirati F18 LibreOffice za pregled dokumenata ?", "N", "DN0" )
         IF cOdgovor == "D"
            set_metric( "F18_LO", NIL, "D" )
            lUseLibreofficeSystem := .F.
         ELSE
            IF cOdgovor == "0"
               set_metric( "F18_LO", NIL, "0" ) // ne pitaj korisnika vise
            ENDIF
            lUseLibreofficeSystem := .T.
         ENDIF
      ENDIF
   ENDIF

   IF lUseLibreofficeSystem
      RETURN f18_open_mime_document( cFile )
   ENDIF

   cCmd := LO_cmd()
   IF is_linux()
      lAsync := .T.
   ENDIF

   RETURN f18_run( cCmd, cFile, NIL, lAsync )



FUNCTION LO_cmd()

   check_LO_download()

   RETURN s_cDirF18Util + s_cUtilName + SLASH + s_cProg


FUNCTION check_LO_download()

   LOCAL cUrl
   LOCAL cZip
   LOCAL cVersion := F18_UTIL_VER
   LOCAL cMySum
   LOCAL lDownload := .F.
   LOCAL cDownloadRazlog := "FILE"
   LOCAL cLOCmd

   IF s_cDirF18Util == NIL
      s_cDirF18Util := f18_exe_path() + "F18_util" + SLASH
      s_cProg := "lo" + iif( is_windows(), ".cmd", "" )
   ENDIF

   cUrl := F18_UTIL_URL_BASE
   cUrl += cVersion + "/" + s_cUtilName + "_" + get_platform() + ".zip"

   IF DirChange( s_cDirF18Util ) != 0  // e.g. $HOME/F18/F18_util
      IF MakeDir( s_cDirF18Util ) != 0
         MsgBeep( "Kreiranje dir: " + s_cDirF18Util + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

   cLOCmd := s_cDirF18Util + s_cUtilName + SLASH + s_cProg
   lDownload :=  !File( cLOCmd )
   IF !lDownload
      cMySum := sha256sum( cLOCmd )
      IF ( cMySum !=  s_cSHA256sum )
         MsgBeep( s_cProg + " sha256sum " + cLOCmd + "## local:" + cMySum + "## remote:" + s_cSHA256sum )
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

   IF lDownload .AND. sha256sum( cLOCmd ) != s_cSHA256sum
      MsgBeep( "ERROR sha256sum: " + cLOCmd  + "##" + s_cSHA256sum )
      RETURN .F.
   ENDIF

   RETURN .T.
