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
FUNCTION full_synchro( cDbfTable, nStepSize, cInfo )

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
   LOCAL cTransactionName

   IF nStepSize == NIL
      nStepSize := 20000
   ENDIF

   nuliraj_ids_and_update_my_semaphore_ver( cDbfTable )

   // transakcija treba da se ne bi vidjele promjene koje prave drugi
   // ako nemam transakcije onda se moze desiti ovo:
   // 1) odabarem 100 000 zapisa i pocnem ih uzimati po redu (po dokumentima)
   // 2) drugi korisnik izmijeni neki stari dokument u sredini prenosa i u njega doda 500 stavki
   // 4) ja cu pokupiti 100 000 stavki a necu posljednjih 500
   // 3) ako nema transakcije ja cu pokupiti tu promjenu, sa transakcijom ja tu promjenu neću vidjeti

   _sql_table  := F18_PSQL_SCHEMA_DOT + cDbfTable
   aDbfRec  := get_a_dbf_rec( cDbfTable )
   _sql_fields := sql_fields( aDbfRec[ "dbf_fields" ] )

   _sql_order  := aDbfRec[ "sql_order" ]

   open_exclusive_zap_close( aDbfRec ) // nuliranje tabele

IF cDbfTable == "pos_pos"
altd()
ENDIF
   cTransactionName :=  "full_" + cDbfTable + ":" + cInfo
   run_sql_query( "BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE", , , cTransactionName )
/*
   ERROR:  SET TRANSACTION ISOLATION LEVEL must be called before any query
STATEMENT:  BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
WARNING:  there is already a transaction in progress
*/

   nCountSql := table_count( _sql_table, "true" )

/*
   nCountSql := table_count( _sql_table, "true" ) <<< 314

   ERROR:  current transaction is aborted, commands ignored until end of transaction block
     //   1 RUN_SQL_QUERY / 88 //   2 _SQL_QUERY / 36 //   3 TABLE_COUNT / 314 //   4 FULL_SYNCHRO / 59 //   5 CHECK_RECNO_AND_FIX / 43 //   6 DBF_REFRESH_0 / 799 //   7 DBF_REFRESH / 750 //   8 F18_LOCK_TABLES / 77 //   9 POS_AZURIRAJ_RACUN / 35 //  10 AZURIRAJ_STAVKE_RACUNA_I_NAPRAVI_FISKALNI_RACUN / 182 //  11 ZAKLJUCI_POS_RACUN / 143 //  12 _POS_PRODAVAC_RACUN / 63 //  13 (b)POS_MAIN_MENU_PRODAVAC / 23 //  14 F18_MENU / 61 //  15 POS_MAIN_MENU_PRODAVAC / 53 //  16 POS_MAIN_MENU_LEVEL / 125 //  17 TPOSMOD:MMENU / 100 //  18 TPOSMOD:RUN / 126 //  19 MAINPOS / 26 //  20 (b)SET_PROGRAM_MODULE_MENU / 227 //  21 PROGRAM_MODULE_MENU / 153 //  22 F18_LOGIN / 219 //  23 MAIN / 39
   SQL ERROR QUERY:  SELECT COUNT(*) FROM fmk.pos_pos WHERE trueERROR:  current transaction is aborted, commands ignored until end of transaction block

*/

   ?E "START full_synchro table: " + cDbfTable + "/ sql count: " + AllTrim( Str( nCountSql ) )

   _seconds := Seconds()

   IF _sql_fields == NIL
      run_sql_query( "ROLLBACK", , , cTransactionName )
      _msg := "sql_fields za " + _sql_table + " nije setovan ... sinhro nije moguć"
      ?E "full_synchro: " + _msg
      unset_a_dbf_rec_chk0( aDbfRec[ "table" ] )
      ?E _msg
      RaiseError( _msg )
   ENDIF

   info_bar( "fsync:" + cDbfTable, "START: " + cDbfTable  + " : " + cInfo + " sql_cnt:" + AllTrim( Str( nCountSql, 10, 0 ) ) )

   FOR _offset := 0 TO nCountSql STEP nStepSize

      _qry :=  "SELECT " + _sql_fields + " FROM " + _sql_table
      _qry += " ORDER BY " + _sql_order
      _qry += " LIMIT " + Str( nStepSize ) + " OFFSET " + Str( _offset )

      // log_write( "GET FROM SQL full_synchro tabela: " + cDbfTable + " " + AllTrim( Str( _offset ) ) + " / qry: " + _qry, 7 )

      lRet := fill_dbf_from_server( cDbfTable, _qry, @_sql_fetch_time, @_dbf_write_time, .T. )

      IF !lRet
         run_sql_query( "ROLLBACK", , , cTransactionName )
         error_bar( "fsync:" + cDbfTable, "ERROR-END full_synchro: " + cDbfTable )
         unset_a_dbf_rec_chk0( aDbfRec[ "table" ] )
         RETURN lRet
      ENDIF

      // info_bar( "fsync:" + cDbfTable, "sql fetch time: " + AllTrim( Str( _sql_fetch_time ) ) + " dbf write time: " + AllTrim( Str( _dbf_write_time ) ) )
      info_bar( "fsync:" + cDbfTable, "STEP full_synchro tabela: " + cDbfTable + " " + AllTrim( Str( _offset + nStepSize ) ) + " / " + AllTrim( Str( nCountSql ) ) )

   NEXT

#ifdef F18_DEBUG_SYNC
   nCountSql := table_count( _sql_table, "true" )
   ?E "full_synchro sql (END transaction): ", cDbfTable, "/ sql_tbl_cnt: ", AllTrim( Str( nCountSql ) )
#endif

   run_sql_query( "COMMIT", , , cTransactionName )

   nCountSql := table_count( _sql_table, "true" )
#ifdef F18_DEBUG_SYNC
   ?E "sql cnt (END transaction): " + cDbfTable + "/ sql count: " + AllTrim( Str( nCountSql ) )
#endif

   info_bar( "fsync", "END full_synchro: " + cDbfTable +  " cnt: " + AllTrim( Str( nCountSql ) ) )
   set_a_dbf_rec_chk0( aDbfRec[ "table" ] )

   RETURN lRet
