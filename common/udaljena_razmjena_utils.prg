/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"




// --------------------------------------------
// promjena privilegija fajlova
// --------------------------------------------
function set_file_access( file_path, mask )
local _cmd 
local _ret := .f.

if file_path == NIL
	file_path := ""
endif

if mask == NIL
	mask := ""
endif

_cmd := "chmod ugo+w " + file_path + mask + "*.*"

_ret := f18_run( _cmd )
    
if _ret <> 0
    MsgBeep( "Problem sa setovanjem privilegija !" )
endif

return _ret


// -----------------------------------------
// otvara listu fajlova za import
// vraca naziv fajla za import
// -----------------------------------------
function get_import_file( modul, import_dbf_path )
local _file
local _filter

if modul == NIL
    modul := "kalk"
endif

_filter := ALLTRIM( modul ) + "*.*"

if _gFList( _filter, import_dbf_path, @_file ) == 0
    _file := ""
endif

return _file


// ----------------------------------------------------------------
// update tabele konto na osnovu pomocne tabele
// ----------------------------------------------------------------
function update_table_konto( zamjena_sifre, fmk_import )
local _app_rec
local _sif_exist := .t.

if fmk_import == NIL
    fmk_import := .f.
endif

f18_lock_tables( { "konto" } )
sql_table_update( nil, "BEGIN" )

select e_konto
set order to tag "ID"
go top

do while !EOF()

    _app_rec := dbf_get_rec()    

    if fmk_import
        // uskladi strukture
        update_rec_konto_struct( @_app_rec )
    endif

    select konto
    hseek _app_rec["id"]

    _sif_exist := .t.
    if !FOUND()
        _sif_exist := .f.
    endif

    if !_sif_exist .or. ( _sif_exist .and. zamjena_sifre == "D" )

        @ m_x + 3, m_y + 2 SAY "import partn id: " + _app_rec["id"] + " : " + PADR( _app_rec["naz"], 20 )

        select konto

        if !_sif_exist
            append blank
        endif

        update_rec_server_and_dbf( "konto", _app_rec, 1, "CONT" )

    endif

    select e_konto
    skip

enddo

sql_table_update( nil, "END" )
f18_free_tables( { "konto" } )

return



// -----------------------------------------------------------
// update tabele partnera na osnovu pomocne tabele
// -----------------------------------------------------------
function update_table_partn( zamjena_sifre, fmk_import )
local _app_rec
local _sif_exist := .t.

if fmk_import == NIL
    fmk_import := .f.
endif

f18_lock_tables( { "partn" } )
sql_table_update( nil, "BEGIN" )

select e_partn
set order to tag "ID"
go top

do while !EOF()
    
    _app_rec := dbf_get_rec()

    if fmk_import
        // uskladi strukture
        update_rec_partn_struct( @_app_rec )
    endif

    select partn
    hseek _app_rec["id"]

    _sif_exist := .t.        
    if !FOUND()
        _sif_exist := .f.
    endif

    if !_sif_exist .or. ( _sif_exist .and. zamjena_sifre == "D" )

        @ m_x + 3, m_y + 2 SAY "import partn id: " + _app_rec["id"] + " : " + PADR( _app_rec["naz"], 20 )

        select partn

        if !_sif_exist
            append blank
        endif

        update_rec_server_and_dbf( "partn", _app_rec, 1, "CONT" )
    endif

    select e_partn
    skip

enddo

sql_table_update( nil, "END" )
f18_free_tables( { "partn" } )

return



// update podataka u tabelu robe
function update_table_roba( zamjena_sifre, fmk_import )
local _app_rec 
local _sif_exist := .t.

if fmk_import == NIL
    fmk_import := .f.
endif

f18_lock_tables( { "roba" } )
sql_table_update( nil, "BEGIN" )

// moramo ziknuti i robu ako fali !
select e_roba
set order to tag "ID"
go top

do while !EOF()
   
    _app_rec := dbf_get_rec()

    if fmk_import
        // uskladi strukture tabela
        update_rec_roba_struct( @_app_rec )
    endif

    select roba
    hseek _app_rec["id"]

    _sif_exist := .t.
    if !FOUND()
        _sif_exist := .f.
    endif

    if !_sif_exist .or. ( _sif_exist .and. zamjena_sifre == "D" )

        @ m_x + 3, m_y + 2 SAY "import roba id: " + _app_rec["id"] + " : " + PADR( _app_rec["naz"], 20 )

        select roba

        if !_sif_exist
            append blank
        endif
        
        update_rec_server_and_dbf( "roba", _app_rec, 1, "CONT" )

    endif

    select e_roba
    skip

enddo

sql_table_update( nil, "END" )
f18_free_tables( { "roba" } )

return

// --------------------------------------------------
// update strukture zapisa tabele sifk
// --------------------------------------------------
static function update_rec_sifk_struct( rec )
local _no_field
local _struct := {}

rec["f_unique"] := rec["unique"]
rec["f_decimal"] := rec["decimal"]

// pobrisi sljedece clanove...
hb_hdel( rec, "unique" ) 
hb_hdel( rec, "decimal" ) 

return



// --------------------------------------------------
// update strukture zapisa tabele konto
// --------------------------------------------------
static function update_rec_konto_struct( rec )
local _no_field
local _struct := {}

// moguca nepostojeca polja tabele roba

AADD( _struct, "match_code" )
AADD( _struct, "pozbilu" )
AADD( _struct, "pozbils" )

for each _no_field in _struct
    if ! HB_HHASKEY( rec, _no_field )
        rec[ _no_field ] := nil
    endif
next

return



// --------------------------------------------------
// update strukture zapisa tabele partn
// --------------------------------------------------
static function update_rec_partn_struct( rec )
local _no_field
local _struct := {}

// moguca nepostojeca polja tabele roba
AADD( _struct, "match_code" )

for each _no_field in _struct
    if ! HB_HHASKEY( rec, _no_field )
        rec[ _no_field ] := nil
    endif
next

// pobrisi sljedece clanove...
hb_hdel( rec, "brisano" ) 
hb_hdel( rec, "rejon" ) 

return



// --------------------------------------------------
// update strukture zapisa tabele roba
// --------------------------------------------------
static function update_rec_roba_struct( rec )
local _no_field
local _struct := {}

// moguca nepostojeca polja tabele roba
AADD( _struct, "idkonto" )
AADD( _struct, "sifradob" )
AADD( _struct, "strings" )
AADD( _struct, "k7" )
AADD( _struct, "k8" )
AADD( _struct, "k9" )
AADD( _struct, "mink" )
AADD( _struct, "fisc_plu" )
AADD( _struct, "match_code" )
AADD( _struct, "mpc4" )
AADD( _struct, "mpc5" )
AADD( _struct, "mpc6" )
AADD( _struct, "mpc7" )
AADD( _struct, "mpc8" )
AADD( _struct, "mpc9" )

for each _no_field in _struct
    if ! HB_HHASKEY( rec, _no_field )
        rec[ _no_field ] := nil
    endif
next

// pobrisi sljedece clanove...
hb_hdel( rec, "carina" ) 
hb_hdel( rec, "_m1_" ) 
hb_hdel( rec, "brisano" ) 

return



// ---------------------------------------------------------
// update tabela sifk, sifv na osnovu pomocnih tabela
// ---------------------------------------------------------
function update_sifk_sifv( fmk_import )
local _app_rec

if fmk_import == NIL
    fmk_import := .f.
endif

// sifk, sifv tabele
select e_sifk
set order to tag "ID2"
go top

// update sifk
do while !EOF()

    _app_rec := dbf_get_rec()
        
    if fmk_import
        // promijeni strukturu ako treba
        update_rec_sifk_struct( @_app_rec )
    endif

    select sifk
    set order to tag "ID2"
    go top
    seek _app_rec["id"] + _app_rec["oznaka"] 

    if !FOUND()
        append blank
    endif
        
    @ m_x + 3, m_y + 2 SAY "import sifk id: " + _app_rec["id"] + ", oznaka: " + _app_rec["oznaka"]
    
    // uvijek update odradi friskog stanja sifk tabele
    update_rec_server_and_dbf( "sifk", _app_rec, 1, "FULL" )
        
    select e_sifk
    skip

enddo

select e_sifv
set order to tag "ID"
go top

// update sifv
do while !EOF()

    _app_rec := dbf_get_rec()
    select sifv
    set order to tag "ID"
    go top
    seek _app_rec["id"] + _app_rec["oznaka"] + _app_rec["idsif"] + _app_rec["naz"] 

    if !FOUND()
        append blank
    endif

    @ m_x + 3, m_y + 2 SAY "import sifv id: " + _app_rec["id"] + ", oznaka: " + _app_rec["oznaka"] + ", sifra: " + _app_rec["idsif"]

    update_rec_server_and_dbf( "sifv", _app_rec, 1, "FULL" )

    select e_sifv
    skip

enddo

return


// ---------------------------------------------
// kreiraj direktorij ako ne postoji
// ---------------------------------------------
function _dir_create( use_path )
local _ret := .t.

//_lokacija := _path_quote( my_home() + "export" + SLASH )

if DirChange( use_path ) != 0
    _cre := MakeDir ( use_path )
    if _cre != 0
        MsgBeep("kreiranje " + use_path + " neuspjesno ?!")
        log_write("dircreate err:" + use_path, 7 )
        _ret := .f.
    endif
endif

return _ret


// -------------------------------------------------
// brise zip fajl exporta
// -------------------------------------------------
function delete_zip_files( zip_file )
if FILE( zip_file )
    FERASE( zip_file )
endif 
return



// ---------------------------------------------------
// brise temp fajlove razmjene
// ---------------------------------------------------
function delete_exp_files( use_path, modul )
local _files := _file_list( use_path, modul )
local _file, _tmp

MsgO( "Brisem tmp fajlove ..." )
for each _file in _files
    if FILE( _file )
        // pobrisi dbf fajl
        FERASE( _file )
        // cdx takodjer ?
        _tmp := ImeDbfCDX(_file)
        FERASE( _tmp )
        // fpt takodjer ?
        _tmp := STRTRAN( _file, ".dbf", ".fpt" )
        FERASE( _tmp )
    endif
next
MsgC()

return


// -------------------------------------------------------
// da li postoji import fajl ?
// -------------------------------------------------------
function import_file_exist( imp_file )
local _ret := .t.

if ( imp_file == NIL )
    imp_file := __import_dbf_path + __import_zip_name
endif

if !FILE( imp_file )
    _ret := .f.
endif

return _ret


// --------------------------------------------
// vraca naziv zip fajla
// --------------------------------------------
function zip_name( modul, export_dbf_path )
local _file 
local _ext := ".zip"
local _count := 1
local _exist := .t.

if modul == NIL
    modul := "kalk"
endif

if export_dbf_path == NIL
    export_dbf_path := my_home()
endif

modul := ALLTRIM( LOWER( modul ) )

_file := export_dbf_path + modul + "_exp_" + PADL( ALLTRIM(STR( _count )), 2, "0" ) + _ext 

if FILE( _file )
    
    // generisi nove nazive fajlova
    do while _exist 

        ++ _count
        _file := export_dbf_path + modul + "_exp_" + PADL( ALLTRIM(STR( _count )), 2, "0" ) + _ext 

        if !FILE( _file )
            _exist := .f.
            exit
        endif

    enddo

endif

return _file



// ----------------------------------------------------
// vraca listu fajlova koji se koriste kod prenosa
// ----------------------------------------------------
static function _file_list( use_path, modul )
local _a_files := {} 

if modul == NIL
    modul := "kalk"
endif

do case

    case modul == "kalk"
        
        AADD( _a_files, use_path + "e_kalk.dbf" )
        AADD( _a_files, use_path + "e_doks.dbf" )
        AADD( _a_files, use_path + "e_roba.dbf" )
        AADD( _a_files, use_path + "e_partn.dbf" )
        AADD( _a_files, use_path + "e_konto.dbf" )
        AADD( _a_files, use_path + "e_sifk.dbf" )
        AADD( _a_files, use_path + "e_sifv.dbf" )

    case modul == "fakt"

        AADD( _a_files, use_path + "e_fakt.dbf" )
        AADD( _a_files, use_path + "e_fakt.fpt" )
        AADD( _a_files, use_path + "e_doks.dbf" )
        AADD( _a_files, use_path + "e_doks2.dbf" )
        AADD( _a_files, use_path + "e_roba.dbf" )
        AADD( _a_files, use_path + "e_partn.dbf" )
        AADD( _a_files, use_path + "e_sifk.dbf" )
        AADD( _a_files, use_path + "e_sifv.dbf" )


    case modul == "fin"

        AADD( _a_files, use_path + "e_suban.dbf" )
        AADD( _a_files, use_path + "e_sint.dbf" )
        AADD( _a_files, use_path + "e_anal.dbf" )
        AADD( _a_files, use_path + "e_nalog.dbf" )
        AADD( _a_files, use_path + "e_partn.dbf" )
        AADD( _a_files, use_path + "e_konto.dbf" )
        AADD( _a_files, use_path + "e_sifk.dbf" )
        AADD( _a_files, use_path + "e_sifv.dbf" )

endcase

return _a_files



// ------------------------------------------
// kompresuj fajlove i vrati path 
// ------------------------------------------
function _compress_files( modul, export_dbf_path )
local _files
local _error
local _zip_path, _zip_name, _file
local __path, __name, __ext

// lista fajlova za kompresovanje
_files := _file_list( export_dbf_path, modul )

_file := zip_name( modul, export_dbf_path )

HB_FNameSplit( _file, @__path, @__name, @__ext ) 

_zip_path := __path
_zip_name := __name + __ext

// unzipuj fajlove
_error := zip_files( _zip_path, _zip_name, _files )

return _error



// ------------------------------------------
// dekompresuj fajlove i vrati path 
// ------------------------------------------
function _decompress_files( imp_file, import_dbf_path, import_zip_name )
local _zip_name, _zip_path
local _error
local __name, __path, __ext

if ( imp_file == NIL )

    _zip_path := import_dbf_path
    _zip_name := import_zip_name

else

    HB_FNameSplit( imp_file, @__path, @__name, @__ext ) 
    _zip_path := __path
    _zip_name := __name + __ext    

endif

log_write("dekompresujem fajl:" + _zip_path + _zip_name, 7 )

// unzipuj fajlove
_error := unzip_files( _zip_path, _zip_name, import_dbf_path )

return _error


// --------------------------------------------------
// popunjava sifrarnike sifk, sifv
// --------------------------------------------------
function _fill_sifk( sifrarnik, id_sif )
local _rec

PushWa()

select e_sifk

if reccount2() == 0  
    // karakteristike upisi samo jednom i to sve
    // za svaki slucaj !
    select sifk
    set order to tag "ID"
    go top

    do while !EOF()
        _rec := dbf_get_rec()
        select e_sifk
        append blank
        dbf_update_rec( _rec )
        select sifk
        skip
    enddo
endif 

// uzmi iz sifv sve one kod kojih je ID=ROBA, idsif=2MON0002
select sifv
set order to tag "IDIDSIF"
seek PADR( sifrarnik, 8 ) + id_sif

do while !EOF() .and. field->id = PADR( sifrarnik, 8 ) ;
    .and. field->idsif = PADR( id_sif, LEN( id_sif ) )

    _rec := dbf_get_rec()
    select e_sifv
    append blank
    dbf_update_rec( _rec )
    select sifv
    skip
enddo

PopWa()

return




