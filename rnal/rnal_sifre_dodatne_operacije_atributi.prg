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


static _tb_direkt
static _aop_id
static __wo_id

// ------------------------------------------------
// otvara sifrarnik dodatnih operacija, atributa
// ------------------------------------------------
function s_aops_att(cId, nAop_id, cAop_desc, lwo_ID, dx, dy)
local nTArea
local cHeader
private ImeKol
private Kol

if nAop_id == nil
	nAop_id := -1
endif

if cAop_desc == nil
	cAop_desc := ""
endif

if lwo_ID == nil
	lwo_ID := .f.
endif

_aop_id := nAop_id
__wo_id := lwo_ID

nTArea := SELECT()
cHeader := "Dodatne operacije, atributi /"

select aops_att
set order to tag "1"

set_a_kol(@ImeKol, @Kol)

if VALTYPE(cId) == "C"
	//try to validate
	if VAL(cId) <> 0
		
		cId := VAL(cId)
		nAop_id := -1
		cAop_Desc := ""
		
	endif
endif

aop_filter(nAop_id, cAop_desc)

private gTBDir := "N"

cRet := PostojiSifra(F_AOPS_ATT, 1, 10, 70, cHeader, @cId, dx, dy, {|Ch| key_handler(Ch) })

if VALTYPE(cAop_desc) == "N"
	cAop_desc := STR(cAop_desc, 10)
endif

if nAop_id > 0 .or. cAop_desc <> ""
	set filter to
endif

if LastKey() == K_ESC
	cId := 0
endif

select (nTArea)

return cRet


// ---------------------------------------------------
// setuje filter na sifraniku
// ---------------------------------------------------
static function aop_filter( nAop_id, cAop_desc )
local cFilter := ""

if nAop_id > 0
	cFilter += 'aop_id == ' + aopid_str(nAop_id)
endif

if !EMPTY(cAop_desc)

	if !EMPTY(cFilter)
		cFilter += ' .and. '
	endif

	cFilter += 'ALLTRIM(UPPER(aop_att_desc)) = ' + cm2str(UPPER(ALLTRIM(cAop_desc))) 
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
	
	AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(aop_att_id)}, "aop_att_id", {|| _inc_id(@waop_att_id, "AOP_ATT_ID"), .f.}, {|| .t.}})

endif

AADD(aImeKol, {PADR("Dod.op.ID", 15), {|| PADR(g_aop_desc( aop_id ), 15) }, "aop_id", {|| set_aop_id(@waop_id) }, {|| s_aops( @waop_id ), show_it(g_aop_desc(waop_id))  }})
AADD(aImeKol, {PADR("Opis", 40), {|| PADR(aop_att_full, 40)}, "aop_att_full"})
AADD(aImeKol, {PADR("Skr. opis (sifra)", 20), {|| PADR(aop_att_desc, 20)}, "aop_att_desc"})

if aops_att->(fieldpos("AOP_ATT_JO")) <> 0
	AADD(aImeKol, { PADR("Joker", 20), {|| aop_att_joker }, "aop_att_joker"})
endif

AADD(aImeKol, {PADC("u art.naz ( /*)", 15), {|| PADR(in_art_desc, 15)}, "in_art_desc"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// ---------------------------------------------------
// setuje polje aop_id pri unosu automatski
// ---------------------------------------------------
static function set_aop_id( nAop_id )
if _aop_id > 0
	nAop_id := _aop_id
	return .f.
else
	return .t.
endif
return 


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
do case
	case Ch == K_CTRL_N .or. Ch == K_F4
		__wo_id := .f.
		set_a_kol(@ImeKol, @Kol)
		return DE_CONT

endcase
return DE_CONT


// -------------------------------
// convert aop_att_id to string
// -------------------------------
function aop_att_str(nId)
return STR(nId, 10)


// -----------------------------------------------
// dodatna operacija atribut u naziv artikla ???
// -----------------------------------------------
function aop_att_in_desc( nAop_att_id )
local lRet := .f.
local nTArea := SELECT()

select aops_att
set order to tag "1"
go top
seek aop_att_str( nAop_att_id )

if FOUND()
	if field->in_art_desc == "*"
		lRet := .t.
	endif
endif

select (nTArea)
return lRet



// -------------------------------
// get aop_att_joker by aopatt_id
// -------------------------------
function g_aatt_joker( nAopatt_id )
local cAttJoker := ""
local nTArea := SELECT()

O_AOPS_ATT
select aops_att
set order to tag "1"
go top
seek aop_att_str(nAopatt_id)

if FOUND()

	// ako ima polja ?
	if aops_att->( fieldpos("AOP_ATT_JO") ) == 0
		
		// uzmi iz opisa
		cAttJoker := ALLTRIM( g_aop_att_desc( nAopatt_id, .t., .f. ) )
		return cAttJoker
		
	endif
	
	if !EMPTY(field->aop_att_joker)
		cAttJoker := ALLTRIM(field->aop_att_joker)
	endif
endif

select (nTArea)

return cAttJoker




// -------------------------------
// get aop_desc by aop_id
// -------------------------------
function g_aop_att_desc( nAop_att_id, lEmpty, lFullDesc )
local cAopAttDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cAopAttDesc := ""
endif

if lFullDesc == nil
	lFullDesc := .t.
endif

O_AOPS_ATT
select aops_att
set order to tag "1"
go top
seek aop_att_str(nAop_att_id)

if FOUND()
	if lFullDesc == .t.
		if !EMPTY(field->aop_att_full)
			cAopAttDesc := ALLTRIM(field->aop_att_full)
		endif
	else
		if !EMPTY(field->aop_att_desc)
			cAopAttDesc := ALLTRIM(field->aop_att_desc)
		endif
	endif
endif

// izbaci konfiguratore ako postoje
rem_jokers( @cAopAttDesc )
//cAopAttDesc := STRTRAN( cAopAttDesc, "#G_CONFIG#", "" )
//cAopAttDesc := STRTRAN( cAopAttDesc, "#HOLE_CONFIG#", "" )
//cAopAttDesc := STRTRAN( cAopAttDesc, "#STAMP_CONFIG#", "" )
//cAopAttDesc := STRTRAN( cAopAttDesc, "#PREP_CONFIG#", "" )

select (nTArea)

return cAopAttDesc



// ---------------------------------------------
// da li se koristi konfigurator stranica
// ako se koristi setuj cVal
// ---------------------------------------------
function is_g_config( cVal, nAop_att_id, ;
		nHeigh, nWidth, nTick )

local nTArea := SELECT()
local lGConf := .f.
local lHConf := .f.
local lStConf := .f.
local lPrepConf := .f.
local lRalConf := .f.

local cConf := ""

local cJoker

// dimension from 1 to 4
local cV1
local cV2
local cV3
local cV4

// radijusi....
local nR1 := 0 
local nR2 := 0
local nR3 := 0
local nR4 := 0

// ako vec postoji vrijednost nista....
// preskoci...
if !EMPTY( cVal )
	return .t.
endif

O_AOPS_ATT
select aops_att
set order to tag "1"
go top
seek aop_att_str(nAop_att_id)

if FOUND()
	
	// standarni konfigurator
	if "#G_CONFIG#" $ field->aop_att_full
		
		lGConf := .t.
	
	// konfigurator busenja rupa
	elseif "#HOLE_CONFIG#" $ field->aop_att_full
		
		lHConf := .t.
	
	// RAL - konfigurator
	elseif "#RAL_CONFIG#" $ field->aop_att_full
		
		lRalConf := .t.

	// konfigurator pozicije pecata
	elseif "#STAMP_CONFIG#" $ field->aop_att_full
		
		lStConf := .t.
	
	elseif "#PREP_CONFIG#" $ field->aop_att_full
		
		lPrepConf := .t.

	elseif "#" $ field->aop_att_full
	
		lGConf := .f.

		aTmp := TokToNiz( field->aop_att_full, "#" )
		cVal := PADR(  ALLTRIM(aTmp[2]) , 150 )
		
		return .t.
		
	endif
	
	// find joker
	if aops_att->(FieldPos("AOP_ATT_JO")) <> 0
		// uzmi iz polja joker
		cJoker := ALLTRIM( field->aop_att_joker )
	else
		// uzmi iz opisa
		cJoker := ALLTRIM( field->aop_att_desc )
	endif
	
endif

// show glass config
if lGConf == .t.

	if glass_config( nWidth, nHeigh, @cV1, @cV2, @cV3, @cV4, ;
			@nR1, @nR2, @nR3, @nR4 ) == .t.
		
		// shema za G_CONFIG
		// 
		//            val1
		//   val2               val3
		//            val4
		//
		// val 1/4 - sirine stakla (gornja/donja)
		// val 2/3 - visine stakla (gornja/donja)
		
		
		// get string...
		cVal := "#"
		
		// prvo stranice
		if cV1 == "D"	
			cVal += "D1#" 
		endif
	
		if cV2 == "D"
			cVal += "D2#"
		endif
		
		if cV3 == "D"
			cVal += "D3#"
		endif
	
		if cV4 == "D"
			cVal += "D4#"
		endif

		// zatim radijusi

		if nR1 <> 0
			cVal += "R1=" + ALLTRIM(STR(nR1)) + "#"
		endif

		if nR2 <> 0
			cVal += "R2=" + ALLTRIM(STR(nR2)) + "#"
		endif

		if nR3 <> 0
			cVal += "R3=" + ALLTRIM(STR(nR3)) + "#"
		endif
		
		if nR4 <> 0
			cVal += "R4=" + ALLTRIM(STR(nR4)) + "#"
		endif


		// formira string
		// 
		// npr: kod brusenja stranica gornje i donje stranice
		// i obrade 1 radijusa
		//
		// joker + ":" + string vrijednosti 
		// 
		// <AOP_B_STR>:#D1#D4#R1=200#
		
		cVal := PADR( cJoker + ":" + cVal, 150 )
	endif
	
endif

if lHConf == .t.

	// konfigurator busenja rupa
	cVal := hole_config( cJoker )
	
endif

if lRalConf == .t.
	cVal := PADR( get_ral( nTick ), 150 )
endif

if lStConf == .t. .and. ;
	pitanje(,"Unjeti pozicije pecata (D/N) ?", "D") == "D"
	
	// konfigurator pozicije pecata
	cVal := stamp_config( cJoker, nWidth, nHeigh )

endif

if lPrepConf == .t.
	
	// konfigurator prepusta
	cVal := prepust_config( cJoker, nWidth, nHeigh, 0, 0, 0, 0 )

endif

select (nTArea)

return .t.


// ---------------------------------------------------
// vraca formiran string za vrijednost operacije
// ---------------------------------------------------
function g_aop_value( cVal )
local cRet := ""
local aTmp := {}
local aRal := {}

if EMPTY(cVal)
	return ""
endif

cVal := ALLTRIM( cVal )

// "<AOP_B_STR>:#D1#D2#"
// "<AOP_B_STR>" + "#D1#D2#"

aTmp := TokToNiz( cVal, ":" )

if aTmp == nil .or. LEN(aTmp) == 0 .or. LEN(aTmp) == 1 
	return cVal
endif

do case
	
	// brusenje stranica
	case aTmp[1] == "<A_B>" 
	
		cRet := _cre_aop_str( aTmp[2] )	
		
	// zaobljavanje
	case aTmp[1] == "<A_Z>"
		
		cRet := _cre_aop_Str( aTmp[2] )

	// pozicija peèata
	case aTmp[1] == "STAMP"
		
		cRet := stamp_read( cVal )
		
	// rupe i dimenzije
	case aTmp[1] == "<A_BU>"

		cRet := hole_read( cVal )
	
	// prepust
	case aTmp[1] == "<A_PREP>"

		cRet := prep_read( cVal )

	case aTmp[1] == "RAL"

		aRal := TokToNiz( aTmp[2], "#" )
		cRet := g_ral_value( VAL(aRal[1]), ;
				VAL(aRal[2]), VAL(aRal[3]) )
endcase


return cRet



static function _cre_aop_str( cStr )
local cRet := ""
local aTmp := {}

cStr := ALLTRIM( cStr )


aTmp := TokToNiz( cStr, "#" )

if aTmp == nil .or. LEN(aTmp) == 0
	return ""
endif


if LEN(aTmp) == 4 .and. ;
	( aTmp[1] + aTmp[2] + aTmp[3] + aTmp[4] == "D1D2D3D4" )
	cRet := "kompletno staklo"
elseif LEN(aTmp) < 4 
	cRet := "pogledaj skicu"
else
	cRet := "-"
endif

return cRet





