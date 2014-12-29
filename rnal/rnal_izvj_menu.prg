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
local _izbor:=1
local _opc:={}
local _opcexe:={}

AADD(_opc, "1. lista naloga otvorenih na tekuci dan          ")
AADD(_opcexe, {|| lst_tek_dan() })

AADD(_opc, "2. nalozi prispjeli za realizaciju ")
AADD(_opcexe, {|| lst_real_tek_dan() })

AADD(_opc, "3. nalozi van roka na tekuci dan ")
AADD(_opcexe, {|| lst_vrok_tek_dan() })

AADD(_opc, "4. lista naloga >= od proizvoljnog datuma ")
AADD(_opcexe, {|| lst_ch_date() })

AADD(_opc, "------------------------------------------- ")
AADD(_opcexe, {|| nil })


AADD(_opc, "S. specifikacija naloga za poslovodje  ")
AADD(_opcexe, {|| m_get_spec( 1 ) })

AADD(_opc, "R. pregled utroska RAL sirovina  ")
AADD(_opcexe, {|| rpt_ral_calc() })

AADD(_opc, "O. pregled ucinka operatera  ")
AADD(_opcexe, {|| r_op_docs() })

AADD(_opc, "P. pregled ucinka proizvodnje  ")
AADD(_opcexe, {|| m_get_rpro() })

AADD(_opc, "------------------------------------------- ")
AADD(_opcexe, {|| nil })

AADD(_opc, "K. kontrola prebacenih dokumenata  ")
AADD(_opcexe, {|| m_rpt_check() })
AADD(_opc, "Kp. popuni veze RNAL <> FAKT (dok.11) ")
AADD(_opcexe, {|| chk_dok_11() })


AADD(_opc, "------------------------------------------- ")
AADD(_opcexe, {|| nil })

AADD(_opc, "Y. send email ")
AADD(_opcexe, {|| f18_email_test() })

f18_menu("rpt_rnal", .f., _izbor, _opc, _opcexe )

return
