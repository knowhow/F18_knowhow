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
#include "common.ch"


CLASS F18Backup

    METHOD New()

    METHOD Backup_data()
    
    METHOD Backup_company()
    METHOD Backup_server()

    METHOD backup_to_removable()
    
    METHOD get_backup_path()
    METHOD get_backup_interval()
    METHOD get_backup_type()
    METHOD get_backup_filename()
    METHOD get_last_backup_date()
    METHOD set_last_backup_date()
    METHOD get_removable_drive()

    METHOD lock()
    METHOD unlock()
    METHOD locked()

    DATA backup_path
    DATA backup_filename
    DATA backup_interval
    DATA backup_type
    DATA last_backup
    DATA removable_drive

ENDCLASS




METHOD F18Backup:New()

::backup_interval := 0
::last_backup := CTOD("")
::removable_drive := ""

return SELF




METHOD F18Backup:Backup_data()

// da li vec neko koristi opciju backup-a
//if ::locked( .t. )
  //  if Pitanje(, "Napravi unlock operacije (D/N)?", "N" ) == "D"
    //    ::unlock()
  //  else
    //    return .f.
  //  endif
//else
    // zakljucaj opciju backup-a da je samo jedan korisnik radi
  //  ::lock()
//endif

if ::backup_type == 1
    ::Backup_company()
else
    ::Backup_server()
endif

// setuj datum kreiranja backup-a
::set_last_backup_date()

// otkljucaj nakon sto je backup napravljen
//::unlock()

return .t.




METHOD F18Backup:Backup_company()
local _ok := .f.
local _cmd := ""
local _server_params := my_server_params()
local _host := _server_params["host"]
local _port := _server_params["port"]
local _database := _server_params["database"]
local _admin_user := "admin"
local _backup_file := ::backup_path + ::get_backup_filename()
local _x := 10
local _y := 2
local _i
local _color_ok := "W+/B+"
local _color_err := "W+/R+"

// pobrisi mi backup file prije svega...
// mozda vec postoji jedan
FERASE( _backup_file )
sleep(1)

// setuj env.varijable
#ifdef __PLATFORM__UNIX
    _cmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
    _cmd += "set pgusername=admin & set PGPASSWORD=boutpgmin & "
#endif

_cmd += "pg_dump"
_cmd += " -h " + ALLTRIM( _host )
_cmd += " -p " + ALLTRIM( STR( _port ) )
_cmd += " -U " + ALLTRIM( _admin_user )
_cmd += " -w "
_cmd += " -F t "
_cmd += " -b "
_cmd += ' -f "' + _backup_file + '"'
_cmd += ' "' + _database + '"'

@ _x, _y SAY "Backup podataka u toku...."

++ _x
@ _x, _y SAY REPLICATE( "=", 70 )

++ _x
@ _x, _y SAY "Naziv fajla backupa: " + _backup_file

++ _x
++ _x
@ _x, _y SAY "ocekujem rezulata operacije... "

// pokreni komandu
hb_run( _cmd )

if FILE( _backup_file )
    @ _x, col() + 1 SAY "OK" COLOR _color_ok
    _ok := .t.
else
    @ _x, col() + 1 SAY "ERROR !!!" COLOR _color_err
endif

if _ok
    ++ _x
    @ _x, _y SAY "Prebacujem backup na removable drive ..."
    ::backup_to_removable()
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
local _backup_file := ::backup_path + ::get_backup_filename()
local _x := 10
local _y := 2
local _i
local _color_ok := "W+/B+"
local _color_err := "W+/R+"

// pobrisi mi backup file prije svega...
// mozda vec postoji jedan
FERASE( _backup_file )
sleep(1)

// setuj env.varijable
#ifdef __PLATFORM__UNIX
    _cmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
    _cmd += "set pgusername=admin & set PGPASSWORD=boutpgmin & "
#endif

_cmd += "pg_dumpall"
_cmd += " -h " + ALLTRIM( _host )
_cmd += " -p " + ALLTRIM( STR( _port ) )
_cmd += " -U " + ALLTRIM( _admin_user )
_cmd += " -w "
_cmd += ' -f "' + _backup_file + '"'

@ _x, _y SAY "Backup podataka u toku...."

++ _x
@ _x, _y SAY REPLICATE( "=", 70 )

++ _x
@ _x, _y SAY "Naziv fajla backupa: " + _backup_file

++ _x
++ _x
@ _x, _y SAY "ocekujem rezulata operacije... "

// pokreni komandu
hb_run( _cmd )

if FILE( _backup_file )
    
    @ _x, col() + 1 SAY "OK" COLOR _color_ok
    _ok := .t.

else

    @ _x, col() + 1 SAY "ERROR !!!" COLOR _color_err

endif

if _ok
    // prebaci i na removable ako treba...
    ++ _x
    @ _x, _y SAY "Prebacujem backup na removable drive ..."
    ::backup_to_removable()
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
local _cmd

::get_removable_drive()

// nema se sta raditi
if EMPTY( ::removable_drive )
    return _ok
endif

#ifdef __PLATFORM__UNIX
    _cmd := "cp " + ::backup_path + ::backup_filename + " " + ::removable_drive 
#else
    _cmd := "copy /y " + ::backup_path + ::backup_filename + " " + ::removable_drive 
#endif

hb_run( _cmd )

if !FILE( ::removable_drive + ::backup_filename )
    MsgBeep( "Nisam uspio prebaciti backup na lokaciju " + ::removable_drive + ::backup_filename )
else
    _ok := .t.
endif

return _ok


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
local _name := "backup_" + DTOC( DATE() ) + ".backup"
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

    @ _x, _y SAY "Obavjestenje: nakon pokretanja procedure backup-a slobodno se prebacite"
    
    ++_x
    @ _x, _y SAY "              na prozor aplikacije i nastavite raditi."

    ++ _x
    @ _x, _y SAY _s_line
    
    ++ _x
    @ _x, _y SAY "Dostupne opcije:"
    
    ++ _x
    @ _x, _y SAY "   1 - backup tekuce firme"
    
    ++ _x
    @ _x, _y SAY "   0 - backup kompletnog servera"

    ++ _x
    @ _x, _y SAY "Vas odabir:" GET _type VALID _type >= 0 PICT "9"

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
set_metric("f18_backup_user", NIL, my_user() )
return .t.


METHOD F18Backup:unlock()
set_metric("f18_backup_user", NIL, "" )
return .t.


METHOD F18Backup:locked( info )
local _ret := .f.
local _user := fetch_metric( "f18_backup_user", NIL, "" )

if info == NIL
    info := .f.
endif

if !EMPTY( _user )

    if info
        MsgBeep( "Backup pokrenut od strane korisnika: " + _user + "#Prekidam operaciju !" )
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
function f18_auto_backup_data( backup_type_def )
local oBackup
local _curr_date := DATE()
local _last_backup

if backup_type_def == NIL
    backup_type_def := 1
endif

oBackup := F18Backup():New()
oBackup:get_backup_type( backup_type_def )
oBackup:get_backup_interval()
oBackup:get_last_backup_date()

// nemam sta raditi ako ovaj interval ne postoji !
if oBackup:backup_interval == 0
    return
endif

// uslov za backup nije zadovoljen...
if ( _curr_date - oBackup:backup_interval ) > oBackup:last_backup
    hb_threadStart( @f18_backup_data_thread(), backup_type_def )
endif

return





function f18_backup_data_thread( type_def )
local oBackup

#ifdef  __PLATFORM__WINDOWS 
    _w := hb_gtCreate("WVT")
#else
    _w := hb_gtCreate("XWC")
#endif

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

    oBackup:Backup_data()

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



