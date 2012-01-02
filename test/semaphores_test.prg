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

#define F_TEST_SEM_1 9001
#define F_TEST_SEM_2 9002

function test_semaphores()
local _i
local _ime_f
local _dbf_struct := {}
local _server_params
local _qry
local _table_name, _alias

// ------------------------
_ime_f := "test_sem_1"
// ------------------------

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  AADD(gaDBFs, { F_TEST_SEM_1,  UPPER(_ime_f),  _ime_f, {|alg| test_sem_1_from_sql_server(alg) }, "IDS", {"ID"}, {|x| sql_where_block(_ime_f, x)}, "ID"})
endif

AADD(_dbf_struct,      { 'ID' ,  'C' ,   1 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })
       
DBCREATE2(_ime_f, _dbf_struct)

CREATE_INDEX("ID",  "id", _ime_f)  
CREATE_INDEX("NAZ", "naz", _ime_f)

TEST_LINE(login_as("admin"), .t.)

_qry := "drop table if exists fmk." + _ime_f + "; "
_qry += "create table " + _ime_f + "(" 
_qry += " id varchar(2) PRIMARY KEY, naz varchar(10)" 
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
  AADD(gaDBFs, { F_TEST_SEM_2,  UPPER(_ime_f),  _ime_f, {|alg| test_sem_2_from_sql_server(alg) }, "IDS", { {"godina", 4}, {"mjesec", 2}, "oznaka" }, {|x| sql_where_block(_ime_f, x)}, "IDN"})
endif

TEST_LINE(sql_concat_ids("test_sem_2"), "to_char(godina,'9999') || to_char(mjesec,'99') || oznaka")


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


login_as("test1")

_alias := "test_sem_1"
_table_name := _alias
? "before reset", _table_name
reset_semaphore_version(_table_name)
? "after reset", _table_name

// -------------------------------
SELECT F_TEST_SEM_1
use

login_as("test2")
lock_semaphore(_table_name, "lock")

login_as("test1")
? "1) before my_usex", used(), alias(), "user=", my_server_params()["user"], _alias

my_usex(_alias)

login_as("test2")
lock_semaphore(_table_name, "free")

login_as("test1")
? "1b) before my_usex", used(), alias(), "user=", my_server_params()["user"], _alias

my_usex(_alias)

? "1) after my_usex", used(), alias(), "user=", my_server_params()["user"], _alias


use


? replicate("-", 100)

login_as("test2")
? "2) before my_usex", used(), alias(), "user=", my_server_params()["user"], _alias
my_usex(_alias)
? "2) after my_usex", used(), alias(), "user=", my_server_params()["user"], _alias


? replicate("-", 100)
use

? "3) before my_usex", used(), alias(), "user=", my_server_params()["user"], _alias
my_usex(_alias)
? "3) after my_usex", used(), alias(), "user=", my_server_params()["user"], _alias
? replicate("-", 100)

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

? "login ", _server_params["user"]

if my_server_login()
   return .t.
else
   return .f.
endif

// ------------------------------------
// ------------------------------------
function create_semaphore(table_name)
local _qry

_qry := "drop table if exists fmk.semaphores_" + table_name + "; "
_qry += "create table fmk.semaphores_" + table_name + "("
_qry += "user_code varchar(20), b_year integer DEFAULT date_part('year', now())  CHECK (b_year > 1990 AND b_year < 2990), b_season integer DEFAULT 0, client_id integer DEFAULT 0, version bigint NOT NULL, last_trans_version bigint, last_trans_time timestamp DEFAULT now(), last_trans_user_code varchar(20), dat date, algorithm varchar(20) DEFAULT 'full', ids text[], PRIMARY KEY(user_code, b_year, b_season, client_id)"
_qry += "); " 
_qry += "GRANT ALL ON TABLE fmk.semaphores_" + table_name + " TO xtrole;"

run_sql_query(_qry)

return .t.
