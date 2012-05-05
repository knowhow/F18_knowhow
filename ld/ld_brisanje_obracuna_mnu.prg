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


#include "ld.ch"

function ld_brisanje_obr()
local _priv := f18_privgranted( "ld_brisanje_podataka" )
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc, "1. brisanje obracuna za jednog radnika       ")
if _priv
    AADD(_opcexe, {|| BrisiRadnika() })
else
    AADD(_opcexe, {|| MsgBeep(cZabrana) })
endif

AADD(_opc, "2. brisanje obracuna za jedan mjesec   ")
if _priv
    AADD(_opcexe, {|| BrisiMjesec()})
else
    AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "3. brisanje nepotrebnih sezona         ")
if _priv
    AADD(_opcexe, {|| PrenosLD()})
else
    AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "4. totalno brisanje radnika iz evidencije")
if _priv
    AADD(_opcexe, {|| TotBrisRadn()})
else
    AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

f18_menu("bris", .f., _izbor, _opc, _opcexe )

return


