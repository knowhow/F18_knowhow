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
local oServer, oRow, oTable
local _server_params
local _sql_qry := "SELECT * FROM boards LIMIT 100"


// setuj parametre
redmine_login_form( nil )

_server_params := get_redmine_server_params( nil )

oServer := redmine_server( _server_params )

oTable := oServer:Query( _sql_qry )

oRow := oTable:GetRow(1)

MsgBeep( ALLTRIM( oRow:Fieldget( oRow:Fieldpos("name") ) ) )

return




