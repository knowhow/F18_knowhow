/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

FUNCTION s_tarifa( cIdTar )

   LOCAL cPom := ""

   PushWA()

   SELECT ( F_TARIFA )

   IF !Used()
      o_tarifa()
   ENDIF
   SET ORDER TO TAG "ID"
   SEEK cIdTar

   IF !Found()
      cPom := "-NEP.TAR- ?!"
   ELSE
      cPom := AllTrim( naz )
   ENDIF

   PopWa()

   RETURN cPom


// -----------------------------
// get stopu za tarifu
// -----------------------------
FUNCTION g_pdv_stopa( cIdTar )

   LOCAL nStopa

   PushWA()

   SELECT ( F_TARIFA )

   IF !Used()
      o_tarifa()
   ENDIF
   SET ORDER TO TAG "ID"
   SEEK PadR( cIdTar, 6 )

   IF !Found()
      nStopa := -999
   ELSE
      nStopa := tarifa->opp
   ENDIF

   PopWa()

   RETURN nStopa
