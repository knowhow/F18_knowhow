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

// variables
static _el_gr
static sif_pict


// --------------------------------------------
// kreira pomocnu tabelu u privpath-u...
// --------------------------------------------
static function _cre_art_tmp()
local aArtDbf := {}
local cArtTbl := "_ART_TMP"

select 230
if USED()
	close _art_tmp
endif

AADD(aArtDbf, {"art_id", "N", 10, 0})
AADD(aArtDbf, {"art_marker", "C", 1, 0})

// brisi dbf i cdx
if FILE(PRIVPATH + cArtTbl + ".DBF")
	FERASE(PRIVPATH + cArtTbl + ".DBF")
	FERASE(PRIVPATH + cArtTbl + ".CDX")
endif

// kreiraj tabelu
if !FILE(PRIVPATH + cArtTbl + ".DBF")
	DBcreate2(PRIVPATH + cArtTbl + ".DBF", aArtDbf)
endif

select 230
if !USED() 
	use (PRIVPATH + cArtTbl)
endif
index on STR(art_id, 10) tag "1"
set order to tag "1"

return



// -------------------------------------------
// funkcija za odabir artikala...
// -------------------------------------------
function pick_articles()
local aAtt := {}
local nRet := 0

if _fnd_par_get() == 0
	return DE_CONT
endif

// setuj i postavi filter....
nRet := _srch_art()

return nRet


// -------------------------------------------------------
// funkcija koja pregleda artikle i tabelu _FND_PAR
//   te setuje i markira artikle u _ART_TMP
// -------------------------------------------------------
static function _srch_art()
local aEl
local nTREC
local nSeekAtt := 1
local nSeekAop := 1
local lFoundAtt := .t.
local lFoundAop := .t.

// kreiraj pomocnu tabelu _ART_TMP i otvori je
_cre_art_tmp()

select articles
set relation to
set filter to
go top

MsgO("Pronalazim artikle ...")

do while !EOF()

	nTREC := RECNO()
	
	// uzmi u matricu elemente artikla
	_fill_a_articles( @aEl, field->art_id )

	select _fnd_par
	go top

	lFoundAtt := .t.
	lFoundAop := .t.

	do while !EOF()
		
		// ako je match code preskoci
		if ALLTRIM(field->fnd_par_type) == "MC"
			skip
			loop
		endif
	
		// ako je ATT i nije prazan fnd_val
		if ALLTRIM(field->fnd_par_type) == "ATT" .and. !EMPTY(field->fnd_val)
			
			nSeekAtt := ASCAN(aEl, { |xVal| STR(xVal[5]) + STR(xVal[6]) == STR(VAL(field->fnd_att)) + STR(VAL(field->fnd_val)) .and. ALLTRIM(xVal[2]) == "ATT" })
			if nSeekAtt == 0
				// izadji jer nisi pronasao...
				lFoundAtt := .f.
				skip
				loop
			endif
			
		endif
		
		// ako je AOP i nije prazan fnd_val
		if ALLTRIM(field->fnd_par_type) == "AOP" .and. !EMPTY(field->fnd_val)
			
			nSeekAop := ASCAN(aEl, { |xVal| xVal[5] == VAL(field->fnd_att) .and. xVal[2] = "AOP" })
			
			if nSeekAop == 0
				// izadji jer nisi pronasao...
				lFoundAop := .f.
				skip
				loop
			endif
			
		endif
		
		select _fnd_par
		skip
	enddo

	if lFoundAtt == .t. .and. lFoundAop == .t.
		// ubaci artikal u _ART_TMP i markiraj ga
		select _art_tmp
		go top
		
		seek artid_str(articles->art_id)
		
		if !FOUND()
			append blank
		endif
		
		replace art_id with articles->art_id
		replace art_marker with "*"
	endif
	
	select articles
	
	go (nTREC)
	
	skip

enddo

// gen match_code filter...
cFiltMC := _gen_mc_filter()

if EMPTY(cFiltMC)
	cFiltMC := ".t."
endif

select articles
go top

// postavi relaciju ARTICLES -> _ART_TMP
// setuj filter po _ART_TMP->ART_MARKER = '*' i ARTICLES->MATCH_CODE

set relation to STR(articles->art_id, 10) into _art_tmp
set filter to _art_tmp->(art_marker) == '*' .and. &cFiltMC
go top

MsgC()

return 1


// --------------------------------------------
// FILTER.GEN. match_code artikla
// --------------------------------------------
static function _gen_mc_filter()
local nTArea := SELECT()
local cFilt := ""

select _fnd_par
set order to tag "1"
go top

do while !EOF()

	if ALLTRIM( field->fnd_par_type ) <> "MC"
		skip
		loop
	endif

	if !EMPTY(cFilt)
		cFilt += " .or. "
	endif
	
	cFilt += " UPPER(match_code) = " + cm2str( UPPER(ALLTRIM(field->fnd_val)) )

	skip
enddo

select (nTArea)

return cFilt


