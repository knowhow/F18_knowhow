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
function set_a_dbf_virm()
local _alg

// kumulativne tabele
set_a_dbf_virm_jprih()

set_a_dbf_sifarnik("vrprim", "VRPRIM" , F_VRPRIM )
set_a_dbf_sifarnik("ldvirm", "LDVIRM" , F_LDVIRM )
set_a_dbf_sifarnik("kalvir", "KALVIR" , F_KALVIR )

// temp tabele - ne idu na server
set_a_dbf_temp( "virm_pripr", "VIRM_PRIPR", F_VIPRIPR )
set_a_dbf_temp( "vrprim2", "VRPRIM2", F_VRPRIM2 )
set_a_dbf_temp( "izlaz", "IZLAZ", F_IZLAZ )

return




// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
static function set_a_dbf_virm_jprih()
local _item, _alg, _tbl 

_tbl := "jprih"
_item := hb_hash()

_item["alias"] := "JPRIH"
_item["table"] := _tbl
_item["wa"]    := F_JPRIH

// temporary tabela - nema semafora
_item["temp"]  := .f.

_item["algoritam"] := {}
	
// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->id + field->idops + field->idkan + field->idn0 + field->racun }
_alg["dbf_key_fields"] := { "id", "idops", "idkan", "idn0", "racun" }
_alg["sql_in"]         := " rpad(id, 6) || rpad(idops, 3) || rpad( idkan, 2 ) || rpad( idn0, 1 ) || rpad( racun, 16 ) " 
_alg["dbf_tag"]        := "ID"
AADD(_item["algoritam"], _alg )

_item["sql_order"] := "id, idops "

f18_dbfs_add(_tbl, @_item)

return .t.



