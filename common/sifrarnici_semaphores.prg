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
function partn_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "partn"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_PARTN, {"id", "naz", "mjesto", "adresa", "ziror", "fax", "mobtel" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function konto_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "konto"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_KONTO, {"id", "naz"})

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function roba_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "roba"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_ROBA, {"id", ;
				"sifradob", "naz", "jmj", "vpc", "vpc2", "nc", "mpc", ;
				"idtarifa", "tip", "barkod", "mpc2", "mpc3", "k1", "k2", ;
				"n1", "n2", "plc", "mink", "zanivel", "zaniv2", ;
				"trosk1", "trosk2", "trosk3", "trosk4", "trosk5", ;
				"fisc_plu", "k7", "k8", "k9", "strings", "fisc_plu" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function sifk_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "sifk"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_SIFK, {"id", ;
				"sort", "naz", "oznaka", "veza", "f_unique", "izvor", "uslov", ;
				"duzina", "f_decimal", "tip", "kvalid", "kwhen", "ubrowsu", ;
				"k1", "k2", "k3", "k4" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function sifv_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "sifv"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_SIFV, {"id", ;
				"idsif", "naz", "oznaka" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function opstine_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "ops"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_OPS, {"id", ;
				"idj", "idn0", "naz", "idkan", "zipcode", "puccanton", "puccity", "region" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function banke_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "banke"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_BANKE, {"id", ;
				"mjesto", "naz", "adresa" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function lokal_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "lokal"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_LOKAL, {"id", ;
				"id_str", "naz" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function trfp_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "trfp"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TRFP, {"id", ;
				"shema", "naz", "idkonto", "dokument", "partner", "d_p", ;
				"znak", "idvd", "idvn", "idtarifa" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function trfp2_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "trfp2"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TRFP2, {"id", ;
				"shema", "naz", "idkonto", "dokument", "partner", "d_p", ;
				"znak", "idvd", "idvn", "idtarifa" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function trfp3_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "trfp3"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TRFP3, {"id", ;
				"shema", "naz", "idkonto", "d_p", "znak", "idvn" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function sast_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "sast"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_SAST, {"id", ;
				"r_br", "id2", "kolicina", "k1", "k2", "n1", "n2" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function rj_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rj"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_RJ, {"id", "naz" })

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
function tdok_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "tdok"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TDOK, {"id", "naz" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function tnal_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "tnal"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TNAL, {"id", "naz" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function valute_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "valute"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_VALUTE, {"id", "naz", "naz2", "datum", ; 
							"kurs1", "kurs2", "kurs3", "tip" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function tarifa_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "tarifa"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_TARIFA, {"id", "naz", "opp", "ppp", "zpp", "vpp", "mpp", "dlruc" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function koncij_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "koncij"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_KONCIJ, {"id", "shema", "naz", "idprodmjes", "region" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function dest_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "dest"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_DEST, {"id", "idpartner", "naziv", "naziv2", "adresa", "mjesto", ;
			"ptt", "telefon", "fax", "mobitel" })

lock_semaphore( _tbl, "free" )

return _result


// -----------------------------------------
// -----------------------------------------
function ftxt_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "fakt_ftxt"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_FTXT, {"id", "naz" })

lock_semaphore( _tbl, "free" )

return _result



// -----------------------------------------
// -----------------------------------------
function f18_rules_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "f18_rules"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_FMKRULES, {"rule_id", "modul_name", ;
			"rule_obj", "rule_no", "rule_name", "rule_ermsg", "rule_level", ;
			"rule_c1", "rule_c2", "rule_c3", "rule_c4", "rule_c5", "rule_c6", ;
			"rule_c7", "rule_n1", "rule_n2", "rule_n3", "rule_d1", "rule_d2"  })

lock_semaphore( _tbl, "free" )

return _result




// ----------------------------------------
// ----------------------------------------
function sifrarnik_from_sql_server(table, algoritam, area, fields)
local _counter
local _rec
local _qry
local _server := pg_server()
local _seconds
local _x, _y
local _tmp_id, _ids
local _sql_ids
local _i
local _qry_obj
local _field_b
local _fnd
local _alias
local _pos

// pronaji alias tabele
_pos := ASCAN( gaDBFs,  { |x|  x[3] == LOWER( table ) } )
_alias := LOWER( gaDBFs[ _pos, 2 ] ) 

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update " + table + " : " + algoritam
_seconds := SECONDS()
_qry :=  "SELECT " 

for _i := 1 to LEN(fields)
  _qry += fields[_i]
  if _i < LEN(fields)
      _qry += ","
  endif
next
_qry += " FROM fmk." + table

if (algoritam == "IDS") 
    _ids := get_ids_from_semaphore(table)

    _qry += " WHERE "
    if LEN(_ids) < 1
       // nema id-ova
       _qry += "false"
    else
        _sql_ids := "("
        for _i := 1 to LEN(_ids)
            _sql_ids += _sql_quote(_ids[_i])
            if _i < LEN(_ids)
            _sql_ids += ","
            endif
        next
        _sql_ids += ")"
        _qry += " ID IN " + _sql_ids
     endif

endif

_qry_obj := _server:Query(_qry) 
if _qry_obj:NetErr()
   MsgBeep("ajoj :" + _qry_obj:ErrorMsg())
   QUIT
endif

SELECT (area)

my_use ( _alias, NIL, .f., "SEMAPHORE", algoritam)

DO CASE
  CASE (algoritam == "FULL")
    // "full" algoritam
    ZAP

  CASE algoritam == "IDS"
    _ids := get_ids_from_semaphore(table)
    SET ORDER TO TAG "ID"
     // pobrisimo sve id-ove koji su drugi izmijenili
    do while .t.
       _fnd := .f.
       for each _tmp_id in _ids
          HSEEK _tmp_id
          if found()
               _fnd := .t.
               DELETE
          endif
        next
        if ! _fnd ; exit ; endif
    enddo
END CASE

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1
DO WHILE ! _qry_obj:Eof()
    append blank
    for _i:=1 to LEN(fields)
       _field_b := FIELDBLOCK( fields[_i])
       _field_type := VALTYPE( EVAL( _field_b ) )
       // replace dbf field
       if _field_type == "C"   
			EVAL(_field_b, hb_Utf8ToStr(_qry_obj:FieldGet(_i))) 
       else
		    EVAL(_field_b, _qry_obj:FieldGet(_i))
       endif 
    next
    _qry_obj:Skip()

    _counter++
    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Close()

if (gDebug > 5)
    log_write(table + "synchro cache:" + STR(SECONDS() - _seconds))
endif

//close all
 
return .t. 


