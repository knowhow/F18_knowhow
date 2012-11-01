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




// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
function fin_reset_broj_dokumenta( firma, tip_dokumenta, broj_dokumenta )
local _param
local _broj := 0

// param: fin/10/10
_param := "fin" + "/" + firma + "/" + tip_dokumenta 
_broj := fetch_metric( _param, nil, _broj )

if VAL( broj_dokumenta ) == _broj
    -- _broj
    // smanji globalni brojac za 1
    set_metric( _param, nil, _broj )
endif

return



// ------------------------------------------------------------------
// fin, uzimanje novog broja za fin dokument
// ------------------------------------------------------------------
function fin_novi_broj_dokumenta( firma, tip_dokumenta )
local _broj := 0
local _broj_nalog := 0
local _len_broj := 8
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()

// param: fin/10/10
_param := "fin" + "/" + firma + "/" + tip_dokumenta 

_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_NALOG
set order to tag "1"
go top

seek firma + tip_dokumenta + "Ž"

skip -1

if field->idfirma == firma .and. field->idvn == tip_dokumenta
    _broj_nalog := VAL( field->brnal )
else
    _broj_nalog := 0
endif

// uzmi sta je vece, nalog broj ili globalni brojac
_broj := MAX( _broj, _broj_nalog )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
_ret := PADL( ALLTRIM( STR( _broj ) ), _len_broj, "0" )

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret


// ------------------------------------------------------------
// setuj broj dokumenta u pripremi ako treba !
// ------------------------------------------------------------
function fin_set_broj_dokumenta()
local _broj_dokumenta
local _t_rec, _rec
local _firma, _td, _null_brdok
local _len_broj := 8

PushWa()

select fin_pripr
go top

_null_brdok := PADR( "0", _len_broj )
        
if field->brnal <> _null_brdok 
    // nemam sta raditi, broj je vec setovan
    PopWa()
    return .f.
endif

_firma := field->idfirma
_td := field->idvn

// daj mi novi broj dokumenta
_broj_dokumenta := fin_novi_broj_dokumenta( _firma, _td )

select fin_pripr
set order to tag "1"
go top

do while !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

    if field->idfirma == _firma .and. field->idvn == _td .and. field->brnal == _null_brdok
        _rec := dbf_get_rec()
        _rec["brnal"] := _broj_dokumenta
        dbf_update_rec( _rec )
    endif

    go (_t_rec)

enddo

PopWa()
 
return .t.


// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function fin_set_param_broj_dokumenta()
local _param
local _broj := 0
local _broj_old
local _firma := gFirma
local _tip_dok := "10"

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Nalog:" GET _firma
    @ m_x + 1, col() + 1 SAY "-" GET _tip_dok

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: fin/10/10
    _param := "fin" + "/" + _firma + "/" + _tip_dok
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj naloga:" GET _broj PICT "99999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return






