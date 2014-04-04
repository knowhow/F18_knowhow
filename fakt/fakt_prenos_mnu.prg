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


#include "fakt.ch"



function fakt_razmjena_podataka()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc,"1. kalk <-> fakt                  ")
AADD( _opcexe,{|| KaFak()})
AADD( _opc,"3. import barkod terminal")
AADD( _opcexe,{|| imp_bterm()})
AADD( _opc,"4. export barkod terminal")
AADD( _opcexe,{|| exp_bterm()})

f18_menu( "rpod", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()

return



