/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"
#include "hbthread.ch"
#include "hbclass.ch"
#include "hbgtinfo.ch"
#include "common.ch"


CLASS F18Backup

    METHOD New()

    METHOD Backup_now()
    
    METHOD Backup_company()
    METHOD Backup_server()

    METHOD backup_to_removable()

    METHOD backup_in_progress_info()
    
    METHOD get_backup_path()
    METHOD get_backup_interval()
    METHOD get_backup_type()
    METHOD get_backup_filename()
    METHOD get_last_backup_date()
    METHOD set_last_backup_date()
    METHOD get_removable_drive()
    METHOD get_windows_ping_time()

    METHOD lock()
    METHOD unlock()
    METHOD locked()

    DATA backup_path
    DATA backup_filename
    DATA backup_interval
    DATA backup_type
    DATA last_backup
    DATA removable_drive
    DATA ping_time

ENDCLASS




METHOD F18Backup:New()

::backup_interval := 0
::last_backup := CTOD("")
::removable_drive := ""
::ping_time := 0

return SELF



METHOD F18Backup:backup_in_progress_info()
local _txt
_txt := "Operacija backup-a u toku. Pokusajte ponovo..."
return _txt



METHOD F18Backup:Backup_now( auto )

if auto == NIL
    auto := .t.
endif

// da li je backup vec pokrenut ? 
if ::locked( .t. )
    if Pitanje(, "Napravi unlock backup operacije (D/N)?", "N" ) == "D"
    else
        return .f.
    endif
else
    //zakljucaj opciju backup-a da je samo jedan korisnik radi
    ::lock()
endif

if ::backup_type == 1
    ::Backup_company()
else
    ::Backup_server()
endif

if auto
    // setuj datum kreiranja backup-a
    ::set_last_backup_date()
endif

// otkljucaj nakon sto je backup napravljen
::unlock()

return .t.




METHOD F18Backup:Backup_company()
local _ok := .f.
local _cmd := ""
local _server_params := my_server_params()
local _host := _server_params["host"]
local _port := _server_params["port"]
local _database := _server_params["database"]
local _admin_user := "admin"
local _x := 7
local _y := 2
local _i, _backup_file
local _color_ok := "W+/B+"
local _color_err := "W+/R+"
local _line := REPLICATE( "-", 70 )

// daj naziv fajla backup-a
::get_backup_filename()
::get_windows_ping_time()

// pobrisi mi backup file prije svega...
// mozda vec postoji jedan
FERASE( ::backup_path + ::backup_filename )
sleep(1)

// setuj env.varijable
#ifdef __PLATFORM__UNIX
    _cmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
    _cmd += "set pgusername=admin&set PGPASSWORD=boutpgmin&"

    if ::ping_time > 0
        // dodaj ping na komandu za backup radi ENV varijabli
        _cmd += "ping -n " + ALLTRIM(STR( ::ping_time )) + " 8.8.8.8&"
    endif

#endif

_backup_file := ::backup_path + ::backup_filename

#ifdef __PLATFORM__WINDOWS
    _backup_file := STRTRAN( _backup_file, "\", "//" )
#endif

_cmd += "pg_dump"
_cmd += " -h " + ALLTRIM( _host )
_cmd += " -p " + ALLTRIM( STR( _port ) )
_cmd += " -U " + ALLTRIM( _admin_user )
_cmd += " -w "
_cmd += " -F c "
_cmd += " -b "
_cmd += ' -f "' + _backup_file + '"'
_cmd += ' "' + _database + '"'

@ _x, _y SAY "Obavjestenje: nakon pokretanja procedure backup-a slobodno se prebacite"
    
++_x
@ _x, _y SAY "              na prozor aplikacije i nastavite raditi."

++ _x
@ _x, _y SAY _line

++ _x
@ _x, _y SAY "Backup podataka u toku...."

++ _x
@ _x, _y SAY _line

++ _x
@ _x, _y SAY "  Lokacija backup-a: " + ::backup_path

++ _x
@ _x, _y SAY "Naziv fajla backupa: " + ::backup_filename

++ _x
++ _x
@ _x, _y SAY "ocekujem rezulat operacije... "

// pokreni komandu
#ifdef __PLATFORM__WINDOWS
    f18_run( _cmd )
#else
    hb_run( _cmd )
#endif

if FILE( ::backup_path + ::backup_filename )
    @ _x, col() + 1 SAY "OK" COLOR _color_ok
    _ok := .t.
else
    @ _x, col() + 1 SAY "ERROR !!!" COLOR _color_err
endif

if _ok

    log_write( "backup company kreiran uspjesno: " + ::backup_path + ::backup_filename, 6 )

    ++ _x
    @ _x, _y SAY "Prebacujem backup na removable drive... "

    if ::backup_to_removable()
        @ _x, col() SAY "OK" COLOR _color_ok
    else
        @ _x, col() SAY "ERROR" COLOR _color_err
    endif

endif

++ _x

for _i := 10 to 1 STEP -1
    @ _x, _y SAY "... izlazim za " + PADL( ALLTRIM( STR( _i ) ), 2 ) + " sekundi"
    sleep(1)
next

return _ok






METHOD F18Backup:Backup_server()
local _ok := .f.
local _cmd := ""
local _server_params := my_server_params()
local _host := _server_params["host"]
local _port := _server_params["port"]
local _database := _server_params["database"]
local _admin_user := "admin"
local _x := 7
local _y := 2
local _i, _backup_file
local _line := REPLICATE( "-", 70 )
local _color_ok := "W+/B+"
local _color_err := "W+/R+"

// daj mi naziv fajla backup-a
::get_backup_filename()
::get_windows_ping_time()

// pobrisi mi backup file prije svega...
// mozda vec postoji jedan
FERASE( ::backup_path + ::backup_filename )
sleep(1)

// setuj env.varijable
#ifdef __PLATFORM__UNIX
    _cmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
    _cmd += "set pgusername=admin&set PGPASSWORD=boutpgmin&"

    if ::ping_time > 0
        // dodaj ping na komandu za backup radi ENV varijabli
        _cmd += "ping -n " + ALLTRIM(STR( ::ping_time )) + " 8.8.8.8&"
    endif

#endif

_backup_file := ::backup_path + ::backup_filename

#ifdef __PLATFORM__WINDOWS
    _backup_file := STRTRAN( _backup_file, "\", "//" )
#endif

_cmd += "pg_dumpall"
_cmd += " -h " + ALLTRIM( _host )
_cmd += " -p " + ALLTRIM( STR( _port ) )
_cmd += " -U " + ALLTRIM( _admin_user )
_cmd += " -w "
_cmd += ' -f "' + _backup_file + '"'

@ _x, _y SAY "Obavjestenje: nakon pokretanja procedure backup-a slobodno se prebacite"
    
++_x
@ _x, _y SAY "              na prozor aplikacije i nastavite raditi."

++ _x
@ _x, _y SAY _line

++ _x
@ _x, _y SAY "Backup podataka u toku...."

++ _x
@ _x, _y SAY REPLICATE( "=", 70 )

++ _x
@ _x, _y SAY "   Lokacija backupa: " + ::backup_path
++ _x
@ _x, _y SAY "Naziv fajla backupa: " + ::backup_filename


++ _x
++ _x
@ _x, _y SAY "ocekujem rezulat operacije... "

// pokreni komandu
#ifdef __PLATFORM__WINDOWS
    f18_run( _cmd )
#else
    hb_run( _cmd )
#endif

if FILE( ::backup_path + ::backup_filename )
    @ _x, col() + 1 SAY "OK" COLOR _color_ok
    _ok := .t.
else
    @ _x, col() + 1 SAY "ERROR !!!" COLOR _color_err
endif

if _ok
    
    log_write( "backup kreiran uspjesno: " + ::backup_path + ::backup_filename , 6 )

    // prebaci i na removable ako treba...
    ++ _x
    @ _x, _y SAY "Prebacujem backup na removable drive... "

    if ::backup_to_removable()
        @ _x, col() SAY "OK" COLOR _color_ok
    else
        @ _x, col() SAY "ERROR" COLOR _color_err
    endif

endif

++ _x

for _i := 10 to 1 STEP -1
    @ _x, _y SAY "... izlazim za " + PADL( ALLTRIM( STR( _i ) ), 2 ) + " sekundi"
    sleep(1)
next

return _ok


// -----------------------------------------------------------
// kreiranje backup fajla na removeble drive
// -----------------------------------------------------------

METHOD F18Backup:backup_to_removable()
local _ok := .f.
local _res

::get_removable_drive()

// nema se sta raditi
if EMPTY( ::removable_drive )
    return _ok
endif

_res := FILECOPY( ::backup_path + ::backup_filename, ::removable_drive + ::backup_filename )
sleep(1)

if !FILE( ::removable_drive + ::backup_filename )
    //MsgBeep( "Nisam uspio prebaciti backup na lokaciju " + ::removable_drive + ::backup_filename )
else
    log_write( "backup to removable drive ok", 6 )
    _ok := .t.
endif

return _ok


METHOD F18Backup:get_windows_ping_time()
::ping_time := fetch_metric( "backup_windows_ping_time", my_user(), 0 )
return .t.




METHOD F18Backup:get_removable_drive()
::removable_drive := fetch_metric( "backup_removable_drive", my_user(), "" )
return .t.



METHOD F18Backup:get_backup_path()
local _path
local _database

if ::backup_type == 0
    set_f18_home_backup()
    ::backup_path := my_home_backup()
else
    _database := my_server_params()["database"]
    set_f18_home_backup( _database )
    ::backup_path := my_home_backup()
endif

return .t.






METHOD F18Backup:get_backup_filename()
local _name
local _tmp
local _server_params := my_server_params() 
local _i

_tmp := "server"

if ::backup_type == 1
    _tmp := ALLTRIM( _server_params["database"] )
endif

for _i := 1 to 99

    // comp: firma_2013_01.01.2013_01.backup
    // serv: server_01.01.2013_01.backup

    _name := _tmp + "_" + DTOC( DATE() ) + "_" + PADL( ALLTRIM( STR( _i ) ), 2, "0" ) + ".backup"

    // ako fajl ne postoji, imamo ga !
    if !FILE( ::backup_path + _name )
        exit
    endif

next

::backup_filename := _name

return _name





// ---------------------------------------------------------
// get backup interval
// ---------------------------------------------------------
METHOD F18Backup:get_backup_interval()
local _param := "backup_company_interval"

if ::backup_type == 0
    _param := "backup_server_interval"
endif

::backup_interval := fetch_metric( _param, my_user(), 0 )

return .t.




// ---------------------------------------------------------
// backup type
// ---------------------------------------------------------
METHOD F18Backup:get_backup_type( backup_type )
local _type := 1
local _x := 1
local _y := 2
local _s_line := REPLICATE( "-", 60 )
local _d_line := REPLICATE( "=", 60 )

if backup_type == NIL

    @ _x, _y SAY "*** BACKUP procedura *** " + DTOC( DATE() )

    ++ _x
    @ _x, _y SAY _d_line

    ++ _x
    @ _x, _y SAY "Dostupne opcije:"
    
    ++ _x
    @ _x, _y SAY "   1 - backup tekuce firme"
    
    ++ _x
    @ _x, _y SAY "   0 - backup kompletnog servera"

    ++ _x
    @ _x, _y SAY "Vas odabir:" GET _type VALID _type >= 0 PICT "9"

    ++ _x
    @ _x, _y SAY _s_line

    read

    if LastKey() == K_ESC
        return .f.
    endif

else
    _type := backup_type 
endif

::backup_type := _type

return .t.


// ---------------------------------------------------------
// backup locking system
// ---------------------------------------------------------
METHOD F18Backup:lock()
set_metric("f18_my_backup_lock_status", my_user(), 1 )
return .t.


METHOD F18Backup:unlock()
set_metric("f18_my_backup_lock_status", my_user(), 0 )
return .t.


METHOD F18Backup:locked( info )
local _ret := .f.
local _lock := fetch_metric( "f18_my_backup_lock_status", my_user(), 0 )

if info == NIL
    info := .f.
endif

if _lock > 0

    if info
        MsgBeep( "Operacija backup-a vec pokrenuta !#Prekidam operaciju !" )
    endif

    _ret := .t.

endif

return _ret




// ---------------------------------------------------------
// set/get backup date
// ---------------------------------------------------------
METHOD F18Backup:set_last_backup_date()
local _type := "company"

if ::backup_type == 0
    _type := "server"
endif

set_metric( "f18_backup_date_" + _type, my_user(), DATE() )
return .t.


METHOD F18Backup:get_last_backup_date()
local _type := "company"

if ::backup_type == 0
    _type := "server"
endif

::last_backup := fetch_metric( "f18_backup_date_" + _type, my_user(), CTOD("") )
return 





// ------------------------------------------------
// poziv backupa podataka sa menija...
// ------------------------------------------------
function f18_backup_data()
hb_threadStart( @f18_backup_data_thread(), NIL )
return





// ------------------------------------------------
// poziv backupa podataka automatski...
// jednostavno napravimo pozive
//
//   f18_auto_backup_data(0)
//   f18_auto_backup_data(1)
//
// ------------------------------------------------
function f18_auto_backup_data( backup_type_def, start_now )
local oBackup
local _curr_date := DATE()
local _last_backup

if backup_type_def == NIL
    backup_type_def := 1
endif

if start_now == NIL
    start_now := .f.
endif

oBackup := F18Backup():New()
oBackup:get_backup_type( backup_type_def )
oBackup:get_backup_interval()
oBackup:get_last_backup_date()

// nemam sta raditi ako ovaj interval ne postoji !
if !start_now .and. oBackup:backup_interval == 0
    return
endif

// uslov za backup nije zadovoljen...
if ( !start_now .and. ( _curr_date - oBackup:backup_interval ) > oBackup:last_backup ) .or. start_now
    hb_threadStart( @f18_backup_data_thread(), backup_type_def )
endif

return





function f18_backup_data_thread( type_def )
local oBackup
local auto_backup := .t.

#ifdef  __PLATFORM__WINDOWS
    _w := hb_gtCreate("WVT")
#else
    _w := hb_gtCreate("XWC")
#endif

if type_def == NIL
    auto_backup := .f.
endif

hb_gtSelect( _w )
hb_gtReload( _w )

// globalne varijable, bitne za neke funkcije...
set_global_vars_0()

// podesi boje...
_set_color()

oBackup := F18Backup():New()

if oBackup:get_backup_type( type_def )

    oBackup:get_backup_path()
    oBackup:get_backup_interval()
    // pokreni backup
    oBackup:Backup_now( auto_backup )

    QUIT

endif

return

// ------------------------------------------------------
// setovanje boje ekrana za backup...
// ------------------------------------------------------
static function _set_color()
local _color := "N/W"
SETCOLOR( _color )
CLEAR SCREEN
return



