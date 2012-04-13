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

// ----------------------------------------------------
// ----------------------------------------------------
function f18_init_semaphores()
local _key
local _f18_dbf
local _temp_tbl

_f18_dbfs := f18_dbfs()


for each _key in _f18_dbfs:Keys

    _temp_tbl := _f18_dbfs[_key]["temp"]
    if !_temp_tbl
         refresh_me(_f18_dbfs[_key])
    endif
next

// ----------------------------------------------------
// ----------------------------------------------------
function refresh_me(a_dbf_rec)
local _wa, _del, _cnt, _msg_1, _msg_2

Box(, 6, 60)


dbf_open_temp(a_dbf_rec, @_cnt, @_del)

_msg_1 := a_dbf_rec["alias"] + " / " + a_dbf_rec["table"]
_msg_2 := "cnt = "  + ALLTRIM(STR(_cnt, 0)) + " / " + ALLTRIM(STR(_del, 0))

@ m_x + 1, m_y + 2 SAY _msg_1
@ m_x + 2, m_y + 2 SAY _msg_2

log_write("prije synchro " +  _msg_1 + " " + _msg_2)

SELECT (_wa)
my_use(a_dbf_rec["alias"], a_dbf_rec["alias"])

USE

 
// ponovo otvori nakon sinhronizacije
dbf_open_temp(a_dbf_rec, @_cnt, @_del)

_msg_1 := a_dbf_rec["alias"] + " / " + a_dbf_rec["table"]
_msg_2 := "cnt = "  + ALLTRIM(STR(_cnt, 0)) + " / " + ALLTRIM(STR(_del, 0))

@ m_x + 4, m_y + 2 SAY _msg_1
@ m_x + 5, m_y + 2 SAY _msg_2


log_write("nakon synchro " +  _msg_1 + " " + _msg_2)

USE

BoxC()


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
static function dbf_open_temp(a_dbf_rec, cnt, del)

SELECT (a_dbf_rec["wa"])
my_use_temp(a_dbf_rec["alias"], my_home() + a_dbf_rec["table"], .f.)

set deleted off

count to del for deleted()
cnt := reccount()

USE
set deleted on
return

