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

STATIC s_hInDbfRefresh := NIL
STATIC s_mtxMutex
STATIC s_aLastRefresh := { "x", 0 }

#ifdef F18_SIMULATE_BUG
STATIC s_nBug1 := 1
#endif

/*
   moguci statusi:
        lock
        locked_by_me
        free
*/

FUNCTION lock_semaphore( table, status, lUnlockTable )

   LOCAL _qry
   LOCAL _ret
   LOCAL _i
   LOCAL _err_msg
   LOCAL _user   := f18_user()
   LOCAL _user_locked
   LOCAL cSemaphoreStatus

   IF skip_semaphore_sync( table )
      RETURN .T.
   ENDIF

   IF lUnlockTable == NIL
      lUnlockTable := .T.
   ENDIF

   // status se moze mijenjati samo ako neko drugi nije lock-ovao tabelu
   log_write( "table: " + table + ", status:" + status + " START", 8 )

   _i := 0
   WHILE .T.

      _i++

      cSemaphoreStatus := get_semaphore_status( table )
      IF cSemaphoreStatus == "unknown"
         RETURN .F.
      ENDIF

      IF !lUnlockTable .AND. cSemaphoreStatus != "free"
         // lUnlockTable = .F. - ne raditi nasilni unlock
         RETURN .F.
      ENDIF

      IF cSemaphoreStatus == "lock"
         _user_locked := get_semaphore_locked_by_me_status_user( table )
         _err_msg := ToStr( Time() ) + " : table locked : " + table + " user: " + _user_locked + " retry : " + Str( _i, 2 ) + "/" + Str( SEMAPHORE_LOCK_RETRY_NUM, 2 )
         log_write( _err_msg, 2 )
         hb_idleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
         log_write( "call stack 1 " + ProcName( 1 ) + " " + AllTrim( Str( ProcLine( 1 ) ) ), 2 )
         log_write( "call stack 2 " + ProcName( 2 ) + " " + AllTrim( Str( ProcLine( 2 ) ) ), 2 )
         MsgC()
      ELSE

         IF _i > 1
            _err_msg := ToStr( Time() ) + " : tabela otključana : " + table + " retry : " + Str( _i, 2 ) + "/" + Str( SEMAPHORE_LOCK_RETRY_NUM, 2 )
            log_write( _err_msg, 2 )
         ENDIF
         EXIT

      ENDIF

      IF ( _i >= SEMAPHORE_LOCK_RETRY_NUM )
         _err_msg := "table " + table + " ostala lockovana nakon " + Str( SEMAPHORE_LOCK_RETRY_NUM, 2 ) + " pokušaja ##" + ;
            "nasilno uklanjam lock !"
         MsgBeep( _err_msg )
         log_write( _err_msg, 2 )
         EXIT

      ENDIF

   ENDDO

   // svi useri su lockovani
   _qry := "UPDATE sem." + table + " SET algorithm=" + sql_quote( status ) + ", last_trans_user_code=" + sql_quote( _user ) + "; "

   IF ( status == "lock" )
      _qry += "UPDATE sem." + table + " SET algorithm='locked_by_me' WHERE user_code=" + sql_quote( _user ) + ";"
   ENDIF

   _ret := run_sql_query( _qry )

   log_write( "table: " + table + ", status:" + status + " - END", 7 )

   IF !Empty( _ret:ErrorMsg() )
      log_write( "qry error: " + _qry + " : " + _ret:ErrorMsg(), 2 )
      RaiseError( _qry )
   ENDIF

   RETURN .T.


FUNCTION get_semaphore_locked_by_me_status_user( table )

   LOCAL _qry
   LOCAL _ret

   _qry := "SELECT user_code FROM sem." + table + " WHERE algorithm = 'locked_by_me'"
   _ret := run_sql_query( _qry )

   RETURN AllTrim( _ret:FieldGet( 1 ) )


/*
     get_semaphore_status( "konto" )

     =>
          "free"  - tabela slobodna
          "locked" - zauzeta
          "unknown" - ne mogu dobiti odgovor od servera, vjerovatno free
*/

FUNCTION get_semaphore_status( table )

   LOCAL _qry
   LOCAL _ret
   LOCAL _user   := f18_user()

   IF skip_semaphore_sync( table )
      RETURN "free"
   ENDIF

   _qry := "SELECT algorithm FROM sem." + table + " WHERE user_code=" + sql_quote( _user )
   _ret := run_sql_query( _qry )

   IF sql_query_bez_zapisa( _ret )
      RETURN "unknown"
   ENDIF

   RETURN AllTrim( _ret:FieldGet( 1 ) )



FUNCTION last_semaphore_version( table )

   LOCAL _qry
   LOCAL _ret

   _qry := "SELECT last_trans_version FROM  sem." + table + " WHERE user_code=" + sql_quote( f18_user() )
   _ret := run_sql_query( _qry )

   IF sql_query_bez_zapisa( _ret )
      RETURN -1
   ENDIF

   RETURN _ret:FieldGet( 1 )




// -----------------------------------------------------------------------
// get_semaphore_version( "konto", last = .t. => last_version)
// -----------------------------------------------------------------------
FUNCTION get_semaphore_version( table, last )

   LOCAL _tbl_obj
   LOCAL _result
   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()
   LOCAL _msg

   insert_semaphore_if_not_exists( table )

   // last_version ili tekuca
   IF last == NIL
      last := .F.
   ENDIF

   _tbl := "sem." + Lower( table )

   _qry := "SELECT "
   IF last
      _qry +=  "MAX(last_trans_version) AS ver"
   ELSE
      _qry += "version as ver"
   ENDIF
   _qry += " FROM " + _tbl + " WHERE user_code=" + sql_quote( _user )

   _qry += " UNION SELECT -1 ORDER BY ver DESC LIMIT 1"

   _tbl_obj := run_sql_query( _qry )

   IF sql_query_bez_zapisa( _tbl_obj )
      _msg = "problem sa:" + _qry
      log_write( _msg, 2 )
      MsgBeep( 2 )
      QUIT_1
   ENDIF

   _result := _tbl_obj:FieldGet( 1 )

   RETURN _result


/*
    get_semaphore_version_h( "konto")
*/

FUNCTION get_semaphore_version_h( table )

   LOCAL _tbl_obj
   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()
   LOCAL _ret := hb_Hash()
   LOCAL _msg

   IF skip_semaphore_sync( table )
      _ret[ "version" ] := 1
      _ret[ "last_version" ] := 1
      RETURN _ret
   ENDIF

   insert_semaphore_if_not_exists( table )

   _tbl := "sem." + Lower( table )

   _qry := "SELECT version, last_trans_version AS last_version"
   _qry += " FROM " + _tbl + " WHERE user_code=" + sql_quote( _user )
   _qry += " UNION SELECT -1, -1 ORDER BY version DESC LIMIT 1"

   _tbl_obj := run_sql_query( _qry )

   IF sql_query_bez_zapisa( _tbl_obj )
      _msg = "problem sa:" + _qry
      log_write( _msg, 2 )
      MsgBeep( _msg )
      QUIT_1
   ENDIF

   _ret[ "version" ]      := _tbl_obj:FieldGet( 1 )
   _ret[ "last_version" ] := _tbl_obj:FieldGet( 2 )

   RETURN _ret



/*
 reset_semaphore_version( "konto")
 set version to -1
*/

FUNCTION reset_semaphore_version( table )

   LOCAL _ret
   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()

   IF skip_semaphore_sync( table )
      RETURN .T.
   ENDIF

   _tbl := "sem." + Lower( table )

   insert_semaphore_if_not_exists( table )

   log_write( "reset semaphore " + _tbl + " update ", 1 )
   _qry := "UPDATE " + _tbl + " SET version=-1, last_trans_version=(CASE WHEN last_trans_version IS NULL THEN 0 ELSE last_trans_version END) WHERE user_code =" + sql_quote( _user )
   run_sql_query( _qry )

   _qry := "SELECT version from " + _tbl + " WHERE user_code =" + sql_quote( _user )
   _ret := run_sql_query( _qry )

   log_write( "reset semaphore, select version" + Str( _ret:FieldGet( 1 ) ), 7 )

   RETURN _ret:FieldGet( 1 )



FUNCTION table_count( cTable, condition )

   LOCAL oQuery
   LOCAL _result
   LOCAL _qry
   LOCAL cMsg

   _qry := "SELECT COUNT(*) FROM " + cTable // provjeri prvo da li postoji uopšte ovaj site zapis

   IF condition != NIL
      _qry += " WHERE " + condition
   ENDIF

   oQuery := run_sql_query( _qry )

   IF sql_query_bez_zapisa( oQuery )
      cMsg := "ERR table_count : " + _qry + " msg: "
      IF is_var_objekat_tpqquery( oQuery )
         cMsg += oQuery:ErrorMsg()
      ENDIF
      ?E cMsg
      // Alert( cMsg )
      QUIT_1
   ENDIF

   // log_write( "table: " + cTable + " count = " + AllTrim( Str( oQuery:FieldGet( 1 ) ) ), 8 )

   _result := oQuery:FieldGet( 1 )

   RETURN _result


/*
 napuni dbf tabelu sa podacima sa servera
  dbf_tabela mora biti otvorena i u tekucoj WA
*/

FUNCTION fill_dbf_from_server( dbf_table, sql_query, sql_fetch_time, dbf_write_time, lShowInfo )

   LOCAL nCounterDataset := 0
   LOCAL _i, cField := "x"
   LOCAL oDataSet
   LOCAL aDbfRec, aDbfFields, cSyncalias, cFullDbf, cFullIdx
   LOCAL nI, cMsg, cCallMsg := "", oError
   LOCAL lRet := .T.
   LOCAL bField, xField, xSqlField := "xsql"

   IF lShowInfo == NIL
      lShowInfo := .F.
   ENDIF

   aDbfRec := get_a_dbf_rec( dbf_table )
   aDbfFields := aDbfRec[ "dbf_fields" ]

   sql_fetch_time := Seconds()
   oDataSet := run_sql_query( sql_query )
   sql_fetch_time := Seconds() - sql_fetch_time

   log_write( "fill_dbf_from_server START", 9 )

#ifdef F18_DEBUG
   ?E "fill_dbf:", dbf_table, "sql lastrec:", oDataSet:LastRec(), "a_dbf_rec dbf_fields: ", pp( aDbfFields )
#endif

   dbf_write_time := Seconds()

   PushWa()

   cFullDbf := my_home() + aDbfRec[ 'table' ]
   cFullIdx := ImeDbfCDX( cFullDbf )

   cSyncAlias := Upper( 'SYNC__' + aDbfRec[ 'table' ] )
   IF Select( cSyncAlias ) == 0
      SELECT ( aDbfRec[ 'wa' ] + 1000 )
      USE ( cFullDbf ) Alias ( cSyncAlias )  SHARED
      IF File( cFullIdx )
         dbSetIndex( cFullIdx )
      ENDIF

   ELSE
      ?E "syncalias ", cSyncAlias, "vec otvoren ?!"
   ENDIF

   BEGIN SEQUENCE WITH {| err| Break( err ) }
      DO WHILE !oDataSet:Eof()

         ++ nCounterDataset
         APPEND BLANK

         FOR _i := 1 TO Len( aDbfFields )

/*
         IF log_level() > 8
            ?E "for petlja ", _i, " fill_dbf:", dbf_table, "a_dbf_rec dbf_fields: ", pp( aDbfFields )
         ENDIF
  */

            cField := aDbfFields[ _i ]
#ifdef F18_SIMULATE_BUG
            IF  nCounterDataset == 100 .AND. _i == 1 .AND.  aDbfRec[ "table" ] == 'fin_suban'
               IF s_nBug1 < 2
                  cField := "simulate_bug"
                  s_nBug1++
                  error_bar( "simul_bug",  "simuliram bug na tabeli " + aDbfRec[ "table" ] )
               ELSE
                  info_bar( "simul_bug", "simuliram bug - otklonjen bug " + aDbfRec[ "table" ] )
               ENDIF
            ENDIF
#endif
            // TODO: brisati
            // bField := FieldWBlock( cField, aDbfRec[ 'wa' ] + 1000 )
            // xField := Eval( bField )
            xSqlField := oDataSet:FieldGet( oDataSet:FieldPos( cField ) )

            IF ValType( field->&cField ) $ "CM" .AND. F18_DBF_ENCODING == "CP852"
               xSqlField := hb_UTF8ToStr( xSqlField )
            ENDIF

            field->&cField := xSqlField
            // Eval( bField, xSqlField )

         NEXT

         IF lShowInfo
            IF nCounterDataset % 2500 == 0
               cMsg :=  my_server_params()[ "database" ] + " fsync: " + dbf_table + " dataset_cnt: " + AllTrim( Str( nCounterDataset ) )
               ?E cMsg
               info_bar( "fill_dbf", cMsg )
            ENDIF
         ENDIF

         oDataSet:Skip()

      ENDDO

   RECOVER USING oError

      LOG_CALL_STACK cCallMsg
      cCallMsg := "fill_dbf ERROR: " + aDbfRec[ "table" ] + " / " + ;
         oError:description + " " + oError:operation + " dbf field: " + cField + "  xSqlValue: " +  hb_ValToStr( xSqlField ) + cCallMsg + ;
         " / alias: " + Alias() + " reccount: " + AllTrim( Str( RecCount() ) )
      ?E cCallMsg
      error_bar( "fill_dbf", cCallMsg )
      unset_a_dbf_rec_chk0( aDbfRec[ "table" ] )
      IF Select( cSyncAlias ) > 0
         USE
         open_exclusive_zap_close( aDbfRec )
      ENDIF

      lRet := .F.

   END SEQUENCE

   IF Select( cSyncAlias ) > 0
      USE
   ENDIF

   IF lRet
      log_write( "fill_dbf_from_server: " + dbf_table + ", count: " + AllTrim( Str( nCounterDataset ) ), 7 )
   ENDIF
   log_write( "fill_dbf_from_server END" + iif( lRet, "", "ERR" ), 9 )

   dbf_write_time := Seconds() - dbf_write_time

   PopWa()

   RETURN lRet



// --------------------------------------------------------------------
// da li je polje u blacklisti
// --------------------------------------------------------------------
FUNCTION field_in_blacklist( field_name, blacklist )

   LOCAL _ok := .F.

   // mozda nije definisana blacklista
   IF blacklist == NIL
      RETURN _ok
   ENDIF

   IF AScan( blacklist, {| val| val == field_name } ) > 0
      _ok := .T.
   ENDIF

   RETURN _ok


/*
   update_semaphore_version_after_push( "konto" )
*/
FUNCTION update_semaphore_version_after_push( table, to_myself )

   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()
   LOCAL _ver_user, _last_ver
   LOCAL _versions
   LOCAL cVerUser

   IF to_myself == NIL
      to_myself := .F.
   ENDIF

   IF skip_semaphore_sync( table )
      RETURN .F.
   ENDIF

   log_write( "START: update semaphore version after push", 7 )

   _tbl := "sem." + Lower( table )
   _versions := get_semaphore_version_h( table )

   _last_ver := _versions[ "last_version" ]

   IF _last_ver < 0
      _last_ver := 1
   ENDIF

   _ver_user := _last_ver
   ++ _ver_user
   cVerUser := AllTrim( Str( _ver_user ) )

   insert_semaphore_if_not_exists( table )

   _qry := ""

   IF !to_myself
      // setuj moju verziju ako ne zelim sebe refreshirati
      _qry := "UPDATE " + _tbl + " SET version=" + cVerUser + " WHERE user_code=" + sql_quote( _user ) + "; "
   ENDIF

   // svim userima setuj last_trans_version
   _qry += "UPDATE " + _tbl + " SET last_trans_version=" + cVerUser + "; "
   // kod svih usera verzija ne moze biti veca od posljednje
   _qry += "UPDATE " + _tbl + " SET version=" + cVerUser + " WHERE version > " + cVerUser + ";"
   run_sql_query( _qry )

   log_write( "END: update semaphore version after push user: " + _user + ", tabela: " + _tbl + ", last_ver=" + Str( _ver_user ), 7 )

   RETURN _ver_user



// ----------------------------------------------------------------------
// nuliraj ids-ove, postavi da je verzija semafora = posljednja verzija
// ------------------------------------------------------------------------
FUNCTION nuliraj_ids_and_update_my_semaphore_ver( table )

   LOCAL _tbl
   LOCAL _ret
   LOCAL _user := f18_user()
   LOCAL _qry

   insert_semaphore_if_not_exists( table )

   log_write( "START: nuliraj ids-ove - user: " + _user, 7 )

   _tbl := "sem." + Lower( table )
   _qry := "UPDATE " + _tbl + " SET " + ;
      " ids=NULL , dat=NULL," + ;
      " version=last_trans_version" + ;
      " WHERE user_code =" + sql_quote( _user )

   _ret := run_sql_query( _qry )

   log_write( "END: nuliraj ids-ove - user: " + _user, 7 )

   RETURN _ret


/*
   TODO: ukloniti ovo ako ne trebamo _id_full
   IF ( _result == 0 )

      // user po prvi put radi sa tabelom semafora, iniciraj full sync
      _id_full := "ARRAY[" + sql_quote( "#F" ) + "]"

      _qry := "INSERT INTO " + _tbl + "(user_code, version, last_trans_version, ids) " + ;
         "VALUES(" + sql_quote( _user )  + ", " + cVerUser + ", (select max(last_trans_version) from " +  _tbl + "), " + _id_full + ")"

      _ret := run_sql_query( _qry )

      log_write( "Dodajem novu stavku semafora za tabelu: " + _tbl + " user: " + _user + " ver.user: " + cVerUser, 7 )

   ENDIF
*/

FUNCTION insert_semaphore_if_not_exists( cTable, lIgnoreChk0 )

   LOCAL nCnt
   LOCAL _user := f18_user()
   LOCAL _qry
   LOCAL _ret
   LOCAL cSqlTbl

   IF skip_semaphore_sync( cTable )
      RETURN .F.
   ENDIF

   hb_default( @lIgnoreChk0, .F. )

   cSqlTbl := "sem." + Lower( cTable )

   IF !lIgnoreChk0 .AND. is_chk0( cTable )
      RETURN .F.
   ENDIF

   nCnt := table_count( cSqlTbl, "user_code=" + sql_quote( _user ) )

   IF ( nCnt == 0 )
      _qry := "INSERT INTO " + cSqlTbl + "(user_code, last_trans_version, version, algorithm) " + ;
         "VALUES(" + sql_quote( _user )  + ", 0, -1, 'free')"
      _ret := run_sql_query( _qry )

      RETURN !sql_error_in_query( _ret, "INSERT" )

   ENDIF

   RETURN .T.


FUNCTION in_dbf_refresh( cTable, lRefresh )

   LOCAL hConnParams := my_server_params()
   LOCAL lRet := .F.

#ifdef F18_DEBUG_THREAD

   ?E "in_dbf_refresh start", cTable, lRefresh
#endif

   cTable := get_a_dbf_rec( cTable, .T. )[ "table" ]

   IF !hb_HHasKey( hConnParams, "database" )
      RETURN .F.
   ENDIF

   IF !hb_HHasKey( s_hInDbfRefresh, hConnParams[ "database" ] )
      IF hb_mutexLock( s_mtxMutex )
         s_hInDbfRefresh[ hConnParams[ "database" ] ] := hb_Hash()
         hb_mutexUnlock( s_mtxMutex )
      ELSE
         RETURN .F.
      ENDIF
   ENDIF

   IF hb_mutexLock( s_mtxMutex )
      IF ! hb_HHasKey( s_hInDbfRefresh[ hConnParams[ "database" ] ], cTable )
         s_hInDbfRefresh[ hConnParams[ "database" ] ][ cTable ]  := .F.
      ENDIF

      IF lRefresh != NIL
         s_hInDbfRefresh[ hConnParams[ "database" ] ][ cTable ] := lRefresh
      ENDIF

      lRet := s_hInDbfRefresh[ hConnParams[ "database" ] ][ cTable ]
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN lRet


FUNCTION set_last_refresh( cTable )

   IF hb_mutexLock( s_mtxMutex )
      IF cTable <> NIL
         s_aLastRefresh[ 1 ] := cTable
         s_aLastRefresh[ 2 ] := Seconds()
      ENDIF
      hb_mutexLock( s_mtxMutex )
   ENDIF

   RETURN s_aLastRefresh


FUNCTION is_last_refresh_before( cTable, nSeconds )

#ifdef F18_DEBUG_THREAD

   ?E "is_last_refresh_before", cTable, nSeconds
#endif

   IF cTable ==  s_aLastRefresh[ 1 ] .AND. ( Seconds() - s_aLastRefresh[ 2 ] )  < nSeconds
      RETURN .T.
   ENDIF

   RETURN .F.




PROCEDURE thread_dbf_refresh( cTable )


   IF open_thread( "dbf_refresh: " + cTable, .T. )
      ErrorBlock( {| objError, lShowreport, lQuit | GlobalErrorHandler( objError, lShowReport, lQuit ) } )
      dbf_refresh( cTable )
      close_thread( "dbf_refresh: " + cTable )
   ELSE
      ?E "init thread dbf_refersh neuspjesan: ", cTable
   ENDIF

   RETURN


FUNCTION we_need_dbf_refresh( cTable )

   LOCAL aDbfRec

   IF cTable == NIL
      IF !Used() .OR. ( rddName() $  "SQLMIX#ARRAYRDD" )
         RETURN .F.
      ENDIF
      cTable := Alias()

      IF Left( cTable, 6 ) == "SYNC__"
         RETURN .F.
      ENDIF
   ENDIF

   aDbfRec := get_a_dbf_rec( cTable, .T. )
   cTable := aDbfRec[ "table" ]

   IF is_last_refresh_before( cTable, MIN_LAST_REFRESH_SEC )
#ifdef F18_DEBUG_THREAD
      ?E  cTable, "last refresh of table < ", MIN_LAST_REFRESH_SEC, " sec before"
#endif
      RETURN .F.
   ENDIF

   IF in_dbf_refresh( cTable )
#ifdef F18_DEBUG_THREAD
      ?E  cTable, "in_dbf_refresh"
#endif
      RETURN .F.
   ENDIF

   IF skip_semaphore_sync( cTable ) // tabela nije sem-shared
      RETURN .F.
   ENDIF

   IF !File( f18_ime_dbf( aDbfRec ) )
#ifdef F18_DEBUG_THREAD
      ?E  cTable, "dbf tabele nema"
#endif
      RETURN .F.
   ENDIF

   RETURN .T.


FUNCTION dbf_refresh( cTable )

   LOCAL aDbfRec
   LOCAL hVersions

   IF !we_need_dbf_refresh( @cTable )
      RETURN .F.
   ENDIF

   in_dbf_refresh( cTable, .T. )

   ?E "going to refresh: " + cTable

   dbf_refresh_0( cTable )

   PushWA()
   hVersions := get_semaphore_version_h( cTable )
   IF ( hVersions[ "version" ] == -1 )
      update_dbf_from_server( cTable, "FULL" )
      hVersions := get_semaphore_version_h( cTable )
   ENDIF

   IF ( hVersions[ "version" ] < hVersions[ 'last_version' ] )
      update_dbf_from_server( cTable, "IDS" )
   ENDIF
   PopWa()

   set_last_refresh( cTable )
   in_dbf_refresh( cTable, .F. )

   RETURN .T.




STATIC FUNCTION dbf_refresh_0( cTable )

   LOCAL cMsg1, cMsg2
   LOCAL nCntSql, nCntDbf, nDeleted
   LOCAL lRet := .T.
   LOCAL aDbfRec := get_a_dbf_rec( cTable )

   IF is_chk0( aDbfRec[ "table" ] )
#ifdef F18_DEBUG_SYNC
      ?E "chk0 already set: " + aDbfRec[ "table" ]
#endif
      RETURN .F.
   ENDIF

   cMsg1 := "START chk0 not set, start dbf_refresh_0: " + aDbfRec[ "alias" ] + " / " + aDbfRec[ "table" ]
   set_a_dbf_rec_chk0( aDbfRec[ "table" ] )
#ifdef F18_DEBUG_SYNC
   ?E cMsg1
#endif

   nCntSql := table_count( aDbfRec[ "table" ] )
   dbf_open_temp_and_count( aDbfRec, nCntSql, @nCntDbf, @nDeleted )

   cMsg1 := "dbf_refresh_0_nakon sync: " +  aDbfRec[ "alias" ] + " / " + aDbfRec[ "table" ]
   cMsg2 := "cnt_sql: " + AllTrim( Str( nCntSql, 0 ) ) + " cnt_dbf: " + AllTrim( Str( nCntDbf, 0 ) ) + " del_dbf: " + AllTrim( Str( nDeleted, 0 ) )
#ifdef F18_DEBUG_SYNC
   ?E cMsg1
   ?E cMsg2
#endif

   IF check_recno_and_fix( aDbfRec[ "table" ], nCntSql, nCntDbf - nDeleted )

      cMsg1 := aDbfRec[ "alias" ] + " / " + aDbfRec[ "table" ]
      cMsg2 := "cnt_sql: " + AllTrim( Str( nCntSql, 0 ) ) + " cnt_dbf: " + AllTrim( Str( nCntDbf, 0 ) ) + " del_dbf: " + AllTrim( Str( nDeleted, 0 ) )
#ifdef F18_DEBUG_SYNC
      ?E cMsg1
      ?E cMsg2
#endif
      IF hocu_li_pakovati_dbf( nCntDbf, nDeleted )
         pakuj_dbf( aDbfRec, .T. )
      ENDIF

      set_a_dbf_rec_chk0( aDbfRec[ "table" ] )
      RETURN .T.

   ELSE
      unset_a_dbf_rec_chk0( aDbfRec[ "table" ] )
   ENDIF

   RETURN .F.


FUNCTION skip_semaphore_sync( cTable )

   LOCAL hRec

#ifdef F18_DEBUG_THREAD

   ?E "skip_semaphore_sync", cTable
#endif

   cTable := Lower( cTable )

   IF Left( cTable, 6 ) == "SYNC__"
      RETURN .T.
   ENDIF

   hRec := get_a_dbf_rec( cTable, .T. )

   IF hRec[ "sql" ] .OR. hRec[ "temp" ]
      RETURN .T.
   ENDIF

   RETURN .F.


INIT PROCEDURE init_semaphores()

   IF s_mtxMutex == NIL
      s_mtxMutex := hb_mutexCreate()
   ENDIF

   IF s_hInDbfRefresh == NIL
      s_hInDbfRefresh := hb_Hash()
   ENDIF

   RETURN
