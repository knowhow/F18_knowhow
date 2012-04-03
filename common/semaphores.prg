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

// ------------------------------------------
// status = "lock" (locked_by_me), "free"
// ------------------------------------------
function lock_semaphore(table, status)
local _qry
local _ret
local _i
local _err_msg
local _server := pg_server()
local _user   := f18_user()


// status se moze mijenjati samo ako neko drugi nije lock-ovao tabelu

_i := 0
while .t.

    _i++
	if get_semaphore_status(table) == "lock"
        _err_msg := ToStr(Time()) + " : table locked : " + table + " retry : " + STR(_i, 2) + "/" + STR(SEMAPHORE_LOCK_RETRY_NUM, 2)
		MsgO(_err_msg)
         log_write(_err_msg)
         hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
        MsgC()
    else
        if _i > 1
           _err_msg := ToStr(Time()) + " : table unlocked : " + table + " retry : " + STR(_i, 2) + "/" + STR(SEMAPHORE_LOCK_RETRY_NUM, 2)
           log_write(_err_msg)
        endif
        exit
    endif

    if (_i >= SEMAPHORE_LOCK_RETRY_NUM)
          _err_msg := "table " + table + " ostala lockovana nakon " + STR(SEMAPHORE_LOCK_RETRY_NUM, 2) + " pokusaja ?!"
          MsgBeep(_err_msg)
          log_write(_err_msg)
          return .f.
    endif
enddo

// svi useri su lockovani
_qry := "UPDATE fmk.semaphores_" + table + " SET algorithm=" + _sql_quote(status) + ", last_trans_user_code=" + _sql_quote(_user) + "; "

if status == "lock"
   _qry += "UPDATE fmk.semaphores_" + table + " SET algorithm='locked_by_me' WHERE user_code=" + _sql_quote(_user) + ";" 
endif

if gDebug > 9 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  // ERROR
  log_write("error :" + _qry)
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

_qry := "SELECT algorithm FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(_user)

if gDebug > 10 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
   log_write("error :" + _qry)
  QUIT
endif

return _ret:Fieldget( 1 )


// ------------------------------------
// ------------------------------------
function last_semaphore_version(table)
local _qry
local _ret
local _server:= pg_server()

_qry := "SELECT last_trans_version FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(f18_user())

if gDebug > 9 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  return -1
endif

return _ret:Fieldget( 1 )

/* ------------------------------------------
  get_semaphore_version( "konto", last = .t. => last_version)
  -------------------------------------------
*/
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
  log_write( RECI_GDJE_SAM0 + " tbl=" + _tbl + " user=" + _user + " table_count = " + STR(_result))
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

/* ------------------------------------------
  reset_semaphore_version( "konto")
  set version to -1
  -------------------------------------------
*/
function reset_semaphore_version(table)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _server := pg_server()

_tbl := "fmk.semaphores_" + LOWER(table)
_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

if (_result == 0)
   _qry := "INSERT INTO " + _tbl + "(user_code, version) " + ;
               "VALUES(" + _sql_quote(_user)  + ", -1 )"
else
    _qry := "UPDATE " + _tbl + " SET version=-1 WHERE user_code =" + _sql_quote(_user) 
endif
_ret := _sql_query( _server, _qry )

_qry := "SELECT version from " + _tbl + ;
           " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret:Fieldget(1)


/*
  ------------------------------------------
  update_semaphore_version( "konto")
  -------------------------------------------
*/
function update_semaphore_version(table, increment)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _last
LOCAL _server := pg_server()
LOCAL _ver_user, _last_ver, _id_full

_tbl := "fmk.semaphores_" + LOWER(table)

_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

_last_ver := get_semaphore_version(table, .t.)

if increment == NIL
   increment := .t.
endif

if _last_ver < 0
  _last_ver := 1
endif

_ver_user := _last_ver
if increment
   _ver_user++
endif

if (_result == 0)
   _id_full := "ARRAY[" + _sql_quote("<FULL>/") + "]"

   _qry := "INSERT INTO " + _tbl + "(user_code, version, last_trans_version, ids) " + ;
               "VALUES(" + _sql_quote(_user)  + ", " + STR(_ver_user) + ", (select max(last_trans_version) from " +  _tbl + "), " + _id_full + ")"
   _ret := _sql_query( _server, _qry)

else
    _qry := "UPDATE " + _tbl + ;
                " SET version=" + STR(_ver_user) + ", ids=NULL , dat=NULL WHERE user_code =" + _sql_quote(_user) 
    _ret := _sql_query( _server, _qry )

endif

if increment
    // svim setuj last_trans_version
    _qry := "UPDATE " + _tbl + " SET last_trans_version=" + STR(_last_ver + 1)  
    _ret := _sql_query( _server, _qry )

    // kod svih usera verzija ne moze biti veca od nLast + 1
    _qry := "UPDATE " + _tbl + " SET version=" + STR(_last_ver + 1) + ;
            " WHERE version > " + STR(_last_ver + 1)
    _ret := _sql_query( _server, _qry )
endif

_qry := "SELECT version from " + _tbl + " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

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
IF VALTYPE(_table_obj) == "L" 
    log_write( "problem sa query-jem: " + _qry )
    QUIT
ENDIF

_result := _table_obj:Fieldget(1)

RETURN _result

// -----------------------------------------------  
// napuni dbf tabelu sa podacima sa servera
// dbf_tabela mora biti otvorena i u tekucoj WA
// -----------------------------------------------  
function fill_dbf_from_server(dbf_table, sql_query)
local _counter := 0
local _i, _fld
local _server := pg_server()
local _qry_obj
local _retry := 3
local _a_dbf_rec
local _dbf_alias, _dbf_fields

_a_dbf_rec := get_a_dbf_rec(dbf_table)
_dbf_alias := _a_dbf_rec["alias"]
_dbf_fields := _a_dbf_rec["dbf_fields"]

_qry_obj := run_sql_query(sql_query, _retry ) 


if !USED() .or. ( _dbf_alias != ALIAS() )
   Alert(PROCNAME(1) + "(" + ALLTRIM(STR(PROCLINE(1))) + ") " + dbf_table + " dbf mora biti otvoren !")
   log_write( "ERR - tekuci dbf alias je " + ALIAS() + " a treba biti " + _dbf_alias)
   QUIT 
endif

DO WHILE !_qry_obj:EOF()

append blank

for _i := 1 to LEN(_dbf_fields)
    _fld := FIELDBLOCK(_dbf_fields[_i])
    if VALTYPE(EVAL(_fld)) $ "CM"
        EVAL(_fld, hb_Utf8ToStr(_qry_obj:FieldGet(_i)))
    else
        EVAL(_fld, _qry_obj:FieldGet(_i))
    endif
next 

_qry_obj:Skip()

++ _counter

ENDDO

log_write( dbf_table +  " updated from sql server rec_cnt: " + ALLTRIM(STR( _counter )) )

return

