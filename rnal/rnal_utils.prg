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


#include "rnal.ch"


// --------------------------------------------------
// prikazi info 99 - otvori sifrarnik
// --------------------------------------------------
function info_0_sif( nPadR )
local cTxt := "/ 0 - otvori sifrarnik /"
show_it( cTxt, nPadR )
return


// --------------------------------------------------
// prikazi info 99 - otvori sifrarnik
// --------------------------------------------------
function info_99_sif( nPadR )
local cTxt := "/ 99 - otvori sifrarnik /"
show_it( cTxt, nPadR )
return


// --------------------------------------------------
// prikazi pay types
// --------------------------------------------------
function info_pay( nPadR )
local cTxt := "/ 1 - z.racun / 2 - gotovina /"
show_it( cTxt, nPadR )
return


// --------------------------------------------------
// prikazi prioritet 
// --------------------------------------------------
function info_priority( nPadR )
local cTxt := "/ 1 - high / 2 - normal / 3 - low /"
show_it( cTxt, nPadR )
return




