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
STATIC s_aLastRefresh := { "x", 0 }

MEMVAR m_x, m_y
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
   LOCAL _server := pg_server()
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

   _ret := _sql_query( _server, _qry )

   log_write( "table: " + table + ", status:" + status + " - END", 7 )

   IF !Empty( _ret:ErrorMsg() )
      log_write( "qry error: " + _qry + " : " + _ret:ErrorMsg(), 2 )
      RaiseError( _qry )
   ENDIF

   RETURN .T.


FUNCTION get_semaphore_locked_by_me_status_user( table )

   LOCAL _qry
   LOCAL _ret
   LOCAL _server := pg_server()

   _qry := "SELECT user_code FROM sem." + table + " WHERE algorithm = 'locked_by_me'"
   _ret := _sql_query( _server, _qry )

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
   LOCAL _server := pg_server()
   LOCAL _user   := f18_user()

   IF skip_semaphore_sync( table )
      RETURN "free"
   ENDIF

   _qry := "SELECT algorithm FROM sem." + table + " WHERE user_code=" + sql_quote( _user )
   _ret := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _ret )
      RETURN "unknown"
   ENDIF

   RETURN AllTrim( _ret:FieldGet( 1 ) )



FUNCTION last_semaphore_version( table )

   LOCAL _qry
   LOCAL _ret
   LOCAL _server := pg_server()

   _qry := "SELECT last_trans_version FROM  sem." + table + " WHERE user_code=" + sql_quote( f18_user() )
   _ret := _sql_query( _server, _qry )

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
   LOCAL _server := pg_server()
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

   _tbl_obj := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _tbl_obj )
      _msg = "problem sa:" + _qry
      log_write( _msg, 2 )
      MsgBeep( 2 )
      QUIT_1
   ENDIF

   _result := _tbl_obj:FieldGet( 1 )

   RETURN _result


// -------------------------------------------
// get_semaphore_version_h( "konto")
// -------------------------------------------
FUNCTION get_semaphore_version_h( table )

   LOCAL _tbl_obj
   LOCAL _qry
   LOCAL _tbl
   LOCAL _server := pg_server()
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

   _tbl_obj := _sql_query( _server, _qry )

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
   LOCAL _server := pg_server()

   IF skip_semaphore_sync( table )
      RETURN .T.
   ENDIF

   _tbl := "sem." + Lower( table )

   insert_semaphore_if_not_exists( table )

   log_write( "reset semaphore " + _tbl + " update ", 1 )
   _qry := "UPDATE " + _tbl + " SET version=-1, last_trans_version=(CASE WHEN last_trans_version IS NULL THEN 0 ELSE last_trans_version END) WHERE user_code =" + sql_quote( _user )
   _sql_query( _server, _qry )

   _qry := "SELECT version from " + _tbl + " WHERE user_code =" + sql_quote( _user )
   _ret := _sql_query( _server, _qry )

   log_write( "reset semaphore, select version" + Str( _ret:FieldGet( 1 ) ), 7 )

   RETURN _ret:FieldGet( 1 )


// ------------------------------
// broj redova za tabelu
// --------------------------------
FUNCTION table_count( table, condition )

   LOCAL _table_obj
   LOCAL _result
   LOCAL _qry
   LOCAL _server := pg_server()
   LOCAL cMsg

   // provjeri prvo da li postoji uopšte ovaj site zapis
   _qry := "SELECT COUNT(*) FROM " + table

   IF condition != NIL
      _qry += " WHERE " + condition
   ENDIF

   _table_obj := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _table_obj )
      cMsg := "table_count(), error: " + _qry + " msg: " + _table_obj:ErrorMsg()
      log_write( cMsg, 1 )
      Alert( cMsg )
      QUIT_1
   ENDIF

   log_write( "table: " + table + " count = " + AllTrim( Str( _table_obj:FieldGet( 1 ) ) ), 8 )


   _result := _table_obj:FieldGet( 1 )

   RETURN _result


/*
 napuni dbf tabelu sa podacima sa servera
  dbf_tabela mora biti otvorena i u tekucoj WA
*/

FUNCTION fill_dbf_from_server( dbf_table, sql_query, sql_fetch_time, dbf_write_time, lShowInfo )

   LOCAL _counter := 0
   LOCAL _i, _fld
   LOCAL _qry_obj
   LOCAL _retry := 3
   LOCAL _a_dbf_rec
   LOCAL _dbf_fields, cSyncalias, cFullDbf, cFullIdx

   IF lShowInfo == NIL
      lShowInfo := .F.
   ENDIF

   _a_dbf_rec := get_a_dbf_rec( dbf_table )
   _dbf_fields := _a_dbf_rec[ "dbf_fields" ]

   sql_fetch_time := Seconds()
   _qry_obj := run_sql_query( sql_query, _retry )
   sql_fetch_time := Seconds() - sql_fetch_time

   log_write( "fill_dbf_from_server START", 9 )

   IF log_level() > 5
      ?E "fill_dbf:", dbf_table, "a_dbf_rec dbf_fiels: ", pp( _dbf_fields )
   ENDIF

   dbf_write_time := Seconds()

   PushWa()

   cFullDbf := my_home() + _a_dbf_rec[ 'table' ]
   cFullIdx := ImeDbfCDX( cFullDbf )

   cSyncAlias := Upper( 'SYNC__' + _a_dbf_rec[ 'table' ] )
   IF Select( cSyncAlias ) == 0
      SELECT ( _a_dbf_rec[ 'wa' ] + 1000 )
      USE ( cFullDbf ) Alias ( cSyncAlias )  SHARED
      IF File( cFullIdx )
         dbSetIndex( cFullIdx )
      ENDIF
   ENDIF

   DO WHILE !_qry_obj:Eof()

      ++ _counter
      APPEND BLANK

      FOR _i := 1 TO Len( _dbf_fields )

         _fld := FieldBlock( _dbf_fields[ _i ] )

         IF ValType( Eval( _fld ) ) $ "CM"
            Eval( _fld, hb_UTF8ToStr( _qry_obj:FieldGet( _qry_obj:FieldPos( _dbf_fields[ _i ] ) ) ) )
         ELSE
            Eval( _fld, _qry_obj:FieldGet( _qry_obj:FieldPos( _dbf_fields[ _i ] ) ) )
         ENDIF

      NEXT

      IF lShowInfo
         IF _counter % 500 == 0
            ?E "synchro '" + dbf_table + "' broj obradjenih zapisa: " + AllTrim( Str( _counter ) )
         ENDIF
      ENDIF

      _qry_obj:Skip()

   ENDDO

   IF Select( cSyncAlias ) > 0
      USE
   ENDIF

   log_write( "fill_dbf_from_server: " + dbf_table + ", count: " + AllTrim( Str( _counter ) ), 7 )
   log_write( "fill_dbf_from_server END", 9 )

   dbf_write_time := Seconds() - dbf_write_time

   PopWa()

   RETURN .T.



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
   LOCAL _server := my_server()
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
   _sql_query( _server, _qry )

   log_write( "END: update semaphore version after push user: " + _user + ", tabela: " + _tbl + ", last_ver=" + Str( _ver_user ), 7 )

   RETURN _ver_user



// ----------------------------------------------------------------------
// nuliraj ids-ove, postavi da je verzija semafora = posljednja verzija
// ------------------------------------------------------------------------
FUNCTION nuliraj_ids_and_update_my_semaphore_ver( table )

   LOCAL _tbl
   LOCAL _ret
   LOCAL _user := f18_user()
   LOCAL _server := pg_server()
   LOCAL _qry

   insert_semaphore_if_not_exists( table )

   log_write( "START: nuliraj ids-ove - user: " + _user, 7 )

   _tbl := "sem." + Lower( table )
   _qry := "UPDATE " + _tbl + " SET " + ;
      " ids=NULL , dat=NULL," + ;
      " version=last_trans_version" + ;
      " WHERE user_code =" + sql_quote( _user )

   _ret := _sql_query( _server, _qry )

   log_write( "END: nuliraj ids-ove - user: " + _user, 7 )

   RETURN _ret


/*
   TODO: ukloniti ovo ako ne trebamo _id_full
   IF ( _result == 0 )

      // user po prvi put radi sa tabelom semafora, iniciraj full sync
      _id_full := "ARRAY[" + sql_quote( "#F" ) + "]"

      _qry := "INSERT INTO " + _tbl + "(user_code, version, last_trans_version, ids) " + ;
         "VALUES(" + sql_quote( _user )  + ", " + cVerUser + ", (select max(last_trans_version) from " +  _tbl + "), " + _id_full + ")"

      _ret := _sql_query( _server, _qry )

      log_write( "Dodajem novu stavku semafora za tabelu: " + _tbl + " user: " + _user + " ver.user: " + cVerUser, 7 )

   ENDIF
*/

FUNCTION insert_semaphore_if_not_exists( cTable, lIgnoreChk0 )

   LOCAL nCnt
   LOCAL _server := pg_server()
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
      _ret := _sql_query( _server, _qry )
      RETURN Empty( _ret:ErrorMsg() )
   ENDIF

   RETURN .T.


FUNCTION in_dbf_refresh( cTable, lRefresh )

   IF s_hInDbfRefresh == nil
      s_hInDbfRefresh := hb_Hash()
   ENDIF

   IF ! hb_HHasKey( s_hInDbfRefresh, cTable )
      s_hInDbfRefresh[ cTable ]  := .F.
   ENDIF

   IF lRefresh != nil
      s_hInDbfRefresh[ cTable ] := lRefresh
   ENDIF

   RETURN s_hInDbfRefresh[ cTable ]


FUNCTION set_last_refresh( cTable )

   IF cTable <> nil
      s_aLastRefresh[ 1 ] := cTable
      s_aLastRefresh[ 2 ] := Seconds()
   ENDIF

   RETURN s_aLastRefresh

FUNCTION is_last_refresh_before( cTable, nSeconds )

   IF cTable ==  s_aLastRefresh[ 1 ] .AND. ( Seconds() - s_aLastRefresh[ 2 ] )  < nSeconds
      RETURN .T.
   ENDIF

   RETURN .F.



PROCEDURE thread_dbf_refresh( cTable )

   PRIVATE m_x, m_y, normal, invert

   m_x := 0
   m_y := 0
   Normal := "B/W"
   Invert := "W/B"

#ifdef F18_DEBUG
   ?E ">>>>> START: thread_dbf_refresh:", cTable, "<<<<<"
#endif
   ErrorBlock( {| objError, lShowreport, lQuit | GlobalErrorHandler( objError, lShowReport, lQuit ) } )
   dbf_refresh( cTable )

#ifdef F18_DEBUG
   ?E "<<<<< END: thread_dbf_refresh:", cTable, " >>>>>"
#endif
   my_server_close()

   RETURN


FUNCTION dbf_refresh( cTable )

   LOCAL aDbfRec
   LOCAL hVersions

   IF  cTable == nil
      IF !Used() .OR. ( rddName() $  "SQLMIX#ARRAYRDD" )
         RETURN .F.
      ENDIF
      cTable := Alias()

      IF Left( cTable, 6 ) == "SYNC__"
         RETURN .F.
      ENDIF
   ENDIF

   aDbfRec := get_a_dbf_rec( cTable, .T. )


   IF in_dbf_refresh( aDbfRec[ 'table' ] )
#ifdef F18_DEBUG
      ?E  aDbfRec[ 'table' ], "in_dbf_refresh"
#endif
      RETURN .F.
   ENDIF


   IF skip_semaphore_sync( aDbfRec[ 'table' ] ) // tabela nije sem-shared
      RETURN .F.
   ENDIF

   IF !File( f18_ime_dbf( aDbfRec ) )
#ifdef F18_DEBUG
      ?E  aDbfRec[ 'table' ], "dbf tabele nema"
#endif
      RETURN .F.
   ENDIF

   IF is_last_refresh_before( aDbfRec[ 'table' ], 7 )
#ifdef F18_DEBUG
      ?E  aDbfRec[ 'table' ], "last refresh of table < 7 sec before"
#endif
      RETURN .F.
   ENDIF

   in_dbf_refresh( aDbfRec[ 'table' ], .T. )

#ifdef F18_DEBUG
   log_write( "going to refresh: " + aDbfRec[ 'table' ], 7 )
#endif

   PushWA()

   hVersions := get_semaphore_version_h( aDbfRec[ 'table' ] )
   IF ( hVersions[ "version" ] == -1 )
      update_dbf_from_server( aDbfRec[ 'table' ], "FULL" )
      hVersions := get_semaphore_version_h( aDbfRec[ 'table' ] )
   ENDIF

   IF ( hVersions[ 'version' ] < hVersions[ 'last_version' ] )
      update_dbf_from_server( aDbfRec[ 'table' ], "IDS" )
   ENDIF

   dbf_refresh_0( aDbfRec )

   PopWa()
   set_last_refresh( aDbfRec[ 'table' ] )

   in_dbf_refresh( aDbfRec[ 'table' ], .F. )

   RETURN .T.




STATIC FUNCTION dbf_refresh_0( aDbfRec )

   LOCAL cMsg1, cMsg2
   LOCAL nCntSql, nCntDbf, nDeleted

   IF is_chk0( aDbfRec[ "table" ] )
      log_write( "chk0 already set: " + aDbfRec[ "table" ], 9 )
      RETURN .F.
   ENDIF

   cMsg1 := "START chk0 not set, start dbf_refresh_0: " + aDbfRec[ "alias" ] + " / " + aDbfRec[ "table" ]

   ?E cMsg1
   log_write( "stanje dbf " +  cMsg1, 8 )

   nCntSql := table_count( aDbfRec[ "table" ] )
   dbf_open_temp_and_count( aDbfRec, nCntSql, @nCntDbf, @nDeleted )

   cMsg1 := "dbf_refresh_0_nakon sync: " +  aDbfRec[ "alias" ] + " / " + aDbfRec[ "table" ]
   cMsg2 := "cnt_sql: " + AllTrim( Str( nCntSql, 0 ) ) + " cnt_dbf: " + AllTrim( Str( nCntDbf, 0 ) ) + " del_dbf: " + AllTrim( Str( nDeleted, 0 ) )
   ?E cMsg1
   ?E cMsg2

   log_write( cMsg1 + " " + cMsg2, 8 )

   check_recno_and_fix( aDbfRec[ "table" ], nCntSql, nCntDbf - nDeleted )

   cMsg1 := aDbfRec[ "alias" ] + " / " + aDbfRec[ "table" ]
   cMsg2 := "cnt_sql: " + AllTrim( Str( nCntSql, 0 ) ) + " cnt_dbf: " + AllTrim( Str( nCntDbf, 0 ) ) + " del_dbf: " + AllTrim( Str( nDeleted, 0 ) )

   ?E cMsg1
   ?E cMsg2


   log_write( "END refresh_me " +  cMsg1 + " " + cMsg2, 8 )

   IF hocu_li_pakovati_dbf( nCntDbf, nDeleted )
      pakuj_dbf( aDbfRec, .T. )
   ENDIF

   set_a_dbf_rec_chk0( aDbfRec[ "table" ] )

   RETURN .T.


FUNCTION skip_semaphore_sync( table )

   LOCAL hRec

   table := Lower( table )

   IF Left( table, 6 ) == "SYNC__"
      RETURN .T.
   ENDIF

   hRec := get_a_dbf_rec( table, .T. )

   IF hRec[ 'sql' ] .OR. hRec[ 'temp' ]
      RETURN .T.
   ENDIF

   RETURN .F.
