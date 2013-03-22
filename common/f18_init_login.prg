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


CLASS F18Login

    METHOD New()
    METHOD MainDbLogin()
    METHOD CompanyDbLogin()

    DATA _company_db_connected
    DATA _main_db_connected

    PROTECTED:
        
        METHOD MainDbLoginForm()
        METHOD CompanyDbLoginForm()
        METHOD Connect()
        
        METHOD _read_params()
        METHOD _write_params()

        DATA main_db_params
        DATA company_db_params

ENDCLASS


// main db connect
// =======================================
// oLogin = F18Login():New()
// oLogin:MainDbLoginForm()
// if !oLogin:_main_db_connected
//   ....
// endif




METHOD F18Login:New()
::main_db_params := hb_hash()
::company_db_params := hb_hash()
return SELF





METHOD F18Login:Connect( params, conn_type )
local _connected 
_connected := my_server_login( params, conn_type )
return _connected




METHOD F18Login:Disconnect()
local _disconn 
_disconn := my_server_logout()
return _disconn





METHOD F18Login:_read_params( server_param )

::main_db_params := hb_hash()
::main_db_params["username"] := server_param["user"]
::main_db_params["password"] := server_param["password"]
::main_db_params["host"] := server_param["host"]
::main_db_params["port"] := server_param["port"]
::main_db_params["database"] := server_param["database"]
::main_db_params["schema"] := server_param["schema"]
::main_db_params["session"] := server_param["session"]
::main_db_params["postgres"] := server_param["postgres"]


return .t.





METHOD F18Login:_write_params( server_params )
return .t.





METHOD F18Login:MainDbLogin( server_param )
local _max_login := 4
local _i
local _logged_in := .f.

// ucitaj parametre iz ini fajla i setuj ::main_db_params
::_read_params( @server_param )

// try to connect
// if not, open login form
if ::Connect( server_param, 0 )
    _logged_in := .t.
endif

if !_logged_in
    
    // imamo pravo na 4 pokusaja !
    for _i := 1 to _max_login
        
        // login forma...
        if ! ::MainDbLoginForm()
            // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
            return _logged_in
        endif
        
        ::_write_params( @server_param )

        // zakaci se !
        if ::Connect( server_param, 0 )
            _logged_in := .t.
            exit
        endif

    next

endif

::_main_db_connected := _logged_in

return _logged_in





METHOD F18Login:CompanyDbLogin( server_param )
local _logged_in := .f.
local _i
local _max_login := 4

// procitaj mi parametre za preduzece
::_read_params( @server_param )

if !_logged_in
    // imamo pravo na 4 pokusaja !
    for _i := 1 to _max_login
        
        // login forma...
        if ! ::CompanyDbLoginForm()
            // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
            return _logged_in
        endif
  
        ::_write_params( @server_param )
      
        // zakaci se !
        if ::Connect( server_param, 1 )
            _logged_in := .t.
            exit
        endif

    next
endif

::_company_db_connected := _logged_in

return





METHOD F18Login:MainDbLoginForm()
local _ok := .f.
local _user, _pwd, _port, _host
local _server
local _x := 5
local _left := 7
local _srv_config := "N"

_user := ::main_db_params["username"]
_pwd := ::main_db_params["username"]
_host := ::main_db_params["host"]
_port := ::main_db_params["port"]
_db := ::main_db_params["postgres"]
_schema := ::main_db_params["schema"]

if ( _host == NIL ) .or. ( _port == NIL )
    _srv_config := "D"
endif 

if _host == NIL
    _host := "localhost"
endif

if _port == NIL
    _port := 5432
endif

// ovdje nije fmk
if _schema == NIL
    _schema := "fmk"
endif

if _user == NIL
    _user := "test1"
endif

_host := PADR( _host, 100 )
_user := PADR( _user, 100 )
_pwd := PADR( _pwd, 100 )

CLEAR SCREEN

@ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

++ _x

@ _x, _left SAY PADC( "***** Unestite podatke za pristup *****", 60 )

++ _x
++ _x
@ _x, _left SAY PADL( "Konfigurisati server ?:", 21 ) GET _srv_config ;
                    VALID _srv_config $ "DN" PICT "@!"
++ _x

read

if _srv_config == "D"
    ++ _x
    @ _x, _left SAY PADL( "Server:", 8 ) GET _host PICT "@S20"
    @ _x, 37 SAY "Port:" GET _port PICT "9999"
else    
    ++ _x
endif

++ _x
++ _x

@ _x, _left SAY PADL( "KORISNIK:", 15 ) GET _user PICT "@S30"

++ _x
++ _x

@ _x, _left SAY PADL( "LOZINKA:", 15 ) GET _pwd PICT "@S30" COLOR "BG/BG"

read

if Lastkey() == K_ESC
    return _ok
endif

::main_db_params["username"] := ALLTRIM( _user )
::main_db_params["host"] := ALLTRIM( _host )
::main_db_params["port"] := _port
::main_db_params["postgres"] := "postgres"

// omogucice da se korisnici user=password jednostavno logiraju
if EMPTY( _pwd )
    ::main_db_params["password"] := ::main_db_params["username"]
else
    ::main_db_params["password"] := ALLTRIM( _pwd )
endif 

_ok := .t.

return _ok





METHOD F18Login:CompanyDbLoginForm()
local _ok := .f.
local _db, _session
local _x := 5
local _left := 7
local _srv_config := "N"

_db := ::main_db_params["database"]
_session := ::main_db_params["session"]

_db := PADR( _db, 30 )
_session := PADR( _session, 4 )

CLEAR SCREEN

@ 5, 5, 15, 70 BOX B_DOUBLE_SINGLE

++ _x

@ _x, _left SAY PADC( "***** Unestite podatke za pristup firmi *****", 60 )

++ _x
++ _x

@ _x, _left SAY PADL( "Firma:", 15 ) GET _db PICT "@S30"

++ _x
++ _x

@ _x, _left SAY PADL( "Sezona:", 15 ) GET _session PICT "@S4"

read

if Lastkey() == K_ESC
    return _ok
endif

::main_db_params["database"] := ALLTRIM( _db )
::main_db_params["session"] := ALLTRIM( _session )

_ok := .t.

return _ok



