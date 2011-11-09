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



// -------------------------------------------
// logiranje promjena pri operaciji azuriranja
// dokumenta
// -------------------------------------------
function doc_logit()
local cDesc := ""
local aArr

select _docs
go top

__doc_no := field->doc_no

// logiraj osnovne podatke
cDesc := "Inicijalni osnovni podaci"

aArr := a_log_main(field->cust_id, ;
		field->doc_priority )

log_main(__doc_no, cDesc, nil, aArr)

select _docs
go top

// logiraj podatke o isporuci
cDesc := "Inicijalni podaci isporuke"
aArr := a_log_ship( field->obj_id, ;
		field->doc_dvr_date, ;
		field->doc_dvr_time, ;
		field->doc_ship_place)
		
log_ship(__doc_no, cDesc, nil, aArr)

select _docs
go top

// logiranje podataka o kontaktu
cDesc := "Inicijalni podaci kontakta"
aArr := a_log_cont( field->cont_id, field->cont_add_desc )

log_cont(__doc_no, cDesc, nil, aArr)

select _docs
go top

// logiranje podataka o placanju
cDesc := "Inicijalni podaci placanja"
aArr := a_log_pay( field->doc_pay_id, field->doc_paid, field->doc_pay_desc )

log_pay(__doc_no, cDesc, nil, aArr)

select _doc_it
go top

// logiranje artikala
cDesc := "Inicijalni podaci stavki"

log_items( __doc_no, cDesc )

// logiranje operacija
cDesc := "Inicijalni podaci dodatnih operacija"
log_aops( __doc_no, cDesc )

return


// -------------------------------------------------
// puni matricu sa osnovnim podacima dokumenta
// aArr = { customer_id, doc_priority }
// -------------------------------------------------
function a_log_main(nCustId, nPriority)
local aArr := {}
AADD(aArr, { nCustId, nPriority })
return aArr


// -------------------------------------------------
// puni matricu sa podacima placanja
// aArr = { doc_pay_id, doc_paid, doc_pay_desc }
// -------------------------------------------------
function a_log_pay(nPayId, cDocPaid, cDocPayDesc)
local aArr := {}
AADD(aArr, { nPayId, cDocPaid, cDocPayDesc })
return aArr


// -------------------------------------------------
// puni matricu sa podacima isporuke
// aArr = { doc_dvr_date, doc_dvr_time, doc_ship_place }
// -------------------------------------------------
function a_log_ship(nObj_id, dDate, cTime, cPlace)
local aArr := {}
AADD(aArr, { nObj_id, dDate, cTime, cPlace })
return aArr


// -------------------------------------------------
// puni matricu sa podacima kontakta
// aArr = { cont_id, cont_add_desc }
// -------------------------------------------------
function a_log_cont(nCont_id, cCont_desc)
local aArr := {}
AADD(aArr, { nCont_id, cCont_desc })
return aArr





// ----------------------------------------------------
// logiranje osnovnih podataka
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aMain - matrica sa osnovnim podacima
// ----------------------------------------------------
function log_main( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "10"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_10_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return


// -----------------------------------
// punjenje loga sa stavkama tipa 10
// -----------------------------------
function _lit_10_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with aArr[1, 1]
replace int_2 with aArr[1, 2]
replace doc_lit_action with cAction

return



// ----------------------------------------------------
// logiranje podataka isporuke
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aArr - matrica sa podacima
// ----------------------------------------------------
function log_ship( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "11"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_11_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return


// -----------------------------------
// punjenje loga sa stavkama tipa 11
// -----------------------------------
function _lit_11_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace date_1 with aArr[1, 2]
replace int_1 with aArr[1, 1]
replace char_1 with aArr[1, 3]
replace char_2 with aArr[1, 4]
replace doc_lit_action with cAction

return


// ----------------------------------------------------
// logiranje podataka kontakata
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aArr - matrica sa podacima
// ----------------------------------------------------
function log_cont( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "12"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_12_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return


// -----------------------------------
// punjenje loga sa stavkama tipa 12
// -----------------------------------
function _lit_12_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with aArr[1, 1]
replace char_1 with aArr[1, 2]
replace doc_lit_action with cAction

return


// ----------------------------------------------------
// logiranje podataka placanja
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// aArr - matrica sa osnovnim podacima
// ----------------------------------------------------
function log_pay( nDoc_no, cDesc, cAction, aArr )
local nDoc_log_no
local cDoc_log_type

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "13"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_13_insert( cAction, nDoc_no, nDoc_log_no, aArr )

return



// -----------------------------------
// punjenje loga sa stavkama tipa 13
// -----------------------------------
function _lit_13_insert(cAction, nDoc_no, nDoc_log_no, aArr)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with aArr[1, 1]
replace char_1 with aArr[1, 2]
replace char_2 with aArr[1, 3]
replace doc_lit_action with cAction

return



// ----------------------------------------------------
// logiranje podataka o lomu...
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// ----------------------------------------------------
function log_damage( nDoc_no, cDesc, cAction )
local nDoc_log_no
local cDoc_log_type

select _tmp1
if RECCOUNT2() == 0
	return
endif

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "21"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

select _tmp1
go top

do while !EOF() 

	if field->art_marker <> "*"
		skip
		loop
	endif
	
	_lit_21_insert( cAction, nDoc_no, nDoc_log_no, ;
			field->art_id,  ;
			field->art_desc, ;
			field->glass_no, ;
			field->doc_it_no, ;
			field->doc_it_qtty, ;
			field->damage )
	
	select _tmp1
	skip
	
enddo

return



// ----------------------------------------------------
// logiranje podataka stavki naloga
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// ----------------------------------------------------
function log_items( nDoc_no, cDesc, cAction )
local nDoc_log_no
local cDoc_log_type

select _doc_it
if RECCOUNT2() == 0
	return
endif

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "20"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

select _doc_it
go top
seek docno_str(nDoc_no)

do while !EOF() .and. field->doc_no == nDoc_no

	_lit_20_insert( cAction, nDoc_no, nDoc_log_no, ;
			field->art_id,  ;
			field->doc_it_desc, ;
			field->doc_it_schema, ;
			field->doc_it_qtty,  ;
			field->doc_it_heigh, ;
			field->doc_it_width )
	
	select _doc_it
	skip
	
enddo

return


// ----------------------------------------------------
// logiranje podataka dodatnih operacija
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// ----------------------------------------------------
function log_aops( nDoc_no, cDesc, cAction )
local nDoc_log_no
local cDoc_log_type

select _doc_ops
if RECCOUNT2() == 0
	return
endif

if ( cAction == nil)
	cAction := "+"
endif

cDoc_log_type := "30"
nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )

select _doc_ops
go top
seek docno_str(nDoc_no)

do while !EOF() .and. field->doc_no == nDoc_no

	_lit_30_insert( cAction, nDoc_no, nDoc_log_no, ;
			field->aop_id,  ;
			field->aop_att_id,  ;
			field->doc_op_desc )
	
	select _doc_ops
	skip
	
enddo

return



// -----------------------------------
// punjenje loga sa stavkama tipa 20
// -----------------------------------
function _lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			nArt_id, cDoc_desc, cDoc_sch, ;
			nArt_qtty, nArt_heigh, nArt_width)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace art_id with nArt_id
replace num_1 with nArt_qtty
replace num_2 with nArt_heigh
replace num_3 with nArt_width
replace char_1 with cDoc_desc
replace char_2 with cDoc_sch
replace doc_lit_action with cAction

return


// -----------------------------------
// punjenje loga sa stavkama tipa 21
// -----------------------------------
function _lit_21_insert(cAction, nDoc_no, nDoc_log_no, ;
			nArt_id, cArt_desc, nGlass_no, nDoc_it_no, ;
			nQty, nDamage )
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace art_id with nArt_id
replace char_1 with cArt_desc
replace num_1 with nQty
replace num_2 with nDamage
replace int_1 with nDoc_it_no
replace int_2 with nGlass_no
replace doc_lit_action with cAction

return




// -----------------------------------
// punjenje loga sa stavkama tipa 30
// -----------------------------------
function _lit_30_insert(cAction, nDoc_no, nDoc_log_no, ;
			nAop_id, nAop_att_id, cDoc_op_desc)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with nAop_id
replace int_2 with nAop_att_id
replace char_1 with cDoc_op_desc
replace doc_lit_action with cAction

return


// ----------------------------------------------------
// logiranje zatvaranje
// nDoc_no - dokument no
// cDesc - opis
// cAction - akcija 
// ----------------------------------------------------
function log_closed( nDoc_no, cDesc, nDoc_status )
local nDoc_log_no
local cDoc_log_type
local cAction := "+"

do case

	case nDoc_status == 1
		// closed
		cDoc_log_type := "99"
	case nDoc_status == 2
		// rejected
		cDoc_log_type := "97"
	case nDoc_status == 4
		// partialy done
		cDoc_log_type := "98"
	case nDoc_status == 5
		// closed but not delivered
		cDoc_log_type := "96"

endcase

nDoc_log_no := _inc_log_no( nDoc_no )

_d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
_lit_99_insert( cAction, nDoc_no, nDoc_log_no, nDoc_status )

return




// -----------------------------------
// punjenje loga sa stavkama tipa 99
// -----------------------------------
function _lit_99_insert(cAction, nDoc_no, nDoc_log_no, nDoc_status)
local nDoc_lit_no

nDoc_lit_no := _inc_lit_no( nDoc_no , nDoc_log_no )

select doc_lit
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_lit_no with nDoc_lit_no
replace int_1 with nDoc_status
replace doc_lit_action with cAction

return


// --------------------------------------------
// dodaje zapis u tabelu doc_log
// --------------------------------------------
function _d_log_insert( nDoc_no, nDoc_log_no, cDoc_log_type, cDesc )
local nOperId
local nTArea := SELECT()

nOperId := GetUserID()

select doc_log
append blank

replace doc_no with nDoc_no
replace doc_log_no with nDoc_log_no
replace doc_log_date with DATE()
replace doc_log_time with PADR(TIME(), 5)
replace doc_log_type with cDoc_log_type
replace operater_id with nOperId
replace doc_log_desc with cDesc

select (nTArea)
return



//-------------------------------------------------------
// vraca sljedeci redni broj dokumenta u DOC_LOG tabeli
//-------------------------------------------------------
function _inc_log_no( nDoc_no )
local nLastNo:=0

PushWa()

select doc_log
set order to tag "1"
go top

seek docno_str( nDoc_no )

do while !EOF() .and. (field->doc_no == nDoc_no)
	nLastNo := field->doc_log_no
	skip
enddo

PopWa()

return nLastNo + 1



// ----------------------------------------------
// konvert doc_log_no -> STR(doc_log_no,10)
// ----------------------------------------------
function doclog_str(nId)
return STR(nId,10)



//------------------------------------------------
// vraca sljedeci doc_lit_no u tabeli DOC_LIT
//------------------------------------------------
static function _inc_lit_no( nDoc_no, nDoc_log_no )
local nLastNo:=0

PushWa()
select doc_lit
set order to tag "1"
go top
seek docno_str( nDoc_no ) + doclog_str( nDoc_log_no )

do while !EOF() .and. (field->doc_no == nDoc_no) ;
		.and. (field->doc_log_no == nDoc_log_no)
	
	nLastNo := field->doc_lit_no
	skip
	
enddo
PopWa()

return nLastNo + 1



// -----------------------------------------------
// logiranje delte izmedju kumulativa i pripreme
// -----------------------------------------------
function doc_delta( nDoc_no, cDesc )
local nTArea := SELECT()

if cDesc == nil
	cDesc := ""
endif

select _docs
set filter to
select _doc_it
set filter to
select _doc_ops
set filter to
select docs
set filter to
select doc_ops
set filter to
select doc_it
set filter to

// delta stavki dokumenta
_doc_it_delta( nDoc_no, cDesc )

// delta dodatnih operacija dokumenta
_doc_op_delta( nDoc_no, cDesc )

select (nTArea)

return


// -------------------------------------------------
// function _doc_it_delta() - delta stavki dokumenta
// nDoc_no - broj naloga
// funkcija gleda _doc_it na osnovu doc_it i trazi
// 1. stavke koje nisu iste
// 2. stavke koje su izbrisane
// -------------------------------------------------
static function _doc_it_delta( nDoc_no, cDesc )
local nDoc_log_no
local cDoc_log_type := "20"
local cAction
local lLogAppend := .f.

// uzmi sljedeci broj DOC_LOG
nDoc_log_no := _inc_log_no( nDoc_no )

// pozicioniraj se na trazeni dokument
select doc_it
set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nArt_id := field->art_id
	nDoc_it_qtty := field->doc_it_qtty
	nDoc_it_heigh := field->doc_it_heigh
	nDoc_it_width := field->doc_it_width
	cDoc_it_desc := field->doc_it_desc
	cDoc_it_sch := field->doc_it_schema
	
	// DOC_IT -> _DOC_IT - provjeri da li je sta brisano
	// akcija "-"
	
	if !item_exist( nDoc_no, nDoc_it_no, nArt_id, .f.)
		
		cAction := "-"
		
		_lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			   nArt_id , ;
			   cDoc_it_desc, ;
			   cDoc_it_sch, ;
			   nDoc_it_qtty , ;
			   nDoc_it_heigh , ;
			   nDoc_it_width )
			
		lLogAppend := .t.
		
		select doc_it
		
		skip
		loop
		
	endif

	// DOC_IT -> _DOC_IT - da li je sta mjenjano od podataka 
	// akcija "E"
	
	if !item_value(nDoc_no, nDoc_it_no, nArt_id, ;
		      nDoc_it_qtty, ;
		      nDoc_it_heigh, ;
		      nDoc_it_width, .f.)
		
		cAction := "E"
		
		_lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			   _doc_it->art_id, ;
			   _doc_it->doc_it_desc, ;
			   _doc_it->doc_it_schema, ;
			   _doc_it->doc_it_qtty, ;
			   _doc_it->doc_it_heigh, ;
			   _doc_it->doc_it_width )
	
		lLogAppend := .t.
	endif
	
	select doc_it
	
	skip
enddo

// pozicioniraj se na _DOC_IT
select _doc_it
set order to tag "1"
go top
seek docno_str(nDoc_no)

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nArt_id := field->art_id
	nDoc_it_qtty := field->doc_it_qtty
	nDoc_it_heigh := field->doc_it_heigh
	nDoc_it_width := field->doc_it_width
	cDoc_it_desc := field->doc_it_desc
	cDoc_it_sch := field->doc_it_schema
	
	// _DOC_IT -> DOC_IT, da li stavka postoji u kumulativu
	// akcija "+"
	
	if !item_exist(nDoc_no, nDoc_it_no, nArt_id, .t.)
		
		cAction := "+"
		
		_lit_20_insert(cAction, nDoc_no, nDoc_log_no, ;
			   nArt_id, ;
			   cDoc_it_desc, ;
			   cDoc_it_sch, ;
			   nDoc_it_qtty, ;
			   nDoc_it_heigh, ;
			   nDoc_it_width)

		lLogAppend := .t.
	
	endif
	
	select _doc_it
	
	skip
enddo

// bilo je promjena dodaj novi log zapis
if lLogAppend 
	_d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
else
	//cDesc := "Nije bilo nikakvih promjena..."
	//_d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
endif

return



// -------------------------------------------------
// function _doc_op_delta() - delta d.operacija
// nDoc_no - broj naloga
// funkcija gleda _doc_ops na osnovu doc_ops i trazi
// 1. stavke koje nisu iste
// 2. stavke koje su izbrisane
// -------------------------------------------------
static function _doc_op_delta( nDoc_no, cDesc )
local nDoc_log_no
local cDoc_log_type := "30"
local cAction
local lLogAppend := .f.

// uzmi sljedeci broj DOC_LOG
nDoc_log_no := _inc_log_no( nDoc_no )

// pozicioniraj se na trazeni dokument
select doc_ops
set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nDoc_op_no := field->doc_op_no
	
	nAop_id := field->aop_id
	nAop_att_id := field->aop_att_id
	cDoc_op_desc := field->doc_op_desc
	
	// DOC_OPS -> _DOC_OPS - provjeri da li je sta brisano
	// akcija "-"
	
	if !aop_exist( nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, nAop_att_id, .f.)
		
		cAction := "-"
		
		_lit_30_insert(cAction, nDoc_no, nDoc_log_no, ;
			   nAop_id , ;
			   nAop_att_id, ;
			   cDoc_op_desc )
			
		lLogAppend := .t.
		
		select doc_ops
		
		skip
		loop
		
	endif

	// DOC_OPS -> _DOC_OPS - da li je sta mjenjano od podataka 
	// akcija "E"
	
	if !aop_value(nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, ;
		      nAop_att_id, ;
		      cDoc_op_desc, .f.)
		
		cAction := "E"
		
		_lit_30_insert(cAction, nDoc_no, nDoc_log_no, ;
			   _doc_ops->aop_id, ;
			   _doc_ops->aop_att_id, ;
			   _doc_ops->doc_op_desc )
	
		lLogAppend := .t.
	endif
	
	select doc_ops
	
	skip
enddo

// pozicioniraj se na _DOC_IT
select _doc_ops
set order to tag "1"
go top
seek docno_str(nDoc_no)

do while !EOF() .and. field->doc_no == nDoc_no

	nDoc_it_no := field->doc_it_no
	nDoc_op_no := field->doc_op_no
	nAop_id := field->aop_id
	nAop_att_id := field->aop_att_id
	cDoc_op_desc := field->doc_op_desc
	
	// _DOC_OPS -> DOC_OPS, da li stavka postoji u kumulativu
	// akcija "+"
	
	if !aop_exist(nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id, nAop_att_id,.t.)
		
		cAction := "+"
		
		_lit_30_insert(cAction, nDoc_no, nDoc_log_no, ;
			   nAop_id, ;
			   nAop_att_id, ;
			   cDoc_op_desc )

		lLogAppend := .t.
	
	endif
	
	select _doc_ops
	
	skip
enddo

// bilo je promjena dodaj novi log zapis
if lLogAppend 

	_d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
	
else

	//cDesc := "Nije bilo promjena ..."
	//_d_log_insert(nDoc_no, nDoc_log_no, cDoc_log_type, cDesc)
	
endif

return



// --------------------------------------
// da li postoji item u tabelama
// _DOC_IT, DOC_IT
// --------------------------------------
static function item_exist( nDoc_no, nDoc_it_no, nArt_id, lKumul)
local nF_DOC_IT := F__DOC_IT
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if ( lKumul == .t. )
	nF_DOC_IT := F_DOC_IT
endif

select (nF_DOC_IT)
set order to tag "1"
go top

seek docno_str(nDoc_no) + docit_str(nDoc_it_no) + artid_str(nArt_id)

if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet



// --------------------------------------
// da li je stavka sirovina ista....
// --------------------------------------
static function item_value(nDoc_no, nDoc_it_no, nArt_id,;
			   nDoc_it_qtty, nDoc_it_heigh, nDoc_it_width, lKumul)
local nF_DOC_IT := F__DOC_IT
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if (lKumul == .t.)
	nF_DOC_IT := F_DOC_IT
endif

select (nF_DOC_IT)
set order to tag "1"
go top
seek docno_str(nDoc_no) + docit_str(nDoc_it_no) + artid_str(nArt_id)
 
if (field->doc_it_qtty == nDoc_it_qtty) .and. ;
   (field->doc_it_heigh == nDoc_it_heigh) .and. ;
   (field->doc_it_width == nDoc_it_width)
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet



// --------------------------------------
// da li postoji item u tabelama
// _DOC_OPS, DOC_OPS
// --------------------------------------
static function aop_exist( nDoc_no, nDoc_it_no, nDoc_op_no, ;
				nAop_id, nAop_att_id, lKumul)
local nF_DOC_OPS := F__DOC_OPS
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if ( lKumul == .t. )
	nF_DOC_OPS := F_DOC_OPS
endif

select (nF_DOC_OPS)
set order to tag "1"
go top

seek docno_str(nDoc_no) + ;
	docit_str(nDoc_it_no) + ;
	docop_str(nDoc_op_no) + ;
	aopid_str(nAop_id) + ;
	aopid_str(nAop_att_id)

if FOUND()
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet



// --------------------------------------
// da li je stavka operacije ista....
// --------------------------------------
static function aop_value(nDoc_no, nDoc_it_no, nDoc_op_no, nAop_id,;
			   nAop_att_id, nDoc_op_desc, lKumul)
local nF_DOC_OPS := F__DOC_OPS
local nTArea := SELECT()
local nTRec := RecNo()
local lRet := .f.

if (lKumul == nil)
	lKumul := .f.
endif

if (lKumul == .t.)
	nF_DOC_OPS := F_DOC_OPS
endif

select (nF_DOC_OPS)
set order to tag "1"
go top
seek docno_str(nDoc_no) + ;
	docit_str(nDoc_it_no) + ;
	docop_str(nDoc_op_no)
 
if (field->aop_id == nAop_id) .and. ;
   (field->aop_att_id == nAop_att_id ) .and. ;
   (field->doc_op_desc == nDoc_op_desc)
	lRet := .t.
endif

select (nTArea)
go (nTRec)

return lRet





// ----------------------------------------------
// vraca string napunjen promjenama tipa "20"
// ----------------------------------------------
function _lit_20_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "artikal: " + PADR(g_art_desc( field->art_id ), 10)
	cRet += "#"
	cRet += "kol.=" + ALLTRIM(STR(field->num_1, 8, 2))
	cRet += ","
	cRet += "vis.=" + ALLTRIM(STR(field->num_2, 8, 2))
	cRet += ","
	cRet += "sir.=" + ALLTRIM(STR(field->num_3, 8, 2))
	cRet += "#"
	
	if !EMPTY(field->char_1)
		cRet += "opis.=" + ALLTRIM(field->char_1)
		cRet += "#"
	endif
	
	if !EMPTY(field->char_2)
		cRet += "shema.=" + ALLTRIM(field->char_2)
		cRet += "#"
	endif

	select doc_lit
	
	skip
enddo

select (nTArea)

return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "21"
// ----------------------------------------------
function _lit_21_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	
	cRet += "stavka: " + ALLTRIM( STR( field->int_1) ) 
	cRet += "#"
	cRet += ALLTRIM("artikal: " + PADR(g_art_desc( field->art_id ), 30))
	cRet += "#"
	cRet += "staklo br: " + ALLTRIM( STR( field->int_2) ) 
	cRet += "#"
	cRet += "lom komada: " + ALLTRIM( STR( field->num_2 ) )
	cRet += "#"
	cRet += "opis: " + ALLTRIM( field->char_1 )
	
	select doc_lit
	
	skip
enddo

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "30"
// ----------------------------------------------
function _lit_30_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "d.oper.: " + g_aop_desc( field->int_1 )
	cRet += "#"
	cRet += "atr.d.oper.:" + g_aop_att_desc(field->int_2)
	cRet += ","
	cRet += "d.opis:" + ALLTRIM(field->char_1)
	cRet += "#"
	
	select doc_lit
	
	skip
enddo

select (nTArea)

return cRet




// ----------------------------------------------
// vraca string napunjen promjenama tipa "01"
// ----------------------------------------------
function _lit_01_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

cRet += "Otvaranje naloga...#"
	
select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "99"
// ----------------------------------------------
function _lit_99_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

nStat := field->int_1

do case
	case nStat == 1
		cRet := "zatvoren nalog...#"
	case nStat == 2
		cRet := "ponisten nalog...#"
	case nStat == 4
		cRet := "djelimicno zatvoren nalog...#"
	case nStat == 5
		cRet := "zatvoren, ali nije isporucen...#"
endcase

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "10"
// ----------------------------------------------
function _lit_10_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "narucioc: " + PADR( g_cust_desc( field->int_1 ), 20)
	cRet += "#"
	cRet += "prioritet: " + ALLTRIM(STR(field->int_2))
	cRet += "#"
	
	select doc_lit
	skip
enddo

select (nTArea)

return cRet


// ----------------------------------------------
// vraca string napunjen promjenama tipa "11"
// ----------------------------------------------
function _lit_11_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "objekat: " + ALLTRIM( g_obj_desc( field->int_1 ) )
	cRet += "#"
	cRet += "datum isp.: " + DTOC(field->date_1)
	cRet += "#"
	cRet += "vrij.isp.: " + ALLTRIM(field->char_1)
	cRet += "#"
	cRet += "mjesto isp.: " + ALLTRIM(field->char_2)
	cRet += "#"
	
	select doc_lit
	skip
enddo

select (nTArea)

return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "12"
// ----------------------------------------------
function _lit_12_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "kontakt.: " + g_cont_desc( field->int_1 )
	cRet += "#"
	cRet += "kont.d.opis.: " + ALLTRIM(field->char_1)
	cRet += "#"
	
	select doc_lit
	skip
enddo

select (nTArea)

return cRet



// ----------------------------------------------
// vraca string napunjen promjenama tipa "13"
// ----------------------------------------------
function _lit_13_get(nDoc_no, nDoc_log_no)
local cRet := ""
local nTArea := SELECT()

select doc_lit
set order to tag "1"
go top
seek docno_str(nDoc_no) + doclog_str(nDoc_log_no)

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_log_no == nDoc_log_no

	cRet += "vr.plac: " + s_pay_id( field->int_1 )
	cRet += "#"
	cRet += "placeno: " + ALLTRIM(field->char_1)
	cRet += "#"
	cRet += "opis: " + ALLTRIM(field->char_2)
	cRet += "#"
	
	select doc_lit
	skip
enddo

select (nTArea)

return cRet




