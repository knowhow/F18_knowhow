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


// ---------------------------------------------------------------
// pregled ucinka po operaterima, koliko naloga su ostvarili 
// u periodu
// ---------------------------------------------------------------
function r_op_docs()
local dD_From := CTOD("")
local dD_to := DATE()
local nOper := 0

//o_sif_tables()

// daj uslove izvjestaja
if _g_vars( @dD_From, @dD_To, @nOper ) == 0
 	return 
endif

// kreiraj report
_cre_op( dD_from, dD_to, nOper )

// filuj nazive operatera
_fill_op()

// stampaj izvjestaj
_p_op_docs( dD_from, dD_to )

return


// ----------------------------------------------------
// stampanje izvjestaja
// ----------------------------------------------------
static function _p_op_docs( dD_from, dD_to )
local cLine
local nCount := 0
local nT_op := 0
local nT_cl := 0
local nT_re := 0
local nT_to := 0
local nCol := 1

START PRINT CRET

?

_rpt_descr( dD_from, dD_to )
_rpt_head( @cLine )

select _tmp1
go top

do while !EOF()
	
	++ nCount

	? PADL( ALLTRIM(STR( nCount )), 3 ) + "."
	
	@ prow(), pcol() + 1 SAY PADR( ALLTRIM( field->op_desc ) + ;
		" (" + ALLTRIM(STR( field->operater)) + ")", 40 )
	
	@ prow(), nCol := pcol() + 1 SAY field->o_count
	@ prow(), pcol() + 1 SAY field->c_count
	@ prow(), pcol() + 1 SAY field->r_count
	@ prow(), pcol() + 1 SAY field->d_total

	nT_op += field->o_count
	nT_cl += field->c_count
	nT_re += field->r_count
	nT_to += field->d_total

	skip
enddo

// ispisi total
? cLine

? "UKUPNO:"
@ prow(), nCol SAY nT_op
@ prow(), pcol() + 1 SAY nT_cl
@ prow(), pcol() + 1 SAY nT_re
@ prow(), pcol() + 1 SAY nT_to

? cLine

close all

FF
END PRINT

return


// ------------------------------------------------
// ispisi naziv izvjestaja po varijanti
// ------------------------------------------------
static function _rpt_descr( dD1, dD2 )
local cTmp := "rpt: "

cTmp += "Pregled obradjenih naloga po operaterima "

? cTmp

cTmp := "za period od " + DTOC( dD1 ) + " do " + DTOC( dD2 )

? cTmp

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head( cLine )
cLine := ""
cTxt := ""

cLine += REPLICATE("-", 4)
cLine += SPACE(1)
cLine += REPLICATE("-", 40) 
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)

cTxt += PADR("r.br", 4)
cTxt += SPACE(1)
cTxt += PADR("Operater", 40)
cTxt += SPACE(1)
cTxt += PADR("Otvoreni", 10)
cTxt += SPACE(1)
cTxt += PADR("Zatvoreni", 10)
cTxt += SPACE(1)
cTxt += PADR("Odbaceni", 10)
cTxt += SPACE(1)
cTxt += PADR("Ukupno", 10)

? cLine
? cTxt
? cLine

return

// ----------------------------------------------
// filuj nazive operatera u tabeli
// ----------------------------------------------
static function _fill_op()
select _tmp1
go top

// prodji kroz tabelu i napuni nazive
do while !EOF()

	replace field->op_desc with ;
		ALLTRIM( getfullusername( field->operater) ) 

	skip
enddo

go top

return



// ------------------------------------------------------------------------
// uslovi izvjestaja specifikacije
// ------------------------------------------------------------------------
static function _g_vars( dDatFrom, dDatTo, nOperater )

local nRet := 1
local nBoxX := 7
local nBoxY := 70
local nX := 1
local nTArea := SELECT()
local nVar1 := 1
private GetList := {}

Box(, nBoxX, nBoxY)

	@ m_x + nX, m_y + 2 SAY "*** Pregled naloga po operaterima"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Obuhvatiti period od:" GET dDatFrom
	@ m_x + nX, col() + 1 SAY "do:" GET dDatTo


	nX += 1

	@ m_x + nX, m_y + 2 SAY "Operater (0 - svi op.):" GET nOperater VALID {|| nOperater == 0 .or. p_users( @nOperater ) } PICT "999"
	
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_op( dD_from, dD_to, nOper  )
local nDoc_no

// kreiraj tmp tabelu
aField := _op_fields()

cre_tmp1( aField )
O__TMP1

// kreiraj indekse
index on STR( operater, 3 ) tag "1"

// otvori potrebne tabele
o_tables( .f. )

select docs
go top

Box(, 1, 50 )

do while !EOF()

	nDoc_no := field->doc_no

	@ m_x + 1, m_y + 2 SAY "... vrsim odabir stavki ... nalog: " + ALLTRIM( STR(nDoc_no) )
	
	nOp_id := field->operater_id

	// provjeri da li ovaj dokument zadovoljava kriterij
	
	// ovo su busy nalozi...
	if field->doc_status > 2
		skip
		loop
	endif

	if DTOS( field->doc_date ) > DTOS( dD_To ) .or. ;
		DTOS( field->doc_date ) < DTOS( dD_From )
	
		// datumski period
		skip
		loop

	endif

	if nOper <> 0

		// po operateru
		
		if ALLTRIM( STR( field->operater_id )) <> ;
			ALLTRIM( STR( nOper ) )
			
			skip
			loop

		endif
	endif

	// ubaci u tabelu
	_a_to_op( field->operater_id, field->doc_status )

	select docs
	skip

enddo

BoxC()

return


// ------------------------------------------------
// ubaci u tabelu
// ------------------------------------------------
static function _a_to_op( nOp_id, nStatus )
local nTArea := SELECT()

select _tmp1
set order to tag "1"
go top

seek STR( nOp_id, 3 ) 

if !FOUND()
	APPEND BLANK
	replace field->operater with nOp_id
endif

do case
	case nStatus == 0
		replace field->o_count with ( field->o_count + 1 )
	case nStatus == 1
		replace field->c_count with ( field->c_count + 1 )
	case nStatus == 2
		replace field->r_count with ( field->r_count + 1 )

endcase

// total uvijek saberi
replace field->d_total with ( field->o_count + ;
		field->c_count + field->r_count )

select (nTArea)
return



// -----------------------------------------------
// vraca strukturu polja tabele _tmp1
// -----------------------------------------------
static function _op_fields()
local aDbf := {}

AADD( aDbf, { "operater", "N",   3, 0 })
AADD( aDbf, { "op_desc",  "C",  40, 0 })
AADD( aDbf, { "o_count",  "N",  10, 0 })
AADD( aDbf, { "c_count",  "N",  10, 0 })
AADD( aDbf, { "r_count",  "N",  10, 0 })
AADD( aDbf, { "d_total",  "N",  10, 0 })

return aDbf

