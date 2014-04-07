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


// --------------------------------------------------------
// --------------------------------------------------------
function set_a_dbf_ld_sif()

set_a_dbf_sifarnik("ld_rj"      , "LD_RJ"     , F_LD_RJ      )
set_a_dbf_sifarnik("por"        , "POR"       , F_POR        )
set_a_dbf_sifarnik("tippr"      , "TIPPR"     , F_TIPPR      )
set_a_dbf_sifarnik("tippr2"     , "TIPPR2"    , F_TIPPR2     )
set_a_dbf_sifarnik("kred"       , "KRED"      , F_KRED       )
set_a_dbf_sifarnik("strspr"     , "STRSPR"    , F_STRSPR     )
set_a_dbf_sifarnik("vposla"     , "VPOSLA"    , F_VPOSLA     )
set_a_dbf_sifarnik("strspr"     , "STRSPR"    , F_STRSPR     )
set_a_dbf_sifarnik("kbenef"     , "KBENEF"    , F_KBENEF     )

return

// -------------------------------------
// -------------------------------------
function set_a_dbf_ld()

// kumulativ
set_a_dbf_ld_ld()
set_a_dbf_ld_parobr()
set_a_dbf_ld_dopr()
set_a_dbf_ld_radkr()
set_a_dbf_ld_obracuni()
set_a_dbf_ld_pk_data()
set_a_dbf_ld_pk_radn()
set_a_dbf_ld_radsat()
set_a_dbf_ld_radsiht()
set_a_dbf_ld_radn()

// privatne temp tabele
set_a_dbf_temp("_ld_radkr"   ,   "_RADKR"        , F__RADKR  )
set_a_dbf_temp("_ld_ld"      ,   "_LD"           , F__LD  )
set_a_dbf_temp("_ld_radn"    ,   "_RADN"         , F__RADN  )
set_a_dbf_temp("_ld_kred"    ,   "_KRED"         , F__KRED  )
set_a_dbf_temp("ld_ldsm"     ,   "LDSM"          , F_LDSM  )
set_a_dbf_temp("ld_opsld"    ,   "OPSLD"         , F_OPSLD  )
set_a_dbf_temp("ld_rekld"    ,   "REKLD"         , F_REKLD  )
set_a_dbf_temp("ld_rekldp"   ,   "REKLDP"        , F_REKLDP  )
set_a_dbf_temp("ldt22"       ,   "LDT22"         , F_LDT22  )


// sif - sihtarice
// stavicu ovdje a ne u ld_sif funkciju jer imaju prefix ld_
set_a_dbf_sifarnik("ld_norsiht"  , "NORSIHT" , F_NORSIHT   )
set_a_dbf_sifarnik("ld_tprsiht"  , "TPRSIHT" , F_TPRSIHT   )


return


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_ld()
local _alg, _tbl 

_tbl := "ld_ld"

_item := hb_hash()

_item["alias"] := "LD"
_item["table"] := _tbl
_item["wa"]    := F_LD

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| STR(field->godina,4) + field->idrj + STR(field->mjesec,2) + field->obr + field->idradn }
_alg["dbf_key_fields"] := { {"godina", 4}, "idrj", {"mjesec", 2 }, "obr", "idradn" }
_alg["sql_in"]         := "lpad(godina::char(4), 4) || rpad(idrj, 2) || lpad(mjesec::char(2),2) || rpad(obr,1) || rpad(idradn,6)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)
 
// algoritam 2 - brisanje
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| STR(field->godina,4) + field->idrj + STR(field->mjesec,2) + field->obr }
_alg["dbf_key_fields"] := { {"godina", 4}, "idrj", {"mjesec", 2 }, "obr" }
_alg["sql_in"]         := "lpad(godina::char(4), 4) || rpad(idrj, 2) || lpad(mjesec::char(2),2) || rpad(obr,1)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)
 
_item["sql_order"] := "godina, idrj, mjesec, obr"

f18_dbfs_add(_tbl, @_item)

return


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_radn()
local _alg, _tbl 

_tbl := "ld_radn"

_item := hb_hash()

_item["alias"] := "RADN"
_item["table"] := _tbl
_item["wa"]    := F_RADN

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id }
_alg["dbf_key_fields"] := { "id" }
_alg["sql_in"]         := "rpad(id, 6)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_parobr()
local _alg, _tbl 

_tbl := "ld_parobr"

_item := hb_hash()

_item["alias"] := "PAROBR"
_item["table"] := _tbl
_item["wa"]    := F_PAROBR

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + field->godina + field->obr}
_alg["dbf_key_fields"] := { "id", "godina", "obr" }
_alg["sql_in"]         := "rpad(id, 2) || rpad(godina, 4) || rpad(obr, 1)"
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_dopr()
local _alg, _tbl 

_tbl := "dopr"

_item := hb_hash()

_item["alias"] := "DOPR"
_item["table"] := _tbl
_item["wa"]    := F_DOPR

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + field->naz + field->tiprada }
_alg["dbf_key_fields"] := { "id", "naz", "tiprada" }
_alg["sql_in"]         := "rpad(id, 2) || rpad(naz, 20) || rpad(tiprada, 1)"
_alg["dbf_tag"]        := "1"

AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return




// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_obracuni()
local _alg, _tbl 

_tbl := "ld_obracuni"

_item := hb_hash()

_item["alias"] := "OBRACUNI"
_item["table"] := _tbl
_item["wa"]    := F_OBRACUNI

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->rj + STR( field->godina, 4 ) + STR( field->mjesec, 2 ) + field->status + field->obr }
_alg["dbf_key_fields"] := { "rj", {"godina", 4}, {"mjesec", 2}, "status", "obr" }
_alg["sql_in"]         := "rpad(rj, 2) || lpad(godina::char(4),4) || lpad(mjesec::char(2),2) || rpad(status, 1) || rpad(obr, 1)"
_alg["dbf_tag"]        := "RJ"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_pk_radn()
local _alg, _tbl 

_tbl := "ld_pk_radn"

_item := hb_hash()

_item["alias"] := "PK_RADN"
_item["table"] := _tbl
_item["wa"]    := F_PK_RADN

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idradn }
_alg["dbf_key_fields"] := { "idradn" }
_alg["sql_in"]         := "rpad(idradn, 6)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_pk_data()
local _alg, _tbl 

_tbl := "ld_pk_data"

_item := hb_hash()

_item["alias"] := "PK_DATA"
_item["table"] := _tbl
_item["wa"]    := F_PK_DATA

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idradn + field->ident + STR( field->rbr, 2 ) }
_alg["dbf_key_fields"] := { "idradn", "ident", {"rbr", 2} }
_alg["sql_in"]         := "rpad(idradn, 6) || rpad(ident, 1) || lpad(rbr::char(2),2)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)
 
// algoritam 2 - brisanje podataka
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idradn }
_alg["dbf_key_fields"] := { "idradn" }
_alg["sql_in"]         := "rpad(idradn, 6)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_radsat()
local _alg, _tbl 

_tbl := "ld_radsat"

_item := hb_hash()

_item["alias"] := "RADSAT"
_item["table"] := _tbl
_item["wa"]    := F_RADSAT

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idradn }
_alg["dbf_key_fields"] := { "idradn" }
_alg["sql_in"]         := "rpad(idradn, 6)"
_alg["dbf_tag"]        := "IDRADN"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_ld_radsiht()
local _alg, _tbl 

_tbl := "ld_radsiht"

_item := hb_hash()

_item["alias"] := "RADSIHT"
_item["table"] := _tbl
_item["wa"]    := F_RADSIHT

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idkonto + STR(field->godina, 4) + STR(field->mjesec, 2) + field->idradn }
_alg["dbf_key_fields"] := { "idkonto", {"godina", 4}, {"mjesec", 2}, "idradn" }
_alg["sql_in"]         := "rpad(idkonto, 7) || lpad(godina::char(4),4) || lpad(mjesec::char(2),2) || rpad(idradn, 6)"
_alg["dbf_tag"]        := "2"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

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
_alg["sql_in"]         := "rpad(idradn,6) || rpad(idkred,6) || rpad(naosnovu, 20) || lpad(godina::char(4),4) || lpad(mjesec::char(2),2)"

// "2", "idradn + idkred + naosnovu + str(godina) + str(mjesec)"
_alg["dbf_tag"]        := "2"
AADD(_item["algoritam"], _alg)
 
f18_dbfs_add(_tbl, @_item)

return



