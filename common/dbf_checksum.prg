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

// -------------------------------------------------
// -------------------------------------------------
function check_after_synchro(dbf_alias)

// dummy funkcija do daljnjeg

return .t.

// ------------------------------------------
// param full synchro - uradi full synchro
// ------------------------------------------
function check_recno_and_fix(dbf_alias, cnt_dbf, full_synchro)
local _cnt_sql, _cnt_dbf
local _a_dbf_rec
local _opened := .f.
local _sql_table
local _dbf, _udbf

if full_synchro == NIL
    full_synchro := .f.
endif

_a_dbf_rec :=  get_a_dbf_rec(dbf_alias)
_sql_table :=  my_server_params()["schema"] + "." + _a_dbf_rec["table"]

_cnt_sql := table_count(_sql_table)

begin sequence with { |err| Break(err) }
    // pozicioniraj se po aliasu, a ne po workarea-i
    SELECT (_a_dbf_rec["alias"])
    USE 
recover
    SELECT (_a_dbf_rec["wa"])
end sequence

_udbf := my_home() + _a_dbf_rec["table"]

if !USED()
    dbUseArea( .f., DBFENGINE, _udbf, _a_dbf_rec["alias"], .t. , .f.)
    if FILE(ImeDbfCdx(_udbf))
        dbSetIndex(ImeDbfCDX(_udbf))
    endif

    _opened := .t.
endif   

if cnt_dbf == NIL
  // reccount() se ne moze iskoristiti jer prikazuje i deleted zapise
  // count je vremenski skupa operacija za velike tabele !
  COUNT TO _cnt_dbf 
else
  // dobili smo info o broju dbf zapisa
  _cnt_dbf := cnt_dbf
endif

log_write( "broj zapisa dbf " + _a_dbf_rec["alias"] + ": " + ALLTRIM(STR(_cnt_dbf, 10)) + " / sql " + _sql_table + ": " + ALLTRIM(STR(_cnt_sql, 10)), 7 )

if _cnt_sql <> _cnt_dbf

    log_write( "ERROR: check_recno " + _a_dbf_rec["alias"] + " cnt: " + ALLTRIM(STR(_cnt_dbf, 10)) + " / " + _sql_table+ " cnt:" + ALLTRIM(STR(_cnt_sql, 10)), 2 )

    // otvori ekskluzivno
    USE
    _dbf := my_home() + _a_dbf_rec["table"]
    dbUseArea( .f., DBFENGINE, _dbf, _a_dbf_rec["alias"], .f. , .f.)
    if FILE(ImeDbfCdx(_dbf))
        dbSetIndex(ImeDbfCDX(_dbf))
    endif

    _dbf_fields :=  _a_dbf_rec["dbf_fields"]

    if _dbf_fields == NIL
        _msg := "setuj dbf_fields u gaDBFS za " + _a_dbf_rec["table"] + " !##Ne mogu full synchro uraditi bez toga"
        log_write( _msg, 2 )
        MsgBeep( _msg )
        QUIT
    else
        if full_synchro
            full_synchro(_a_dbf_rec["table"], 50000)
        endif
    endif

    USE
endif

if _opened
    USE
endif

return 


