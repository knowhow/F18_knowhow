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

// --------------------------------------------------
// get atribut opis
// --------------------------------------------------
function get_fakt_atribut_opis(dok, from_server)
return get_fakt_atribut(dok, "opis", from_server)

// --------------------------------------------------
// get atribut ref, lot
// --------------------------------------------------
function get_fakt_atribut_ref(dok, from_server)
return get_fakt_atribut(dok, "ref", from_server)

function get_fakt_atribut_lot(dok, from_server)
return get_fakt_atribut(dok, "lot", from_server)


function get_fakt_atribut(dok, atribut, from_server)
local _ret

if from_server == NIL
   from_server := .t.
endif

if from_server
        _ret := get_fakt_atribut_from_server( dok["idfirma"], dok["idtipdok"], dok["brdok"], dok["rbr"], atribut)
else
        _ret := get_fakt_atribut_from_dbf( dok["idfirma"], dok["idtipdok"], dok["brdok"], dok["rbr"], atribut)
endif

return _ret

// --------------------------------------------------------------------
// vraca atribut iz pomocne tabele
// --------------------------------------------------------------------
function get_fakt_atribut_from_dbf( id_firma, tip_dok, br_dok, r_br, atribut )
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

    // ako je prazan vrijednost
    // nemoj upisivati...
    if EMPTY( value )
        select ( _t_area )
        return _ok
    endif

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
    
    // setuj i ako je value empty i ako nije
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
// update atributa na serveru
// ------------------------------------------------------------------------
function update_fakt_atributi_from_server( params )
local _ok := .t.
local _qry
local _server := pg_server()
local _old_firma := params["old_firma"]
local _old_tipdok := params["old_tipdok"]
local _old_brdok := params["old_brdok"]
local _new_firma := params["new_firma"]
local _new_tipdok := params["new_tipdok"]
local _new_brdok := params["new_brdok"]

// prvo pobrisi sa servera
_qry := "UPDATE fmk.fakt_fakt_atributi "
_qry += "SET "
_qry += "idfirma = " + _sql_quote( _new_firma ) 
_qry += ", idtipdok = " + _sql_quote( _new_tipdok )
_qry += ", brdok = " + _sql_quote( _new_brdok )
_qry += " WHERE "
_qry += " idfirma = " + _sql_quote( _old_firma ) 
_qry += " AND idtipdok = " + _sql_quote( _old_tipdok ) 
_qry += " AND brdok = " + _sql_quote( _old_brdok ) 

_ret := _sql_query( _server, _qry )

if VALTYPE( _ret ) == "L"
    _ok := .f.
endif

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

    // ako je prazna vrijednost, nemoj nista upisivati...
    if EMPTY( field->value )
        skip
        loop
    endif

    if (id_firma != field->idfirma) .or. (tip_dok != field->idtipdok) .or. (br_dok != field->brdok)
        // ogranici se na stavke dokumenta
        skip
        loop
    endif

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
_atrib := get_fakt_atrib_list_from_server( id_firma, tip_dok, br_dok )

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


// -----------------------------------------------------
// ova funkcija treba da uradi:
// - provjeri ima li viska atributa
// - provjeri ima li duplih atributa 
// -----------------------------------------------------
function fakt_atributi_fix( dok_arr )

// pobrisi duple zapise
fakt_atributi_brisi_duple( dok_arr )
// brisi visak atributa ako postoji
fakt_atributi_brisi_visak( dok_arr )

return

// -----------------------------------------------------
// brisi visak atributa ako postoji 
// -----------------------------------------------------
static function fakt_atributi_brisi_visak( dok_arr )
local _id_firma, _tip_dok, _br_dok
local _tmp
local _t_area := SELECT()
local _ok := .t.

if LEN( dok_arr ) > 1
    return _ok
endif

_id_firma := dok_arr[ 1, 1 ]
_tip_dok := dok_arr[ 1, 2 ]
_br_dok := dok_arr[ 1, 3 ]
_tmp := _id_firma + _tip_dok + _br_dok

select ( F_FAKT_ATRIB )
if !used()
    O_FAKT_ATRIB
endif

set order to tag "1"
go top

do while !EOF()
    
    skip 1
    _t_rec := RECNO()
    skip -1

    if field->idfirma + field->idtipdok + field->brdok <> _tmp
        delete
        __dbPack()
    endif

    go ( _t_rec )

enddo

// zatvori atribute
use

select ( _t_area )

return _ok





// -----------------------------------------------------
// provjera ispravnosti atributa za dokument 
// -----------------------------------------------------
static function fakt_atributi_brisi_duple( dok_arr )
local _id_firma, _tip_dok, _br_dok
local _t_area := SELECT()
local _ok := .t.

if LEN( dok_arr ) > 1
    return _ok
endif

_id_firma := dok_arr[ 1, 1 ]
_tip_dok := dok_arr[ 1, 2 ]
_br_dok := dok_arr[ 1, 3 ]

select ( F_FAKT_ATRIB )
if !used()
    O_FAKT_ATRIB
endif

set order to tag "1"
go top

do while !EOF() .and. field->idfirma == _id_firma .and. ;
        field->idtipdok == _tip_dok .and. ;
        field->brdok == _br_dok
    
    skip 1
    _t_rec := RECNO()
    skip -1

    _r_br := field->rbr

    skip 1
    
    if field->rbr == _r_br
        delete
        __dbPack()
    endif

    go ( _t_rec )

enddo

// zatvori atribute
use

select ( _t_area )

return _ok



