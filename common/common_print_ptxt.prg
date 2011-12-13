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

function PtxtSekvence()

public gpIni:=  "#%INI__#"
public gpCOND:= "#%KON17#"
public gpCOND2:="#%KON20#"
public gp10CPI:="#%10CPI#"
public gP12CPI:="#%12CPI#"
public gPB_ON :="#%BON__#"
public gPB_OFF:="#%BOFF_#"
public gPU_ON:="#%UON__#"
public gPU_OFF:="#%UOFF_#"
public gPI_ON:="#%ION__#"
public gPI_OFF:="#%IOFF_#"
public gPFF   :="#%NSTR_#"
public gPO_Port:="#%PORTR#"
public gPO_Land:="#%LANDS#"

public gRPL_Normal:=""
public gRPL_Gusto:=""

return


/* --------------------- */
function Ptxt(cImeF)

local cPtxtSw:=""
local nFH

local cKom

if gPtxtSw <> nil
	cPtxtSw := gPtxtSw
else
	cPTXTSw := R_IniRead ( 'DOS','PTXTSW',  "/P", EXEPATH+'FMK.INI' )
endif

#ifdef __PLATFORM__WINDOWS
	cImeF := '"' + cImeF + '"'
#endif

cKom := "PTXT " + cImeF + " "

cKom += " "+ cPtxtSw

if compat50()
	// postavi compatibility
	cKom += " /c50"
endif

Run(cKom)

return


// -----------------------------------------------
// ako gPTxtC50 varijabla nije definisana
// onda se mora ici ka PTXT kompatibilnost
// ako postoji varijabla onda je ona  logicka
// i vraca se postavka PTXT-a
// -----------------------------------------------
static function compat50()
local cType

cType:=TYPE("gPtxtC50")
do case
	case cType == "L"
		return gPtxtC50
	otherwise
		return .t.
endcase

