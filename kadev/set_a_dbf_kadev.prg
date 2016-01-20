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

#include "f18.ch"


// -------------------------------------
// -------------------------------------
function set_a_dbf_kadev()
local _alg

// kumulativne tabele:
set_a_dbf_kadev_0()
set_a_dbf_kadev_1()
set_a_dbf_kadev_globusl()
set_a_dbf_kadev_uslovi()
set_a_dbf_kadev_rjrmj()
set_a_dbf_kadev_defrjes()

set_a_dbf_sifarnik( "kadev_promj", "KADEV_PROMJ" , F_KADEV_PROMJ )
set_a_dbf_sifarnik( "kadev_rj", "KDV_RJ" , F_KDV_RJ )
set_a_dbf_sifarnik( "kadev_rmj", "KDV_RMJ" , F_KDV_RMJ )
set_a_dbf_sifarnik( "kadev_mz", "KDV_MZ" , F_KDV_MZ )
set_a_dbf_sifarnik( "kadev_nerdan", "KDV_NERDAN" , F_KDV_NERDAN )
set_a_dbf_sifarnik( "kadev_k1", "KDV_K1" , F_KDV_K1 )
set_a_dbf_sifarnik( "kadev_k2", "KDV_K2" , F_KDV_K2 )
set_a_dbf_sifarnik( "kadev_zanim", "KDV_ZANIM" , F_KDV_ZANIM )
set_a_dbf_sifarnik( "kadev_rrasp", "KDV_RRASP" , F_KDV_RRASP )
set_a_dbf_sifarnik( "kadev_cin", "KDV_CIN" , F_KDV_CIN )
set_a_dbf_sifarnik( "kadev_ves", "KDV_VES" , F_KDV_VES )
set_a_dbf_sifarnik( "kadev_nac", "KDV_NAC" , F_KDV_NAC )
set_a_dbf_sifarnik( "kadev_rjes", "KDV_RJES" , F_KDV_RJES )

set_a_dbf_temp( "kadev_obrazdef", "KDV_OBRAZDEF", F_KDV_OBRAZDEF   )

return


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_rjrmj()
local _item, _alg, _tbl 

_tbl := "kadev_rjrmj"
_item := hb_hash()

_item["alias"] := "KDV_RJRMJ"
_item["table"] := _tbl
_item["wa"]    := F_KDV_RJRMJ

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idrj + field->idrmj + field->idzanim1 + field->idstrsprod + field->idstrsprdo }
_alg["dbf_key_fields"] := { "idrj", "idrmj", "idzanim1", "idstrsprod", "idstrsprdo" }
_alg["sql_in"]         := " rpad( idrj, 6 ) || rpad( idrmj, 4 ) || rpad( idzanim1, 4 ) || rpad( idstrsprod, 3 ) || rpad( idstrsprdo, 3 ) " 
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "idrj, idrmj"

f18_dbfs_add(_tbl, @_item)

return .t.




// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_0()
local _item, _alg, _tbl 

_tbl := "kadev_0"
_item := hb_hash()

_item["alias"] := "KADEV_0"
_item["table"] := _tbl
_item["wa"]    := F_KADEV_0

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id }
_alg["dbf_key_fields"] := { "id" }
_alg["sql_in"]         := " rpad(id, 13)  " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "id"

f18_dbfs_add(_tbl, @_item)

return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_1()
local _item, _alg, _tbl 

_tbl := "kadev_1"
_item := hb_hash()

_item["alias"] := "KADEV_1"
_item["table"] := _tbl
_item["wa"]    := F_KADEV_1

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + DTOS(field->datumod) + field->idpromj + field->opis }
_alg["dbf_key_fields"] := { "id", "datumod", "idpromj", "opis" }
_alg["sql_in"]         := " rpad( id, 13 ) || to_char( datumod, 'YYYYMMDD' ) || rpad( idpromj, 2 ) || rpad( opis, 50 )" 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )


// algoritam 2 - sve promjene
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id }
_alg["dbf_key_fields"] := { "id" }
_alg["sql_in"]         := " rpad( id, 13 ) " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "id, datumod"

f18_dbfs_add(_tbl, @_item)

return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_globusl()
local _item, _alg, _tbl 

_tbl := "kadev_globusl"
_item := hb_hash()

_item["alias"] := "KDV_GLOBUSL"
_item["table"] := _tbl
_item["wa"]    := F_KDV_GLOBUSL

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->komentar }
_alg["dbf_key_fields"] := { "komentar" }
_alg["sql_in"]         := " rpad( komentar, 25 ) " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "komentar"

f18_dbfs_add(_tbl, @_item)

return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_obrazdef()
local _item, _alg, _tbl 

_tbl := "kadev_obrazdef"
_item := hb_hash()

_item["alias"] := "KDV_OBRAZDEF"
_item["table"] := _tbl
_item["wa"]    := F_KDV_OBRAZDEF

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->tip + field->grupa + field->red_br }
_alg["dbf_key_fields"] := { "tip", "grupa", "red_br" }
_alg["sql_in"]         := " rpad( tip, 1 ) || rpad( grupa, 1 ) || rpad( red_br, 1 ) " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "tip, grupa, red_br"

f18_dbfs_add(_tbl, @_item)

return .t.



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_uslovi()
local _item, _alg, _tbl 

_tbl := "kadev_uslovi"
_item := hb_hash()

_item["alias"] := "KDV_USLOVI"
_item["table"] := _tbl
_item["wa"]    := F_KDV_USLOVI

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id }
_alg["dbf_key_fields"] := { "id" }
_alg["sql_in"]         := " rpad( id, 8 ) " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "id"

f18_dbfs_add(_tbl, @_item)

return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_kadev_defrjes()
local _item, _alg, _tbl 

_tbl := "kadev_defrjes"
_item := hb_hash()

_item["alias"] := "KDV_DEFRJES"
_item["table"] := _tbl
_item["wa"]    := F_KDV_DEFRJES

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idrjes + field->id }
_alg["dbf_key_fields"] := { "idrjes", "id" }
_alg["sql_in"]         := " rpad( idrjes, 2 ) || rpad( id, 2 ) " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )

// algoritam 2 - po id-u
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idrjes }
_alg["dbf_key_fields"] := { "idrjes" }
_alg["sql_in"]         := " rpad( idrjes, 2 ) " 
_alg["dbf_tag"]        := "1"
AADD(_item["algoritam"], _alg )


_item["sql_order"] := "idrjes, id"

f18_dbfs_add(_tbl, @_item)

return .t.


