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

funciton f18_init_semahores()
local _key
local _f18_dbf

_f18_dbfs := f18_dbfs()


for each _key in _f18_dbfs:Keys

    if ! _f18_dbfs[_key]["temp"] 
             refresh_me(_f18_dbfs[_key])
    endif
next

// ----------------------------------------------------
// ----------------------------------------------------
function refresh_me(a_dbf_rec)
local _del, _cnt

Box(, 3, 60)


SELECT a_dbf_rec["wa"]
my_use_temp(a_dbf_rec["alias"], my_home() + a_dbf_rec["alias"])

set delete off

count to _del for deleted()
_cnt := reccount()

USE


@ m_x + 1, m_y + 2 SAY a_dbf_rec["alias"] + " / " + a_dbf_rec["table"]
@ m_x + 2, m_y + 2 SAY "cnt = "  + ALLTRIM(STR(_cnt, 0)) + " / " + ALLTRIM(STR(_del, 0))

SELECT a_dbf_rec["wa"]
my_use(a_dbf_rec["alias"], a_dbf_rec["alias"])


BoxC()
