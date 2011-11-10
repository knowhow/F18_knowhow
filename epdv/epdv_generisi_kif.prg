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


#include "epdv.ch"

/*
* ----------------------------------------------------------------
*                            Copyright Sigma-com software 2006 
* ----------------------------------------------------------------
*/

function gen_kif()

local dDatOd
local dDatDo
local cSezona

dDatOd := DATE()
dDatDo := DATE()
cSezona := SPACE(4)

Box(, 3, 40)
	@ m_x+1, m_y+2 SAY "Datum do " GET dDatOd 
	@ m_x+2, m_y+2 SAY "      do " GET dDatDo
	@ m_x+3, m_y+2 SAY "sezona" GET cSezona
	
	READ
BoxC()

if LASTKEY()==K_ESC
	return 
endif


// ima li nesto u kif pripremi ?
SELECT F_P_KIF
if !used()
	O_P_KIF
endif

if RECCOUNT2() <>0
	MsgBeep("KIF Priprema nije prazna !")
	if Pitanje(,"Isprazniti KIF pripremu ?", "N") == "D"
		SELECT p_kif
		zap
	endif
endif


Box(,5, 60)
	fakt_kif(dDatOd, dDatDo, cSezona)
	
	kalk_kif(dDatOd, dDatDo, cSezona)
	
	tops_kif(dDatOd, dDatDo, cSezona)
	
	fin_kif(dDatOd, dDatDo, cSezona)

	renm_rbr("P_KIF", .f.)
BoxC()

return

