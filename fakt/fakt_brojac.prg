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


// -----------------------------------------------
// vraca novi broj dokumenta
// -----------------------------------------------
static function _nBrDok( cFirma, cTip, cBrDok )
cBrDok := fakt_brojac(0)
return .t.


// ------------------------------------------------------------------
// fakt, uzimanje novog broja za fakt dokument
// ------------------------------------------------------------------
function fakt_novi_broj_dokumenta( firma, tip_dokumenta, sufiks )
local _broj := 0
local _broj_doks := 0
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()

if sufiks == nil
    sufiks := ""
endif

// param: fakt/10/10
_param := "fakt" + "/" + firma + "/" + tip_dokumenta 

_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_FAKT_DOKS
set order to tag "1"
go top
seek firma + tip_dokumenta + "Ž"
skip -1

if field->idfirma == firma .and. field->idtipdok == tip_dokumenta
    _broj_doks := VAL( PADR( field->brdok, gNumDio ) )
else
    _broj_doks := 0
endif

// uzmi sta je vece, doks broj ili globalni brojac
_broj := MAX( _broj, _broj_doks )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
_ret := fakt_brojac(_broj, field->datdok )

if !EMPTY( sufiks )
    _ret := _ret + sufiks
endif

_ret := PADR( _ret, FAKT_BRDOK_LENGTH )

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret

// -------------------------------------
// -------------------------------------
function fakt_brojac(num)
local _param := fakt_params()

if num == 0 
   return  PADR( REPLICATE( "0", _param["brojac_numericki_dio"]), FAKT_BRDOK_LENGTH )
else
   return 999
endif

