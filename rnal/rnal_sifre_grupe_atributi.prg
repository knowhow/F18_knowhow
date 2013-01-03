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


static _e_gr_id
static __wo_id

// -------------------------------------------------------
// otvara sifrarnik atributa grupa
// -------------------------------------------------------
function s_e_gr_att(cId, nGr_id, cE_gr_at_desc, lwoID, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol
private GetList:={}

if lwoID == nil
	lwoID := .f.
endif

__wo_id := lwoID

nTArea := SELECT()

cHeader := "Elementi - grupe atributi /  'V' - pr.vrijednosti / required '*'"

if nGr_id == nil
	nGr_id := -1
endif

if cE_gr_at_desc == nil
	cE_gr_at_desc := ""
endif

_e_gr_id := nGr_id

select e_gr_att
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
gr_filter(nGr_id, cE_gr_at_desc)

select e_gr_att
go top

cRet := PostojiSifra(F_E_GR_ATT, 1, MAXROWS()-10, MAXCOLS()-5, cHeader, @cId, dx, dy, {|| key_handler() })

if VALTYPE(cE_gr_at_desc) == "N"
	cE_gr_at_desc := STR(cE_gr_at_desc, 10)
endif

if nGr_id > 0 .or. cE_gr_at_desc <> ""
	set filter to
endif

select (nTArea)

if LastKey() == K_ESC
	cRet := 0
endif

return cRet



// ---------------------------------------------------
// gr_id filter na e_gr_att sifrarniku
// nE_gr_id - grupa id
// ---------------------------------------------------
static function gr_filter(nE_gr_id, cE_gr_at_desc)
local cFilter := ""

if nE_gr_id > 0
	cFilter += 'e_gr_id == ' + e_gr_id_str(nE_gr_id)
endif

if !EMPTY(cE_gr_at_desc)

	if !EMPTY(cFilter)
		cFilter += ' .and. '
	endif

	cFilter += 'UPPER(e_gr_at_de) = ' + cm2str(UPPER(ALLTRIM(cE_gr_at_desc))) 
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

if __wo_id == .f.
	AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(e_gr_at_id)}, "e_gr_at_id", {|| _inc_id(@we_gr_at_id, "E_GR_AT_ID"), .f.}, {|| .t.}})
endif

AADD(aImeKol, {PADC("Elem.grupa", 10), {|| PADR(g_e_gr_desc(e_gr_id), 10)}, "e_gr_id", {|| set_gr_id(@we_gr_id) }, {|| s_e_groups(@we_gr_id), show_it( g_e_gr_desc( we_gr_id ) ) }})

AADD(aImeKol, {PADC("Opis", 20), {|| PADR(e_gr_at_de, 20)}, "e_gr_at_de"})

AADD(aImeKol, {PADC("Joker", 20), {|| PADR(e_gr_at_jo, 20) }, "e_gr_at_jo"})

AADD(aImeKol, {PADC("Neoph", 5), {|| e_gr_at_re}, "e_gr_at_re", {|| .t.}, {|| .t. } })

AADD(aImeKol, {PADC("u art.naz ( /*)", 15), {|| PADR(in_art_des, 15)}, "in_art_des"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// ---------------------------------------------------
// setuje polje e_gr_id pri unosu automatski
// ---------------------------------------------------
static function set_gr_id( nE_gr_id )
if _e_gr_id > 0
	nE_gr_id := _e_gr_id
	return .f.
else
	return .t.
endif
return 


// ------------------------------------
// setuje polje required
// ------------------------------------
static function set_required()
local _rec

_rec := dbf_get_rec()
	
if _rec["e_gr_at_re"] == "*"
	_rec["e_gr_at_re"] := " "
else
	_rec["e_gr_at_re"] := "*"
endif

dbf_update_rec( _rec )
	
return



// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler()
local nE_gr_at_id := field->e_gr_at_id
local nTRec := RecNo()

do case
	
	case UPPER(CHR(Ch)) == "V"
		
		s_e_gr_val(nil, nE_gr_at_id)
		go (nTRec)
		return DE_CONT
	
	case UPPER(CHR(Ch)) == "R"
		
		Beep(1)
		set_required()
		
		return DE_REFRESH
		
	case Ch == K_CTRL_N .or. Ch == K_F4
		
		__wo_id := .f.
		set_a_kol(@ImeKol, @Kol)
		
		return DE_CONT
endcase

return DE_CONT


// -------------------------------
// convert e_gr_at_id to string
// -------------------------------
function e_gr_at_str(nId)
return STR(nId, 10)


// --------------------------------------------
// vraca djoker za pojedini atribut	
// --------------------------------------------
function g_gr_att_joker( nE_gr_att )
local cEGrAttJoker := ""
local nTArea := SELECT()

O_E_GR_ATT
select e_gr_att
set order to tag "1"
go top
seek e_gr_at_str(nE_gr_att)

if FOUND()
	if !EMPTY(field->e_gr_at_jo)
		cEGrAttJoker := ALLTRIM(field->e_gr_at_jo)
	endif
endif

select (nTArea)

return cEGrAttJoker


// --------------------------------------------------
// get e_gr_at_desc by e_gr_att_id
// --------------------------------------------------
function g_gr_at_desc( nE_gr_att_id, lShowRequired, lEmpty )
local cEGrAttDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cEGrAttDesc := ""
endif

if lShowRequired == nil
	lShowRequired := .f.
endif

O_E_GR_ATT
select e_gr_att
set order to tag "1"
go top
seek e_gr_at_str(nE_gr_att_id)

if FOUND()
	if !EMPTY(field->e_gr_at_de)
		
		cEGrAttDesc := ""
		
		if lShowRequired == .t.
			
			if !EMPTY(field->e_gr_at_re)
			
				cEGrAttDesc += "(" 
				cEGrAttDesc += ALLTRIM(field->e_gr_at_re) 
				cEGrAttDesc += ")"
			
			endif
			
		endif
		
		cEGrAttDesc += " "
		cEGrAttDesc += ALLTRIM(field->e_gr_at_de)
	endif
endif

select (nTArea)

return cEGrAttDesc


// ------------------------------------------
// gr_att in art_desc ???
// ------------------------------------------
function gr_att_in_desc( nE_gr_att )
local lRet := .f.
local nTArea := SELECT()

select e_gr_att
set order to tag "1"
seek e_gr_at_str( nE_gr_att )

if FOUND()
	if field->in_art_des == "*"
		lRet := .t.
	endif
endif

select (nTArea)
return lRet



// ------------------------------------------------------
// napuni matricu aAtt sa atributima grupa
// ------------------------------------------------------
function a_gr_attibs(aAtt, nE_Gr_id)
local nTArea := SELECT()
select e_gr_att
set filter to "e_gr_id == " + e_gr_id_str(nE_gr_id)
go top

do while !EOF() .and. field->e_gr_id == nE_gr_id
	AADD(aAtt, { field->e_gr_at_id, ALLTRIM(field->e_gr_at_de), 0, 0, 0 })
	skip
enddo

set filter to

select (nTArea)
return


