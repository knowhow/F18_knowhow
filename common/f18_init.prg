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
#include "dbinfo.ch"

static __server := NIL
static __server_params := NIL

// logiranje na server
static __server_log := .f.

static __f18_home := NIL
static __f18_home_root := NIL
static __f18_home_backup := NIL

thread static __log_handle := NIL

static __my_error_handler := NIL
static __global_error_handler := NIL
static __test_mode := .f.
static __no_sql_mode := .f.

static __max_rows := 35
static __max_cols := 120

#ifdef  __PLATFORM__WINDOWS
    static __font_name := "Lucida Console"
    static __font_size := 20
    static __font_width := 10
#else

    #ifdef  __PLATFORM__LINUX
        static __font_name := "terminus"

        static __font_size  := 20
        static __font_width := 10

    #else
        static __font_name  := "ubuntu mono"
        static __font_size  := 30
        static __font_width := 15

    #endif

#endif

static __log_level := 3


// ---------------------------------
// 
// ---------------------------------
function f18_init_app( arg_v )
local oLogin

#ifdef NTX_INDICES
   REQUEST DBFNTX
   REQUEST DBFFPT
#else
  REQUEST DBFCDX
  REQUEST DBFFPT
#endif

#ifndef NODE
#ifdef __PLATFORM__WINDOWS

 // REQUEST HB_GT_WIN
 // REQUEST HB_GT_WIN_DEFAULT
 REQUEST HB_GT_WVT
 REQUEST HB_GT_WVT_DEFAULT
  
#else

  //REQUEST HB_GT_CRS_DEFAULT
  REQUEST HB_GT_XWC_DEFAULT

#endif
#endif

RDDSETDEFAULT( RDDENGINE )

Set( _SET_AUTOPEN, .f.  )
//Set( _SET_AUTOSHARE, 0  )
//SET DBFLOCKSCHEME TO DB_DBFLOCK_HB32
//SET DBFLOCKSCHEME TO DB_DBFLOCK_HB64 

init_harbour()

public gRj         := "N"
public gReadOnly   := .f.
public gSQL        := "N"
public gOModul     := NIL
public cDirPriv    := ""
public cDirRad     := ""
public cDirSif     := ""
public glBrojacPoKontima := .t.

set_f18_home_root()

log_create()

SetgaSDbfs()
set_global_vars_0()
PtxtSekvence()

__my_error_handler := { |objError| GlobalErrorHandler(objError, .f.) }

__global_error_handler := ERRORBLOCK(__my_error_handler)

set_screen_dimensions()

_get_log_level_from_config()

init_gui()

if no_sql_mode()
   set_f18_home("f18_test")
   return .t.
endif

// iniciraj logiranje
f18_init_app_login( NIL, arg_v )

return .t.




// -----------------------------------------------------
// inicijalne opcije kod pokretanja firme
// -----------------------------------------------------
function f18_init_app_opts()
// ovdje treba napraviti meni listu sa opcijama
// vpn, rekonfiguracija, itd... neke administraitvne opcije
// otvaranje nove firme...
local _opt := {}
local _optexe := {}
local _izbor := 1

AADD( _opc, hb_utf8tostr( "1. vpn konekcija                         " ))
AADD( _opcexe, { || NIL } )
AADD( _opc, hb_utf8tostr( "2. rekonfiguriši server  " ))
AADD( _opcexe, { || NIL } )
AADD( _opc, hb_utf8tostr( "3. otvaranje nove firme  " ))
AADD( _opcexe, { || NIL } )
// itd...

f18_menu( "mn", .f., _izbor, _opc, _opcexe  )

return .t.





// -----------------------------------------------------
// inicijalna login opcija
// -----------------------------------------------------
function f18_init_app_login( force_connect, arg_v )
local oLogin

if force_connect == NIL
    force_connect := .t.
endif

// nova login metoda - u izradi !!!!

_get_server_params_from_config()

oLogin := F18Login():New()
oLogin:main_db_login( @__server_params, force_connect )
__main_db_params := __server_params

if oLogin:_main_db_connected
  
    // 1 konekcija je na postgres i to je ok
    // ako je vec neka druga...
    if oLogin:_login_count > 1
        // ostvari opet konekciju na main_db postgres
        oLogin:disconnect()
        oLogin:main_db_login( @__server_params, .t. )
    endif
 
    // upisi parametre za sljedeci put... 
    _write_server_params_to_config()
    
    do while .t.
    
        if !oLogin:company_db_login( @__server_params )
            quit
        endif

        // upisi parametre tekuce firme... treba li nam ovo ??????
        _write_server_params_to_config()

        if oLogin:_company_db_connected 

            _show_info()
            post_login()
            f18_app_parameters( .t. )
            set_hot_keys()

            module_menu( arg_v )

        endif

    enddo

else
    // neko je rekao ESC
    quit
endif

return


static function _show_info()
local _x, _y
local _txt := ""

_x := ( MAXROWS() / 2 ) - 12
_y := MAXCOLS()
            
// ocisti ekran...            
CLEAR SCREEN
    
_txt := PADC( hb_utf8tostr( ". . .  S A Č E K A J T E    T R E N U T A K  . . ." ) , _y )
@ _x , 2 SAY _txt

_txt := PADC( ". . . . . . k o n e k c i j a    n a    b a z u   u   t o k u . . . . . . .", _y )
@ _x + 1 , 2 SAY _txt

return 



// prelazak iz sezone u sezonu
function f18_old_session()
local oLogin := F18Login():New()
oLogin:company_db_relogin( @__server_params )
return .t.





// -------------------------------
// init harbour postavke
// -------------------------------
function init_harbour()

SET CENTURY OFF
// epoha je u stvari 1999, 2000 itd
SET EPOCH TO 1960  
SET DATE TO GERMAN
REQUEST HB_CODEPAGE_SL852 
REQUEST HB_CODEPAGE_SLISO

hb_setTermCP("SLISO")
hb_CdpSelect("SL852")

SET DELETED ON

SETCANCEL(.f.)

set( _SET_EVENTMASK, INKEY_ALL )
mSetCursor( .t. )

return .t.



// ---------------------------------------------------------------
// ---------------------------------------------------------------
function set_screen_dimensions()
local _msg

local _pix_width  := hb_gtInfo( HB_GTI_DESKTOPWIDTH )
local _pix_height := hb_gtInfo( HB_GTI_DESKTOPHEIGHT)

_msg := "screen res: " + ALLTRIM(to_str(_pix_width)) + " " + ALLTRIM(to_str(_pix_height)) + " varijanta: "

#ifdef NODE
  return .t.
#endif

do CASE


  case _pix_width >= 1440 .and. _pix_height >= 900

     font_size(24)
     font_width(100)
     maxrows(35)
     maxcols(119)

     log_write( _msg + "1")

  case _pix_width >= 1280 .and. _pix_height >= 820

    #ifdef  __PLATFORM__DARWIN
       //font_name("Ubuntu Mono")
       font_name("ubuntu mono")
       font_size(24)
       font_width(12)
       maxrows(35)
       maxcols(110)
       log_write( _msg + "2longMac")
    #else

       font_size(24)
       font_width(100)
       maxrows(35)
       maxcols(105)


       log_write( _msg + "2long")
    #endif


  case _pix_width >= 1280 .and. _pix_height >= 800

     font_size(22)
     font_width(100)
     maxrows(35)
     maxcols(115)

     log_write( _msg + "2")

  case  _pix_width >= 1024 .and. _pix_height >= 768

     font_size(20)
     font_width(100)
     maxrows(35)
     maxcols(100)

     log_write( _msg + "3")

  otherwise

     // case _pix_width >= 800 .and. _pix_height >= 600

    /*
    font_size(18)
    font_width(9)

    maxrows(31)
    maxcols(80)
    */

    font_size(16)
    font_width(8)

    maxrows(35)
    maxcols(100)
     
    log_write( _msg + "4")

endcase


_get_screen_resolution_from_config()

hb_gtInfo( HB_GTI_FONTNAME , font_name())
hb_gtInfo( HB_GTI_FONTWIDTH, font_width())
hb_gtInfo( HB_GTI_FONTSIZE , font_size())

if setmode(maxrows(), maxcols())
   log_write( "setovanje ekrana: setovan ekran po rezoluciji" )
else
   log_write( "setovanje ekrana: ne mogu setovati ekran po trazenoj rezoluciji !" )
   QUIT_1
endif

return

#ifdef NODE

function f18_set_server_params(pars)
local _ret := hb_hash()

_ret["ret"] := 0

log_write("parametri: " + pp(pars))

__server_params := hb_hash()
__server_params["port"] := pars["port"]
__server_params["database"] := pars["database"]
__server_params["host"] := pars["host"]
__server_params["user"] := pars["user"]
__server_params["schema"] := pars["schema"]
__server_params["password"] := pars["password"]

return hb_jsonDecode(_ret)

function _get_server_params_from_config()
return

#else

#ifdef TEST 

function _get_server_params_from_config()

__server_params := hb_hash()
__server_params["port"] := 5432
__server_params["database"] := "f18_test"
__server_params["host"] := "localhost"
__server_params["user"] := "test1"
__server_params["schema"] := "fmk"
__server_params["password"] := __server_params["user"]
__server_params["postgres"] := "postgres"

return

#else

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
_ini_params["session"] := nil

if !f18_ini_read( F18_SERVER_INI_SECTION + IIF( test_mode(), "_test", ""), @_ini_params, .t. )
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
__server_params["postgres"] := "postgres"

return 
#endif

#endif
// --------------------------------------------------------
// --------------------------------------------------------
function _write_server_params_to_config()
local _key, _ini_params := hb_hash()

for each _key in { "host", "database", "user", "schema", "port", "session" }
    _ini_params[_key] := __server_params[_key] 
next

if !f18_ini_write( F18_SERVER_INI_SECTION + IIF( test_mode(), "_test", "" ), _ini_params, .t. )
    MsgBeep("problem ini write")
endif


// -------------------------------
// -------------------------------
function post_login( gvars )
local _ver
local oDB_lock := F18_DB_LOCK():New()
local _need_lock_synchro := .f.

if gvars == NIL
    gvars := .t.
endif

// da li treba zakljucati bazu
// ovo provjeri uvijek, ako naleti da treba zakljucat ce je odmah...
if oDb_lock:db_must_be_locked()
    // i ako ja zakljucam bazu, potrebno je napraviti sinhronizaciju podataka
    // postoji mogucnost da nikada nije napravljen...
    _need_lock_synchro := .t.
endif

// provjeri moj db_lock parametar
// ako je zakljucana na serveru
if oDB_lock:is_locked()
    if oDB_lock:run_synchro()
        MsgBeep( "Baza je zakljucana ali postoji mogucnost da je neko mjenjao podatake#Pokrecem sinhro." )
        _need_lock_synchro := .t.
    endif
else
    // resetuj moj lock param ako treba
    oDb_lock:reset_my_lock_params()
endif 

// ~/.F18/empty38/
set_f18_home( my_server_params()["database"] )
log_write("home baze: " + my_home())

#ifndef NODE
hb_gtInfo( HB_GTI_WINTITLE, "[ "+ my_server_params()["user"] + " ][ "+ my_server_params()["database"] +" ]" )

_ver := read_dbf_version_from_config()
#endif

// setuje u matricu sve tabele svih modula
set_a_dbfs()

#ifndef NODE
    // kreiranje tabela...
    cre_all_dbfs(_ver)
#endif

// inicijaliziraj "dbf_key_fields" u __f18_dbf hash matrici
set_a_dbfs_key_fields()

#ifndef NODE
write_dbf_version_to_config()
#endif

check_server_db_version()

__server_log := .t.

if gvars
    set_all_gvars()
endif

if !oDB_lock:is_locked() .or. _need_lock_synchro
    f18_init_semaphores()
endif

if _need_lock_synchro
    // setuj tekuci klijentski lock parametar
    oDB_lock:set_my_lock_params( .t. )
endif

set_init_fiscal_params()

// brisanje loga nakon logiranja...
f18_log_delete()

run_on_startup()

return .t.


// --------------------------------
// --------------------------------
function set_all_gvars()
public goModul

goModul := TFinMod():new()
goModul:setgvars()

goModul := TKalkMod():new()
goModul:setgvars()

goModul := TFaktMod():new()
goModul:setgvars()

return

// ------------------------------------------
// kreira sve potrbne indekse
// ------------------------------------------
function repair_dbfs()
local _ver

_ver := read_dbf_version_from_config()

cre_all_dbfs(_ver)

return

#ifdef NODE
 static function _get_log_level_from_config()
   log_level(7)
 return .t.

#else

// -----------------------------------------------------------
// vraca informaciju o nivou logiranja aplikcije
// -----------------------------------------------------------
static function _get_log_level_from_config()
local _var_name
local _ini_params := hb_hash()
local _section := "Logging"

_ini_params["log_level"] := nil

IF !f18_ini_read( _section, @_ini_params, .t. )
    MsgBeep("logging: problem sa ini read")
    return
ENDIF

// setuj varijable iz inija
IF _ini_params["log_level"] != nil
    log_level( VAL( _ini_params["log_level"] ) )
ENDIF

return .t.

#endif

// ------------------------------------------------------------
// vraca informacije iz inija vezane za screen rezoluciju
// ------------------------------------------------------------
static function _get_screen_resolution_from_config()
local _var_name

local _ini_params := hb_hash()

_ini_params["max_rows"] := nil
_ini_params["max_cols"] := nil
_ini_params["font_name"] := nil
_ini_params["font_width"] := nil
_ini_params["font_size"] := nil

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

_var_name := "font_width"
IF _ini_params[_var_name] != nil
    __font_width := VAL( _ini_params[_var_name] )
ENDIF

_var_name := "font_size"
IF _ini_params[_var_name] != nil
    __font_size := VAL( _ini_params[_var_name] )
ENDIF

return .t.

// ---------------------------------------
// vraca maksimalni broj redova
// ---------------------------------------
function maxrows(x)

if VALTYPE(x) == "N"
  __max_rows := x
endif

return __max_rows

// -----------------------------------
// vraca maksimalni broj kolona
// ----------------------------------
function maxcols(x)

if VALTYPE(x) == "N"
  __max_cols := x
endif

return __max_cols

// -------------------------
// -------------------------
function font_name(x)

if VALTYPE(x) == "C"
  __font_name := x
endif
return __font_name

// -------------------------
// -------------------------
function font_width(x)

if VALTYPE(x) == "N"
  __font_width := x
endif
return __font_width


// -------------------------
// -------------------------
function font_size(x)

if VALTYPE(x) == "N"
  __font_size := x
endif
return __font_size

// ----------------------------
// vraca nivo logiranja
// ----------------------------
function log_level(x)

if VALTYPE(x) == "N"
  __log_level := x
endif

#ifdef TEST
   return 7
#else
   return __log_level
#endif

// ------------------------------------------
// ------------------------------------------
static function f18_form_login( server_params )
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

local cHostname, cDatabase, cUser, cPassword, nPort, cSchema, cSession
local lSuccess := .t.   
local nX := 5
local nLeft := 7
local cConfigureServer := "N"

cHostName := server_params["host"]
cDatabase := server_params["database"]
cUser := server_params["user"]
cSchema := server_params["schema"]
nPort := server_params["port"]
cSession := server_params["session"]
cPassword := ""

if (cHostName == nil) .or. (nPort == nil)
    cConfigureServer := "D"
endif 

if cSession == NIL
    cSession := ALLTRIM( STR( YEAR( DATE() ) ) )
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
@ nX, 55 SAY "Sezona:" GET cSession

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
server_params["session"]  := cSession

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
function my_server_login( params, conn_type )
local _key, _server

if params == NIL
    params := __server_params
endif

if conn_type == NIL
    conn_type := 1
endif

for each _key in params:Keys
   if params[_key] == NIL
        if conn_type == 1
            log_write( "error server params key: " + _key )
        endif
        return .f.
   endif
next

_server := TPQServer():New( params["host"], ;
                        if( conn_type == 1, params["database"], "postgres" ), ;
                        params["user"], ;
                        params["password"], ;
                        params["port"], ;
                        if( conn_type == 1, params["schema"], "public" ) )

if !_server:NetErr()

    my_server( _server )

    if conn_type == 1
        set_sql_search_path()
        log_write( "server connection ok: " + params["user"] + " / " + if ( conn_type == 1, params["database"], "postgres" ) )
    endif

    return .t.

else

    if conn_type == 1
        log_write( "error server connection: " + _server:ErrorMsg() )
    endif

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


function f18_curr_session()
return __server_params["session"]


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


// -----------------------------
// ------------------------------
function my_home_backup(home_backup)

if home_backup != NIL
  __f18_home_backup := home_backup
endif

return __f18_home_backup



// ----------------------------
// ----------------------------
function set_f18_home_backup( database )
local _home := hb_DirSepAdd( my_home_root() + "backup" )

f18_create_dir( _home )

if database <> NIL
    _home := hb_DirSepAdd( _home + database )
    f18_create_dir( _home )
endif

my_home_backup( _home )

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


function test_mode(tm)
if tm != nil
  __test_mode := tm
endif

return __test_mode


function no_sql_mode(val)
if val != nil
  __no_sql_mode := val
endif

return __no_sql_mode



static function f18_no_login_quit()

log_write( "direct login: " + ;
        my_server_params()["host"] + " / " + ;
        my_server_params()["database"] + " / " + ;
        my_server_params()["user"] + " / " +  ;
        STR(my_server_params()["port"])  + " / " + ; 
        my_server_params()["schema"])

MsgBeep("Neuspješna prijava na server.")

log_close() 

QUIT_1

return

// ---------------
// ---------------
function relogin()
local oBackup := F18Backup():New()
local _ret := .f.

if oBackup:locked()
    MsgBeep( oBackup:backup_in_progress_info() )
    return _ret
endif

__server_log := .f.

my_server_logout()

_get_server_params_from_config()

if f18_form_login()
   post_login()
endif

_write_server_params_to_config()
_ret := .t.

return _ret


// -------------------------------
// -------------------------------
function log_write( msg, level, silent )
local _msg_time

if level == NIL
    // uzmi defaultni
    level := log_level()
endif

if silent == NIL
	silent := .f.
endif

// treba li logirati ?
if level > log_level() 
    return
endif

_msg_time := DTOC( DATE() ) 
_msg_time += ", " 
_msg_time += PADR( TIME(), 8 ) 
_msg_time += ": " 
 
// time ide samo u fajl, ne na server
// ovdje ima neki problem #30139 iskljucujem dok ne skontamo
// baca mi ove poruke u outf.txt
// FWRITE( __log_handle, _msg_time + msg + hb_eol() )

#ifndef TEST
#ifndef NODE
if __server_log
    server_log_write( msg, silent )
endif
#endif
#endif

return


function log_disable()
__server_log := .f.
return

function log_enable()
__server_log := .f.
return


// -------------------------------------------------
// -------------------------------------------------
function log_create()

if ( __log_handle := FCREATE(F18_LOG_FILE) ) == -1
    ? "Cannot create log file: " + F18_LOG_FILE
    QUIT_1
endif

return

// -------------------------------------------------
// -------------------------------------------------
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
// ----------------------------
function view_log()
local _cmd

_out_file := my_home() + "F18.log.txt"

FILECOPY( F18_LOG_FILE, _out_file)
_cmd := "f18_editor " + _out_file
f18_run(_cmd)

return .t.

// ------------------------------------------------
// ------------------------------------------------
function set_hot_keys()

SETKEY( K_SH_F1,{|| Calc() })
SETKEY( K_F3, {|| new_f18_session_thread() })
SETKEY( K_SH_F6, {|| f18_old_session() } )

return


// ---------------------------------------------
// pokreni odredjenu funkciju odmah na pocetku
// ---------------------------------------------
function run_on_startup()
local _ini, _fakt_doks

_ini := hb_hash()
_ini["run"] := ""

f18_ini_read("run" + IIF(test_mode(), "_test", ""), @_ini, .f.)

SWITCH (_ini["run"])
   CASE "fakt_pretvori_otpremnice_u_racun"
        _fakt_doks := FaktDokumenti():New()
        _fakt_doks:pretvori_otpremnice_u_racun()

END

