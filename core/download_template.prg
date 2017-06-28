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

#define TEMPLATE_URL_BASE "https://github.com/hernad/F18_template/releases/download/"

STATIC s_cDirF18Template
STATIC s_cUrl
STATIC s_hTemplates




FUNCTION download_template_ld_obr_2002()

   RETURN download_template( "ld_obr_2002.xlsx", "b7f74944d0f30e0e3eed82a67ffff0f9cef943a79dd2fdc788bc05f2a6aac228" )


FUNCTION download_template_ld_obr_2001() // v17

   download_template( "ld_obr_2001-A.xlsx", "62f994cded4cd1e5325ee5dca99a67b58f500157b45c268c790ea445c634a4e1" )

   RETURN download_template( "ld_obr_2001.xlsx", "e4a0e83befd7c7ae477feeaf382986044f62e4ae31dbb722087d392c10494f38" )


FUNCTION f18_exe_template_file_name( cTemplate )

   RETURN f18_exe_path() + "template" + SLASH + cTemplate


FUNCTION download_template( cTemplateName,  cSHA256sum )

   IF s_hTemplates == NIL
      s_hTemplates := hb_Hash()
   ENDIF

   IF hb_HHasKey( s_hTemplates, cTemplateName )
      RETURN .T. // template je vec ucitan
   ENDIF

   s_cDirF18Template := f18_exe_path() + "template" + SLASH
   s_cUrl := TEMPLATE_URL_BASE + f18_template_ver() + "/" + cTemplateName

   IF DirChange( s_cDirF18Template ) != 0
      IF MakeDir( s_cDirF18Template ) != 0
         error_bar( "tpl", "Kreiranje dir: " + s_cDirF18Template + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

// #ifndef F18_DEBUG
   IF !File( s_cDirF18Template + cTemplateName ) .OR. ;
         ( sha256sum( s_cDirF18Template + cTemplateName ) != cSHA256sum )

      IF !Empty( download_file( s_cUrl, s_cDirF18Template + cTemplateName ) )
         info_bar( "tpl", "Download " + s_cDirF18Template + cTemplateName )
      ELSE
         error_bar( "tpl", "Error download:" + s_cDirF18Template + cTemplateName + "##" + s_cUrl )
         RETURN .F.
      ENDIF
   ENDIF

   IF sha256sum( s_cDirF18Template + cTemplateName ) != cSHA256sum
      MsgBeep( "ERROR sha256sum: " + s_cDirF18Template + cTemplateName + "##" + cSHA256sum )
      RETURN .F.
   ENDIF
// #endif

   s_hTemplates[ cTemplateName ] := .T.

   RETURN .T.
