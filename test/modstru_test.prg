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


function create_test_f18_dbf()
local ime_f := "test_f18"
local dbf_struct := {}
local _i

AADD(dbf_struct,      { 'ID' ,  'C' ,   2 ,  0 })
AADD(dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })
       
DBCREATE2(ime_f, dbf_struct)

CREATE_INDEX("ID",  "id", ime_f)  
CREATE_INDEX("NAZ", "naz", ime_f)


my_usex(ime_f)

APPEND BLANK


for _i := 1 to 50
 replace id with STR(_i, 2)
 replace naz with "naz" + STR(_i, 2)
next


return .f.

function modstru_test()
local _ini_params
local _current_dbf_ver, _new_dbf_ver
local _ini_section := "DBF_version"

create_test_f18_dbf()

// ucitaj parametre iz inija, ako postoje ...
_ini_params := hb_hash()
_ini_params["major"] := "0"
_ini_params["minor"] := "0"
_ini_params["patch"] := "0"

if !f18_ini_read(_ini_section, @_ini_params, .f.)
   MsgBeep("problem sa ini_params " + _ini_section)
endif
_current_dbf_ver := get_dbf_ver(_ini_params["major"], _ini_params["minor"], _ini_params["patch"])
_new_dbf_ver := get_dbf_ver( F18_DBF_VER_MAJOR, F18_DBF_VER_MINOR, F18_DBF_VER_PATCH)

log_write("current dbf version:" + STR(_current_dbf_ver))
log_write("    F18 dbf version:" + STR(_new_dbf_ver))

// 0.2.0
// if _current_dbf_ver < _new_dbf_ver
//modstru({"*fin_budzet", "C IDKONTO C 7 0  IDKONTO C 10 0",  "A IDKONTO2 C 7 0"})

modstru({"*test_f18", "C ID C 2 0  ID C 5 0",  "A NAZ2 C 40 0"})
// endif

//my_use( "BUDZET", "fin_budzet", .t.)
my_use( "test_f18", "test_f18", .t.)

TEST_LINE( FIELDPOS("NAZ2") > 0 .and. LEN(EVAL(FIELDBLOCK("ID"))) == 5,  .t.)
//TEST_LINE( FIELDPOS("IDKONTO2") > 0 .and. LEN(EVAL(FIELDBLOCK("IDKONTO"))) == 10,  .t.)
use

return

