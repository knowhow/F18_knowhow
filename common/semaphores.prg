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

#include "fmk.ch"
#include "common.ch"


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
   LOCAL _err_msg, _msg
   LOCAL _server := pg_server()
   LOCAL _user   := f18_user()
   LOCAL _user_locked := ""
   LOCAL cSemaphoreStatus

   IF skip_semaphore( table)
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

         RETURN .F.
      ENDIF

   ENDDO

   // svi useri su lockovani
   _qry := "UPDATE fmk.semaphores_" + table + " SET algorithm=" + _sql_quote( status ) + ", last_trans_user_code=" + _sql_quote( _user ) + "; "

   IF ( status == "lock" )
      _qry += "UPDATE fmk.semaphores_" + table + " SET algorithm='locked_by_me' WHERE user_code=" + _sql_quote( _user ) + ";"
   ENDIF

   _ret := _sql_query( _server, _qry )

   log_write( "table: " + table + ", status:" + status + " - END", 7 )

   IF ValType( _ret ) == "L"
      log_write( "qry error: " + _qry, 2 )
      RaiseError( _qry )
   ENDIF

   RETURN .T.


FUNCTION get_semaphore_locked_by_me_status_user( table )

   LOCAL _qry
   LOCAL _ret
   LOCAL _server := pg_server()

   _qry := "SELECT user_code FROM fmk.semaphores_" + table + " WHERE algorithm = 'locked_by_me'"
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

   IF skip_semaphore( table)
        RETURN "free" 
   ENDIF
   
   _qry := "SELECT algorithm FROM fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote( _user )
   _ret := _sql_query( _server, _qry )

   IF ValType( _ret ) == "L"
      RETURN "unknown"
   ENDIF

   RETURN AllTrim( _ret:FieldGet( 1 ) )



FUNCTION last_semaphore_version( table )

   LOCAL _qry
   LOCAL _ret
   LOCAL _server := pg_server()

   _qry := "SELECT last_trans_version FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote( f18_user() )
   _ret := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _ret )
      RETURN -1
   ENDIF

   RETURN _ret:FieldGet( 1 )



FUNCTION sql_query_bez_zapisa( ret )

   SWITCH ValType( ret )
   CASE "L"
      RETURN .T.
   CASE "O"
      // TPQQuery nema nijednog zapisa
      IF ret:lEof .AND. ret:lBof
         RETURN .T.
      ENDIF
      EXIT
   OTHERWISE
      MsgBeep( "sql_query ? ret valtype: " + ValType( ret ) )
      QUIT_1
   END SWITCH

   RETURN .F.


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


   IF skip_semaphore( table)
        RETURN 1
   ENDIF

   // trebam last_version
   IF last == NIL
      last := .F.
   ENDIF

   _tbl := "fmk.semaphores_" + Lower( table )

   _qry := "SELECT "
   IF last
      _qry +=  "MAX(last_trans_version) AS ver"
   ELSE
      _qry += "version as ver"
   ENDIF
   _qry += " FROM " + _tbl + " WHERE user_code=" + _sql_quote( _user )

   _qry += " UNION SELECT -1 ORDER BY ver DESC LIMIT 1"

   _tbl_obj := _sql_query( _server, _qry )

   IF ValType( _tbl_obj ) == "L"
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

   IF skip_semaphore( table)
        _ret[ "version" ] := 1
        _ret[ "last_version" ] := 1
        RETURN _ret
   ENDIF


   _tbl := "fmk.semaphores_" + Lower( table )

   _qry := "SELECT version, last_trans_version AS last_version"
   _qry += " FROM " + _tbl + " WHERE user_code=" + _sql_quote( _user )
   _qry += " UNION SELECT -1, -1 ORDER BY version DESC LIMIT 1"

   _tbl_obj := _sql_query( _server, _qry )

   IF ValType( _tbl_obj ) == "L"
      _msg = "problem sa:" + _qry
      log_write( _msg, 2 )
      MsgBeep( 2 )
      QUIT_1
   ENDIF

   _ret[ "version" ]      := _tbl_obj:FieldGet( 1 )
   _ret[ "last_version" ] := _tbl_obj:FieldGet( 2 )

   RETURN _ret




// ------------------------------------------
// reset_semaphore_version( "konto")
// set version to -1
// -------------------------------------------
FUNCTION reset_semaphore_version( table )

   LOCAL _ret
   LOCAL _result
   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()
   LOCAL _server := pg_server()

   IF skip_semaphore( table)
        RETURN .T.
   ENDIF


   _tbl := "fmk.semaphores_" + Lower( table )
   _result := table_count( _tbl, "user_code=" + _sql_quote( _user ) )

   IF ( _result == 0 )
      log_write( "reset semaphore " + _tbl + " insert ", 1 )
      _qry := "INSERT INTO " + _tbl + "(user_code, last_trans_version, version, algorithm) " + ;
         "VALUES(" + _sql_quote( _user )  + ", 0, -1, 'free')"
   ELSE
      log_write( "reset semaphore " + _tbl + " update ", 1 )
      _qry := "UPDATE " + _tbl + " SET version=-1, last_trans_version=(CASE WHEN last_trans_version IS NULL THEN 0 ELSE last_trans_version END) WHERE user_code =" + _sql_quote( _user )
   ENDIF

   _ret := _sql_query( _server, _qry )
   _qry := "SELECT version from " + _tbl + " WHERE user_code =" + _sql_quote( _user )
   _ret := _sql_query( _server, _qry )

   log_write( "reset semaphore, select version" + Str( _ret:FieldGet( 1 ) ), 7 )

   RETURN _ret:FieldGet( 1 )


// ---------------------------------------
// date algoritam
// ---------------------------------------
FUNCTION push_dat_to_semaphore( table, date )

   LOCAL _tbl
   LOCAL _result
   LOCAL _ret
   LOCAL _qry
   LOCAL _sql_ids
   LOCAL _i
   LOCAL _user := f18_user()
   LOCAL _server := pg_server()

   IF skip_semaphore( table)
        RETURN .F.
   ENDIF


   _tbl := "fmk.semaphores_" + table
   _result := table_count( _tbl, "user_code=" + _sql_quote( _user ) )

   _qry := "UPDATE " + _tbl + ;
      " SET dat=" + _sql_quote( date ) + ;
      " WHERE user_code =" + _sql_quote( _user )
   _ret := _sql_query( _server, _qry )

   RETURN _ret



// ---------------------------------------
// vrati date za DATE algoritam
// ---------------------------------------
FUNCTION get_dat_from_semaphore( table )

   LOCAL _server :=  pg_server()
   LOCAL _tbl
   LOCAL _tbl_obj
   LOCAL _qry
   LOCAL _dat

   _tbl := "fmk.semaphores_" + table

   _qry := "SELECT dat FROM " + _tbl + " WHERE user_code=" + _sql_quote( f18_user() )
   _tbl_obj := _sql_query( _server, _qry )
   IF ValType( _tbl_obj ) == "L"
      MsgBeep( "problem sa:" + _qry )
      QUIT_1
   ENDIF

   _dat := oTable:FieldGet( 1 )

   RETURN _dat


// ------------------------------
// broj redova za tabelu
// --------------------------------
FUNCTION table_count( table, condition )

   LOCAL _table_obj
   LOCAL _result
   LOCAL _qry
   LOCAL _server := pg_server()

   // provjeri prvo da li postoji uopšte ovaj site zapis
   _qry := "SELECT COUNT(*) FROM " + table

   IF condition != NIL
      _qry += " WHERE " + condition
   ENDIF

   _table_obj := _sql_query( _server, _qry )

   log_write( "table: " + table + " count = " + AllTrim( Str( _table_obj:FieldGet( 1 ) ) ), 8 )

   IF ValType( _table_obj ) == "L"
      log_write( "table_count(), error: " + _qry, 1 )
      QUIT_1
   ENDIF

   _result := _table_obj:FieldGet( 1 )

   RETURN _result




// --------------------------------------------------------------------------------
// napuni dbf tabelu sa podacima sa servera
// dbf_tabela mora biti otvorena i u tekucoj WA
// --------------------------------------------------------------------------------
FUNCTION fill_dbf_from_server( dbf_table, sql_query, sql_fetch_time, dbf_write_time, lShowInfo )

   LOCAL _counter := 0
   LOCAL _i, _fld
   LOCAL _server := pg_server()
   LOCAL _qry_obj
   LOCAL _retry := 3
   LOCAL _a_dbf_rec
   LOCAL _dbf_alias, _dbf_fields

   IF lShowInfo == NIL
      lShowInfo := .F.
   ENDIF

   _a_dbf_rec := get_a_dbf_rec( dbf_table )
   _dbf_alias := _a_dbf_rec[ "alias" ]
   _dbf_fields := _a_dbf_rec[ "dbf_fields" ]

   sql_fetch_time := Seconds()
   _qry_obj := run_sql_query( sql_query, _retry )
   sql_fetch_time := Seconds() - sql_fetch_time

   IF !Used() .OR. ( _dbf_alias != Alias() )
      Alert( ProcName( 1 ) + "(" + AllTrim( Str( ProcLine( 1 ) ) ) + ") " + dbf_table + " dbf mora biti otvoren !" )
      log_write( "ERR - tekuci dbf alias je " + Alias() + " a treba biti " + _dbf_alias, 2 )
      QUIT_1
   ENDIF

   log_write( "fill_dbf_from_server(), poceo", 9 )

   dbf_write_time := Seconds()

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
             @ m_x + 7, m_y + 2 SAY8 "synchro '" + dbf_table + "' broj obrađenih zapisa: " + AllTrim( Str( _counter ) )
          ENDIF
      ENDIF

      _qry_obj:Skip()


   ENDDO

   log_write( "fill_dbf_from_server(), table: " + dbf_table + ", count: " + AllTrim( Str( _counter ) ), 7 )

   log_write( "fill_dbf_from_server(), zavrsio", 9 )

   dbf_write_time := Seconds() - dbf_write_time

   RETURN




// --------------------------------------------------------------------
// da li je polje u blacklisti
// --------------------------------------------------------------------
FUNCTION field_in_blacklist( field_name, blacklist )

   LOCAL _ok := .F.
   LOCAL _scan

   // mozda nije definisana blacklista
   IF blacklist == NIL
      RETURN _ok
   ENDIF

   IF AScan( blacklist, {|val| val == field_name } ) > 0
      _ok := .T.
   ENDIF

   RETURN _ok


/*
   update_semaphore_version_after_push( "konto" )
*/
FUNCTION update_semaphore_version_after_push( table, to_myself )

   LOCAL _ret
   LOCAL _result
   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()
   LOCAL _last
   LOCAL _server := my_server()
   LOCAL _ver_user, _last_ver, _id_full
   LOCAL _versions
   LOCAL _a_dbf_rec
   LOCAL _ret_ver
   LOCAL cVerUser

   IF to_myself == NIL
      to_myself := .F.
   ENDIF

   IF skip_semaphore( table)
        RETURN .F.
   ENDIF

   log_write( "START: update semaphore version after push", 7 )

   _a_dbf_rec := get_a_dbf_rec( table )

   _tbl := "fmk.semaphores_" + Lower( table )
   _result := table_count( _tbl, "user_code=" + _sql_quote( _user ) )
   _versions := get_semaphore_version_h( table )

   _last_ver := _versions[ "last_version" ]
   _version  := _versions[ "version" ]

   IF _last_ver < 0
      _last_ver := 1
   ENDIF

   _ver_user := _last_ver
   ++ _ver_user
   cVerUser := ALLTRIM( STR( _ver_user ) )

   IF ( _result == 0 )

      // user po prvi put radi sa tabelom semafora, iniciraj full sync
      _id_full := "ARRAY[" + _sql_quote( "#F" ) + "]"

      _qry := "INSERT INTO " + _tbl + "(user_code, version, last_trans_version, ids) " + ;
         "VALUES(" + _sql_quote( _user )  + ", " + cVerUser + ", (select max(last_trans_version) from " +  _tbl + "), " + _id_full + ")"

      _ret := _sql_query( _server, _qry )

      log_write( "Dodajem novu stavku semafora za tabelu: " + _tbl + " user: " + _user + " ver.user: " + cVerUser, 7 )

   ENDIF

   _qry := ""

   IF !to_myself
      // setuj moju verziju ako ne zelim sebe refreshirati
      _qry := "UPDATE " + _tbl + " SET version=" + cVerUser + " WHERE user_code=" + _sql_quote( _user ) + "; "
   ENDIF

   // svim userima setuj last_trans_version
   _qry += "UPDATE " + _tbl + " SET last_trans_version=" + cVerUser + "; "
   // kod svih usera verzija ne moze biti veca od posljednje
   _qry += "UPDATE " + _tbl + " SET version=" + cVerUser + ;
      " WHERE version > " + cVerUser + ";"
   _ret := _sql_query( _server, _qry )

   log_write( "END: update semaphore version after push user: " + _user + ", tabela: " + _tbl + ", last_ver=" + Str( _ver_user ), 7 )

   RETURN _ver_user




// ----------------------------------------------------------------------
// nuliraj ids-ove, postavi da je verzija semafora = posljednja verzija
// ------------------------------------------------------------------------
FUNCTION nuliraj_ids_and_update_my_semaphore_ver( table )

   LOCAL _tbl, _count
   LOCAL _ret
   LOCAL _user := f18_user()
   LOCAL _server := pg_server()
   LOCAL _free
   LOCAL _sem_status

   IF skip_semaphore( table)
        RETURN .F.
   ENDIF

   log_write( "START: nuliraj ids-ove - user: " + _user, 7 )

   _tbl := "fmk.semaphores_" + Lower( table )
   _qry := "UPDATE " + _tbl + " SET "
   _qry += " ids=NULL , dat=NULL,"
   _qry += " version=last_trans_version"
   _qry += " WHERE user_code =" + _sql_quote( _user )
	
   _ret := _sql_query( _server, _qry )

   log_write( "END: nuliraj ids-ove - user: " + _user, 7 )

   RETURN _ret


STATIC FUNCTION skip_semaphore( table )

   table := LOWER( table )

   IF table == "sifk" .OR. table == "sifv"
        RETURN .T.
   ENDIF

   RETURN .F.

   
