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


// ------------------------------------------------
// otvara TBrowse objekat nad tabelom za stampu
// 
// ------------------------------------------------
function sel_items()
local nArea
local nTArea
local GetList:={}
local nBoxX := 12
local nBoxY := 77
local cHeader := ""
local cFooter := ""
local cBoxOpt := ""
private ImeKol
private Kol

nTArea := SELECT()

cHeader := ":: Odabir stavki za stampu ::"

t_rpt_open()

select t_docit
go top

Box(, nBoxX, nBoxY, .t.)

cBoxOpt += "<SPACE> markiranje stavke"
cBoxOpt += " "
cBoxOpt += "<ESC> izlaz"
cBoxOpt += " "
cBoxOpt += "<I> unos isporuke"

@ m_x + nBoxX, m_y + 2 SAY cBoxOpt

set_a_kol(@ImeKol, @Kol)

ObjDbedit("t_docit", nBoxX, nBoxY, {|| key_handler()}, cHeader, cFooter,,,,,1)

BoxC()

select (nTArea)

if LastKey() == K_ESC
	return 1
endif

return 1
  


// ------------------------------------------
// key handler nad tabelom
// ------------------------------------------
static function key_handler()
local nTRec := RECNO()
local nRet := DE_CONT

do case
	case (Ch == ASC(' '))
		Beep(0.5)
		if field->print == "D"
			replace field->print with "N"
		else
			replace field->print with "D"
		endif
		return DE_REFRESH
	case (UPPER(CHR(Ch))) == "I"
		// unos isporuke
		if set_deliver() = 0
			return DE_CONT
		else
			return DE_REFRESH
		endif
endcase


return nRet


// ------------------------------------
// unos isporuke
// ------------------------------------
static function set_deliver()
local nRet := 1
local GetList := {}
local nDeliver := field->doc_it_qtty

Box(, 1, 25)
	@ m_x + 1, m_y + 2 SAY "isporuceno ?" GET nDeliver PICT "9999999.99"
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
	return nRet
endif

replace field->doc_it_qtty with nDeliver

// rekalkulisi podatke 
recalc_pr()

return nRet


// -------------------------------------------------------
// setovanje kolona za selekciju
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol:={}

AADD(aImeKol, {"nalog", {|| doc_no }, "doc_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"rbr", {|| PADR( ALLTRIM(STR(doc_it_no)),3) }, "doc_it_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADR("artikal",20), {|| PADR(g_art_desc(art_id,.t.,.f.),20) }, "art_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"ispor.", {|| STR(doc_it_qtty,12,2) }, "doc_it_qtty", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADR("dimenzije",20) , {|| PADR(_g_dim(doc_it_qtty, doc_it_height, doc_it_width),20) }, "doc_it_qtty", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"marker", {|| PADR(_g_st(print),3) }, "print", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"total", {|| "doc_it_total" }, "doc_it_total", {|| .t.}, {|| .t.} })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -------------------------------------------------
// vraca ispis status polja
// -------------------------------------------------
static function _g_st( cVal )
local cRet := ""

cRet := ">"
cRet += cVal
cRet += "<"

return cRet


// ---------------------------------------------------
// ispisuje opis dimenzija
// ---------------------------------------------------
static function _g_dim( nQtty, nH, nW )
local cRet := ""

cRet += ALLTRIM(STR(nQtty,12,0))
cRet += "x"
cRet += ALLTRIM(STR(nH,12,2))
cRet += "x"
cRet += ALLTRIM(STR(nW,12,2))

return cRet



