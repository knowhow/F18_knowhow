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

FUNCTION use_sql_ld_ld( nGodina, nMjesec, nMjesecDo, nVrInvalid, nStInvalid )

   LOCAL cSql
   LOCAL aDbf := a_dbf_ld_ld()
   LOCAL cTable := "ld_ld"
   LOCAL hIndexes, cKey

   cSql := "SELECT "
   cSql += sql_from_adbf( @aDbf, cTable )

   cSql += ", ld_radn.vr_invalid, ld_radn.st_invalid "
   cSql += " FROM fmk." + cTable
   cSql += " LEFT JOIN fmk.ld_radn ON ld_ld.idradn = ld_radn.id"

   cSql += " WHERE godina =" + _sql_quote( nGodina ) + ;
      " AND mjesec>=" + _sql_quote( nMjesec ) + " AND mjesec<=" + _sql_quote( nMjesecDo )

   IF nVrInvalid > 0
     cSql += "AND vr_invalid = " + _sql_quote( nVrInvalid )
   ENDIF

   IF nStInvalid > 0
     cSql += "AND st_invalid >= " + _sql_quote( nStInvalid )
   ENDIF

   SELECT F_LD
   use_sql( cTable, cSql, "LD" )

   hIndexes := h_ld_ld_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &(hIndexes[ cKey ])  TAG ( cKey ) TO ( cTable )
   NEXT
   SET ORDER TO TAG "1"

   RETURN .T.
