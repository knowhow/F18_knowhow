/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "rnal.ch"

// -----------------------------------------
// otvara sifrarnik narucioca
// -----------------------------------------
function s_customers(cId, cCustDesc, dx, dy)
local nTArea
local cHeader
local cTag := "1"
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Narucioci"
cHeader += SPACE(5)
cHeader += "/ 'K' - pr.kontakata  / 'O' - pr.objekata"

select customs
set order to tag cTag

if cCustDesc == nil
	cCustDesc := ""
endif

set_a_kol(@ImeKol, @Kol)

if VALTYPE(cId) == "C"
	//try to validate
	if VAL(cId) <> 0
		cId := VAL(cId)
		cCustDesc := ""
	endif
endif

// postavi filter...
set_f_kol( cCustDesc, @cId )	

cRet := PostojiSifra(F_CUSTOMS, cTag, maxrows() - 15, maxcols() - 15, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

if !EMPTY(cCustDesc)
	set filter to
	go top
endif

if LastKey() == K_ESC
	cId := 0
endif

select (nTArea)

return cRet


// --------------------------------------------------
// setovanje filtera nad tabelom customers
// --------------------------------------------------
static function set_f_kol( cCustDesc, cId )
local cFilter := ""

if !EMPTY(cCustDesc)
	
	cCustDesc := ALLTRIM(cCustDesc)

    if RIGHT( cCustDesc ) == "$"

        // vrati uslov u normalno stanje
        cCustDesc := LEFT( cCustDesc, LEN( cCustDesc ) - 1 )
        // vrati i id u normalno stanje
        cId := cCustDesc

        // pretrazi po dijelu naziva	
	    cFilter += _filter_quote( UPPER( cCustDesc ) ) + " $ ALLTRIM(UPPER(cust_desc))" 
    else
	    cFilter += "ALLTRIM(UPPER(cust_desc)) = " + _filter_quote( UPPER(cCustDesc) )
	endif

endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return .t.



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 20), {|| sif_idmc(cust_id, .f., 20)}, "cust_id", {|| _inc_id(@wcust_id, "CUST_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 40), {|| PADR(cust_desc, 40)}, "cust_desc"})
AADD(aImeKol, {PADC("Adresa", 20), {|| PADR(cust_addr, 20)}, "cust_addr"})
AADD(aImeKol, {PADC("Telefon", 20), {|| PADR(cust_tel, 20)}, "cust_tel"})
AADD(aImeKol, { "ID broj", {|| cust_ident } , "cust_ident", {|| set_cust_mc(@wmatch_code, @wcust_desc) }, {|| _chk_id(@wcust_id, "CUST_ID") } })


for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------------------------
// generisi match code za contakt...
// --------------------------------------------------
static function set_cust_mc( m_code, cust_desc )

if !EMPTY(m_code)
	return .t.
endif

m_code := UPPER( PADR( cust_desc, 5 ) )
m_code := PADR( m_code, 10 )

return .t.


// -----------------------------------------
// key handler funkcija
// -----------------------------------------
static function key_handler(Ch)
local cTblFilter := DBFILTER()
local nRec := RECNO()
local nRet := DE_CONT

do case
	case UPPER(CHR(Ch)) == "K"
	
		// pregled kontakata
		s_contacts(nil, field->cust_id)
		nRet := DE_CONT
		
	case UPPER(CHR(Ch)) == "O"
	
		// pregled objekata
		s_objects(nil, field->cust_id)
		nRet := DE_CONT
	
	case CH == K_F3
		
		// ispravka sifre 
		nRet := wid_edit( "CUST_ID" )
endcase

select customs
//set filter to cTblFilter
go (nRec)

return nRet


// -------------------------------
// convert cust_id to string
// -------------------------------
function custid_str(nId)
return STR(nId, 10)



// -------------------------------
// get cust_id_desc by cust_id
// -------------------------------
function g_cust_desc(nCust_id, lEmpty)
local cCustDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cCustDesc := ""
endif

O_CUSTOMS
select customs
set order to tag "1"
go top
seek custid_str(nCust_id)

if FOUND()
	if !EMPTY(field->cust_desc)
		cCustDesc := ALLTRIM(field->cust_desc)
	endif
endif

select (nTArea)

return cCustDesc


// ----------------------------------------------------
// vraca ime kupca, ako je NN onda kontakt
// ----------------------------------------------------
function _cust_cont( nCust_id, nCont_id )
local xRet := ""
local nTArea := SELECT()
local cTmp := ""

select customs
seek custid_str( nCust_id )

if FOUND()
	cTmp := ALLTRIM( field->cust_desc )
endif

// ako je NN onda potrazi kontakt
if cTmp == "NN"
	
	select contacts
	seek contid_str( nCont_id )
	
	if FOUND()
		cTmp := ALLTRIM( field->cont_desc )
	endif

endif

xRet := cTmp

select (nTArea)

return xRet



