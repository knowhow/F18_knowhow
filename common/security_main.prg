/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

// f18, login screen
function f18_login_screen( cHostname, cDatabase, cUser, cPassword, nPort, cSchema )
local lSuccess := .t.	
local nX := 5
local nLeft := 7
local cPort
local cConfigureServer := "N"
local params

params := hb_hash()
params["host_name"] := nil
params["database"] := nil
params["user_name"] := nil
params["schema"] := nil
params["port"] := nil

f18_ini_read("F18_server", @params, .t.)


cHostName := params["host_name"]
cDatabase := params["database"]
cUser := params["user_name"]
cSchema := params["schema"]
cPort := params["port"]
cPassword := PADR( cPassword, 100 )

if (cHostName == nil) .or. (cPort == nil)
	cConfigureServer := "D"
endif 

if cHostName == nil
   cHostName := PADR("localhost", 100)
endif

if cPort == nil
   nPort := 5432
else
   nPort := VAL( cPort )
endif

if cSchema == nil
  cSchema :=  PADR("fmk", 40)
endif

if cDatabase == nil
  cDatabase := PADR("bringout1", 100)
endif

if cUser == nil
  cUser := PADR("admin", 100)
endif

clear screen

@ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

++ nX

@ nX, nLeft SAY PADC("***** Unestite podatke za pristup *****", 60)

++ nX
++ nX
@ nX, nLeft SAY PADL( "Konfigurisati server ?:", 21 ) GET cConfigureServer VALID cConfigureServer $ "DN" PICT "@!"
++ nX 

read

if cConfigureServer == "D"
	++ nX
	@ nX, nLeft SAY PADL( "Server:", 8 ) GET cHostname PICT "@S20"
	@ nX, 37 SAY "Port:" GET nPort PICT "9999"
	@ nX, 48 SAY "Shema:" GET cSchema PICT "@S15"
else	
	++ nX
endif

++ nX
++ nX

@ nX, nLeft SAY PADL( "Baza:", 15 ) GET cDatabase PICT "@S30"

++ nX
++ nX

@ nX, nLeft SAY PADL( "KORISNIK:", 15 ) GET cUser PICT "@S30"

++ nX
++ nX

@ nX, nLeft SAY PADL( "LOZINKA:", 15 ) GET cPassword PICT "@S30"

read

if Lastkey() == K_ESC
	return .f.
endif

// podesi varijable
cHostName := ALLTRIM( cHostname )
cUser := ALLTRIM( cUser )
cPassword := ALLTRIM( cPassword )
cDatabase := ALLTRIM( cDatabase )
cSchema := ALLTRIM( cSchema )

// snimi u ini fajl...
params["database"] := cDatabase
params["host_name"] := cHostName
params["user_name"] := cUser
params["schema"] := cSchema 
params["port"] := ALLTRIM(STR(nPort))

f18_ini_write( "F18_server", params, .t.)

return lSuccess



function ImaPravoPristupa( cObjekat, cKomponenta, cFunkcija )
local cTmpQry
local cTable := "public.privgranted"
local oTable
local lResult := .t.
local oServer := pg_server()
local nResult

nResult := table_count(cTable, "privilege = " + _sql_quote( cFunkcija ) ) 

// provjeri prvo da li ima uopste ovih zapisa u tabeli
if nResult <> 1
	log_write( cTable + " " + "privilege = " + cFunkcija + " count =" + STR(nResult))
	return lResult
endif

cTmpQry := "SELECT granted FROM " + cTable + " WHERE privilege = " + _sql_quote( cFunkcija )
oTable := _sql_query( oServer, cTmpQry )
if oTable == NIL
	MsgBeep( "problem sa:" + cTmpQry)
    quit
endif

if oTable:Fieldget( oTable:Fieldpos("granted") ) == "false"
	lResult := .f.
endif

return lResult



// vraca id user-a
function GetUserID( cUser )
local cTmpQry
local cTable := "public.usr_bak"
local oTable
local nResult
local oServer := pg_server()

cTmpQry := "SELECT usr_id FROM " + cTable + " WHERE usr_username = " + _sql_quote( cUser )
oTable := _sql_query( oServer, cTmpQry )
IF oTable == NIL
      MsgBeep( "problem sa:" + cTmpQry)
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("usr_id") )

return nResult


// vraca username usera iz sec.systema
function GetUserName( nUser_id )
local cTmpQry
local cTable := "public.usr_bak"
local oTable
local cResult
local oServer := pg_server()

cTmpQry := "SELECT usr_username FROM " + cTable + " WHERE usr_id = " + ALLTRIM(STR( nUser_id ))
oTable := _sql_query( oServer, cTmpQry )
IF oTable == NIL
      MsgBeep( "problem sa:" + cTmpQry)
      QUIT
ENDIF

cResult := oTable:Fieldget( oTable:Fieldpos("usr_username") )

return cResult


// vraca full username usera iz sec.systema
function GetFullUserName( nUser_id )
local cTmpQry
local cTable := "public.usr_bak"
local oTable
local cResult
local oServer := pg_server()

cTmpQry := "SELECT usr_propername FROM " + cTable + " WHERE usr_id = " + ALLTRIM(STR( nUser_id ))
oTable := _sql_query( oServer, cTmpQry )
IF oTable == NIL
      MsgBeep( "problem sa:" + cTmpQry)
      QUIT
ENDIF

cResult := oTable:Fieldget( oTable:Fieldpos("usr_propername") )

return cResult


