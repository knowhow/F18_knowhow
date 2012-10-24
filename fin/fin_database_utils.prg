/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


// ----------------------------------------------------------------
// vraca naredni redni broj fin naloga
// ----------------------------------------------------------------
function fin_dok_get_next_rbr( idfirma, idvn, brnal )
local _rbr := ""

// vrati mi zadnji redni broj sa dokumenta
_rbr := fin_dok_get_last_rbr( idfirma, idvn, brnal )

if EMPTY( _rbr )
    return _rbr
endif

// uvecaj i sredi redni broj
_rbr := STR( VAL( ALLTRIM( _rbr ) ) + 1 , 4 )

return _rbr


// ----------------------------------------------------------------
// vraca najveci redni broj stavke u nalogu
// ----------------------------------------------------------------
function fin_dok_get_last_rbr( idfirma, idvn, brnal )
local _qry, _qry_ret, _table
local _server := pg_server()
local oRow
local _last

_qry := "SELECT MAX(rbr) AS last FROM fmk.fin_suban " + ;
        " WHERE idfirma = " + _sql_quote( idfirma ) + ;
        " AND idvn = " + _sql_quote( idvn ) + ;
        " AND brnal = " + _sql_quote( brnal )

_table := _sql_query( _server, _qry )
_table:Refresh()

oRow := _table:GetRow( 1 )

_last := oRow:FieldGet( oRow:FieldPos("last"))

if VALTYPE( _last ) == "L"
    _last := ""
endif

return _last



