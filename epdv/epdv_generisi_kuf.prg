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
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/

function gen_kuf()

local dDatOd
local dDatDo
local cSezona := SPACE(4)

dDatOd := DATE()
dDatDo := DATE()

Box(, 6, 40)
	@ m_x+1, m_y+2 SAY "Generacija KUF"
	
	@ m_x+3, m_y+2 SAY "Datum do " GET dDatOd 
	@ m_x+4, m_y+2 SAY "      do " GET dDatDo
	
	@ m_x+6, m_y+2 SAY "sezona" GET cSezona
	READ
BoxC()

if LASTKEY()==K_ESC
	return 
endif


// ima li nesto u kif pripremi ?
SELECT F_P_KUF
if !used()
	O_P_KUF
endif

if RECCOUNT2() <>0
	MsgBeep("KUF Priprema nije prazna !")
	if Pitanje(,"Isprazniti KUF pripremu ?", "N") == "D"
		SELECT p_kuf
		zap
	endif
endif


Box(,5, 60)
	
	kalk_kuf(dDatOd, dDatDo, cSezona)
	fin_kuf(dDatOd, dDatDo, cSezona)
	
	renm_rbr("P_KUF", .f.)
BoxC()

return

