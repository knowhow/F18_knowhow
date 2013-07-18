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
#include "f18_ver.ch"
#include "hbclass.ch"
#include "common.ch"

static DB_LOCK_PARAM := "database_lock"
static SRV_LOCK_PARAM := "server_lock"
static CLI_LOCK_PARAM := "client_lock"


// ----------------------------------------------------
// ----------------------------------------------------
CLASS F18_DB_LOCK

    METHOD New()
    METHOD is_locked()
    METHOD form_lock()
    METHOD get_lock_params()
    METHOD set_lock_params() 
    METHOD set_my_lock_params() 
    METHOD reset_my_lock_params()
    METHOD run_synchro()
    METHOD warrning()

    DATA lock_params

ENDCLASS


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:New()
::lock_params := hb_hash()
::get_lock_params()
return SELF



// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:is_locked()
local _ok := .f.

if ::lock_params["database_locked"]
    _ok := .t.
endif

return _ok


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:form_lock()
local _ok := .f.

return _ok


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:get_lock_params()
local _server := fetch_metric( DB_LOCK_PARAM, NIL, CTOD("") )
local _client := fetch_metric( DB_LOCK_PARAM, my_user(), CTOD("") )

::lock_params[ SRV_LOCK_PARAM ] := _server
::lock_params[ CLI_LOCK_PARAM ] := _client

if _server <> CTOD( "" )
    ::lock_params["database_locked"] := .t.
else
    ::lock_params["database_locked"] := .f.
endif

return


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:set_lock_params( lock )

if lock == NIL
    lock := .t.
endif

if lock
    set_metric( DB_LOCK_PARAM, NIL, DATE() )
    set_metric( DB_LOCK_PARAM, my_user(), DATE() )
    log_write( "F18_DOK_OPER, DATABASE LOCK " + DTOC( DATE() ), 2 )
else
    set_metric( DB_LOCK_PARAM, NIL, CTOD("") )
    set_metric( DB_LOCK_PARAM, my_user(), CTOD("") )
    log_write( "F18_DOK_OPER, DATABASE UNLOCK " + DTOC( DATE() ), 2 )
endif

::get_lock_params()

return 


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:set_my_lock_params( force_set )

if force_set == NIL
    force_set := .f.
endif

// nemam setovan parametar, setuj ga !
if ::lock_params[ CLI_LOCK_PARAM ] == CTOD("")
    force_set := .t.
endif

if force_set    
    // setuj moj parametar lock-a na osnovu 
    set_metric( DB_LOCK_PARAM, my_user(), ::lock_params[ SRV_LOCK_PARAM ] )
    ::get_lock_params()
endif

return


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:reset_my_lock_params()

// nemam setovan parametar, setuj ga !
if ::lock_params[ CLI_LOCK_PARAM ] <> CTOD("")
    // setuj moj parametar lock-a na osnovu 
    set_metric( DB_LOCK_PARAM, my_user(), CTOD("") )
    ::get_lock_params()
endif

return



// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:run_synchro()
local _ok := .f.

// da li je zakljucano ?
if !::is_locked()
    return
endif

if ::lock_params[ CLI_LOCK_PARAM ] < ::lock_params[ SRV_LOCK_PARAM ]
    // setuj mi moj lock parametar na osnovu serverskog
    _ok := .t.
endif

return _ok 


// -----------------------------------------------------
METHOD F18_DB_LOCK:warrning()
// -----------------------------------------------------
MsgBeep( "Baza je zakljucana ili nemate pravo pristupa ovoj opciji !" )
return .f.



function f18_database_lock_menu()
local oDb_lock 
local GetList := {}
local _tmp
local _answ := "D"
local _db_locked

if !SigmaSif( "ADMIN" )
    MsgBeep( "Opcija nedostupna !" )
    return 
endif

oDb_lock := F18_DB_LOCK():New()
_db_locked := oDb_lock:is_locked()

if _db_locked
    _tmp := "Otkljucati bazu (D/N) ?" 
else
    _tmp := "Zakljucati bazu (D/N) ?" 
endif

Box(, 5, 60 )
    @ m_x + 1, m_y + 2 SAY "*** otkljucavanje/zakljucavanje baze ***"
    @ m_x + 2, m_y + 2 SAY "INFO:"
    @ m_x + 3, m_y + 2 SAY "Nakon sto je baza zakljucana, nije moguce mjenjati podatke"
    @ m_x + 5, m_y + 2 SAY _tmp GET _answ VALID _answ $ "DN" PICT "@!"
    read
BoxC()

if LastKey() == K_ESC .or. _answ == "N"
    return
endif

if _db_locked
    oDb_lock:set_lock_params( .f. )
else
    oDb_lock:set_lock_params( .t. )
endif

return



