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

set_a_fakt_doks_doks2("fakt_doks"  , "FAKT_DOKS"  , F_FAKT_DOKS)
set_a_fakt_doks_doks2("fakt_doks2" , "FAKT_DOKS2" , F_FAKT_DOKS2)

set_a_dbf_fakt_ugov()
set_a_dbf_fakt_rugov()

set_a_dbf_fakt_gen_ug()
set_a_dbf_fakt_gen_ug_p()

// tabele sa strukturom sifarnika (id je primarni ključ)
set_a_dbf_sifarnik("fakt_ftxt"  , "FTXT"  , F_FTXT   )
set_a_dbf_sifarnik("dest"       , "DEST"  , F_DEST   )

// temp fakt tabele - ne idu na server
set_a_dbf_temp("fakt_relac"   ,   "RELAC"        , F_RELAC   )
set_a_dbf_temp("fakt_vozila"  ,   "VOZILA"       , F_VOZILA  )
set_a_dbf_temp("fakt_kalpos"  ,   "KALPOS"       , F_KALPOS  )
set_a_dbf_temp("dracun"       ,   "DRN"          , F_DRN     )
set_a_dbf_temp("racun"        ,   "RN"           , F_RN      )
set_a_dbf_temp("dracuntext"   ,   "DRNTEXT"      , F_DRNTEXT )
set_a_dbf_temp("fakt_pripr"   ,   "FAKT_PRIPR"   , F_FAKT_PRIPR   )
set_a_dbf_temp("fakt_pripr2"  ,   "FAKT_PRIPR2"  , F_FAKT_PRIPR2  )
set_a_dbf_temp("fakt_pripr9"  ,   "FAKT_PRIPR9"  , F_FAKT_PRIPR9  )
set_a_dbf_temp("fiscal_fdevice"  ,   "FDEVICE"   , F_FDEVICE )
set_a_dbf_temp("fakt_pormp"   ,   "PORMP"        , F_PORMP   )
set_a_dbf_temp("_fakt_roba"   ,   "_ROBA"        , F__ROBA   )
set_a_dbf_temp("_fakt_partn"  ,   "_PARTN"       , F__PARTN  )
set_a_dbf_temp("fakt_logk"    ,   "LOGK"         , F_LOGK    )
set_a_dbf_temp("fakt_logkd"   ,   "LOGKD"        , F_LOGKD   )
set_a_dbf_temp("fakt_barkod"  ,   "BARKOD"       , F_BARKOD  )
set_a_dbf_temp("fakt_rj"      ,   "RJ"           , F_RJ      )
set_a_dbf_temp("fakt_upl"     ,   "UPL"          , F_UPL     )
set_a_dbf_temp("fakt_s_pripr" ,   "FAKT_S_PRIPR" , F_FAKT    )
set_a_dbf_temp("_fakt_fakt"   ,   "_FAKT"        , F__FAKT   )
set_a_dbf_temp("fakt_fapripr" ,   "FAKT_FAPRIPR" , F_FAKT_PRIPR )


return


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

// funkcija a_genug() definise dbf polja

_alg["dbf_key_block"]  := {|| DTOS(field->dat_obr)}
_alg["dbf_key_fields"] := {"dat_obr"}
_alg["sql_in"]         := "to_char(dat_obr, 'YYYYMMDD')" 
_alg["dbf_tag"]        := "DAT_OBR"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "dat_obr"

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
_item["wa"]    := F_G_UG_P

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| DTOS(field->dat_obr) + id_ugov + idpartner }
_alg["dbf_key_fields"] := {"dat_obr", "id_ugov", "idpartner"}
_alg["sql_in"]         := "to_char(dat_obr, 'YYYYMMDD') || rpad(id_ugov,10) || rpad(idpartner,6)" 

// CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)+ID_UGOV+IDPARTNER", "GEN_UG_P")
_alg["dbf_tag"]        := "DAT_OBR"

AADD(_item["algoritam"], _alg)

_item["sql_order"] := "dat_obr, id_ugov, idpartner"

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
_alg["dbf_key_block"]  := {|| field->idfirma + field->idtipdok + field->brdok + field->rbr }
_alg["dbf_key_fields"] := {"idfirma", "idtipdok", "brdok", "rbr"}
_alg["sql_in"]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8) || lpad(rbr,3)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

// algoritam 2 - nivo dokumenta
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idtipdok + field->brdok }
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
_alg["dbf_key_block"]  := {|| field->idfirma + field->idtipdok + field->brdok}
_alg["dbf_key_fields"] := {"idfirma", "idtipdok", "brdok"}
_alg["sql_in"]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8)"
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "idfirma, idtipdok, brdok"

f18_dbfs_add(_tbl, @_item)
return .t.


