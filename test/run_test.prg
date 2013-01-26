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

function test_external_run()

local _src := my_home() + "_test_mozes_brisati_.txt"
local _cmd := "echo test_f18 > " + '"' + _src + '"'
//local _dest := my_home() + "test_dest.txt"


FERASE(_src)

_ret := f18_run(_cmd)

TEST_LINE(_ret, 0)
TEST_LINE(FILE(_src), .t.)
return .t.
