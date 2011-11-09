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


static __cust_id


// -------------------------------------
// otvara tabelu kontakata
// -------------------------------------
function s_contacts( cId, nCust_id, cContDesc, dx, dy )
local nTArea
local cHeader
local cTag := "4"
private ImeKol
private Kol

if nCust_id == nil
	nCust_id := -1
endif

if cContDesc == nil
	cContDesc := ""
endif

__cust_id := nCust_id

nTArea := SELECT()

cHeader := "Kontakti /"

select contacts

if cID == nil
	// cont_desc
	cTag := "4"
else
	// cust_id + cont_desc
	cTag := "3"
endif


set_a_kol(@ImeKol, @Kol, nCust_id)

if VALTYPE(cId) == "C"
	//try to validate
	if VAL(cId) <> 0
	
		cId := VAL(cId)
		nCust_id := -1
		cContDesc := ""
		cTag := "1"
		
	endif
endif

set order to tag cTag
set filter to
cust_filter(nCust_id, cContDesc)

cRet := PostojiSifra(F_CONTACTS, cTag, 10, 70, cHeader, @cId, dx, dy, ;
		{|| key_handler( Ch ) })

if LastKey() == K_ESC
	cId := 0
endif

select (nTArea)

return cRet


// --------------------------------------
// obrada tipki u sifrarniku
// --------------------------------------
static function key_handler()
local nRet := DE_CONT

do case
	case Ch == K_F3
		nRet := wid_edit( "CONT_ID" )
endcase


return nRet



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol, nCust_id)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(cont_id)}, "cont_id", {|| _inc_id(@wcont_id, "CONT_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Narucioc", 10), {|| g_cust_desc( cust_id ) }, "cust_id", {|| set_cust_id(@wcust_id) }, {|| s_customers(@wcust_id), show_it( g_cust_desc(wcust_id)) }})
AADD(aImeKol, {PADC("Ime i prezime", 20), {|| PADR(cont_desc, 20)}, "cont_desc", {|| .t.}, {|| val_cont_name(wcont_desc) } })
AADD(aImeKol, {PADC("Telefon", 20), {|| PADR(cont_tel, 20)}, "cont_tel"})
AADD(aImeKol, {PADC("Dodatni opis", 20), {|| PADR(cont_add_desc, 20)}, "cont_add_desc", {|| set_cont_mc(@wmatch_code, @wcont_desc) }, {|| _chk_id(@wcont_id, "CONT_ID") } })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



// ---------------------------------------------
// validacija imena i prezimena
// ---------------------------------------------
static function val_cont_name( cCont_desc )
local aPom := {}

aPom := TokToNiz( ALLTRIM( cCont_desc ), " " )

do case
	case LEN(aPom) == 1
		
		MsgBeep("Format unosa je IME + PREZIME#Ako je prezime nepoznato unosi se IME + NN !")
		return .f.
		
	case EMPTY(cCont_desc)
		
		MsgBeep("Unos imena i prezimena je obavezan !!!")
		
		return .f.
		
endcase

return .t.



// ----------------------------------------------
// setuje cust_id pri unosu automatski
// ----------------------------------------------
static function set_cust_id( nCust_id )
if __cust_id > 0
	nCust_id := __cust_id
	return .f.
else
	return .t.
endif
return



// --------------------------------------------------
// generisi match code za contakt...
// --------------------------------------------------
static function set_cont_mc( m_code, cont_desc )
local aPom := TokToNiz( ALLTRIM(cont_desc), " ")
local i

if !EMPTY(m_code)
	return .t.
endif

m_code := ""

for i:=1 to LEN(aPom)
	m_code += UPPER( LEFT( aPom[i], 2 ) )
next

m_code := PADR( m_code, 10 )

return .t.




// -------------------------------------------
// filter po cust_id
// nCust_id - id customer
// -------------------------------------------
static function cust_filter(nCust_id, cContDesc)
local cFilter := ""

if nCust_id > 0
	cFilter += "cust_id == " + custid_str(nCust_id)
endif

if !EMPTY(cContDesc)
	
	if !EMPTY(cFilter)
		cFilter += " .and. "
	endif
	
	cContDesc := ALLTRIM(cContDesc)
	cFilter += " ALLTRIM(UPPER(cont_desc)) = " + cm2str(UPPER(cContDesc))
	
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return



// -------------------------------
// convert cont_id to string
// -------------------------------
function contid_str(nId)
return STR(nId, 10)



// -------------------------------
// get cont_id_desc by cont_id
// -------------------------------
function g_cont_desc(nCont_id, lEmpty)
local cContDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cContDesc := ""
endif

O_CONTACTS
select contacts
set order to tag "1"
go top
seek contid_str(nCont_id)

if FOUND()
	if !EMPTY(field->cont_desc)
		cContDesc := ALLTRIM(field->cont_desc)
	endif
endif

select (nTArea)

return cContDesc


// -------------------------------
// get cont_tel by cont_id
// -------------------------------
function g_cont_tel(nCont_id, lEmpty)
local cContTel := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cContTel := ""
endif

O_CONTACTS
select contacts
set order to tag "1"
go top
seek contid_str(nCont_id)

if FOUND()
	if !EMPTY(field->cont_tel)
		cContTel := ALLTRIM(field->cont_tel)
	endif
endif

select (nTArea)

return cContTel



