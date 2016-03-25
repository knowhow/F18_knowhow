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


FUNCTION sql_table_update( table, op, record, where_str, silent )

   LOCAL _i, _tmp, _tmp_2, _msg, lSqlTable
   LOCAL _ret := .F.
   LOCAL _result
   LOCAL _qry
   LOCAL _tbl
   LOCAL _where
   LOCAL _server := my_server()
   LOCAL _key
   LOCAL _pos
   LOCAL _dec
   LOCAL _len
   LOCAL _a_dbf_rec, _alg
   LOCAL _dbf_fields, _sql_fields, _sql_order, _dbf_wa, _dbf_alias, _sql_tbl
   LOCAL _sql_dbf := .F.

   IF silent == NIL
      silent := .F.
   ENDIF

   IF op $ "ins#del"

      IF table == NIL
         table := Alias()
      ENDIF

      IF USED() .AND. ( rddName() == "SQLMIX" )
           // u sql tabeli su utf enkodirani stringovi
           _sql_dbf := .T.
      ENDIF

      _a_dbf_rec := get_a_dbf_rec( table )

      _dbf_fields := _a_dbf_rec[ "dbf_fields" ]
      _sql_fields := sql_fields( _dbf_fields )

      _sql_order  := _a_dbf_rec[ "sql_order" ]

      _dbf_wa    := _a_dbf_rec[ "wa" ]
      _dbf_alias := _a_dbf_rec[ "alias" ]
      lSqlTable := _a_dbf_rec[ "sql" ]
      _sql_tbl   := F18_PSQL_SCHEMA_DOT + table

      // uvijek je algoritam 1 nivo recorda
      _alg := _a_dbf_rec[ "algoritam" ][ 1 ]

      IF where_str == NIL
         IF record <> NIL
            where_str := sql_where_from_dbf_key_fields( _alg[ "dbf_key_fields" ], record, lSqlTable )
         ENDIF
      ENDIF

   ENDIF

   log_write( "sql table update, poceo", 9, silent )

   DO CASE

   CASE op == "BEGIN"
      _qry := "BEGIN"

   CASE ( op == "END" ) .OR. ( op == "COMMIT" )
      _qry := "COMMIT"

   CASE op == "ROLLBACK"
      _qry := "ROLLBACK"

   CASE op == "del"

      IF ( where_str == NIL ) .AND. ( record == NIL .OR. ( record[ "id" ] == NIL ) )
         _msg := RECI_GDJE_SAM + " nedozvoljeno stanje, postavit eksplicitno where na 'true' !!"
         Alert( _msg )
         log_write( _msg, 2, silent )
         QUIT_1
      ENDIF
      _qry := "DELETE FROM " + _sql_tbl + " WHERE " + where_str

   CASE op == "ins"

      _qry := "INSERT INTO " + _sql_tbl +  "("

      FOR _i := 1 TO Len( _a_dbf_rec[ "dbf_fields" ] )

         IF field_in_blacklist( _a_dbf_rec[ "dbf_fields" ][ _i ], _a_dbf_rec[ "blacklisted" ] )
            LOOP
         ENDIF

         _qry += _a_dbf_rec[ "dbf_fields" ][ _i ]

         IF _i < Len( _a_dbf_rec[ "dbf_fields" ] )
            _qry += ","
         ENDIF

      NEXT

      _qry += ")  VALUES ("

      FOR _i := 1 TO Len( _a_dbf_rec[ "dbf_fields" ] )

         _tmp := _a_dbf_rec[ "dbf_fields" ][ _i ]

         IF field_in_blacklist( _tmp, _a_dbf_rec[ "blacklisted" ] )
            LOOP
         ENDIF

         IF !hb_HHasKey( record, _tmp )
            _msg := "record " + op + " ne sadrzi " + _tmp + " field !?## pogledaj log !"
            log_write( _msg + " " + pp( record ), 2 )
            MsgBeep( _msg )
            RaiseError( _msg + " " + pp( record ) )
            RETURN _ret
         ENDIF

         IF ValType( record[ _tmp ] ) == "N"

            IF  _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 1 ] == "I"
              _tmp_2 := STR( record[ _tmp ], 5, 0 )
            ELSE
              _tmp_2 := Str( record[ _tmp ], _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 2 ], _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 3 ] )
            ENDIF

            IF Left( _tmp_2, 1 ) == "*"
               _msg := "err_num_width - field: " + _tmp + "  value:" + AllTrim( Str( record[ _tmp ] ) ) + " / width: " +  AllTrim( Str( _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 2 ] ) ) + " : " +  AllTrim( Str( _a_dbf_rec[ "dbf_fields_len" ][ _tmp ][ 3 ] ) )
               log_write( _msg, 2 )
               RaiseError( _msg )
            ELSE
               _qry += _tmp_2
            ENDIF
         ELSE
            IF _sql_dbf
                // sql tabela sadrzi utf-8 enkodirane podatke
                _qry += _sql_quote_u( record[ _tmp ] )
            ELSE
                _qry += sql_quote( record[ _tmp ] )
            ENDIF
         ENDIF

         IF _i < Len( _a_dbf_rec[ "dbf_fields" ] )
            _qry += ","
         ENDIF

      NEXT

      _qry += ")"

   END CASE

   _ret := _sql_query( _server, _qry, silent )

   log_write( "sql table update, table: " + IIF( table == NIL, "NIL", table ) + ", op: " + op + ", qry: " + _qry, 8, silent )
   log_write( "sql table update, VALTYPE(_ret): " + ValType( _ret ), 9, silent )
   log_write( "sql table update, zavrsio", 9, silent )

   IF !EMPTY( _ret:ErrorMsg() )
      RETURN .F.
   ELSE
      RETURN .T.
   ENDIF
