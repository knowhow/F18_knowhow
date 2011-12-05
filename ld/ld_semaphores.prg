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

#include "ld.ch"
#include "common.ch"


// -----------------------------------------
// -----------------------------------------
function ld_ld_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_ld"
local _ld_index_tag := "1"
local _ld_field_tag := "mjesec || godina || idradn"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_LD, ;
		{ "godina", "idrj", "idradn", ;
		"mjesec", "brbod", "idstrspr", ;
		"idvposla", "kminrad", "usati", "uneto", "uodbici", ;
		"uiznos", "varobr", "ubruto", "uneto2", "ulicodb", "trosk", ;
		"opor", "tiprada", "nakn_opor", "nakn_neop", "udopr", ;
		"udop_st", "uporez", "upor_st", "v_ispl", "obr", ;
		"i01", "i02", "i03", "i04", "i05", "i06", "i07", "i08", "i09", "i10", ;
		"i11", "i12", "i13", "i14", "i15", "i16", "i17", "i18", "i19", "i20", ;
		"i21", "i22", "i23", "i24", "i25", "i26", "i27", "i28", "i29", "i30", ;
		"s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", ;
		"s11", "s12", "s13", "s14", "s15", "s16", "s17", "s18", "s19", "s20", ;
		"s21", "s22", "s23", "s24", "s25", "s26", "s27", ;
		"s28", "s29", "s30" }, _ld_index_tag, _ld_field_tag )

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_rj_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_rj"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_LD_RJ, {"id", "naz", "tiprada", "opor" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function ld_radkr_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "os_radkr"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RADKR, ;
		{ "id", "naz" })

lock_semaphore( _tbl, "free" )

return _result


