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

#include "fmk.ch"
#include "f18_ver.ch"

// ------------------------------------
// ------------------------------------
function server_db_version()
local _qry
local _ret
local _server:= pg_server()

_qry := "SELECT u2.knowhow_package_version('fmk')"

log_write( _qry, 9 )
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  return -1
endif

return _ret:Fieldget(1)

// ---------------------------------
// ---------------------------------
function check_server_db_version()
local _server_db_num, _server_db_str, _f18_required_server_str, _f18_required_server_num
local _msg

#ifdef TEST
   altd()
   if _TEST_NO_DATABASE
      return .t.
   endif
#endif

_f18_required_server_num := get_version_num(SERVER_DB_VER_MAJOR, SERVER_DB_VER_MINOR, SERVER_DB_VER_PATCH)

_server_db_num := server_db_version()

if (_f18_required_server_num > _server_db_num)

   _f18_required_server_str := get_version_str(_f18_required_server_num)
   _server_db_str := get_version_str(_server_db_num)

   _msg := "F18 klijent trazi verziju " + _f18_required_server_str + " server db je verzije: " + _server_db_str

   log_write( _msg, 3 )

   MsgBeep(_msg)

   OutMsg(1, _msg + hb_osNewLine())
   QUIT_1
endif

return .t.

