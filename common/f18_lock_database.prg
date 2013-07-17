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
    METHOD run_synchro()

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
METHOD F18_DB_LOCK:set_lock_params()

set_metric( DB_LOCK_PARAM, NIL, DATE() )
set_metric( DB_LOCK_PARAM, my_user(), DATE() )

::get_lock_params()

return 


// ----------------------------------------------------
// ----------------------------------------------------
METHOD F18_DB_LOCK:set_my_lock_params()

if ::lock_params[ SRV_LOCK_PARAM ] <> CTOD("") .and. ::lock_params[ CLI_LOCK_PARAM ] == CTOD("")
    // setuj moj parametar lock-a na osnovu 
    set_metric( DB_LOCK_PARAM, my_user(), ::lock_params[ SRV_LOCK_PARAM ] )
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
    _ok := .t.
endif

return _ok 



