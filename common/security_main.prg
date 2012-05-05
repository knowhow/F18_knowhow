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


// -----------------------------------------------------------
// -----------------------------------------------------------
function ImaPravoPristupa( cObjekat, cKomponenta, cFunkcija )
local _ret

_ret := f18_privgranted( cFunkcija )

if !_ret
    _ret := .t.
endif

return _ret


// ---------------------------------------------------
// da li korisnik ima dozvoljen pristup
// ---------------------------------------------------
function f18_privgranted( funct )
local _tmp
local _table := "public.privgranted"
local oTable
local oServer := pg_server()
local _count
local _ret := .f.

if funct == NIL
    return _ret
endif

_count := table_count( _table, "privilege=" + _sql_quote( funct ) ) 

if _count == 0
	return _ret
endif

_tmp := "SELECT granted FROM " + _table + " WHERE privilege = " + _sql_quote( funct )

oTable := _sql_query( oServer, _tmp )

if oTable == NIL
	log_write( PROCLINE(1) + " : " + _tmp )
    quit
endif

if oTable:FieldGet(1) == .t.
	_ret := .t.
    return _ret
endif

return _ret



// vraca id user-a
function GetUserID()
local cTmpQry
local cTable := "public.usr_bak"
local oTable
local nResult
local oServer := pg_server()
local cUser   := ALLTRIM( my_user() )

cTmpQry := "SELECT usr_id FROM " + cTable + " WHERE usr_username = " + _sql_quote( cUser )
oTable := _sql_query( oServer, cTmpQry )
IF oTable == NIL
      log_write(PROCLINE(1) + " : "  + cTmpQry)
      QUIT
ENDIF

if oTable:eof()
  return 0
else
  return oTable:Fieldget(1)
endif


// vraca username usera iz sec.systema
function GetUserName( nUser_id )
local cTmpQry
local cTable := "public.usr_bak"
local oTable
local cResult
local oServer := pg_server()

cTmpQry := "SELECT usr_username FROM " + cTable + " WHERE usr_id = " + ALLTRIM(STR( nUser_id ))
oTable := _sql_query( oServer, cTmpQry )

if oTable == NIL
      log_write(PROCLINE(1) + " : "  + cTmpQry)
      QUIT
endif

if oTable:eof()
  return "?user?"
else
  return oTable:Fieldget(1)
endif


// vraca full username usera iz sec.systema
function GetFullUserName( nUser_id )
local cTmpQry
local cTable := "public.usr_bak"
local oTable
local oServer := pg_server()

cTmpQry := "SELECT usr_propername FROM " + cTable + " WHERE usr_id = " + ALLTRIM(STR( nUser_id ))
oTable := _sql_query( oServer, cTmpQry )

if oTable == NIL
      log_write(PROCLINE(1) + " : "  + cTmpQry)
      QUIT
endif

if oTable:eof()
  return "?user?"
else
  return oTable:Fieldget(1)
endif


