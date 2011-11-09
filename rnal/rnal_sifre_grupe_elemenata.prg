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


static _wo_id


// -----------------------------------------
// otvara sifrarnik artikala
// -----------------------------------------
function s_e_groups(cId, lwo_ID, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol
private GetList:={}

nTArea := SELECT()

cHeader := "Elementi - grupe /"
cHeader += SPACE(5)
cHeader += "'A' - pregled atributa grupe"

if lwo_ID == nil
	_wo_id := .f.
endif

select e_groups
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
	
cRet := PostojiSifra(F_E_GROUPS, 1, 8, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

if _wo_id == .f.

	AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(e_gr_id)}, "e_gr_id", {|| _inc_id(@we_gr_id, "E_GR_ID"), .f.}, {|| .t.}})

endif

AADD(aImeKol, {PADC("Puni naziv grupe", 30), {|| PADR(e_gr_full_desc, 30)}, "e_gr_full_desc"})
AADD(aImeKol, {PADC("Skr. opis (sifra)", 15), {|| PADR(e_gr_desc, 15)}, "e_gr_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
local nTRec := RecNo()
local nE_gr_id := field->e_gr_id

do case

	case UPPER(CHR(Ch)) == "A"
		// pregled atributa
		s_e_gr_att(nil, nE_gr_id)
		go (nTRec)
		return DE_CONT

	case Ch == K_CTRL_N .or. Ch == K_F4
	
		_wo_id := .f.
		set_a_kol(@ImeKol, @Kol)
		return DE_CONT
		
endcase

return DE_CONT


// -------------------------------
// convert e_gr_id to string
// -------------------------------
function e_gr_id_str(nId)
return STR(nId, 10)



// -------------------------------
// get e_gr_desc by e_gr_id
// -------------------------------
function g_e_gr_desc(nE_gr_id, lEmpty, lFullDesc )
local cEGrDesc := "?????"
local nTArea := SELECT()
local cVal := ""

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cEGrDesc := ""
endif

if lFullDesc == nil
	lFullDesc := .t.
endif

O_E_GROUPS
select e_groups
set order to tag "1"
go top
seek e_gr_id_str(nE_gr_id)

if FOUND()

	if lFullDesc == .t.
		if !EMPTY(field->e_gr_full_desc)
			cEGrDesc := ALLTRIM(field->e_gr_full_desc)
		endif
	else
		if !EMPTY(field->e_gr_desc)
			cEGrDesc := ALLTRIM(field->e_gr_desc)
		endif
	endif
	
endif

select (nTArea)

if !EMPTY(cEGrDesc)
	cEGrDesc := PADR(cEGrDesc, 6)
endif

return cEGrDesc


// ----------------------------------------------
// vraca grupu, trazeci po e_gr_desc
// ----------------------------------------------
function g_gr_by_type( cType )
local nTArea := SELECT()
local nGroup := 0

O_E_GROUPS
select e_groups
set order to tag "2"

go top

seek PADR(cType, 20)

if FOUND() .and. ALLTRIM( field->e_gr_desc ) == cType
	
	nGroup := field->e_gr_id
	
endif

set order to tag "1"
select (nTArea)

return nGroup


// ----------------------------------------------------
// vraca group_description by element id
// ----------------------------------------------------
function g_grd_by_elid( nEl_id )
local nTArea := SELECT()
local cGrDesc := ""

O_ELEMENTS
select elements 
set order to tag "2"
go top

seek elid_str( nEl_id )

if FOUND() .and. field->el_id == nEl_id
	cGrDesc := g_e_gr_desc( field->e_gr_id, .t., .f. )
endif

select (nTArea)

return cGrDesc

