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

static l_new_doc
static _oper_id
static _doc

// -------------------------------------------------
// unos / ispravka osnovnih podataka dokumenta
// lNew - nova stavka .t. or .f.
// -------------------------------------------------
function e_doc_main_data( lNew )
local nRecCnt := 0
local nGetBoxX := 22
local nGetBoxY := 70
private GetList:={}

nRecCnt := RECCOUNT2()

if lNew .and. nRecCnt == 1
	MsgBeep("Vec postoji definisan nalog !!!#Dodavanje novih stavki onemoguceno!")
	return 0
endif

l_new_doc := lNew

_oper_id := GetUserID()

select _docs

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos osnovnih podataka naloga")
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna obavezna", nGetBoxY - 2 ) COLOR "BG+/B"

set_opc_box( nGetBoxX , 50 )

Scatter()
_doc := _doc_no

if _e_box_main( nGetBoxX, nGetBoxY ) == 0

	select _docs
	BoxC()
	return 0
	
endif

BoxC()

select _docs

if l_new_doc
	append blank
endif
   
Gather()

return 1



// -----------------------------------------------
// setuj box na dnu kao pomoc
// nX - x kordinata max
// nLeft - LEFT vrijednost
// cTxt1...cTxt3 - mogucnost 3 reda teksta
// cColor - mogucnost zadavanja boje, def: BG+/B
// -----------------------------------------------
function set_opc_box( nX, nLeft, ;
			cTxt1, cTxt2, cTxt3, ;
			cColor )
local i

if nX == nil
	nX := 20
endif

if nLeft == nil
	nLeft := 50
endif

if cTxt1 == nil
	cTxt1 := ""
endif

if cTxt2 == nil
	cTxt2 := ""
endif

if cTxt3 == nil
	cTxt3 := ""
endif

if cColor == nil
	cColor := "BG+/B"
endif

cTxt1 := PADR(cTxt1, nLeft)
cTxt2 := PADR(cTxt2, nLeft)
cTxt3 := PADR(cTxt3, nLeft)

@ m_x + nX - 2 , m_y + 2 SAY cTxt1 COLOR cColor
@ m_x + nX - 1 , m_y + 2 SAY cTxt2 COLOR cColor

if !EMPTY( cTxt3 )
	@ m_x + nX , m_y + 2 SAY cTxt3 COLOR cColor
endif

return .t.



// ---------------------------------------------
// forma  unosa podataka
// ---------------------------------------------
static function _e_box_main( nBoxX, nBoxY )
local nX := 1
local nLeft := 21
local cCustId
local cContId
local cObjId

// setuj def.vrijednosti polja za novi dokument
if l_new_doc

	_doc_date := DATE()
	_doc_dvr_date := DATE() + 2
	_doc_dvr_time := PADR( PADR(TIME(), 5), 8)
	_doc_ship_place := PADR("", LEN(_doc_ship_place) )
	_doc_priority := 2
	_doc_pay_id := 1
	_doc_paid := "D"
	_doc_pay_desc := SPACE( LEN(_doc_pay_desc) )
	_doc_status := 0
	_doc_sh_desc := SPACE( LEN( _doc_sh_desc ) )
	
	cCustId := PADR("", 10)
	cContId := PADR("", 10)
	cObjId := PADR("", 10)
else
	
	cCustId := STR(_cust_id, 10)
	cContId := STR(_cont_id, 10)
	cObjId := STR(_obj_id, 10)
	
endif

// set vrijednosti polja koja se uvijek mijenjaju
_operater_id := _oper_id

// unos podataka...

@ m_x + nX, m_y + 2 SAY "Datum naloga (*):" GET _doc_date WHEN set_opc_box( nBoxX, 50 ) 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Narucioc (*):", nLeft) GET cCustid VALID {|| s_customers(@cCustId, cCustId), set_var(@_cust_id, @cCustId) , show_it(g_cust_desc( _cust_id ), 35 ) } WHEN set_opc_box( nBoxX, 50, "0 - otvori sifrarnik" ) 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Datum isporuke (*):", nLeft) GET _doc_dvr_date VALID must_enter( _doc_dvr_date ) WHEN set_opc_box( nBoxX, 50 )

@ m_x + nX, col() + 2 SAY PADL("Vrijeme isporuke (*):", nLeft) GET _doc_dvr_time VALID must_enter(_doc_dvr_time) WHEN set_opc_box(nBoxX, 50, "format: HH:MM")

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Objekat isporuke (*):", nLeft) GET cObjId VALID {|| s_objects( @cObjid, _cust_id, cObjId), set_var(@_obj_id, @cObjid) , show_it( g_obj_desc( _obj_id ), 35 ) } WHEN set_opc_box( nBoxX, 50, "Objekat u koji se isporucuje", "0 - otvori sifrarnik")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Mjesto isporuke :", nLeft) GET _doc_ship_place VALID {|| sh_place_pattern(@_doc_ship_place) } PICT "@S46" WHEN set_opc_box( nBoxX, 50, "mjesto gdje se roba isporucuje", "/RP - rg prod. /T - tvornica nar." )
@ m_x + nX, col() SAY ">" COLOR "I"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Kontakt osoba (*):", nLeft) GET cContid VALID {|| s_contacts( @cContid, _cust_id, cContId), set_var(@_cont_id, @cContid) , show_it( g_cont_desc( _cont_id ), 35 ) } WHEN set_opc_box( nBoxX, 50, "0 - otvori sifrarnik")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("dodatni opis:", nLeft + 2 ) GET _cont_add_desc PICT "@S44" WHEN set_opc_box( nBoxX, 50, "dodatni opis kontakta" )
@ m_x + nX, col() SAY ">" COLOR "I"

nX += 3

@ m_x + nX, m_y + 2 SAY PADL("Prioritet (*):", nLeft) GET _doc_priority VALID {|| (_doc_priority > 0 .and. _doc_priority < 4), show_it(s_priority(_doc_priority), 40) } PICT "9" WHEN set_opc_box( nBoxX, 50, "1 - high, 2 - normal, 3 - low") 

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Vrsta placanja (*):", nLeft) GET _doc_pay_id VALID {|| (_doc_pay_id > 0 .and. _doc_pay_id < 3), show_it(s_pay_id( _doc_pay_id ), 40)} PICT "9"  WHEN set_opc_box( nBoxX, 50, "1 - ziro racun, 2 - gotovina" ) 

nX += 1
	
@ m_x + nX, m_y + 2 SAY PADL("Placeno (D/N)? (*):", nLeft) GET _doc_paid VALID _doc_paid $ "DN" PICT "@!" WHEN set_opc_box( nBoxX, 50 )
	
@ m_x + nX, col() + 2 SAY "dod.nap.plac:" GET _doc_pay_desc PICT "@S29" WHEN set_opc_box( nBoxX, 50, "dodatne napomene vezane za placanje" )
@ m_x + nX, col() SAY ">" COLOR "I"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Kratki opis (*):", nLeft) GET _doc_sh_desc VALID !EMPTY(_doc_sh_desc) PICT "@S46" WHEN set_opc_box( nBoxX, 50, "kratki opis naloga (asocijacija)", "npr: ulazna stijena, vrata ...") 
@ m_x + nX, col() SAY ">" COLOR "I"

nX += 1 

@ m_x + nX, m_y + 2 SAY PADL("Dod.opis naloga:", nLeft) GET _doc_desc VALID chk_mandatory( _doc_desc, _doc_priority ) PICT "@S46" WHEN set_opc_box( nBoxX, 50, "dodatni opis naloga" )
@ m_x + nX, col() SAY ">" COLOR "I"

read

ESC_RETURN 0

return 1


// --------------------------------------------
// provjerava da li je popunjena varijabla
// --------------------------------------------
function empty_var( xVar )
local nRet := .t.
local cVarType := VALTYPE( xVar )
do case
	case cVarType == "C"
		if EMPTY( xVar )
			lRet := .f.
		endif
	case cVarType == "N"
		if xVar == 0
			lRet := .f.
		endif
endcase

return lRet


// ------------------------------------------
// set N polje iz C varijable
// ------------------------------------------
function set_var( _field, xVar, nLen )

if nLen == nil
	nLen := 10
endif

// convert to "C"
if VALTYPE(xVar) == "N"
	
	// set field
	_field := xVar
	
	// convert to "C"
	xVar := PADL( STR(xVar, nLen), nLen )
	
endif

return .t.



// -----------------------------------------------------
// setuje nazive za mjesto isporuke prema patternu
// recimo /RP - ramaglas prodaja
// "/" + nastavak je pattern
// -----------------------------------------------------
static function sh_place_pattern( cPattern )
local nLen := LEN(cPattern)

do case
	case ALLTRIM(cPattern) == "/RP"
		cPattern := PADR("Rama-glas prodaja", nLen)
	case ALLTRIM(cPattern) == "/T"
		cPattern := PADR("Tvornica narucioca", nLen)
endcase

return .t.



// ---------------------------------------------------------
// prvovjeri da li je polje neophodno na osnovu prioriteta
// ---------------------------------------------------------
static function chk_mandatory( cDesc, nDocPriority ) 
local lRet := .t.

do case
	case nDocPriority < 2 .and. EMPTY( cDesc )
		lRet := .f.
		
endcase

if lRet == .f.
	msgbeep( "Unos polja obavezan, prioritet = " + ;
		s_priority( nDocPriority ) )
endif

return lRet


// ----------------------------
// vrati opis prioriteta
// ----------------------------
function s_priority( _doc_prior )
local xRet := ""
do case
	case _doc_prior == 1
		xRet := "HIGH"
	case _doc_prior == 2
		xRet := "NORMAL"
	case _doc_prior == 3
		xRet := "LOW"
endcase
return xRet

// ------------------------------
// vrati opis vrste placanja
// ------------------------------
function s_pay_id( _pay_id )
local xRet := ""
do case
	case _pay_id == 1
		xRet := "ziro racun"
	case _pay_id == 2
		xRet := "gotovina"
endcase
return xRet



