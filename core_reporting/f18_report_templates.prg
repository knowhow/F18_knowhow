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

STATIC  s_cTemplatesLoc

FUNCTION f18_template_location()

   LOCAL cLoc, aFileList
#ifdef __PLATFORM__WINDOWS

   cLoc := "c:" + SLASH + "knowhowERP" + SLASH + "template" + SLASH
#else
   cLoc := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "template" + SLASH
#endif

   IF s_cTemplatesLoc != NIL
      RETURN s_cTemplatesLoc
   ENDIF

   aFileList := hb_vfDirectory( cLoc )
   IF Len( aFileList ) > 1
      s_cTemplatesLoc := cLoc
      RETURN cLoc
   ENDIF

   cLoc := my_home_root() + "template" +  SLASH
   aFileList := hb_vfDirectory( cLoc )
   IF Len( aFileList ) > 1
      s_cTemplatesLoc := cLoc
      RETURN cLoc
   ENDIF

   RETURN ""
