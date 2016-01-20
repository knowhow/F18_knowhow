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
function set_a_dbf_epdv()

set_a_dbf_epdv_pdv()

// kuf i kif su tabele identične strukture
set_a_dbf_epdv_kuf_kif("epdv_kuf", "KUF", F_KUF)
set_a_dbf_epdv_kuf_kif("epdv_kif", "KIF", F_KIF)

// tabele sa strukturom sifarnika (id je primarni ključ)
set_a_dbf_sifarnik("epdv_sg_kif", "SG_KIF" , F_SG_KIF )
set_a_dbf_sifarnik("epdv_sg_kuf", "SG_KUF" , F_SG_KUF )

// temp epdv tabele - ne idu na server
set_a_dbf_temp("epdv_p_kif", "P_KIF", F_P_KIF)
set_a_dbf_temp("epdv_p_kuf", "P_KUF", F_P_KUF)
set_a_dbf_temp("epdv_r_kuf", "R_KUF", F_R_KUF)
set_a_dbf_temp("epdv_r_kif", "R_KIF", F_R_KIF)
set_a_dbf_temp("epdv_r_pdv", "R_PDV", F_R_PDV)

return


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_epdv_pdv()
local _item, _alg, _tbl 

_tbl := "epdv_pdv"

_item := hb_hash()

_item["alias"] := "PDV"
_item["table"] := _tbl
_item["wa"]    := F_PDV

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| DTOS(field->per_od) + DTOS(field->per_do) }
_alg["dbf_key_fields"] := { "per_od", "per_do"}
_alg["sql_in"]         := "to_char(per_od, 'YYYYMMDD') || to_char(per_do, 'YYYYMMDD')" 
_alg["dbf_tag"]        := "PERIOD"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "per_od, per_do"

f18_dbfs_add(_tbl, @_item)
return .t.



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_epdv_kuf_kif(table, alias, wa)
local _item, _alg, _tbl 

_tbl := table

_item := hb_hash()

_item["alias"] := alias
_item["table"] := table
_item["wa"]    := wa

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| STR(field->br_dok, 6 ) + STR(field->r_br, 6 ) }
_alg["dbf_key_fields"] := { {"br_dok", 6 }, {"r_br", 6 } }
_alg["sql_in"]         := "lpad(br_dok::char(6), 6) || lpad(r_br::char(6),6)"
_alg["dbf_tag"]        := "BR_DOK"
AADD(_item["algoritam"], _alg)

// algoritam 2 - povrat dokumenta 
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| STR(field->br_dok, 6 ) }
_alg["dbf_key_fields"] := { {"br_dok", 6 } } 
_alg["sql_in"]         := "lpad( br_dok::char(6), 6 )"
_alg["dbf_tag"]        := "BR_DOK"
AADD(_item["algoritam"], _alg)

_item["sql_order"] := "br_dok, r_br, datum"

f18_dbfs_add(_tbl, @_item)
return .t.


