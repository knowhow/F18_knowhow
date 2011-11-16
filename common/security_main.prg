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

cHostName := PADR( f18_ini_read( "F18_server", "host_name", ini_home_root() ), 100 )
cDatabase := PADR( f18_ini_read( "F18_server", "database", ini_home_root() ), 100 )
cUser := PADR( f18_ini_read( "F18_server", "user_name", ini_home_root() ), 100 )
cSchema := PADR( f18_ini_read( "F18_server", "schema", ini_home_root() ), 100 )
cPort := f18_ini_read( "F18_server", "port", ini_home_root() )
cPassword := PADR( cPassword, 100 )

if EMPTY( cPort )
	cPort := "0"
endif

nPort := VAL( cPort )

if EMPTY(cHostName) .or. EMPTY(cPort)
	cConfigureServer := "D"
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

@ nX, nLeft SAY PADL( "LOZINKA:", 15 ) GET cPassword PICT "@S30" COLOR "BG/BG"

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
f18_ini_write( "F18_server", "database", cDatabase, ini_home_root() )
f18_ini_write( "F18_server", "host_name", cHostname, ini_home_root() )
f18_ini_write( "F18_server", "user_name", cUser, ini_home_root() )
f18_ini_write( "F18_server", "schema", cSchema, ini_home_root() )
f18_ini_write( "F18_server", "port", ALLTRIM(STR(nPort)), ini_home_root() )

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


