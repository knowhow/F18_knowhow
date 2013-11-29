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
#include "f18_ver.ch"
#include "fileio.ch"

CLASS F18AdminOpts

    VAR update_app_f18
    VAR update_app_f18_version
    VAR update_app_templates
    VAR update_app_templates_version
    VAR update_app_info_file
    VAR update_app_script_file

    METHOD new()

    METHOD update_db()
    DATA update_db_result

    METHOD create_new_db()
    METHOD drop_db()
    METHOD delete_db_data_all()

    METHOD new_session()

    METHOD relogin_as()

    METHOD force_synchro_db()

    METHOD update_app()

    METHOD get_os_name()

    METHOD wget_download()

    DATA create_db_result
    
    PROTECTED:
        
        METHOD update_db_download()
        METHOD update_db_all()
        METHOD update_db_company()
        METHOD update_db_command()
        METHOD create_new_db_params()
    
        METHOD update_app_form()
        METHOD update_app_dl_scripts()
        METHOD update_app_get_versions()
        METHOD update_app_run_script()
        METHOD update_app_run_app_update()
        METHOD update_app_run_templates_update()
        METHOD update_app_unzip_templates()

        DATA _new_db_params
        DATA _update_params

ENDCLASS



METHOD F18AdminOpts:New()
::update_db_result := {}
::create_db_result := {}
return self



// ------------------------------------------------
// ------------------------------------------------
METHOD F18AdminOpts:update_app()
local _ver_params := hb_hash()
local _upd_params := hb_hash()
local _upd_file := ""
local _ok := .f.

// setuj mi ove stavke...
::update_app_info_file := "UPDATE_INFO"
::update_app_script_file := "f18_upd.sh"

#ifdef __PLATFORM__WINDOWS
    ::update_app_script_file := "f18_upd.bat"
#endif

// download scripts...
if !::update_app_dl_scripts()
    MsgBeep( "Problem sa download-om skripti. Provjerite internet koneciju." )
    return SELF
endif

// daj mi informacije o url i verzijama
_ver_params := ::update_app_get_versions()

if _ver_params == NIL
    return SELF
endif

// daj mi parametre za update
if !::update_app_form( _ver_params )
    return SELF
endif

// update template-a...
if ::update_app_templates
    ::update_app_run_templates_update( _ver_params )
endif

// update f18 aplikcije
if ::update_app_f18
    ::update_app_run_app_update( _ver_params )
endif

return SELF



// ------------------------------------------------------------------------
// update aplikcije...
// ------------------------------------------------------------------------
METHOD F18AdminOpts:update_app_run_templates_update( params )
local _upd_file := "F18_template_#VER#.tar.bz2"
local _dest := SLASH + "opt" + SLASH + "knowhowERP" + SLASH

#ifdef __PLATFORM__WINDOWS
    _dest := "c:" + SLASH + "knowhowERP" + SLASH
#endif
    
if ::update_app_templates_version == "#LAST#"
    ::update_app_templates_version := params["templates"]
endif

_upd_file := STRTRAN( _upd_file, "#VER#", ::update_app_templates_version )

// download fajla za update...
if !::wget_download( params["url"], _upd_file, _dest + _upd_file, .t., .t. )
    return SELF
endif

// update run script
::update_app_unzip_templates( _dest, _dest, _upd_file )

return SELF



// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
METHOD F18AdminOpts:update_app_unzip_templates( destination_path, location_path, filename )
local _cmd
local _args := "-jxf"

MsgO( "Vrsim update template fajlova ..." )

#ifdef __PLATFORM__WINDOWS

    // 1) pozicioniraj se u potrebni direktorij...
    DirChange( destination_path )

    // 2) prvo bunzip2
    _cmd := "bunzip2 -f " + location_path + filename
    hb_run( _cmd )

    // 3) tar 
    _cmd := "tar xvf " + STRTRAN( filename, ".bz2", "" ) 
    hb_run( _cmd )

#else

    _cmd := "tar -C " + location_path + " " + _args + " " + location_path + filename
    hb_run( _cmd )

#endif

MsgC()

return SELF



// ------------------------------------------------------------------------
// update aplikcije...
// ------------------------------------------------------------------------
METHOD F18AdminOpts:update_app_run_app_update( params )
local _upd_file := "F18_#OS#_#VER#.gz"
    
if ::update_app_f18_version == "#LAST#"
    ::update_app_f18_version := params["f18"]
endif

#ifdef __PLATFORM__LINUX
    _upd_file := STRTRAN( _upd_file, "#OS#", ::get_os_name() + "_i686" )
#else
    _upd_file := STRTRAN( _upd_file, "#OS#", ::get_os_name() )
#endif

_upd_file := STRTRAN( _upd_file, "#VER#", ::update_app_f18_version )

if ::update_app_f18_version == F18_VER
    MsgBeep( "Verzija aplikacije " + F18_VER + " je vec instalirana !" )
    return SELF
endif

// download fajla za update...
if !::wget_download( params["url"], _upd_file, my_home_root() + _upd_file, .t., .t. )
    return SELF
endif

// update run script
::update_app_run_script( my_home_root() + _upd_file )

return SELF



// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD F18AdminOpts:update_app_run_script( update_file )
local _url := my_home_root() + ::update_app_script_file

#ifdef __PLATFORM__WINDOWS
    _url := 'start cmd /C ""' + _url
    _url += '" "' + update_file + '""' 
#else
    #ifdef __PLATFORM__LINUX
        _url := "bash " + _url
    #endif
    _url += " " + update_file
#endif

#ifdef __PLATFORM__UNIX
    _url := _url + " &"
#endif

Msg( "F18 ce se sada zatvoriti#Nakon update procesa ponovo otvorite F18", 4)

// pokreni skriptu    
hb_run( _url )

// zatvori aplikaciju ako je update aplikacije...
QUIT

return SELF





// ------------------------------------------------
// ------------------------------------------------
METHOD F18AdminOpts:update_app_form( upd_params )
local _ok := .f.
local _f_ver_prim := 1
local _f_ver_sec := 4
local _f_ver_third := SPACE(10)
local _t_ver_prim := 1
local _t_ver_sec := 4
local _t_ver_third := SPACE(10)
local _x := 1
local _col_app, _col_temp, _line
local _upd_f, _upd_t, _pos

_upd_f := "D"
_upd_t := "N"
_col_app := "W/G+"
_col_temp := "W/G+"

if F18_VER < upd_params["f18"]
    _col_app := "W/R+" 
endif
if F18_TEMPLATE_VER < upd_params["templates"]
    _col_temp := "W/R+"
endif

Box(, 14, 65 )

    @ m_x + _x, m_y + 2 SAY PADR( "## UPDATE F18 APP ##", 64 ) COLOR "I"
   
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY _line := ( REPLICATE( "-", 10 ) + " " + REPLICATE( "-", 20 ) + " " + REPLICATE( "-", 20 ) )

    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "[INFO]", 10 ) + "/" + PADC( "Trenutna", 20 ) + "/" + PADC( "Dostupna", 20 )

    ++ _x

    @ m_x + _x, m_y + 2 SAY _line 

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADR( "F18", 10 ) + " " + PADC( F18_VER, 20 )
    @ m_x + _x, col() SAY " "
    @ m_x + _x, col() SAY PADC( upd_params["f18"], 20 ) COLOR _col_app

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADR( "template", 10 ) + " " + PADC( F18_TEMPLATE_VER, 20 )
    @ m_x + _x, col() SAY " "
    @ m_x + _x, col() SAY PADC( upd_params["templates"], 20 ) COLOR _col_temp

    ++ _x

    @ m_x + _x, m_y + 2 SAY _line

    ++ _x
    ++ _x

    _pos := _x

    @ m_x + _x, m_y + 2 SAY "       Update F18 ?" GET _upd_f PICT "@!" VALID _upd_f $ "DN"

    READ

    if _upd_f == "D"

        @ m_x + _x, m_y + 25 SAY "VERZIJA:" GET _f_ver_prim PICT "99" VALID _f_ver_prim > 0
        @ m_x + _x, col() + 1 SAY "." GET _f_ver_sec PICT "99" VALID _f_ver_sec > 0
        @ m_x + _x, col() + 1 SAY "." GET _f_ver_third PICT "@S10"
    
    endif

    ++ _x
    ++ _x
    _pos := _x

    @ m_x + _x, m_y + 2 SAY "  Update template ?" GET _upd_t PICT "@!" VALID _upd_t $ "DN"

    READ

    if _upd_t == "D"
        
        @ m_x + _x, m_y + 25 SAY "VERZIJA:" GET _t_ver_prim PICT "99" VALID _t_ver_prim > 0
        @ m_x + _x, col() + 1 SAY "." GET _t_ver_sec PICT "99" VALID _t_ver_sec > 0
        @ m_x + _x, col() + 1 SAY "." GET _t_ver_third PICT "@S10"
    
        READ

    endif

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// setuj postavke...
::update_app_f18 := ( _upd_f == "D" )
::update_app_templates := ( _upd_t == "D" )

if ::update_app_f18
    // sastavi mi verziju
    if !EMPTY( _f_ver_third )
        // zadana verzija
        ::update_app_f18_version := ALLTRIM( STR( _f_ver_prim ) ) + ;
                            "." + ;
                            ALLTRIM( STR( _f_ver_sec ) ) + ;
                            "." + ;
                            ALLTRIM( _f_ver_third )
    else
        ::update_app_f18_version := "#LAST#"
    endif

    _ok := .t.

endif

if ::update_app_templates
    // sastavi mi verziju
    if !EMPTY( _t_ver_third )
        // zadana verzija
        ::update_app_templates_version := ALLTRIM( STR( _t_ver_prim ) ) + ;
                            "." + ;
                            ALLTRIM( STR( _t_ver_sec ) ) + ;
                            "." + ;
                            ALLTRIM( _t_ver_third )
    else
        ::update_app_templates_version := "#LAST#"
    endif

    _ok := .t.

endif

return _ok




// ------------------------------------------------
// ------------------------------------------------
METHOD F18AdminOpts:update_app_get_versions()
local _urls := hb_hash()
local _o_file, _tmp, _a_tmp
local _file := my_home_root() + ::update_app_info_file
local _count := 0

_o_file := TFileRead():New( _file )
_o_file:Open()

if _o_file:Error()
	MSGBEEP( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
	return SELF
endif

_tmp := ""

// prodji kroz svaku liniju i procitaj zapise
while _o_file:MoreToRead()
	_tmp := hb_strtoutf8( _o_file:ReadLine() )
    _a_tmp := TokToNiz( _tmp, "=" )
    if LEN( _a_tmp ) > 1
        ++ _count
        _urls[ ALLTRIM( LOWER( _a_tmp[1] ) ) ] := ALLTRIM( _a_tmp[2] )
    endif
enddo

_o_file:Close()

if _count == 0
    MsgBeep( "Nisam uspio nista procitati iz fajla sa verzijama !" )
    _urls := NIL
endif

return _urls



// ------------------------------------------------
// ------------------------------------------------
METHOD F18AdminOpts:update_app_dl_scripts()
local _ok := .f.
local _path := my_home_root()
local _url 
local _script 
local _ver_params
local _silent := .t.
local _always_erase := .t.

MsgO( "Vrsim download skripti za update ... sacekajte trenutak !" )

// skini mi info fajl o verzijama...
_url := "https://raw.github.com/knowhow/F18_knowhow/master/"
if !::wget_download( _url, ::update_app_info_file, _path + ::update_app_info_file, _always_erase, _silent )
    MsgC()
    return _ok
endif

// skini mi skriptu f18_upd.sh
_url := "https://raw.github.com/knowhow/F18_knowhow/master/scripts/"
if !::wget_download( _url, ::update_app_script_file, _path + ::update_app_script_file, _always_erase, _silent )
    MsgC()
    return _ok
endif

MsgC()

_ok := .t.
return _ok



// ----------------------------------------------
// ----------------------------------------------
METHOD F18AdminOpts:get_os_name()
local _os := "Ubuntu"

#ifdef __PLATFORM__WINDOWS
    _os := "Windows"
#endif

#ifdef __PLATFORM__DARWIN
    _os := "MacOSX"
#endif

return _os



// ---------------------------------------------------------------
// ---------------------------------------------------------------
METHOD F18AdminOpts:wget_download( url, filename, location, erase_file, silent, only_newer )
local _ok := .f.
local _cmd := ""
local _h, _lenght

if erase_file == NIL
    erase_file := .f.
endif

if silent == NIL
    silent := .f.
endif

if only_newer == NIL
    only_newer := .f.
endif

if erase_file
    FERASE( location )
    sleep(1)
endif

_cmd += "wget " 

#ifdef __PLATFORM__WINDOWS
    _cmd += " --no-check-certificate "
#endif

_cmd += url + filename

_cmd += " -O "

#ifdef __PLATFORM__WINDOWS
    _cmd += '"' + location + '"'
#else
    _cmd += location 
#endif

if !silent
    MsgO( "vrsim download ... sacekajte !" )
endif

hb_run( _cmd )

sleep(1)

if !silent
    MsgC()
endif

if !FILE( location )
    // nema fajle
    MsgBeep( "Fajl " + location + " nije download-ovan !!!" )
    return _ok
endif

// provjeri velicinu fajla...
_h := FOPEN( location )

if _h >= 0
    _length := FSEEK( _h, 0, FS_END )
    FSEEK( _h, 0 )
    FCLOSE( _h )
    if _length <= 0
        MsgBeep( "Trazeni fajl ne postoji !!!" )
        return _ok
    endif
endif

_ok := .t.

return _ok




// -----------------------------------------------
// -----------------------------------------------
METHOD F18AdminOpts:update_db()
local _ok := .f.
local _x := 1
local _version := SPACE(50)
local _db_list := {}
local _server := my_server_params()
local _database := ""
local _upd_empty := "N"
private GetList := {}

_database := SPACE(50)

Box(, 10, 70 )

    @ m_x + _x, m_y + 2 SAY "**** upgrade db-a / unesite verziju ..."
    
    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "     verzija db-a (npr. 4.6.1):" GET _version PICT "@S30" VALID !EMPTY( _version )

    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "naziv baze / prazno update-sve:" GET _database PICT "@S30"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Update template [empty] baza (D/N) ?" GET _upd_empty VALID _upd_empty $ "DN" PICT "@!"

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
::_update_params["updade_empty"] := _upd_empty

if !EMPTY( _database )
    AADD( _db_list, { ALLTRIM( _database ) } )
else
    _db_list := F18Login():New():database_array()
endif

if _upd_empty == "D"	
	// dodaj i empty template tabele u update shemu...
    AADD( _db_list, { "empty" } )
    AADD( _db_list, { "empty_sezona" } )
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



// ----------------------------------------------------------------
// ----------------------------------------------------------------
METHOD F18AdminOpts:update_db_download()
local _ok := .f.
local _ver := ::_update_params["version"]
local _cmd := ""
local _path := my_home_root()
local _file := "f18_db_migrate_package_" + ALLTRIM( _ver ) + ".gz"
local _url := "http://knowhow-erp-f18.googlecode.com/files/"

if FILE( ALLTRIM( _path ) + ALLTRIM( _file ) )

    if Pitanje(, "Izbrisati postojeci download file ?", "N" ) == "D"
        FERASE( ALLTRIM( _path ) + ALLTRIM( _file ) )
        sleep(1)
    else
        ::_update_params["file"] := ALLTRIM( _path ) + ALLTRIM( _file )
        return .t.
    endif

endif

// download fajla
if ::wget_download( _url, _file, _path + _file )
    ::_update_params["file"] := ALLTRIM( _path ) + ALLTRIM( _file )
    _ok := .t.
endif

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

if ALLTRIM( company ) $ "#empty#empty_sezona#"
    // ovo su template tabele...
    AADD( _sess_list, { "empty" } )    
else

    if LEFT( company, 1 ) == "!"

		company := RIGHT( ALLTRIM( company ), LEN( ALLTRIM( company ) ) - 1 )
        // rucno zadat naziv baze, ne gledaj sezone...
        AADD( _sess_list, { "empty" } )        

    elseif ! ( "_" $ company )

        // nema sezone, uzmi sa servera...
        _sess_list := F18Login():New():get_database_sessions( company )

    else

	    if SUBSTR( company, LEN( company ) - 3, 1 ) $ "1#2" 
		    // vec postoji zadana sezona...
    	    // samo je dodaj u matricu...
		    AADD( _sess_list, { RIGHT( ALLTRIM( company ) , 4 ) } )
		    company := PADR( ALLTRIM( company ), LEN( ALLTRIM( company ) ) - 5  )
	    else
    	    _sess_list := F18Login():New():get_database_sessions( company )
	    endif

    endif

endif

for _i := 1 to LEN( _sess_list )

    // ako je ovaj marker uzmi cisto ono sto je navedeno...
    if _sess_list[ _i, 1 ] == "empty"
        // ovo je za empty template tabele..
        _database := ALLTRIM( company )
    else 
        _database := ALLTRIM( company ) + "_" + ALLTRIM( _sess_list[ _i, 1 ] )
    endif

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
local _params
local _dbs := {}
local _i
local _pg_srv, _my_params, _t_user, _t_pwd, _t_database
local _qry 
local _from_sess, _to_sess
local _db_from, _db_to
local _db := SPACE(100)
local _db_delete := "N"
local _count := 0
local _res := {}
local _ok := .t.

if !SigmaSif("ADMIN")
    MsgBeep( "Opcija zasticena !" )
    return _ok
endif

_from_sess := YEAR( DATE() ) - 1
_to_sess := YEAR( DATE() )

SET CURSOR ON
SET CONFIRM ON
 
Box(, 7, 60 )
    @ m_x + 1, m_y + 2 SAY "Otvaranje baze za novu sezonu ***" COLOR "I"
    @ m_x + 3, m_y + 2 SAY "Vrsi se prenos sa godine:" GET _from_sess PICT "9999"
    @ m_x + 3, col() + 1 SAY "na godinu:" GET _to_sess PICT "9999" VALID ( _to_sess > _from_sess .and. _to_sess - _from_sess == 1 )
    @ m_x + 5, m_y + 2 SAY "Baza (prazno-sve):" GET _db PICT "@S30"
    @ m_x + 6, m_y + 2 SAY "Ako baza postoji, pobrisi je ? (D/N)" GET _db_delete VALID _db_delete $ "DN" PICT "@!"
    read
BoxC()

SET CONFIRM OFF

if LastKey() == K_ESC
    return _ok
endif

_my_params := my_server_params()
_t_user := _my_params["user"]
_t_pwd := _my_params["password"]
_t_database := _my_params["database"]

// napravi relogin...
_pg_srv := ::relogin_as( "admin", "boutpgmin" )

_qry := "SELECT datname FROM pg_database " 

if EMPTY( _db )
    _qry += "WHERE datname LIKE '%_" + ALLTRIM( STR( _from_sess ) ) + "' "
else
    _qry += "WHERE datname = " + _sql_quote( ALLTRIM( _db ) + "_" + ALLTRIM( STR( _from_sess ) ) )
endif
_qry += "ORDER BY datname;"

// daj mi listu...
_dbs := _sql_query( _pg_srv, _qry )
_dbs:Refresh()
_dbs:GoTo(1)

// treba da imamo listu baza...
// uzemomo sa select-om sve sto ima 2013 recimo 
// i onda cemo provrtiti te baze i napraviti 2014
Box(, 3, 60 )

do while !_dbs:EOF()

    oRow := _dbs:GetRow()

    // test_2013
    _db_from := ALLTRIM( oRow:FieldGet(1) )
    // test_2014
    _db_to := STRTRAN( _db_from, "_" + ALLTRIM( STR( _from_sess ) ), "_" + ALLTRIM( STR( _to_sess ) ) ) 

    @ m_x + 1, m_y + 2 SAY "Vrsim otvaranje " + _db_from + " > " + _db_to

    // init parametri za razdvajanje...
    // pocetno stanje je 1
    _params := hb_hash()
    _params["db_type"] := 1
    _params["db_name"] := _db_to
    _params["db_template"] := _db_from
    _params["db_drop"] := _db_delete
    _params["db_comment"] := ""

    // napravi relogin...
    _pg_srv := ::relogin_as( "admin", "boutpgmin" )

    // otvori bazu...
    if ! ::create_new_db( _params, _pg_srv )
        AADD( _res, { _db_to, _db_from, "ERR" } )
    else
        ++ _count
    endif

    _dbs:Skip()

enddo

BoxC()

// vrati se gdje si bio...
::relogin_as( _t_user, _t_pwd, _t_database )

// imamo i rezultate operacije... kako da to vidimo ?
if LEN( _res ) > 0
    MsgBeep( "Postoje greske kod otvaranja sezone !" )
endif

if _count > 0
    MsgBeep( "Uspjesno otvoreno " + ALLTRIM( STR( _count ) ) + " baza..." )
endif

return _ok



// ---------------------------------------------------------------
// kreiranje nove baze 
// ---------------------------------------------------------------
METHOD F18AdminOpts:create_new_db( params, pg_srv )
local _ok := .f.
local _db_name, _db_template, _db_drop, _db_type, _db_comment
local _qry
local _ret, _res 
local _relogin := .f.
local _db_params, _t_user, _t_pwd, _t_database

// 1) params read
// ===============================================================
if params == NIL

    if !SigmaSif("ADMIN")
        MsgBeep( "Opcija zasticena !" )
        return _ok
    endif

    params := hb_hash()

    // CREATE DATABASE name OWNER admin TEMPLATE templ;
    if !::create_new_db_params( @params )
        return _ok
    endif

endif

// uzmi parametre koje ces koristiti dalje...
_db_name := params["db_name"]
_db_template := params["db_template"]
_db_drop := params["db_drop"] == "D"
_db_type := params["db_type"]
_db_comment := params["db_comment"]

if EMPTY( _db_template ) .or. LEFT( _db_template, 5 ) == "empty"
    // ovo ce biti prazna baza uvijek...
    _db_type := 0
endif

// 2) relogin as admin
// ===============================================================
// napravi relogin na bazi... radi admin prava...
if pg_srv == NIL
    _db_params := my_server_params()
    _t_user := _db_params["user"]
    _t_pwd := _db_params["password"]
    _t_database := _db_params["database"]
    pg_srv := ::relogin_as( "admin", "boutpgmin" )
    _relogin := .t.
endif

// 3) DROP DATABASE
// ===============================================================
if _db_drop
    // napravi mi DROP baze
    if !::drop_db( _db_name, pg_srv )
        // vrati se u prvobitno stanje operacije...
        if _relogin
            ::relogin_as( _t_user, _t_pwd, _t_database )
        endif
        return _ok
    endif
else
    // provjeri da li ovakva baza vec postoji ?!!!
    _qry := "SELECT COUNT(*) FROM pg_database " 
    _qry += "WHERE datname = " + _sql_quote( _db_name )
    _res := _sql_query( pg_srv, _qry )
    if VALTYPE( _res ) <> "L" 
        if _res:GetRow(1):FieldGet(1) > 0
            // vrati se u prvobitno stanje operacije...
            if _relogin
                ::relogin_as( _t_user, _t_pwd, _t_database )
            endif
            return _ok
        endif
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
_ret := _sql_query( pg_srv, _qry )
MsgC()

if VALTYPE( _ret ) == "L" .and. _ret == .f.
    // doslo je do neke greske...
    if _relogin
        ::relogin_as( _t_user, _t_pwd, _t_database )
    endif
    return _ok
endif

// 5) GRANT ALL ...
// ===============================================================

// mozemo sada da napravimo grantove
_qry := "GRANT ALL ON DATABASE " + _db_name + " TO admin;"
_qry += "GRANT ALL ON DATABASE " + _db_name + " TO xtrole WITH GRANT OPTION;"

MsgO( "Postavljam privilegije baze..." )
_ret := _sql_query( pg_srv, _qry )
MsgC()

if VALTYPE( _ret ) == "L" .and. _ret == .f.
    // doslo je do neke greske...
    if _relogin
        ::relogin_as( _t_user, _t_pwd, _t_database )
    endif
    return _ok
endif


// 6) COMMENT ON DATABASE ...
// ===============================================================

// komentar ako postoji !
if !EMPTY( _db_comment )
    _qry := "COMMENT ON DATABASE " + _db_name + " IS " + _sql_quote( hb_strtoutf8( _db_comment ) ) + ";"
    MsgO( "Postavljam opis baze..." )
    _ret := _sql_query( pg_srv, _qry )
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
_qry += "DELETE FROM fmk.metric WHERE metric_name LIKE '%lock%';"

// ako je potrebno brisati sve onda dodaj i sljedece...
if data_type > 1
    
    _qry += "DELETE FROM fmk.os_os;"
    _qry += "DELETE FROM fmk.os_promj;"

    _qry += "DELETE FROM fmk.sii_sii;"
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
// forsirana sinhronizacija podataka baze
// ----------------------------------------------------------
METHOD F18AdminOpts:force_synchro_db()
local _var
local oDb_lock := F18_DB_LOCK():New()
local _is_locked := oDb_lock:is_locked()
local _curr_lock_str

if _is_locked 
    // privremeno moramo iskljuciti lock
    _curr_lock_str := oDb_lock:lock_params["server_lock"]
    oDb_lock:set_lock_params( .f. )
endif

_ver := read_dbf_version_from_config()
set_a_dbfs()
cre_all_dbfs( _ver )
set_a_dbfs_key_fields()
write_dbf_version_to_config()
check_server_db_version()
f18_init_semaphores()

if _is_locked
    // ponovo vrati lock
    oDb_lock:set_lock_params( .t., _curr_lock_str )
endif

return



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



