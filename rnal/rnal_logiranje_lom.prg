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

static __doc_no
static __oper_id

// ---------------------------------
// promjena, lom na artiklima
// ---------------------------------
function _ch_damage( nOperId )
local nTRec := RecNo()
local cDesc
local cDamage
local aDbf := {}

__oper_id := nOperId

// setuj polja tabele....
tmp_damage( @aDbf )

// kreiraj pomocnu tabelu...
cre_tmp1( aDbf )
o_tmp1()
select _tmp1
zap

select docs
__doc_no := field->doc_no

// napuni tmp sa stavkama naloga
_doc_to_tmp()

// box sa unosom podataka
if _box_damage( @cDesc ) == 0
	return
endif

beep(1)

log_damage( __doc_no, cDesc, "+" )

beep(2)

select docs
Scatter()

Gather()

skip

select docs
go (nTRec)

return



// --------------------------------------------
// setovanje polja tabele _tmp1
// --------------------------------------------
static function tmp_damage( aDbf )

AADD(aDbf, { "doc_no", "N", 10, 0 })
AADD(aDbf, { "doc_it_no", "N", 4, 0 })
AADD(aDbf, { "art_id", "N", 10, 0 })
AADD(aDbf, { "glass_no", "N", 3, 0 })
AADD(aDbf, { "doc_it_qtty", "N", 12, 2 })
AADD(aDbf, { "doc_it_h", "N", 12, 2 })
AADD(aDbf, { "doc_it_w", "N", 12, 2 })
AADD(aDbf, { "damage", "N", 12, 2 })
AADD(aDbf, { "art_marker", "C", 1, 0 })
AADD(aDbf, { "art_desc", "C", 150, 0 })

return



// ---------------------------------------------
// napuni tmp tabelu sa stavkama naloga
// ---------------------------------------------
static function _doc_to_tmp()
local nTArea := SELECT()

select doc_it
set order to tag "1"
go top
seek docno_str( __doc_no )

do while !EOF() .and. field->doc_no == __doc_no

	select _tmp1
	append blank
	
	Scatter()
	
	_doc_no := doc_it->doc_no
	_doc_it_no := doc_it->doc_it_no
	_art_id := doc_it->art_id
	_doc_it_qtty := doc_it->doc_it_qtty
	_doc_it_h := doc_it->doc_it_height
	_doc_it_w := doc_it->doc_it_width
	_damage := 0
	_glass_no := 0
	
	Gather()
	
	select doc_it
	skip
	
enddo

select (nTArea)
return


// --------------------------------------
// box sa unosom podataka osnovnih
// --------------------------------------
static function _box_damage( cDesc )
local nBoxX := 14
local nBoxY := 77
local cHeader
local lLogCh := .f.
local cFooter
local cOptions
private GetList:={}
private ImeKol
private Kol

cHeader := " *** Dokument broj: " + docno_str( __doc_no ) + " "
cFooter := " *** Evidencija loma na stavkama "

cOptions := "<SPACE> markiranje stavki"
cOptions += " "
cOptions += "<ESC> snimanje promjena"

Box(, nBoxX, nBoxY, .t.)

select _tmp1
go top

set_a_kol( @ImeKol, @Kol )

@ m_x + (nBoxX-1), m_y + 1 SAY cOptions

ObjDbedit("damage", nBoxX, nBoxY, {|| key_handler() }, cHeader, cFooter,,,,, 2)

BoxC()

if LastKey() == K_ESC

	// provjeri da li treba logirati ista...
	select _tmp1
	go top

	do while !EOF()
		if field->art_marker == "*"
			lLogCh := .t.
			exit
		endif
		skip
	enddo
	
	if lLogCh == .t. .and. Pitanje(, "Logirati promjene (D/N) ?", "D") == "D"
		// daj opis promjene
		_get_ch_desc( @cDesc )
		
		cDesc := ""
		return 1
		
	else
		cDesc := ""
		return 0
	endif
endif

return 0


// ------------------------------------------
// setovanje kolona browse-a
// ------------------------------------------
static function set_a_kol( aImeKol, aKol )
aImeKol := {}
aKol := {}

AADD(aImeKol, {"rbr" , {|| docit_str( doc_it_no ) }, ;
	"doc_it_no", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"artikal/kol" , {|| sh_article( art_id, doc_it_qtty, ;
	doc_it_w, doc_it_h ) }, ;
	"art_id", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"staklo" , {|| glass_no }, ;
	"glass_no", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"steta" , {|| damage }, ;
	"damage", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"mark" , {|| PADR( art_marker, 4 ) }, ;
	"art_marker", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"opis" , {|| PADR( art_desc, 35 ) }, ;
	"art_desc", {|| .t.}, {|| .t.} })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// -----------------------------------------
// prikaz artikla u tabeli
// -----------------------------------------
static function sh_article( nArt_id , nQtty, nWidth, nHeight )
local xRet := "???"
local cTmp 
local nTmp

// dimenzije
xRet := "("
xRet += ALLTRIM( STR( nWidth, 12, 0 ) ) 
xRet += "x" 
xRet += ALLTRIM( STR( nHeight, 12, 0 ) )
xRet += "x"
xRet += ALLTRIM( STR( nQtty, 12, 0 ) )
xRet += ")"

// naziv
cTmp := ALLTRIM( g_art_desc( nArt_id, .t., .f. ) )

xRet := cTmp + " " + xRet

return PADR(xRet, 35)


// ---------------------------------------
// obrada key handlera
// ---------------------------------------
static function key_handler()

do case
	case Ch == ASC(" ")
		// markiranje loma "*"
		return _mark_item()
	
endcase

return DE_CONT


// --------------------------------------
// markiranje stavke...
// --------------------------------------
static function _mark_item()
local cDesc 
local nDamage
local nGlass_no

if field->art_marker == "*"
	
	if pitanje(,"Ukloniti marker sa ove stavke (D/N) ?", "D") == "D"
		
		replace field->art_marker with SPACE(1)
		replace field->art_desc with SPACE(150)
		replace field->damage with 0
		replace field->glass_no with 0

		Beep(1)
		
		return DE_REFRESH
	else
		return DE_CONT
	endif
	
else
	
	if _get_it_desc( @cDesc, field->doc_it_qtty, ;
		@nDamage, @nGlass_no ) > 0
	
		replace field->art_marker with "*"
		replace field->art_desc with cDesc
		replace field->damage with nDamage
		replace field->glass_no with nGlass_no
	
		beep(2)

		return DE_REFRESH
	else
		return DE_CONT
	endif
endif

return



// ----------------------------------------------------------------
// unesi opis stavke...
// ----------------------------------------------------------------
static function _get_it_desc( cDesc, nQty, nDamage, nGlass_no )
local nRet := 1
private GetList:={}

Box(, 6, 70)
	
	cDesc := SPACE(150)
	nDamage := 0
	nGlass_no := 1
	
	@ m_x + 1, m_y + 2 SAY " *** Unos podataka o ostecenjima " ;
		COLOR "BG+/B"
	
	@ m_x + 3, m_y + 2 SAY "odnosi se na staklo br:" GET nGlass_no ;
		PICT "99"

	@ m_x + 4, m_y + 2 SAY " broj ostecenih komada:" GET nDamage ;
		PICT "999999.99" VALID nDamage <= nQty
	
	@ m_x + 6, m_y + 2 SAY "opis:" GET cDesc PICT "@S60" ;
		VALID !EMPTY(cDesc)
	
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet



// -----------------------------------------
// unesi opis promjene
// -----------------------------------------
static function _get_ch_desc( cDesc )
private GetList:={}

Box(, 5, 70)
	
	cDesc := SPACE(150)
	
	@ m_x + 1, m_y + 2 SAY " *** Unos opisa promjene " COLOR "BG+/B"
	
	@ m_x + 3, m_y + 2 SAY "opis:" GET cDesc PICT "@S60" 
	
	read
BoxC()

return 


// ---------------------------------------------------------
// kalkulise ostecenja po odredjenom artiklu sa naloga
// 
// params:
//  * nDoc_no - broj dokumenta
//  * nDoc_it_no - broj stavke dokumenta
//  * nArt_id - id artikla
//  * nElem_no - broj elementa u artiklu (1 ili 2 ili 3 ...)
// ---------------------------------------------------------
function calc_dmg( nDoc_no, nDoc_it_no, nArt_id, nElem_no )
local nRet := 0
local nTArea := SELECT()
local cLogType := PADR("21",3)

if nElem_no == nil
	nElem_no := 0
endif

select doc_log
set order to tag "2"
seek docno_str( nDoc_no ) + cLogType

if !FOUND()
	select (nTArea)
	return nRet
endif

// prodji kroz logove tipa "21" - lom
do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_type == cLogType

	nDoc_log_no := field->doc_log_no

	select doc_lit
	seek docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

	do while !EOF() .and. field->doc_no == nDoc_no .and. ;
		field->doc_log_no == nDoc_log_no

		// field->int_1 = stavka naloga
		// field->int_2 = broj elementa artikla
		// field->num_2 = broj komada slomljenih

		if field->art_id = nArt_id
			
			if field->int_1 = nDoc_it_no .and. ;
				if( nElem_no > 0, ;
					field->int_2 = nElem_no, .t. )
				
				nRet += field->num_2

			endif

		endif

		skip
	enddo
	
	select doc_log
	skip

enddo

select (nTArea)

return nRet

