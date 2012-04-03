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

// ----------------------------------------------
// fin_suban - update
// ----------------------------------------------
function update_server_from_rec( table, op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()
local _a_dbf_rec, _alg
local _a_dbf_fields, _sql_fields
local _sql_where
local _i, _tmp

_a_dbf_rec := get_a_dbf_rec(table)

_dbf_fields := _a_dbf_rec["dbf_fields"]
_sql_fields := sql_fields( _dbf_fields )

_sql_order  := _a_dbf_rec["sql_order"]


_dbf_wa    := _a_dbf_rec["wa"]
_dbf_alias := _a_dbf_rec["alias"]

_sql_tbl   := "fmk." + table


// uvijek je algoritam 1 nivo recorda
_alg := _a_dbf_rec["algoritam"][1]

_fields_string := ""

if record <> nil
    _where_str := sql_where_from_dbf_key_fields(_alg["dbf_key_fields"], record)
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"

 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"

 CASE op == "del"
    _qry := "DELETE FROM " + _sql_tbl + ;
             " WHERE " + _where

 CASE op == "ins"

    _qry := "INSERT INTO " + _sql_tbl +  "("  

    for _i := 1 to LEN(_a_dbf_rec["dbf_fields"])

        _qry += _a_dbf_rec["dbf_fields"][_i]

        if _i < LEN(_a_dbf_rec["dbf_fields"])
            _qry += ","
        endif

    next

    _qry += ")  VALUES (" 
    for _i := 1 to LEN(_a_dbf_rec["dbf_fields"])

        _tmp := _a_dbf_rec["dbf_fields"][_i]

        if VALTYPE(record[_tmp]) == "N"
            _qry += STR(record[_tmp], _a_dbf_rec["dbf_fields_len"][_tmp][2], _a_dbf_rec["dbf_fields_len"][_tmp][3])
            //_qry += decimal_to_string( record[_tmp])
        else
            _qry += _sql_quote(record[_tmp])
        endif

        if _i < LEN(_a_dbf_rec["dbf_fields"])
            _qry += ","
        endif

    next
    
    _qry += ")"

ENDCASE
    
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
 


// --------------------------------
// 5.55 => "5.55", 6.666 => "6.666"
// ---------------------------------
function decimal_to_string( num )
local _i, _tmp

num := ROUND(num, 8)

// do 6 decimala
for _i := 0 to 6
  _tmp := num * (10 ** _i) 
  if round( round(_tmp, 0) - round(_tmp, 7), 8) == 0
      return ALLTRIM(STR( num, 20, _i))
  endif
next
