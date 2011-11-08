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


#include "kalk.ch"



function SumirajKolicinu(nUlaz, nIzlaz, nTotalUlaz, nTotalIzlaz, fPocStanje, lPrikazK2)

if fPocStanje==nil
	fPocStanje:=.f.
endif

if lPrikazK2 == nil
	lPrikazK2 := .f.
endif

if (IsPlanika() .and. !fPocStanje)
	if lPrikazK2
		nTotalUlaz+=nUlaz
		nTotalIzlaz+=nIzlaz
	else
		if roba->k2<>PADR("X",4)
			nTotalUlaz+=nUlaz
			nTotalIzlaz+=nIzlaz
		endif
	endif
else
	nTotalUlaz+=nUlaz
	nTotalIzlaz+=nIzlaz
endif

return




function FillPObjekti()

SELECT pobjekti    
GO TOP
do while !eof()
	// prodaja tarifa ukupno
	REPLACE prodtu with 0
	// prodaja ukupno
	REPLACE produ  with 0
	REPLACE zaltu  with 0
	REPLACE zalu   with 0
	skip
enddo

return


function KesirajKalks(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)
local cPom
// ugasena funkcija !!
return 0

