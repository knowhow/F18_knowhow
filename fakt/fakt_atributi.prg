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

// --------------------------------------------------
// get atribut opis
// --------------------------------------------------
function get_fakt_atribut_opis( dok, from_server )
local oAtrib := F18_DOK_ATRIB():new("fakt")
oAtrib:from_dbf := ( from_server == .f. )
oAtrib:atrib := "opis"
oAtrib:dok_hash := dok
return oAtrib:get_atrib()

// --------------------------------------------------
// get atribut ref, lot
// --------------------------------------------------
function get_fakt_atribut_ref( dok, from_server )
local oAtrib := F18_DOK_ATRIB():new("fakt")
oAtrib:from_dbf := ( from_server == .f. )
oAtrib:atrib := "ref"
oAtrib:dok_hash := dok
return oAtrib:get_atrib()


function get_fakt_atribut_lot( dok, from_server )
local oAtrib := F18_DOK_ATRIB():new("fakt")
oAtrib:from_dbf := ( from_server == .f. )
oAtrib:atrib := "lot"
oAtrib:dok_hash := dok
return oAtrib:get_atrib()


