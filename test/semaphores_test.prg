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

#define F_TEST_SEM_1 401

function dbf_test()
local _i
local _ime_f
local _dbf_struct := {}
local _field_10

_ime_f := "test_sem_1"

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  AADD(gaDBFs, { F_TEST_SEM_1,  UPPER(_ime_f),  _ime_f, {|alg| test_sem_1_from_sql_server(alg) }, "IDS", {"ID"}, {|x| "ID=" + _sql_quote(x["id"]) }, "ID" )
endif

AADD(_dbf_struct,      { 'ID' ,  'C' ,   1 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })
       
DBCREATE2(_ime_f, _dbf_structG)

CREATE_INDEX("ID",  "id", _ime_f)  
CREATE_INDEX("NAZ", "naz", _ime_f)

my_usex(_ime_f)

return .t.

// -----------------------------------------
// -----------------------------------------
function test_sem_1_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "test_sem_1"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM
	if get_semaphore_status( _tbl ) == "lock"
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif
next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TEST_SEM_1, {"id", "naz"})

lock_semaphore( _tbl, "free" )

return _result


