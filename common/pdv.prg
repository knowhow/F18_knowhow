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

#include "fmk.ch"
#include "cre_all.ch"

FUNCTION IsPdvObveznik( cIdPartner )

   LOCAL cIdBroj

   cIdBroj := IzSifKPartn( "REGB", cIdPartner, .F. )

   IF !Empty( cIdBroj )
      IF Len( AllTrim( cIdBroj ) ) == 12

         RETURN .T.
      ELSE
         RETURN .F.
      ENDIF
   ELSE
      RETURN .F.
   ENDIF


