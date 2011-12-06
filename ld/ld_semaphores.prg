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
local _ld_field_tag := "godina::char(4) || mjesec::char(2) || idradn || obr"

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
		"i31", "i32", "i33", "i34", "i35", "i36", "i37", "i38", "i39", "i40", ;
		"i41", "i42", "i43", "i44", "i45", "i46", "i47", "i48", "i49", "i50", ;
		"i51", "i52", "i53", "i54", "i55", "i56", "i57", "i58", "i59", "i60", ;
		"s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", ;
		"s11", "s12", "s13", "s14", "s15", "s16", "s17", "s18", "s19", "s20", ;
		"s21", "s22", "s23", "s24", "s25", "s26", "s27", "s28", "s29", "s30", ;
		"s31", "s32", "s33", "s34", "s35", "s36", "s37", "s38", "s39", "s40", ;
		"s41", "s42", "s43", "s44", "s45", "s46", "s47", "s48", "s49", "s50", ;
		"s51", "s52", "s53", "s54", "s55", "s56", "s57", "s58", "s59", "s60" ;
		 }, _ld_index_tag, _ld_field_tag )

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
local _index_tag := "1"
local _field_tag := " godina::char(4) || mjesec::char(2) || idradn || idkred || naosnovu"
 
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
			"placeno" }, _index_tag, _field_tag )

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function ld_radsat_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_radsat"
local _index_tag := "IDRADN"
local _fields_tag := "idradn"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RADSAT, ;
		{ "idradn", "sati", "status" }, _index_tag, _fields_tag )

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
local _index_tag := "4"
local _field_tag := "idradn || godina::char(4) || mjesec::char(2) || idkonto"

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
		"bodova" }, _index_tag, _field_tag )

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_pk_data_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_pk_data"
local _index_tag := "1"
local _fields_tag := "idradn || ident || rbr::char(3)"

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
			"prihod", "udio", "koef" }, _index_tag, _fields_tag )

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_pk_radn_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_pk_radn"
local _index_tag := "1"
local _fields_tag := "idradn"

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
		"lo_ufakt" }, _index_tag, _fields_tag )

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ld_obracuni_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_obracuni"
local _index_tag := "RJ"
local _fields_tag := "rj || godina::char(4) || mjesec::char(2) || status || obr"

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
		"mj_ispl", "ispl_za", "vr_ispl" }, _index_tag, _fields_tag )

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
local _fields_tag := "id || godina::char(4)"
local _index_tag := "ID"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_PAROBR, ;
		{ "id", "naz", "vrbod", "k1", "k2", "k3", "k4", "k5", "k6", ;
		"k7", "k8", "m_br_sat", "m_net_sat", "prosld", "idrj", "godina" }, ;
		_index_tag, _fields_tag )

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



// -----------------------------------------
// -----------------------------------------
function ld_tprsiht_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ld_tprsiht"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_TPRSIHT, ;
		{ "id", "naz", "k1", "k2", "k3", "ff" })

lock_semaphore( _tbl, "free" )

return _result



// ----------------------------------
// ---------------------------------
function sql_update_ld_ld( values )
local _table := "ld_ld"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "godina=" + _sql_quote(STR(values["godina"], 4)) + ;
	" AND mjesec=" + _sql_quote(STR(values["mjesec"], 2)) + ;
	" AND idradn=" + _sql_quote(values["idradn"]) + ;
	" AND obr=" + _sql_quote(values["obr"])


for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")

  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

    if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, STR(values["godina"],4) + STR(values["mjesec"],2) + values["idradn"] + values["obr"] ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  

    else
        _ok := .f.
	endif

  else
     _ok := .f.
  endif

  msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" )

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

lock_semaphore( _table, "free" )

return _ok



// ----------------------------------
// ---------------------------------
function sql_update_ld_radkr( values )
local _table := "ld_radkr"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "godina=" + _sql_quote(STR(values["godina"], 4)) + ;
	" AND mjesec=" + _sql_quote(STR(values["mjesec"], 2)) + ;
	" AND idradn=" + _sql_quote(values["idradn"]) + ;
	" AND idkred=" + _sql_quote(values["idkred"]) + ;
	" AND naosnovu=" + _sql_quote(values["naosnovu"])

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")

  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

    if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, STR(values["godina"],4) + STR(values["mjesec"],2) + values["idradn"] + values["idkred"] + values["naosnovu"] ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  
    else
        _ok := .f.
	endif
  else
     _ok := .f.
  endif

  msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" )

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

lock_semaphore( _table, "free" )


return _ok


// ----------------------------------
// ---------------------------------
function sql_update_ld_radsat( values )
local _table := "ld_radsat"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "idradn=" + _sql_quote( values["idradn"] )

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")


  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

   if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, values["idradn"] ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  

	else
        _ok := .f.   
	endif

  else
      _ok := .f.
 endif

 msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" )

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

lock_semaphore( _table, "free" )

return _ok


// ----------------------------------
// ---------------------------------
function sql_update_ld_radsiht( values )
local _table := "ld_radsiht"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "idradn=" + _sql_quote(values["idradn"]) + ;
	" AND godina=" + _sql_quote(STR(values["godina"], 4)) + ;
	" AND mjesec=" + _sql_quote(STR(values["mjesec"], 2)) + ;
	" AND idkonto=" + _sql_quote(values["idkred"]) 

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")

  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

   if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, values["idradn"] + STR(values["godina"],4) + STR(values["mjesec"],2) + values["idkonto"] ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  

    else
        _ok := .f.
	endif

  else
      _ok := .f.
  endif

  msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" )

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

lock_semaphore( _table, "free" )

return _ok


// ----------------------------------
// ---------------------------------
function sql_update_ld_pk_data( values )
local _table := "ld_pk_data"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "idradn=" + _sql_quote( values["idradn"]) + ;
	" AND ident=" + _sql_quote( values["ident"] ) + ;
	" AND rbr=" + _sql_quote( STR(values["rbr"], 3) )

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")

  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

   if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, values["idradn"] + values["ident"] + STR(values["rbr"],3) ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  

	else
		_ok := .f.
	endif

  else
	_ok := .f.
  endif

  msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" ) 

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

// oslobodi tabelu svakako

lock_semaphore( _table, "free" )

return _ok



// ----------------------------------
// ---------------------------------
function sql_update_ld_pk_radn( values )
local _table := "ld_pk_radn"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "idradn=" + _sql_quote( values["idradn"] )

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")

  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

   if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, values["idradn"] ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  

	else
		_ok := .f.
	endif

  else
	_ok := .f.
  endif

  msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" ) 

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

lock_semaphore( _table, "free" )

return _ok


// ----------------------------------
// ---------------------------------
function sql_update_ld_obracuni( values )
local _table := "ld_obracuni"
local _key, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _where
local _i

_where := "idrj=" + _sql_quote( values["idrj"]) + ;
	" AND godina=" + _sql_quote( STR(values["godina"], 4) ) + ;
	" AND mjesec=" + _sql_quote( STR(values["mjesec"], 2) ) + ;
	" AND status=" + _sql_quote( values["status"] ) + ;
	" AND obr=" + _sql_quote( values["obr"] )

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _table ) == "lock"
		Msgbeep( "tabela zakljucana: " + _table )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _table, "lock" )
	endif

next

if _ok == .t.

  msgo("Azuriranje tabele " + _table + " u toku...")

  sql_table_update( _table, "BEGIN" )

  if sql_table_update( _table, "del", values, _where )

   if sql_table_update( _table, "ins", values )
       
		update_semaphore_version( _table, .t. )
  
       	AADD( _ids, values["idrj"] + STR( values["godina"], 4) + STR(values["mjesec"],2) + values["status"] + values["obr"] ) 
       	push_ids_to_semaphore( _table, _ids )

       	sql_table_update( _table, "END" )  

	else
		_ok := .f.
	endif

  else
	_ok := .f.
  endif

  msgc()

endif

if ! _ok

    sql_table_update( _table, "ROLLBACK" ) 

    MsgBeep("Problem sa azuriranjem tabele " + _table )

endif

// oslobodi tabelu svakako

lock_semaphore( _table, "free" )

return _ok






