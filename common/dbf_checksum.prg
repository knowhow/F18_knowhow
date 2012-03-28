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

check_recno(dbf_alias)

return .t.

// ------------------------------------------
// ------------------------------------------
function check_recno(dbf_alias)
local _cnt_sql, _cnt_dbf
local _a_dbf_rec
local _opened := .f.
local _sql_table

_a_dbf_rec :=  get_a_dbf_rec(dbf_alias)
_sql_table :=  my_server_params()["schema"] + "." + _a_dbf_rec["table"]

_cnt_sql := table_count(_sql_table)


SELECT (_a_dbf_rec["wa"])
if !USED()
    dbUseArea( .f., "DBFCDX", my_home() + _a_dbf_rec["table"], _a_dbf_rec["alias"], .t. , .f.)
    _opened := .t.
endif   

// ovo ne moze prikazuje i deleted zapise
//_cnt_dbf := RECCOUNT()
// hoce li ovo usporiti otvaranje za velike tabele ?! 
COUNT TO _cnt_dbf 


if _cnt_sql <> _cnt_dbf
   lock_semaphore(_a_dbf_rec["table"], "lock")

   log_write("ERR check_recno " + _a_dbf_rec["alias"] + " cnt: " + ALLTRIM(STR(_cnt_dbf, 10)) + " / " + _sql_table+ " cnt:" + ALLTRIM(STR(_cnt_sql, 10)))
   // otvori ekskluzivno
   USE
   dbUseArea( .f., "DBFCDX", my_home() + _a_dbf_rec["table"], _a_dbf_rec["alias"], .f. , .f.)

   _dbf_fields :=  _a_dbf_rec["dbf_fields"]

   if _dbf_fields == NIL
      _msg := "setuj dbf_fields u gaDBFS za " + _a_dbf_rec["table"] + " !##Ne mogu full synchro uraditi bez toga"
      log_write(_msg)
      MsgBeep(_msg)
      QUIT
   else
      full_synchro(_a_dbf_rec["table"], 15000)
   endif

   USE
   lock_semaphore(_a_dbf_rec["table"], "free")
endif

if _opened
   USE
endif


return 
