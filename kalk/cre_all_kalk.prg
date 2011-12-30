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

function cre_all_kalk(ver)
local aDbf
local _alias, _table_name

// -----------------------------------------------
// kalk_doks
// -----------------------------------------------
	
aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IdZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IdZADUZ2'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'NV'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'VPV'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'MPV'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

_alias := "KALK_DOKS"
_table_name := "kalk_doks"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2(_alias, aDbf)
endif

// 0.4.0
if ver["current"] < 0400
   modstru({"*" + _table_name, "A SIFRA C 6 0"})
endif

reset_semaphore_version(_table_name)
my_usex(_alias)
USE

CREATE_INDEX("1", "IdFirma+idvd+brdok", _alias)
CREATE_INDEX("2","IdFirma+MKONTO+idzaduz2+idvd+brdok", _alias)
CREATE_INDEX("3","IdFirma+dtos(datdok)+podbr+idvd+brdok", _alias)
CREATE_INDEX("DAT","datdok", _alias)

// za RN
if glBrojacPoKontima == .t.
		CREATE_INDEX("1S","IdFirma+idvd+SUBSTR(brdok,6)+LEFT(brdok,5)", _alias)
endif

CREATE_INDEX("V_BRF",  "brfaktp+idvd", _alias)
CREATE_INDEX("V_BRF2", "idvd+brfaktp", _alias)

return .t.

