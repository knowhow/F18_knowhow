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

if no_lock == NIL
   no_lock := .f.
endif

if no_lock .or. rlock()
    for each _key in vars:Keys
        // replace polja
        _field_b := FIELDBLOCK(_key)
        // napuni field sa vrijednosti
        EVAL( _field_b, vars[_key] ) 
    next 
    if !no_lock 
         dbrunlock()
    endif
else
    MsgBeep( "Ne mogu rlock-ovati:" + ALIAS())
    return .f.
endif

return .t.




// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
function delete_rec_server_and_dbf(table, values, id_fields, where_block, order_key_tag)
local _ids := {}
local _pos
local _full_id
local _dbf_pkey_search
local _field
local _where_str

if table == NIL
   table := ALIAS()
endif

if values == NIL
  values := dbf_get_rec()
endif

// pronadji u tabeli koji je naziv te tabele
_pos   := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(table) } )
table  := gaDBFs[ _pos, 3 ] 
_alias := gaDBFs[ _pos, 2 ]

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


// tag po kome se primarni kljuc pretrazuje
if order_key_tag == NIL
   if LEN(gaDBFs[_pos]) > 7 
      order_key_tag := gaDBFs[_pos, 8]
   else
      order_key_tag := "ID"
   endif
endif

sql_table_update(table, "BEGIN")

_where_str := EVAL(where_block, values)
if sql_table_update(table, "del", nil, _where_str) 

   update_semaphore_version(table, .t.)
   
   _full_id := ""
   for each _field  in id_fields
     _full_id += values[_field]
   next

   AADD(_ids, _full_id)
   push_ids_to_semaphore( table, _ids )


   SELECT (_alias)
   SET ORDER TO TAG (order_key_tag)
   _dbf_pkey_search := ""
   for each _field in id_fields
       _dbf_pkey_search += values[_field]
   next

   if FLOCK()
      SEEK _dbf_pkey_search
      while FOUND()
          DELETE
          // sve dok budes nalazio pod ovim kljucem brisi
          SEEK _dbf_pkey_search
      enddo
   else
      sql_table_update(table, "ROLLBACK")
      return .f.
   endif
   DBUNLOCKALL() 

   sql_table_update(table, "END")
   return .t.

else
   sql_table_update(table, "ROLLBACK")
   return .f.
endif


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

if _pos == 0
   MsgBeep("gaDBFs table ? :" + table)
   quit
endif

_table := gaDBFs[ _pos, 3 ] 

sql_table_update( _table, "BEGIN" )

_rec["id"] := NIL
// ostala polja su nevazna za brisanje


if sql_table_update( _table, "del", _rec)
   update_semaphore_version( _table, .t.)
   sql_table_update( _table, "END")

   // zapujemo dbf
   if FLOCK()
      ZAP
      dbunlockall()
   endif

   return .t.

else
   sql_table_update( _table, "ROLLBACK")
   return .f.
endif

return .t.

// ------------------------------------
// set_global_vars_from_dbf("w")
// geerise public vars wId, wNaz ..
// sa vrijednostima dbf polja Id, Naz 
// -------------------------------------
function set_global_vars_from_dbf(zn)

local _i, _struct, _field, _var

private cImeP,cVar

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
  zn:="_"
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





// -----------------------------------------
// -----------------------------------------
function update_rec_on_server(table, values, id_fields, where_block)
local _vars

if values == NIL
    // pokupi iz takuceg dbf zapisa vrijednosti
    values := dbf_get_rec()
endif

return update_rec_server_and_dbf(table, values, id_fields, where_block, .t.)

// ----------------------------------------------------------------------------------------------------------
// vrsimo snimanje na server
//
// mijenja zapis na serveru, pa u dbf-u 
//
// update_rec_server_and_dbf( table, values, 
//                           {"id", "oznaka"}, 
//                           {|x| "ID=" + _sql_quote(x["id"]) + "|| OZNAKA=" + _sql_quote(x["oznaka"]) })
//
//  server_only je pobezveze, radi gornje funkcije za koju nisam siguran da ikome treba
// -----------------------------------------------------------------------------------------------------------
function update_rec_server_and_dbf(table, values, id_fields, where_block, server_only)
local _key, _field, _field_b
local _ok := .t.
local _values_old := hb_hash()
local _ids := {}
local _pos
local _val_dbf, _val_mem
local _changed_id, _values_dbf, _full_id_dbf, _full_id_mem 
local _where_str

if !USED()
   MsgBeep("mora biti otvorena neka tabela ?!")
   return .f.
endif

if table == NIL
   table := ALIAS()
endif

if values == NIL
  values := dbf_get_rec()
endif


// proadji naziv tabele prema aliasu
_pos := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(table) } )
table := gaDBFs[ _pos, 3 ]

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

sql_table_update(table, "BEGIN")
_where_str := EVAL(where_block, values)
if !sql_table_update(table, "del", nil, _where_str) 
   sql_table_update(table, "ROLLBACK")
   MsgBeep("mi imamos mnogos problemos - SQL del / 1")
   return .f.
endif

if !sql_table_update(table, "ins", values)
   sql_table_update(table, "ROLLBACK")
   MsgBeep("mi imamos mnogos problemos - SQL ins / 1")
   return .f.
endif

if update_semaphore_version(table, .t.) < 0
   sql_table_update(table, "ROLLBACK")
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
    if !sql_table_update(table, "del", NIL, EVAL(where_block, _values_dbf)) 
       sql_table_update(table, "ROLLBACK")
       MsgBeep("mi imamos mnogos problemos - del / 2")
       return .f.
    endif
endif

AADD(_ids, _full_id_mem)

if !push_ids_to_semaphore(table, _ids)
     sql_table_update(table, "ROLLBACK")
     MsgBeep("mi imamos mnogos problemos - push_ids_to_semaphore / 2")
     return .f.
endif

if server_only
  sql_table_update(table, "END")
  return .t.
endif

if dbf_update_rec(values)
    sql_table_update(table, "END")
    return .t.
else
    sql_table_update(_table, "ROLLBACK")
    MsgBeep("mi imamos dbf problemos - moramo sql rollbackos")
    return .f.
endif


