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
function brisi_sve_u_tabeli(table)
_rec := hb_hash()


sql_tabela_update("BEGIN")

_rec["id"] := NIL
// ostala polja su nevazna za brisanje

if sql_tabela_update(table, "del", _rec)
   sql_tabela_update("END")
   // zapujemo dbf
   ZAP
   return .t.
else
   sql_tabla_update("ROLLBACK")
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
function sql_tabela_update(table, op, record )

LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()
local _key

_tbl := "fmk." + LOWER(table)

if record["id"] == NIL
   // kompletnu tabelu
   _where := "true"
else
_where := "ID = " + _sql_quote(record["id"])
endif

DO CASE
   CASE op == "BEGIN"
    _qry := "BEGIN;"
   CASE op == "END"
    _qry := "COMMIT;" 
   CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
   CASE op = "del"
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

endif
   
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

