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



// -----------------------------------------------
// generisi standardna RNAL pravila
//      ako NE POSTOJE
// -----------------------------------------------
function gen_rnal_rules()
local nTArea := SELECT()

O_FMKRULES

// element CODE_GEN, staklo
in_elcode_rule("G", "<GL_TICK>#<GL_TYPE>", ;
	"Sifra stakla, glass code")

// element CODE_GEN, distancer
in_elcode_rule("F", "<FR_TYPE>#<FR_TICK>#<FR_GAS>", ;
	"Sifra distancera, frame code")

select (nTArea)
return


// -----------------------------------------------
// ubacuje pravilo za formiranje naziva elementa
// -----------------------------------------------
static function in_elcode_rule( cElCond, cRule, cRuleName )
local cModul
local cRuleObj
local cErrMsg
local nLevel := 5
local cRuleC3
local cRuleC4
local cRuleC7

cTRule := r_elem_code( cElCond )

if !EMPTY(cTRule)
	return
endif
	
cModul := g_rulemod( "RNAL" )
cRuleObj := g_ruleobj("ARTICLES")
cErrMsg := "-"
cRuleC3 := g_rule_c3("CODE_GEN")
cRuleC4 := g_rule_c4( cElCond )

select fmkrules
set order to tag "1"
go bottom

nNrec := field->rule_id + 1

append blank

_rec := dbf_get_rec()
_rec["rule_id"] := nNrec
_rec["modul_name"] := cModul
_rec["rule_obj"] := cRuleObj
_rec["rule_no"] := 1
_rec["rule_name"] := cRuleName
_rec["rule_ermsg"] := cErrMsg
_rec["rule_level"] := nLevel
_rec["rule_c3"] := cRuleC3
_rec["rule_c4"] := cRuleC4
_rec["rule_c7"] := cRule

update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )

return



// -----------------------------------------------
// setovanje specificnih rules kolona
// -----------------------------------------------
function g_rule_cols_rnal()
local aCols := {}

AADD( aCols, { "cond.1", {|| rule_c1 }, "rule_c1", {|| .t.}, {|| .t.} })
AADD( aCols, { "cond.2", {|| rule_c2 }, "rule_c2", {|| .t.}, {|| .t.} })
AADD( aCols, { "cond.3", {|| rule_c3 }, "rule_c3", {|| .t.}, {|| .t.} })
AADD( aCols, { "cond.4", {|| rule_c4 }, "rule_c4", {|| .t.}, {|| .t.} })
AADD( aCols, { "cond.5", {|| rule_c5 }, "rule_c5", {|| .t.}, {|| .t.} })
AADD( aCols, { "cond.6", {|| rule_c6 }, "rule_c6", {|| .t.}, {|| .t.} })
AADD( aCols, { "cond.7", {|| rule_c7 }, "rule_c7", {|| .t.}, {|| .t.} })

return aCols


// ------------------------------------------
// vraca block za pregled sifrarnika
// ------------------------------------------
function g_rule_block_rnal()
local bBlock 

bBlock := {|| ed_rules() }

return bBlock


// ------------------------------------------
// ispravka sifrarnika rules
// ------------------------------------------
static function ed_rules()
return DE_CONT



// -----------------------------------------------------------
// vraca iz pravila kod za formiranje naziva elementa
// params:
//   cElCond - element condition - tip elementa
//
// pravilo je sljedece:
// 
// modul_name = RNAL
// rule_obj = ARTICLES
// rule_c1 = <CODE_GEN> "CODE_GEN" - generacija "kod"-a
// rule_c2 = cElCond - tip elementa "F" / "G" ili ....
// -----------------------------------------------------------
function r_elem_code( cElCond )
local cCode := ""
local cModul
local cRuleType
local cObj
local nTArea := SELECT()

cModul := g_rulemod( "RNAL" )
cObj := g_ruleobj( "ARTICLES" )
cRuleType := g_rule_c3( "CODE_GEN" )
cElCond := g_rule_c4( cElCond )

O_FMKRULES
select fmkrules
set order to tag "ELCODE"
go top

seek cModul + cObj + cRuleType + cElCond

if FOUND()
	cCode := ALLTRIM( field->rule_c7 )
endif

select (nTArea)

return cCode

// ----------------------------------------------
// validacija errora - pravila
// ----------------------------------------------
static function err_validate( nLevel )
local lRet := .f.

if nLevel <= 3

	lRet := .t.
	
elseif nLevel == 4
	
	if Pitanje(, "Zelite zanemariti ovo pravilo (D/N) ?", "N" ) == "D"
	
		lRet := .t.
	
	endif

endif

return lRet


// -----------------------------------------------------------
// vraca matricu sa pravilima za shemu generisanja elemenata
// nType - tip artikla, jednostruki, dvostruki itd..
// -----------------------------------------------------------
function r_el_schema( nType )
local aSchema
local nTArea := SELECT()
local nTmp
local aTmp

local cObj := g_ruleobj( "ARTICLES" )
local cCond := g_rule_c3( "AUTO_ELEM" )
local cMod := g_rulemod( "RNAL" )

// default schema
aSchema := {}

O_FMKRULES
select fmkrules
set order to tag "ELCODE"
go top

seek cMod + cObj + cCond

do while !EOF() .and. field->modul_name == cMod ;
		.and. field->rule_obj == cObj ;
		.and. field->rule_c3 == cCond
	
	if !EMPTY( field->rule_c4 ) 
		
		aTmp := TokToNiz( ALLTRIM(field->rule_c4), "-" )
		
		// val = 1-SH1
		// aTmp = ['1', 'SH1']
		
		nTmp := VAL( aTmp[1] )
		
		if nTmp == nType
			
			// ubaci pravilo...
			AADD( aSchema, { ALLTRIM( field->rule_c7 ) } )
		
		endif
	
	endif
	
	skip
	
enddo

select (nTArea)


return aSchema




// -------------------------------------------
// pravila za sifre iz FMK / otpremnica
// -------------------------------------------
function rule_s_fmk( cField, nTickness, cType, cKind, cQttyType  )
local nErrLevel := 0
local cReturn := ""

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	cReturn := _rule_s_fmk( cField, nTickness, cType, cKind, @cQttyType )

endif

return cReturn


// ---------------------------------------------
// uzima sifru za FMK kod prenosa otpremnice
// cQttyType se setuje ovom funkcijom
//   
// ---------------------------------------------
static function _rule_s_fmk( cField, nTickness, cType, cKind, cQttyType )

local nReturn := 0
local nTArea := SELECT()

local cObj := "FMK_OTPREMNICA"
local cCond := ALLTRIM(cField)
local cMod := "RNAL"

local aTTick := {}

local nErrLevel
local cKtoList
local cNalog
local cReturn := ""

O_FMKRULES
select fmkrules
set order to tag "ITEM1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c5( cCond )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj ) ;
		.and. field->rule_c5 == g_rule_c5( cCond )
	
	// specificni tip stakla... npr: samo "F"
	if !EMPTY( cType )
		
		if ALLTRIM( field->rule_c6 ) == "ALL" 
			// to je to......
		elseif ALLTRIM( field->rule_c6 ) <> ALLTRIM( cType )
			// idi dalje
			skip
			loop
		endif
		
	endif

	// vrsta stakla RG ili naruèioc
	if !EMPTY( cKind )
		// ako nije ta vrsta preskoci...
		if ALLTRIM( field->rule_c4 ) <> ALLTRIM( cKind )
			skip
			loop
		endif
	endif

	// setuj vrijednost u kojoj æe se obraèunati kolièina
	cQttyType := ALLTRIM( field->rule_c3 )
	
	// to je rule -> debljina rang 0-20, uzmi u matricu
	// medjutim moze biti i prazno, onda su sve dimenzije stakla
	// u igri...
	// tada je aTTick[1] == "     "
	
	aTTick := TokToNiz( field->rule_c2, "-" )
	
	lRange := .f.
	
	if LEN(aTTick) > 1
		lRange := .t.
	endif
	
	// ispitaj debljinu
	
	// ako se koristi rangovi
	if lRange == .t.
		
		// trazi se vrijednost recimo od 0-20
		if nTickness >= VAL( aTTick[1] ) .and. ;
			nTickness <= VAL( aTTick[2] )
			
			cReturn := ALLTRIM( field->rule_c7 )
			
			// nasao sam izadji iz petlje
		
			exit
			
		endif

	else

		// sve dimenzije stakla, ako je prazno
		if EMPTY( ALLTRIM( aTTick[1] ) )
			
			cReturn := ALLTRIM( field->rule_c7 )
			exit
			
		endif
		
		// trazi se odredjena vrijendost, npr 20
		if nTickness = VAL( aTTick[1] )
			
			cReturn := ALLTRIM( field->rule_c7 )

			// nasao sam izadji iz petlje
			exit
		
		endif
	endif
	
	skip
	
enddo

select (nTArea)

return cReturn




// -------------------------------------------
// pravilo za unos operacija
// -------------------------------------------
function rule_aop( xVal, aArr, lShErr )
local nErrLevel := 0

if lShErr == nil
	lShErr := .t.
endif

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_aop_( xVal, aArr, lShErr )

endif

return err_validate( nErrLevel )



// ---------------------------------------------
// rule za unos opracija dokumenta
// 
//   aArr -> matrica sa definicijom artikla...
// ---------------------------------------------
static function _rule_aop_( xVal,  aArr, lShErr )

local nReturn := 0
local nTArea := SELECT()

local cObj := "ITEMS"
local cCond := "DOC_IT_AOP"
local cMod := "RNAL"

local nErrLevel
local cKtoList
local cNalog

O_FMKRULES
select fmkrules
set order to tag "ITEM1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c5( cCond )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj ) ;
		.and. field->rule_c5 == g_rule_c5( cCond )
	
	// pravilo: koja operacija <A_KSR> recimo
	cAopCond := ALLTRIM( fmkrules->rule_c7 )
	
	// operator, < > = <> itd...
	xOperCond := ALLTRIM( fmkrules->rule_c2 )
	
	// vrijednost koja se provjerava
	xValue := ALLTRIM( fmkrules->rule_c3 )
	
	// tip elementa
	xType := ALLTRIM( fmkrules->rule_c4 )

	// atribut elementa
	xAttType := ALLTRIM( fmkrules->rule_c6 )

	nErrLevel := fmkrules->rule_level

	// da li postoji artikal koji zadovoljava ovo ???
	if nErrLevel <> 0 .and. cAopCond == xVal .and. ;
		_r_aop_cond( xVal, xValue, xType, ;
			xAttType, xOperCond, aArr )
		
		nReturn := nErrLevel
		
		if lShErr == .t.
			sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		endif
		
		

		exit
	
	endif
	
	skip
	
enddo

select (nTArea)

return nReturn


// -------------------------------------------
// pravilo za polje u items
// -------------------------------------------
function rule_items( cField, xVal, aArr, lShErr )
local nErrLevel := 0

if lShErr == nil
	lShErr := .t.
endif

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_item_( cField, xVal, aArr, lShErr )

endif

return err_validate( nErrLevel )


// ---------------------------------------------
// rule za item u unosu. 1
// 
//   aArr -> matrica sa definicijom artikla...
// ---------------------------------------------
static function _rule_item_( cField, xVal,  aArr, lShErr )

local nReturn := 0
local nTArea := SELECT()

local cObj := "ITEMS"
local cCond := ALLTRIM(cField)
local cMod := "RNAL"

local nErrLevel
local cKtoList
local cNalog

O_FMKRULES
select fmkrules
set order to tag "ITEM1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c5( cCond )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj ) ;
		.and. field->rule_c5 == g_rule_c5( cCond )
	
	cArtCond := ALLTRIM( fmkrules->rule_c7 )
	xRCond := ALLTRIM( fmkrules->rule_c2 )
	xRVal1 := ALLTRIM( fmkrules->rule_c3 )
	xRVal2 := ALLTRIM( fmkrules->rule_c4 )

	nErrLevel := fmkrules->rule_level

	// da li postoji artikal koji zadovoljava ovo ???
	if nErrLevel <> 0 .and. ;
		_r_item_cond( xVal, xRCond, xRVal1, xRVal2 ) .and. ;
		_r_art_cond( aArr, cArtCond ) 
		
		nReturn := nErrLevel
		
		if lShErr == .t.
			sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		endif
		
		exit
	
	endif
	
	skip
	
enddo

select (nTArea)

return nReturn


// -------------------------------------------------------------
// provjera uslova r_item_cond()
// -------------------------------------------------------------
static function _r_item_cond( xVal, xCond, xRVal1, xRVal2 )
local lRet := .t.

xCond := ALLTRIM(xCond)

do case
	
	// provjera minimalne i maximalne vrijednosti
	case xCond == "MIN" 
		
		if xVal >= VAL(xRVal1) 
			lRet := .f.
		endif
	
	case xCond == "MAX"
		
		if xVal <= VAL(xRVal2)
			lRet := .f.
		endif
	

endcase

return lRet


// --------------------------------------------
//
// pravila nad artiklima
// 
// --------------------------------------------
function rule_articles( aArr )
local nErrLevel := 0

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_art1( aArr )

endif

return err_validate( nErrLevel )




// ---------------------------------------------
// rule za sastavljanje artikla ver. 1
// 
//   aArr -> matrica sa definicijom artikla...
// ---------------------------------------------
static function _rule_art1( aArr )

local nReturn := 0
local nTArea := SELECT()

local cObj := "ARTICLES"
local cCond := "ART_NEW"
local cMod := "RNAL"

local nErrLevel
local cKtoList
local cNalog

O_FMKRULES
select fmkrules
set order to tag "RNART1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c3( cCond )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj ) ;
		.and. field->rule_c3 == g_rule_c3( cCond )
	
	cArtcond := ALLTRIM( fmkrules->rule_c7 )

	nErrLevel := fmkrules->rule_level

	// postoji li pravilo koje ne-zadovoljava ???
	if nErrLevel <> 0 .and. ;
		_r_art_cond( aArr, cArtCond ) 
		
		nReturn := nErrLevel
		
		sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		
		exit
	
	endif
	
	skip
	
enddo

select (nTArea)

return nReturn


// ---------------------------------------------------------
// uslov za provjeru operacija i artikala
// ---------------------------------------------------------
static function _r_aop_cond( cSearch, cVal, cEl_type, ;
	cEl_att, cOper, aArr )

local lReturn := .f.
local nScan

nScan := 0

if cOper == "="

	nScan := ASCAN( aArr, { |xV| ALLTRIM(xV[2]) == ALLTRIM(cEl_type) ;
		.and. ALLTRIM(xV[4]) == ALLTRIM(cEl_att) ;
		.and. ALLTRIM(xV[5]) == ALLTRIM(cVal) } )

elseif cOper == ">"
	
	nScan := ASCAN( aArr, { |xV| ALLTRIM(xV[2]) == ALLTRIM(cEl_type) ;
		.and. ALLTRIM(xV[4]) == ALLTRIM(cEl_att) ;
		.and. ALLTRIM(xV[5]) > ALLTRIM(cVal) } )

elseif cOper == "<"
	
	nScan := ASCAN( aArr, { |xV| ALLTRIM(xV[2]) == ALLTRIM(cEl_type) ;
		.and. ALLTRIM(xV[4]) == ALLTRIM(cEl_att) ;
		.and. ALLTRIM(xV[5]) < ALLTRIM(cVal) } )

elseif cOper == "<>"
	
	nScan := ASCAN( aArr, { |xV| ALLTRIM(xV[2]) == ALLTRIM(cEl_type) ;
		.and. ALLTRIM(xV[4]) == ALLTRIM(cEl_att) ;
		.and. ALLTRIM(xV[5]) <> ALLTRIM(cVal) } )

endif

if nScan <> 0
	lReturn := .t.
endif

return lReturn



// ---------------------------------------------------------
// uslov za poredjenje artikla sa pravilom - matrice
//
// aArr - matrica sa osnovnim elementima artikla iz unosa
// cArtCond - rule artikla
// ---------------------------------------------------------
static function _r_art_cond( aArr, cArtCond )
local aTmp := {}
local aTmp2 := {}
local aArtArr := {}
local i
local i2
local nCond
local lExist := .t.

// example rule:
//
// "1:<GL_TYPE>=FL;<GL_TICK>=4#3:<GL_TYPE>=LO"


// prvo rastavi elemente sa "#"

aTmp := TokToNiz( cArtCond, "#" )

for i := 1 to LEN( aTmp )

	// "1:<GL_TYPE>=FL;<GL_TICK>=4"
	cTmp := ALLTRIM( aTmp[ i ] )

	// zatim rastavi broj elementa od uslova..... sa ":"
	aTmp2 := TokToNiz( cTmp, ":" )
	
	// i dobit ces sljedece:
	//
	// aTmp2[1] = "1"
	// aTmp2[2] = "<GL_TYPE>=FL;<GL_TICK>=4"
	
	// broj elementa = 1
	nElem := VAL( ALLTRIM( aTmp2[1] ) )
	
	// uslov je = <GL_TYPE>=FL;<GL_TICK>=4
	cElCond := ALLTRIM( aTmp2[2] )

	// sada razdvoji uslove, moze ih biti vise, sa ";"
	aElConds := TokToNiz( cElCond, ";" )
	
	// dodaj ih u nasu novu matricu....

	for i2 := 1 to LEN( aElConds )
		
		// dobije se:
		// 
		// aElConds[1] = "<GL_TYPE>=FL"
		// aElConds[2] = "<GL_TICK>=4"
		
		cECond := ALLTRIM( aElConds[ i2 ] )

		// rastavi sada uslov na djoker i vrijednost sa "="

		aECnds := TokToNiz( cECond, "=" )
		
		// i ubaci u novu matricu koja ce sluziti za usporedbu
		// .....
		// format matrice ce biti ovakav:
		//
		// aArtArr[1] = { 1, "<GL_TYPE>", "FL" }
		// aArtArr[2] = { 1, "<GL_TICK>",  "4" }
		// aArtArr[3] = { 3, "<GL_TYPE>", "LO" }
		
		AADD( aArtArr, { nElem, aECnds[1], aECnds[2] } )
	
	next

next

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// UPOREDJIVANJE NOVE MATRICE SA USLOVIMA SA POSTOJECOM IZ UNOSA
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// format matrice iz unosa je npr:
//
// aArr = { EL_NO, GR_VAL_CODE, GR_VAL, JOKER, ATR_CODE, ATR_VAL } 
//
// aArr[1] = { 1, "G", "staklo", "<GL_TYPE>", "FL", "FLOAT" }
// aArr[2] = { 1, "G", "staklo", "<GL_TICK>", "4", "4mm" }
// aArr[3] = { 2, "F", "distancer", "<FR_TYPE>", "A", "Aluminij" }
// aArr[4] = { 2, "F", "distancer", "<FR_TICK>", "10", "10mm" }
// aArr[4] = { 2, "F", "distancer", "<FR_GAS>", "A", "Argon" }
// aArr[4] = { 3, "G", "staklo", "<GL_TYPE>", "FL", "FLOAT" }
// aArr[4] = { 3, "G", "staklo", "<GL_TYPE>", "4", "4mm" }


for nCond := 1 to LEN( aArtArr )
	
	// element = 1
	nElement := aArtArr[ nCond, 1 ]
	
	// djoker atributa = "<GL_TYPE>"
	cCondAtt := aArtArr[ nCond, 2 ]
	
	// vrijednost atributa = "4"
	cCondVal := aArtArr[ nCond, 3 ]

	
	// ako postoji upitnik... onda je to "like"...
	// pr: S?, moze biti: "S", "SC", "SG" ....
	
	if LEN(cCondVal) > 1 .and. "?" $ cCondVal 
	
		// ponisti upitnik ....
		cCondVal := STRTRAN( cCondVal, "?", "" )
		
		// pronadji da li postoji takav zapis... u matrici aArr
		nSeek := ASCAN( aArr, {| xVal | xVal[1] == nElement .and. ;
					ALLTRIM(xVal[4]) == cCondAtt .and. ;
					ALLTRIM(xVal[5]) = cCondVal } )
	
	// rijec je o bilo kojem uslovu...
	// na poziciji nElement
	
	elseif LEN(cCondVal) == 1 .and. cCondVal == "?"
	
		// pronadji da li postoji takav zapis... u matrici aArr
		nSeek := ASCAN( aArr, {| xVal | xVal[1] == nElement .and. ;
					ALLTRIM(xVal[4]) == cCondAtt } )
	
	// trazi se striktni uslov
	// npr: "L"
	
	else
		// pronadji da li postoji takav zapis... u matrici aArr
		nSeek := ASCAN( aArr, {| xVal | xVal[1] == nElement .and. ;
					ALLTRIM(xVal[4]) == cCondAtt .and. ;
					ALLTRIM(xVal[5]) == cCondVal } )

	endif
	
	if nSeek == 0
	
		lExist := .f.
		exit
		
	endif

next

return lExist



