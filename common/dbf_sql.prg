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

#include "f18.ch"

// ------------------------------
// no_lock - ne zakljucavaj
// ------------------------------
function dbf_update_rec( vars, no_lock )
local _key
local _field_b
local _msg
local _a_dbf_rec

if no_lock == NIL
   no_lock := .f.
endif

if !used()
   _msg := "dbf_update_rec - nema otvoren dbf"
   log_write( _msg, 1 )
   Alert(_msg)
   quit_1
endif

if no_lock .or. my_rlock()

    _a_dbf_rec := get_a_dbf_rec( ALIAS() )
    
    for each _key in vars:Keys

        // blacklistovano polje
        if field_in_blacklist( _key, _a_dbf_rec["blacklisted"] )
            LOOP
        endif

        // replace polja
        if FIELDPOS( _key ) == 0
           _msg := RECI_GDJE_SAM + "dbf field " + _key + " ne postoji u " + ALIAS()
           //Alert(_msg)
           log_write( _msg, 1 )
        else
           _field_b := FIELDBLOCK(_key)
           // napuni field sa vrijednosti
           EVAL( _field_b, vars[_key] )
        endif

    next
 
    if !no_lock 
         my_unlock()
    endif
else
    MsgBeep( "Ne mogu rlock-ovati:" + ALIAS())
    return .f.
endif

return .t.


