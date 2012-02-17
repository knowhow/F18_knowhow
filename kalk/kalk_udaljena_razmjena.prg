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


#include "kalk.ch"


function kalk_udaljena_razmjena_podataka()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. => export podataka               ")
AADD(_opcexe, {|| _kalk_export() })
AADD(_opc,"2. <= import podataka    ")
AADD(_opcexe, {|| _kalk_import() })

f18_menu( "razmjena", .f., _izbor, _opc, _opcexe )

close all
return


// ----------------------------------------
// export podataka modula KALK
// ----------------------------------------
static function _kalk_export()
local _vars := hb_hash()
local _exported := .f.

// uslovi exporta
if !_vars_export( @_vars )
    return
endif

// export podataka
_exported := __export( _vars )

// arhiviraj podatke
if _exported 
    // files =
    // _compress()
endif

return



// ----------------------------------------
// import podataka modula KALK
// ----------------------------------------
static function _kalk_import()
local _imported := .f.
local _vars := hb_hash()

// parametri
if !_vars_import( @_vars )
    return
endif

// dekompresovanje podataka
_decompress( _vars )

// import procedura
_imported := __import()

return



// -------------------------------------------
// uslovi exporta dokumenta
// -------------------------------------------
static function _vars_export( vars )
local _ret := .t.

return _ret



// -------------------------------------------
// uslovi importa dokumenta
// -------------------------------------------
static function _vars_import( vars )
local _ret := .t.

return _ret



// -------------------------------------------
// export podataka
// -------------------------------------------
static function __export( vars )
local _ret := .f.
local _id_firma, _id_vd, _br_dok
local _app_rec
local _cnt := 0

// kreiraj tabele exporta
_cre_exp_tbls()

// otvori export tabele za pisanje podataka
_o_exp_tables()

// otvori lokalne tabele za prenos
_o_tables()

select doks
go top

do while !EOF()
    
    _id_firma := field->idfirma
    _id_vd := field->idvd
    _br_dok := field->brdok

    // if if if if...


    // dodaj zapis u tabelu e_doks
    _app_rec := dbf_get_rec()
    select e_doks
    append blank
    dbf_update_rec( _app_rec )    

    ++ _cnt

    select kalk
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    do while !EOF() .and. field->idfirma == _id_firma .and. field->idvd == _id_vd .and. field->brdok == _br_dok

        _app_rec := dbf_get_rec()
        
        select e_kalk
        append blank
        dbf_update_rec( _app_rec )

        select kalk
        skip

    enddo

    select doks
    skip

enddo

if ( _cnt == 0 )
    _ret := .f.
endif

return _ret



// ----------------------------------------
// import podataka
// ----------------------------------------
static function __import()
local _ret := .t.
local _id_firma, _id_vd, _br_dok
local _app_rec
local _cnt := 0

// otvaranje export tabela
_o_exp_tables()

// otvori potrebne tabele za import podataka
_o_tables()

select e_doks
set order to tag "1"
go top

do while !EOF()

    _id_firma := field->idfirma
    _id_vd := field->idvd
    _br_dok := field->brdok

    // da li postoji u prometu vec ?
    if _vec_postoji_u_prometu( _id_firma, _id_vd, _br_dok ) == 0
        select e_doks
        skip
        loop
    endif

    // zikni je u nasu tabelu doks
    select e_doks
    _app_rec := dbf_get_rec()

    select doks
    update_rec_server_and_dbf( "kalk_doks", _app_rec )

    ++ _cnt

    // zikni je u nasu tabelu kalk
    select e_kalk
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    // prebaci mi stavke tabele KALK
    do while !EOF() .and. field->idfirma == _id_firma .and. field->idvd == _id_vd .and. field->brdok == _br_dok
        
        _app_rec := dbf_get_rec()

        select kalk
        update_rec_server_and_dbf( "kalk", _app_rec )

        select e_kalk
        skip

    enddo

    select e_doks
    skip

enddo

if _cnt > 0

    // moramo ziknuti i robu ako fali !
    select e_roba
    set order to tag "ID"
    go top

    do while !EOF()
    
        _roba_id := field->id

        select roba
        hseek _roba_id

        if !FOUND()

            select e_roba
            _app_rec := dbf_get_rec()

            select roba
            update_rec_server_and_dbf( "roba", _app_rec )

        endif

        select e_roba
        skip

    enddo

endif


return _ret


// ---------------------------------------------------------------------
// provjerava da li dokument vec postoji u prometu
// ---------------------------------------------------------------------
static function _vec_postoji_u_prometu( id_firma, id_vd, br_dok )
local _t_area := SELECT()
local _ret := .t.

select kalk_doks
go top
seek id_firma + id_vd + br_dok

if !FOUND()
    _ret := .f.
endif

select (_t_area)
return _ret



// ----------------------------------------
// kreiranje tabela razmjene
// ----------------------------------------
static function _cre_exp_tbls()

// tabela kalk
O_KALK
copy structure extended to ( my_home() + "struct" )
use
create (my_home() + "e_kalk") from ( my_home() + "struct")

// tabela doks
O_KALK_DOKS
copy structure extended to ( my_home() + "struct" )
use
create (my_home() + "e_doks") from ( my_home() + "struct")

// tabela roba
O_ROBA
copy structure extended to ( my_home() + "struct" )
use
create (my_home() + "e_roba") from ( my_home() + "struct")

// tabela partn
O_PARTN
copy structure extended to ( my_home() + "struct" )
use
create (my_home() + "e_partn") from ( my_home() + "struct")

// tabela partn
O_PARTN
copy structure extended to ( my_home() + "struct" )
use
create (my_home() + "e_partn") from ( my_home() + "struct")

// tabela konta
O_KONTO
copy structure extended to ( my_home() + "struct" )
use
create (my_home() + "e_konto") from ( my_home() + "struct")


return


// ----------------------------------------------------
// otvaranje potrebnih tabela za prenos
// ----------------------------------------------------
static function _o_tables()
O_KALK
O_KALK_DOKS
O_SIFK
O_SIFV
O_KONTO
O_PARTN
O_ROBA
return




// ----------------------------------------------------
// otvranje export tabela
// ----------------------------------------------------
static function _o_exp_tables( use_path )

if ( use_path == NIL )
    use_path := my_home()
endif

// otvori kalk tabelu
select ( 500 )
use ( use_path + "e_kalk" ) alias "e_kalk"
index on ( idfirma + idvd + brdok ) tag "1"

// otvori doks tabelu
select ( 501 )
use ( use_path + "e_doks" ) alias "e_doks"
index on ( idfirma + idvd + brdok ) tag "1"

// otvori roba tabelu
select ( 502 )
use ( use_path + "e_roba" ) alias "e_roba"
index on ( id ) tag "ID"

// otvori partn tabelu
select ( 503 )
use ( use_path + "e_partn" ) alias "e_partn"
index on ( id ) tag "ID"

// otvori konto tabelu
select ( 504 )
use ( use_path + "e_konto" ) alias "e_konto"
index on ( id ) tag "ID"

return




// ----------------------------------------------------
// vraca listu fajlova koji se koriste kod prenosa
// ----------------------------------------------------
static function _file_list( use_path )
local _a_files := {} 

AADD( _a_files, use_path + "e_kalk.dbf" )
AADD( _a_files, use_path + "e_doks.dbf" )
AADD( _a_files, use_path + "e_roba.dbf" )
AADD( _a_files, use_path + "e_partn.dbf" )
AADD( _a_files, use_path + "e_konto.dbf" )

return _a_files


// ------------------------------------------
// kompresuj fajlove i vrati path 
// ------------------------------------------
static function _compress( vars )
local _path
local _files
local _export_path := ALLTRIM( vars["export_path"] )
local _zip_path := ALLTRIM( vars["zip_file_name"] )
local _error

// lista fajlova za kompresovanje
_files := _file_list()

// unzipuj fajlove
_error := zip_files( _zip_path, _files )

return _export_path



// ------------------------------------------
// dekompresuj fajlove i vrati path 
// ------------------------------------------
static function _decompress( vars )
local _path
local _files
local _export_path := ALLTRIM( vars["export_path"] )
local _zip_path := ALLTRIM( vars["zip_file_name"] )
local _error

// unzipuj fajlove
_error := unzip_files( _zip_path, _export_path )

return _export_path



