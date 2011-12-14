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
static __my_error_handler := NIL
static __global_error_handler := NIL

#include "fmk.ch"

// -------------------------
// -------------------------
function f18_init_app()
local _ini_params
local _key

REQUEST DBFCDX

// ? "setujem default engine ..." + RDDENGINE
RDDSETDEFAULT( RDDENGINE )

REQUEST HB_CODEPAGE_SL852 
REQUEST HB_CODEPAGE_SLISO

SET DELETED ON

SETCANCEL(.f.)

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

SET DATE TO GERMAN

log_write("== F18 start: " + hb_ValToStr(DATE()) + " / " + hb_ValToStr(TIME()) + " ==")
SetgaSDbfs()
set_global_vars_0()
set_a_dbfs()


__my_error_handler := { |objError| GlobalErrorHandler(objError, .f.) }

__global_error_handler := ERRORBLOCK(__my_error_handler)


// ucitaj parametre iz inija, ako postoje ...
_ini_params := hb_hash()
_ini_params["host"] := nil
_ini_params["database"] := nil
_ini_params["user"] := nil
_ini_params["schema"] := nil
_ini_params["port"] := nil

if !f18_ini_read(F18_SERVER_INI_SECTION, @_ini_params, .t.)
   MsgBeep("problem ini read")
endif

// definisi parametre servera
__server_params := hb_hash()

// preuzmi iz ini-ja
for each _key in _ini_params:Keys
   __server_params[_key] := _ini_params[_key]
next
// port je numeric
if VALTYPE(__server_params["port"]) == "C"
  __server_params["port"] := VAL(__server_params["port"])
endif
__server_params["password"] := __server_params["user"]

if !my_server_login()
    // pokusaj se logirati kao user/user
 	_form_login(@__server_params)
endif


if my_server_login()

   for each _key in _ini_params:Keys
      _ini_params[_key] := __server_params[_key] 
   next
   if !f18_ini_write(F18_SERVER_INI_SECTION, _ini_params, .t.)
      MsgBeep("problem ini write")
   endif


   // ~/.F18/empty38/
   set_f18_home( my_server_params()["database"] )
   log_write("home baze: " + my_home())

   
   dbf_update()
   return .t.
else

   log_write( "direct login: " + ;
		my_server_params()["host"] + " / " + ;
		my_server_params()["database"] + " / " + ;
		my_server_params()["user"] + " / " +  ;
		STR(my_server_params()["port"])  + " / " + ; 
		my_server_params()["schema"])

   MsgBeep("Ne mogu se prijaviti na server !##Za detalje pogledajte log: " + F18_LOG_FILE)
   log_close() 
   QUIT
endif

return .f.


// ---------------------------
// ---------------------------
static function _form_login(server_params)
local _server

if ! f18_login_screen(@server_params) 
	return .f.
endif

if my_server_login( server_params )

  log_write( "form login: " + ;
		server_params["host"] + " / " + ;
		server_params["database"] + " / " + ;
		server_params["user"] + " / " +  ;
		STR(my_server_params()["port"])  + " / " + ;
		server_params["schema"])
  return .t.
endif

return .f.

/*
    _server := my_server()
 
    log_write( "nisam se uspio zakaciti ni drugi put sa parametrima..." )  
	clear screen
  	?
  	? "Greska sa konekcijom na server:"
  	? "==============================="
    
    if _server != NIL
  	  ? _server:ErrorMsg()
  	  log_write( _server:ErrorMsg() )
    endif

  	inkey(0)
  	quit
*/


// f18, login screen
function f18_login_screen(server_params)

local cHostname, cDatabase, cUser, cPassword, nPort, cSchema
local lSuccess := .t.	
local nX := 5
local nLeft := 7
local cConfigureServer := "N"

cHostName := server_params["host"]
cDatabase := server_params["database"]
cUser := server_params["user"]
cSchema := server_params["schema"]
nPort := server_params["port"]
cPassword := ""

if (cHostName == nil) .or. (nPort == nil)
	cConfigureServer := "D"
endif 

if cHostName == nil
   cHostName := "localhost"
endif

if nPort == nil
   nPort := 5432
endif

if cSchema == nil
  cSchema := "fmk"
endif

if cDatabase == nil
  cDatabase := "bringout"
endif

if cUser == nil
  cUser := "admin"
endif

cSchema   := PADR(cSchema, 40)
cDatabase := PADR(cDatabase, 100)
cHostName := PADR(cHostName, 100)
cUser     := PADR(cUser, 100)
cPassword := PADR(cPassword, 100 )

clear screen

@ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

++ nX

@ nX, nLeft SAY PADC("***** Unestite podatke za pristup *****", 60)

++ nX
++ nX
@ nX, nLeft SAY PADL( "Konfigurisati server ?:", 21 ) GET cConfigureServer VALID cConfigureServer $ "DN" PICT "@!"
++ nX 

read

if cConfigureServer == "D"
	++ nX
	@ nX, nLeft SAY PADL( "Server:", 8 ) GET cHostname PICT "@S20"
	@ nX, 37 SAY "Port:" GET nPort PICT "9999"
	@ nX, 48 SAY "Shema:" GET cSchema PICT "@S15"
else	
	++ nX
endif

++ nX
++ nX

@ nX, nLeft SAY PADL( "Baza:", 15 ) GET cDatabase PICT "@S30"

++ nX
++ nX

@ nX, nLeft SAY PADL( "KORISNIK:", 15 ) GET cUser PICT "@S30"

++ nX
++ nX

@ nX, nLeft SAY PADL( "LOZINKA:", 15 ) GET cPassword PICT "@S30" COLOR "BG/BG"

read

if Lastkey() == K_ESC
	return .f.
endif

// podesi varijable
cHostName := ALLTRIM( cHostname )
cUser     := ALLTRIM( cUser )
cPassword := ALLTRIM( cPassword )
cDatabase := ALLTRIM( cDatabase )
cSchema   := ALLTRIM( cSchema )

server_params["host"]      := cHostName
server_params["database"]  := cDatabase
server_params["user"]      := cUser
server_params["schema"]    := cSchema 
server_params["port"]      := nPort
server_params["password"]  := cPassword

return lSuccess




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
local _key, _server

if params == NIL
   params := __server_params
endif

for each _key in params:Keys
   if params[_key] == NIL
       return .f.
   endif
next

_server :=  TPQServer():New( params["host"], params["database"], params["user"], params["password"], params["port"], params["schema"] )

if !_server:NetErr()
    my_server(_server)
	set_sql_search_path()
    return .t.
else
    return .f.
endif

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

function my_error_handler()
return  __my_error_handler

function global_error_handler()
return  __global_error_handler

