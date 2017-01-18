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


FUNCTION o_vrste_placanja()

   LOCAL cTabela := "vrstep"

   SELECT ( F_VRSTEP )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_tdok()

   LOCAL cTabela := "tdok"

   SELECT ( F_TDOK )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION o_tnal()

   LOCAL cTabela := "tnal"

   SELECT ( F_TNAL )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.
