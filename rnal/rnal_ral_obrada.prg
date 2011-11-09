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
// kreira tabelu ral
// --------------------------------------
function c_tbl_ral()
local aDbf := {}
local cPath := SIFPATH
local cTable := "RAL"

AADD( aDbf, { "id", "N", 5, 0 })
AADD( aDbf, { "gl_tick", "N", 2, 0 })
AADD( aDbf, { "desc", "C", 50, 0 })
AADD( aDbf, { "en_desc", "C", 50, 0 })
AADD( aDbf, { "col_1", "N", 8, 0 })
AADD( aDbf, { "col_2", "N", 8, 0 })
AADD( aDbf, { "col_3", "N", 8, 0 })
AADD( aDbf, { "col_4", "N", 8, 0 })
AADD( aDbf, { "colp_1", "N", 12, 5 })
AADD( aDbf, { "colp_2", "N", 12, 5 })
AADD( aDbf, { "colp_3", "N", 12, 5 })
AADD( aDbf, { "colp_4", "N", 12, 5 })

if !FILE( cPath + cTable + ".DBF" )
	DbCreate2( cPath + cTable, aDbf )
endif

CREATE_INDEX("1", "STR(id,5)+STR(gl_tick,2)", cPath + cTable, .t.)
CREATE_INDEX("2", "desc", cPath + cTable, .t.)

return


// --------------------------------------
// otvara sifranik ral
// --------------------------------------
function sif_ral( cId, dx, dy )
local cHeader := "RAL"
private ImeKol
private Kol

O_RAL

// setuj kolone tabele
set_a_kol( @ImeKol, @Kol )

PostojiSifra(F_RAL, 1, 12, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

return



// ----------------------------------------
// obrada tipki na tastaturi
// ----------------------------------------
static function key_handler( cCh )
return DE_CONT


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("RAL", 5), {|| id }, "id", {|| .t.}, {|| .t.}})
AADD(aImeKol, {PADC("Debljina", 8), {|| gl_tick }, "gl_tick", ;
	{|| .t.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(desc, 20)}, "desc"})
AADD(aImeKol, {PADC("en.naziv", 20), {|| PADR(en_desc, 20)}, "en_desc"})
AADD(aImeKol, {PADC("Boja 1", 10), {|| col_1 }, "col_1"})
AADD(aImeKol, {PADC("% boje 1", 12), {|| colp_1 }, "colp_1"})
AADD(aImeKol, {PADC("Boja 2", 10), {|| col_2 }, "col_2"})
AADD(aImeKol, {PADC("% boje 2", 12), {|| colp_2 }, "colp_2"})
AADD(aImeKol, {PADC("Boja 3", 10), {|| col_3 }, "col_3"})
AADD(aImeKol, {PADC("% boje 3", 12), {|| colp_3 }, "colp_3"})
AADD(aImeKol, {PADC("Boja 4", 10), {|| col_4 }, "col_4"})
AADD(aImeKol, {PADC("% boje 4", 12), {|| colp_4 }, "colp_4"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------------
// vraca ral informacije
// --------------------------------------
function get_ral( nTick )
local cRet := ""
local nRal := 0
local nRoller := 1
local GetList := {}
local nTarea := SELECT()

if nTick == nil
	nTick := 0
endif

O_RAL

Box(,2,40)

	@ m_x + 1, m_y + 2 SAY "Valjak (1/2/3):" GET nRoller PICT "9" ;
		VALID sh_roller( nRoller )
	@ m_x + 2, m_y + 2 SAY "         RAL ->" GET nRal PICT "99999"
	
	read

BoxC()

// probaj naci po debljini...
select ral
go top
seek STR( nRal, 5 ) + STR( nTick, 2 )

if !FOUND()
	// probaj samo po ral-u
	go top
	seek STR( nRal, 5 )

	if !FOUND()
		// otvori sifrarnik pa izaberi...
		sif_ral( @nRal )
	endif
endif

// uzmi vrijednost iz polja
nTick := field->gl_tick

select (nTarea)

if LastKey() == K_ESC
	return cRet
endif

// format stringa je:
// ------------------
// "RAL:1000#4#80"
//
// 1000 - oznaka ral
// 4 - debljina, 0 - default
// 80 - valjak gramaza...

cRet := "RAL:" + ALLTRIM( STR( nRal, 5 )) + ;
	"#" + ALLTRIM(STR(nTick, 2)) + ;
	"#" + ALLTRIM(STR( _g_roller( nRoller ) ))

return cRet


// --------------------------------------------
// ispisuje vrijednost valjka
// --------------------------------------------
static function sh_roller( nRoll )
local nValue := _g_roller( nRoll )
local cValue

cValue := "-> " + ALLTRIM(STR(nValue)) + " gr/m2"

@ m_x + 1, col() + 2 SAY PADR(cValue, 12)

return .t.



// ------------------------------------------
// vraca roller dimenziju
// ------------------------------------------
static function _g_roller( nRoll )
local nVal := 80

do case
	case nRoll = 1
		nVal := 80
	case nRoll = 2
		nVal := 100
	case nRoll = 3
		nVal := 150
endcase

return nVal


// ----------------------------------------
// vraca informaciju o ral-u
// nRal - oznaka RAL-a (numeric)
// nTick - debljina stakla
// ----------------------------------------
function g_ral_value( nRal, nTick, nRoller )
local xRet := ""
local nTArea := SELECT()
O_RAL

if nTick == nil
	nTick := 0
endif

if nRoller == nil
	nRoller := 80
endif

if nTick = 0
	seek STR(nRal, 5)
else
	seek STR(nRal, 5) + STR(nTick, 2)
endif

if FOUND()
	
	// opis
	xRet += " "
	xRet += ALLTRIM( field->en_desc )
	xRet += " "
	xRet += ALLTRIM( STR(nRoller) ) + " gr/m2" 

	// prva boja
	if field->col_1 <> 0 .and. field->colp_1 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_1)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_1, 12, 2)) + "%"
		xRet +=  ")"
	endif

	// druga boja
	if field->col_2 <> 0 .and. field->colp_2 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_2)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_2, 12, 2)) + "%"
		xRet +=  ")"
	endif
	
	// treca boja
	if field->col_3 <> 0 .and. field->colp_3 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_3)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_3, 12, 2)) + "%"
		xRet +=  ")"
	endif
	
	// cetvrta boja
	if field->col_4 <> 0 .and. field->colp_4 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_4)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_4, 12, 2)) + "%"
		xRet +=  ")"
	endif

endif

if !EMPTY(xRet)
	xRet := "RAL-" + ALLTRIM(STR(field->id,5)) + ":" + xRet
endif

select (nTArea)
return xRet


// ----------------------------------------------
// ispisi utrosak boja
// ----------------------------------------------
function sh_ral_calc( aColor )
local cTmp := ""
local i

// 1. 152000 (54.00%) -> 0.091 kg
// 2. 182000 (44.00%) -> 0.072 kg
// itd....

? "RAL: utrosak boja (kg)"
? "-----------------------------------"

for i := 1 to LEN(aColor)

	cTmp := STR(i, 1) + ". " + PADR( STR(aColor[i, 1], 8), 8 ) + ;
		PADR(" (" + STR(aColor[i, 2], 12, 2) + "%" + ") ", 12) + ;
		" -> " + PADR( STR(aColor[i, 3], 15, 3), 12 ) + " kg"

	? cTmp
next

return



// ----------------------------------------------
// izracunaj ukupni utrosak boja
//
// nRal - ral oznaka
// nTick - debljina stakla
// nRoller - valjak 
// nUm2 - ukupna kvadratura stakla
// ----------------------------------------------
function calc_ral( nRal, nTick, nRoller, nUm2 )
local nTArea := SELECT()
local nColor1 := 0.00000000000
local nColor2 := 0.00000000000
local nColor3 := 0.00000000000
local nColor4 := 0.00000000000
local aColor := {}

O_RAL
go top
seek STR(nRal, 5) + STR(nTick, 2)

if FOUND()
	
	nColor1 := c_ral_color( field->colp_1, nUm2, nRoller )
	nColor2 := c_ral_color( field->colp_2, nUm2, nRoller )
	nColor3 := c_ral_color( field->colp_3, nUm2, nRoller )
	nColor4 := c_ral_color( field->colp_4, nUm2, nRoller )
	
	if nColor1 <> 0
		AADD( aColor, { field->col_1, field->colp_1, nColor1 } )
	endif
	if nColor2 <> 0
		AADD( aColor, { field->col_2, field->colp_2, nColor2 } )
	endif
	if nColor3 <> 0
		AADD( aColor, { field->col_3, field->colp_3, nColor3 } )
	endif
	if nColor4 <> 0
		AADD( aColor, { field->col_4, field->colp_4, nColor4 } )
	endif

endif

select (nTArea)

return aColor



// --------------------------------------------------------------
// izracunaj utrosak boje u "kg"
//
// nPercent = procenat boje
// nRoller = valjak (gr/m2)
// nUm2 = ukupna kvadratura stakla
// 
// --------------------------------------------------------------
function c_ral_color( nPercent, nUm2, nRoller )
local nRet := 0

if nPercent = 0
	return nRet
endif

nRet := Round2( (((nPercent / 100) * nUm2 * nRoller ) / 1000 ), 12 )

return nRet


