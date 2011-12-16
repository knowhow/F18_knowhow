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
local _ime_f := "test_f18"
local _dbf_struct := {}
local _i

AADD(_dbf_struct,      { 'ID' ,  'C' ,   2 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })
       
DBCREATE2(_ime_f, _dbf_struct)

CREATE_INDEX("ID",  "id", _ime_f)  
CREATE_INDEX("NAZ", "naz", _ime_f)

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  AADD(gaDBFs, { 100,  UPPER(_ime_f),  _ime_f  } )
endif

my_usex(ime_f)

for _i := 1 to 50
 APPEND BLANK
 replace id with STR(_i, 2)
 replace naz with "naz" + STR(_i, 2)
next


return .f.

function modstru_test()
local _ini_params
local _current_dbf_ver, _new_dbf_ver
local _ini_section := "DBF_version"

create_test_f18_dbf()

modstru({"*test_f18", "C ID C 2 0  ID C 5 0",  "A NAZ2 C 40 0"})

my_use( "test_f18", "test_f18", .t.)

TEST_LINE( FIELDPOS("NAZ2") > 0 .and. LEN(EVAL(FIELDBLOCK("ID"))) == 5,  .t.)
use

return

