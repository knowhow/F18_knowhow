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

CLASS FaktCounter  INHERIT  DocCounter
    METHOD New
    METHOD set_sql_get
ENDCLASS

METHOD FaktCounter:New(idfirma, idtipdok, datdok, new_number)	
local _param := fakt_params()

// return  PADR( REPLICATE( "0", _param["brojac_numericki_dio"]), FAKT_BRDOK_LENGTH )

//    @ m_x+15,m_y+2 SAY "Numericki dio broja dokumenta:" GET gNumDio PICT "99"
//    ovo treba proglasiti za legacy


::super:New(0, 12, gNumDio, "", "<G2>", "0", {"fakt", idfirma, idtipdok},  datdok)

if new_number == NIL
     new_number := .f.
endif

if new_number
   ::new_document_number()
endif


return SELF

// --------------------------------------
// --------------------------------------
METHOD FaktCounter:set_sql_get()

// uzmi brdok iz fakt_doks za zadatu firmu, tip dokumenta, i dokumente iz zadane godine
::c_sql_get := "select brdok from fmk.fakt_doks where idfirma=" + _sql_quote(::a_s_param[2]) + ;
               " AND idtipdok=" + _sql_quote(::a_s_param[3]) + ;
               " AND EXTRACT(YEAR FROM datdok)=" + ALLTRIM(STR(::year)) + ;
               " ORDER BY (datdok, brdok) DESC LIMIT 1"

return .t.



// --------------------------------------------------------
// generisi nov broj dokumenta uzevsi serverski brojac
// --------------------------------------------------------
function fakt_novi_broj_dokumenta(idfirma, idtipdok, datdok)
local _counter := FaktCounter():New(idfirma, idtipdok, datdok, .t.)

return _counter:to_str()

// --------------------------------------------------------
// brdok nula
// --------------------------------------------------------
function fakt_brdok_0(idfirma, idtipdok, datdok)
local _counter := FaktCounter():New(idfirma, idtipdok, datdok)

return _counter:to_str()



// --------------------------------------------------------
// vrati brojac unazad, ako treba 
// nakon brisanja dokumenta koji je vec dobio broj
// --------------------------------------------------------
function fakt_rewind(idfirma, idtipdok, datdok, brdok)
local _counter := FaktCounter():New(idfirma, idtipdok, datdok)

_counter:rewind(brdok)

return .t.


// ------------------------------------------------------------
// setuj broj dokumenta
// ------------------------------------------------------------
function fakt_set_broj_dokumenta()
local _broj_dokumenta
local _t_rec
local _firma, _td, _datdok, _cnt, _null_brdok

PushWa()

select fakt_pripr
go top

_firma := field->idfirma
_td    := field->idtipdok
_datdok := field->datdok

_cnt := FaktCounter():New(_firma, _td, _datdok)
_cnt:decode(field->brdok) 

if _cnt:counter > 0
    _cnt:update_server_counter_if_counter_greater()
    PopWa()
    return .f.
endif

_null_brdok := _cnt:to_str()

// daj mi novi broj dokumenta
_broj_dokumenta := fakt_novi_broj_dokumenta( _firma, _td, _datdok )

select fakt_pripr
set order to tag "1"
go top

do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    if (field->idfirma == _firma) .and. (field->idtipdok == _td) .and. (field->brdok == _null_brdok)
        replace field->brdok with _broj_dokumenta
    endif
    go (_t_rec)
enddo

O_FAKT_ATRIB

// promjeni mi i u fakt_atributi
select fakt_atrib
set order to tag "1"
go top

do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1

    if (field->idfirma == _firma) .and. (field->idtipdok == _td) .and. (field->brdok == _null_brdok)
        replace field->brdok with _broj_dokumenta
    endif
    go ( _t_rec )
enddo

select ( F_FAKT_ATRIB )
use

PopWa()
 
return .t.


function SljedBrFakt(cIdRj,cIdVd,dDo,cIdPartner)
local nArr:=SELECT()
local cBrFakt
_datdok:=dDo
_idpartner:=cIdPartner
cBrFakt:= fakt_novi_broj_dokumenta( cIdRJ, cIdVd )
select (nArr)
return cBrFakt


// ---------------------------------------
// ---------------------------------------
function fakt_fix_brdok(brdok)
local _cnt
_cnt := FaktCounter():New("99", "99", DATE())
_cnt:fix(@brdok)

return .t.
