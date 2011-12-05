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
local _tbl := "ld_radkr"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RADKR, ;
		{ "idradn", "mjesec", "godina", "idkred", "naosnovu", "iznos", ;
			"placeno" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function ld_radsat_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_radsat"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RADSAT, ;
		{ "idradn", "sati", "status" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_norsiht_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_norsiht"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_NORSIHT, ;
		{ "id", "naz", "jmj", "iznos", "n1", "k1", "k2" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function ld_radn_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_radn"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RADN, ;
		{ "id", "naz", "imerod", "ime", "brbod", "kminrad", "idstrspr", ;
		"idvposla", "idopsst", "idopsrad", "pol", "matbr", "datod", ;
		"k1", "k2", "k3", "k4", "rmjesto", "brknjiz", "brtekr", "isplata", ;
		"idbanka", "porol", "n1", "n2", "n3", "osnbol", "idrj", ;
		"streetname", "streetnum", "hiredfrom", "hiredto", "klo", ;
		"tiprada", "sp_koef", "opor", "trosk", "aktivan", "ben_srmj", ;
		"s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function ld_radsiht_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_radsiht"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RADSIHT, ;
		{ "godina", "mjesec", "dan", "dandio", "idrj", "idradn", ;
		"idkonto", "opis", "idtippr", "brbod", "idnorsiht", "izvrseno", ;
		"bodova" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_pk_data_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_pk_data"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_PK_DATA, ;
		{ "idradn", "ident", "rbr", "ime_pr", "jmb", "sr_naz", "sr_kod", ;
			"prihod", "udio", "koef" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_pk_radn_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_pk_radn"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_PK_RADN, ;
		{ "idradn", "zahtjev", "datum", "r_prez", "r_ime", "r_imeoca", ;
		"r_jmb", "r_adr", "r_opc", "r_opckod", "r_drodj", "r_tel", "p_naziv", ;
		"p_jib", "p_zap", "lo_osn", "lo_brdr", "lo_izdj", "lo_clp", "lo_clpi", ;
		"lo_ufakt" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_obracuni_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_obracuni"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_OBRACUNI, ;
		{ "rj", "mjesec", "godina", "obr", "status", "dat_ispl", ;
		"mj_ispl", "ispl_za", "vr_ispl" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function por_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "por"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_POR, ;
		{ "id", "naz", "iznos", "dlimit", "poopst", "algoritam", ;
		"por_tip", "s_sto_1", "s_izn_1", "s_sto_2", "s_izn_2" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function dopr_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "dopr"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_DOPR, ;
		{ "id", "naz", "iznos", "idkbenef", "dlimit", "poopst", ;
		"dop_tip", "tiprada" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function ld_parobr_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_parobr"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_PAROBR, ;
		{ "id", "naz" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function tippr_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "tippr"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_TIPPR, ;
		{ "id", "naz", "aktivan", "fiksan", "ufs", "koef1", ;
		"formula", "uneto", "opis", "tpr_tip" })

lock_semaphore( _tbl, "free" )

return _result




// -----------------------------------------
// -----------------------------------------
function tippr2_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "tippr2"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_TIPPR2, ;
		{ "id", "naz", "aktivan", "fiksan", "ufs", "koef1", ;
		"formula", "uneto", "opis", "tpr_tip" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function kred_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "kred"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_KRED, ;
		{ "id", "naz", "ziro", "zirod", "telefon", "adresa", ;
		"ptt", "fil", "mjesto" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function strspr_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "strspr"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_STRSPR, ;
		{ "id", "naz", "naz2" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function kbenef_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "kbenef"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_KBENEF, ;
		{ "id", "naz", "iznos" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function vposla_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "vposla"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_VPOSLA, ;
		{ "id", "naz", "idkbenef" })

lock_semaphore( _tbl, "free" )

return _result






