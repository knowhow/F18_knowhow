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
ENDCLASS

METHOD FaktCounter:New(idfirma, idtipdok, datdok, new_number)	
local _param := fakt_params()

// return  PADR( REPLICATE( "0", _param["brojac_numericki_dio"]), FAKT_BRDOK_LENGTH )

::super:New(0, 12, 6, "", "<G2>", "0", {"fakt", idfirma, idtipdok},  datdok)

if new_number == NIL
     new_number := .f.
endif

if new_number
   ::new_document_number()
endif

return SELF

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
// brdok nula
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

_cnt := FaktCounter(_firma, _td, _datdok)
_cnt:decode(field->brdok) 

if _cnt:counter > 0
    // nemam sta raditi, broj je vec setovan
    PopWa()
    return .f.
endif

_null_brdok := _cnt:to_str()

_firma := field->idfirma
_td    := field->idtipdok
_datdok := field->datdok

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
