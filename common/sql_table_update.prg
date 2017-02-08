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

   LOCAL nI, cTmp, _tmp_2, _msg, lSqlTable
   LOCAL oQueryRet := NIL
   LOCAL _result
   LOCAL cQuery
   LOCAL _tbl
   LOCAL _where
   LOCAL _key
   LOCAL _pos
   LOCAL _dec
   LOCAL _len
   LOCAL hDbfRec, hAlgoritam1
   LOCAL aDbfFields, aSqlFields, _sql_order, nDbfWA, cDbfAlias, cSqlTableFullName

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

      hDbfRec := get_a_dbf_rec( cTable )

      if cTable == "fin_suban"
      altd()
      endif

      aDbfFields := hDbfRec[ "dbf_fields" ]
      aSqlFields := sql_fields( aDbfFields )

      _sql_order  := hDbfRec[ "sql_order" ]

      nDbfWA    := hDbfRec[ "wa" ]
      cDbfAlias := hDbfRec[ "alias" ]
      lSqlTable := hDbfRec[ "sql" ]
      cSqlTableFullName   := F18_PSQL_SCHEMA_DOT + cTable

      // uvijek je algoritam 1 nivo recorda
      hAlgoritam1 := hDbfRec[ "algoritam" ][ 1 ]

      IF cWhereStr == NIL
         IF hRecord <> NIL
            cWhereStr := sql_where_from_dbf_key_fields( hAlgoritam1[ "dbf_key_fields" ], hRecord, lSqlTable )
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
      cQuery := "DELETE FROM " + cSqlTableFullName + " WHERE " + cWhereStr

   CASE cSqlOperator == "ins"

      cQuery := "INSERT INTO " + cSqlTableFullName +  "("

      FOR nI := 1 TO Len( hDbfRec[ "dbf_fields" ] )

         IF field_in_blacklist( hDbfRec[ "dbf_fields" ][ nI ], hDbfRec[ "blacklisted" ] )
            LOOP
         ENDIF

         cQuery += hDbfRec[ "dbf_fields" ][ nI ]

         IF nI < Len( hDbfRec[ "dbf_fields" ] )
            cQuery += ","
         ENDIF

      NEXT

      cQuery += ")  VALUES ("

      FOR nI := 1 TO Len( hDbfRec[ "dbf_fields" ] )

         cTmp := hDbfRec[ "dbf_fields" ][ nI ]

         IF cTmp == "obradjeno" .OR. field_in_blacklist( cTmp, hDbfRec[ "blacklisted" ] ) // polje obradjeno je automatski timestamp
            LOOP
         ENDIF

         IF !hb_HHasKey( hRecord, cTmp )
            _msg := "record " + cSqlOperator + " ne sadrzi " + cTmp + " field !?## pogledaj log !"
            log_write( _msg + " " + pp( hRecord ), 2 )
            MsgBeep( _msg )
            RaiseError( _msg + " " + pp( hRecord ) )
            RETURN .F.
         ENDIF

         IF ValType( hRecord[ cTmp ] ) == "N"
            IF  hDbfRec[ "dbf_fields_len" ][ cTmp ][ 1 ] == "I"
               _tmp_2 := Str( hRecord[ cTmp ], 5, 0 )
            ELSE
               _tmp_2 := Str( hRecord[ cTmp ], hDbfRec[ "dbf_fields_len" ][ cTmp ][ 2 ], hDbfRec[ "dbf_fields_len" ][ cTmp ][ 3 ] )
            ENDIF

            IF Left( _tmp_2, 1 ) == "*"
               _msg := "err_num_width - field: " + cTmp + "  value:" + AllTrim( Str( hRecord[ cTmp ] ) ) + " / width: " +  AllTrim( Str( hDbfRec[ "dbf_fields_len" ][ cTmp ][ 2 ] ) ) + " : " +  AllTrim( Str( hDbfRec[ "dbf_fields_len" ][ cTmp ][ 3 ] ) )
               log_write( _msg, 2 )
               RaiseError( _msg )
            ELSE
               cQuery += _tmp_2
            ENDIF
         ELSE
            // IF lSqlDbf
            // cQuery += sql_quote_u( hRecord[ cTmp ] ) // sql tabela sadrzi utf-8 enkodirane podatke
            // ELSE
            cQuery += sql_quote( hRecord[ cTmp ] )
            // ENDIF
         ENDIF

         IF nI < Len( hDbfRec[ "dbf_fields" ] )
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
