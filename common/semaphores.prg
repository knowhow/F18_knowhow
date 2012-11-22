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

// --------------------------------------------------------------
// koristenje f18_lock_tables( arr ), f18_free_tables( arr )
// --------
//   if !f18_lock_tables( {"pos_doks", "pos_pos"} )
//       -- prekidamo operaciju
//   endif
//   
//   sql_table_update(nil, "BEGIN")
//   update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
//   f18_free_tables( {"pos_doks", "pos_pos"} )
//   sql_table_update(nil, "END")
//
//  ako imamo samo jednan zapis, jednu tabelu, transakcija i lockovanje
//  se desavaju unutar funkcije update_rec_server_and_dbf:
//
//   update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )
//
//  na isti nacin se koristi i u kombinaciji sa 
//      delete_rec_server_and_dbf()
// --------------------------------------------------------------

// -----------------------------------------------------
// lokovanje tabela zadatih u matrici a_tables
// a_tables := {"sifk", "sifv"...}
// -----------------------------------------------------
function f18_lock_tables( a_tables )
local _ok := .t.
local _i, _tbl 

PushWa()

if LEN( a_tables ) == NIL
    PopWA()
    return .f.
endif

if sql_table_update( nil, "BEGIN" )

    for _i := 1 to LEN( a_tables )
       _tbl := get_a_dbf_rec(a_tables[_i])["table"]
       _ok := _ok .and. lock_semaphore( _tbl, "lock" )
    next

    if _ok
        sql_table_update( nil, "END" ) 
        log_write( "uspjesno izvrsen lock tabela " + pp( a_tables ), 7 )

        // nakon uspjesnog lockovanja svih tabela preuzmi promjene od drugih korisnika
        my_use_semaphore_on()
        for _i := 1 to LEN( a_tables )
            _tbl := get_a_dbf_rec(a_tables[_i])["table"]
            // otvori tabelu i selectuj workarea koja je rezervisana za ovu tabelu
            my_use(_tbl, NIL, NIL, NIL, NIL, NIL, .t.)
        next
        my_use_semaphore_off()

    else
        sql_table_update( nil, "ROLLBACK")
    endif


else
    _ok := .f.
    log_write( "ERROR: nisam uspio napraviti lock tabela " + pp( a_tables ) , 2 )
endif

// pozicioniraj se na dbf prije ulaska u funkciju
PopWA()

return _ok

// -----------------------------------------------------
// unlokovanje tabela zadatih u matrici a_tables
// a_tables := {"sifk", "sifv"}
// -----------------------------------------------------
function f18_free_tables( a_tables )
local _ok := .t.
local _i, _tbl

if LEN( a_tables ) == NIL
    return .f.
endif

for _i := 1 to LEN( a_tables )
    _tbl := get_a_dbf_rec(a_tables[_i])["table"]
    lock_semaphore( _tbl, "free" )
next

log_write( "uspjesno izvrseno oslobadjanje tabela " + pp( a_tables ), 7 )

my_use_semaphore_on()

return _ok


// ------------------------------------------
// status = "lock" (locked_by_me), "free"
// ------------------------------------------
function lock_semaphore(table, status)
local _qry
local _ret
local _i
local _err_msg, _msg
local _server := pg_server()
local _user   := f18_user()

// status se moze mijenjati samo ako neko drugi nije lock-ovao tabelu

log_write( "table: " + table + ", status:" + status + " START" , 8 )

_i := 0

while .t.

    _i++

    if (get_semaphore_status(table) == "lock")
        _err_msg := ToStr(Time()) + " : table locked : " + table + " retry : " + STR(_i, 2) + "/" + STR(SEMAPHORE_LOCK_RETRY_NUM, 2)
        log_write( _err_msg, 2 )
        @ maxrows() - 1, maxcols() - 70 SAY PADR(_err_msg, 53)
        hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
        log_write( "call stack 1 " + PROCNAME(1) + ALLTRIM(STR(PROCLINE(1))), 2 )
        log_write( "call stack 2 " + PROCNAME(2) + ALLTRIM(STR(PROCLINE(2))), 2 )
        MsgC()
    else
        if _i > 1
            _err_msg := ToStr(Time()) + " : table unlocked : " + table + " retry : " + STR(_i, 2) + "/" + STR(SEMAPHORE_LOCK_RETRY_NUM, 2)
            @ maxrows() - 1, maxcols() - 70 SAY PADR(_err_msg, 53)
            log_write( _err_msg, 2 )
        endif
        exit
    endif

    if ( _i >= SEMAPHORE_LOCK_RETRY_NUM )
          _err_msg := "table " + table + " ostala lockovana nakon " + STR(SEMAPHORE_LOCK_RETRY_NUM, 2) + " pokusaja ##" + ;
                      "nasilno uklanjam lock !"
          MsgBeep(_err_msg)
          log_write( _err_msg, 2 )
          exit

          return .f.
    endif

enddo

// svi useri su lockovani
_qry := "UPDATE fmk.semaphores_" + table + " SET algorithm=" + _sql_quote(status) + ", last_trans_user_code=" + _sql_quote(_user) + "; "

if (status == "lock")
    _qry += "UPDATE fmk.semaphores_" + table + " SET algorithm='locked_by_me' WHERE user_code=" + _sql_quote(_user) + ";" 
endif

_ret := _sql_query( _server, _qry )

log_write( "table: " + table + ", status:" + status + " - END" , 7 )

if VALTYPE(_ret) == "L"
    // ERROR
    log_write("qry error: " + _qry, 7 )
    Alert("error :" + _qry)
    QUIT
endif

return .t.


// -----------------------------------
// -----------------------------------
function get_semaphore_status(table)
local _qry
local _ret
local _server := pg_server()
local _user   := f18_user()

_qry := "SELECT algorithm FROM fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(_user)
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
    log_write( "semafor status error: " + _qry, 6 )
    QUIT
endif

return ALLTRIM(_ret:Fieldget( 1 ))



// ------------------------------------
// ------------------------------------
function last_semaphore_version(table)
local _qry
local _ret
local _server:= pg_server()

_qry := "SELECT last_trans_version FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(f18_user())
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
    return -1
endif

return _ret:Fieldget( 1 )


// -----------------------------------------------------------------------
// get_semaphore_version( "konto", last = .t. => last_version)
// -----------------------------------------------------------------------
function get_semaphore_version(table, last)
LOCAL _tbl_obj
LOCAL _result
LOCAL _qry
local _tbl
local _server := pg_server()
local _user := f18_user()

// trebam last_version
if last == NIL
   last := .f.
endif

_tbl := "fmk.semaphores_" + LOWER(table)
_result := table_count( _tbl, "user_code=" + _sql_quote(_user)) 

if _result <> 1
    log_write( RECI_GDJE_SAM0 + " tbl=" + _tbl + " user=" + _user + " table_count = " + STR(_result), 7 )
    return -1
endif

_qry := "SELECT "
if last
    _qry +=  "MAX(last_trans_version) AS last_version"
else
    _qry += "version"
endif
_qry += " FROM " + _tbl + " WHERE user_code=" + _sql_quote(_user)

_tbl_obj := _sql_query( _server, _qry )

if VALTYPE(_tbl_obj) == "L" 
      MsgBeep( "problem sa:" + _qry)
      QUIT
endif

_result := _tbl_obj:Fieldget(1)

RETURN _result


// -------------------------------------------
// get_semaphore_version_h( "konto")
// -------------------------------------------
function get_semaphore_version_h(table)
LOCAL _tbl_obj
LOCAL _qry
local _tbl
local _server := pg_server()
local _user := f18_user()
local _ret := hb_hash()

_tbl := "fmk.semaphores_" + LOWER(table)
_result := table_count( _tbl, "user_code=" + _sql_quote(_user)) 

if _result <> 1
    log_write( _tbl + " " + _user + "count =" + STR(_result), 7 )

    _ret["version"]      := -1
    _ret["last_version"] := -1

    return _ret
endif

_qry := "SELECT version, last_trans_version AS last_version"
_qry += " FROM " + _tbl + " WHERE user_code=" + _sql_quote(_user)

_tbl_obj := _sql_query( _server, _qry )

if VALTYPE(_tbl_obj) == "L" 
    log_write( "problem sa: " + _tbl + " " + _user + " " + _qry )
    MsgBeep( "problem sa:" + _qry)
    QUIT
endif

_ret["version"]      := _tbl_obj:Fieldget(1)
_ret["last_version"] := _tbl_obj:Fieldget(2)

RETURN _ret




// ------------------------------------------
// reset_semaphore_version( "konto")
// set version to -1
// -------------------------------------------
function reset_semaphore_version(table)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _server := pg_server()

_tbl := "fmk.semaphores_" + LOWER(table)
_result := table_count( _tbl, "user_code=" + _sql_quote(_user)) 

log_write( "reset semaphore table: " + table + ", poceo", 9 )

if ( _result == 0 )
    _qry := "INSERT INTO " + _tbl + "(user_code, version) " + ;
               "VALUES(" + _sql_quote(_user)  + ", -1 )"
else
    _qry := "UPDATE " + _tbl + " SET version=-1 WHERE user_code =" + _sql_quote(_user) 
endif

log_write( "reset semaphore, set version = 1", 7 )
_ret := _sql_query( _server, _qry )

_qry := "SELECT version from " + _tbl + ;
           " WHERE user_code =" + _sql_quote(_user) 

_ret := _sql_query( _server, _qry )

log_write( "reset semaphore, select version" + STR( _ret:Fieldget(1) ) , 7 )
log_write( "reset semaphore, table: " + table + ", zavrsio", 9 )

return _ret:Fieldget(1)


//---------------------------------------
// date algoritam
//---------------------------------------
function push_dat_to_semaphore( table, date )
local _tbl
local _result
local _ret
local _qry
local _sql_ids
local _i
local _user := f18_user()
local _server := pg_server()

_tbl := "fmk.semaphores_" + table
_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

_qry := "UPDATE " + _tbl + ;
              " SET dat=" + _sql_quote(date) + ;
              " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret



//---------------------------------------
// vrati date za DATE algoritam
//---------------------------------------
function get_dat_from_semaphore(table)
local _server :=  pg_server()
local _tbl
local _tbl_obj
local _qry
local _dat

_tbl := "fmk.semaphores_" + table

_qry := "SELECT dat FROM " + _tbl + " WHERE user_code=" + _sql_quote(f18_user())
_tbl_obj := _sql_query( _server, _qry )
IF VALTYPE(_tbl_obj) == "L" 
      MsgBeep( "problem sa:" + _qry)
      QUIT
ENDIF

_dat := oTable:Fieldget(1)

RETURN _dat


// ------------------------------  
//  broj redova za tabelu
//  --------------------------------
function table_count(table, condition)
LOCAL _table_obj
LOCAL _result
LOCAL _qry
LOCAL _server := pg_server()
// provjeri prvo da li postoji uopšte ovaj site zapis
_qry := "SELECT COUNT(*) FROM " + table 

if condition != NIL
  _qry += " WHERE " + condition
endif

_table_obj := _sql_query( _server, _qry )

log_write( "table: " + table + " count = " + ALLTRIM(STR( _table_obj:Fieldget(1))) , 8 )

IF VALTYPE(_table_obj) == "L" 
    log_write( "table_count(), error: " + _qry, 1 )
    QUIT
ENDIF

_result := _table_obj:Fieldget(1)

RETURN _result



// --------------------------------------------------------------------------------
// napuni dbf tabelu sa podacima sa servera
// dbf_tabela mora biti otvorena i u tekucoj WA
// --------------------------------------------------------------------------------
function fill_dbf_from_server(dbf_table, sql_query, sql_fetch_time, dbf_write_time)
local _counter := 0
local _i, _fld
local _server := pg_server()
local _qry_obj
local _retry := 3
local _a_dbf_rec, _msg
local _dbf_alias, _dbf_fields

_a_dbf_rec := get_a_dbf_rec(dbf_table)
_dbf_alias := _a_dbf_rec["alias"]
_dbf_fields := _a_dbf_rec["dbf_fields"]

sql_fetch_time := SECONDS()
_qry_obj := run_sql_query(sql_query, _retry ) 
sql_fetch_time := SECONDS() - sql_fetch_time

if !USED() .or. ( _dbf_alias != ALIAS() )
    Alert(PROCNAME(1) + "(" + ALLTRIM(STR(PROCLINE(1))) + ") " + dbf_table + " dbf mora biti otvoren !")
    log_write( "ERR - tekuci dbf alias je " + ALIAS() + " a treba biti " + _dbf_alias, 2 )
    QUIT 
endif

log_write( "fill_dbf_from_server(), poceo", 9 )

dbf_write_time := SECONDS()

DO WHILE !_qry_obj:EOF()

    ++ _counter
    append blank

    for _i := 1 to LEN(_dbf_fields)
        _fld := FIELDBLOCK(_dbf_fields[_i])
        if VALTYPE(EVAL(_fld)) $ "CM"
            EVAL(_fld, hb_Utf8ToStr(_qry_obj:FieldGet(_i)))
        else
            EVAL(_fld, _qry_obj:FieldGet(_i))
        endif
    next 
                
    _msg := ToStr(Time()) + " : sync fill : " + dbf_table + " : " + ALLTRIM( STR( _counter ) )

    @ maxrows() - 1, maxcols() - 70 SAY PADR( _msg, 53 )
 
    _qry_obj:Skip()


ENDDO

log_write( "fill_dbf_from_server(), table: " + dbf_table + ", count: " + ALLTRIM( STR( _counter )), 7 )

log_write( "fill_dbf_from_server(), zavrsio", 9 )

dbf_write_time := SECONDS() - dbf_write_time
return


// --------------------------------------------------------------------------------------------
// update_semaphore_version_after_push( "konto")
//
// --------------------------------------------------------------------------------------------
function update_semaphore_version_after_push(table)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _last
LOCAL _server := pg_server()
LOCAL _ver_user, _last_ver, _id_full
local _versions
local _a_dbf_rec
local _ret_ver

log_write( "START: update semaphore version after push", 7)

_a_dbf_rec := get_a_dbf_rec(table)

_tbl := "fmk.semaphores_" + LOWER(table)
_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 
_versions := get_semaphore_version_h(table)

_last_ver := _versions["last_version"]
_version  := _versions["version"]

if _last_ver < 0
  _last_ver := 1
endif

_ver_user := _last_ver

_ver_user++

if ( _result == 0 )

    _id_full := "ARRAY[" + _sql_quote("#F") + "]"
    // user po prvi put radi sa tabelom semafora, iniciraj full sync
    _qry := "INSERT INTO " + _tbl + "(user_code, version, last_trans_version, ids) " + ;
               "VALUES(" + _sql_quote(_user)  + ", " + STR(_ver_user) + ", (select max(last_trans_version) from " +  _tbl + "), " + _id_full + ")"
    _ret := _sql_query( _server, _qry)

    log_write( "Dodajem novu stavku semafora za tabelu: " + _tbl + " user: " + _user + " ver.user: " + STR(_ver_user), 7)

endif

// svim userima setuj last_trans_version
_qry := "UPDATE " + _tbl + " SET last_trans_version=" + STR(_ver_user)
//_ret := _sql_query( _server, _qry )

// kod svih usera verzija ne moze biti veca od nLast + 1
_qry += ";"
_qry += "UPDATE " + _tbl + " SET version=" + STR(_ver_user) + ;
        " WHERE version > " + STR(_ver_user)

// dva sql statementa u jedan query provjeriti da li ovo radi pa izbrisati komentar
_ret := _sql_query( _server, _qry )

log_write( "END: update semaphore version after push " + _user + " last_ver=" + STR( _ver_user ), 7)

return _ver_user

// ----------------------------------------------------------------------
// nuliraj ids-ove, postavi da je verzija semafora = posljednja verzija
// ------------------------------------------------------------------------
function nuliraj_ids_and_update_my_semaphore_ver(table)
local _tbl
local _ret
local _user := f18_user()
local _server := pg_server()
local _free
local _sem_status

log_write( "START: nuliraj ids-ove - user: " + _user, 7)

_tbl := "fmk.semaphores_" + LOWER(table)

_qry := "UPDATE " + _tbl + " SET " 
_qry += " ids=NULL , dat=NULL, version=last_trans_version  WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

log_write( "END: nuliraj ids-ove - user: " + _user, 7)

return _ret


