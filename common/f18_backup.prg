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

    METHOD set_backup_path()
    METHOD get_backup_path()
    
    METHOD set_backup_interval()
    METHOD get_backup_interval()

    METHOD set_backup_type()
    METHOD get_backup_type()

    PROTECTED:

        DATA backup_path
        DATA backup_interval
        DATA backup_type


ENDCLASS




METHOD F18Backup:New()
return SELF




METHOD F18Backup:Backup_data()

if ::backup_type == 1
    ::Backup_company()
else
    ::Backup_server()
endif

return .t.




METHOD F18Backup:Backup_company()
local _ok := .f.

::set_backup_path( ::backup_type )

MsgBeep( "Pravim backup preduzeca, " + ::backup_path )

return _ok






METHOD F18Backup:Backup_server()
local _ok := .f.

::set_backup_path( ::backup_type )

MsgBeep( "Pravim backup servera !, " + ::backup_path )

return _ok





METHOD F18Backup:get_backup_path()
return ::backup_path


METHOD F18Backup:set_backup_path( backup_type )
local _path
local _database

if backup_type == NIL
    backup_type := 1
endif

if backup_type == 0
    set_f18_home_backup()
    ::backup_path := my_home_backup()
else
    _database := my_server_params()["database"]
    set_f18_home_backup( _database )
    ::backup_path := my_home_backup()
endif

return .t.



METHOD F18Backup:get_backup_interval()
return ::backup_interval


METHOD F18Backup:set_backup_interval()
local _param := "backup_company_interval"

if ::backup_type == 0
    _param := "backup_server_interval"
endif

::backup_interval := fetch_metric( _param, my_user(), 0 )

return .t.



METHOD F18Backup:get_backup_type()
return ::backup_type

METHOD F18Backup:set_backup_type()
local _type := 1

Box(, 6, 60 )

    @ m_x + 1, m_y + 2 SAY "Kreirati backup podataka ***"
    @ m_x + 3, m_y + 2 SAY "   1 - backup tekuce firme"
    @ m_x + 4, m_y + 2 SAY "   0 - backup kompletnog servera"
    @ m_x + 6, m_y + 2 SAY "odabir:" GET _type VALID _type >= 0 PICT "9"

    read

BoxC()

altd()

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

if oBackup:set_backup_type()
    oBackup:Backup_data()
endif

return



