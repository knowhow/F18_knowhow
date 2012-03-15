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
#include "hbgtinfo.ch"
#include "hbcompat.ch"

thread static __server := NIL
thread static __server_params := NIL

static __f18_home := NIL
static __f18_home_root := NIL

thread static __log_handle := NIL

static __my_error_handler := NIL
static __global_error_handler := NIL
static __test_mode := .f.

static __max_rows := 40
static __max_cols := 140
static __font_name := "Lucida Console"

// ---------------------------------
// 
// ---------------------------------
function f18_init_app()

REQUEST DBFCDX
REQUEST DBFCDX

#ifdef __PLATFORM__WINDOWS

 // REQUEST HB_GT_WIN
 // REQUEST HB_GT_WIN_DEFAULT
 REQUEST HB_GT_WVT
 REQUEST HB_GT_WVT_DEFAULT
  
#else

  //REQUEST HB_GT_CRS_DEFAULT
  REQUEST HB_GT_XWC_DEFAULT

#endif

RDDSETDEFAULT( RDDENGINE )

REQUEST HB_CODEPAGE_SL852 
REQUEST HB_CODEPAGE_SLISO

hb_setCodePage("SL852" )
hb_setTermCP("SLISO")
hb_CdpSelect("SL852")


SET DELETED ON

SETCANCEL(.f.)


set( _SET_EVENTMASK, INKEY_ALL )
mSetCursor( .t. )

public gRj         := "N"
public gReadOnly   := .f.
public gSQL        := "N"
public Invert      := .f.
public gOModul     := NIL
public cDirPriv    := ""
public cDirRad     := ""
public cDirSif     := ""
public glBrojacPoKontima := .t.

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

PtxtSekvence()

__my_error_handler := { |objError| GlobalErrorHandler(objError, .f.) }

__global_error_handler := ERRORBLOCK(__my_error_handler)

_get_screen_resolution_from_config()

hb_gtInfo( HB_GTI_FONTNAME , font_name())

if setmode(maxrows(), maxcols())
   log_write( "setovanje ekrana: setovan ekran po rezoluciji" )
else
   log_write( "setovanje ekrana: ne mogu setovati ekran po trazenoj rezoluciji !" )
   QUIT
endif


_get_server_params_from_config()

// pokusaj se logirati kao user/user
if !my_server_login()
    // ako ne prikazi formu za unos
    f18_form_login()
endif

_write_server_params_to_config() 

post_login()

return .t.


// -------------------------------------
// -------------------------------------
function _get_server_params_from_config()
local _key, _ini_params

// ucitaj parametre iz inija, ako postoje ...
_ini_params := hb_hash()
_ini_params["host"] := nil
_ini_params["database"] := nil
_ini_params["user"] := nil
_ini_params["schema"] := nil
_ini_params["port"] := nil

if !f18_ini_read(F18_SERVER_INI_SECTION + IIF(test_mode(), "_test", ""), @_ini_params, .t.)
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

return 

// --------------------------------------------------------
// --------------------------------------------------------
static function _write_server_params_to_config()
local _key, _ini_params := hb_hash()

for each _key in {"host", "database", "user", "schema", "port"}
    _ini_params[_key] := __server_params[_key] 
next

if !f18_ini_write(F18_SERVER_INI_SECTION + IIF(test_mode(), "_test", ""), _ini_params, .t.)
    MsgBeep("problem ini write")
endif

// -------------------------------
// -------------------------------
function post_login()
local _ver

// ~/.F18/empty38/
set_f18_home( my_server_params()["database"] )
log_write("home baze: " + my_home())

_ver := read_dbf_version_from_config()

cre_all_dbfs(_ver)

write_dbf_version_to_config()

check_server_db_version()

return .t.


// ------------------------------------------------------------
// vraca informacije iz inija vezane za screen rezoluciju
// ------------------------------------------------------------
static function _get_screen_resolution_from_config()
local _ini_params := hb_hash()

_ini_params["max_rows"] := nil
_ini_params["max_cols"] := nil
_ini_params["font_name"] := nil

IF !f18_ini_read( F18_SCREEN_INI_SECTION, @_ini_params, .t. )
    MsgBeep("screen resolution: problem sa ini read")
    return
ENDIF

// setuj varijable iz inija
IF _ini_params["max_rows"] != nil
    __max_rows := VAL( _ini_params["max_rows"] )
ENDIF

IF _ini_params["max_cols"] != nil
    __max_cols := VAL( _ini_params["max_cols"] )
ENDIF

IF _ini_params["font_name"] != nil
    __font_name := _ini_params["font_name"]
ENDIF


return .t.


// vraca maksimalni broj redova
function maxrows()
return __max_rows


// vraca maksimalni broj kolona
function maxcols()
return __max_cols

function font_name()
return __font_name

// ------------------------------------------
// ------------------------------------------
static function f18_form_login(server_params)
local _ret
local _server

if server_params == NIL
   server_params := __server_params
endif

do while .t.

    if !_login_screen(@server_params)
         f18_no_login_quit()
         return .f.
    endif

    if my_server_login( server_params )
         log_write( "form login succesfull: " + server_params["host"] + " / " + server_params["database"] + " / " + server_params["user"] + " / " + STR(my_server_params()["port"])  + " / " + server_params["schema"])
         exit
    else
       Beep(4)
    endif

enddo

return .t.


// ------------------------------------------
// ------------------------------------------
static function _login_screen(server_params)

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
  cDatabase := "f18_test"
endif

if cUser == nil
  cUser := "test1"
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

cHostName := ALLTRIM( cHostname )
cUser     := ALLTRIM( cUser )

// omogucice da se korisnici user=password jednostavno logiraju
if EMPTY(cPassword)
   cPassword := cUser
else
   cPassword := ALLTRIM( cPassword )
endif 
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
       log_write("error server params key: " + _key)
       return .f.
   endif
next

_server :=  TPQServer():New( params["host"], params["database"], params["user"], params["password"], params["port"], params["schema"] )

if !_server:NetErr()
    my_server(_server)
    set_sql_search_path()
    log_write("server connection ok: " + params["user"] + " / " + params["database"])
    return .t.
else
    log_write("error server connection: " + _server:ErrorMsg())
    return .f.
endif

// --------------------------
// --------------------------
function my_server_logout()

if VALTYPE(__server) == "O"
 __server:Close()
endif

return __server

// -----------------------------
// -----------------------------
function my_server_search_path( path )
local _key := "search_path"

if path == nil
   if !hb_hhaskey(__server_params, _key)
     __server_params[_key] := "fmk, public, u2"
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

// ----------------------------
// ----------------------------
function _path_quote(path)

if (AT(path, " ") != 0) .and. (AT(PATH, '"') == 0)
  altd()
  return  '"' + path + '"'
else
  return path
endif



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

function my_error_handler()
return  __my_error_handler

function global_error_handler()
return  __global_error_handler

function dummy_error_handler()
return {|err| BREAK(err) }

function  test_mode(tm)
if tm != nil
  __test_mode := tm
endif

return __test_mode

static function f18_no_login_quit()

log_write( "direct login: " + ;
        my_server_params()["host"] + " / " + ;
        my_server_params()["database"] + " / " + ;
        my_server_params()["user"] + " / " +  ;
        STR(my_server_params()["port"])  + " / " + ; 
        my_server_params()["schema"])

MsgBeep(hb_Utf8ToStr("Neuspješna prijava na server."))

log_close() 

QUIT

return

// ---------------
// ---------------
function relogin()

my_server_logout()

_get_server_params_from_config()
if f18_form_login()
   post_login()
endif
_write_server_params_to_config()

return .t.


// -------------------------------
// -------------------------------
function log_write(msg)
 FWRITE(__log_handle, msg + hb_eol())
return

function log_close()
 FCLOSE(__log_handle)
return .t.


// ----------------------------------
// ----------------------------------
function log_handle(handle)

if handle != NIL
  __log_handle := handle
endif

return __log_handle


// ----------------------------
//
// ----------------------------
function view_log()
local _cmd

_out_file := my_home() + "F18.log.txt"

FILECOPY( F18_LOG_FILE, _out_file)
run (_cmd := "f18_editor " + _out_file)

return .t.
