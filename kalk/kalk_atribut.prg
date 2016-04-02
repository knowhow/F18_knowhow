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


// --------------------------------------------------
// get atribut opis
// --------------------------------------------------
function get_kalk_atribut_opis( dok, from_server )
local oAtrib := DokAtributi():new("kalk", F_KALK_ATRIB)
oAtrib:from_dbf := ( from_server == .f. )
oAtrib:atrib := "opis"
oAtrib:workarea := F_KALK_ATRIB
oAtrib:dok_hash := dok
return oAtrib:get_atrib()



// --------------------------------------------------
// get atribut rok
// --------------------------------------------------
function get_kalk_atribut_rok( dok, from_server )
local oAtrib := DokAtributi():new("kalk", F_KALK_ATRIB)
oAtrib:from_dbf := ( from_server == .f. )
oAtrib:atrib := "rok"
oAtrib:dok_hash := dok
return oAtrib:get_atrib()



