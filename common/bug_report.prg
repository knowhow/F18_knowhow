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
#include "f18_ver.ch"
#include "error.ch"

// -----------------------------------------------
// -----------------------------------------------
function GlobalErrorHandler(err_obj)

local _i, _err_code
local _out_file

_err_code := err_obj:genCode

BEEP(5)
_out_file := my_home_root() + "error.txt"

PTxtSekvence()


set console off
    
set printer off
set device to printer

set printer to (_out_file)
set printer on


P_12CPI

? REPLICATE("=", 84) 
? "F18 bug report (v3.2) :", DATE(), TIME()
? REPLICATE("=", 84) 


? "Verzija programa:", F18_VER, F18_VER_DATE, FMK_LIB_VER
?

? "SubSystem/severity    :", err_obj:SubSystem, err_obj:severity
? "GenCod/SubCode/OsCode :", err_obj:GenCode, err_obj:SubCode, err_obj:OsCode
? "Opis                  :", err_obj:description
? "ImeFajla              :", err_obj:filename
? "Operacija             :", err_obj:operation
? "Argumenti             :", err_obj:args
? "canRetry/canDefault   :", err_obj:canRetry, err_obj:canDefault

? 
? "CALL STACK:"
? "---", REPLICATE("-", 80)
for _i := 1 to 30
   if !empty(PROCNAME(_i))
       ? STR(_i, 3), PROCNAME(_i) + " / " +   ALLTRIM(STR(ProcLine(_i), 6))
   endif
next
? "---", REPLICATE("-", 80)
?

server_connection_info()

server_db_version_info()

server_info()

if USED() 
   current_dbf_info()
else
   ? "USED() = false"
endif

if err_obj:cargo <> NIL

    ? "== CARGO" , REPLICATE("=", 50)
    for _i := 1 TO LEN(err_obj:cargo)
    if err_obj:cargo[_i] == "var"
        ?  "* var ", err_obj:cargo[++_i], ":", pp(err_obj:cargo[++_i])
    endif
    next
    ? REPLICATE("-", 60)

endif
    
?
? "== END OF BUG REPORT =="


SET DEVICE TO SCREEN
set printer off
set printer to
set console on


close all

run (_cmd := "f18_editor " + _out_file)

// if Pitanje(, "Continue F18 ?", "N") == "D"
//  BREAK(err_obj)
// endif

RETURN

static function server_info()
local _key
local _server_vars := {"server_version", "TimeZone"}
local _sys_info

?
? "/---------- BEGIN PostgreSQL vars --------/"
?
for each _key in _server_vars 
  ? PADR(_key, 25) + ":",  server_show(_key)
next
?

? "/----------  END PostgreSQL vars --------/"
?
_sys_info := server_sys_info()

if _sys_info != NIL
    ?
    ? "/-------- BEGIN PostgreSQL sys info --------/"
    for each _key in _sys_info:Keys
        ? PADR(_key, 25) + ":",  _sys_info[_key]
    next
    ?
    ? "/-------  END PostgreSQL sys info --------/"
    ?
endif

return .t.

// --------------------------------------
// --------------------------------------
static function server_connection_info()
?
? "/----- SERVER connection info: ---------- /"
?
? "host/database/port/schema :", my_server_params()["host"] + " / " + my_server_params()["database"] + " / " +  ALLTRIM(STR(my_server_params()["port"], 0)) + " / " +  my_server_params()["schema"]  
? "                     user :", my_server_params()["user"]
?
return .t.

// -------------------------------
// -------------------------------
static function server_db_version_info()
local _server_db_num, _server_db_str, _f18_required_server_str, _f18_required_server_num

_f18_required_server_num := get_version_num(SERVER_DB_VER_MAJOR, SERVER_DB_VER_MINOR, SERVER_DB_VER_PATCH)

_server_db_num := server_db_version()

_f18_required_server_str := get_version_str(_f18_required_server_num)
_server_db_str := get_version_str(_server_db_num)

? "F18 client required server db >=     :", _f18_required_server_str, "/", ALLTRIM(STR(_f18_required_server_num, 0))
? "Actual knowhow ERP server db version :", _server_db_str, "/", ALLTRIM(STR(_server_db_num, 0))

return .t.


// ---------------------------------
// ---------------------------------
static function current_dbf_info()
local _struct, _i

? "Trenutno radno podrucje:", alias() ,", record:", RECNO(), "/", RECCOUNT()

_struct := DBSTRUCT()

? REPLICATE("-", 60)
? "Record content:"
? REPLICATE("-", 60)
for _i := 1 to LEN( _struct )
   ? STR(_i, 3), PADR(_struct[_i, 1], 15), _struct[_i, 2], _struct[_i, 3], _struct[_i, 4], EVAL(FIELDBLOCK(_struct[_i, 1]))
next
? REPLICATE("-", 60)

return .t.

