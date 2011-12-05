/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "os.ch"
#include "common.ch"

// -----------------------------------------
// -----------------------------------------
function os_os_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "os_os"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_OS, ;
		{ "id", "naz", "idrj", ;
		"datum", "datotp", "opisotp", ;
		"idkonto", "kolicina", "jmj", "idam", "idrev", ;
		"nabvr", "otpvr", "amd", "amp", "revd", "revp", ;
		"k1", "k2", "k3", ;
		"opis", "brsoba", "idpartner" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function os_k1_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "os_k1"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_K1, ;
		{ "id", "naz" })

lock_semaphore( _tbl, "free" )

return _result




// -----------------------------------------
// -----------------------------------------
function os_promj_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "os_promj"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_PROMJ, ;
		{ "id", "opis", "datum", "tip", ;
			"nabvr", "otpvr", "amd", "amp", ;
			"revd", "revp" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function os_amort_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "os_amort"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_AMORT, ;
		{ "id", "naz", "iznos" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function os_reval_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "os_reval"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_REVAL, ;
		{ "id", "naz", "i1", "i2", "i3", "i4", "i5", "i6", "i7", ;
			"i8", "i9", "i10", "i11", "i12" })

lock_semaphore( _tbl, "free" )

return _result


