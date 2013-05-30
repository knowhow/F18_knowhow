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
#include "common.ch"


CLASS F18AdminOpts

    METHOD new()

    METHOD update_db()
    DATA update_db_result

    METHOD create_new_db()
    METHOD drop_db()
    METHOD delete_db_data_all()

    METHOD new_session()

    METHOD relogin_as()

    DATA create_db_result
    
    PROTECTED:
        
        METHOD update_db_download()
        METHOD update_db_all()
        METHOD update_db_company()
        METHOD update_db_command()
        DATA _update_params

        METHOD create_new_db_params()
        DATA _new_db_params

ENDCLASS



METHOD F18AdminOpts:New()
::update_db_result := {}
::create_db_result := {}
return self




METHOD F18AdminOpts:update_db()
local _ok := .f.
local _x := 1
local _version := SPACE(50)
local _db_list := {}
local _server := my_server_params()
local _database := ""
private GetList := {}

_database := SPACE(50)

Box(, 8, 70 )

    @ m_x + _x, m_y + 2 SAY "**** upgrade db-a / unesite verziju ..."
    
    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "     verzija db-a (npr. 4.6.1):" GET _version PICT "@S30" VALID !EMPTY( _version )

    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "naziv baze / prazno update-sve:" GET _database PICT "@S30"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// snimi parametre...
::_update_params := hb_hash()
::_update_params["version"] := ALLTRIM( _version )
::_update_params["database"] := ALLTRIM( _database )
::_update_params["host"] := _server["host"]
::_update_params["port"] := _server["port"]
::_update_params["file"] := "?"

if !EMPTY( _database )
    AADD( _db_list, { ALLTRIM( _database ) } )
else
    _db_list := F18Login():New():database_array()
endif

// download fajla sa interneta...
if !::update_db_download()  
    return _ok
endif

if ! ::update_db_all( _db_list )
    return _ok
endif

if LEN( ::update_db_result ) > 0
    // imamo i rezultate...
    
endif

_ok := .t.

return _ok





METHOD F18AdminOpts:update_db_download()
local _ok := .f.
local _ver := ::_update_params["version"]
local _cmd := ""
local _path := my_home_root()
local _file := "f18_db_migrate_package_" + ALLTRIM( _ver ) + ".gz"

if FILE( ALLTRIM( _path ) + ALLTRIM( _file ) )

    if Pitanje(, "Izbrisati postojeci download file ?", "N" ) == "D"
        FERASE( ALLTRIM( _path ) + ALLTRIM( _file ) )
        sleep(1)
    else
        ::_update_params["file"] := ALLTRIM( _path ) + ALLTRIM( _file )
        return .t.
    endif

endif


_cmd := "wget " 
#ifdef __PLATFORM__WINDOWS
    _cmd += '"' +  "http://knowhow-erp-f18.googlecode.com/files/" + _file + '"'
#else
    _cmd += "http://knowhow-erp-f18.googlecode.com/files/" + _file
#endif

_cmd += " -O "

#ifdef __PLATFORM__WINDOWS
    _cmd += '"' + _path + _file + '"'
#else
    _cmd += _path + _file
#endif

MsgO( "vrsim download db paketa ... sacekajte !" )

hb_run( _cmd )

sleep(1)

MsgC()

if !FILE( _path + _file )
    // nema fajle
    MsgBeep( "Fajl " + _path + _file + " nije download-ovan !!!" )
    return _ok
endif

::_update_params["file"] := ALLTRIM( _path ) + ALLTRIM( _file )

_ok := .t.

return _ok



METHOD F18AdminOpts:update_db_all( arr )
local _i
local _ok := .f.

for _i := 1 to LEN( arr )
    if ! ::update_db_company( ALLTRIM( arr[ _i, 1 ] ) )
        return _ok
    endif
next

_ok := .t.
return _ok


METHOD F18AdminOpts:update_db_command( database )
local _cmd := ""
local _file := ::_update_params["file"]

#ifdef __PLATFORM__DARWIN
    _cmd += "open "
#endif

#ifdef __PLATFORM__WINDOWS
    _cmd += "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
    _cmd += SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

_cmd += "knowhowERP_package_updater"

#ifdef __PLATFORM__WINDOWS
    _cmd += ".exe"
#endif

#ifdef __PLATFORM__DARWIN
    _cmd += ".app"
#endif

#ifndef __PLATFORM__DARWIN
if !FILE( _cmd )
    MsgBeep( "Fajl " + _cmd  + " ne postoji !" )
    return NIL
endif
#endif

_cmd += " -databaseURL=//" + ALLTRIM( ::_update_params["host"] ) 

_cmd += ":"

_cmd += ALLTRIM( STR( ::_update_params["port"] ) )

_cmd += "/" + ALLTRIM( database )

_cmd += " -username=admin"

_cmd += " -passwd=boutpgmin"

#ifdef __PLATFORM__WINDOWS
    _cmd += " -file=" + '"' + ::_update_params["file"] + '"'
#else
    _cmd += " -file=" + ::_update_params["file"]
#endif

_cmd += " -autorun"

return _cmd




METHOD F18AdminOpts:update_db_company( company )
local _sess_list := {}
local _i
local _database
local _cmd 
local _ok := .f.

if ! ( "_" $ company )
    // nema sezone, uzmi sa servera...
    _sess_list := F18Login():New():get_database_sessions( company )
else
   
	if SUBSTR( company, LEN( company ) - 4, 1 ) $ "1#2" 
		// vec postoji zadana sezona...
    	// samo je dodaj u matricu...
		AADD( _sess_list, { RIGHT( ALLTRIM( company ) , 4 ) } )
		company := PADR( ALLTRIM( company ), LEN( ALLTRIM( company ) ) - 5  )
	else
    	_sess_list := F18Login():New():get_database_sessions( company )
	endif

endif

for _i := 1 to LEN( _sess_list )

    _database := ALLTRIM( company ) + "_" + ALLTRIM( _sess_list[ _i, 1 ] )

    _cmd := ::update_db_command( _database )

    if _cmd == NIL
        return _ok
    endif

    MsgO( "Vrsim update baze " + _database ) 
    
    _ok := hb_run( _cmd )

	
    // ubaci u matricu rezultat...
    AADD( ::update_db_result, { company, _database, _cmd, _ok } )

    MsgC()

next

_ok := .t.

return _ok



// -----------------------------------------------------------------------
// razdvajenje sezona...
// -----------------------------------------------------------------------
METHOD F18AdminOpts:new_session()
local _params := hb_hash()
local _dbs := {}
local _i
local _pg_srv, _my_params, _t_user, _t_pwd, _t_database
local _qry 
local _from_sess, _to_sess
local _db_from, _db_to
local _count := 0
local _res := {}
local _ok := .t.

// ovo jos ne radi 
MsgBeep( "Funkcija nije u upotrebi !" )
return

_my_params := my_server_params()
_t_user := _my_params["user"]
_t_pwd := _my_params["password"]
_t_database := _my_params["database"]

// napravi relogin...
_pg_srv := ::relogin_as( "admin", "boutpgmin" )

_qry := "SELECT datname FROM pg_database " 
_qry += "WHERE datname LIKE '% + " + _from_year + "' "
_qry += "ORDER BY datname;"

// daj mi listu...
_dbs := _sql_query( _pg_srv, _qry )
_dbs:Refresh()
_dbs:GoTo(1)

// treba da imamo listu baza...
// uzemomo sa select-om sve sto ima 2013 recimo 
// i onda cemo provrtiti te baze i napraviti 2014

do while !_dbs:EOF()

    ++ _count

    oRow := _dbs:GetRow()

    // test_2013
    _db_from := ALLTRIM( oRow:FieldGet(1) )
    // test_2014
    _db_to := STRTRAN( _tmp, "_" + _from_year, "_" + _to_year ) 

    // init parametri za razdvajanje...
    // pocetno stanje je 1
    _params["db_type"] := 1
    _params["db_name"] := _db_to
    _params["db_template"] := _db_from
    _params["db_drop"] := "D"
    _params["db_comment"] := ""

    // otvori bazu...
    if ! ::create_new_db( _params, _pg_srv )
        AADD( _res, { _db_to, _db_from, "ERR" } )
    endif

    _dbs:Skip()

enddo

// vrati se gdje si bio...
::relogin_as( _t_user, _t_pwd, _t_database )

// imamo i rezultate operacije... kako da to vidimo ?
if LEN( _res ) > 0
    // ?????
endif

return _ok



// ---------------------------------------------------------------
// kreiranje nove baze 
// ---------------------------------------------------------------
METHOD F18AdminOpts:create_new_db( _params, _pg_srv )
local _ok := .f.
local _db_name, _db_template, _db_drop, _db_type, _db_comment
local _qry
local _ret 
local _relogin := .f.
local _db_params, _t_user, _t_pwd, _t_database

// 1) params read
// ===============================================================
if _params == NIL

    if !SigmaSif("ADMIN")
        MsgBeep( "Opcija zasticena !" )
        return _ok
    endif

    _params := hb_hash()

    // CREATE DATABASE name OWNER admin TEMPLATE templ;
    if !::create_new_db_params( @_params )
        return _ok
    endif

endif

// uzmi parametre koje ces koristiti dalje...
_db_name := _params["db_name"]
_db_template := _params["db_template"]
_db_drop := _params["db_drop"] == "D"
_db_type := _params["db_type"]
_db_comment := _params["db_comment"]

if EMPTY( _db_template ) .or. LEFT( _db_template, 5 ) == "empty"
    // ovo ce biti prazna baza uvijek...
    _db_type := 0
endif

// 2) relogin as admin
// ===============================================================
// napravi relogin na bazi... radi admin prava...
if _pg_srv == NIL

    _db_params := my_server_params()
    _t_user := _db_params["user"]
    _t_pwd := _db_params["password"]
    _t_database := _db_params["database"]

    _pg_srv := ::relogin_as( "admin", "boutpgmin" )

    _relogin := .t.

endif

// 3) DROP DATABASE
// ===============================================================
if _db_drop
    // napravi mi DROP baze
    if !::drop_db( _db_name, _pg_srv )
        return _ok
    endif
endif


// 4) CREATE DATABASE
// ===============================================================
// query string za CREATE DATABASE sekvencu
_qry := "CREATE DATABASE " + _db_name + " OWNER admin"
if !EMPTY( _db_template )
    _qry += " TEMPLATE " + _db_template
endif
_qry += ";"

MsgO( "Kreiram novu bazu " + _db_name + " ..." )
_ret := _sql_query( _pg_srv, _qry )
MsgC()

if VALTYPE( _ret ) == "L" .and. _ret == .f.
    // doslo je do neke greske...
    return _ok
endif

// 5) GRANT ALL ...
// ===============================================================

// mozemo sada da napravimo grantove
_qry := "GRANT ALL ON DATABASE " + _db_name + " TO admin;"
_qry += "GRANT ALL ON DATABASE " + _db_name + " TO xtrole WITH GRANT OPTION;"

MsgO( "Postavljam privilegije baze..." )
_ret := _sql_query( _pg_srv, _qry )
MsgC()

if VALTYPE( _ret ) == "L" .and. _ret == .f.
    // doslo je do neke greske...
    return _ok
endif


// 6) COMMENT ON DATABASE ...
// ===============================================================

// komentar ako postoji !
if !EMPTY( _db_comment )
    _qry := "COMMENT ON DATABASE " + _db_name + " IS " + _sql_quote( hb_strtoutf8( _db_comment ) ) + ";"
    MsgO( "Postavljam opis baze..." )
    _ret := _sql_query( _pg_srv, _qry )
    MsgC()
endif


// 7) sredi podatake....
// ===============================================================

// sad se mogu pozabaviti brisanje podataka...
if _db_type > 0
    ::delete_db_data_all( _db_name, _db_type )
endif

// 8) vrati se na postgres bazu...
// ===============================================================

// vrati se u prvobitno stanje operacije...
if _relogin
    ::relogin_as( _t_user, _t_pwd, _t_database )
endif

_ok := .t.

return _ok


//-------------------------------------------------------------------
// drop baze podataka
//-------------------------------------------------------------------
METHOD F18AdminOpts:relogin_as( user, pwd, database )
local _pg_server
local _db_params := my_server_params()

// logout
my_server_logout()

_db_params["user"] := user
_db_params["password"] := pwd

if database <> NIL
    _db_params["database"] := database
endif

my_server_params( _db_params )
my_server_login( _db_params )
_pg_server := pg_server()

return _pg_server



//-------------------------------------------------------------------
// drop baze podataka
//-------------------------------------------------------------------
METHOD F18AdminOpts:drop_db( db_name, pg_srv )
local _ok := .t.
local _qry, _ret
local _my_params
local _relogin := .f.

if db_name == NIL

    if !SigmaSif("ADMIN")
        MsgBeep( "Opcija zasticena !" )
        _ok := .f.
        return
    endif

    // treba mi db name ?
    db_name := SPACE( 30 )

    Box(, 1, 60 )
        @ m_x + 1, m_y + 2 SAY "Naziv baze:" GET db_name VALID !EMPTY( db_name )
        read
    BoxC()

    if LastKey() == K_ESC
        _ok := .f.
        return _ok
    endif

    db_name := ALLTRIM( db_name )

    if Pitanje(, "100% sigurni da zelite izbrisati bazu '" + db_name + "' ?", "N" ) == "N"
        _ok := .f.
        return _ok
    endif

endif

if pg_srv == NIL

    // treba mi relogin...
    _relogin := .t.

    _my_params := my_server_params()
    _t_user := _my_params["user"]
    _t_pwd := _my_params["password"]
    _t_database := _my_params["database"]

    // napravi relogin...
    pg_srv := ::relogin_as( "admin", "boutpgmin" )

endif

_qry := "DROP DATABASE IF EXISTS " + db_name + ";"

MsgO( "Brisanje baze u toku..." )
_ret := _sql_query( pg_srv, _qry )
MsgC()

if VALTYPE( _ret ) == "L" .and. _ret == .f.
    _ok := .f.
endif

// vrati me nazad ako je potrebno
if _relogin
    ::relogin_as( _t_user, _t_pwd, _t_database )
endif

return _ok
 



// -------------------------------------------------------------------
// brisanje podataka u bazi podataka
// -------------------------------------------------------------------
METHOD F18AdminOpts:delete_db_data_all( db_name, data_type )
local _ok := .t.
local _ret
local _qry
local _pg_srv

if db_name == NIL
    MsgBeep( "Opcija zahtjeva naziv baze ..." )
    _ok := .f.
    return _ok
endif

if data_type == NIL
    data_type := 1
endif

// napravi relogin na bazu...
_pg_srv := ::relogin_as( "admin", "boutpgmin", ALLTRIM( db_name ) )

// data_type
// 1 - pocetno stanje
// 2 - brisi sve podatke

// bitne tabele za reset podataka baze
_qry := ""
_qry += "DELETE FROM fmk.kalk_kalk;"
_qry += "DELETE FROM fmk.kalk_doks;"
_qry += "DELETE FROM fmk.kalk_doks2;"

_qry += "DELETE FROM fmk.pos_doks;"
_qry += "DELETE FROM fmk.pos_pos;"
_qry += "DELETE FROM fmk.pos_dokspf;"

_qry += "DELETE FROM fmk.fakt_fakt_atributi;"
_qry += "DELETE FROM fmk.fakt_doks;"
_qry += "DELETE FROM fmk.fakt_doks2;"
_qry += "DELETE FROM fmk.fakt_fakt;"

_qry += "DELETE FROM fmk.fin_suban;"
_qry += "DELETE FROM fmk.fin_anal;"
_qry += "DELETE FROM fmk.fin_sint;"
_qry += "DELETE FROM fmk.fin_nalog;"

_qry += "DELETE FROM fmk.mat_suban;"
_qry += "DELETE FROM fmk.mat_anal;"
_qry += "DELETE FROM fmk.mat_sint;"
_qry += "DELETE FROM fmk.mat_nalog;"

_qry += "DELETE FROM fmk.rnal_docs;"
_qry += "DELETE FROM fmk.rnal_doc_it;"
_qry += "DELETE FROM fmk.rnal_doc_it2;"
_qry += "DELETE FROM fmk.rnal_doc_ops;"
_qry += "DELETE FROM fmk.rnal_doc_log;"
_qry += "DELETE FROM fmk.rnal_doc_lit;"

_qry += "DELETE FROM fmk.epdv_kuf;"
_qry += "DELETE FROM fmk.epdv_kif;"

_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE 'fin/%';"
_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE 'kalk/%';"
_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE 'fakt/%';"
_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE 'pos/%';"
_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE 'epdv/%';"
_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE '%auto_plu%';"

// ako je potrebno brisati sve onda dodaj i sljedece...
if data_type > 1
    
    _qry += "DELETE FROM fmk.os_os;"
    _qry += "DELETE FROM fmk.os_promj;"

    _qry += "DELETE FROM fmk.sii_os;"
    _qry += "DELETE FROM fmk.sii_promj;"

    _qry += "DELETE FROM fmk.ld_ld;"
    _qry += "DELETE FROM fmk.ld_radkr;"
    _qry += "DELETE FROM fmk.ld_radn;"
    _qry += "DELETE FROM fmk.ld_pk_data;"
    _qry += "DELETE FROM fmk.ld_pk_radn;"

    _qry += "DELETE FROM fmk.roba;"
    _qry += "DELETE FROM fmk.partn;"
    _qry += "DELETE FROM fmk.sifv;"

endif

MsgO( "Priprema podataka za novu bazu..." )
_ret := _sql_query( _pg_srv, _qry )
MsgC()

if VALTYPE( _ret ) == "L" .and. _ret == .f.
    _ok := .f.
endif

return _ok
 


// -------------------------------------------------------------------
// kreiranje baze, parametri
// -------------------------------------------------------------------
METHOD F18AdminOpts:create_new_db_params( params )
local _ok := .f.
local _x := 1
local _db_name := SPACE(50)
local _db_template := SPACE(50)
local _db_year := ALLTRIM( STR( YEAR( DATE() ) ) )
local _db_comment := SPACE(100)
local _db_drop := "N"
local _db_type := 1
local _db_str

Box(, 12, 70 )

    @ m_x + _x, m_y + 2 SAY "*** KREIRANJE NOVE BAZE PODATAKA ***"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv nove baze:" GET _db_name VALID _new_db_valid( _db_name ) PICT "@S30"
    @ m_x + _x, col() + 1 SAY "godina:" GET _db_year PICT "@S4" VALID !EMPTY( _db_year )

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Opis baze (*):" GET _db_comment PICT "@S50"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Koristiti kao uzorak postojecu bazu (*):"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv:" GET _db_template PICT "@S40"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Brisi bazu ako vec postoji ! (D/N)" GET _db_drop VALID _db_drop $ "DN" PICT "@!"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Praznjenje podataka (1) pocetno stanje (2) sve" GET _db_type PICT "9"
    
    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "*** opcije markirane kao (*) nisu obavezne"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// formiranje strina naziva baze...
_db_str := ALLTRIM( _db_name ) + "_" + ALLTRIM( _db_year )

// provjeri string ...
// .... nesto ....

// template empty
if EMPTY( _db_template )
    _db_template := "empty"
endif

// - zaista nema template !
if ALLTRIM( _db_template ) == "!"
    _db_template := ""
endif

params["db_name"] := ALLTRIM( _db_str )
params["db_template"] := ALLTRIM( _db_template )
params["db_drop"] := _db_drop
params["db_type"] := _db_type
params["db_comment"] := ALLTRIM( _db_comment )

_ok := .t.

return _ok


// ----------------------------------------------------------
// dodavanje nove baze - validator
// ----------------------------------------------------------
static function _new_db_valid( db_name )
local _ok := .f.

if EMPTY( db_name )
    MsgBeep( "Naziv baze ne moze biti prazno !" )
    return _ok
endif

if ( "-" $ db_name .or. ; 
   "?" $ db_name .or. ;
   ":" $ db_name .or. ;
   "," $ db_name .or. ;
   "." $ db_name )

    MsgBeep( "Naziv baze ne moze sadrzavati znakove .:- itd... !" )
    return _ok

endif

_ok := .t.
return _ok




