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


#include "pos.ch"

function pos_menu_realizacija()

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. kase             ")
AADD(opcexe,{|| realizacija_kase(.f.)})
AADD(opc,"2. odjeljenja")
AADD(opcexe,{|| realizacija_odjeljenja()})
AADD(opc,"3. radnici")
AADD(opcexe,{|| realizacija_radnik(.f.)})

#IFDEF DEPR
	AADD(opc,"4. dijelovi objekta ")
  	AADD(opcexe,{|| realizacija_dio_objekta()})
#ELSE
  	AADD(opc,"------ ")
  	AADD(opcexe,nil)
#ENDIF

AADD(opc,"5. realizacija po K1")
AADD(opcexe,{|| realizacija_kase(.f.,,,"2")})

Menu_SC("real")

return .f.

