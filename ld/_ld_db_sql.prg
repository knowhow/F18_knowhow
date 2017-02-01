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

/*
SEEK Str( nGodina, 4 ) + cIdRj + Str( nMjesec, 2 ) + ld_broj_obracuna() + cIdRadn

seek_ld( cIdRj, nGodina, nMjesec, cObracun, cIdRadn )
*/

FUNCTION seek_ld( cIdRj, nGodina, nMjesec, cObracun, cIdRadn )

   LOCAL cSql
   LOCAL cTable := "ld_ld"
   LOCAL hIndexes, cKey

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   cSql += " WHERE godina =" + sql_quote( nGodina )

   IF cIdRj != NIL
      cSql += " AND idrj=" + sql_quote( cIdRj )
   ENDIF

   IF nMjesec != NIL
      cSql += " AND mjesec=" + sql_quote( nMjesec )
   ENDIF

   IF cObracun != NIL
      cSql += " AND obr=" + sql_quote( cObracun )
   ENDIF

   IF cIdRadn != NIL
      cSql += " AND idradn=" + sql_quote( cIdRadn )
   ENDIF

   SELECT F_LD
   use_sql( cTable, cSql, "LD" )

   hIndexes := h_ld_ld_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( "LD" )
   NEXT
   SET ORDER TO TAG "1"
   GO TOP

   RETURN .T.


/*
   SELECT radkr
   SET ORDER TO 1
   SEEK Str( _godina, 4 ) + Str( _mjesec, 2 ) + _idradn
*/
FUNCTION seek_radkr( nGodina, nMjesec, cIdRadn, cIdKred, cNaOsnovu )

   LOCAL cSql
   LOCAL cTable := "ld_radkr"
   LOCAL hIndexes, cKey

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   cSql += " WHERE godina =" + sql_quote( nGodina )

   IF nMjesec != NIL
      cSql += " AND mjesec=" + sql_quote( nMjesec )
   ENDIF

   IF cIdRadn != NIL
      cSql += " AND idradn=" + sql_quote( cIdRadn )
   ENDIF

   IF cIdKred != NIL
      cSql += " AND idkred=" + sql_quote( cNaOsnovu )
   ENDIF

   IF cNaOsnovu != NIL
      cSql += " AND naosnovu=" + sql_quote( cNaOsnovu )
   ENDIF

   SELECT F_RADKR
   use_sql( cTable, cSql, "RADKR" )

   hIndexes := h_ld_radkr_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( "RADKR" )
   NEXT

   IF cNaOsnovu != NIL
      SET ORDER TO TAG "2"
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   GO TOP

   RETURN .T.


FUNCTION seek_radkr_2( cIdRadn, cIdkred, cNaOsnovu, nGodina, nMjesec )

   RETURN seek_radkr( nGodina, nMjesec, cIdRadn, cIdKred, cNaOsnovu )



FUNCTION use_sql_ld_ld( nGodina, nMjesec, nMjesecDo, nVrInvalid, nStInvalid, cFilter )

   LOCAL cSql
   LOCAL aDbf := a_dbf_ld_ld()
   LOCAL cTable := "ld_ld"
   LOCAL hIndexes, cKey

   hb_default( @cFilter, ".t." )

   cSql := "SELECT "
   cSql += sql_from_adbf( @aDbf, cTable )

   cSql += ", ld_radn.vr_invalid, ld_radn.st_invalid "
   cSql += " FROM " + F18_PSQL_SCHEMA_DOT + cTable
   cSql += " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "ld_radn ON ld_ld.idradn = ld_radn.id"

   cSql += " WHERE godina =" + sql_quote( nGodina ) + ;
      " AND mjesec>=" + sql_quote( nMjesec ) + " AND mjesec<=" + sql_quote( nMjesecDo )

   IF nVrInvalid > 0
      cSql += "AND vr_invalid = " + sql_quote( nVrInvalid )
   ENDIF

   IF nStInvalid > 0
      cSql += "AND st_invalid >= " + sql_quote( nStInvalid )
   ENDIF

   SELECT F_LD
   use_sql( cTable, cSql, "LD" )


   hIndexes := h_ld_ld_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cTable ) FOR &cFilter
   NEXT
   SET ORDER TO TAG "1"
   GO TOP

   RETURN .T.
