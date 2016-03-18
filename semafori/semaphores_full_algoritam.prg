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

MEMVAR m_x, m_y


/*
 napuni tablu sa servera
  nStepSize - broj zapisa koji se citaju u jednom query-u
*/
FUNCTION full_synchro( dbf_table, nStepSize, cInfo )

   LOCAL _seconds
   LOCAL nCountSql
   LOCAL _offset
   LOCAL _qry
   LOCAL _sql_table, _sql_fields
   LOCAL aDbfRec
   LOCAL _sql_order
   LOCAL _opened
   LOCAL _sql_fetch_time, _dbf_write_time
   LOCAL _msg
   LOCAL lRet := .T.

   IF nStepSize == NIL
      nStepSize := 20000
   ENDIF

   nuliraj_ids_and_update_my_semaphore_ver( dbf_table )

   // transakcija treba da se ne bi vidjele promjene koje prave drugi
   // ako nemam transakcije onda se moze desiti ovo:
   // 1) odabarem 100 000 zapisa i pocnem ih uzimati po redu (po dokumentima)
   // 2) drugi korisnik izmijeni neki stari dokument u sredini prenosa i u njega doda 500 stavki
   // 4) ja cu pokupiti 100 000 stavki a necu posljednjih 500
   // 3) ako nema transakcije ja cu pokupiti tu promjenu, sa transakcijom ja tu promjenu neću vidjeti

   _sql_table  := F18_PSQL_SCHEMA_DOT + dbf_table
   aDbfRec  := get_a_dbf_rec( dbf_table )
   _sql_fields := sql_fields( aDbfRec[ "dbf_fields" ] )

   _sql_order  := aDbfRec[ "sql_order" ]

   open_exclusive_zap_close( aDbfRec ) // nuliranje tabele


   run_sql_query( "BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE" )
   nCountSql := table_count( _sql_table, "true" )

   log_write( "START full_synchro table: " + dbf_table + "/ sql count: " + AllTrim( Str( nCountSql ) ), 3 )

   _seconds := Seconds()

   IF _sql_fields == NIL
      _msg := "sql_fields za " + _sql_table + " nije setovan ... sinhro nije moguć"
      log_write( "full_synchro: " + _msg, 2 )
      ?E _msg
      RaiseError( _msg )
   ENDIF

   info_bar( "fsync:" + dbf_table, "START: " + dbf_table  + " : " + cInfo + " sql_cnt:" + AllTrim( Str( nCountSql, 10, 0 ) ) )

   FOR _offset := 0 TO nCountSql STEP nStepSize

      _qry :=  "SELECT " + _sql_fields + " FROM " + _sql_table
      _qry += " ORDER BY " + _sql_order
      _qry += " LIMIT " + Str( nStepSize ) + " OFFSET " + Str( _offset )

      //log_write( "GET FROM SQL full_synchro tabela: " + dbf_table + " " + AllTrim( Str( _offset ) ) + " / qry: " + _qry, 7 )

      lRet := fill_dbf_from_server( dbf_table, _qry, @_sql_fetch_time, @_dbf_write_time, .T. )

      IF !lRet
         run_sql_query( "ROLLBACK" )
         error_bar( "fsync:" + dbf_table, "ERROR-END full_synchro: " + dbf_table )
         RETURN lRet
      ENDIF

      // info_bar( "fsync:" + dbf_table, "sql fetch time: " + AllTrim( Str( _sql_fetch_time ) ) + " dbf write time: " + AllTrim( Str( _dbf_write_time ) ) )
      info_bar( "fsync:" + dbf_table, "STEP full_synchro tabela: " + dbf_table + " " + AllTrim( Str( _offset + nStepSize ) ) + " / " + AllTrim( Str( nCountSql ) ) )

   NEXT

   IF log_level() > 6
      nCountSql := table_count( _sql_table, "true" )
      log_write( "full_synchro sql (END transaction): " + dbf_table + "/ sql_tbl_cnt: " + AllTrim( Str( nCountSql ) ), 7 )
   ENDIF

   run_sql_query( "COMMIT" )

   IF log_level() > 6
      nCountSql := table_count( _sql_table, "true" )
      log_write( "sql cnt END transaction): " + dbf_table + "/ sql count: " + AllTrim( Str( nCountSql ) ), 7 )
   ENDIF

   info_bar( "fsync", "END full_synchro: " + dbf_table +  " cnt: " + AllTrim( Str( nCountSql ) ) )

   set_a_dbf_rec_chk0( aDbfRec[ "table" ] )

   RETURN lRet
