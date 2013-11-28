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

#include "fmk.ch"
#include "hbclass.ch"
#include "hbgtinfo.ch"
#include "common.ch"


CLASS F18_DOK_ATRIB

    DATA modul
    DATA from_dbf
    DATA dok_hash
    DATA atrib

    METHOD New()
    METHOD get_atrib()
    METHOD set_atrib()
    METHOD delete_atrib()
    METHOD create_local_atrib_table()
    METHOD fix_atrib()
    METHOD zapp_local_table()
    METHOD atrib_dbf_to_server()
    METHOD atrib_server_to_dbf()
    METHOD atrib_hash_to_dbf()
    METHOD update_atrib_from_server()
    METHOD delete_atrib_from_server()
    METHOD open_local_table()

    PROTECTED:

        VAR table_name_server
        VAR table_name_local
        VAR alias
        VAR area

        METHOD get_atrib_from_server()
        METHOD get_atrib_from_dbf()
        METHOD get_atrib_list_from_server()
        METHOD set_table_name()
        METHOD set_dbf_alias()
        METHOD set_dbf_area()
        METHOD atrib_delete_duplicate()
        METHOD atrib_delete_rest()

ENDCLASS



// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:New( _modul_, _dok_hash_, _atrib_ )

::dok_hash := hb_hash()

if _modul_ <> NIL
    ::modul := _modul_
endif

if _dok_hash_ <> NIL
    ::dok_hash := _dok_hash_
endif

if _atrib_ <> NIL
    ::atrib := _atrib_
endif

return SELF




// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:set_dbf_alias()
::alias := ALLTRIM( LOWER( ::modul ) ) + "_atrib" 
return SELF




// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:set_dbf_area()
local _tmp := 355

do while .t.   
    SELECT ( _tmp )
    if USED()
        ++ _tmp
        loop
    else
        exit
    endif
enddo

::area := _tmp

return SELF




// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:open_local_table()
local _alias 

// setuj naziv tabele
::set_table_name()
// setuj alijas
::set_dbf_alias()
// oredi podrucje
::set_dbf_area()

//#xcommand O_FAKT_ATRIB => select (F_FAKT_ATRIB) ; my_usex ("fakt_atrib") ; set order to tag  "1"
SELECT ( ::area )

my_use_temp( ::alias, my_home() + ::table_name_local + ".dbf", .f., .t. )

SET ORDER TO TAG "1"

return SELF





// ----------------------------------------------------------------
// kreira se pomocna tabela atributa...
// ----------------------------------------------------------------
METHOD F18_DOK_ATRIB:create_local_atrib_table( force )
local _dbf := {}
local _ind_key := "idfirma + idtipdok + brdok + rbr + atribut"
local _ind_uniq := ".t."

if force == NIL
    force := .f.
endif

AADD( _dbf, { 'IDFIRMA'   , 'C' ,   2 ,  0 } )
AADD( _dbf, { 'IDTIPDOK'  , 'C' ,   2 ,  0 } )
AADD( _dbf, { 'BRDOK'     , 'C' ,   8 ,  0 } )
AADD( _dbf, { 'RBR'       , 'C' ,   3 ,  0 } ) 
AADD( _dbf, { 'ATRIBUT'   , 'C' ,  50 ,  0 } )
AADD( _dbf, { 'VALUE'     , 'C' , 250 ,  0 } )

::set_table_name()

if force .or. !FILE( my_home() + ::table_name_local + ".dbf" )
    DBCreate( my_home() + ::table_name_local + ".dbf", _dbf )
endif

// otvori tabelu...
::open_local_table()

//INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx) FOR &cFilter UNIQUE
INDEX ON &_ind_key TAG "1" FOR &_ind_uniq UNIQUE

SELECT ( ::area )
USE
     	         
return SELF



// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:set_table_name()

if !EMPTY( ::modul )
    ::table_name_local := ALLTRIM( LOWER( ::modul ) ) + "_pripr_atrib"
    ::table_name_server := "fmk." + ALLTRIM( LOWER( ::modul ) ) + "_" + ;
                                ALLTRIM( LOWER( ::modul ) ) + "_atributi"
else 
    MsgBeep( "DATA:modul nije setovano !" )
endif

return SELF


// ----------------------------------------------------------------------
// vraca atribut
// ----------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib( _dok, _atribut )
local _ret

// postoji mogucnost i setovanja kroz poziv metode
if PCOUNT() > 0

    if _dok <> NIL
        ::dok_hash := _dok    
    endif

    if _atribut <> NIL
        ::atrib := _atribut
    endif

endif

// setuj naziv tabele
::set_table_name()

if !::from_dbf
    _ret := ::get_atrib_from_server()
else
    _ret := ::get_atrib_from_dbf()
endif

return _ret



// --------------------------------------------------------------------
// vraca atribut iz pomocne tabele
// --------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib_from_dbf()
local _ret := ""
local _t_area := SELECT()

// otvori mi tabelu atributa...
::open_local_table()

set order to tag "1"
go top

seek ( ::dok_hash["idfirma"] + ::dok_hash["idtipdok"] + ::dok_hash["brdok"] + ::dok_hash["rbr"] + ::atrib )

if FOUND()
    _ret := ALLTRIM( field->value )
endif

USE

select ( _t_area )

return _ret



// -------------------------------------------------------------------------
// vraca odredjeni atribut sa servera
// -------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib_from_server()
local _val := ""
local _attr := ::get_atrib_list_from_server()

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
METHOD F18_DOK_ATRIB:get_atrib_list_from_server()
local _a_atrib := {}
local _qry, _table, oItem
local _idfirma, _idtipdok, _brdok, _rbr, _atrib
local _where

_idfirma := ::dok_hash["idfirma"]
_idtipdok := ::dok_hash["idtipdok"]
_brdok := ::dok_hash["brdok"]

if ::atrib == NIL
    _atrib := ""
else
    _atrib := ::atrib
endif

if hb_hhaskey( ::dok_hash, "rbr" )
    if ::dok_hash["rbr"] == NIL
        _rbr := ""
    else
        _rbr := ::dok_hash["rbr"]
    endif
else
    _rbr := ""
endif

_where := "idfirma = " + _sql_quote( _idfirma )
_where += " AND "
_where += "brdok = " + _sql_quote( _brdok )
_where += " AND "
_where += "idtipdok = " + _sql_quote( _idtipdok )

if !EMPTY( _rbr )
    _where += " AND rbr = " + _sql_quote( _rbr )
endif

if !EMPTY( _atrib )
    _where += "atribut = " + _sql_quote( _atrib )
endif
 
_table := _select_all_from_table( ::table_name_server, NIL, { _where }, { "atribut" } )

if _table == NIL
    return NIL
endif

_table:Refresh()

// napuni mi matricu sa rezultatom...
do while !_table:EOF()
    oItem := _table:GetRow()
    AADD( _a_atrib, { oItem:FieldGet( oItem:FieldPos( "rbr") ), ;
                    oItem:FieldGet( oItem:FieldPos( "atribut" ) ), ;
                    hb_utf8tostr( oItem:FieldGet( oItem:FieldPos( "value" ) ) ) } )    
    _table:Skip()
enddo

return _a_atrib





// ---------------------------------------------------------------------------
// setovanje atributa u pomocnu tabelu
// ---------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:set_atrib( atrib_key, value )
local _ok := .t.
local _rec, _t_area 

_t_area := SELECT()

::open_local_table()

set order to tag "1"
go top
seek ( ::dok_hash["idfirma"] + ::dok_hash["idtipdok"] + ::dok_hash["brdok"] + ::dok_hash["rbr"] + atrib_key )

if !FOUND() 

    // ako je prazan vrijednost
    // nemoj upisivati...
    if EMPTY( value )
        use
        select ( _t_area )
        return _ok
    endif

    // nema zapisa...

    append blank

    _rec := dbf_get_rec()

    _rec["idfirma"] := ::dok_hash["idfirma"]
    _rec["idtipdok"] := ::dok_hash["idtipdok"]
    _rec["brdok"] := ::dok_hash["brdok"]
    _rec["rbr"] := ::dok_hash["rbr"]
    _rec["atribut"] := atrib_key
    _rec["value"] := value

    dbf_update_rec( _rec )

else
    
    // setuj i ako je value empty i ako nije
    _rec := dbf_get_rec()
    _rec["value"] := value
    dbf_update_rec( _rec )

endif

// zatvori fakt atribute
use

// vrati se gdje si bio !
select ( _t_area )

return _ok



// --------------------------------------------------------------------------
// ubaci atribute iz hash matrice u dbf atribute
// --------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_hash_to_dbf( hash )
local _rec, _key

// prodji kroz atribute i napuni dbf
for each _key in hash:keys()    
    ::set_atrib( _key, hash[ _key ] )
next

return




// ---------------------------------------------------------
// zapuje fakt atribute
// ---------------------------------------------------------
METHOD F18_DOK_ATRIB:zapp_local_table()
local _t_area := SELECT()

::open_local_table()

zap
__dbPack()

// zatvori ih
use

select ( _t_area )
return



// ---------------------------------------------------------------------------
// brisanje atributa iz lokalnog dbf-a
// ---------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:delete_atrib()
local _ok := .t.
local _t_area := SELECT()
local _idfirma, _idtipdok, _brdok, _rbr, _atribut

_idfirma := ::dok_hash["idfirma"]
_idtipdok := ::dok_hash["idtipdok"]
_brdok := ::dok_hash["brdok"]
_rbr := ::dok_hash["rbr"]
_atribut := ::dok_hash["atribut"]

if _rbr == NIL
    _rbr := ""
endif

if _atribut == NIL
    _atribut := ""
endif

::open_local_table()
go top
seek ( _idfirma + _idtipdok + _brdok + _rbr + _atribut ) 

do while !EOF() .and. field->idfirma == _idfirma .and. field->idtipdok == _idtipdok ;
                .and. field->brdok == _brdok ;
                .and. IF( !EMPTY( _rbr ), field->rbr == _rbr, .t. ) ;
                .and. IF( !EMPTY( _atribut ), field->atribut == _atribut, .t. )
    delete
    skip
enddo

__dbPack()
// zatvori mi fakt atribute
use

select ( _t_area )
return _ok



// ------------------------------------------------------------------------
// update atributa na serveru
// ------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:update_atrib_from_server( params )
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
_qry := "UPDATE " + ::table_name_server + " " 
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
METHOD F18_DOK_ATRIB:delete_atrib_from_server()
local _ok := .t.
local _qry
local _server := pg_server()

// prvo pobrisi sa servera
_qry := "DELETE FROM " + ::table_name_server
_qry += " WHERE "
_qry += "idfirma = " + _sql_quote( ::dok_hash["idfirma"] ) 
_qry += " AND idtipdok = " + _sql_quote( ::dok_hash["idtipdok"] )
_qry += " AND brdok = " + _sql_quote( ::dok_hash["brdok"] )
 
_ret := _sql_query( _server, _qry )

if VALTYPE( _ret ) == "L"
    _ok := .f.
endif

return _ok



// -------------------------------------------------------------------------
// pusiranje atributa na server
// -------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_dbf_to_server()
local _ok := .t.
local _t_area := SELECT()
local _qry, _table
local _server := pg_server()
local _res

::open_local_table()

// nema zapisa, nemam sta raditi....
if RECCOUNT() == 0
    USE
    select ( _t_area )
    return _ok
endif

// prvo mi pobrisi sa servera ove podatke... 
if !::delete_atrib_from_server()
    USE
    _ok := .f.
    select ( _t_area )
    return _ok
endif

select ALIAS( ::area )
set order to tag "1"
go top

// insertuj iz dbf table
do while !EOF()

    // ako je prazna vrijednost, nemoj nista upisivati...
    if EMPTY( field->value )
        skip
        loop
    endif

    if ( ::dok_hash["idfirma"] != field->idfirma ) .or. ;
            ( ::dok_hash["idtipdok"] != field->idtipdok ) .or. ;
            ( ::dok_hash["brdok"] != field->brdok )
        // ogranici se na stavke dokumenta
        skip
        loop
    endif

    _qry := "INSERT INTO " + ::table_name_server + " "
    _qry += "( idfirma, idtipdok, brdok, rbr, atribut, value ) "
    _qry += "VALUES (" 
    _qry += _sql_quote( ::dok_hash["idfirma"] ) + ", " 
    _qry += _sql_quote( ::dok_hash["idtipdok"] ) + ", " 
    _qry += _sql_quote( ::dok_hash["brdok"] ) + ", " 
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
select ALIAS( ::area )
use

select ( _t_area )
return _ok




// ------------------------------------------------------------------------
// puni lokalni dbf sa podacima iz matrice
// ------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_server_to_dbf()
local _atrib
local _i, _rec
local _t_area := SELECT()
local _ok := .t.

::set_table_name()

// daj mi atribute sa servera... ako postoje !
_atrib := ::get_atrib_list_from_server()

if VALTYPE( _atrib ) == "L"
    // nije se nista napunilo, matrica je NIL
    _ok := .f.
    return _ok 
endif

// matrica je jednostavno prazna, nema nista...
if LEN( _atrib ) == 0
    return _ok
endif

::open_local_table()
go top

for _i := 1 to LEN( _atrib )

    append blank

    _rec := dbf_get_rec()
    _rec["idfirma"] := ::dok_hash["idfirma"]
    _rec["idtipdok"] := ::dok_hash["idtipdok"]
    _rec["brdok"] := ::dok_hash["brdok"]
    _rec["rbr"] := _atrib[ _i, 1 ]
    _rec["atribut"] := _atrib[ _i, 2 ]
    _rec["value"] := _atrib[ _i, 3 ]
    
    dbf_update_rec( _rec )

next

// zatvori mi fakt atribute
select ( ::area )
use

select ( _t_area )

return _ok


// -----------------------------------------------------
// ova funkcija treba da uradi:
// - provjeri ima li viska atributa
// - provjeri ima li duplih atributa 
// -----------------------------------------------------
METHOD F18_DOK_ATRIB:fix_atrib( area, dok_arr )
local _dok_params
local _i

::set_table_name()

for _i := 1 to LEN( dok_arr )

    _dok_params := hb_hash()
    _dok_params["idfirma"] := dok_arr[ _i, 1 ]
    _dok_params["idtipdok"] := dok_arr[ _i, 2 ]
    _dok_params["brdok"] := dok_arr[ _i, 3 ]
    
    // pobrisi duple zapise
    ::atrib_delete_duplicate( _dok_params )

next
    
// brisi visak atributa ako postoji
::atrib_delete_rest( area )

return


// -----------------------------------------------------
// brisi visak atributa ako postoji 
// -----------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_delete_rest( area )
local _id_firma, _tip_dok, _br_dok
local _t_area := SELECT()
local _ok := .t.
local _deleted := .f.
local _alias := ::alias
local _tmp := ALLTRIM( LOWER( ::modul ) ) + "_pripr"

// selekt pripreme tabele modula
select ALIAS( area )
set order to tag "1"

// otvori atribute
::open_local_table()

set order to tag "1"
go top

do while !EOF()
    
    skip 1
    _t_rec := RECNO()
    skip -1

    // selektuje pripremu tabelu modula !
    select ALIAS( area )

    // ima li u njoj stavke iz atributa ?
    seek &(_alias)->idfirma + &(_alias)->idtipdok + &(_alias)->brdok + &(_alias)->rbr

    if !FOUND()
        // prebaci se na atribute i pobrisi ...
        select ALIAS( ::area )
        delete
        _deleted := .t.
    else
        select ALIAS( ::area )
    endif

    go ( _t_rec )

enddo

if _deleted
    __dbPack()
endif

// zatvori atribute
use

select ( _t_area )

return _ok





// -----------------------------------------------------
// provjera ispravnosti atributa za dokument 
// -----------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_delete_duplicate( param )
local _id_firma, _tip_dok, _br_dok, _b1
local _t_area := SELECT()
local _ok := .t.
local _r_br, _atrib, _r_br_2, _atrib_2, _eof := .f.
local _deleted := .f.

_id_firma := param["idfirma"]
_tip_dok := param["idtipdok"]
_br_dok := param["brdok"]

::open_local_table()

set order to tag "1"
go top
seek _id_firma + _tip_dok + _br_dok

_b1 := {|| field->idfirma == _id_firma .and. field->idtipdok == _tip_dok .and. field->brdok == _br_dok }

do while !eof() .and. EVAL(_b1)

    // prvi zapis
    _r_br := field->rbr
    _atrib := field->atribut

    // sljedeci zapis  
    skip 1
    _t_rec := RECNO()
    _r_br_2 := field->rbr
    _atrib_2 := field->atribut

    if EOF()
       _eof := .t.
    else
       _eof := .f.
    endif

    if !_eof .and. EVAL(_b1) .and. (_r_br_2 == _r_br) .and. (_atrib_2 == _atrib)
        delete
        _deleted := .t.
    endif

    if _eof
        exit
    endif
    
    go _t_rec
enddo

if _deleted
    __dbPack()
endif

// zatvori atribute
use

select ( _t_area )

return _ok

