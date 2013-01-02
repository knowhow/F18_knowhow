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

// ------------------------------------------------------
// vraca ukupno sa pdv
// ------------------------------------------------------
function _uk_sa_pdv( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
    nRet := nIznos
else
    if !IsIno( cPartner ) .and. !IsOslClan( cPartner )
        nRet := ( nIznos * 1.17 )
    else
        nRet := nIznos
    endif
endif

select (nTArea)
return nRet




// --------------------------------------------------
// Vraca naziv objekta
// --------------------------------------------------
function fakt_objekat_naz( id_obj )
local _ret := ""

PushWa()

O_FAKT_OBJEKTI

select fakt_objekti
set order to tag "ID"
seek id_obj

if FOUND()
    _ret := ALLTRIM( field->naz )
endif

PopWa()
return _ret



// --------------------------------------------------
// Vraca objekat iz tabele fakt
// ako se zadaje bez parametara pretpostavlja se da je 
// napravljena tabela relacije fakt_doks->fakt
// --------------------------------------------------
function fakt_objekat_id( id_firma, id_tipdok, br_dok )
local _ret := ""
local _memo

PushWa()
<<<<<<< HEAD

if idfirma == NIL
=======
if id_firma == NIL
>>>>>>> master
  id_firma = fakt->idfirma
  id_tipdok = fakt->idtipdok
  br_dok = fakt->brdok
endif

select ( F_FAKT )

if !Used()
   O_FAKT
endif

select fakt

// filter se mora iskljuciti inace se ova funkcija rekurzivno poziva
// PopWa ce uraditi restore filtera
set filter to
set order to tag "1"
<<<<<<< HEAD
go top
=======
>>>>>>> master
seek id_firma + id_tipdok + br_dok + "  1"

if !FOUND()
    _ret := SPACE(10)
else
  _memo := ParsMemo( fakt->txt )
  if LEN( _memo ) >= 20
      _ret := PADR(_memo[20], 10)
  endif
endif

PopWa()
return _ret

// ----------------------------------------------------------------------
// setuje pojedinacni clan matrice memo
// ----------------------------------------------------------------------
function fakt_memo_field_to_txt( memo_field )
local _txt := ""
local _val := ""
local _i

for _i := 1 to LEN( memo_field )

    _tmp := memo_field[ _i ]

    if VALTYPE( _tmp ) == "D"
        _val := DTOC( _tmp )
    elseif VALTYPE( _tmp ) == "N"
        _val := VAL( _tmp )
    else
        _val := _tmp
    endif

    _txt += CHR(16) + _val + CHR(17)

next

return _txt



// --------------------------------------------------
// Vraca vezne dokumente
// ako se zadaje bez parametara pretpostavlja se da je 
// napravljena tabela relacije fakt_doks->fakt
// --------------------------------------------------
function get_fakt_vezni_dokumenti( id_firma, tip_dok, br_dok )
local _t_arr := SELECT()
local _ret := ""
local _memo

if PCOUNT() > 0

    select ( F_FAKT )

    if !Used()
        O_FAKT
    endif
    
    // pozicioniraj se na stavku broj 1
    select fakt
    set order to tag "1"
    go top
    seek id_firma + tip_dok + br_dok
    
    if !FOUND()
        return _ret
    endif

endif

// to se krije kao 20 clan matrice
_memo := ParsMemo( fakt->txt )

if LEN( _memo ) >= 19
    _ret := _memo[19]
endif

select ( _t_arr )

return _ret



// ------------------------------------------------------
// da li je fakt priprema prazna 
// mogucnost brisanja pripreme
// ------------------------------------------------------
function fakt_priprema_prazna()
local _ret := .t.
local _t_area := SELECT()

select ( F_FAKT_PRIPR )
if !Used()
    O_FAKT_PRIPR
endif

// prazna je
if RECCOUNT2() == 0
    select ( _t_area )
    return _ret
endif

_ret := .f.

if Pitanje(, "Priprema modula FAKT nije prazna, izbrisati postojece stavke (D/N) ?", "N" ) == "D"

    // pobrisi pripremu
    select fakt_pripr
    zapp()
    __dbPack()
    _ret := .t.

endif

select ( _t_area )

return _ret






