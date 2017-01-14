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

FUNCTION o_fakt()
   RETURN o_dbf_table( F_FAKT, "fakt", "1" )

FUNCTION o_fakt_doks()
   RETURN o_dbf_table( F_FAKT_DOKS, "fakt_doks", "1" )

FUNCTION select_fakt_doks()

   select_o_dbf( "FAKT_DOKS", F_FAKT_DOKS, "fakt_doks", "1" )
   IF Alias() != "FAKT_DOKS"
      Alert( "Nije FAKT DOKS ?!" )
      RETURN .F.
   ENDIF

   RETURN .T.
