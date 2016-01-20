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


#include "f18.ch"
#include "cre_all.ch"

// -----------------------------------------
// kreiranje tabele relacija
// -----------------------------------------
function cre_relation( ver )
local aDbf
local _table_name, _alias, _created 

aDbf := g_rel_tbl()

_table_name := "relation"
_alias := "RELATION"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX( "1", "TFROM+TTO+TFROMID", _alias )
CREATE_INDEX( "2", "TTO+TFROM+TTOID", _alias )

return


// ------------------------------------------
// struktura tabele relations
// ------------------------------------------
static function g_rel_tbl()
local aDbf := {}

// TABLE FROM
AADD( aDbf, { "TFROM"   , "C", 10, 0 } )
// TABLE TO
AADD( aDbf, { "TTO"   , "C", 10, 0 } )
// TABLE FROM ID
AADD( aDbf, { "TFROMID" , "C", 10, 0 } )
// TABLE TO ID
AADD( aDbf, { "TTOID" , "C", 10, 0 } )

// structure example:
// -------------------------------------------
// TFROM    | TTO     | TFROMID  | TTOID
// ------------------- -----------------------
// ARTICLES | ROBA    |    123   |  22TX22
// CUSTOMS  | PARTN   |     22   |  1CT02
// .....

return aDbf


// ---------------------------------------------
// vraca vrijednost za zamjenu
// cType - '1' = TBL1->TBL2, '2' = TBL2->TBL1 
// cFrom - iz tabele
// cTo - u tabelu
// cId - id za pretragu
// ---------------------------------------------
function g_rel_val( cType, cFrom, cTo, cId )
local xVal := ""
local nTArea := SELECT()

if cType == nil
	cType := "1"
endif

O_RELATION
set order to tag &cType
go top

seek PADR(cFrom,10) + PADR(cTo,10) + PADR(cId,10) 

if FOUND() .and. field->tfrom == PADR(cFrom, 10) ;
	.and. field->tto == PADR(cTo, 10) ;
	.and. field->tfromid == PADR(cId, 10)

	if cType == "1"
		xVal := field->ttoid
	else
		xVal := field->tfromid
	endif

endif

select ( nTArea )
return xVal



// ------------------------------
// dodaj u relacije
// ------------------------------
function add_to_relation( f_from, f_to, f_from_id, f_to_id )
local _t_area := SELECT()
local _rec

select ( F_RELATION )
if !Used()
    O_RELATION
endif

select relation

append blank
_rec := dbf_get_rec()

_rec["tfrom"] := PADR( f_from, 10 )
_rec["tto"] := PADR( f_to, 10 )
_rec["tfromid"] := PADR( f_from_id, 10 )
_rec["ttoid"] := PADR( f_to_id, 10 )

update_rec_server_and_dbf( "relation", _rec, 1, "FULL" )

select ( _t_area )
return



// ---------------------------------------------
// otvara tabelu relacija
// ---------------------------------------------
function p_relation( cId , dx, dy )
local nTArea := SELECT()
local i
local bFrom
local bTo
private ImeKol
private Kol

select ( F_RELATION )
if !Used()
    O_RELATION
endif

ImeKol:={}
Kol:={}

AADD(ImeKol, { "Tab.1" , {|| tfrom }, "tfrom", {|| .t. }, {|| !EMPTY(wtfrom)} })
AADD(ImeKol, { "Tab.2" , {|| tto   }, "tto", {|| .t.}, {|| !EMPTY(wtto)} })
AADD(ImeKol, { "Tab.1 ID" , {|| tfromid }, "tfromid" })
AADD(ImeKol, { "Tab.2 ID" , {|| ttoid }, "ttoid" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return PostojiSifra( F_RELATION, 1, 10, 65, "Lista relacija konverzije", @cId, dx, dy )




// ---------------------------------------------
// vraca cijenu artikla iz sifrarnika robe
// ---------------------------------------------
function g_art_price( cId, cPriceType )
local nPrice := 0
local nTArea := SELECT()

if cPriceType == nil
	cPriceType := "VPC1"
endif

select ( F_ROBA )
if !Used()
    O_ROBA
endif

select roba
seek cId

if FOUND() .and. field->id == cID
	do case
		case cPriceType == "VPC1"
			nPrice := field->vpc
		case cPriceType == "VPC2"
			nPrice := field->vpc2
		case cPriceType == "MPC1"
			nPrice := field->mpc
		case cPriceType == "MPC2"
			nPrice := field->mpc2
		case cPriceType == "NC"
			nPrice := field->nc
	endcase
endif

return nPrice




