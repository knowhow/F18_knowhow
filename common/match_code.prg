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

// -----------------------------------
// pretraga po match_code polju
// -----------------------------------
function m_code_src()
local cSrch
local cFilter

if !is_m_code()
	// ne postoji polje match_code
	return 0
endif

Box(, 7, 60)
	private GetList:={}
	cSrch:=SPACE(20)
	set cursor on
	@ m_x+1, m_y+2 SAY "Match code:" GET cSrch VALID !EMPTY(cSrch)
	@ m_x+3, m_y+2 SAY "Uslovi za pretragu:" COLOR "I"
	@ m_x+4, m_y+2 SAY " /ABC = m.code pocinje sa 'ABC'  ('ABC001')"
	@ m_x+5, m_y+2 SAY " ABC/ = m.code zavrsava sa 'ABC' ('001ABC')"
	@ m_x+6, m_y+2 SAY " #ABC = 'ABC' je unutar m.code  ('01ABC11')"
	@ m_x+7, m_y+2 SAY " ABC  = m.code je striktno 'ABC'    ('ABC')"
	read
BoxC()

// na esc 0
if LastKey() == K_ESC
	return 0
endif

cSrch := TRIM(cSrch)
// sredi filter
g_mc_filter(@cFilter, cSrch)

if !EMPTY(cFilter)
	// set matchcode filter
     	s_mc_filter(cFilter)  
else
	set filter to
	go top
endif
   
return 1


// ------------------------------------------
// provjerava da li postoji polje match_code
// ------------------------------------------
function is_m_code()
if fieldpos("MATCH_CODE")<>0
	return .t.
endif
return .f.


// ---------------------------------
// setuj match code filter
// ---------------------------------
static function s_mc_filter(cFilter)
set filter to &cFilter
go top
return

// -------------------------------------
// sredi filter po match_code za tabelu
// -------------------------------------
static function g_mc_filter(cFilt, cSrch)
local cPom
local nLeft

cFilt:="TRIM(match_code)"
cSrch := TRIM(cSrch)

do case
	case LEFT(cSrch, 1) == "/"
	
		// match code pocinje
		cPom := STRTRAN(cSrch, "/", "")
		cFilt += "=" + Cm2Str(cPom)
		
	case LEFT(cSrch, 1) == "#"
		
		// pretraga unutar match codea
		cPom := STRTRAN(cSrch, "#", "")
		
		cFilt := Cm2Str(ALLTRIM(cPom))
		cFilt += "$ match_code"

	case RIGHT(cSrch, 1) == "/"
		
		// match code zavrsava sa...
		cPom := STRTRAN(cSrch, "/", "")
		nLeft := LEN(ALLTRIM(cPom))
		
		cFilt := "RIGHT(ALLTRIM(match_code),"+ALLTRIM(STR(nLeft))+")"
		cFilt += "==" + Cm2Str(ALLTRIM(cPom))
		
	otherwise
		
		// striktna pretraga
		cFilt += "==" + Cm2Str(cSrch)
endcase

return


