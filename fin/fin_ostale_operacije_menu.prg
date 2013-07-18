/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

function MnuOstOperacije()
local oDB_lock := F18_DB_LOCK():New()
local _db_locked := oDB_lock:is_locked()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. povrat dokumenta u pripremu                " )
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT", "POVRATNALOGA")) .or. !_db_locked
	AADD( _opcexe, {|| povrat_fin_naloga() })
else
    AADD( _opcexe, { || oDb_lock:warrning() } )
endif

AADD( _opc, "2. preknjizenje     ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREKNJIZENJE")) .or. !_db_locked
	AADD( _opcexe, {|| Preknjizenje()})
else
    AADD( _opcexe, { || oDb_lock:warrning() } )
endif

AADD( _opc, "3. prebacivanje kartica")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREBKARTICA")) .or. !_db_locked
	AADD( _opcexe, {|| Prebfin_kartica()})
else
    AADD( _opcexe, { || oDb_lock:warrning() } )
endif

AADD( _opc, "4. otvorene stavke")
if !_db_locked
    AADD( _opcexe, { || OStav() } )
else
    AADD(_opcexe, { || oDb_lock:warrning() } )
endif

AADD(opc, "5. obrada kamata ")
AADD(opcexe, {|| fin_kamate_menu() })

f18_menu( "oop", .f., _izbor, _opc, _opcexe )

return



