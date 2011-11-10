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


#include "ld.ch"



// ------------------------------------
// pozicionira se na grupu 
// ------------------------------------
function gr_pos( cId )
local nTArea := SELECT()
local lRet := .f.

O_KONTO
select konto
seek cId

if FOUND()
	lRet := .t.
endif

select (nTArea)
return lRet


// -------------------------------------------
// vraca naziv grupe
// -------------------------------------------
function g_gr_naz( cId )
local xRet := ""

if gr_pos( cId )
	xRet := ALLTRIM( konto->naz )
endif

return xRet




