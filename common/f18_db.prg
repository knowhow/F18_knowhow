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




// --------------------------------------
// --------------------------------------
function delete_rec_dbf_and_server(table, where)
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

if sql_table_update(_table, "del", _rec, where)
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

function get_dbf_global_memvars(zn)
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

      // oslobadja public ili private varijablu
      __MVXRELEASE( zn + _ime_polja)
  endif

next

return _ret


// -----------------------------------------
// -----------------------------------------
function update_rec_on_server(values, id_fields, where_block)
local _vars

if values == NIL
    // pokupi iz takuceg dbf zapisa vrijednosti
    values := dbf_get_rec()
endif

return update_rec_server_and_dbf(values, id_fields, where_block, .t.)

// ----------------------------------------------------------------------------------------------------------
// vrsimo snimanje na server
//
// mijenja zapis na serveru, pa u dbf-u 
//
// update_rec_server_and_dbf( values, 
//                           {"id", "oznaka"}, 
//                           {|x| "ID=" + _sql_quote(x["id"]) + "|| OZNAKA=" + _sql_quote(x["oznaka"]) })
//
//  server_only je pobezveze, radi gornje funkcije za koju nisam siguran da ikome treba
// -----------------------------------------------------------------------------------------------------------
function update_rec_server_and_dbf(values, id_fields, where_block, server_only)
local _l_table
local _table
local _key, _field, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _val_dbf, _val_mem
local _changed_id, _values_dbf, _full_id_dbf, _full_id_mem 

if !USED()
   MsgBeep("mora biti otvorena neka tabela ?!")
   return .f.
endif

_l_table := LOWER(ALIAS())

// proadji naziv tabele prema aliasu
_pos := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(_l_table) } )
_table := gaDBFs[ _pos, 3 ]

if id_fields == NIL
   if LEN(gaDBFs[_pos]) > 5
       id_fields := gaDBFs[_pos, 6]
   else
       id_fields := { "id" }
   endif
endif

if where_block == NIL
   if LEN(gaDBFs[_pos]) > 6
      where_block := gaDBFs[_pos, 7]
   else
      where_block := { |x| "ID=" + _sql_quote(x['id']) }
   endif
endif

if server_only == NIL
  server_only := .f.
endif

sql_table_update(_table, "BEGIN")

// ostala polja su nevazna za brisanje

if !sql_table_update(_table, "del", nil, EVAL(where_block, values))
   sql_table_update(_table, "ROLLBACK")
   MsgBeep("mi imamos mnogos problemos - SQL del / 1")
   return .f.
endif

if !sql_table_update(_table, "ins", values)
   sql_table_update(_table, "ROLLBACK")
   MsgBeep("mi imamos mnogos problemos - SQL ins / 1")
   return .f.
endif

if update_semaphore_version(_table, .t.) < 0
   sql_table_update(_table, "ROLLBACK")
   MsgBeep("mi imamos mnogos problemos - update_semaphore_version / 1")
   return .f.
endif

_full_id_dbf := ""
_full_id_mem := ""
_changed_id  := .f.
_values_dbf  := hb_hash()
for each _field  in id_fields
    _values_dbf[_field] := EVAL(FIELDBLOCK(_field))
    if _values_dbf[_field] != values[_field]
        _changed_id := .t.
    endif
    _full_id_dbf += _values_dbf[_field]
    _full_id_mem += values[_field]
next

// razlike izmedju dbf-a i values postoje
if _changed_id
    AADD(_ids, _full_id_dbf)
    if !sql_table_update(_table, "del", NIL, EVAL(where_block, _values_dbf)) 
       sql_table_update(_table, "ROLLBACK")
       MsgBeep("mi imamos mnogos problemos - del / 2")
       return .f.
    endif
endif

AADD(_ids, _full_id_mem)

if !push_ids_to_semaphore( _table, _ids )
     sql_table_update(_table, "ROLLBACK")
     MsgBeep("mi imamos mnogos problemos - push_ids_to_semaphore / 2")
     return .f.
endif

if server_only
  sql_table_update(_table, "END")
  return .t.
endif

if dbf_update_rec(values)
    sql_table_update(_table, "END")
    return .f.
else
    sql_table_update(_table, "ROLLBACK")
    MsgBeep("mi imamos dbf problemos - moramo sql rollbackos")
    return .f.
endif


