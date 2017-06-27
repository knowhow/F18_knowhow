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
STATIC s_cSHA256sum := "2fe1a1b7a204ec6d282518a9e04acc4bfb6abb4b7bc84de1a65557e0168c56dc"  // LO/lo.cmd (007 verzija)
#endif

#ifdef __PLATFORM__LINUX
STATIC s_cSHA256sum := "3f1e4b90548791a7d787a6d63e224cdce74aaa92212c6ff818b66c1fe24eb24f" // LO/lo
#endif

STATIC s_cDownloadF18LO


FUNCTION LO_open_dokument( cFile )

   LOCAL lAsync := .F.
   LOCAL cCmd, lUseLibreofficeSystem := .F., lFirstRun := .F.
   LOCAL cOdgovor


   IF s_cDownloadF18LO == NIL
      s_cDownloadF18LO := fetch_metric( "F18_LO", NIL, "N" )
      lFirstRun := .T. // prvi put postavlja pitanje
   ENDIF


   IF is_mac()
      lUseLibreofficeSystem := .T.
   ELSE
      IF s_cDownloadF18LO == "0" // ne pitaj korisnika da li da ucitava F18 LO koristiti system LibreOffic3
         lUseLibreofficeSystem := .T.
      ELSEIF s_cDownloadF18LO == "N" // pitati korisnika
         IF lFirstRun
            cOdgovor := Pitanje( , "Instalirati F18 LibreOffice za pregled dokumenata (D/N/0) ?", "N", "DN0" )

            IF cOdgovor == "D"
               set_metric( "F18_LO", NIL, "D" )
               s_cDownloadF18LO := "D"
               lUseLibreofficeSystem := .F.
            ELSE
               IF cOdgovor == "0"
                  set_metric( "F18_LO", NIL, "0" ) // ne pitaj korisnika vise
                  s_cDownloadF18LO := "0"
               ENDIF
               lUseLibreofficeSystem := .T.
            ENDIF
         ELSE
            lUseLibreofficeSystem := .T.
         ENDIF
      ELSE // D - koristit F18 LO
         lUseLibreofficeSystem := .F.
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

FUNCTION LO_convert_xlsx_cmd()

   check_LO_download()

   RETURN s_cDirF18Util + s_cUtilName + SLASH + "lo_dbf_xlsx" + iif( is_windows(), ".cmd", "" )


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
