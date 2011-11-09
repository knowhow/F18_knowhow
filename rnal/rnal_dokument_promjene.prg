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
static __doc_no
static __oper_id

// --------------------------
// meni promjena
// --------------------------
function m_changes( nDoc_no )
private opc:={}
private opcexe:={}
private izbor:=1

__doc_no := nDoc_no
__oper_id := GetUserID()

AADD(opc, "promjena, osnovni podaci naloga ")
AADD(opcexe, {|| _ch_main() })
AADD(opc, "promjena, podaci isporuke ")
AADD(opcexe, {|| _ch_ship() })
AADD(opc, "promjena, podaci o placanju ")
AADD(opcexe, {|| _ch_pay() })
AADD(opc, "promjena, podaci kontakta")
AADD(opcexe, {|| _ch_cont() })
AADD(opc, "promjena, novi kontakt naloga ")
AADD(opcexe, {|| _ch_cont(.t.) })
AADD(opc, "promjena, lom artikala ")
AADD(opcexe, {|| _ch_damage( __oper_id ) })

Menu_sc("changes")

return



// ---------------------------------
// promjena osnovnih podataka 
// ---------------------------------
function _ch_main()
local nTRec := RecNo()
local nCustId
local nDoc_priority
local cDesc
local aArr

if Pitanje(,"Zelite izmjeniti osnovne podatke naloga (D/N)?", "D") == "N"
	return
endif

select docs

nCustId := field->cust_id
nDoc_priority := field->doc_priority

// box sa unosom podataka
if _box_main(@nCustId, @nDoc_priority, @cDesc) == 0
	return
endif

aArr := a_log_main( nCustId, nDoc_priority ) 
log_main(__doc_no, cDesc, "E", aArr)

select docs
Scatter()

if _cust_id <> nCustId
	_cust_id := nCustId
endif
if _doc_priority <> nDoc_priority
	_doc_priority := nDoc_priority
endif

Gather()

skip

select docs
go (nTRec)

return


// --------------------------------------
// box sa unosom podataka osnovnih
// --------------------------------------
static function _box_main(nCust, nPrior, cDesc)
local cCust := SPACE(10)

Box(, 7, 65)
	cDesc := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena na osnovnim podacima naloga:"
	@ m_x + 3, m_y + 2 SAY "Narucioc:" GET cCust VALID {|| s_customers(@cCust, cCust), set_var(@nCust, @cCust), show_it( g_cust_desc( nCust ) ) }
	@ m_x + 4, m_y + 2 SAY "Prioritet (1/2/3):" GET nPrior VALID nPrior > 0 .and. nPrior < 4
	@ m_x + 7, m_y + 2 SAY "Opis promjene:" GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1



// ---------------------------------
// promjena podataka o isporuci
// ---------------------------------
function _ch_ship()
local nTRec := RecNo()
local cShipPlace
local cDvrTime
local dDvrDate
local nObj_id
local cObj_id
local cDesc
local aArr
local nCust_id

if Pitanje(,"Zelite izmjeniti podatke o isporuci naloga (D/N)?", "D") == "N"
	return
endif

select docs

cShipPlace := field->doc_ship_place
dDvrDate := field->doc_dvr_date
cDvrTime := field->doc_dvr_time
nObj_id := field->obj_id
nCust_id := field->cust_id

// box sa unosom podataka
if _box_ship(@nObj_id, @cShipPlace, @cDvrTime, @dDvrDate, @cDesc, nCust_id) == 0
	return
endif

// logiraj isporuku
aArr := a_log_ship( nObj_id, dDvrDate, cDvrTime, cShipPlace )
log_ship(__doc_no, cDesc, "E", aArr)

select docs

Scatter()

if _doc_ship_place <> cShipPlace
	_doc_ship_place := cShipPlace
endif

if _doc_dvr_time <> cDvrTime
	_doc_dvr_time := cDvrTime
endif

if _doc_dvr_date <> dDvrDate
	_doc_dvr_date := dDvrDate
endif

if _obj_id <> nObj_id
	_obj_id := nObj_id
endif

Gather()

select docs
go (nTRec)

return


// --------------------------------------
// box sa unosom podataka o isporuci
// --------------------------------------
static function _box_ship(nObj_id, cShip, cTime, dDate, cDesc, nCust_id )
local cObj_id := PADR(STR(nObj_id, 10), 10)

Box(, 8, 65)
	cDesc := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena podataka o isporuci:"
	
	@ m_x + 3, m_y + 2 SAY PADL("Novi objekat isporuke:",22) GET cObj_id VALID {|| s_objects( @cObj_id, nCust_id, cObj_id ), set_var(@nObj_id, @cObj_id), show_it( ALLTRIM(g_obj_desc( nObj_id ) ) )  } 
	@ m_x + 4, m_y + 2 SAY PADL("Novo mjesto isporuke:",22) GET cShip VALID !EMPTY(cShip) PICT "@S30"
	@ m_x + 5, m_y + 2 SAY PADL("Novo vrijeme isporuke:",22) GET cTime VALID !EMPTY(cTime)
	@ m_x + 6, m_y + 2 SAY PADL("Novi datum isporuke:",22) GET dDate VALID !EMPTY(dDate)
	@ m_x + 8, m_y + 2 SAY PADL("Opis promjene:",22) GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1


// ---------------------------------
// promjena podataka o placanju
// ---------------------------------
function _ch_pay()
local nTRec := RecNo()
local cDoc_paid
local nDoc_pay_id
local cDoc_pay_desc
local cDesc
local aArr

if Pitanje(,"Zelite izmjeniti podatke o placanju naloga (D/N)?", "D") == "N"
	return
endif

select docs

cDoc_paid := field->doc_paid
nDoc_pay_id := field->doc_pay_id
cDoc_pay_desc := field->doc_pay_desc

// box sa unosom podataka
if _box_pay(@nDoc_pay_id, @cDoc_paid, @cDoc_pay_desc, @cDesc) == 0
	return
endif

// logiraj placanje..
aArr := a_log_pay( nDoc_pay_id, cDoc_paid, cDoc_pay_desc )
log_pay(__doc_no, cDesc, "E", aArr)

select docs

Scatter()

if _doc_paid <> cDoc_paid
	_doc_paid := cDoc_paid
endif

if _doc_pay_desc <> cDoc_pay_desc
	_doc_pay_desc := cDoc_pay_desc
endif

if _doc_pay_id <> nDoc_pay_id
	_doc_pay_id := nDoc_pay_id
endif

Gather()

select docs
//go (nTRec)

return


// --------------------------------------
// box sa unosom podataka o placanju
// --------------------------------------
static function _box_pay(nPay_id, cPaid, cPayDesc, cDesc)

Box(, 7, 65)
	cDesc := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Promjena podataka o placanju:"
	@ m_x + 3, m_y + 2 SAY PADL("Vrsta placanja:",22) GET nPay_id VALID {|| nPay_id > 0 .and. nPay_id < 3, show_it( s_pay_id( nPay_id ) )  }
	@ m_x + 4, m_y + 2 SAY PADL("Placeno (D/N):",22) GET cPaid VALID cPaid $ "DN"
	@ m_x + 5, m_y + 2 SAY PADL("dod.napomene:",22) GET cPayDesc PICT "@S40"
	@ m_x + 7, m_y + 2 SAY PADL("Opis promjene:",22) GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1



// ---------------------------------
// promjeni kontakt naloga
// ---------------------------------
function _ch_cont( lNew )
local nTRec := RecNo()
local cDesc
local aArr
local cType := "E"
local nCont_id := VAL(STR(0, 10))
local cCont_desc := SPACE( 150 )
local nCust_id := VAL(STR(0, 10))

if lNew == nil
	lNew := .f.
endif

if !lNew
	
	select docs
	
	nCust_id := field->cust_id
	nCont_id := field->cont_id
	cCont_desc := field->cont_add_desc
	
endif

if _box_cont(@nCust_id, @nCont_id, @cCont_desc, @cDesc) == 0
	return 
endif

// logiraj promjenu kontakta
aArr := a_log_cont( nCont_id, cCont_desc )

if lNew 
	cType := "+"
endif

log_cont(__doc_no, cDesc, cType, aArr)

select docs
	
Scatter()

if _cont_id <> nCont_id
	_cont_id := nCont_id
endif
if _cont_add_desc <> cCont_desc
	_cont_add_desc := cCont_desc
endif

Gather()

select docs
go (nTRec)

return


// ------------------------------------
// box sa podatkom o kontaktu
// ------------------------------------
static function _box_cont(nCust, nCont, cContdesc, cDesc)
local lNew := .f.
local cCont := SPACE(10)

cCont := PADR( ALLTRIM( STR( nCont ) ), 10 )

if nCont == 0
	lNew := .t.
endif

Box(, 7, 65)

	cDesc := SPACE(150)
	
	if lNew == .t.
		@ m_x + 1, m_y + 2 SAY "Novi kontakti naloga:"
	else
		@ m_x + 1, m_y + 2 SAY "Ispravka kontakta naloga:"
	endif
	
	@ m_x + 3, m_y + 2 SAY PADL("Kontakt:",20) GET cCont VALID {|| s_contacts(@cCont, nCust, cCont), set_var( @nCont, @cCont ) , show_it( g_cont_desc( nCont ) )}
	
	@ m_x + 4, m_y + 2 SAY PADL("Kontakt, dodatni opis:",20) GET cContDesc PICT "@S30"
	
	@ m_x + 7, m_y + 2 SAY "Opis promjene:" GET cDesc PICT "@S40"
	read
BoxC()

ESC_RETURN 0

return 1




