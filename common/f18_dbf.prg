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

// --------------------------------------
// uzima sva polja iz tekuceg dbf zapisa
// --------------------------------------
function dbf_get_rec()
local _ime_polja, _i, _struct
local _ret := hb_hash()

_struct := DBSTRUCT()
for _i := 1 to LEN(_struct)

  _ime_polja := _struct[_i, 1]
   
  if !("#"+ _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#")
      _ret[ LOWER(_ime_polja) ] := EVAL( FIELDBLOCK(_ime_polja) )
  endif

next

return _ret

// ------------------------------
// no_lock - ne zakljucavaj
// ------------------------------
function dbf_update_rec(vars, no_lock)
local _key
local _field_b
local _msg

if no_lock == NIL
   no_lock := .f.
endif

if !used()
   _msg := "dbf_update_rec - nema otvoren dbf"
   log_write( _msg, 1 )
   Alert(_msg)
   quit_1
endif

if no_lock .or. rlock()
    for each _key in vars:Keys
        // replace polja
        if FIELDPOS(_key) == 0
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
         dbrunlock()
    endif
else
    MsgBeep( "Ne mogu rlock-ovati:" + ALIAS())
    return .f.
endif

return .t.


