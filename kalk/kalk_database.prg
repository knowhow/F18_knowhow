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


#include "kalk.ch"



// --------------------------------------------------------------------------
// vraca stanje artikla na magacinu
// --------------------------------------------------------------------------
function kalk_kol_stanje_artikla_magacin( m_konto, id_roba, datum_do )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local oRow
local _stanje

if datum_do == NIL
    datum_do := DATE()
endif

_qry := "SELECT " + ;
        " SUM( " + ;
            " CASE " + ;
                " WHEN mu_i = '1' AND idvd NOT IN ('12', '22', '94') THEN kolicina " + ;
                " WHEN mu_i = '1' AND idvd IN ('12', '22', '94') THEN -kolicina " + ;
                " WHEN mu_i = '5' THEN -kolicina " + ;
                " WHEN mu_i = '8' THEN -kolicina " + ;
            " END ) as stanje_m " + ;
        " FROM fmk.kalk_kalk " + ;
        " WHERE " + ;
        " idfirma = " + _sql_quote( gFirma ) + ;
        " AND mkonto = " + _sql_quote( m_konto ) + ;
        " AND idroba = " + _sql_quote( id_roba ) + ;
        " AND " + _sql_date_parse( "datdok", CTOD(""), datum_do )

_table := _sql_query( _server, _qry )
_table:Refresh()

oRow := _table:GetRow( 1 )

_stanje := oRow:FieldGet( oRow:FieldPos("stanje_m"))

if VALTYPE( _stanje ) == "L"
    _stanje := 0
endif

return _stanje




// --------------------------------------------------------------------------
// vraca stanje artikla u prodavnici
// --------------------------------------------------------------------------
function kalk_kol_stanje_artikla_prodavnica( p_konto, id_roba, datum_do )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local oRow
local _stanje

if datum_do == NIL
    datum_do := DATE()
endif

_qry := "SELECT SUM( CASE WHEN pu_i = '1' THEN kolicina-gkolicina-gkolicin2 " + ;
        " WHEN pu_i = '5' THEN -kolicina " + ;
        " WHEN pu_i = 'I' THEN -gkolicin2 ELSE 0 END ) as stanje_p " + ;
        " FROM fmk.kalk_kalk " + ;
        " WHERE " + ;
        " idfirma = " + _sql_quote( gFirma ) + ;
        " AND pkonto = " + _sql_quote( p_konto ) + ;
        " AND idroba = " + _sql_quote( id_roba ) + ;
        " AND " + _sql_date_parse( "datdok", CTOD(""), datum_do )

_table := _sql_query( _server, _qry )
_table:Refresh()

oRow := _table:GetRow( 1 )

_stanje := oRow:FieldGet( oRow:FieldPos("stanje_p"))

if VALTYPE( _stanje ) == "L"
    _stanje := 0
endif

return _stanje



// --------------------------------------------------------------
// vracaju se stavke iz _kalk tabele u _kalk_pripr
// --------------------------------------------------------------
function vrati_stavke_iz_kalk_tmp()
local _rec
local _tmp_count := 0
local _ret := .f.

close all

select ( F_KALK_PRIPR )
if !Used()
	O_KALK_PRIPR
endif

if kalk_pripr->( RECCOUNT() ) == 0 

	O__KALK
	select _kalk
    
	do while !EOF()

    	_rec := dbf_get_rec()

        select kalk_pripr
        append blank

		++ _tmp_count
		
        dbf_update_rec( _rec )

        select _kalk
        skip            

  	enddo
            
endif
    
close all

if _tmp_count > 0
	_ret := .t.
	MsgBeep( "Stavke koje su bile privremeno sklonjene sada su vracene! Obradite ih!" )
endif

return _ret



