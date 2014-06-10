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



// ----------------------------------------
// vraca saldo partnera
// ----------------------------------------
function get_fin_partner_saldo( id_partner, id_konto, id_firma )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _saldo := 0

_qry := "SELECT SUM( CASE WHEN d_p = '1' THEN iznosbhd ELSE -iznosbhd END ) AS saldo FROM fmk.fin_suban " + ;
        " WHERE idpartner = " + _sql_quote( id_partner ) + ;
        " AND idkonto = " + _sql_quote( id_konto ) + ;
        " AND idfirma = " + _sql_quote( id_firma )

_table := _sql_query( _server, _qry )

oRow := _table:GetRow( 1 )

_saldo := oRow:FieldGet( oRow:FieldPos("saldo"))

if VALTYPE( _saldo ) == "L"
    _saldo := 0
endif

return _saldo 



// -----------------------------------------
// datum posljednje uplate partnera
// -----------------------------------------
function g_dpupl_part( id_partner, id_konto, id_firma )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _max := CTOD("")

_qry := "SELECT MAX( datdok ) AS uplata FROM fmk.fin_suban " + ;
        " WHERE idpartner = " + _sql_quote( id_partner ) + ;
        " AND idkonto = " + _sql_quote( id_konto ) + ;
        " AND idfirma = " + _sql_quote( id_firma ) + ;
        " AND d_p = '2' "

_table := _sql_query( _server, _qry )

oRow := _table:GetRow( 1 )

_max := oRow:FieldGet( oRow:FieldPos("uplata"))

if VALTYPE( _max ) == "L"
    _max := CTOD("")
endif

return _max




// --------------------------------------------
// datum posljednje promjene kupac / dobavljac
// --------------------------------------------
function g_dpprom_part( id_partner, id_konto, id_firma )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _max := CTOD("")

_qry := "SELECT MAX( datdok ) AS uplata FROM fmk.fin_suban " + ;
        " WHERE idpartner = " + _sql_quote( id_partner ) + ;
        " AND idkonto = " + _sql_quote( id_konto ) + ;
        " AND idfirma = " + _sql_quote( id_firma )

_table := _sql_query( _server, _qry )

oRow := _table:GetRow( 1 )

_max := oRow:FieldGet( oRow:FieldPos("uplata"))

if VALTYPE( _max ) == "L"
    _max := CTOD("")
endif

return _max




// -------------------------------------------------------
// ispisuje na ekranu box sa stanjem kupca
// -------------------------------------------------------
function g_box_stanje( cPartner, cKKup, cKDob )
local nSKup := 0
local nSDob := 0
local dDate := CTOD("")
local nSaldo := 0
local nX
private GetList:={}

if cKKUP <> NIL
    nSKup := get_fin_partner_saldo( cPartner, cKKup, gFirma )
    dDate := g_dpupl_part( cPartner, cKKup, gFirma )
endif

if cKDOB <> NIL
    nSDob := get_fin_partner_saldo( cPartner, cKDob, gFirma )
endif

nSaldo := nSKup + nSDob

if nSaldo = 0
	return .t.
endif

nX := 1

Box(, 9, 50)

	@ m_x + nX, m_y + 2 SAY "Trenutno stanje partnera:"

    ++ nX

    @ m_x + nX, m_y + 2 SAY "-----------------------------------------------"
    		
	++ nX

    if cKKUP <> NIL
	    @ m_x + nX, m_y + 2 SAY PADR( "(1) stanje na kontu " + cKKup + ": " + ALLTRIM(STR(nSKup, 12, 2)) + " KM", 45 ) COLOR IF(nSKup > 100, "W/R+", "W/G+")
    endif

    ++ nX
    
    if cKDOB <> NIL
	    @ m_x + nX, m_y + 2 SAY PADR( "(2) stanje na kontu " + cKDob + ": " + ALLTRIM(STR(nSDob,12,2)) + " KM", 45 ) COLOR "W/GB+"
    endif

	++ nX

	@ m_x + nX, m_y + 2 SAY "-----------------------------------------------"
    	++nX

	@ m_x + nX, m_y + 2 SAY "Total (1+2) = " + ALLTRIM(STR(nSaldo,12,2)) + " KM" COLOR IF(nSaldo > 100, "W/R+", "W/G+")
	
	nX += 2

    @ m_x + nX, m_y + 2 SAY "Datum zadnje uplate: " + DToC(dDate)
		
    inkey(0)

BoxC()

return .t.





