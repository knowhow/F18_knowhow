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


// -----------------------------------------
// test funkcija mysql
// -----------------------------------------
function rnal_mysql_test()
local oServer, oRow, oQuery
local _server_addr := "192.168.55.29"
local _server_user := "root"
local _server_pwd := "47EDzsqL"
local _server_db := "redmine"
local _sql_qry := "SELECT * FROM queries"

#ifdef __PLATFORM__LINUX

oServer := TMySQLServer():New( _server_addr, _server_user, _server_pwd )

if oServer:NetErr()
	Alert( oServer:Error() )
	return
endif

oServer:SelectDB( _server_db )

oQuery := oServer:Query( _sql_qry )

oRow := oQuery:GetRow()

#endif

return




