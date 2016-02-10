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

STATIC s_lInSync := .F.

/*
 napuni tablu sa servera
  step_size - broj zapisa koji se citaju u jednom query-u
*/
FUNCTION full_synchro( dbf_table, step_size, cInfo )

   LOCAL _seconds
   LOCAL _count
   LOCAL _offset
   LOCAL _qry
   LOCAL _sql_table, _sql_fields
   LOCAL aDbfRec
   LOCAL _sql_order
   LOCAL _opened
   LOCAL _sql_fetch_time, _dbf_write_time
   LOCAL _msg


   IF s_lInSync
      RETURN .F.
   ENDIF

   s_lInSync := .T.

   IF step_size == NIL
      step_size := 20000
   ENDIF

   nuliraj_ids_and_update_my_semaphore_ver( dbf_table )

   // transakcija treba da se ne bi vidjele promjene koje prave drugi
   // ako nemam transakcije onda se moze desiti ovo:
   // 1) odabarem 100 000 zapisa i pocnem ih uzimati po redu (po dokumentima)
   // 2) drugi korisnik izmijeni neki stari dokument u sredini prenosa i u njega doda 500 stavki
   // 4) ja cu pokupiti 100 000 stavki a necu posljednjih 500
   // 3) ako nema transakcije ja cu pokupiti tu promjenu, sa transakcijom ja tu promjenu neću vidjeti

   _sql_table  := "fmk." + dbf_table
   aDbfRec  := get_a_dbf_rec( dbf_table )
   _sql_fields := sql_fields( aDbfRec[ "dbf_fields" ] )

   _sql_order  := aDbfRec[ "sql_order" ]

   // nuliranje tabele
   reopen_exclusive_and_zap( aDbfRec[ "table" ], .T., .T. )
   USE

   Box(, 10, 70 )

   @ m_x + 1, m_y + 2 SAY8 "full synchro: " + _sql_table + " => " + dbf_table

   run_sql_query( "BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE" )
   _count := table_count( _sql_table, "true" )

   log_write( "START full_synchro table: " + dbf_table + "/ sql count: " + AllTrim( Str( _count ) ), 3 )

   _seconds := Seconds()

   IF _sql_fields == NIL
      _msg := "sql_fields za " + _sql_table + " nije setovan ... sinhro nije moguć"
      log_write( "full_synchro: " + _msg, 2 )
      MsgBeep( _msg )
      RaiseError( _msg )
   ENDIF

   @ m_x + 3, m_y + 2 SAY cInfo + " sql_cnt:" + Alltrim( STR(_count, 10, 0))

   FOR _offset := 0 TO _count STEP step_size

      _qry :=  "SELECT " + _sql_fields + " FROM " + _sql_table
      _qry += " ORDER BY " + _sql_order
      _qry += " LIMIT " + Str( step_size ) + " OFFSET " + Str( _offset )

      log_write( "GET FROM SQL full_synchro tabela: " + dbf_table + " " + AllTrim( Str( _offset ) ) + " / qry: " + _qry, 7 )

      @ m_x + 5, m_y + 2 SAY "dbf <- qry (ne zatvarati aplikaciju u toku ovog procesa)"

      fill_dbf_from_server( dbf_table, _qry, @_sql_fetch_time, @_dbf_write_time, .T. )

      @ m_x + 9, m_y + 15 SAY "sql fetch time: " + AllTrim( Str( _sql_fetch_time ) ) + " dbf write time: " + AllTrim( Str( _dbf_write_time ) )

      @ m_x + 10, m_y + 2 SAY _offset + step_size
      @ Row(), Col() + 2 SAY "/"
      @ Row(), Col() + 2 SAY _count

      log_write( "STEP full_synchro tabela: " + dbf_table + " " + AllTrim( Str( _offset + step_size ) ) + " / " + AllTrim( Str( _count ) ), 7 )

   NEXT

   IF log_level() > 6
      _count := table_count( _sql_table, "true" )
      log_write( "full_synchro sql (END transaction): " + dbf_table + "/ sql count: " + AllTrim( Str( _count ) ), 7 )
   ENDIF

   run_sql_query( "COMMIT" )

   IF log_level() > 6
      _count := table_count( _sql_table, "true" )
      log_write( "sql count nakon END transaction): " + dbf_table + "/ sql count: " + AllTrim( Str( _count ) ), 7 )
   ENDIF

   BoxC()

   log_write( "END full_synchro tabela: " + dbf_table +  " cnt: " + AllTrim( Str( _count ) ), 3 )

   s_lInSync := .F.
   set_a_dbf_rec_chk0( aDbfRec[ "table" ] )

   RETURN .T.
