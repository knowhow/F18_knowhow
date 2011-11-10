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




// Ako je dan < 10
//     return { 01.predhodni_mjesec , zadnji.predhodni_mjesec}
//     else
//     return { 01.tekuci_mjesec, danasnji dan }

function rpt_d_interval (dToday)
local nDay, nFDOm
local dDatOd, dDatDo
nDay:= DAY(dToday)
nFDOm := BOM(dToday)

if nDay < 10
	// prvi dan u tekucem mjesecu - 1
	dDatDo := nFDom - 1
	// prvi dan u proslom mjesecu
	dDatOd := BOM(dDatDo)
	
else
	dDatOd := nFDom
	dDatDo := dToday
endif


return { dDatOd, dDatDo }

