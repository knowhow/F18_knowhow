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

#include "fmk.ch"


// -------------------------------------
// -------------------------------------
function set_a_dbf_ld()

set_a_dbf_ld_radkr()

return

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_radkr()
local _alg, _tbl 

_tbl := "ld_radkr"

_item := hb_hash()

_item["alias"] := "RADKR"
_item["table"] := _tbl
_item["wa"]    := F_RADKR

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idradn + field->idkred + field->naosnovu + STR(field->godina, 4, 0) + STR(field->mjesec, 2, 0)}
_alg["dbf_key_fields"] := { "idradn", "idkred", "naosnovu", {"godina", 4}, {"mjesec", 2 }}
_alg["sql_in"]         := "rpad(idradn,6) || rpad(idkred,6) || rpad(naosnovu, 20) || godina::char(4) || mjesec::char(2)"

// "2", "idradn + idkred + naosnovu + str(godina) + str(mjesec)"
_alg["dbf_tag"]        := "2"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

