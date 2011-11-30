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

static __server := NIL
static __server_params := NIL


#include "fmk.ch"

// -------------------------
// -------------------------
function init_f18_app()
local cHostName, cDatabase, cUser, cPassword, nPort, cSchema
local oServer

REQUEST DBFCDX

? "setujem default engine ..." + RDDENGINE
RDDSETDEFAULT( RDDENGINE )

REQUEST HB_CODEPAGE_SL852 
REQUEST HB_CODEPAGE_SLISO

SET DELETED ON

HB_CDPSELECT("SL852")

if setmode(MAXROWS(), MAXCOLS())
   ? "hej mogu setovati povecani ekran !"
else
   ? "ne mogu setovati povecani ekran !"
   QUIT
endif

public gRj := "N"
public gReadOnly := .f.
public gSQL := "N"
public Invert := .f.

set_a_dbfs()

//_thread_aDBFs := ACLONE(gaDBFs)

if f18_login_screen( @cHostname, @cDatabase, @cUser, @cPassword, @nPort, @cSchema ) = .f.
	quit
endif

__server_params := hb_hash()
__server_params["host_name"] := cHostName
__server_params["database"] := cDatabase
__server_params["user"] := cUser
__server_params["password"] := cPassword
__server_params["port"] := nPort
__server_params["schema"] := cSchema

// try to loggon...

my_server_login(my_server_params())

log_write(my_server_params()["host_name"] + " / " + my_server_params()["database"] + " / " + my_server_params()["user"] + " / " +  STR(my_server_params()["port"])  + " / " + my_server_params()["schema"])

if my_server():NetErr()
      
	  clear screen

	  ?
	  ? "Greska sa konekcijom na server:"
	  ? "==============================="
	  ? oServer:ErrorMsg()

	  log_write( oServer:ErrorMsg() )
	  inkey(0)
	  quit

endif

// init_threads()

return oServer 


// ------------------
// set_get server
// ------------------
function pg_server(server)

if server <> NIL
   __server := server
endif
return __server

function my_server(server)
return pg_server(server)

// ----------------------------
// set_get server_params
// -------------------------------
function my_server_params(params)
local  _key

if params <> nil
   for each _key in params:Keys
       __server_params[_key] := params[_key]
   next
endif
return __server_params 

// --------------------------
// --------------------------
function my_server_login(params)

if params == NIL
   params := __server_params
endif

__server :=  TPQServer():New( params["host_name"], params["database"], params["user"], params["password"], params["port"], params["schema"] )


if !__server:NetErr()
	set_sql_search_path()
endif

return __server

// --------------------------
// --------------------------
function my_server_logout()
__server:Close()

return __server

// -----------------------------
// -----------------------------
function my_server_search_path(path)
local _key := "search_path"

if path == nil
   if !hb_hhaskey(__server_params, _key)
     __server_params[_key] := "fmk,public"
   endif
else
   __server_params[_key] := path
endif

return __server_params[_key]


// -----------------------------
// -----------------------------
function f18_user()
return __server_params["user"]


function f18_database()
return __server_params["database"]


function my_user()
return f18_user()



