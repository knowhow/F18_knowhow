/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

// -----------------------------------
// -----------------------------------
function brisi_stavku_u_tabeli(table)
local _rec := hb_hash()
local _ids := {}
local _pos
local _table

// pronaji u tabeli koji je naziv te tabele
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
   // zapujemo dbf
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


// ------------------------
// ------------------------
function f18_get_rec()
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



return f18_scatter_global_vars()

function f18_update_rec(values, where)
return f18_gather(values, where)


// -------------------------
// -------------------------

function f18_scatter_global_vars(zn)
local _ime_polja, _i, _struct
local _ret := hb_hash()
//private cImeP,cVar
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
// ---------------------------------
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

// sve je ok sada zauriramo dbf
for each _key in values:Keys
    _field_b := FIELDBLOCK(_key)
    // napuni field sa vrijednosti
    EVAL(_field_b, values[_key])
next

return .t.



// -----------------------------------
// -----------------------------------
function brisi_sve_u_tabeli(table)
local _rec := hb_hash()
local _pos
local _table

// pronaji u tabeli koji je naziv te tabele
_pos := ASCAN( gaDBFs,  { |x|  x[2] == UPPER(table) } )
_table := gaDBFs[ _pos, 3 ] 

sql_table_update( _table, "BEGIN" )

_rec["id"] := NIL
// ostala polja su nevazna za brisanje

if sql_table_update( _table, "del", _rec)
   update_semaphore_version( _table, .t.)
   sql_table_update( _table, "END")
   // zapujemo dbf
   ZAP
   return .t.
else
   sql_table_update( _table, "ROLLBACK")
   return .f.
endif

return .t.
 
//----------------------------------------------
// ----------------------------------------------
function sql_table_update(table, op, record, where )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()
local _key
local _dbstruct
local __pos
local __dec
local __len

_tbl := "fmk." + LOWER(table)

DO CASE
   CASE op == "BEGIN"
    _qry := "BEGIN;"

   CASE op == "END"
    _qry := "COMMIT;" 

   CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"

   CASE op == "del"
    if (where == NIL) .and. (record["id"] == NIL)
      // brisi kompletnu tabelu
      _where := "true"
    else
      if where == NIL
         _where := "ID = " + _sql_quote(record["id"])
      else
         // moze biti "id = nesto and id_2 = nesto_drugo"
         _where := where
      endif
    endif
    _qry := "DELETE FROM " + _tbl + ;
            " WHERE " + _where  

   CASE op == "ins"
	
	_dbstruct := {}
	_dbstruct := DBSTRUCT()

    _qry := "INSERT INTO " + _tbl + "(" 
    for each  _key in record:Keys
       _qry +=  _key + ","
    next 
    // otkini zadnji zarez
    _qry := SUBSTR( _qry, 1, LEN(_qry) - 1) + ")"

    _qry += " VALUES(" 
     
    for each _key in record:Keys
        // ako je polje numericko
		if VALTYPE( record[_key] ) == "N"
			
			__pos := ASCAN( _dbstruct, {|_var| LOWER(_var[1]) == LOWER(_key)} )
			__len := _dbstruct[ __pos, 3 ]
			__dec := _dbstruct[ __pos, 4 ]
  
			_qry += STR( record[_key], __len, __dec ) + ","
        else
			_qry += _sql_quote( record[_key]) + ","
    	endif 	
	next 
    _qry := SUBSTR( _qry, 1, LEN(_qry) - 1) + ")"

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif

