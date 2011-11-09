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


static _e_gr_at
static __wo_id

// -------------------------------------------------------------
// otvara sifrarnik artikala
// -------------------------------------------------------------
function s_e_gr_val(cId, nE_gr_at_id, cE_gr_vl_desc, lwo_ID, dx, dy)
local nTArea
local cHeader
local nCdx := 1
private ImeKol
private Kol
private GetList:={}

nTArea := SELECT()

cHeader := "Elementi - atributi, vrijednosti atributa /"

if nE_gr_at_id == nil
	nE_gr_at_id := -1
endif

if cE_gr_vl_desc == nil
	cE_gr_vl_desc := ""
endif

if lwo_ID == nil
	lwo_ID := .f.
endif

_e_gr_at := nE_gr_at_id
__wo_id := lwo_ID

select e_gr_val
set order to tag "1"

set_a_kol(@ImeKol, @Kol)
gr_att_filter(nE_gr_at_id, cE_gr_vl_desc)

go top

private gTBDir := "N"

cRet := PostojiSifra(F_E_GR_VAL, 1, 16, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

if VALTYPE(cE_gr_vl_desc) == "N"
	cE_gr_vl_desc := STR(cE_gr_vl_desc, 10)
endif

if nE_gr_at_id > 0 .or. cE_gr_vl_desc <> ""
	set filter to
endif

select (nTArea)

return cRet


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

if __wo_id == .f.

	AADD(aImeKol, {PADC("ID/MC", 10), {|| PADR(sif_idmc(e_gr_vl_id),10)}, "e_gr_vl_id", {|| _inc_id(@we_gr_vl_id, "E_GR_VL_ID"), .f.}, {|| .t.}})

endif

AADD(aImeKol, {PADC("Grupa/atribut", 15), {|| "(" + ALLTRIM(g_egr_by_att(e_gr_at_id)) + ") / " + PADR(g_gr_at_desc(e_gr_at_id), 15)}, "e_gr_at_id", {|| set_e_gr_at(@we_gr_at_id) }, {|| s_e_gr_att( @we_gr_at_id ), show_it( g_gr_at_desc( we_gr_at_id ) ) }})

AADD(aImeKol, {PADC("Vrijednost", 20), {|| PADR(e_gr_vl_full, 28) + ".." }, "e_gr_vl_full"})

AADD(aImeKol, {PADC("Skr. opis (sifra)", 20), {|| PADR(e_gr_vl_desc, 10) }, "e_gr_vl_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// ---------------------------------------------------
// setuje polje e_gr_at_id pri unosu automatski
// ---------------------------------------------------
static function set_e_gr_at( nE_gr_at )
if _e_gr_at > 0
	nE_gr_at := _e_gr_at
	return .f.
else
	return .t.
endif
return 




// ------------------------------------------------------
// filter po polju e_gr_at_id
//
// nE_gr_at_id - id atributa grupe
// nE_gr_vl_desc - description vrijednosti...
// ------------------------------------------------------
static function gr_att_filter(nE_gr_at_id, cE_gr_vl_desc)
local cFilter := ""

if nE_gr_at_id > 0
	cFilter += "e_gr_at_id == " + e_gr_at_str(nE_gr_at_id)
endif

if !EMPTY( cE_gr_vl_desc )
	
	if !EMPTY(cFilter)
		cFilter += " .and. "
	endif

	cFilter += "UPPER(e_gr_vl_fu) = " + cm2str( UPPER(ALLTRIM(cE_gr_vl_desc)) )
endif

if !EMPTY(cFilter)
	set filter to
	set filter to &cFilter
	go top
endif

return


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)

do case

	case Ch == K_CTRL_N .or. Ch == K_F4
		__wo_ID := .f.
		set_a_kol(@ImeKol, @Kol)
		return DE_CONT

endcase

return DE_CONT


// -------------------------------
// convert e_gr_val_id to string
// -------------------------------
function e_gr_vl_str(nId)
return STR(nId, 10)


// -------------------------------
// get e_gr_desc by e_gr_id
// -------------------------------
function g_e_gr_vl_desc( nE_gr_vl_id, lEmpty, lFullDesc )
local cEGrValDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cEGrValDesc := ""
endif

if lFullDesc == nil
	lFullDesc := .t.
endif

O_E_GR_VAL
select e_gr_val
set order to tag "1"
go top
seek e_gr_vl_str(nE_gr_vl_id)

if FOUND()
	if lFullDesc == .t.
		if !EMPTY(field->e_gr_vl_full)
			cEGrValDesc := ALLTRIM(field->e_gr_vl_full)
		endif
	else
		if !EMPTY(field->e_gr_vl_desc)
			cEGrValDesc := ALLTRIM(field->e_gr_vl_desc)
		endif
	endif
endif

select (nTArea)

return cEGrValDesc


// --------------------------------------------------
// vraæa grupu elementa po vrijednosti atributa
// --------------------------------------------------
function g_egr_by_att( nE_gr_att, lEmpty, lFullDesc )
local cGr := "?????"
local nTArea := SELECT()
local nTRec := RecNo()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cGr := ""
endif

select e_gr_att
set order to tag "1"
go top
seek e_gr_at_str(nE_gr_att)

if FOUND()
	cGr := ALLTRIM( g_e_gr_desc( field->e_gr_id, lEmpty, lFullDesc ) )
endif

select (nTArea)
go (nTRec)

return cGr



// -------------------------------------------------
// vraca atribut grupe elementa iz tabele e_gr_val 
// -------------------------------------------------
function g_gr_att_val( nE_gr_val )
local nE_gr_att := 0
local nTArea := SELECT()

select e_gr_val
set order to tag "1"
go top
seek e_gr_vl_str(nE_gr_val)

if FOUND()
	nE_gr_att := field->e_gr_at_id
endif

select (nTArea)
return nE_gr_att




