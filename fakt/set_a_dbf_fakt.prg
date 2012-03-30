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
function set_a_dbf_fakt()

set_a_dbf_fakt_fakt()

set_a_fakt_doks_doks2("fakt_doks", "FAKT_DOKS", F_FAKT_DOKS)
set_a_fakt_doks_doks2("fakt_doks2", "FAKT_DOKS2", F_FAKT_DOKS2)

set_a_dbf_fakt_ugov()
set_a_dbf_fakt_rugov()

set_a_dbf_fakt_gen_ug()

// tabele sa strukturom sifarnika (id je primarni ključ)
set_a_dbf_sifarnik("fakt_ftxt", "FTXT" , F_FTXT )

// temp fakt tabele - ne idu na server
set_a_dbf_temp("fakt_relac"   ,   "RELAC"   , F_RELAC   )
set_a_dbf_temp("fakt_vozila"  ,   "VOZILA"  , F_VOZILA  )
set_a_dbf_temp("fakt_kalpos"  ,   "KALPOS"  , F_KALPOS  )
set_a_dbf_temp("dracun"       ,   "DRN"     , F_DRN     )
set_a_dbf_temp("racun"        ,   "RN"      , F_RN      )
set_a_dbf_temp("dracuntext"   ,   "DRNTEXT" , F_DRNTEXT )


// ----------------------------------------------------------
// ----------------------------------------------------------
function set_a_dbf_fakt_ugov()
local _item, _alg, _tbl 

_tbl := "fakt_ugov"

_item := hb_hash()

_item["alias"] := "UGOV"
_item["table"] := _tbl
_item["wa"]    := F_UGOV

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()

// funkcija a_ugov() definise dbf polja

_alg["dbf_key_block"]  := {|| field->id + field->idpartner}
_alg["dbf_key_fields"] := {"id", "idpartner"}
_alg["sql_in"]         := "rpad(id,10) || rpad(idpartner,6)"
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "id, idpartner, datod, datdo"

f18_dbfs_add(_tbl, @_item)
return .t.


// -----------------------------------------------------------
// -----------------------------------------------------------
function set_a_dbf_fakt_rugov()
local _item, _alg, _tbl 

_tbl := "fakt_rugov"

_item := hb_hash()

_item["alias"] := "RUGOV"
_item["table"] := _tbl
_item["wa"]    := F_RUGOV

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()

// funkcija a_rugov() definise dbf polja
_alg["dbf_key_block"]  := {|| field->id + field->idroba}
_alg["dbf_key_fields"] := {"id", "idroba"}
_alg["sql_in"]         := "rpad(id,10) || rpad(idroba,10)"
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "id, idroba, dest"

f18_dbfs_add(_tbl, @_item)
return .t.

// -----------------------------------
// -----------------------------------
function set_a_dbf_fakt_gen_ug()
local _item, _alg, _tbl 

_tbl := "fakt_gen_ug"

_item := hb_hash()

_item["alias"] := "GEN_UG"
_item["table"] := _tbl
_item["wa"]    := F_GEN_UG

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()

// funkcija a_ugov() definise dbf polja

_alg["dbf_key_block"]  := {|| field->datobr}
_alg["dbf_key_fields"] := {"datobr"}
_alg["sql_in"]         := "to_char(datobr, 'YYYYMMDD')" 
_alg["dbf_tag"]        := "DAT_OBR"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "datobr"

f18_dbfs_add(_tbl, @_item)
return .t.


// -----------------------------------
// -----------------------------------
function set_a_dbf_fakt_gen_ug_p()
local _item, _alg, _tbl 

_tbl := "fakt_gen_ug_p"

_item := hb_hash()

_item["alias"] := "GEN_UG_P"
_item["table"] := _tbl
_item["wa"]    := F_GEN_UG_P

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()


AADD( gaDbfs, { F_G_UG_P, "GEN_UG_P", "fakt_gen_ug_p", { | alg | gen_ug_p_from_sql_server( alg ) }, "IDS", 

 {|x| sql_where_block("fakt_gen_ug_p", x)}, "DAT_OBR" } )

_alg["dbf_key_block"]  := {|| field->datobr}
_alg["dbf_key_fields"] := {"dat_obr", "id_ugov", "idpartner"}
_alg["sql_in"]         := "to_char(dat_obr, 'YYYYMMDD') || rpad(id_ugov,10) || rpad(idpartner,6)" 

// CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)+ID_UGOV+IDPARTNER", "GEN_UG_P")
_alg["dbf_tag"]        := "DAT_OBR"

AADD(_item["algoritam"], _alg)

_item["sql_order"] := "datobr, id_ugov, idpartner"

f18_dbfs_add(_tbl, @_item)
return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fakt_fakt()
local _item, _alg, _tbl 

_tbl := "fakt_fakt"

_item := hb_hash()

_item["alias"] := "FAKT"
_item["table"] := _tbl
_item["wa"]    := F_FAKT

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->brdok + field->rbr }
_alg["dbf_key_fields"] := {"idfirma", "idtipdok", "brdok", "rbr"}
_alg["sql_in"]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8) || lpad(rb,3)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

// algoritam 2 - nivo dokumenta
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->brdok}
_alg["dbf_key_fields"] := {"idfirma", "idtipdok", "brdok"}
_alg["sql_in"]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "idfirma, idtipdok, brdok, rbr"

f18_dbfs_add(_tbl, @_item)
return .t.

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_fakt_doks_doks2(tbl, alias, wa)
local _item, _alg, _tbl 

_tbl := tbl

_item := hb_hash()

_item["alias"] := alias
_item["table"] := _tbl
_item["wa"]    := wa

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->brdok}
_alg["dbf_key_fields"] := {"idfirma", "idtipdok", "brdok"}
_alg["sql_in"]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "idfirma, idtipdok, brdok"

f18_dbfs_add(_tbl, @_item)
return .t.

