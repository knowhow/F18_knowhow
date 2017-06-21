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
STATIC s_cTemplateName
STATIC s_cUrl
STATIC s_cSHA256sum



FUNCTION download_template_ld_obr_2002()

   s_cTemplateName := "ld_obr_2002.xlsx"
   s_cSHA256sum := "b7f74944d0f30e0e3eed82a67ffff0f9cef943a79dd2fdc788bc05f2a6aac228"

   RETURN download_template()


FUNCTION download_template_ld_obr_2001()

   s_cTemplateName := "ld_obr_2001.xlsx"
   s_cSHA256sum := "23721f993561d4aa178730a18bde38294b3c720733d64bb9c691e973f00165fc"  // v17

   RETURN download_template()


FUNCTION f18_exe_template_file_name( cTemplate )

   RETURN f18_exe_path() + "template" + SLASH + cTemplate


FUNCTION download_template( cTemplateName,  cSHA256sum )

   IF cTemplateName != NIL
      s_cTemplateName := cTemplateName
   ENDIF

   IF cSHA256sum != NIL
      s_cSHA256sum := cSHA256sum
   ENDIF

   s_cDirF18Template := f18_exe_path() + "template" + SLASH
   s_cUrl := TEMPLATE_URL_BASE + ;
      f18_template_ver() + "/" + s_cTemplateName

   IF DirChange( s_cDirF18Template ) != 0
      IF MakeDir( s_cDirF18Template ) != 0
         error_bar( "tpl", "Kreiranje dir: " + s_cDirF18Template + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

// #ifndef F18_DEBUG
   IF !File( s_cDirF18Template + s_cTemplateName ) .OR. ;
         ( sha256sum( s_cDirF18Template + s_cTemplateName ) != s_cSHA256sum )

      IF !Empty( download_file( s_cUrl, s_cDirF18Template + s_cTemplateName ) )
         info_bar( "tpl", "Download " + s_cDirF18Template + s_cTemplateName )
      ELSE
         error_bar( "tpl", "Error download:" + s_cDirF18Template + s_cTemplateName + "##" + s_cUrl )
         RETURN .F.
      ENDIF
   ENDIF

   IF sha256sum( s_cDirF18Template + s_cTemplateName ) != s_cSHA256sum
      MsgBeep( "ERROR sha256sum: " + s_cDirF18Template + s_cTemplateName + "##" + s_cSHA256sum )
      RETURN .F.
   ENDIF
// #endif

   RETURN .T.
