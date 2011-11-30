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

#include "fmk.ch"
#include "common.ch"

// -----------------------------------------
// -----------------------------------------
function ugov_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "fakt_ugov"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_UGOV, ;
		{ "id", "datod", "idpartner", ;
		"datdo", "vrsta", "idtipdok", ;
		"naz", "aktivan", "dindem", "idtxt", ;
		"zaokr", "lab_prn", "iddodtxt", ;
		"a1", "a2", "b1", "b2", "txt2", "txt3", ;
		"txt4", "f_nivo", "f_p_d_nivo", ;
		"dat_l_fakt", "def_dest" })

lock_semaphore( _tbl, "free" )

return _result




// -----------------------------------------
// -----------------------------------------
function rugov_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "fakt_rugov"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RUGOV, ;
		{"id", "idroba", "kolicina", "porez", "rabat" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function gen_ug_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "fakt_gen_ug"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_GEN_UG, ;
		{"dat_obr", "dat_gen", "dat_u_fin", "kto_kup", "kto_dob", ;
		"opis", "brdok_od", "brdok_do", "fakt_br", "saldo", "saldo_pdv", ;
		"dat_val" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function gen_ug_p_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "fakt_gen_ug_p"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_G_UG_P, ;
		{"dat_obr", "idpartner", "id_ugov", "saldo_kup", "saldo_dob", ;
		"d_p_upl_ku", "d_p_prom_k", "d_p_prom_d", "f_iznos", "f_iznos_pd" })

lock_semaphore( _tbl, "free" )

return _result




