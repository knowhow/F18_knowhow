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
for _i:=1 to len(_struct)

  _ime_polja := _struct[_i, 1]
   
  if !("#"+ _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#")
      _ret[ LOWER(_ime_polja) ] := EVAL( FIELDBLOCK(_ime_polja) )
  endif

next

return _ret

// ------------------------------
// ------------------------------
function dbf_update_rec(vars)
local _key
local _field_b

if rlock()
    for each _key in vars:Keys
        // replace polja
        _field_b := FIELDBLOCK(_key)
        // napuni field sa vrijednosti
        EVAL( _field_b, vars[_key] ) 
    next 
    dbrunlock()
else
    MsgBeep( "Ne mogu rlock-ovati:" + ALIAS())
    return .f.
endif

return .t.



// -----------------------------------------
// -----------------------------------------
function update_rec_on_server(values, where)
local _vars

if values == NIL
    // pokupi iz takuceg dbf zapisa vrijednosti
    values := dbf_get_rec()
endif

return f18_gather(values, where)


// ------------------------------------------
// vars sadrzi polja u dbf koja se mjenjaju
//
// server uvijek uzima SVA polja dbf
// i azurira kompletan record 
// ------------------------------------------
function update_rec_dbf_and_server(vars, where)
local _key
local _all_vars
local _field_b

if rlock()
    for each _key in vars:Keys
        // replace polja
        _field_b := FIELDBLOCK( _key )
        EVAL( _field_b, vars[_key] )
    next
    update_rec_on_server( NIL, where)
    dbrunlock()
else
    MsgBeep( "Ne mogu rlock-ovati" + ALIAS())
    return .f.
endif

return .t.


// --------------------------------------
// --------------------------------------
function delete_rec_dbf_and_server(table)
local _rec := hb_hash()
local _ids := {}
local _pos
local _table

if table == NIL
   table := ALIAS()
endif

// pronadji u tabeli koji je naziv te tabele
_pos := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(table) } )
_table := gaDBFs[ _pos, 3 ] 

sql_table_update(_table, "BEGIN")

_rec["id"] := field->id
// ostala polja su nevazna za brisanje

if sql_table_update(_table, "del", _rec)
   update_semaphore_version(_table, .t.)
   
   AADD(_ids, _rec["id"])
   push_ids_to_semaphore( _table, _ids )

   sql_table_update(_table, "END")
   // brisemo DBF zapis
   if rlock()
      DELETE
      dbrunlock()
   endif
   
   return .t.
else
   sql_table_update(_table, "ROLLBACK")
   return .f.
endif

return .t.


// -----------------------------------
// -----------------------------------
function delete_all_dbf_and_server(table)
local _rec := hb_hash()
local _pos
local _table

if table == NIL
   table := ALIAS()
endif

// pronadji u tabeli koji je naziv te tabele
_pos := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(table) } )
_table := gaDBFs[ _pos, 3 ] 

sql_table_update( _table, "BEGIN" )

_rec["id"] := NIL
// ostala polja su nevazna za brisanje

if sql_table_update( _table, "del", _rec)
   update_semaphore_version( _table, .t.)
   sql_table_update( _table, "END")

   // zapujemo dbf
   if flock()
      ZAP
      dbunlockall()
   endif

   return .t.

else
   sql_table_update( _table, "ROLLBACK")
   return .f.
endif

return .t.
 

// -------------------------------------
// --------------------------------------

function f18_scatter_global_vars(zn)
local _ime_polja, _i, _struct
local _ret := hb_hash()

if zn==nil
  zn:="_"
endif

_struct := DBSTRUCT()
for _i:=1 to len(_struct)

  _ime_polja := _struct[_i, 1]
   
  if !("#"+ _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#")

     // punimo hash matricu sa vrijednostima public varijabli
     // _ret["idfirma" := wIdFirma, za zn = "w"
      _ret[ LOWER(_ime_polja) ] := EVAL( MEMVARBLOCK( zn + _ime_polja) )
  endif

next

return _ret


// ----------------------------------
//  vrsimo snimanje na server
// ----------------------------------
function f18_gather(values, where)
local _l_table
local _table
local _key, _field_b
local _ok := .f.
local _values_old := hb_hash()
local _ids := {}
local _pos

_l_table := LOWER(ALIAS())

// pronaji u tabeli koji je naziv te tabele
_pos := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(_l_table) } )
_table := gaDBFs[ _pos, 3 ] 

if where == NIL
  where := "ID=" + _sql_quote(values['id'])
endif

sql_table_update(_table, "BEGIN")

// ostala polja su nevazna za brisanje

if sql_table_update(_table, "del", values, where )

   // izbrisali smo, sada dodajemo vrijednost
   if sql_table_update(_table, "ins", values)
       update_semaphore_version(_table, .t.)
  
       _field_b := FIELDBLOCK("id")
       if EVAL(_field_b) <> values["id"]
           // vrijednost u dbf se razlikuje od memvar zato pobrisi staru sifru
           _values_old["id"] := EVAL(_field_b)
           AADD(_ids, _values_old["id"])
           sql_table_update(_table, "del", _values_old) 
       endif 

       AADD(_ids, values["id"])
       push_ids_to_semaphore( _table, _ids )

       sql_table_update(_table, "END")

       _ok := .t.
   endif

endif

if ! _ok
    sql_table_update(_table, "ROLLBACK")

    MsgBeep("podrska za semafore za " + _table + "nedostaje")
    // return .f.
endif

if rlock()
    // sve je ok sada zauriramo dbf
    for each _key in values:Keys
        _field_b := FIELDBLOCK(_key)
        // napuni field sa vrijednosti
        EVAL(_field_b, values[_key])
    next
else
    MsgBeep("ajoj rlock dbf ne radi : " + ALIAS())
endif

return .t.
