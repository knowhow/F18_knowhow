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

#include "fakt.ch"


// --------------------------------------------------------------------
// vraca atribut iz pomocne tabele
// --------------------------------------------------------------------
function get_fakt_atribut( id_firma, tip_dok, br_dok, r_br, atribut )
local _ret := ""
local _t_area := SELECT()

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif

set order to tag "1"
go top

seek ( id_firma + tip_dok + br_dok + r_br + atribut )

if FOUND()
    _ret := ALLTRIM( field->value )
endif

// zatvori mi fakt_atribute
use

select ( _t_area )

return _ret




// ---------------------------------------------------------------------------
// setovanje atributa u pomocnu tabelu
// ---------------------------------------------------------------------------
function set_fakt_atribut( id_firma, tip_dok, br_dok, r_br, atribut, value )
local _ok := .t.
local _rec, _t_area 

_t_area := SELECT()

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif

set order to tag "1"
go top
seek ( id_firma + tip_dok + br_dok + r_br + atribut )

if !FOUND()

    // nema zapisa...

    append blank

    _rec := dbf_get_rec()

    _rec["idfirma"] := id_firma
    _rec["idtipdok"] := tip_dok
    _rec["brdok"] := br_dok
    _rec["rbr"] := r_br
    _rec["atribut"] := atribut
    _rec["value"] := value

    dbf_update_rec( _rec )

else
    
    // postoji zapis, setuj samo value

    _rec := dbf_get_rec()
    _rec["value"] := value
    dbf_update_rec( _rec )

endif

// zatvori fakt atribute
select (F_FAKT_ATRIB)
use

// vrati se gdje si bio !
select ( _t_area )

return _ok



// --------------------------------------------------------------------------
// ubaci atribute iz hash matrice u dbf atribute
// --------------------------------------------------------------------------
function fakt_atrib_hash_to_dbf( id_firma, tip_dok, br_dok, r_br, hash )
local _rec, _key

// prodji kroz atribute i napuni dbf
for each _key in hash:keys()
    set_fakt_atribut( id_firma, tip_dok, br_dok, r_br, _key, hash[ _key ] )
next

return


// -------------------------------------------------------------------------
// vraca odredjeni atribut sa servera
// -------------------------------------------------------------------------
function get_fakt_atribut_from_server( id_firma, tip_dok, br_dok, r_br, attr )
local _val := ""
local _attr := get_fakt_atrib_list_from_server( id_firma, tip_dok, br_dok, r_br, attr )

if LEN( _attr ) <> 0
    _val := _attr[ 1, 3 ]
endif

return _val


// ----------------------------------------------------------------------------
// vraca listu atributa sa servera za pojedini dokument
// 
// ako zadamo id_firma + tip_dok + br_dok -> dobijamo sve za taj dokument
// ako zadamo id_firma + tip_dok + br_dok + r_br -> dobijamo za tu stavku
// ako zadamo id_firma + tip_dok + br_dok + r_br + atribut -> dobijamo 
//                                                   samo trazeni atribut
//
// vraca se matrica { "rbr", "value", "atribut" }
// ----------------------------------------------------------------------------
function get_fakt_atrib_list_from_server( id_firma, tip_dok, br_dok, r_br, atribut )
local _atrib := {}
local _qry, _table, oItem
local _server := pg_server()

if r_br == NIL
    r_br := ""
endif

if atribut == NIL
    atribut := ""
endif

_qry := "SELECT rbr, atribut, value "
_qry += "FROM fmk.fakt_fakt_atributi "
_qry += "WHERE idfirma = " + _sql_quote( id_firma )
_qry += " AND idtipdok = " + _sql_quote( tip_dok )
_qry += " AND brdok = " + _sql_quote( br_dok )

if !EMPTY( r_br )
    _qry += " AND rbr = " + _sql_quote( r_br )
endif

if !EMPTY( atribut )
    _qry += " AND atribut = " + _sql_quote( atribut )
endif

_qry += " ORDER BY atribut"

// izvrsi query
_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

// napuni mi matricu sa rezultatom...
do while !_table:EOF()

    oItem := _table:GetRow()
    
    AADD( _atrib, { oItem:FieldGet( oItem:FieldPos( "rbr") ), ;
                    oItem:FieldGet( oItem:FieldPos( "atribut" ) ), ;
                    hb_utf8tostr( oItem:FieldGet( oItem:FieldPos( "value" ) ) ) } )    

    _table:Skip()

enddo

return _atrib



// ---------------------------------------------------------
// zapuje fakt atribute
// ---------------------------------------------------------
function zapp_fakt_atributi()
local _t_area := SELECT()

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif

zap
__dbPack()

// zatvori ih
use

select ( _t_area )
return



// ---------------------------------------------------------------------------
// brisanje atributa iz lokalnog dbf-a
// ---------------------------------------------------------------------------
function delete_fakt_atribut( id_firma, tip_dok, br_dok, r_br, atribut )
local _ok := .t.
local _t_area := SELECT()

if r_br == NIL
    r_br := ""
endif

if atribut == NIL
    atribut := ""
endif

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif
go top
seek ( id_firma + tip_dok + br_dok + r_br + atribut ) 

do while !EOF() .and. field->idfirma == id_firma .and. field->idtipdok == tip_dok ;
                .and. field->brdok == br_dok ;
                .and. IF( !EMPTY( r_br ), field->rbr == r_br, .t. ) ;
                .and. IF( !EMPTY( atribut ), field->atribut == atribut, .t. ) ;
    
    delete
    skip

enddo

__dbPack()

// zatvori mi fakt atribute
select ( F_FAKT_ATRIB )
use

select ( _t_area )
return _ok



// ------------------------------------------------------------------------
// brisanje atributa sa servera
// ------------------------------------------------------------------------
function delete_fakt_atributi_from_server( id_firma, tip_dok, br_dok )
local _ok := .t.
local _qry
local _server := pg_server()

// prvo pobrisi sa servera
_qry := "DELETE FROM fmk.fakt_fakt_atributi "
_qry += "WHERE "
_qry += "idfirma = " + _sql_quote( id_firma ) 
_qry += " AND idtipdok = " + _sql_quote( tip_dok )
_qry += " AND brdok = " + _sql_quote( br_dok )
 
_ret := _sql_query( _server, _qry )

if VALTYPE( _ret ) == "L"
    _ok := .f.
endif

return _ok


// -------------------------------------------------------------------------
// pusiranje atributa na server
// -------------------------------------------------------------------------
function fakt_atributi_dbf_to_server( id_firma, tip_dok, br_dok )
local _ok := .t.
local _t_area := SELECT()
local _qry, _table
local _server := pg_server()
local _res

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif

// nema zapisa, nemam sta raditi....
if RECCOUNT() == 0
    return _ok
endif

// prvo mi pobrisi sa servera ove podatke... 
if !delete_fakt_atributi_from_server( id_firma, tip_dok, br_dok )
    _ok := .f.
    select ( _t_area )
    return _ok
endif

select fakt_atrib
set order to tag "1"
go top

// insertuj iz dbf table
do while !EOF()

    _qry := "INSERT INTO fmk.fakt_fakt_atributi "
    _qry += "( idfirma, idtipdok, brdok, rbr, atribut, value ) "
    _qry += "VALUES (" 
    _qry += _sql_quote( id_firma ) + ", " 
    _qry += _sql_quote( tip_dok ) + ", " 
    _qry += _sql_quote( br_dok ) + ", " 
    _qry += _sql_quote( field->rbr ) + ", " 
    _qry += _sql_quote( field->atribut ) + ", " 
    _qry += _sql_quote( field->value ) 
    _qry += ")"

    _res := _sql_query( _server, _qry )

    if VALTYPE( _res ) == "L"
        _ok := .f.
        exit
    endif 

    skip

enddo

// zatvori mi atribute
select fakt_atrib
use

select ( _t_area )
return _ok




// ------------------------------------------------------------------------
// puni lokalni dbf sa podacima iz matrice
// ------------------------------------------------------------------------
function fakt_atributi_server_to_dbf( id_firma, tip_dok, br_dok )
local _atrib
local _i, _rec
local _t_area := SELECT()
local _ok := .t.

// daj mi atribute sa servera... ako postoje !
_atrib := get_fakt_atributi_arr_from_server( id_firma, tip_dok, br_dok )

if VALTYPE( _atrib ) == "L"
    // nije se nista napunilo, matrica je NIL
    _ok := .f.
    return _ok 
endif

// matrica je jednostavno prazna, nema nista...
if LEN( _atrib ) == 0
    return _ok
endif

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif
go top

for _i := 1 to LEN( _atrib )

    append blank

    _rec := dbf_get_rec()
    _rec["idfirma"] := id_firma
    _rec["idtipdok"] := tip_dok
    _rec["brdok"] := br_dok
    _rec["rbr"] := _atrib[ _i, 1 ]
    _rec["atribut"] := _atrib[ _i, 2 ]
    _rec["value"] := _atrib[ _i, 3 ]
    
    dbf_update_rec( _rec )

next

// zatvori mi fakt atribute
select ( F_FAKT_ATRIB )
use

select ( _t_area )

return _ok






