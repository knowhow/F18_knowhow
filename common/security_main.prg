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
function ImaPravoPristupa( obj, komponenta, funct )
local _ret := .t.
return _ret

// ---------------------------------------------------
// da li postoji privilegija ?
// ---------------------------------------------------
function f18_privilege_exist( funct )
local _table := "public.privgranted"
local _count
local _ret := .f.

_count := table_count( _table, "privilege=" + _sql_quote( funct ) ) 

if _count > 0
    _ret := .t.
	return _ret
endif

return _ret


// ---------------------------------------------------
// da li korisnik ima dozvoljen pristup
// ---------------------------------------------------
function f18_privgranted( funct )
local _tmp
local oTable
local oServer := pg_server()
local _ret := .f.

if funct == NIL
    return _ret
endif

if !f18_privilege_exist( funct )
    _ret := .t.
	return _ret
endif

_tmp := "SELECT checkprivilege( " + _sql_quote( funct ) + " ) "

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



// ------------------------------------------------------
// vraca id user-a
// ------------------------------------------------------
function GetUserID()
local cTmpQry
local cTable := "public.usr"
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

return





// ------------------------------------------------------
// vraca username usera iz sec.systema
// ------------------------------------------------------
function GetUserName( nUser_id )
local cTmpQry
local cTable := "public.usr"
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
  return hb_utf8tostr( oTable:Fieldget(1) )
endif

return


// vraca full username usera iz sec.systema
function GetFullUserName( nUser_id )
local cTmpQry
local cTable := "public.usr"
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
  return hb_utf8tostr( oTable:Fieldget(1) )
endif

return


// --------------------------------------------------
// odabir f18 user-a
// --------------------------------------------------
function choose_f18_user_from_list( oper_id )
local _list

oper_id := 0

// daj mi listu korisnika u array
_list := _list_f18_users()

// izbaci mi listu ...
oper_id := array_choice( _list )

return .t.


// -------------------------------------------------------
// array choice
// -------------------------------------------------------
static function array_choice( arr, choice )
local _ret
local _i, _n
local _tmp
private izbor := 1
private opc := {}
private opcexe := {}
private GetList:={}

choice := 1

for _i := 1 to LEN( arr )

    _tmp := ""
    _tmp += PADL( ALLTRIM(STR( _i )) + ")", 3 )
    _tmp += " " + PADR( arr[ _i, 2] , 30 )

    AADD( opc, _tmp )
    AADD( opcexe, {|| choice := izbor, izbor := 0 })
    
next

Menu_SC( "izbor", .f. )

if LastKey() == K_ESC
    choice := 0
    _ret := 0
else
    _ret := arr[ choice, 1 ]
endif

return _ret


// --------------------------------------------------
// daj mi listu f18 usera u array
// --------------------------------------------------
static function _list_f18_users()
local _qry, _table
local _server := pg_server()
local _list := {}
local _row

_qry := "SELECT usr_id AS id, usr_username AS name, usr_propername AS fullname, usr_email AS email " + ;
        "FROM public.usr " + ;
        "WHERE usr_username NOT IN ( 'postgres', 'admin' ) " + ;
        "ORDER BY usr_username;"

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

for _i := 1 to _table:LastRec()

    // daj mi row
    _row := _table:GetRow( _i )

    AADD( _list, { _row:FieldGet( _row:FieldPos("id") ), ;
                    _row:FieldGet( _row:FieldPos("name") ), ;
                    _row:FieldGet( _row:FieldPos("fullname") ), ;
                    _row:FieldGet( _row:FieldPos("email") ) } )

next

return _list




