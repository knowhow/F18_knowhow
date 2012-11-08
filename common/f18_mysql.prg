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


static __usr_str := "user"
static __pwd_str := "password"
static __server_str := "server"
static __db_str := "database"

// ------------------------------------------------
// puni hash matricu sa parametrima
// ------------------------------------------------
function get_mysql_server_params( var )
local _params := hb_hash()

// mogu se setovati za vise parametara
if var == NIL
	var := ""
endif

_params[ __server_str ] := ALLTRIM( fetch_metric( var + "_mysql_par_server", my_user(), "" ) )
_params[ __usr_str ] := ALLTRIM( fetch_metric( var + "_mysql_par_user", my_user(), "" ) )
_params[ __pwd_str ] := ALLTRIM( fetch_metric( var + "_mysql_par_password", my_user(), "" ) )
_params[ __db_str ] := ALLTRIM( fetch_metric( var + "_mysql_par_database", my_user(), "" ) )

return _params



// ------------------------------------------------
// puni hash matricu sa parametrima
// ------------------------------------------------
function set_mysql_server_params( params, var )

if var == NIL
	var := ""
endif

set_metric( var + "_mysql_par_server", my_user(), params[ __server_str ] )
set_metric( var + "_mysql_par_user", my_user(), params[ __usr_str ] )
set_metric( var + "_mysql_par_password", my_user(), params[ __pwd_str ] )
set_metric( var + "_mysql_par_database", my_user(), params[ __db_str ] )

return



// ------------------------------------------------
// forma setovanja parametara
// varijanta koja se koristi unutar parametara
// generalno moze biti NIL
// ------------------------------------------------
function mysql_login_form( var )
local _i := 1
local _left := 15
local _username, _password, _database, _server
local _params

// uzmi trenutne parametre iz sqldb-a
_params := get_mysql_server_params( var )

// setuj u lokalne varijable
_username := PADR( _params[ __usr_str ], 100 )
_password := PADR( _params[ __pwd_str ], 100 )
_database := PADR( _params[ __db_str ], 100 )
_server := PADR( _params[ __server_str ], 200 )

Box(, 6, 70 )

	// forma parametara za login

	@ m_x + _i, m_y + 2 SAY PADR( "*** MYSQL login parametri ***", 50 ) COLOR "I"

	++ _i
	++ _i
	
	@ m_x + _i, m_y + 2 SAY PADL( "Adresa servera:", _left ) GET _server PICT "@S30"
	
	++ _i

	@ m_x + _i, m_y + 2 SAY PADL( "Baza:", _left ) GET _database PICT "@S15"

	++ _i
	++ _i

	@ m_x + _i, m_y + 2 SAY PADL( "Korisnik:", _left ) GET _username PICT "@S15"
	@ m_x + _i, col() + 1 SAY "Lozinka:" GET _password PICT "@S15"

	read

BoxC()

if LastKey() == K_ESC
	return .f.
endif

// setuj u trenutnu matricu parametre
_params[ __usr_str ] := ALLTRIM( _username )
_params[ __pwd_str ] := ALLTRIM( _password )
_params[ __db_str ] := ALLTRIM( _database )
_params[ __server_str ] := ALLTRIM( _server )

// snimi tekuce parametre u sqldb
set_mysql_server_params( _params, var )

return .t.




// ------------------------------------------------
// konektor za mysql
// =================
//
// _var := "" // ovo moze biti da 2 izvjestaja 
//              koriste razlicite parametre za
//              pristup serveru
//              generalno moze biti NIL
// _params := get_mysql_server_params( _var )
// oServer := mysql_server( _params )
//
// if oServer <> NIL
//    proslijedi query itd... 
// endif
//
// ------------------------------------------------
function mysql_server( params )
local oServer := NIL
local _server_addr := params[ __server_str ]
local _server_user := params[ __usr_str ]
local _server_pwd := params[ __pwd_str ]
local _server_db := params[ __db_str ]

#ifdef __PLATFORM__LINUX

	if params == NIL
		return NIL
	endif

	oServer := TMySQLServer():New( _server_addr, _server_user, _server_pwd )

	if oServer:NetErr()
		Alert( oServer:Error() )
		return NIL
	endif

	oServer:SelectDB( _server_db )

	return oServer

#else
	return NIL
#endif

return NIL






