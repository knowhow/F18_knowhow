/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

// ------------------------------------
// ------------------------------------
function server_show(var)
local _qry
local _ret
local _server:= pg_server()

_qry := "SHOW " + var

if gDebug > 9 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  return -1
endif

return _ret:Fieldget(1)


// ------------------------------------
// ------------------------------------
function server_sys_info(var)
local _qry
local _ret_sql
local _server:= pg_server()
local _ret := hb_hash()

_qry := "select inet_client_addr(), inet_client_port(),  inet_server_addr(), inet_server_port(), user"

if gDebug > 9 
  log_write(_qry)
endif
_ret_sql := _sql_query( _server, _qry )

if VALTYPE(_ret_sql) == "L"
  return NIL
endif

_ret["client_addr"] := _ret_sql:FieldGet(1)
_ret["client_port"] := _ret_sql:FieldGet(2)
_ret["server_addr"] := _ret_sql:FieldGet(3)
_ret["server_port"] := _ret_sql:FieldGet(4)
_ret["user"]        := _ret_sql:FieldGet(5)

return _ret
