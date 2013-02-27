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

#include "hbclass.ch"
#include "common.ch"


CLASS F18Backup

    METHOD New()

    METHOD Backup_data()
    
    METHOD Backup_company()
    METHOD Backup_server()

    METHOD get_backup_path()
    METHOD get_backup_interval()
    METHOD get_backup_type()
    METHOD get_backup_filename()

    METHOD lock()
    METHOD unlock()
    METHOD locked()

    PROTECTED:

        DATA backup_path
        DATA backup_filename
        DATA backup_interval
        DATA backup_type

ENDCLASS




METHOD F18Backup:New()
return SELF




METHOD F18Backup:Backup_data()

MsgBeep("Opcija nije u funkciji !!!!")

// da li vec neko koristi opciju backup-a
if ::locked( .t. )
    ::unlock()
    return .f.
else
    // zakljucaj opciju backup-a da je samo jedan korisnik radi
    ::lock()
endif

// 1 - preduzece
// 0 - kompletan server

if ::backup_type == 1
    ::Backup_company()
else
    ::Backup_server()
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

// imamo dostupne podatke
//
// ::backup_path := ""
// ::backup_type := 0 ili 1
// ::backup_interval := 30 recimo...

_cmd += "pg_dump"
_cmd += " -h " + ALLTRIM( _host )
_cmd += " -p " + ALLTRIM( STR( _port ) )
_cmd += " -U " + ALLTRIM( _admin_user )
_cmd += " -w "
_cmd += " -F t "
_cmd += " -b "
_cmd += ' -f "' + ::backup_path + ::get_backup_filename() + '"'
_cmd += ' "' + _database + '"'

MsgBeep( _cmd )

//hb_run( _cmd )

return _ok






METHOD F18Backup:Backup_server()
local _ok := .f.

MsgBeep( "Pravim backup servera !, " + ::backup_path )

return _ok






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
local _name := "backup_" + DTOC( DATE() ) + ".sql"
return _name





METHOD F18Backup:get_backup_interval()
local _param := "backup_company_interval"

if ::backup_type == 0
    _param := "backup_server_interval"
endif

::backup_interval := fetch_metric( _param, my_user(), 0 )

return .t.




METHOD F18Backup:get_backup_type()
local _type := 1

Box(, 6, 60 )

    @ m_x + 1, m_y + 2 SAY "Kreirati backup podataka ***"
    @ m_x + 3, m_y + 2 SAY "   1 - backup tekuce firme"
    @ m_x + 4, m_y + 2 SAY "   0 - backup kompletnog servera"
    @ m_x + 6, m_y + 2 SAY "odabir:" GET _type VALID _type >= 0 PICT "9"

    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

::backup_type := _type

return .t.




// ------------------------------------------------
// poziv backupa podataka sa menija...
// ------------------------------------------------
function f18_backup_data()
local oBackup

oBackup := F18Backup():New()

if oBackup:get_backup_type()

    oBackup:get_backup_path()
    oBackup:get_backup_interval()

    oBackup:Backup_data()

endif

return






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



