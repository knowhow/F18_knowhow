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

// -------------------------------------------------
// specifikacija kredita po kreditorima
// -------------------------------------------------
function sp_kredita()
local nMjesec
local nGodina
local cIdRj
local cObr
local cIdRadnik
local cTpKr

// uslovi izvjestaja
if _getVars( @nMjesec, @nGodina, @cIdRj, @cObr, ;
	@cIdRadnik, @cTpKr ) == .f.
	
	return

endif


return


// setovanje varijabli za izvjestaj
static function _getVars( nMj, nGod, cRj, cObr, cIdRadn, cTpKr )
local lRet := .t.
local nX := 1

cTpKr := "30"
nMj := gMjesec
nGod := gGodina
cRj := SPACE(50)
cObr := " "
cIdRadn := SPACE(6)

Box(,6, 60)

	@ m_x + nX, m_y + 2 SAY "Za period:" GET nMj
	@ m_x + nX, col() + 1 SAY "/" GET nGod

	++ nX

	@ m_x + nX, m_y + 2 SAY "Za period:" GET nMj

	read
BoxC()

if LastKey() == K_ESC
	lRet := .f.
endif

return lRet


