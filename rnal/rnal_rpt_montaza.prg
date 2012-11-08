/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "rnal.ch"


// varijanta izvjestaja
static __rpt_var := NIL



// --------------------------------------------------
// izvjestaj montaze koji se generise na osnovu
// redmine podataka
// --------------------------------------------------
function rnal_rpt_montaza()
local _params := hb_hash()
local _data := NIL

#ifndef __PLATFORM__LINUX
	MsgBeep("Izvjestaj radi samo na linux oper.sistemu !!!")
	return
#endif

// uslovi izvjestaja
if !get_vars( @_params )
	return
endif

// kreiraj izvjestaj
_data := cre_rpt( _params )

if _data <> NIL
	// kreiraj xml
	cre_xml( _data, _params )

endif

return



// --------------------------------------------------
// kreiraj izvjestaj i vrati mi u tabelu
// --------------------------------------------------
static function cre_rpt( params )
local _server_params
local oServer
local oTable
local _query

// daj mi parametre konekcije
_server_params := get_mysql_server_params( __rpt_var )

// konektuj se na server
oServer := mysql_server( _server_params )
// da li je server ziv ???
if oServer == NIL
	return NIL
endif

_query := "SELECT * FROM boards LIMIT 100"

oTable := oServer:Query( _query )

if oTable == NIL
	return NIL
endif

return oTable




// -------------------------------------------------
// generisi xml fajl
// -------------------------------------------------
static function cre_xml( table, params )
local oRow

oRow := table:GetRow(1)

MsgBeep( ALLTRIM( oRow:Fieldget( oRow:Fieldpos("name") ) ) )

return





// --------------------------------------------------
// uslovi izvjestaja
// --------------------------------------------------
static function get_vars( params )
local _i := 1
local _conn := "N"

Box(, 10, 70 )

	@ m_x + _i, m_y + 2 SAY "Podesiti parametre konekcije (D/N) ?" GET _conn VALID _conn $ "DN" PICT "@!"

	read

	if _conn == "D"
		// setuj parametre konekcije
		mysql_login_form( __rpt_var )
	endif

	++ _i
	++ _i

	@ m_x + _i, m_y + 2 SAY "datum od"

	read	

BoxC()

if LastKey() == K_ESC
	return .f.
endif

// snimi parametre
// _params[""] := param1
// _params[""] := param2
// _params[""] := param3
// _params[""] := param4


return .t.






