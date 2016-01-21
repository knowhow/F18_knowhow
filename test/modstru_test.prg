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

#include "f18.ch"

static _table_name := "f18_test"

function create_test_f18_dbf()
local _dbf_struct := {}
local _i

// tabele sa strukturom sifarnika (id je primarni ključ)
set_a_dbf_sifarnik(_table_name   , "F18_TEST"     , 500      )



AADD(_dbf_struct,      { 'ID' ,  'C' ,   2 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })

// moramo inicijalno napuniti semafor
reset_semaphore_version(_table_name)

DBCREATE2(_table_name, _dbf_struct)

CREATE_INDEX("ID",  "id", _table_name)
CREATE_INDEX("NAZ", "naz", _table_name)

my_usex(_table_name)

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

create_sql_table_f18_test()
create_semaphore(_table_name)
create_test_f18_dbf()

modstru({"*" + _table_name, "C ID C 2 0  ID C 5 0",  "A NAZ2 C 40 0"})

my_use( _table_name, _table_name, .t.)

TEST_LINE( FIELDPOS("NAZ2") > 0 .and. LEN(EVAL(FIELDBLOCK("ID"))) == 5,  .t.)
use
return


// ------------------------------------
// ------------------------------------
function create_sql_table_f18_test()
local _qry, _ret

_qry := "drop table if exists fmk.f18_test;"
_qry += "create table f18_test ("
_qry += "id varchar(2), naz varchar(40)"
_qry += "); "
_qry += "GRANT ALL ON TABLE fmk.f18_test TO xtrole;"

_ret := run_sql_query(_qry)

if VALTYPE(_ret)  == "O"
   return .t.
else
   return .f.
endif
