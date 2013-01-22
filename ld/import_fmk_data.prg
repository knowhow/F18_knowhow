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

if !SigmaSif( "IMPORT" )
    return
endif

if !get_vars( @_params )
    return 
endif

// reset sifre radnika u parametrima
if _params["radn_reset"] == "D"
    // ovo ce setovati globalni brojac na 0...
    // tako da import moze ici iz pocetka
    nova_sifra_radnika( "", .t. )
endif

// provjeri zapise sifrarnika RADN... 
_ok := __check_import_radn( _params )

if !_ok .and. Pitanje(, "Nastaviti dalje ?", "D") == "N"
    return
endif

// kreira se pomocna tabela za sifre radnika
_create_tmp_tbl()

// importuj mi prvo radnike
if !__import_radn( _params ) .and. Pitanje(, "Nastaviti dalje ?", "N" ) == "N"
    // sta ako je ovo ok ?????? a sta ako nije....
    return
endif

// importuju se podaci....
__import_data( _params )

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
local _tip_pr := PADR( fetch_metric( "ld_import_tippr_matrix", NIL, "" ), 500 )
local _dat_od := fetch_metric( "ld_import_datum_od", NIL, CTOD("") )
local _dat_do := fetch_metric( "ld_import_datum_do", NIL, DATE() )
local _prefix := fetch_metric( "ld_import_radn_prefix", NIL, SPACE(3) )
local _imp_kred := "N"
local _imp_obr := "N"
local _sif_reset := "N"

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
    @ m_x + _x, m_y + 2 SAY "Tip pr:" GET _tip_pr PICT "@S50"

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Import obracuna (D/N):" GET _imp_obr PICT "@!" VALID _imp_obr $ "DN"
    @ m_x + _x, col() + 1 SAY "Import kredita (D/N):" GET _imp_kred PICT "@!" VALID _imp_kred $ "DN"
   
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Reset sifre radnika (D/N):" GET _sif_reset PICT "@!" VALID _sif_reset $ "DN"
    
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Kumulativ LD:" GET _kum_path PICT "@S50"
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Sifrarnik LD:" GET _sif_path PICT "@S50"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// snimi sql parametre
set_metric( "ld_import_fmk_kum_path", NIL, ALLTRIM( _kum_path ) )
set_metric( "ld_import_fmk_sif_path", NIL, ALLTRIM( _sif_path ) )
set_metric( "ld_import_tippr_matrix", NIL, ALLTRIM( _tip_pr ) )
set_metric( "ld_import_datum_od", NIL, _dat_od )
set_metric( "ld_import_datum_do", NIL, _dat_do )
set_metric( "ld_import_radn_prefix", NIL, _prefix )

// snimi mi hash matricu
_ok := .t.
params := hb_hash()
params["rj_fmk"] := _fmk_rj
params["rj_f18"] := _f18_rj
params["radn_prefix"] := _prefix
params["tip_pr"] := _tip_pr
params["radn_reset"] := _sif_reset
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["import_kredit"] := _imp_kred
params["import_obracun"] := _imp_obr
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
index on ( id ) tag "1"
index on ( id2 ) tag "2"
index on ( jmbg ) tag "3"

return





// -----------------------------------------------
// use 
// -----------------------------------------------
static function _use_tmp_table()

select ( F_TMP_1 )
use
my_use_temp( "LD_RADN_TMP", my_home() + "ld_radn_tmp.dbf", .f., .t. )
set order to tag "3"

return





// -----------------------------------------------
// import podataka u tekucu bazu LD-a
// -----------------------------------------------
static function __import_data( params )
local _ok := .f.

// import sifrarnika
__import_general_data( params )

if params["import_obracun"] == "D"
    // importuj zapise ld tabele
    _ok := __import_ld_data( params )
endif

if params["import_kredit"] == "D"
    // importuj zapise ld kredita
    _ok := __import_kred_data( params )
endif 

return _ok




// ----------------------------------------------------
// chekiranje zapisa tabele radnika nakon importa...
// ----------------------------------------------------
static function __check_import_radn( params )
local _a_tmp := {}
local _mat_br
local _ok := .t.
local _kumpath := params["kum_path"]
local _err := {}

// zakaci mi se na radnike iz FMK
// to ce biti alias FMK_RADN
select ( F_TMP_2 )
use
my_use_temp( "FMK_RADN", _kumpath + "RADN.DBF", .f., .t. )
set order to tag "ID"
go top

// provjera po maticnim brojevima...
// ima li duplih
do while !EOF()

    _mat_br := field->matbr
    
    if LEN( ALLTRIM( _mat_br ) ) < 13
        dodaj_u_err( @_err, field->id, "maticni broj kratak ili ga nema! " + field->matbr )
    endif

    skip

enddo

// zatvori tmp table
select ( F_TMP_2 )
use

if LEN( _err ) > 0
    _ok := .f.
endif

prikazi_err( _err )

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

select ( F_PK_RADN )
if !Used()
    O_PK_RADN
endif

select ( F_PK_DATA )
if !Used()
    O_PK_DATA
endif


// zakaci mi se na radnike iz FMK
// to ce biti alias FMK_RADN
select ( F_TMP_2 )
use
my_use_temp( "FMK_RADN", _kumpath + "RADN.DBF", .f., .t. )
set order to tag "1"

// broj zapisa u sifrarniku radnika
_fmk_count := RECCOUN()

// zakaci mi se na pk_radn iz FMK
// to ce biti alias FMK_PK
select ( F_TMP_4 )
use
my_use_temp( "FMK_PK", _kumpath + "PK_RADN.DBF", .f., .t. )
index on ( idradn ) TAG "1" TO ( _kumpath + "ld_pk_tag")
set order to tag "1"

// zakaci mi se na pk_data iz FMK
// to ce biti alias FMK_PKDATA
select ( F_TMP_5 )
use
my_use_temp( "FMK_PKDATA", _kumpath + "PK_DATA.DBF", .f., .t. )
index on ( idradn ) TAG "1" TO ( _kumpath + "ld_pkd_tag")
set order to tag "1"


// otvori pomocnu tabelu za upis radnika...
_use_tmp_table()
set order to tag "3"


// ideja je sljedeca... 
// napuni mi sifrarnik F18 sa radnicima ali pri tome dodjeljivaj nove sifre
// puni pomocnu tabelu sa parovima stara sifra <> nova sifra 
// kod punjenja pregledaj ima li u pomocnoj tabeli, ako nema dodaj

select fmk_radn
set order to tag "1"
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

    // ako nema maticnog broja - vozdra !!!
    if EMPTY( _fmk_jmbg )
        skip
        loop
    endif

    // uslovi za preskakanje...
    if EMPTY( _fmk_id_radn )
        skip
        loop
    endif

    // sve je ok, idemo dalje...

    // vidimo ima li radnika u tmp tabeli...
    // trazit cemo po JMBG
    select ld_radn_tmp
    set order to tag "3"
    go top
    seek _fmk_jmbg

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

            // polja koja fale
            _rec2["match_code"] := ""
            _rec2["s1"] := ""
            _rec2["s2"] := ""
            _rec2["s3"] := ""
            _rec2["s4"] := ""
            _rec2["s5"] := ""
            _rec2["s6"] := ""
            _rec2["s7"] := ""
            _rec2["s8"] := ""
            _rec2["s9"] := ""
     
            // bit ce sigurno nekih zapisa za izbaciti i slicno ?!???? sa hb_hdel()
            @ m_x + 2, m_y + 2 SAY "import zapisa: " + ALLTRIM( STR( _count ) ) + "/" + ALLTRIM( STR( _fmk_count ) )

            select radn
            APPEND BLANK
            update_rec_server_and_dbf( "radn", _rec2, 1, "FULL" )

        endif

        // podaci poreznih kartica...
        prebaci_pk_data( _fmk_id_radn, _nova_f18_sifra )

    endif

    select fmk_radn
    skip

enddo

BoxC()

// zatvori pomocnu tabelu radnika
select ( F_TMP_1 )
use

select ( F_TMP_2 )
use

select ( F_TMP_3 )
use

select ( F_TMP_4 )
use

select ( F_TMP_5 )
use

select radn
_f18_count := RECCOUNT()
use

if _f18_count <> _fmk_count
    MsgBeep( "FMK radnici: " + ALLTRIM(STR( _fmk_count )) + ", F18 radnici: " + ALLTRIM( STR( _f18_count) ) )
else
    MsgBeep( "Importovao " + ALLTRIM(STR( _f18_count )) )
endif

return _ok


// ------------------------------------------------------------
// kopiranje podataka poreznih kartica...
// ------------------------------------------------------------
static function prebaci_pk_data( sifra, nova_sifra )
local _rec
local _t_area := SELECT()

// ova funkcija podrazumjeva otvorene tabele:
//   fmk_pk i fmk_pkdata
// kao i:
//   ld_pkradn i ld_pkdata

select pk_radn
set order to tag "1"
go top
seek nova_sifra

if !FOUND()

    // nema podataka za ovog radnika

    select fmk_pk
    set order to tag "1"
    go top
    seek sifra
    
    if !FOUND()
        // nema poreznih podataka radnika
        select ( _t_area )
        return
    endif
    
    do while !EOF() .and. field->idradn == sifra

        _rec := dbf_get_rec()
        _rec["idradn"] := nova_sifra

        select pk_radn
        append blank
        
        update_rec_server_and_dbf( "ld_pk_radn", _rec, 1, "CONT" )

        select fmk_pk
        skip

    enddo

    select fmk_pkdata
    set order to tag "1"
    go top
    seek sifra

    do while !EOF() .and. field->idradn == sifra

        _rec := dbf_get_rec()
        _rec["idradn"] := nova_sifra

        select pk_data
        append blank
        
        update_rec_server_and_dbf( "ld_pk_data", _rec, 1, "CONT" )

        select fmk_pkdata
        skip

    enddo

endif

select ( _t_area )

return






// -----------------------------------------------------------------------
// odredjuje novu sifru radnika
// -----------------------------------------------------------------------
static function nova_sifra_radnika( prefix, reset )
local _last_num := fetch_metric( "ld_import_fmk_zadnja_sifra", NIL, 0 )
local _sifra := ""
local _tmp

if prefix == NIL
    prefix := ""
endif

if reset == NIL
    reset := .f.
endif

_tmp := _last_num + 1

if reset
    _tmp := 0
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
local _tip_pr := params["tip_pr"]
local _f18_rj := params["rj_f18"]
local _dat_od := params["datum_od"]
local _dat_do := params["datum_do"]
local _rec, _rec2, _fmk_id_radn, _f18_id_radn
local _count := 0
local _fmk_count
local _a_tippr := {}
local _mj_od, _mj_do
local _god_od, _god_do
local _err := {}

// mjeseci....
_mj_od := MONTH( _dat_od )
_mj_do := MONTH( _dat_do )
// godine...
_god_od := YEAR( _dat_od )
_god_do := YEAR( _dat_do )

// koristi temp tabelu radnika...
// alias: LD_RADN_TMP
_use_tmp_table()
set order to tag "3"

// zakaci mi se na obracun iz FMK
// alias: FMK_LD
select ( F_TMP_2 )
use
my_use_temp( "FMK_LD", _kumpath + "LD.DBF", .f., .t. )
// napravi mi indeks za ovu potrebu...
index on ( idrj + idradn + STR( godina ) + STR( mjesec ) ) TAG "IMP" TO ( _kumpath + "ld_imp_tag")
_fmk_count := RECCOUNT()


// otvori FMK tabelu radnika 
// alias: FMK_LDRADN
select ( F_TMP_3 )
use
my_use_temp( "FMK_LDRADN", _kumpath + "RADN.DBF", .f., .t. )
index on ( id ) TAG "1" TO ( _kumpath + "ldradn_imp_tag")
set order to tag "1"


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


// tipovi primanja matrica
if !EMPTY( _tip_pr )
    _a_tippr := set_tippr_matrix( _tip_pr )
endif

Box(, 2, 66 )

@ m_x + 1, m_y + 2 SAY "Import podataka obracuna za radnu jedinicu: " + _fmk_rj + " u toku..." 

// glavna petlja...
do while !EOF() .and. field->idrj == _fmk_rj

    // fmk radnik
    _fmk_id_radn := field->idradn

    // preskakanje...
    if EMPTY( _fmk_id_radn )
        skip
        loop
    endif

    select fmk_ldradn
    set order to tag "1"
    go top
    seek _fmk_id_radn
    
    if FOUND()

        _fmk_jmbg := field->matbr

    else
        // dodaj u err matricu...
        dodaj_u_err( @_err, _fmk_id_radn, "nesto je ovdje problematicno !!!! radnik: " + _fmk_id_radn  )

        select fmk_ld

        skip
        loop

    endif

    // pronadji ga u temp tabeli - novu sifru
    select ld_radn_tmp
    set order to tag "3"
    go top
    seek _fmk_jmbg

    if !FOUND()
        dodaj_u_err( @_err, _fmk_id_radn, "Nemoguce !!! radnika " + _fmk_jmbg + " / " + _fmk_id_radn + " nema u pomocnoj tabeli !!!!" )
        select fmk_ld
        skip
        loop
    endif

    // ovo mu je prava sifra...
    _f18_id_radn := field->id2

    select fmk_ld

    // sada prodji i ubaci zapise po radniku...
    do while !EOF() .and. field->idrj == _fmk_rj .and. field->idradn == _fmk_id_radn

        // uslovi za preskakanje...

        // prazan zapis...
        if EMPTY( STR( field->godina, 4 ) )
            skip
            loop
        endif

        // datumski uslov ...
        if ( STR( field->godina, 4 ) + STR( field->mjesec, 2 ) < STR( _god_od, 4 ) + STR( _mj_od, 2 ) ) .or. ; 
            ( STR( field->godina, 4 ) + STR( field->mjesec, 2 ) > STR( _god_do, 4 ) + STR( _mj_do, 2 ) )
            skip
            loop
        endif

        // uzmi zapis....
        _rec := dbf_get_rec()

        // ubacimo ga u f18 LD, ali pod novom radnom jedinicom
        _rec["idradn"] := _f18_id_radn
        _rec["idrj"] := _f18_rj

        // nepostojeca polja
        dodaj_nepostojeca_polja_ld( @_rec )

        // zamjeni tipove primanja na osnovu matrice
        change_tippr_from_matrix( @_rec, _a_tippr )

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
select ( F_TMP_3 )
use

// prenos ok
_ok := .t.

// prikazi errore
prikazi_err( _err )

// imamo counter koji mozemo iskoristiti za nesto
// _count

return _ok


// ----------------------------------------------------------
// importuj u ld nepostojeca polja
// ----------------------------------------------------------
static function dodaj_nepostojeca_polja_ld( rec )
local _i

rec["obr"] := "1"
rec["radsat"] := 0

for _i := 41 to 60
    rec[ "s" + ALLTRIM(STR( _i )) ] := 0
    rec[ "i" + ALLTRIM(STR( _i )) ] := 0
next

return


// -----------------------------------------------------------
// dodaj u matricu gresaka
// -----------------------------------------------------------
static function dodaj_u_err( data, key, err )
local _scan

_scan := ASCAN( data, {|var| var[1] == key } )

if _scan == 0
    AADD( data, { key, err } )
endif

return


static function prikazi_err( data )
local _i

if LEN( data ) == 0
    return
endif

START PRINT CRET

? 
? "GRESKE PRILIKOM IMPORTA !!!!"
? REPLICATE( "-", 100 )
? "Kljuc   Greska"
? REPLICATE( "-", 100 )

for _i := 1 to LEN( data )
    ? PADL( ALLTRIM(STR( _i )), 5 ) + ")", data[ _i, 1 ], data[ _i, 2 ]
next

FF
END PRINT

return




// ----------------------------------------------------
// vraca matricu zamjena tipova primanja...
// ----------------------------------------------------
static function set_tippr_matrix( data )
local _matrix := {}
local _i
local _a_tmp_1, _a_tmp_2
local _tmp, _scan

// 12->13;02->04;...

_a_tmp_1 := TokToNiz( data, ";" )

// rastavi mi 12-13 i 02->04
for _i := 1 to LEN( _a_tmp_1 )

    // rastavi mi: 12->13
    _a_tmp_2 := TokToNiz( _a_tmp_1[ _i ], "->" )

    _scan := ASCAN( _matrix, { |val| val[1] == _a_tmp_2[1] } )

    if _scan == 0
        // dodaj u ovu matricu kao [ 12, 13 ]
        AADD( _matrix, { _a_tmp_2[1], _a_tmp_2[2] } )
    endif
next

return _matrix

// --------------------------------------------------------------
// vrsi zamjenu podataka tipova primanja na osnovu matrice
// --------------------------------------------------------------
static function change_tippr_from_matrix( rec, matrix )
local _i
local _search := ""
local _found := "" 

for _i := 1 to LEN( matrix )

    // ovo trazimo u matrici
    _search := matrix[ _i, 1 ]
    
    // postoji kandidat za zamjenu...
    _found := get_tippr_from_matrix( matrix, _search )

    if !EMPTY( _found )

        // zamjeni vrijednosti

        // sati...
        rec[ "s" + _found ] := _rec[ "s" + _search ]
        // original setuj na 0
        rec[ "s" + _search ] := 0

        // iznos ... 
        rec[ "i" + _found ] := _rec[ "i" + _search ]
        // original setuj na 0
        rec[ "i" + _search ] := 0
    
    endif

next

return .t.



// ----------------------------------------------------
// vraca vrijednost iz matrice tipova primanja
// ----------------------------------------------------
static function get_tippr_from_matrix( matrix, search )
local _val := ""
local _scan

_scan := ASCAN( matrix, { |val| val[1] == search } )

if _scan <> 0
    _val := matrix[ _scan, 2 ]
endif

return _val



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
local _err := {}

// koristi temp tabelu radnika...
// alias: LD_RADN_TMP
_use_tmp_table()
set order to tag "1"

// zakaci mi se na obracun iz FMK
// alias: FMK_KRED
select ( F_TMP_2 )
use
my_use_temp( "FMK_KRED", _kumpath + "RADKR.DBF", .f., .t. )
// napravi mi indeks za ovu potrebu...
index on ( idradn + STR( godina ) + STR( mjesec ) ) TAG "IMP" TO ( _kumpath + "kred_imp_tag")
_fmk_count := RECCOUNT()

// otvori FMK tabelu radnika 
// alias: FMK_LDRADN
select ( F_TMP_3 )
use
my_use_temp( "FMK_LDRADN", _kumpath + "RADN.DBF", .f., .t. )
index on ( id ) TAG "1" TO ( _kumpath + "ldradn_imp_tag")
set order to tag "1"


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

Box(, 2, 66 )

@ m_x + 1, m_y + 2 SAY "Import podataka kredita za radnu jedinicu: " + _fmk_rj + " u toku..." 

// glavna petlja...
do while !EOF()

    // fmk radnik
    _fmk_id_radn := field->idradn

    // nadji ga u tabeli ldradn
    select fmk_ldradn
    set order to tag "1"
    go top
    seek _fmk_id_radn
    
    if FOUND()
        _fmk_jmbg := field->matbr
    else
        dodaj_u_err( @_err, _fmk_id_radn, "nesto je ovdje problematicno !!!!, radnika " + _fmk_id_radn + " nema u tabeli radnika !!! " )
        select fmk_kred
        skip
        loop
    endif

    // pronadji ga u temp tabeli - novu sifru
    select ld_radn_tmp
    set order to tag "3"
    go top
    seek _fmk_jmbg

    if !FOUND()
        dodaj_u_err( @_err, _fmk_id_radn, "Nemoguce !!! radnika nema u pomocnoj tabeli !!!! radnik " + _fmk_id_radn )
        select fmk_kred
        skip
        loop
    endif

    // ovo mu je prava sifra...
    _f18_id_radn := field->id2

    select fmk_kred

    do while !EOF() .and. field->idradn == _fmk_id_radn

        _rec := dbf_get_rec()
        // ubacimo ga u f18 LD, ali pod novom radnom jedinicom
        _rec["idradn"] := _f18_id_radn

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
select ( F_TMP_3 )
use

// prenos ok
_ok := .t.

// prikazi greske
prikazi_err( _err )

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
local _sifpath := params["sif_path"]
local _kumpath := params["kum_path"]
local _rec

// porezi
O_POR
if RECCOUNT() == 0
    // porezi...
    select ( F_TMP_4 )
    use
    my_use_temp( "FMK_POR", _sifpath + "POR.DBF", .f., .t. )
    go top
    do while !EOF()

        _rec := dbf_get_rec()
        _rec["match_code"] := ""

        select por
        append blank
        update_rec_server_and_dbf( "por", _rec, 1, "FULL" )

        select fmk_por
        skip

    enddo
endif
select ( F_POR )
use

// doprinosi
O_DOPR
if RECCOUNT() == 0
    // porezi...
    select ( F_TMP_4 )
    use
    my_use_temp( "FMK_DOPR", _sifpath + "DOPR.DBF", .f., .t. )
    go top
    do while !EOF()

        _rec := dbf_get_rec()
        _rec["match_code"] := ""

        select dopr
        append blank
        update_rec_server_and_dbf( "dopr", _rec, 1, "FULL" )

        select fmk_dopr
        skip

    enddo
endif
select ( F_DOPR )
use

// porezi
O_TIPPR
if RECCOUNT() == 0
    // porezi...
    select ( F_TMP_4 )
    use
    my_use_temp( "FMK_TIPPR", _sifpath + "TIPPR.DBF", .f., .t. )
    go top
    do while !EOF()

        _rec := dbf_get_rec()

        select tippr
        append blank
        update_rec_server_and_dbf( "tippr", _rec, 1, "FULL" )

        select fmk_tippr
        skip

    enddo
endif
select ( F_TIPPR )
use

// parametri obracuna
O_PAROBR
if RECCOUNT() == 0
    // porezi...
    select ( F_TMP_4 )
    use
    my_use_temp( "FMK_PAROBR", _sifpath + "PAROBR.DBF", .f., .t. )
    go top
    do while !EOF()

        _rec := dbf_get_rec()
        _rec["obr"] := "1"

        select parobr
        append blank
        update_rec_server_and_dbf( "parobr", _rec, 1, "FULL" )

        select fmk_parobr
        skip

    enddo
endif
select ( F_PAROBR )
use

// krediti
O_KRED
if RECCOUNT() == 0
    // porezi...
    select ( F_TMP_4 )
    use
    my_use_temp( "FMK_KRED", _sifpath + "KRED.DBF", .f., .t. )
    go top
    do while !EOF()

        _rec := dbf_get_rec()
        _rec["match_code"] := ""
        _rec["telefon"] := ""

        select kred
        append blank
        update_rec_server_and_dbf( "kred", _rec, 1, "FULL" )

        select fmk_kred
        skip

    enddo
endif
select ( F_KRED )
use




return _ok


