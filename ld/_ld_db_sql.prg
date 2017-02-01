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

FUNCTION seek_ld( cIdRj, nGodina, nMjesec, cObracun, cIdRadn, cTag )

   LOCAL cSql
   LOCAL cTable := "ld_ld"
   LOCAL hIndexes, cKey

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   cSql += " WHERE godina=" + Str( nGodina, 4, 0 )

   IF cIdRj != NIL
      cSql += " AND idrj=" + sql_quote( cIdRj )
   ENDIF

   IF nMjesec != NIL
      cSql += " AND mjesec=" + Str( nMjesec, 2, 0 )
   ENDIF

   IF cObracun != NIL
      cSql += " AND obr=" + sql_quote( cObracun )
   ENDIF

   IF cIdRadn != NIL .AND. !Empty( cIdRadn )
      cSql += " AND idradn=" + sql_quote( cIdRadn )
   ENDIF

   SELECT F_LD
   use_sql( cTable, cSql, "LD" )

   hIndexes := h_ld_ld_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( "LD" )
   NEXT
   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN .T.


FUNCTION seek_ld_2( cIdRj, nGodina, nMjesec, cObracun, cIdRadn )

   seek_ld( cIdRj, nGodina, nMjesec, cObracun, cIdRadn )
   SET ORDER TO TAG "2"

   RETURN .T.


FUNCTION ld_max_godina()

   LOCAL cSql

   cSql := "select max(godina) as godina from fmk.ld_ld"
   use_sql( "ld_ld", cSql, "LD" )

   RETURN .T.


FUNCTION ld_min_godina()

   LOCAL cSql

   cSql := "select min(godina) as godina from fmk.ld_ld"
   use_sql( "ld_ld", cSql, "LD" )

   RETURN .T.

/*
   SELECT radkr
   SET ORDER TO 1
   SEEK Str( _godina, 4 ) + Str( _mjesec, 2 ) + _idradn
*/
FUNCTION seek_radkr( nGodina, nMjesec, cIdRadn, cIdKred, cNaOsnovu, cTag )

   LOCAL cSql
   LOCAL cTable := "ld_radkr"
   LOCAL hIndexes, cKey, lWhere := .F.

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable


   IF nGodina != NIL
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "godina=" + Str( nGodina, 4 )
   ENDIF


   IF nMjesec != NIL
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "mjesec=" + Str( nMjesec, 2 )
   ENDIF


   IF cIdRadn != NIL .AND. !Empty( cIdRadn )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idradn=" + sql_quote( cIdRadn )
   ENDIF


   IF cIdKred != NIL
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idkred=" + sql_quote( cIdKred )
   ENDIF


   IF cNaOsnovu != NIL
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "naosnovu=" + sql_quote( cNaOsnovu )
   ENDIF

   SELECT F_RADKR
   use_sql( cTable, cSql, "RADKR" )

   hIndexes := h_ld_radkr_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( "RADKR" )
   NEXT

   IF cTag == NIL
      IF cNaOsnovu != NIL
         cTag := "2"
      ELSE
         cTag := "1"
      ENDIF
   ENDIF

   SET ORDER TO TAG ( cTag )

   GO TOP

   RETURN .T.


FUNCTION seek_radkr_2( cIdRadn, cIdkred, cNaOsnovu, nGodina, nMjesec )

   RETURN seek_radkr( nGodina, nMjesec, cIdRadn, cIdKred, cNaOsnovu )


FUNCTION o_radkr_1rec()
   RETURN o_radkr( .T. )


FUNCTION o_radkr_all_rec()
   RETURN o_radkr( .F. )


FUNCTION o_radkr( lRec1 )

   LOCAL cSql, lRet, hIndexes, cKey

   hb_default( @lRec1, .T. )

   cSql := "select * from fmk.ld_radkr"

   IF lRec1
      cSql += " LIMIT 1"
   ENDIF

   IF !lRec1
      MsgO( "Preuzimanje tabele RADKR sa servera ..." )
   ENDIF
   lRet := use_sql( "ld_radkr", cSql, "RADKR" )

   hIndexes := h_ld_radkr_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( "RADKR" )
   NEXT

   IF !lRec1
      Msgc()
   ENDIF

   RETURN lRet


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

   cSql += " WHERE godina =" + Str( nGodina, 4 ) + ;
      " AND mjesec>=" + Str( nMjesec, 2, 0 ) + " AND mjesec<=" + Str( nMjesecDo, 2, 0 )

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
