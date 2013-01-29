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

#include "fakt.ch"
#include "hbclass.ch"
#include "common.ch"

CLASS FinCounter  INHERIT  DocCounter
    METHOD New
    METHOD set_sql_get 
ENDCLASS

METHOD FinCounter:New(idfirma, idvn, datnal, new_number)	
local _param := fakt_params()

::super:New(0, 12, 6, "", "<G2>", "0", {"fin", idfirma, idvn},  datnal)

if new_number == NIL
     new_number := .f.
endif

if new_number
   ::new_document_number()
endif

return SELF

// ------------------------------------------------
// ------------------------------------------------
METHOD FinCounter:set_sql_get()

::c_sql_get := "select brnal from fmk.fin_nalog where idfirma=" + _sql_quote(::a_s_param[2]) + ;
   " AND idvn=" + _sql_quote(::a_s_param[3]) + ;
   " AND EXTRACT(YEAR FROM datnal)=" + ALLTRIM(STR(::year)) + ;
   " ORDER BY (datnal, brnal) DESC LIMIT 1"

return .t.


// --------------------------------------------------------
// brdok nula
// --------------------------------------------------------
function fin_brnal_0(idfirma, idvn, datnal)
local _counter := FinCounter():New(idfirma, idvn, datnal)

return _counter:to_str()

// --------------------------------------------------------
// generisi nov broj naloga uzevsi serverski brojac
// --------------------------------------------------------
function fin_novi_broj_naloga(idfirma, idvn, datnal)
local _counter := FinCounter():New(idfirma, idvn, datnal, .t.)

return _counter:to_str()

// --------------------------------------------------------
// brnal nula
// --------------------------------------------------------
function fin_rewind(idfirma, idvn, datnal, brnal)
local _counter := FinCounter():New(idfirma, idvn, datnal)

_counter:rewind(brnal)

return .t.


// ------------------------------------------------------------
// setuj broj dokumenta
// ------------------------------------------------------------
function fin_set_broj_naloga()
local _broj_naloga
local _t_rec
local _firma, _td, _datnal, _cnt, _null_brnal

PushWa()

select fin_pripr
go top

_firma  := field->idfirma
_td     := field->idvn

// UPDATE: datnal u finansijama (nalog, suban) je bio besmislen
//         on  je setovan sa datumom azuriranja
//         jedini smislen datum u fin_pripr je datdok
//         kod ažuriranja (pnalog) je sada setovano da je datnal=MAX(datdok)

_datnal := field->datdok
_brnal  := field->brnal

_cnt := FinCounter():New(_firma, _td, _datnal)
_cnt:decode(_brnal)

if _cnt:counter > 0
    _cnt:update_server_counter_if_counter_greater()
    PopWa()
    return .f.
endif

_null_brnal := _cnt:to_str()

// daj mi novi broj dokumenta
_broj_naloga := fin_novi_broj_naloga( _firma, _td, _datnal )

select fin_pripr
set order to tag "1"
go top

do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    if (field->idfirma == _firma) .and. (field->idvn == _td) .and. (field->brnal == _null_brnal)
        replace field->brnal with _broj_naloga
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
local _god := year_2str(YEAR(DATE()))

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Firma:" GET _firma
    @ m_x + 1, col() + 1 SAY "Tip" GET _tip_dok
    @ m_x + 1, col() + 1 SAY "Godina" GET _godina

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: fin/10/10
    _param := "fin" + "/" + _firma + "/" + _tip_dok + "/" + _godina
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


// ---------------------------------------
// ---------------------------------------
function fix_brnal(brnal)
local _cnt
_cnt := FinCounter():New("99", "99", DATE())
_cnt:fix(@brnal)

return .t.



