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


#include "kalk.ch"


// -----------------------------------------
// izvjestaj TKV
// -----------------------------------------
function kalk_tkv()
local _vars
local _calc_rec := 0

// skeleton ::

// uslovi izvjestaja...
if !get_vars( @_vars )
    return
endif

// generisanje izvjestaja
_calc_rec := kalk_gen_fin_stanje_magacina( _vars )

if _calc_rec > 0
    // stampaj TKV izvjestaj
    stampaj_tkv()
endif

return


// -----------------------------------------
// uslovi izvjestaja
// -----------------------------------------
static function get_vars( vars )
local _ret := .t.
return _ret



// ------------------------------------------
// stampa izvjestaja TKV
// ------------------------------------------
static function stampaj_tkv()


return





