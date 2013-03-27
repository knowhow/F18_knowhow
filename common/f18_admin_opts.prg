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

    PROTECTED:
        
        METHOD update_db_download()
        METHOD update_db_all()
        METHOD update_db_company()
        METHOD update_db_command()

        DATA _update_params

ENDCLASS



METHOD F18AdminOpts:New()
::update_db_result := {}
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
    if ! ::update_db_company( arr[ _i, 1 ] )
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

_sess_list := F18Login():New():get_database_sessions( company )

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





