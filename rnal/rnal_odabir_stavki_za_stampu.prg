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
local _t_rec := RECNO()
local _ret := DE_CONT
local _rec

do case

	case ( Ch == ASC(' ') )

		Beep(0.5)
        
        _rec := dbf_get_rec()

		if _rec["print"] == "D"
            _rec["print"] := "N"
		else
            _rec["print"] := "D"
		endif
        
        dbf_update_rec( _rec )

		return DE_REFRESH

	case ( UPPER( CHR( Ch ) ) ) == "I"

		// unos isporuke
		if set_deliver() = 0
			return DE_CONT
		else
			return DE_REFRESH
		endif

endcase

return _ret


// ------------------------------------
// unos isporuke
// ------------------------------------
static function set_deliver()
local _ret := 1
local GetList := {}
local _deliver := field->doc_it_qtt
local _rec

Box(, 1, 25)
	@ m_x + 1, m_y + 2 SAY "isporuceno ?" GET _deliver PICT "9999999.99"
	read
BoxC()

if LastKey() == K_ESC
	_ret := 0
	return _ret
endif

_rec := dbf_get_rec()
_rec["doc_it_qtt"] := _deliver
dbf_update_rec( _rec )

// rekalkulisi podatke 
recalc_pr()

return _ret


// -------------------------------------------------------
// setovanje kolona za selekciju
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol:={}

AADD(aImeKol, {"nalog", {|| doc_no }, "doc_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"rbr", {|| PADR( ALLTRIM(STR(doc_it_no)),3) }, "doc_it_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADR("artikal",20), {|| PADR(g_art_desc(art_id,.t.,.f.),20) }, "art_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"ispor.", {|| STR(doc_it_qtt,12,2) }, "doc_it_qtt", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADR("dimenzije",20) , {|| PADR(_g_dim(doc_it_qtt, doc_it_hei, doc_it_wid),20) }, "doc_it_qtt", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"marker", {|| PADR(_g_st(print),3) }, "print", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"total", {|| "doc_it_tot" }, "doc_it_tot", {|| .t.}, {|| .t.} })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -------------------------------------------------
// vraca ispis status polja
// -------------------------------------------------
static function _g_st( value )
local _ret := ""

_ret := ">"
_ret += value
_ret += "<"

return _ret


// ---------------------------------------------------
// ispisuje opis dimenzija
// ---------------------------------------------------
static function _g_dim( qtty, height, width )
local _ret := ""

_ret += ALLTRIM(STR( qtty , 12, 0 ))
_ret += "x"
_ret += ALLTRIM(STR( height, 12, 2 ))
_ret += "x"
_ret += ALLTRIM(STR( width , 12, 2 ))

return _ret



