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


function O_TK_DB()
O_KASE
O_ODJ
O_DIO
O_SIFK
O_SIFV
O_POS_ROBA
O_SIROV
O_POS
return




function ZagFirma()
local cStr, nLines, cFajl, i, nOfset:=0

if (!EMPTY(gZagIz))
	cFajl:=PRIVPATH+AllTrim(gRnHeder)
	nLines:=BrLinFajla(cFajl)
	for i:=1 to nLines
		aPom:=SljedLin(cFajl,nOfset)
		cRed:=aPom[1]
		nOfset:=aPom[2]
		if (ALLTRIM(STR(i))$gZagIz)
			? cRed
		endif
	next
endif

return


