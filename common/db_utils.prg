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

#include "fmk.ch"


function test_sql_table_browse()
local _srv := pg_server()
local _c_qry, _o_qry
local _brw

_c_qry := "SELECT * FROM fmk.roba ORDER BY id;"
_o_qry := _sql_query( _srv, _c_qry )

_brw := TBrowseSQL():new( 2, 2, 20, 70, _srv, _o_qry, "fmk.roba" )
_brw:BrowseTable( .f., NIL )

return

