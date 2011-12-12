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

static __server := NIL
static __server_params := NIL
static __f18_home := NIL
static __f18_home_root := NIL
static __log_handle := NIL

#include "fmk.ch"

// -------------------------
// -------------------------
function init_f18_app()
local _ini_params

REQUEST DBFCDX

// ? "setujem default engine ..." + RDDENGINE
RDDSETDEFAULT( RDDENGINE )

REQUEST HB_CODEPAGE_SL852 
REQUEST HB_CODEPAGE_SLISO

SET DELETED ON

HB_CDPSELECT("SL852")

if setmode(MAXROWS(), MAXCOLS())
   ? "hej mogu setovati povecani ekran !"
else
   ? "ne mogu setovati povecani ekran !"
   QUIT
endif

set( _SET_EVENTMASK, INKEY_ALL )
mSetCursor( .t. )

public gRj := "N"
public gReadOnly := .f.
public gSQL := "N"
public Invert := .f.
public gOModul := NIL
public cDirPriv:=""
public cDirRad:=""
public cDirSif:=""

set_f18_home_root()

if ( __log_handle := FCREATE(F18_LOG_FILE) ) == -1
    ? "Cannot create log file: " + F18_LOG_FILE
    QUIT
endif

SetgaSDbfs()
set_global_vars_0()
set_a_dbfs()

// ucitaj parametre iz inija, ako postoje ...
_ini_params := hb_hash()
_ini_params["host_name"] := nil
_ini_params["database"] := nil
_ini_params["user_name"] := nil
_ini_params["schema"] := nil
_ini_params["port"] := nil


if !f18_ini_read("F18_server", @_ini_params, .t.)
	// idemo na formu za logiranje
	__form_login()
endif

// definisi parametre servera
__server_params := hb_hash()

__server_params["host_name"] := _ini_params["host_name"]
__server_params["database"] := _ini_params["database"]
__server_params["user"] := _ini_params["user_name"]
__server_params["password"] := _ini_params["user_name"]
__server_params["port"] := VAL( _ini_params["port"] )
__server_params["schema"] := _ini_params["schema"]

// pokusaj se logirati kao user/user
my_server_login( my_server_params() )

// ~/.F18/empty38/
set_f18_home( my_server_params()["database"] )
log_write("home baze: " + my_home())

log_write( "direct login: " + ;
		my_server_params()["host_name"] + " / " + ;
		my_server_params()["database"] + " / " + ;
		my_server_params()["user"] + " / " +  ;
		STR(my_server_params()["port"])  + " / " + ; 
		my_server_params()["schema"])

if __server:NetErr()
	log_write( "Nisam se zakacio kao user/user, pokusat cu sa novim parmetrima !" )
	// idemo na login formu
	__form_login()
endif

dbf_update()
my_server(__server)

return .t.


static function __form_login()
local cHostName, cDatabase, cUser, cPassword, nPort, cSchema

// idemo na login formu

if f18_login_screen( @cHostname, @cDatabase, @cUser, @cPassword, @nPort, @cSchema ) = .f.
	log_write( "nesto nije uredu kod login forme" )
	quit
endif

__server_params := hb_hash()
__server_params["host_name"] := cHostName
__server_params["database"] := cDatabase
__server_params["user"] := cUser
__server_params["password"] := cPassword
__server_params["port"] := nPort
__server_params["schema"] := cSchema

my_server_login( my_server_params() )

log_write( "form login: " + ;
		my_server_params()["host_name"] + " / " + ;
		my_server_params()["database"] + " / " + ;
		my_server_params()["user"] + " / " +  ;
		STR(my_server_params()["port"])  + " / " + ;
		my_server_params()["schema"])

if __server:NetErr()
    
    log_write( "nisam se uspio zakaciti ni drugi put sa parametrima..." )  
	clear screen

  	?
  	? "Greska sa konekcijom na server:"
  	? "==============================="
  	? __server:ErrorMsg()

  	log_write( __server:ErrorMsg() )
  	inkey(0)
  	quit

endif


return


// ------------------
// set_get server
// ------------------
function pg_server(server)

if server <> NIL
   __server := server
endif
return __server

function my_server(server)
return pg_server(server)

// ----------------------------
// set_get server_params
// -------------------------------
function my_server_params(params)
local  _key

if params <> nil
   for each _key in params:Keys
       __server_params[_key] := params[_key]
   next
endif
return __server_params 

// --------------------------
// --------------------------
function my_server_login(params)

if params == NIL
   params := __server_params
endif

__server :=  TPQServer():New( params["host_name"], params["database"], params["user"], params["password"], params["port"], params["schema"] )


if !__server:NetErr()
	set_sql_search_path()
else
	log_write( "greska sa konekcijom na server: " + __server:ErrorMsg() )
endif

return __server

// --------------------------
// --------------------------
function my_server_logout()
__server:Close()

return __server

// -----------------------------
// -----------------------------
function my_server_search_path( path )
local _key := "search_path"

if path == nil
   if !hb_hhaskey(__server_params, _key)
     __server_params[_key] := "fmk,public"
   endif
else
   __server_params[_key] := path
endif

return __server_params[_key]


// -----------------------------
// -----------------------------
function f18_user()
return __server_params["user"]


function f18_database()
return __server_params["database"]


function my_user()
return f18_user()

// --------------------
// --------------------
function my_home(home)

if home != NIL
  __f18_home := home
endif

return __f18_home

// -----------------------------
// ------------------------------
function my_home_root(home_root)

if home_root != NIL
  __f18_home_root := home_root
endif

return __f18_home_root


// ----------------------------
// ----------------------------
function set_f18_home_root()
local home

#ifdef __PLATFORM__WINDOWS
  home := hb_DirSepAdd( GetEnv( "USERPROFILE" ) ) 
#else
  home := hb_DirSepAdd( GetEnv( "HOME" ) ) 
#endif

home := hb_DirSepAdd(home + ".f18")

f18_create_dir(home)

my_home_root(home)
return .t.


// ---------------------------
// ~/.F18/bringout1
// ~/.F18/rg1
// ~/.F18/test
// ---------------------------
function set_f18_home(database)
local _home 

if database <> nil
	_home := hb_DirSepAdd(my_home_root() + database)
	f18_create_dir( _home )
endif

my_home(_home)
return .t.


// -------------------------------
// -------------------------------
function log_write(msg)
 FWRITE(__log_handle, msg + hb_eol())
return

function log_close()
 FCLOSE(__log_handle)
return .t.

