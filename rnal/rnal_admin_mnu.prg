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


#include "rnal.ch"


function rnal_mnu_admin()
local opc := {}
local opcexe := {}
local izbor := 1

AADD(opc, "1. administracija db-a            ")
AADD(opcexe, {|| m_adm() })
AADD(opc, "2. regeneracija naziva artikala   ")
AADD(opcexe, {|| _a_gen_art() })

f18_menu("administracija", .F., izbor, opc, opcexe )

return



function _a_gen_art()
local nCnt := 0

if !SigmaSif("ARTGEN")
	msgbeep("!!!!! opcija nedostupna !!!!!")
	return
endif

rnal_o_sif_tables()

nCnt := auto_gen_art()

MsgBeep("Obradjeno " + ALLTRIM(STR(nCnt)) + " stavki !")

return


