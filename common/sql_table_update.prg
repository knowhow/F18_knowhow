/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


/*
   update hRecord na serveru
*/

FUNCTION sql_table_update( cTable, cSqlOperator, hRecord, cWhereStr, lSilent )

   LOCAL nI, _tmp, _tmp_2, _msg, lSqlTable
   LOCAL oQueryRet := NIL
   LOCAL _result
   LOCAL cQuery
   LOCAL _tbl
   LOCAL _where
   LOCAL _key
   LOCAL _pos
   LOCAL _dec
   LOCAL _len
   LOCAL _a_dbf_rec, _alg
   LOCAL _dbf_fields, _sql_fields, _sql_order, _dbf_wa, _dbf_alias, _sql_tbl

   // LOCAL lSqlDbf := .F. hRecord je uvijek 852 enkodiran!

   IF lSilent == NIL
      lSilent := .F.
   ENDIF

   IF cSqlOperator $ "ins#del"

      IF cTable == NIL
         cTable := Alias()
      ENDIF

      // IF USED() .AND. ( rddName() == "SQLMIX" )
      // lSqlDbf := .T.  // u sql tabeli su utf enkodirani stringovi
      // ENDIF

      _a_dbf_rec := get_a_dbf_rec( cTable )

      _dbf_fields := _a_dbf_rec[ "dbf_fields" ]
      _sql_fields := sql_fields( _dbf_fields )

      _sql_order  := _a_dbf_rec[ "sql_order" ]

      _dbf_wa    := _a_dbf_rec[ "wa" ]
      _dbf_alias := _a_dbf_rec[ "alias" ]
      lSqlTable := _a_dbf_rec[ "sql" ]
      _sql_tbl   := F18_PSQL_SCHEMA_DOT + cTable

      // uvijek je algoritam 1 nivo recorda
      _alg := _a_dbf_rec[ "algoritam" ][ 1 ]

      IF cWhereStr == NIL
         IF hRecord <> NIL
            cWhereStr := sql_where_from_dbf_key_fields( _alg[ "dbf_key_fields" ], hRecord, lSqlTable )
         ENDIF
      ENDIF

   ENDIF

   // log_write( "sql table update, poceo", 9, lSilent )

   DO CASE

   CASE cSqlOperator == "BEGIN"
      cQuery := "BEGIN"

   CASE ( cSqlOperator == "END" ) .OR. ( cSqlOperator == "COMMIT" )
      cQuery := "COMMIT"

   CASE cSqlOperator == "ROLLBACK"
      cQuery := "ROLLBACK"

   CASE cSqlOperator == "del"

      IF ( cWhereStr == NIL ) .AND. ( hRecord == NIL .OR. ( hRecord[ "id" ] == NIL ) )
         _msg := RECI_GDJE_SAM + " nedozvoljeno stanje, postavit eksplicitno where na 'true' !!"
         Alert( _msg )
         log_write( _msg, 2, lSilent )
         QUIT_1
      ENDIF
      cQuery := "DELETE FROM " + _sql_tbl + " WHERE " + cWhereStr

   CASE cSqlOperator == "ins"

      cQuery := "INSERT INTO " + _sql_tbl +  "("

      FOR nI := 1 TO Len( _a_dbf_rec[ "dbf_fields" ] )

         IF field_in_blacklist( _a_dbf_rec[ "dbf_fields" ][ nI ], _a_dbf_rec[ "blacklisted" ] )
            LOOP
         ENDIF

         cQuery += _a_dbf_rec[ "dbf_fields" ][ nI ]

         IF nI < Len( _a_dbf_rec[ "dbf_fields" ] )
            cQuery += ","
         ENDIF

      NEXT

      cQuery += ")  VALUES ("

      FOR nI := 1 TO Len( _a_dbf_rec[ "dbf_fields" ] )

         _tmp := _a_dbf_rec[ "dbf_fields" ][ nI ]

         IF field_in_blacklist( _tmp, _a_dbf_rec[ "blacklisted" ] )
            LOOP
         ENDIF

         IF !hb_HHasKey( hRecord, _tmp )
            _msg := "record " + cSqlOperator + " ne sadrzi " + _tmp + " field !?## pogledaj log !"
            log_write( _msg + " " + pp( hRecord ), 2 )
            MsgBeep( _msg )
            RaiseError( _msg + " " + pp( hRecord ) )
            RETURN .F.
         ENDIF

         IF ValType( hRecord[ _tmp ] ) == "N"
            IF  _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 1 ] == "I"
               _tmp_2 := Str( hRecord[ _tmp ], 5, 0 )
            ELSE
               _tmp_2 := Str( hRecord[ _tmp ], _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 2 ], _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 3 ] )
            ENDIF

            IF Left( _tmp_2, 1 ) == "*"
               _msg := "err_num_width - field: " + _tmp + "  value:" + AllTrim( Str( hRecord[ _tmp ] ) ) + " / width: " +  AllTrim( Str( _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 2 ] ) ) + " : " +  AllTrim( Str( _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 3 ] ) )
               log_write( _msg, 2 )
               RaiseError( _msg )
            ELSE
               cQuery += _tmp_2
            ENDIF
         ELSE
            // IF lSqlDbf
            // cQuery += sql_quote_u( hRecord[ _tmp ] ) // sql tabela sadrzi utf-8 enkodirane podatke
            // ELSE
            cQuery += sql_quote( hRecord[ _tmp ] )
            // ENDIF
         ENDIF

         IF nI < Len( _a_dbf_rec[ "dbf_fields" ] )
            cQuery += ","
         ENDIF

      NEXT

      cQuery += ")"

   END CASE

   // ?E "sql table update", cQuery
   oQueryRet := run_sql_query( cQuery )

   log_write( "sql table update, table: " + iif( cTable == NIL, "NIL", cTable ) + ", op: " + cSqlOperator + ", qry: " + cQuery, 8, lSilent )
   log_write( "sql table update, VALTYPE(oQueryRet): " + ValType( oQueryRet ), 9, lSilent )
   log_write( "sql table update, zavrsio", 9, lSilent )

   IF sql_error_in_query( oQueryRet, "INSERT" )
      RETURN .F.
   ENDIF

   RETURN .T.
