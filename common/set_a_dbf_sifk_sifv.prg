/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

function set_a_dbf_sifk_sifv()

set_a_dbf_sifk()
set_a_dbf_sifv()

return

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_sifk()
local _alg, _tbl 

_tbl := "sifk"

_item := hb_hash()

_item["alias"] := "SIFK"
_item["table"] := _tbl
_item["wa"]    := F_SIFK

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + field->oznaka }
_alg["dbf_key_fields"] := { "id", "oznaka" } 
_alg["sql_in" ]        := "rpad(id,8) || rpad(oznaka,4)"
// "2", "idradn + idkred + naosnovu + str(godina) + str(mjesec)"
_alg["dbf_tag"]        := "ID2"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_sifv()
local _alg, _tbl 

_tbl := "sifv"

_item := hb_hash()

_item["alias"] := "SIFV"
_item["table"] := _tbl
_item["wa"]    := F_SIFV

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + field->oznaka + field->idsif + field->naz}
_alg["dbf_key_fields"] := { "id", "oznaka", "idsif", "naz" } 
_alg["sql_in" ]        := "rpad(id,8) || rpad(oznaka,4) || rpad(idsif,15) || rpad(naz,50)"
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg)

// algoritam 2 - brisi sve stavke sa kljucem id + oznaka + idsif
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + field->oznaka + field->idsif}
_alg["dbf_key_fields"] := { "id", "oznaka", "idsif"} 
_alg["sql_in" ]        := "rpad(id,8) || rpad(oznaka,4) || rpad(idsif,15)"
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return
