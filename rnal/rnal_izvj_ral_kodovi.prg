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


// --------------------------------------
// utrosak boja kod RAL-a
// --------------------------------------
function rpt_ral_calc()
local dD_From
local dD_To
local nOper
local cRalList
local cColorList

if _get_vars( @dD_From, @dD_To, @nOper, ;
	@cRalList, @cColorList ) == 0
	return
endif

// kreiraj report
_cre_report( dD_from, dD_to, nOper, cRalList, cColorList )

// ispisi report
_r_ral_calc( dD_From, dD_to, nOper )

return


// ----------------------------------------------
// uslovi izvjestaja
// ----------------------------------------------
static function _get_vars( dD_f, dD_t, nOper, ;
	cRList, cColList )

dD_f := DATE() - 30
dD_t := DATE()
nOper := 0
cRList := SPACE(200)
cColList := SPACE(200)

Box(,6,60)
	@ m_x + 1, m_y + 2 SAY "Datum od:" GET dD_f
	@ m_x + 1, col() + 1 SAY "do:" GET dD_t
	@ m_x + 2, m_y + 2 SAY "Operater (0 - svi):" GET nOper ;
		VALID {|| nOper == 0 .or. p_users(@nOper) } ;
		PICT "999"
	@ m_x + 4, m_y + 2 SAY " RAL kodovi (prazno-svi):" GET cRList PICT "@S25"
	@ m_x + 5, m_y + 2 SAY "boje kodovi (prazno-sve):" GET cColList PICT "@S25"
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1



// ---------------------------------------------------------------
// glavna funkcija za kreiranje pomocne tabele
// ---------------------------------------------------------------
static function _cre_report( dD_f, dD_t, nOper, cRalLst, cColLst )
local aField
local cValue := ""
local aValue := {}
local aRal := {}
local nRal := 0
local nTick := 0
local nRoller := 0
local nDoc_no
local nDoc_it_no
local nDoc_it_el_no
local aArt := {}
local aArr := {}
local aElem := {}
local nElement := 0

// kreiraj tmp tabelu
aField := _rpt_fields()

cre_tmp1( aField )
O__TMP1
index on STR(r_color, 8) tag "1"

// otvori potrebne tabele
O_RAL
o_tables( .f. )

_main_filter( dD_f, dD_t, nOper )

Box(, 1, 50 )

do while !EOF()
	
	// uzmi podatke dokumenta da vidis treba li da se generise
	// u izvjestaj ?

	nDoc_no := field->doc_no
	nDoc_it_no := field->doc_it_no
	nDoc_it_el_no := field->doc_it_el_no

	select docs
	go top
	seek docno_str( nDoc_no )

	// provjeri uslove !!!

	// ako je rejected ili busy... preskoci
	if ( docs->doc_status == 2 .or. docs->doc_status == 3 )
		select doc_ops
		skip
		loop
	endif

	if nOper <> 0 .and. ( docs->operater_id <> nOper )
		select doc_ops
		skip
		loop
	endif

	// datum.....
	if DTOS(docs->doc_date) > DTOS(dD_t) .or. ;
		DTOS(docs->doc_date) < DTOS(dD_f)
		select doc_ops
		skip
		loop
	endif

	// vrni se nazad, idemo dalje
	select doc_ops

	// "RAL:1000#4#80"
	cValue := ALLTRIM( field->aop_value )
	// ukini "RAL:", to nam ne treba !
	cValue := STRTRAN( cValue, "RAL:", "" )

	// aRal[1] = 1000
	// aRal[2] = 4
	// aRal[3] = 80

	aRal := TokToNiz( cValue, "#" )
	// imamo i vrijednosti
	nRal := VAL( aRal[1] )
	nTick := VAL( aRal[2] )
	nRoller := VAL( aRal[3] )
	
	// provjeri uslov po listi
	if !EMPTY( cRalLst )
		if !(ALLTRIM(STR( nRal )) $ ALLTRIM( cRalLst ))
			select doc_ops
			skip
			loop
		endif
	endif

	select ral
	go top
	seek STR( nRal, 5 ) + STR( nTick, 2 )
	// provjeri uslov po listi boja
	if !EMPTY( cColLst )
		if !(ALLTRIM(STR( field->col_1 )) $ ALLTRIM( cColLst )) .or. ;
		 !(ALLTRIM(STR( field->col_2 )) $ ALLTRIM( cColLst )) .or. ;
		 !(ALLTRIM(STR( field->col_3 )) $ ALLTRIM( cColLst )) .or. ;
		 !(ALLTRIM(STR( field->col_4 )) $ ALLTRIM( cColLst ))
			select doc_ops
			skip
			loop
		endif
	endif

	@ m_x + 1, m_y + 2 SAY "dokument: " + docno_str( nDoc_no )

	select doc_it
	go top
	seek docno_str( nDoc_no ) + docit_str( nDoc_it_no )
	
	nArt_id := field->art_id
	// koliko ima kvadrata
	nUm2 := c_ukvadrat( field->doc_it_qtty, ;
		field->doc_it_height, ;
		field->doc_it_widht) 

	// sada imam sve potrebne podatke za obracun
	aArr := calc_ral( nRal, nTick, nRoller, nUm2 )

	// dobio sam obracun u aArr sad ga treba upisati u 
	// pomocnu tabelu ...

	for i := 1 to LEN( aArr )
		app_to_tmp1( aArr[i, 1], aArr[i, 3] )
	next
	
	// idemo dalje...
	select doc_ops
	skip
enddo

BoxC()

return


// -------------------------------------------------
// dodaj u pomocnu tabelu
// -------------------------------------------------
static function app_to_tmp1( nColor, nTotal )
local nTArea := SELECT()

O__TMP1
go top
seek STR( nColor, 8 )

if !FOUND()
	append blank
	replace field->r_color with nColor
endif

replace field->c_total with ( field->c_total + nTotal )

select (nTArea)
return



// -----------------------------------------
// polja tabele izvjestaja
// -----------------------------------------
static function _rpt_fields()
local aRet := {}

AADD(aRet, { "r_color", "N", 8, 0 })
AADD(aRet, { "c_total", "N", 20, 8 })

return aRet


// -------------------------------------------------
// filter 
// -------------------------------------------------
static function _main_filter( dDFrom, dDTo, nOper )
local cFilter := ""

select doc_ops

cFilter := "'RAL:' $ aop_value"
set filter to &cFilter
go top

return

// ------------------------------------------------
// ispis reporta
// ------------------------------------------------
static function _r_ral_calc( dD_from, dD_to, nOper )
local nCnt := 0

select _tmp1
if RECCOUNT2() == 0
	msgbeep("nema podataka")
	return
endif

set order to tag "1"
go top

START PRINT CRET

? "Utrosak boja kod RAL obrade:"
?
? "Period od " + DTOC( dD_from ) + " do " + DTOC( dD_to )
? "---------------------------------------------------"
? "r.br * boja   * utrosak u kg            *"
? "----- -------- -------------------------"

do while !EOF()

	++ nCnt

	? STR( nCnt, 4) + "."
	@ prow(), pcol() + 1 SAY r_color
	@ prow(), pcol() + 1 SAY STR( c_total, 12, 4 )

	skip

enddo

close all

FF
END PRINT

return




