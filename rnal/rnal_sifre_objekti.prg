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
// otvara tabelu objekata
// -------------------------------------
function s_objects( cId, nCust_id, cObjDesc, dx, dy )
local nTArea
local cHeader
local cTag := "4"
private ImeKol
private Kol

if nCust_id == nil
	nCust_id := -1
endif

if cObjDesc == nil
	cObjDesc := ""
endif

__cust_id := nCust_id

nTArea := SELECT()

cHeader := "Objekti /"

select objects

if cID == nil
	// obj_desc
	cTag := "4"
else
	// cust_id + obj_desc
	cTag := "3"
endif

set_a_kol(@ImeKol, @Kol, nCust_id)

if VALTYPE(cId) == "C"
	//try to validate
	if VAL(cId) <> 0
	
		cId := VAL(cId)
		nCust_id := -1
		cObjDesc := ""
		cTag := "1"
	endif
endif

set order to tag cTag

set filter to
obj_filter(nCust_id, cObjDesc)

cRet := PostojiSifra(F_OBJECTS, cTag, 10, 70, cHeader, @cId, dx, dy, ;
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
		nRet := wid_edit( "OBJ_ID" )
endcase


return nRet



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol, nCust_id)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("ID/MC", 10), {|| sif_idmc(obj_id)}, "obj_id", {|| _inc_id(@wobj_id, "OBJ_ID"), .f.}, {|| .t.}})
AADD(aImeKol, {PADC("Narucioc", 10), {|| g_cust_desc( cust_id ) }, "cust_id", {|| set_cust_id(@wcust_id) }, {|| s_customers(@wcust_id), show_it( g_cust_desc(wcust_id)) }})
AADD(aImeKol, {PADC("Naziv objekta", 20), {|| PADR(obj_desc, 30)}, "obj_desc", {|| .t.}, {|| _chk_id(@wobj_id, "OBJ_ID") } })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return




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



// -------------------------------------------
// filter po cust_id
// nCust_id - id customer
// -------------------------------------------
static function obj_filter(nCust_id, cObjDesc)
local cFilter := ""

if nCust_id > 0
	cFilter += "cust_id == " + custid_str(nCust_id)
endif

if !EMPTY(cObjDesc)
	
	if !EMPTY(cFilter)
		cFilter += " .and. "
	endif
	
	cObjDesc := ALLTRIM(cObjDesc)
	cFilter += " ALLTRIM(UPPER(obj_desc)) = " + cm2str(UPPER(cObjDesc))
	
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

return



// -------------------------------
// convert obj_id to string
// -------------------------------
function objid_str(nId)
return STR(nId, 10)



// -------------------------------
// get obj_id_desc by obj_id
// -------------------------------
function g_obj_desc(nObj_id, lEmpty)
local cObjDesc := "?????"
local nTArea := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t.
	cObjDesc := ""
endif

O_OBJECTS
select objects
set order to tag "1"
go top
seek objid_str(nObj_id)

if FOUND()
	if !EMPTY(field->obj_desc)
		cObjDesc := ALLTRIM(field->obj_desc)
	endif
endif

select (nTArea)

return cObjDesc


