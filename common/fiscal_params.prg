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


#include "fmk.ch"

static __use_fiscal_opt := .f.


// ----------------------------------------------------------
// vraca ili setuje fiskalni parametar
// ----------------------------------------------------------
function fiscal_opt_active()
local _opt := fetch_metric( "fiscal_opt_active", my_user(), "N" )

if _opt == "N"
    __use_fiscal_opt := .f.
else
    __use_fiscal_opt := .t.
endif

return __use_fiscal_opt


// ----------------------------------------------------------
// menij fiskalnih opcija
// ----------------------------------------------------------
function f18_fiscal_params_menu()
local _opc := {}
local _opc_exe := {}
local _izbor := 1

// setuj mi glavnu varijablu
fiscal_opt_active()

AADD( _opc, "1. fiskalni uredjaji: globalne postavke        " )
AADD( _opc_exe, { || set_main_fiscal_params() })
AADD( _opc, "2. fiskalni uredjaji: korisnicke postavke " )
AADD( _opc_exe, { || set_user_fiscal_params() })
AADD( _opc, "3. korisnicke fiskalne postavke  " )
AADD( _opc_exe, { || set_global_fiscal_params() })
AADD( _opc, "4. pregled parametara" )
AADD( _opc_exe, { || print_fiscal_params() })

f18_menu( "fiscal", .f., _izbor, _opc, _opc_exe )

return



// ---------------------------------------------
// init fiscal params
// 
//    setuju se init vrijednosti u parametrima:
//
//    fiscal_device_01_id, active, name...
//    fiscal_device_02_id, active, name...
//
// ---------------------------------------------
function set_init_fiscal_params()
local _devices := 10
local _i
local _tmp, _dev_param
local _dev_id

for _i := 1 to _devices

    // "01", "02", ...
    _dev_id := PADL( ALLTRIM(STR(_i)), 2, "0" )
    _dev_param := "fiscal_device_" + _dev_id

    // fiscal_device_01_id
    _tmp := fetch_metric( _dev_param + "_id", NIL, 0  )

    if _tmp == 0

        // setuj mi device_id parametar
        set_metric( _dev_param + "_id", NIL, _i )
        set_metric( _dev_param + "_active", NIL, "N" )
        set_metric( _dev_param + "_drv", NIL, "FPRINT" )
        set_metric( _dev_param + "_name", NIL, "Fiskalni uredjaj " + _dev_id )

    endif

next

return .t.




// --------------------------------------------------------------
// vraca naziv fiskalnog uredjaja 
// --------------------------------------------------------------
static function get_fiscal_device_name( device_id )
local _tmp := PADL( ALLTRIM(STR( device_id )), 2, "0" )
return fetch_metric( "fiscal_device_" + _tmp + "_name", NIL, "" )



// ---------------------------------------------------------------------
// setovanje globalnih fiskalnih parametara
// ---------------------------------------------------------------------
function set_global_fiscal_params()
local _x := 1
local _fiscal := fetch_metric( "fiscal_opt_active", my_user(), "N" )
local _fiscal_devices := PADR( fetch_metric( "fiscal_opt_usr_devices", my_user(), "" ), 50 )
local _pos_def := fetch_metric( "fiscal_opt_usr_pos_default_device", my_user(), 0 )

Box(, 5, 60 )

    @ m_x + _x, m_y + 2 SAY "Koristiti fiskalne opcije (D/N) ?" GET _fiscal ;
        PICT "@!" ;
        VALID _fiscal $ "DN"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "*** Korisiti sljedece fiskalne uredjaje"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "ID:" GET _fiscal_devices PICT "@S30"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Default POS uredjaj:" GET _pos_def PICT "99"

    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi parametre
set_metric( "fiscal_opt_active", my_user(), _fiscal )
set_metric( "fiscal_opt_usr_devices", my_user(), ALLTRIM( _fiscal_devices ) )
set_metric( "fiscal_opt_usr_pos_default_device", my_user(), _pos_def )

// setuj glavni parametar
fiscal_opt_active()

return .t.




// ---------------------------------------------
// set global fiscal params
// ---------------------------------------------
function set_main_fiscal_params()
local _device_id := 1
local _max_id := 10
local _min_id := 1
local _x := 1
local _dev_tmp
local _dev_name, _dev_act, _dev_type, _dev_drv
local _dev_iosa, _dev_serial, _dev_plu, _dev_pdv, _dev_init_plu
local _dev_avans, _dev_timeout, _dev_vp_sum
local _dev_restart

if !__use_fiscal_opt 
    MsgBeep( "Fiskalne opcije moraju biti ukljucene !!!" )
    return .f.
endif

Box(, 20, 80 )

    @ m_x + _x, m_y + 2 SAY "Uredjaj ID:" GET _device_id ;
        PICT "99" ;
        VALID ( _device_id >= _min_id .and. _device_id <= _max_id )

    read

    if LastKey() == K_ESC
        BoxC()
        return .f.
    endif

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "**** Podesenje uredjaja", 60 ) COLOR "I"

    // iscitaj mi sada kada imam parametar tekuce postavke uredjaja

    _dev_tmp := PADL( ALLTRIM(STR( _device_id )), 2, "0" )
    _dev_name := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, "" ), 100 )
    _dev_act := fetch_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, "N" )
    _dev_drv := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, "" ), 20 )
    _dev_type := fetch_metric( "fiscal_device_" + _dev_tmp + "_type", NIL, "P" )
    _dev_pdv := fetch_metric( "fiscal_device_" + _dev_tmp + "_pdv", NIL, "D" )
    _dev_iosa := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_iosa", NIL, "1234567890123456" ), 16 )
    _dev_serial := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_serial", NIL, "000000" ), 20 )
    _dev_plu := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_type", NIL, "D" )
    _dev_init_plu := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_init", NIL, 10 )
    _dev_avans := fetch_metric( "fiscal_device_" + _dev_tmp + "_auto_avans", NIL, 0 )
    _dev_timeout := fetch_metric( "fiscal_device_" + _dev_tmp + "_time_out", NIL, 300 )
    _dev_vp_sum := fetch_metric( "fiscal_device_" + _dev_tmp + "_vp_sum", NIL, 1 )
    _dev_restart := fetch_metric( "fiscal_device_" + _dev_tmp + "_restart_service", NIL, "N" )

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Naziv uredjaja:" GET _dev_name ;
        PICT "@S40"

    @ m_x + _x, col() + 1 SAY "Aktivan (D/N):" GET _dev_act ;
        PICT "@!" ;
        VALID _dev_act $ "DN"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Drajver (FPRINT/HCP/TREMOL/TRING/...):" GET _dev_drv ;
        PICT "@S20" ;
        VALID !EMPTY( _dev_drv )

    read

    if LastKey() == K_ESC
        BoxC()
        return .f.
    endif

    if ALLTRIM( _dev_drv ) == "FPRINT"

        ++ _x

        @ m_x + _x, m_y + 2 SAY "IOSA broj:" GET _dev_iosa ;
            PICT "@S16" ;
            VALID !EMPTY( _dev_iosa )

        @ m_x + _x, col() + 1 SAY "Serijski broj:" GET _dev_serial ;
            PICT "@S20" ;
            VALID !EMPTY( _dev_serial )

    endif

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uredjaj je u sistemu PDV-a (D/N):" GET _dev_pdv ;
        PICT "@!" ;
        VALID _dev_pdv $ "DN"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Tip uredjaja (K - kasa, P - printer):" GET _dev_type ;
        PICT "@!" ;
        VALID _dev_type $ "KP"

    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADR( "**** Parametri artikla", 60 ) COLOR "I"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Za artikal koristiti plu [D/P] (stat./dinam.) [I] id, [B] barkod:" GET _dev_plu ;
        PICT "@!" ;
        VALID _dev_plu $ "DPIB"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "(dinamicki) inicijalni PLU kod:" GET _dev_init_plu PICT "999999"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "**** Parametri rada sa uredjajem", 60 ) COLOR "I"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Automatski polog u uredjaj:" GET _dev_avans PICT "999999.99"
    @ m_x + _x, col() + 1 SAY "Timeout fiskalnih operacija:" GET _dev_timeout PICT "999"

    ++ _x    

    @ m_x + _x, m_y + 2 SAY "Zbirni racun u VP (0/1/...):" GET _dev_vp_sum PICT "999"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Restart servisa nakon slanja komande (D/N) ?" GET _dev_restart ;
            PICT "@!" ;
            VALID _dev_restart $ "DN"


    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi mi parametre uredjaja
set_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, ALLTRIM( _dev_name ) )
set_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, _dev_act )
set_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, ALLTRIM( _dev_drv ) )
set_metric( "fiscal_device_" + _dev_tmp + "_type", NIL, _dev_type )
set_metric( "fiscal_device_" + _dev_tmp + "_pdv", NIL, _dev_pdv )
set_metric( "fiscal_device_" + _dev_tmp + "_iosa", NIL, ALLTRIM( _dev_iosa ) )
set_metric( "fiscal_device_" + _dev_tmp + "_serial", NIL, ALLTRIM( _dev_serial ) )
set_metric( "fiscal_device_" + _dev_tmp + "_plu_type", NIL, _dev_plu )
set_metric( "fiscal_device_" + _dev_tmp + "_plu_init", NIL, _dev_init_plu )
set_metric( "fiscal_device_" + _dev_tmp + "_auto_avans", NIL, _dev_avans )
set_metric( "fiscal_device_" + _dev_tmp + "_time_out", NIL, _dev_timeout )
set_metric( "fiscal_device_" + _dev_tmp + "_vp_sum", NIL, _dev_vp_sum )
set_metric( "fiscal_device_" + _dev_tmp + "_restart_service", NIL, _dev_restart )

return .t.





// ---------------------------------------------
// ---------------------------------------------
function set_user_fiscal_params()
local _user_name := my_user()
local _user_id := GetUserId( _user_name )
local _device_id := 1
local _max_id := 10
local _min_id := 1
local _x := 1
local _dev_drv, _dev_tmp
local _out_dir, _out_file, _ans_file, _print_a4
local _op_id, _op_pwd, _print_fiscal
local _op_docs

if !__use_fiscal_opt 
    MsgBeep( "Fiskalne opcije moraju biti ukljucene !!!" )
    return .f.
endif

Box(, 20, 80 )

    // to-do, napraviti da se ispisu uredjaj i korisnik... pored GET polja

    @ m_x + _x, m_y + 2 SAY PADL( "Uredjaj ID:", 15 ) GET _device_id ;
        PICT "99" ;
        VALID {|| ( _device_id >= _min_id .and. _device_id <= _max_id ), ;
                show_it( get_fiscal_device_name( _device_id, 30 ) ), .t. }

    ++ _x

    @ m_x + _x, m_y + 2 SAY PADL( "Korisnik:", 15 ) GET _user_id ;
        PICT "99999999" ;
        VALID { || IIF( _user_id == 0, choose_f18_user_from_list( @_user_id ), .t. ), ;
            show_it( GetFullUserName( _user_id ), 30 ), .t.  }

    read

    if LastKey() == K_ESC
        BoxC()
        return .f.
    endif

    // korisnik ce biti na osnovu izbora
    _user_name := ALLTRIM( GetUserName( _user_id ) )

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "*** podesenja rada sa uredjajem", 60 ) COLOR "I"

    ++ _x

    // iscitaj mi sada kada imam parametar tekuce postavke uredjaja za korisnika
    _dev_tmp := PADL( ALLTRIM(STR( _device_id )), 2, "0" )
    // drajver uredjaja
    _dev_drv := ALLTRIM( fetch_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, "" ) )

    // ---------------------------
    // korisnicki parametri
    // ---------------------------
    _out_dir := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, out_dir_op_sys( _dev_drv ) ), 300 )
    _out_file := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_out_file", _user_name, out_file_op_sys( _dev_drv ) ), 50 )
    _out_answer := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_out_answer", _user_name, "" ), 50 )

    _op_id := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_op_id", _user_name, "1" ), 10 )
    _op_pwd := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_op_pwd", _user_name, "000000" ), 10 )
    _print_a4 := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_a4", _user_name, "N" )
    _print_fiscal := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_fiscal", _user_name, "D" )
    _op_docs := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_op_docs", _user_name, "" ), 100 )
    
    @ m_x + _x, m_y + 2 SAY "Direktorij izlaznih fajlova:" GET _out_dir PICT "@S50" VALID _valid_fiscal_path( _out_dir )

    ++ _x

    @ m_x + _x, m_y + 2 SAY "       Naziv izlaznog fajla:" GET _out_file PICT "@S20" VALID !EMPTY( _out_file )

    ++ _x

    @ m_x + _x, m_y + 2 SAY "       Naziv fajla odgovora:" GET _out_answer PICT "@S20"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Operater, ID:" GET _op_id PICT "@S10"
    @ m_x + _x, col() + 1 SAY "lozinka:" GET _op_pwd PICT "@S10"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Stampati A4 racun nakon fiskalnog (D/N/G/X):" GET _print_a4 ;
        PICT "@!" VALID _print_a4 $ "DNGX"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uredjaj koristiti za slj.tipove dokumenata:" GET _op_docs PICT "@S20" 

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Korisnik moze printati fiskalne racune (D/N/T):" GET _print_fiscal ;
        PICT "@!" VALID _print_fiscal $ "DNT"
    
    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi mi parametre uredjaja
set_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, ALLTRIM( _out_dir ) )
set_metric( "fiscal_device_" + _dev_tmp + "_out_file", _user_name, ALLTRIM( _out_file ) )
set_metric( "fiscal_device_" + _dev_tmp + "_out_answer", _user_name, ALLTRIM( _out_answer ) )
set_metric( "fiscal_device_" + _dev_tmp + "_op_id", _user_name, ALLTRIM( _op_id ) )
set_metric( "fiscal_device_" + _dev_tmp + "_op_pwd", _user_name, ALLTRIM( _op_pwd ) )
set_metric( "fiscal_device_" + _dev_tmp + "_print_a4", _user_name, _print_a4 )
set_metric( "fiscal_device_" + _dev_tmp + "_print_fiscal", _user_name, _print_fiscal )
set_metric( "fiscal_device_" + _dev_tmp + "_op_docs", _user_name, ALLTRIM( _op_docs ) )
 
return .t.




// ---------------------------------------------------------------------
// izlazni direktorij za fiskalne funkcije
// ---------------------------------------------------------------------
static function out_dir_op_sys( dev_type )
local _path := ""

do case

    case dev_type == "FPRINT" .or. dev_type == "TREMOL"

        #ifdef __PLATFORM__WINDOWS
            _path := "C:" + SLASH + "fiscal" + SLASH
        #else
            _path := SLASH + "home" + SLASH + "bringout" + SLASH + "fiscal" + SLASH
        #endif

    case dev_type == "HCP"

        #ifdef __PLATFORM__WINDOWS
            _path := "C:" + SLASH + "HCP" + SLASH
        #else
            _path := SLASH + "home" + SLASH + "bringout" + SLASH + "HCP" + SLASH
        #endif

endcase

return _path


// ---------------------------------------------------------------------
// izlazni fajl za fiskalne opcije
// ---------------------------------------------------------------------
static function out_file_op_sys( dev_type )
local _file := ""

do case
    case dev_type == "FPRINT"
        _file := "out.txt"
    case dev_type == "HCP"
        _file := "TR$_01.XML"
    case dev_type == "TREMOL"
        _file := "01.xml"
endcase

return _file




// -------------------------------------------------------
// validacija path-a izlaznih fajlova
// -------------------------------------------------------
static function _valid_fiscal_path( fiscal_path, create_dir )
local _ok := .t.
local _cre

if create_dir == NIL
    create_dir := .t.
endif

fiscal_path := ALLTRIM( fiscal_path )

if EMPTY( fiscal_path )
    MsgBeep( "Izlazni direktorij za fiskalne fajlove ne smije biti prazan ?!!!" )
    _ok := .f.
    return _ok
endif

if DirChange( fiscal_path ) != 0
    // probaj kreirati direktorij...
    if create_dir
        _cre := MakeDir( fiscal_path )
        if _cre != 0
            MsgBeep( "Kreiranje " + fiscal_path + " neuspjesno ?!#Provjerite putanju direktorija izlaznih fajlova." )
            _ok := .f.
        endif
    else
        MsgBeep( "Izlazni direktorij: " + fiscal_path + "#ne postoji !!!" )
        _ok := .f.
    endif
endif

return _ok



// ---------------------------------------------------------------
// vraca odabrani fiskalni uredjaj
// ---------------------------------------------------------------
function get_fiscal_device( user, tip_dok, from_pos )
local _device_id := 0
local _dev_arr
local _pos_default

if !__use_fiscal_opt 
    return NIL
endif

if from_pos == NIL
    from_pos := .f.
endif

if tip_dok == NIL
    tip_dok := ""
endif

_dev_arr := get_fiscal_devices_list( user, tip_dok )

if LEN( _dev_arr ) == 0
    return _device_id
endif

// default pos fiskalni uredjaj...
// ako je setovan, uvijek ces njega koristiti
// nema potrebe da se ulazi u listu uredjaj...
if from_pos
    _pos_default := fetch_metric( "fiscal_opt_usr_pos_default_device", my_user(), 0 )
    if _pos_default > 0
        return _pos_default
    endif
endif

if LEN( _dev_arr ) > 1
    // prikazi mi listu uredjaja...
    _device_id := arr_fiscal_choice( _dev_arr )
else
    // samo je jedan uredjaj u listi, ovo je njegov ID
    _device_id := _dev_arr[ 1, 1 ]
endif

return _device_id



// -----------------------------------------------------
// vraca listu fiskalnih uredjaja kroz matricu
// -----------------------------------------------------
function get_fiscal_devices_list( user, tip_dok )
local _arr := {}
local _i
local _dev_max := 10
local _dev_tmp
local _usr_dev_list := ""
local _dev_docs_list := ""

// ako je zadan user, provjeri njegova lokalna podesenja
if user == NIL
    user := my_user()
endif

if tip_dok == NIL
    tip_dok := ""
endif

// ovo je lista koja se setuje kod korisnika...
_usr_dev_list := fetch_metric( "fiscal_opt_usr_devices", user, "" )

for _i := 1 to _dev_max
    
    _dev_tmp := PADL( ALLTRIM( STR( _i) ), 2, "0" )

    _dev_id := fetch_metric( "fiscal_device_" + _dev_tmp + "_id", NIL, 0 )

    _dev_docs_list := fetch_metric( "fiscal_device_" + _dev_tmp + "_op_docs", my_user(), "" )

    if ( _dev_id <> 0 ) ;
        .and. ( fetch_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, "N" ) == "D" ) ;
        .and. IF( !EMPTY( _usr_dev_list ), ALLTRIM(STR( _dev_id ) ) + "," $ _usr_dev_list + ",", .t. ) ;
        .and. IF( !EMPTY( _dev_docs_list), tip_dok $ _dev_docs_list, .t. )

        // ubaci u matricu: dev_id, dev_name
        AADD( _arr, { _dev_id, fetch_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, "" ) } )

    endif

next

if LEN( _arr ) == 0
    MsgBeep( "Nema podesen niti jedan fiskalni uredjaj !!!" )
endif

return _arr



// -------------------------------------------------------
// array choice
// -------------------------------------------------------
static function arr_fiscal_choice( arr )
local _ret := 0
local _i, _n
local _tmp
local _izbor := 1
local _opc := {}
local _opcexe := {}
local _m_x := m_x
local _m_y := m_y

for _i := 1 to LEN( arr )

    _tmp := ""
    _tmp += PADL( ALLTRIM(STR( _i )) + ")", 3 )
    _tmp += " uredjaj " + PADL( ALLTRIM( STR( arr[ _i, 1 ] ) ) , 2, "0" )
    _tmp += " : " + PADR( arr[ _i, 2 ], 40 )

    AADD( _opc, _tmp )
    AADD( _opcexe, {|| "" })
    
next

do while .t. .and. LastKey() != K_ESC
    _izbor := Menu( "choice", _opc, _izbor, .f. )
	if _izbor == 0
        exit
    else
        _ret := arr[ _izbor, 1 ]
        _izbor := 0
    endif
enddo

m_x := _m_x
m_y := _m_y

return _ret




// --------------------------------------------------------------
// vraca hash matricu sa postavkama fiskalnog uredjaja
// --------------------------------------------------------------
function get_fiscal_device_params( device_id, user_name )
local _param := hb_hash()
local _dev_tmp := PADL( ALLTRIM(STR( device_id )), 2, "0" )
local _dev_param
local _user_name := my_user()
local _out_dir

if !__use_fiscal_opt 
    return NIL
endif

// pretpostavlja da ce se koristiti tekuci user
// ali mozemo zadati i nekog drugog korisnika
if user_name <> NIL
    _user_name := user_name
endif

_dev_param := "fiscal_device_" + _dev_tmp

_dev_id := fetch_metric( _dev_param + "_id", NIL, 0 )

// nema tog fiskalnog uredjaja
if _dev_id == 0
    return NIL
endif

// napuni mi hash matricu sa podacima uredjaja...

// globalni parametri
_param["id"] := _dev_id
_param["name"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, "" )
_param["active"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, "" ) 
_param["drv"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, "" )
_param["type"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_type", NIL, "P" )
_param["pdv"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_pdv", NIL, "D" )
_param["iosa"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_iosa", NIL, "" ) 
_param["serial"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_serial", NIL, "" )
_param["plu_type"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_type", NIL, "D" )
_param["plu_init"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_init", NIL, 10 )
_param["auto_avans"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_auto_avans", NIL, 0 )
_param["timeout"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_time_out", NIL, 300 )
_param["vp_sum"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_vp_sum", NIL, 1 )
_param["restart_service"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_restart_service", NIL, "N" )

#ifdef TEST
   _out_dir := "/tmp/"
#else
   // user parametri
  _out_dir := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, "" )
#endif

// ako nema podesen output dir, onda znamo i da user nije setovan...
if EMPTY( _out_dir )
    return NIL
endif

#ifdef TEST
   _param["out_dir"]  := "/tmp/"
   _param["out_file"] := "fiscal.txt"
   _param["out_answer"] := "answer.txt"
   _param["op_id"] := "01"
   _param["op_pwd"] := "00"
   _param["print_a4"] := "N"
   _param["print_fiscal"] := "T"
   _param["op_docs"] := ""
#else
  _param["out_dir"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, "" )
  _param["out_file"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_file", _user_name, "" )
  _param["out_answer"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_answer", _user_name, "" )
  _param["op_id"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_op_id", _user_name, "" ) 
  _param["op_pwd"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_op_pwd", _user_name, "" )
  _param["print_a4"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_a4", _user_name, "N" )
  _param["print_fiscal"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_fiscal", _user_name, "D" )
  _param["op_docs"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_op_docs", _user_name, "" )
#endif

// chekiranje parametara 
if !post_check( _param )
    return NIL
endif
 
return _param


// ---------------------------------------------------------------
// chekiranje nakon setovanja, da li ima lokacije itd...
// ---------------------------------------------------------------
static function post_check( param )
local _ret := .t.

// provjeri lokaciju 
_ret := _valid_fiscal_path( param["out_dir"], .f. )

if !_ret
    MsgBeep( "Izlazni direktorij " + ALLTRIM( param["out_dir"] ) + " nije ispravan !!!#Prekidam operaciju!" )
    return _ret
endif

// izlazni fajl
if EMPTY( param["out_file"] )
    MsgBeep( "Naziv izlaznog fajla mora biti popunjen ispravno !!!" )
    _ret := .f.
    return _ret
endif

return _ret




// ----------------------------------------------------------
// prikazi fiskalne parametre
// ----------------------------------------------------------
function print_fiscal_params()
local _dev_arr
local _usr_count, _dev_param
local _user := my_user()
local _usr_cnt, _user_id, _user_name
local _dev_cnt, _dev_id, _dev_name, _dev_act

if !__use_fiscal_opt 
    MsgBeep( "Fiskalne opcije moraju biti ukljucene !!!" )
    return .f.
endif

_usr_arr := get_list_f18_users()

START PRINT CRET
?
? "Prikaz fiskalnih parametara:"
?

for _usr_cnt := 1 to LEN( _usr_arr )

    _user_id := _usr_arr[ _usr_cnt, 1 ]
    _user_name := _usr_arr[ _usr_cnt, 2 ]

    // izvuci mi listu za pojedinog korisnika...
    _dev_arr := get_fiscal_devices_list( _user_name )

    ? 
    ? "Korisnik:", ALLTRIM( STR( _user_id ) ), "-", GetFullUserName( _user_id )
    ? REPLICATE( "=", 80 ) 

    for _dev_cnt := 1 to LEN( _dev_arr )

        _dev_id := _dev_arr[ _dev_cnt, 1 ]
        _dev_name := _dev_arr[ _dev_cnt, 2 ]

        ? SPACE(3), REPLICATE( "-", 70 )
        ? SPACE(3), "Uredjaj id:", ALLTRIM( STR( _dev_id ) ), "-", _dev_name
        ? SPACE(3), REPLICATE( "-", 70 )

        // sada imamo parametre za pojedini stampac

        _dev_param := get_fiscal_device_params( _dev_id, _user_name )

        if _dev_param == NIL
            ? SPACE(3), "nema podesenih parametara !!!"
        else
            _print_param( _dev_param )
        endif

    next

next

FF
END PRINT

return



// ------------------------------------------------------
// printanje parametra
// ------------------------------------------------------
static function _print_param( param )

? SPACE(3), "Drajver:", param["drv"], "IOSA:", param["iosa"], "Serijski broj:", param["serial"], "Tip uredjaja:", param["type"] 
? SPACE(3), "U sistemu PDV-a:", param["pdv"]
?
? SPACE(3), "Izlazni direktorij:", ALLTRIM( param["out_dir"] )
? SPACE(3), "       naziv fajla:", ALLTRIM( param["out_file"] ), "naziv fajla odgovora:", ALLTRIM( param["out_answer"] )
? SPACE(3), "Operater ID:", param["op_id"], "PWD:", param["op_pwd"]
?
? SPACE(3), "Tip PLU kodova:", param["plu_type"], "Inicijalni PLU:", ALLTRIM( STR( param["plu_init"] ) )
? SPACE(3), "Auto polog:", ALLTRIM( STR( param["auto_avans"], 12, 2 ) ), ;
	"Timeout fiskalnih operacija:", ALLTRIM( STR( param["timeout"] ) )
?
? SPACE(3), "A4 print:", param["print_a4"], " dokumenti za stampu:", param["op_docs"]
? SPACE(3), "Zbirni VP racun:", ALLTRIM( STR( param["vp_sum"] ) )

return


