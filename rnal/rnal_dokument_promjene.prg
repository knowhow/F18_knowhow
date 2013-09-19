/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "rnal.ch"


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
__oper_id := GetUserID( f18_user() )

AADD(opc, "promjena, osnovni podaci naloga ")
AADD(opcexe, {|| _ch_main() })
AADD(opc, "promjena, podaci isporuke ")
AADD(opcexe, {|| _ch_ship() })
AADD(opc, "promjena, podaci o placanju ")
AADD(opcexe, {|| _ch_pay() })
AADD(opc, "promjena, podaci kontakta")
AADD(opcexe, {|| _ch_cont() })
AADD(opc, "promjena, napomene i opisi")
AADD(opcexe, {|| _ch_description() })
AADD(opc, "promjena, novi kontakt naloga ")
AADD(opcexe, {|| _ch_cont(.t.) })
AADD(opc, "promjena, lom artikala ")
AADD(opcexe, {|| _ch_damage( __oper_id ) })
AADD(opc, "napravi neuskladjeni proizvod ")
AADD(opcexe, {|| rnal_damage_doc_generate( __doc_no ) })

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
local nDoc_no
local aArr
local _rec

if Pitanje(,"Zelite izmjeniti osnovne podatke naloga (D/N)?", "D") == "N"
	return
endif

select docs

nCustId := field->cust_id
nDoc_priority := field->doc_priori
nDoc_no := field->doc_no

// box sa unosom podataka
if _box_main(@nCustId, @nDoc_priority, @cDesc) == 0
	return
endif

aArr := a_log_main( nCustId, nDoc_priority ) 
log_main(__doc_no, cDesc, "E", aArr)

select docs
_rec := dbf_get_rec()

if _rec["cust_id"] <> nCustId
	_rec["cust_id"] := nCustId
endif
if _rec["doc_priori"] <> nDoc_priority
	_rec["doc_priori"] := nDoc_priority
endif

update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )

log_write( "F18_DOK_OPER: rnal, promjena osnovnih podataka naloga broj: " + ALLTRIM( STR( nDoc_no ) ), 2 )

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
local nDoc_no
local cObj_id
local cDesc
local aArr
local nCust_id

if Pitanje(,"Zelite izmjeniti podatke o isporuci naloga (D/N)?", "D") == "N"
	return
endif

select docs

cShipPlace := field->doc_ship_p
dDvrDate := field->doc_dvr_da
cDvrTime := field->doc_dvr_ti
nObj_id := field->obj_id
nCust_id := field->cust_id
nDoc_no := field->doc_no

// box sa unosom podataka
if _box_ship(@nObj_id, @cShipPlace, @cDvrTime, @dDvrDate, @cDesc, nCust_id) == 0
	return
endif

// logiraj isporuku
aArr := a_log_ship( nObj_id, dDvrDate, cDvrTime, cShipPlace )
log_ship( __doc_no, cDesc, "E", aArr )

select docs

set_global_memvars_from_dbf()

if _doc_ship_p <> cShipPlace
	_doc_ship_p := cShipPlace
endif

if _doc_dvr_ti <> cDvrTime
	_doc_dvr_ti := cDvrTime
endif

if _doc_dvr_da <> dDvrDate
	_doc_dvr_da := dDvrDate
endif

if _obj_id <> nObj_id
	_obj_id := nObj_id
endif

_rec := get_dbf_global_memvars()    
update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )

log_write( "F18_DOK_OPER: rnal, promjena podataka isporuke naloga broj: " + ALLTRIM( STR( nDoc_no ) ), 2 )

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
local nDoc_no

if Pitanje(,"Zelite izmjeniti podatke o placanju naloga (D/N)?", "D") == "N"
	return
endif

select docs

cDoc_paid := field->doc_paid
nDoc_pay_id := field->doc_pay_id
cDoc_pay_desc := field->doc_pay_de
nDoc_no := field->doc_no

// box sa unosom podataka
if _box_pay(@nDoc_pay_id, @cDoc_paid, @cDoc_pay_desc, @cDesc) == 0
	return
endif

// logiraj placanje..
aArr := a_log_pay( nDoc_pay_id, cDoc_paid, cDoc_pay_desc )
log_pay(__doc_no, cDesc, "E", aArr)

select docs

set_global_memvars_from_dbf()

if _doc_paid <> cDoc_paid
	_doc_paid := cDoc_paid
endif

if _doc_pay_de <> cDoc_pay_desc
	_doc_pay_de := cDoc_pay_desc
endif

if _doc_pay_id <> nDoc_pay_id
	_doc_pay_id := nDoc_pay_id
endif

_rec := get_dbf_global_memvars()    
update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )

log_write( "F18_DOK_OPER: rnal, promjena podataka placanja naloga broj: " + ALLTRIM( STR( nDoc_no ) ), 2 )

select docs

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
local nDoc_no 

if lNew == nil
	lNew := .f.
endif

if !lNew
	
	select docs
	
	nCust_id := field->cust_id
	nCont_id := field->cont_id
	cCont_desc := field->cont_add_d
	
endif

nDoc_no := field->doc_no

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
	
set_global_memvars_from_dbf()

if _cont_id <> nCont_id
	_cont_id := nCont_id
endif
if _cont_add_d <> cCont_desc
	_cont_add_d := cCont_desc
endif

_rec := get_dbf_global_memvars()    
update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )

log_write( "F18_DOK_OPER: rnal, promjena podataka kontakta naloga broj: " + ALLTRIM( STR( nDoc_no ) ), 2 )

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



// ---------------------------------
// promjeni kontakt naloga
// ---------------------------------
function _ch_description()
local _t_rec := RecNo()
local _add_desc 
local _ch_desc := SPACE(200)
local _sh_desc
local _doc_no
local _rec
local _update := .f.

select docs
	
_add_desc := field->doc_desc
_sh_desc := field->doc_sh_des
_doc_no := field->doc_no

if _box_descr( @_sh_desc, @_add_desc, @_ch_desc ) == 0
	return 
endif

select docs
_rec := dbf_get_rec()
	
if _rec["doc_desc"] <> _add_desc
	_rec["doc_desc"] := _add_desc
    _update := .t.
endif

if _rec["doc_sh_des"] <> _sh_desc
	_rec["doc_sh_des"] := _sh_desc
    _update := .t.
endif

if _update
    update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )
    log_write( "F18_DOK_OPER: rnal, promjena opisa i napomena naloga broj: " + ALLTRIM( STR( _doc_no ) ) + ;
        ", opis: " + ALLTRIM( _ch_desc ), 2 )
endif

select docs
go ( _t_rec )

return


// ------------------------------------
// box sa podatkom o kontaktu
// ------------------------------------
static function _box_descr( sh_desc, add_desc, ch_desc )

Box(, 7, 65 )

	@ m_x + 1, m_y + 2 SAY "Ispravka opisa i napomena naloga:"
	
	@ m_x + 3, m_y + 2 SAY PADL("Kratki opis:", 20) GET sh_desc PICT "@S30"
	@ m_x + 4, m_y + 2 SAY PADL("Dodatni opis:", 20) GET add_desc PICT "@S30"
	
	@ m_x + 7, m_y + 2 SAY "Opis promjene:" GET ch_desc PICT "@S40"
	
    read

BoxC()

ESC_RETURN 0

return 1



