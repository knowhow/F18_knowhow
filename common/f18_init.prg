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

/* ------------------------
  vraca postgresql oServer 
  ------------------------- */
function init_f18_app(cHostName, cDatabase, cUser, cPassword, nPort, cSchema)
local oServer
local cServer_search_path := pg_search_path()

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

log_write(cHostName + " / " + cDatabase + " / " + cUser + " / " + cPassWord + " / " +  STR(nPort)  + " / " + cSchema)

// try to loggon...
oServer := TPQServer():New( cHostName, cDatabase, cUser, cPassWord, nPort, cSchema )

if oServer:NetErr()
      
	  clear screen

	  ?
	  ? "Greska sa konekcijom na server:"
	  ? "==============================="
	  ? oServer:ErrorMsg()

	  log_write( oServer:ErrorMsg() )
      
	  inkey(0)
 
	  quit

endif

_set_sql_path( oServer, cServer_search_path )

// init_threads()

return oServer 



