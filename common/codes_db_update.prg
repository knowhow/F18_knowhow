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

sql_table_update(table, "BEGIN")

_rec["id"] := field->id
// ostala polja su nevazna za brisanje

if sql_table_update(table, "del", _rec)
   update_semaphore_version(table, .t.)
   
   AADD(_ids, _rec["id"])
   push_ids_to_semaphore( table, _ids )

   sql_table_update(table, "END")
   // zapujemo dbf
   DELETE

   return .t.
else
   sql_table_update(table, "ROLLBACK")
   return .f.
endif

 /* 
    nTArea := SELECT()
    
    // logiraj promjenu brisanja stavke
    if _LOG_PROMJENE == .t.
    EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
    "stavka: " + to_str( FIELDGET(1) ), "", "", DATE(), DATE(), "", ;
    "brisanje sifre iz sifrarnika")
    endif
    
    select (nTArea)
*/

return .t.

// -------------------------
// -------------------------
function f18_Scatter(zn)
local _ime_polja, _i, _struct
local _ret := hb_hash()
//private cImeP,cVar
if zn==nil
  zn:="_"
endif

// ostavimo ovo radi kompatibilnosti
Scatter(zn)

_struct := DBSTRUCT()
for _i:=1 to len(_struct)

  _ime_polja := _struct[i, 1]
   
  if !("#"+ _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#")
      _ret[_ime_polja] := EVAL(FIELDBLOCK(_ime_polja))
  endif

next

return _ret



// ---------------------
// ---------------------
function f18_Gather(cZn)

local i, aStruct
local _field_b

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
 
for i:=1 to len(aStruct)
     _field_b := FIELDBLOCK(aStruct[i,1])

     // cImeP - privatna var
     cVar := cZn + cImeP

     IF "U" $ TYPE(cVar)
         MsgBeep2("Neuskladj.strukt.baza! F-ja: GATHER(), Alias: " + ALIAS() + ", Polje: " + cImeP)
     ELSE
            EVAL(_field_b, EVAL(MEMVARBLOCK(cVar)) )
     ENDIF
next

return nil



// -----------------------------------
// -----------------------------------
function brisi_sve_u_tabeli(table)
local _rec := hb_hash()

sql_table_update(table, "BEGIN")

_rec["id"] := NIL
// ostala polja su nevazna za brisanje

if sql_table_update(table, "del", _rec)
   update_semaphore_version(table, .t.)
   sql_table_update(table, "END")
   // zapujemo dbf
   ZAP
   return .t.
else
   sql_table_update(table, "ROLLBACK")
   return .f.
endif

/*
        nTArea := SELECT()
        // logiraj promjenu brisanja stavke
        if _LOG_PROMJENE == .t.
            EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
            "", "", "", DATE(), DATE(), "", ;
            "brisanje kompletnog sifrarnika")
        endif
*/
 
return .t.
 
//----------------------------------------------
// ----------------------------------------------
function sql_table_update(table, op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()
local _key

_tbl := "fmk." + LOWER(table)

DO CASE
   CASE op == "BEGIN"
    _qry := "BEGIN;"

   CASE op == "END"
    _qry := "COMMIT;" 

   CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"

   CASE op == "del"
    if record["id"] == NIL
      // kompletnu tabelu
      _where := "true"
    else
      _where := "ID = " + _sql_quote(record["id"])
    endif
    _qry := "DELETE FROM " + _tbl + ;
            " WHERE " + _where  

   CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + "(" 
    for each  _key in record:Keys
       _qry +=  _key + ","
    next 
    // otkini zadnji zarez
    _qry := SUBSTR( _qry, 1, LEN(_qry) - 1) + ")"

    _qry += " VALUES(" 
     for each _key in record:Keys
          _qry += _sql_quote( record[_key]) + ","
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

