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

/* ------------------------------------------
  reset_semaphore_version( "konto")
  set version to -1
  -------------------------------------------
*/
function server_log_write( msg, silent )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _server := pg_server()

// TODO: server_log wratiti nazad

return .f.

if silent == NIL
	silent := .f.
endif

_tbl := "fmk.log"

msg  := PROCNAME(2) + "(" + ALLTRIM(STR(PROCLINE(2))) + ") : " + msg
_qry := "INSERT INTO " + _tbl + "(user_code, msg) VALUES(" +  _sql_quote(_user) + "," +  _sql_quote(msg) + ")"
_ret := _sql_query_no_log( _server, _qry, silent )

return .t.




static function _sql_query_no_log( srv, qry, silent )
local _msg, _ret

if silent == NIL
	silent := .f.
endif

_ret := srv:Query( qry )

/* TODO: ne znam odakle ove neterror greske
if _ret:NetErr()

	if !silent
    	_msg := _ret:ErrorMsg()
      	MsgBeep( _msg )
	endif

    return .f.

endif
*/
return _ret




