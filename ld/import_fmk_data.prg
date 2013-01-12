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


#include "ld.ch"


// ----------------------------------------------
// import podataka iz FMK
// ----------------------------------------------
function import_data_from_fmk()
local _count
local _params
local _ok

if !get_vars( @_params )
    return 
endif

// kreira se pomocna tabela za sifre radnika
_create_tmp_tbl()

// importuj mi prvo radnike
if __import_radn( _params )
    // provjeri zapise ... 
    _ok := __check_import_radn( _params )

    // sta ako je ovo ok ?????? a sta ako nije....

endif

// importuju se podaci....
_ok := __import_data( _params )

return



// -----------------------------------------------
// parametri opcije...
// -----------------------------------------------
static function get_vars( params )
local _ok := .f.
local _x := 1
local _fmk_rj := SPACE(2)
local _f18_rj := SPACE(2)
local _kum_path := PADR( fetch_metric( "ld_import_fmk_kum_path", NIL, "c:\sigma\ld\kum1\" ), 300 )
local _sif_path := PADR( fetch_metric( "ld_import_fmk_sif_path", NIL, "c:\sigma\sif1\" ), 300 )
local _dat_od := CTOD("")
local _dat_do := DATE()
local _prefix := SPACE(3)

Box(, 15, 70 )

    @ m_x + _x, m_y + 2 SAY "Import podataka iz FMK:" COLOR "I"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Radna jedinica u FMK:" GET _fmk_rj
    @ m_x + _x, col() + 1 SAY "-> F18:" GET _f18_rj VALID !EMPTY( _f18_rj )
    
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Za period od:" GET _dat_od
    @ m_x + _x, col() + 1 SAY "do:" GET _dat_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Prefiks za sifru partnera:" GET _prefix
    
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Kumulativ LD:" GET _kum_path PICT "@S50"
    @ m_x + _x, m_y + 2 SAY "Sifrarnik LD:" GET _sif_path PICT "@S50"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// snimi sql parametre
set_metric( "ld_import_fmk_kum_path", NIL, ALLTRIM( _kum_path ) )
set_metric( "ld_import_fmk_sif_path", NIL, ALLTRIM( _sif_path ) )

// snimi mi hash matricu
_ok := .t.
params := hb_hash()
params["rj_fmk"] := _fmk_rj
params["rj_f18"] := _f18_rj
params["radn_prefix"] := _prefix
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["kum_path"] := ALLTRIM( _kum_path )
params["sif_path"] := ALLTRIM( _sif_path )

return _ok



// ----------------------------------------------
// kreira se pomocna tabela za radnika
// ----------------------------------------------
static function _create_tmp_tbl()
local _dbf := {}
local _tbl_name := "ld_radn_tmp.dbf"

AADD( _dbf, { "ID", "C", 6, 0 } )
AADD( _dbf, { "ID2", "C", 6, 0 } )
AADD( _dbf, { "JMBG", "C", 13, 0 } )

if !FILE( my_home() + _tbl_name )
    dbcreate( my_home() + _tbl_name, _dbf )
endif

_use_tmp_table()

// indeksi...
index on ( "id" ) tag "1"
index on ( "id2" ) tag "2"
index on ( "jmbg" ) tag "3"

return



// -----------------------------------------------
// use 
// -----------------------------------------------
static function _use_tmp_table()

select ( F_TMP_1 )
use
my_use_temp( "LD_RADN_TMP", my_home() + "ld_radn_tmp.dbf", .f., .t. )
set order to tag "1"

return



// -----------------------------------------------
// import podataka u tekucu bazu LD-a
// -----------------------------------------------
static function __import_data( params )
local _ok

// importuj zapise ld tabele
_ok := __import_ld_data( params )

// importuj zapise ld kredita
_ok := __import_kred_data( params ) 

return _ok


// ----------------------------------------------------
// chekiranje zapisa tabele radnika nakon importa...
// ----------------------------------------------------
static function __check_import_radn( params )
local _a_tmp := {}
local _mat_br
local _ok := .t.

_use_tmp_table()
set order to tag "3"
go top

// provjera po maticnim brojevima...
// ima li duplih
do while !EOF()

    skip 1
    _mat_br := field->jmbg
    skip -1
    
    if field->jmbg == _mat_br
        AADD( _a_tmp, { field->id, field->id2, field->jmbg } )
    endif

    skip

enddo

// zatvori tmp table
select ( F_TMP_1 )
use

if LEN( _a_tmp ) > 0

    _ok := .f.

    // imamo gresaka...
    START PRINT CRET

    ? 
    ? "Radnici sa identicnim maticnim brojem:"
    ? "--------------------------------------------------------------"
    ? "FMK    F18    JMBG"
    ? "------ ------ -------------"

    for _i := 1 to LEN( _a_tmp )
        ? _a_tmp[ _i, 1 ], _a_tmp[ _i, 2 ], _a_tmp[ _i, 3 ]
    next

    FF
    END PRINT

endif

return _ok



// ----------------------------------------------------
// import radnika
// ----------------------------------------------------
static function __import_radn( params )
local _ok := .f.
local _kumpath := params["kum_path"]
local _prefix := ALLTRIM( params["radn_prefix"] )
local _count := 0
local _fmk_count
local _f18_count
local _fmk_id_radn, _fmk_jmbg, _rec

if !FILE( _kumpath + "RADN.DBF" )
    MsgBeep( "Na lokaciji " + _kumpath + " nema tabele RADN.DBF !!!" )
    return _ok
endif

// ovo su radnici iz F18
select ( F_RADN )
if !Used()
    O_RADN
endif

// zakaci mi se na radnike iz FMK
// to ce biti alias FMK_RADN
select ( F_TMP_2 )
use
my_use_temp( "FMK_RADN", _kumpath + "RADN.DBF", .f., .t. )

// broj zapisa u sifrarniku radnika
_fmk_count := RECCOUN()

// otvori pomocnu tabelu za upis radnika...
_use_tmp_table()
set order to tag "1"


// ideja je sljedeca... 
// napuni mi sifrarnik F18 sa radnicima ali pri tome dodjeljivaj nove sifre
// puni pomocnu tabelu sa parovima stara sifra <> nova sifra 
// kod punjenja pregledaj ima li u pomocnoj tabeli, ako nema dodaj

select fmk_radn
set order to tag "ID"
go top

_ok := .t.

Box(, 2, 66 )

@ m_x + 1, m_y + 2 SAY "import radnika u toku..."

// glavna petlja...
do while !EOF()

    // id radnika u FMK
    _fmk_id_radn := field->id
    // maticni broj radnika u FMK
    _fmk_jmbg := field->matbr

    // uslovi za preskakanje...
    if EMPTY( _fmk_id_radn )
        skip
        loop
    endif

    // sve je ok, idemo dalje...

    // vidimo ima li radnika u tmp tabeli...
    select ld_radn_tmp
    go top
    seek _fmk_id_radn

    if !FOUND()

        // treba da ga dodamo i dodjelimo mu novu sifru...
        APPEND BLANK
        _rec := dbf_get_rec()
        _rec["id"] := _fmk_id_radn
        _rec["jmbg"] := _fmk_jmbg

        // daj mi novu sifru radnika
        _nova_f18_sifra := nova_sifra_radnika( _prefix )

        _rec["id2"] := _nova_f18_sifra

        // ubaci zapis u pomocnu tabelu
        dbf_update_rec( _rec )

        // sada dodajemo tu sifru u radnike...
        // ali novu

        select radn
        go top
        seek _nova_f18_sifra

        if !FOUND()
        
            ++ _count

            select fmk_radn
            _rec2 := dbf_get_rec()
            _rec2["id"] := _nova_f18_sifra
        
            // bit ce sigurno nekih zapisa za izbaciti i slicno ?!???? sa hb_hdel()
            @ m_x + 2, m_y + 2 SAY "import zapisa: " + ALLTRIM( STR( _count ) ) + "/" + ALLTRIM( STR( _fmk_count ) )

            select radn
            APPEND BLANK
            update_rec_server_and_dbf( "radn", _rec2, 1, "FULL" )

        endif

    endif

    select fmk_radn
    skip

enddo

BoxC()

// zatvori pomocnu tabelu radnika
select ( F_TMP_1 )
use

// zatvori tmp tabelu
select ( F_TMP_2 )
use

// zatvori radnike
select radn
_f18_count := RECCOUNT()
use

if _f18_count <> _fmk_count
    MsgBeep( "FMK radnici: " + ALLTRIM(STR( _fmk_count )) + ", F18 radnici: " + ALLTRIM( STR( _f18_count) ) )
else
    MsgBeep( "Importovao " + ALLTRIM(STR( _f18_count )) )
endif

return _ok


// -----------------------------------------------------------------------
// odredjuje novu sifru radnika
// -----------------------------------------------------------------------
static function nova_sifra_radnika( prefix )
local _last_num := fetch_metric( "ld_import_fmk_zadnja_sifra", NIL, 0 )
local _sifra := ""
local _tmp := _last_num + 1

if prefix == NIL
    prefix := ""
endif

// sifra ce da bude "00001", "000002", "000003" itd...
// imamo i mogucnost prefiksa, recimo "F" pa ce biti "F0001", "F0002" itd...

_sifra := prefix + PADL( ALLTRIM( STR( _tmp ) ), 6 - LEN( prefix ), "0" )

// snimi parametar za dalje...
set_metric( "ld_import_fmk_zadnja_sifra", NIL, _tmp )

return _sifra





// ----------------------------------------------------
// import podataka obracuna
// ----------------------------------------------------
static function __import_ld_data( params )
local _ok := .f.
local _kumpath := params["kum_path"]
local _fmk_rj := params["rj_fmk"]
local _f18_rj := params["rj_f18"]
local _dat_od := params["datum_od"]
local _dat_do := params["datum_do"]
local _rec, _rec2, _fmk_id_radn, _f18_id_radn
local _count := 0
local _fmk_count

// koristi temp tabelu radnika...
// alias: LD_RADN_TMP
_use_tmp_table()
set order to tag "1"

// zakaci mi se na obracun iz FMK
// alias: FMK_LD
select ( F_TMP_2 )
use
my_use_temp( "FMK_LD", _kumpath + "LD.DBF", .f., .t. )
// napravi mi indeks za ovu potrebu...
index on ( idrj + idradn + STR( godina ) + STR( mjesec ) ) TAG "IMP" TO ( _kumpath + "ld_imp_tag")
_fmk_count := RECCOUNT()


// zakaci mi se na LD F18
// alias: LD
select ( F_LD )
if !Used()
    O_LD
endif

// idemo sada na prebacivanje podataka
select fmk_ld
set order to tag "IMP"
go top

seek _fmk_rj 

if !f18_lock_tables( { "ld_ld" }, .f. )
    MsgBeep( "Ne mogu napraviti lock tabele ld_ld !!!!" )
    return _ok
endif
sql_table_update( nil, "BEGIN" )


Box(, 2, 66 )

@ m_x + 1, m_y + 2 SAY "Import podataka za radnu jedinicu: " + _fmk_rj + " u toku..." 

// glavna petlja...
do while !EOF() .and. field->idrj == _fmk_rj

    // fmk radnik
    _fmk_id_radn := field->idradn

    // pronadji ga u temp tabeli - novu sifru
    select ld_radn_tmp
    go top
    seek _fmk_id_radn 

    if !FOUND()
        MsgBeep( "Nemoguce !!! radnika nema u pomocnoj tabeli !!!!" )
        return _ok 
    endif

    // ovo mu je prava sifra...
    _f18_id_radn := field->id2

    select fmk_ld

    // sada prodji i ubaci zapise po radniku...
    do while !EOF() .and. field->idrj == _fmk_rj .and. field->idradn == _fmk_id_radn

        // uzmi zapis....
        _rec := dbf_get_rec()

        // ubacimo ga u f18 LD, ali pod novom radnom jedinicom
        _rec["idradn"] := _f18_id_radn
        _rec["idrj"] := _f18_rj
        select ld
        APPEND BLANK
        update_rec_server_and_dbf( "ld_ld", _rec, 1, "CONT" )
    
        ++ _count

        @ m_x + 2, m_y + 2 SAY "import zapisa: " + ALLTRIM( STR( _count ) ) + "/" + ALLTRIM( STR( _fmk_count ) )

        // idemo dalje...
        select fmk_ld
        skip

    enddo

enddo

BoxC()

f18_free_tables( { "ld_ld" } )
sql_table_update( nil, "END" )

// zatvori sve tabele
select ( F_TMP_2 )
use
select ( F_TMP_1 )
use
select ( F_LD )
use

// prenos ok
_ok := .t.

// imamo counter koji mozemo iskoristiti za nesto
// _count

return _ok






// ----------------------------------------------------
// import podataka kredita
// ----------------------------------------------------
static function __import_kred_data( params )
local _ok := .f.
local _kumpath := params["kum_path"]
local _fmk_rj := params["rj_fmk"]
local _f18_rj := params["rj_f18"]
local _dat_od := params["datum_od"]
local _dat_do := params["datum_do"]
local _rec, _rec2, _fmk_id_radn, _f18_id_radn
local _count := 0
local _fmk_count

// koristi temp tabelu radnika...
// alias: LD_RADN_TMP
_use_tmp_table()
set order to tag "1"

// zakaci mi se na obracun iz FMK
// alias: FMK_KRED
select ( F_TMP_2 )
use
my_use_temp( "FMK_KRED", _kumpath + "LDKRED.DBF", .f., .t. )
// napravi mi indeks za ovu potrebu...
index on ( idrj + idradn + STR( godina ) + STR( mjesec ) ) TAG "IMP" TO ( _kumpath + "kred_imp_tag")
_fmk_count := RECCOUNT()

// zakaci mi se na LDKRED F18
// alias: RADKR
select ( F_RADKR )
if !Used()
    O_RADKR
endif

// zapocni mi transakciju...
if !f18_lock_tables( { "ld_radkr" }, .f. )
    MsgBeep( "Ne mogu lokovati tabelu ld_radkr !!!" ) 
    return _ok
endif
sql_table_update( nil, "BEGIN" ) 


// idemo sada na prebacivanje podataka
select fmk_kred
set order to tag "IMP"
go top

seek _fmk_rj 

Box(, 2, 66 )

@ m_x + 1, m_y + 2 SAY "Import podataka za radnu jedinicu: " + _fmk_rj + " u toku..." 

// glavna petlja...
do while !EOF() .and. field->idrj == _fmk_rj

    // fmk radnik
    _fmk_id_radn := field->idradn

    // pronadji ga u temp tabeli - novu sifru
    select ld_radn_tmp
    go top
    seek _fmk_id_radn 

    if !FOUND()
        MsgBeep( "Nemoguce !!! radnika nema u pomocnoj tabeli !!!!" )
        return _ok 
    endif

    // ovo mu je prava sifra...
    _f18_id_radn := field->id2

    select fmk_kred

    do while !EOF() .and. field->idrj == _fmk_rj .and. field->idradn == _fmk_id_radn

        _rec := dbf_get_rec()
        // ubacimo ga u f18 LD, ali pod novom radnom jedinicom
        _rec["idradn"] := _f18_id_radn
        _rec["idrj"] := _f18_rj
        select radkr
        APPEND BLANK
        update_rec_server_and_dbf( "ld_radkr", _rec, 1, "CONT" )
    
        ++ _count

        @ m_x + 2, m_y + 2 SAY "import zapisa: " + ALLTRIM( STR( _count ) ) + "/" + ALLTRIM( STR( _fmk_count ) )

        // idemo dalje...
        select fmk_kred
        skip

    enddo

enddo

BoxC()

f18_free_tables( { "ld_radkr" } )
sql_table_update( nil, "END" ) 

// zatvori sve tabele
select ( F_TMP_2 )
use
select ( F_TMP_1 )
use
select ( F_RADKR )
use

// prenos ok
_ok := .t.

// imamo counter koji mozemo iskoristiti za nesto
// _count

return _ok





// -----------------------------------------------------
// import osnovnih podataka
// porezi, doprinosi, opcine 
// tipovi primanja itd...
// -----------------------------------------------------
static function __import_general_data( params )
local _ok := .f.



return _ok


