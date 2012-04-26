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

// ------------------------------------
// set_global_vars_from_dbf("w")
// geerise public vars wId, wNaz ..
// sa vrijednostima dbf polja Id, Naz 
// -------------------------------------
function set_global_memvars_from_dbf(zn)

return set_global_vars_from_dbf(zn)

// --------------------------------------------------
// TODO: imee set_global_vars_from_dbf je legacy
// --------------------------------------------------
function set_global_vars_from_dbf(zn)

local _i, _struct, _field, _var

private cImeP, cVar

if zn == NIL 
  zn := "_"
endif

_struct := DBSTRUCT()

for _i := 1 to LEN(_struct)
   _field := _struct[_i, 1]

    if !("#"+ _field +"#" $ "#BRISANO#_OID_#_COMMIT_#")
        _var := zn + _field
        // kreiram public varijablu sa imenom vrijednosti _var varijable
        __MVPUBLIC(_var)
        EVAL(MEMVARBLOCK(_var), EVAL(FIELDBLOCK(_field))) 

    endif
next

return .t.

// -------------------------------------
// --------------------------------------
function get_dbf_global_memvars(zn)
local _ime_polja, _i, _struct
local _ret := hb_hash()

if zn==nil
  zn := "_"
endif

_struct := DBSTRUCT()
for _i := 1 to len(_struct)

  _ime_polja := _struct[_i, 1]
   
  if !("#"+ _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#")

     // punimo hash matricu sa vrijednostima public varijabli
     // _ret["idfirma"] := wIdFirma, za zn = "w"
      _ret[ LOWER(_ime_polja) ] := EVAL( MEMVARBLOCK( zn + _ime_polja) )

      // oslobadja public ili private varijablu
      __MVXRELEASE( zn + _ime_polja)
  endif

next

return _ret




