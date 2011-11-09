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


// -------------------------------
// menij izvjestaji
// -------------------------------

function m_rpt()
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. lista naloga otvorenih na tekuci dan          ")
AADD(opcexe, {|| lst_tek_dan() })

AADD(opc, "2. nalozi prispjeli za realizaciju ")
AADD(opcexe, {|| lst_real_tek_dan() })

AADD(opc, "3. nalozi van roka na tekuci dan ")
AADD(opcexe, {|| lst_vrok_tek_dan() })

AADD(opc, "4. lista naloga >= od proizvoljnog datuma ")
AADD(opcexe, {|| lst_ch_date() })

AADD(opc, "------------------------------------------- ")
AADD(opcexe, {|| nil })

AADD(opc, "S. specifikacija naloga za poslovodje  ")
AADD(opcexe, {|| m_get_spec( 1 ) })

AADD(opc, "R. pregled utroska RAL sirovina  ")
AADD(opcexe, {|| rpt_ral_calc() })

AADD(opc, "O. pregled ucinka operatera  ")
AADD(opcexe, {|| r_op_docs() })

AADD(opc, "P. pregled ucinka proizvodnje  ")
AADD(opcexe, {|| m_get_rpro() })

AADD(opc, "------------------------------------------- ")
AADD(opcexe, {|| nil })

AADD(opc, "K. kontrola prebacenih dokumenata  ")
AADD(opcexe, {|| m_rpt_check() })
AADD(opc, "Kp. popuni veze RNAL <> FAKT (dok.11) ")
AADD(opcexe, {|| chk_dok_11() })

Menu_SC("rpt_rnal")

return







