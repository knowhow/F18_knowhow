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

static __import_dbf_path 
static __export_dbf_path
static __import_zip_name
static __export_zip_name


function kalk_udaljena_razmjena_podataka()
local _opc := {}
local _opcexe := {}
local _izbor := 1

__import_dbf_path := my_home() + "import_dbf" + SLASH
__export_dbf_path := my_home() + "export_dbf" + SLASH
__import_zip_name := "kalk_imp.zip"
__export_zip_name := "kalk_exp.zip"

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
local _exported_rec
local _error

// uslovi exporta
if !_vars_export( @_vars )
    return
endif

// pobrisi u folderu tmp fajlove ako postoje
delete_exp_files( __export_dbf_path )
delete_zip_files( __export_dbf_path + __export_zip_name )

// exportuj podatake
_exported_rec := __export( _vars )

// zatvori sve tabele prije operacije pakovanja
close all

// arhiviraj podatke
if _exported_rec > 0 
    
    // kompresuj ih u zip fajl za prenos
    _error := _compress_files()

    // sve u redu
    if _error == 0
        
        // pobrisi fajlove razmjene
        delete_exp_files( __export_dbf_path )

        // otvori folder sa exportovanim podacima
        open_folder( __export_dbf_path )

    endif

endif

// vrati se na glavni direktorij
DirChange( my_home() )

if ( _exported_rec > 0 )
    MsgBeep( "Exportovao " + ALLTRIM(STR( _exported_rec )) + " dokumenta." )
endif

close all
return



// ----------------------------------------
// import podataka modula KALK
// ----------------------------------------
static function _kalk_import()
local _imported_rec
local _vars := hb_hash()

// parametri
if !_vars_import( @_vars )
    return
endif

// dekompresovanje podataka
_decompress_files( _vars )

// import procedura
_imported_rec := __import( _vars )

// vrati se na home direktorij nakon svega
DirChange( my_home() )

if ( _imported_rec > 0 )
    MsgBeep( "Importovao " + ALLTRIM( STR( _imported_rec ) ) + " dokumenta." )
endif

return



// -------------------------------------------
// uslovi exporta dokumenta
// -------------------------------------------
static function _vars_export( vars )
local _ret := .f.
local _dat_od := fetch_metric( "kalk_export_datum_od", my_user(), DATE() - 30 )
local _dat_do := fetch_metric( "kalk_export_datum_do", my_user(), DATE() )
local _konta := fetch_metric( "kalk_export_lista_konta", my_user(), PADR( "1320;", 200 ) )
local _vrste_dok := fetch_metric( "kalk_export_vrste_dokumenata", my_user(), PADR( "10;11;", 200 ) )
local _x := 1

Box(, 8, 70 )

    @ m_x + _x, m_y + 2 SAY "*** Uslovi exporta dokumenata"

    ++ _x
    ++ _x
        
    @ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET _vrste_dok PICT "@S40"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
    @ m_x + _x, col() + 1 SAY "do" GET _dat_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedeca konta:" GET _konta PICT "@S30"

    read

BoxC()

// snimi parametre
if LastKey() <> K_ESC

    _ret := .t.

    set_metric( "kalk_export_datum_od", my_user(), _dat_od )
    set_metric( "kalk_export_datum_do", my_user(), _dat_do )
    set_metric( "kalk_export_lista_konta", my_user(), _konta )
    set_metric( "kalk_export_vrste_dokumenata", my_user(), _vrste_dok )

    vars["datum_od"] := _dat_od
    vars["datum_do"] := _dat_do
    vars["konta"] := _konta
    vars["vrste_dok"] := _vrste_dok
    
endif

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
local _ret := 0
local _id_firma, _id_vd, _br_dok
local _app_rec
local _cnt := 0
local _dat_od, _dat_do, _konta, _vrste_dok
local _usl_mkonto, _usl_pkonto

// uslovi za export ce biti...
_dat_od := vars["datum_od"]
_dat_do := vars["datum_do"]
_konta := ALLTRIM( vars["konta"] )
_vrste_dok := ALLTRIM( vars["vrste_dok"] )
 
// kreiraj tabele exporta
_cre_exp_tbls( __export_dbf_path )

// otvori export tabele za pisanje podataka
_o_exp_tables( __export_dbf_path )

// otvori lokalne tabele za prenos
_o_tables()

Box(, 2, 65 )

@ m_x + 1, m_y + 2 SAY "... export kalk dokumenata u toku"

select kalk_doks
go top

do while !EOF()

    _id_firma := field->idfirma
    _id_vd := field->idvd
    _br_dok := field->brdok

    // provjeri uslove

    // lista konta...
    if !EMPTY( _konta )

        _usl_mkonto := Parsiraj( ALLTRIM(_konta), "mkonto" )
        _usl_pkonto := Parsiraj( ALLTRIM(_konta), "pkonto" )

        if !( &_usl_mkonto )
            if !( &_usl_pkonto )
                skip
                loop
            endif
        endif

    endif

    // lista dokumenata...
    if !EMPTY( _vrste_dok )
        if !( field->idvd $ _vrste_dok )
            skip
            loop
        endif
    endif

    // datumski uslov...
    if ( field->datdok < _dat_od ) .or. ( field->datdok > _dat_do )
        skip
        loop
    endif

    // ako je sve zadovoljeno !
    // dodaj zapis u tabelu e_doks
    _app_rec := dbf_get_rec()
    select e_doks
    append blank
    dbf_update_rec( _app_rec )    

    ++ _cnt
    @ m_x + 2, m_y + 2 SAY PADR(  PADL( ALLTRIM(STR( _cnt )), 6 ) + ". " + "dokument: " + _id_firma + "-" + _id_vd + "-" + ALLTRIM( _br_dok ), 50 )

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

    select kalk_doks
    skip

enddo

BoxC()

if ( _cnt > 0 )
    _ret := _cnt
endif

return _ret



// ----------------------------------------
// import podataka
// ----------------------------------------
static function __import( vars )
local _ret := 0
local _id_firma, _id_vd, _br_dok
local _app_rec
local _cnt := 0

// otvaranje export tabela
_o_exp_tables( __import_dbf_path )

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

    select kalk_doks
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

if _cnt > 0
    _ret := _cnt
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


// ---------------------------------------------
// kreiraj direktorij ako ne postoji
// ---------------------------------------------
static function _dir_create( use_path )
local _ret := .t.

//_lokacija := _path_quote( my_home() + "export" + SLASH )

if DirChange( use_path ) != 0
    _cre := MakeDir ( use_path )
    if _cre != 0
        MsgBeep("kreiranje " + use_path + " neuspjesno ?!")
        log_write("dircreate err:" + use_path )
        _ret := .f.
    endif
endif

return _ret



// ----------------------------------------
// kreiranje tabela razmjene
// ----------------------------------------
static function _cre_exp_tbls( use_path )
local _cre 

if use_path == NIL
    use_path := my_home()
endif

// provjeri da li postoji direktorij, pa ako ne - kreiraj
_dir_create( use_path )

// tabela kalk
O_KALK
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_kalk") from ( my_home() + "struct")

// tabela doks
O_KALK_DOKS
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_doks") from ( my_home() + "struct")

// tabela roba
O_ROBA
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_roba") from ( my_home() + "struct")

// tabela partn
O_PARTN
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_partn") from ( my_home() + "struct")

// tabela partn
O_PARTN
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_partn") from ( my_home() + "struct")

// tabela konta
O_KONTO
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_konto") from ( my_home() + "struct")


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

// zatvori sve prije otvaranja ovih tabela
close all

// otvori kalk tabelu
select ( 360 )
use ( use_path + "e_kalk" ) alias "e_kalk"
index on ( idfirma + idvd + brdok ) tag "1"

// otvori doks tabelu
select ( 361 )
use ( use_path + "e_doks" ) alias "e_doks"
index on ( idfirma + idvd + brdok ) tag "1"

// otvori roba tabelu
select ( 362 )
use ( use_path + "e_roba" ) alias "e_roba"
index on ( id ) tag "ID"

// otvori partn tabelu
select ( 363 )
use ( use_path + "e_partn" ) alias "e_partn"
index on ( id ) tag "ID"

// otvori konto tabelu
select ( 364 )
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



// -------------------------------------------------
// brise zip fajl exporta
// -------------------------------------------------
static function delete_zip_files( zip_file )
if FILE( zip_file )
    FERASE( zip_file )
endif 
return



// ---------------------------------------------------
// brise temp fajlove razmjene
// ---------------------------------------------------
static function delete_exp_files( use_path )
local _files := _file_list( use_path )
local _file, _tmp

MsgO( "Brisem tmp fajlove ..." )
for each _file in _files
    if FILE( _file )
        // pobrisi dbf fajl
        FERASE( _file )
        // cdx takodjer ?
        _tmp := STRTRAN( _file, ".dbf", ".cdx" )
        FERASE( _tmp )
    endif
next
MsgC()

return


// ------------------------------------------
// kompresuj fajlove i vrati path 
// ------------------------------------------
static function _compress_files()
local _files
local _error
local _zip_path, _zip_name

// lista fajlova za kompresovanje
_files := _file_list( __export_dbf_path )

_zip_path := __export_dbf_path
_zip_name := __export_zip_name

// unzipuj fajlove
_error := zip_files( _zip_path, _zip_name, _files )

return _error



// ------------------------------------------
// dekompresuj fajlove i vrati path 
// ------------------------------------------
static function _decompress_files()
local _zip_name, _zip_path
local _error

_zip_path := __import_dbf_path
_zip_name := __import_zip_name

// unzipuj fajlove
_error := unzip_files( _zip_path, _zip_name, __import_dbf_path )

return _error



