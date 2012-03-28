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
function set_a_dbf_fin()

set_a_dbf_fin_suban()
set_a_dbf_fin_anal()
set_a_dbf_fin_sint()
set_a_dbf_fin_nalog()

return



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_suban()
local _alg, _tbl 

_tbl := "fin_suban"

_item := hb_hash()

_item["alias"] := "SUBAN"
_item["table"] := _tbl
_item["wa"]    := F_SUBAN

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal + field->rbr }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]         := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 4)"
_alg["dbf_tag"]        := "4"
AADD(_item["algoritam"], _alg)


// algoritam 2 - dokument
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal" } 
_alg["sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]    := "4"
AADD(_item["algoritam"], _alg)

// za full sinhronizaciju trebamo jedinstveni poredak
_item["sql_order"] := "idfirma, idvn, brnal, rbr"

f18_dbfs_add(_tbl, @_item)
return .t.

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_anal()
local _item
local _alg, _tbl

_tbl := "fin_anal"

_item := hb_hash()

_item["alias"] := "ANAL"
_item["wa"]    := F_ANAL
_item["table"] := _tbl
// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"] := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 3)"
_alg["dbf_tag"]   := "2"
AADD(_item["algoritam"], _alg)


// algoritam 2 - dokument
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal" } 
_alg["sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]    := "2"
AADD(_item["algoritam"], _alg)

// za full sinhronizaciju trebamo jedinstveni poredak
_item["sql_order"] := "idfirma, idvn, brnal, rbr"

f18_dbfs_add(_tbl, @_item)
return .t.

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_sint()
local _alg, _tbl, _item

_tbl := "fin_sint"

_item := hb_hash()

_item["alias"] := "SINT"
_item["table"] := _tbl
_item["wa"]    := F_SINT

// temporary tabela - nema semafora
_item["temp"]  := .f.


_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"] := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 3)"
_alg["dbf_tag"]   := "2"
AADD(_item["algoritam"], _alg)


// algoritam 2 - dokument
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal" } 
_alg["sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]    := "2"
AADD(_item["algoritam"], _alg)

// za full sinhronizaciju trebamo jedinstveni poredak
_item["sql_order"] := "idfirma, idvn, brnal, rbr"

f18_dbfs_add(_tbl, @_item)

return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_nalog()
local _alg, _tbl
local _itm

_tbl := "fin_nalog"

_item := hb_hash()

_item["alias"] := "NALOG"
_item["wa"]    := F_NALOG
_item["table"] := _tbl

// temporary tabela - nema semafora
_item["temp"]  := .f.


_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block" ] := {|| field->idfirma + field->idvn + field->brnal} 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal"} 
_alg["sql_in"]         := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "idfirma, idvn, brnal"

f18_dbfs_add(_tbl, @_item)
return .t.


