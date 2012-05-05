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


function ld_sifrarnici()
local _opc:={}
local _opcexe:={}
local _izbor:=1

o_ld_sif_tables()

AADD(_opc,"1. opci sifrarnici                     ")
AADD(_opcexe, {|| MnuOpSif()})
AADD(_opc,"2. specijalni sifrarnici")
AADD(_opcexe, {|| MnuSpSif()})

f18_menu("sif", .f., _izbor, _opc, _opcexe )

return



function MnuOpSif()
local _opc:={}
local _opcexe:={}
local _izbor:=1
local _priv := f18_privgranted( "ld_korekcija_sifrarnika" )

if !_priv
    MsgBeep( cZabrana )
    return .t.
endif

AADD(_opc, lokal("1. radnici                            "))
AADD(_opcexe, {|| P_Radn()})
AADD(_opc, lokal("5. radne jedinice"))
AADD(_opcexe, {|| P_LD_RJ()})
AADD(_opc, lokal("6. opstine"))
AADD(_opcexe, {|| P_Ops()})
AADD(_opc, lokal("9. vrste posla"))
AADD(_opcexe, {|| P_VPosla()})
AADD(_opc, lokal("B. strucne spreme"))
AADD(_opcexe, {|| P_StrSpr()})
AADD(_opc, lokal("C. kreditori"))
AADD(_opcexe, {|| P_Kred()})
AADD(_opc, lokal("F. banke"))
AADD(_opcexe, {|| P_Banke()})
AADD(_opc, lokal("G. sifk"))
AADD(_opcexe, {|| P_SifK()})

if (IsRamaGlas())
    AADD(_opc, lokal("H. radni nalozi") )
    AADD(_opcexe, {|| P_RNal()})
endif

gLokal := ALLTRIM( gLokal )

if gLokal <> "0"
    AADD(_opc, lokal("L. lokalizacija") )
    AADD(_opcexe, {|| P_Lokal()})
endif

f18_menu("op", .f., _izbor, _opc, _opcexe )

return



function MnuSpSif()
local _opc:={}
local _opcexe:={}
local _izbor := 1
local _priv := f18_privgranted( "ld_korekcija_sifrarnika" )

if !_priv
    MsgBeep( cZabrana )
    return .t.
endif

AADD(_opc,"1. parametri obracuna                  ")
AADD(_opcexe, {|| P_ParObr()})
AADD(_opc,"2. tipovi primanja")
AADD(_opcexe, {|| P_TipPr()})
AADD(_opc,"3. tipovi primanja / ostali obracuni")
AADD(_opcexe, {|| P_TipPr2()})
AADD(_opc,"4. porezne stope ")
AADD(_opcexe, {|| P_Por()})
AADD(_opc,"5. doprinosi ")
AADD(_opcexe, {|| P_Dopr()})
AADD(_opc,"6. koef.benef.rst")
AADD(_opcexe, {|| P_KBenef()})

if gSihtarica == "D"
    AADD(_opc,"7. tipovi primanja u sihtarici")
    AADD(_opcexe, {|| P_TprSiht()})
    AADD(_opc,"8. norme radova u sihtarici   ")
    AADD(_opcexe, {|| P_NorSiht()})
endif

if gSihtGroup == "D"
    AADD(_opc,"8. lista konta   ")
    AADD(_opcexe, {|| p_konto()})
endif

f18_menu("spc", .f., _izbor, _opc, _opcexe )

return



// otvaranje tabela sifrarnika 
static function o_ld_sif_tables()

O_SIFK
O_SIFV
O_BANKE
O_TPRSIHT
O_NORSIHT
O_RADN
O_PAROBR
O_TIPPR
O_LD_RJ
O_POR
O_DOPR
O_STRSPR
O_KBENEF
O_VPOSLA
O_OPS
O_KRED
O_TIPPR2

if (IsRamaGlas())
    O_RNAL
endif

return



