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
#include "hbthread.ch"

#define F_TEST_SEM_1 9001
#define F_TEST_SEM_2 9002

function test_semaphores()
local _i
local _ime_f
local _dbf_struct := {}
local _server_params
local _qry
local _table_name, _alias
local _thread_2_id
local _rec

_ime_f := "test_sem_1"

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  AADD(gaDBFs, { F_TEST_SEM_1,  "TEST_SEM_1",  "test_sem_1", {|alg| test_sem_1_from_sql_server(alg) }, "IDS", {"id"}, {|x| sql_where_block("test_sem_1", x)}, "ID"})
endif

cre_t_1("test_sem_1", .t.)

TEST_LINE(login_as("admin"), .t.)

_qry := "drop table if exists fmk." + _ime_f + "; "
_qry += "create table " + _ime_f + "(" 
_qry += " id varchar(4) PRIMARY KEY, naz varchar(20)" 
_qry += "); " 
_qry += "GRANT ALL ON TABLE fmk." + _ime_f + " TO xtrole;"

run_sql_query(_qry)

create_semaphore(_ime_f)

TEST_LINE(login_as("test1"), .t.)


// ------------------------
_ime_f := "test_sem_2"
// ------------------------

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  AADD(gaDBFs, { F_TEST_SEM_2,  "TEST_SEM_2",  "test_sem_2", {|alg| test_sem_2_from_sql_server(alg) }, "IDS", { {"godina", 4}, {"mjesec", 2}, "oznaka" }, {|x| sql_where_block("test_sem_2", x)}, "IDN"})
endif

TEST_LINE(sql_concat_ids("test_sem_2"), "to_char(godina,'9999') || to_char(mjesec,'99') || oznaka")

_dbf_struct := {}
AADD(_dbf_struct,      { 'godina' ,  'N' ,   4 ,  0 })
AADD(_dbf_struct,      { 'mjesec' ,  'N' ,   2 ,  0 })
AADD(_dbf_struct,      { 'oznaka' ,  'C' ,   2 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })
       
DBCREATE2(_ime_f, _dbf_struct)

CREATE_INDEX("IDN", "STR(godina, 4) + STR(mjesec, 2) + oznaka", _ime_f)  
CREATE_INDEX("NAZ", "naz", _ime_f)

login_as("admin")

_qry := "drop table if exists fmk." + _ime_f + "; "
_qry += "create table " + _ime_f + "(" 
_qry += " godina int, mjesec int, oznaka varchar(2), naz varchar(10), PRIMARY KEY(godina, mjesec, oznaka)" 
_qry += "); " 
_qry += "GRANT ALL ON TABLE fmk." + _ime_f + " TO xtrole;"
run_sql_query(_qry)

create_semaphore(_ime_f)



upgrade_test_tables_semaphore_v2()

TEST_LINE( is_table_column_exists("test_sem_1", "b_year"), .t. )
TEST_LINE( is_table_column_exists("test_sem_1", "b_seasson"), .t. )
TEST_LINE( is_table_column_exists("test_sem_1", "org_id"), .t. )

TEST_LINE( is_table_column_exists("test_sem_2", "b_year"), .t. )




_alias := "test_sem_1"
_table_name := _alias
? "before reset", _table_name
reset_semaphore_version(_table_name)
? "after reset", _table_name

// -------------------------------
SELECT F_TEST_SEM_1
use

login_as("test2")
my_usex(_alias)
my_server_logout()


login_as("test1")
_thread_2_id  :=  hb_threadStart(  HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ), @_thread_2_fn() )

//hb_threadJoin( _thread_2_id )

my_usex(_alias)
TEST_LINE(ALIAS(), UPPER(_alias))

_rec := dbf_get_rec()

for _i := 1 to 500
  APPEND BLANK
  _rec["id"] := STR(_i, 4)
  _rec["naz"] := "naz " + STR(_i, 4)
  update_rec_server_and_dbf(_table_name, _rec)
next

TEST_LINE(reccount(), 500)


use

login_as("test3")
my_usex(_alias)
TEST_LINE(ALIAS(), UPPER(_alias))
use


login_as("test2")
my_usex(_alias)

// user: test3, ids = "{<FULL>/}"
use
login_as("test3")
my_usex(_alias)


// user: test2, ids = "{<FULL>/}"
use
login_as("test2")
my_usex(_alias)

use


/*
// -------------------------------
_alias := "test_sem_2"
_table_name := _alias

SELECT F_TEST_SEM_2
use

login_as("test3")
reset_semaphore_version(_table_name)
my_usex(_alias)
use

login_as("test2")
my_usex(_alias)
use

login_as("test1")
my_usex(_alias)
use

*/
return .t.

// -----------------------------------------
// -----------------------------------------
function test_sem_1_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "test_sem_1"

lock_semaphore( _tbl, "lock" )
_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TEST_SEM_1, {"id", "naz"})
lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function test_sem_2_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "test_sem_2"

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TEST_SEM_2, {"id", "naz"}, "IDN" )

return _result


// -------------------------------
// -------------------------------
static function login_as(user)
local _server_params

_server_params := my_server_params()

? "logout ", _server_params["user"]
my_server_logout()

_server_params["user"] := user
_server_params["password"] := user

my_server_params(_server_params)

if my_server_login()
   return .t.
else
   return .f.
endif

// ------------------------------------
// ------------------------------------
function create_semaphore(table_name)
local _qry, _ret

_qry := "drop table if exists fmk.semaphores_" + table_name + "; "
_qry += "create table fmk.semaphores_" + table_name + "("
_qry += "user_code varchar(20), b_year integer DEFAULT date_part('year', now())  CHECK (b_year > 1990 AND b_year < 2990), b_season integer DEFAULT 0, client_id integer DEFAULT 0, version bigint NOT NULL, last_trans_version bigint, last_trans_time timestamp DEFAULT now(), last_trans_user_code varchar(20), dat date, algorithm varchar(20) DEFAULT 'full', ids text[], PRIMARY KEY(user_code, b_year, b_season, client_id)"
_qry += "); " 
_qry += "GRANT ALL ON TABLE fmk.semaphores_" + table_name + " TO xtrole;"

_ret := run_sql_query(_qry)

if VALTYPE(_ret)  == "O"
   return .t.
else
   return .f.
endif

// -------------------------------------
// -------------------------------------
function upgrade_test_tables_semaphore_v2()
local _qry, _qry_obj, _table

// select tablename from pg_catalog.pg_tables where schemaname = 'fmk' and NOT ( (tablename LIKE 'semaphores_%') OR (tablename LIKE 'test_%') OR (tablename LIKE 'pkg%') OR (tablename = 'metric') OR (tablename = 'client_id')) order by tablename;

_qry := "select tablename from pg_catalog.pg_tables where schemaname = 'fmk' and (tablename LIKE 'test_%')  order by tablename;"

_qry_obj := run_sql_query(_qry)

DO WHILE ! _qry_obj:Eof()    
    _table := _qry_obj:FieldGet(1)
    alter_table_semaphore_v2(_table)

    _qry_obj:Skip()
ENDDO

_qry_obj:Close()

return .t.

// ---------------------------------
// ---------------------------------
function alter_table_semaphore_v2(table)
local _qry, _ret

_qry := "ALTER TABLE fmk." + table + " ADD COLUMN org_id integer DEFAULT 0,  ADD COLUMN b_year integer DEFAULT 0, ADD COLUMN b_seasson integer DEFAULT 0;"

_qry += "ALTER TABLE fmk." +  table + " DROP CONSTRAINT " + table + "_pkey, ADD PRIMARY KEY " + sql_primary_key(table) + ";"

_ret := run_sql_query(_qry)

if VALTYPE(_ret)  == "O"
   return .t.
else
   return .f.
endif

// -------------------------------------------
// -------------------------------------------
function is_table_column_exists(table, column)
local _qry, _ret

_qry := "SELECT count(column_name) FROM information_schema.columns WHERE table_name =" + _sql_quote(table) + " AND table_schema='fmk' AND column_name=" + _sql_quote(LOWER(column))

_ret := run_sql_query(_qry)

if VALTYPE(_ret)  == "O"
   return (_ret:FieldGet(1) == 1)
else
   return .f.
endif


// --------------------------------
// --------------------------------
function _thread_2_fn()
local _table_name := "test_sem_1"

log_handle(FCREATE(STRTRAN(F18_LOG_FILE, ".log", "_2.log")) )

log_write("--- thread 2: ----")

? "... thread_2_fn ..."
_get_server_params_from_config()

log_write(pp(my_server_params()))

if !login_as("test2")
  log_write("login thread neuspjesan !!!!")
  log_close()
  return .f.
endif
? pp(my_server_params())

log_write(ToStr(TIME()) + ": ... thread_2_fn ... lock")
lock_semaphore(_table_name, "lock")
//? "... thread_2_fn ... lock", my_user(), VALTYPE(my_server()), get_semaphore_version(_table_name)
//? "my_home", my_home(), "sempahore status:", get_semaphore_status(_table_name)

hb_IdleSleep(10)
log_write(ToStr(TIME()) + ": ... thread_2_fn ... unlock")
lock_semaphore(_table_name, "free")

my_server_logout()
return



