/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"
#include "cre_all.ch"

// -------------------------------------------
// -------------------------------------------
function g_lokal_fields()
local aDbf:={}

AADD(aDBf,{ "id"    , "C" ,   2 ,  0 })
// id stringa
AADD(aDBf,{ "id_str"  , "N" ,   6 ,  0 })
// string
AADD(aDBf,{ "naz"    , "C" ,   200 ,  0 })

return aDbf


// --------------------------------
// --------------------------------
function cre_lokal(ver)
local aDBF, _table_name, _alias, _created

aDbf := g_lokal_fields()
	
_table_name := "lokal"
_alias := "LOKAL"

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

CREATE_INDEX("ID","id+STR(id_str,6,0)+naz", _alias )
CREATE_INDEX("IDNAZ","id+naz", _alias )
CREATE_INDEX("ID_STR","STR(id_str,6,0)+naz+id", _alias )
CREATE_INDEX("NAZ","naz+str(id_str,6,0)", _alias )

return

