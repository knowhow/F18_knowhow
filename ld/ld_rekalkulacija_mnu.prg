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



function ld_rekalkulacija()
local _opc:={}
local _opcexe:={}
local _izbor:=1
local _priv := f18_privgranted( "ld_unos_podataka" )

if !_priv
    MsgBeep( F18_SECUR_WARRNING )
    return .t.
endif

if GetObrStatus(gRj,gGodina,gMjesec) $ "ZX"
    MsgBeep("Obracun zakljucen! Ne mozete vrsiti ispravku podataka!!!")
    return
elseif GetObrStatus(gRj,gGodina,gMjesec)=="N"
    MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(gMjesec))+"."+ALLTRIM(STR(gGodina)))
    return
endif

AADD( _opc, "1. rekalkulacija satnica i primanja               ")
AADD( _opcexe, {|| RekalkPrimanja()})
AADD( _opc, "2. ponovo izracunaj neto sati/neto iznos/odbici")
AADD( _opcexe, {|| RekalkSve()})
AADD( _opc, "3. rekalkulacija odredjenog primanja za procenat")
AADD( _opcexe, {|| RekalkProcenat()})
AADD( _opc, "4. rekalkulacija odredjenog primanja po formuli")
AADD( _opcexe, {|| RekalkFormula()})

f18_menu( "rklk", .f., _izbor, _opc, _opcexe )

return



