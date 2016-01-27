/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"



function virm_razmjena_podataka()
local _opc:={}
local _opcexe:={}
local _Izbor:=1

AADD(_opc, "1. ld   ->   virman             ")
AADD(_opcexe, {|| virm_prenos_ld()})
AADD(_opc, "2. fin  ->   virman   ")
AADD(_opcexe, {|| virm_prenos_fin()})
AADD(_opc, "3. kalk ->   virman   ")
AADD(_opcexe, {|| virm_prenos_kalk()})

f18_menu("mraz", .f., _izbor, _opc, _opcexe )

return



