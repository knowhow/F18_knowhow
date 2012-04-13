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

// kumulativne tabele
set_a_dbf_fin_suban()
set_a_dbf_fin_anal()
set_a_dbf_fin_sint()
set_a_dbf_fin_nalog()
set_a_dbf_fin_parek()

// sifrarnici
set_a_dbf_sifarnik("fin_funk"      , "FUNK"     ,       F_FUNK       )
set_a_dbf_sifarnik("fin_fond"      , "FOND"     ,       F_FOND       )
set_a_dbf_sifarnik("fin_buiz"      , "BUIZ"     ,       F_BUIZ       )
set_a_dbf_sifarnik("fin_ulimit"    , "ULIMIT"   ,       F_ULIMIT     )

// temporary
set_a_dbf_temp("fin_konto"        , "_KONTO"   ,       F__KONTO   )
set_a_dbf_temp("fin_partn"        , "_PARTN"   ,       F__PARTN   )
set_a_dbf_temp("fin_pripr"   , "FIN_PRIPR"     , F_FIN_PRIPR  )
set_a_dbf_temp("fin_psuban"    , "PSUBAN"   ,       F_PSUBAN     )
set_a_dbf_temp("fin_panal"     , "PANAL"    ,       F_PANAL      )
set_a_dbf_temp("fin_psint"     , "PSINT"    ,       F_PSINT      )
set_a_dbf_temp("fin_pnalog"    , "PNALOG"   ,       F_PNALOG     )
set_a_dbf_temp("fin_budzet"    , "BUDZET"   ,       F_BUDZET     )
set_a_dbf_temp("fin_koniz"     , "KONIZ"    ,       F_KONIZ      )
set_a_dbf_temp("fin_izvje"     , "IZVJE"    ,       F_IZVJE      )
set_a_dbf_temp("fin_zagli"     , "ZAGLI"    ,       F_ZAGLI      )
set_a_dbf_temp("fin_koliz"     , "KOLIZ"    ,       F_KOLIZ      )
set_a_dbf_temp("fin_bbklas"      , "BBKLAS"     ,       F_IOS       )
set_a_dbf_temp("fin_ios"         , "IOS"        ,       F_BBKLAS    )
set_a_dbf_temp("fin_ostav"       , "OSTAV"      ,       F_OSTAV     )
set_a_dbf_temp("fin_osuban"      , "OSUBAN"     ,       F_OSUBAN    )
set_a_dbf_temp("temp12"         , "TEMP12"      ,       F_TEMP12    )
set_a_dbf_temp("temp60"         , "TEMP60"      ,       F_TEMP60    )
set_a_dbf_temp("vksg"           , "VKSG"        ,       F_VKSG      )

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

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_parek()
local _alg, _tbl
local _itm

_tbl := "fin_parek"

_item := hb_hash()

_item["alias"] := "PAREK"
_item["wa"]    := F_PAREK
_item["table"] := _tbl

// temporary tabela - nema semafora
_item["temp"]  := .f.


_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block" ] := {|| field->idpartija } 
_alg["dbf_key_fields"] := { "idpartija" } 
_alg["sql_in"]         := "rpad(idpartija,6)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "idpartija"

f18_dbfs_add(_tbl, @_item)
return .t.


