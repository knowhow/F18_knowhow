/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

function MnuSifrarnik()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc, "1. opći šifarnici                  ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","OPCISIFOPEN"))
	AADD(_opcexe, {|| SifFmkSvi()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(_opc, "2. finansijsko poslovanje ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","FINPSIFOPEN"))
	AADD(_opcexe, {|| _menu_specif()})
else
	AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

if (gRj=="D" .or. gTroskovi=="D")
	AADD(_opc, "3. budžet")
	AADD(_opcexe, {|| _menu_budzet()})
endif

f18_menu("sif", .f., _izbor, _opc, _opcexe )

return


static function _menu_specif()
local _opc:={}
local _opcexe:={}
local _izbor:=1

O_KONTO
O_KS
O_TRFP2
O_TRFP3
O_PKONTO
O_ULIMIT

AADD(_opc, "1. kontni plan                          ")
AADD(_opcexe, {|| P_KontoFin()})
AADD(_opc, "2. sheme kontiranja                     ")
AADD(_opcexe, {|| P_Trfp2()})
AADD(_opc, "3. prenos konta u ng")
AADD(_opcexe, {|| P_PKonto()})
AADD(_opc, "4. limiti po ugovorima") 
AADD(_opcexe, {|| P_ULimit()})
AADD(_opc, "5. sheme kontiranja obracuna LD")
AADD(_opcexe, {|| P_TRFP3()})
AADD(_opc, "6. kamatne stope")
AADD(_opcexe, {|| P_KS()})

f18_menu("sopc", .f., _izbor, _opc, _opcexe )

return



static function _menu_budzet()
local _opc:={}
local _opcexe:={}
local _Izbor:=1

OSifBudzet()

AADD(_opc,"1. radne jedinice              ")
AADD(_opcexe, {|| P_Rj()})
AADD(_opc,"2. funkc.kval       ")
AADD(_opcexe, {|| P_FunK()})
AADD(_opc,"3. plan budzeta")
AADD(_opcexe, {|| P_Budzet()})
AADD(_opc,"4. partije->konta ")
AADD(_opcexe, {|| P_ParEK()})
AADD(_opc,"5. fond   ")
AADD(_opcexe, {|| P_Fond()})
AADD(_opc,"6. konta-izuzeci")
AADD(_opcexe, {|| P_BuIZ()})

f18_menu("sbdz", .f., _izbor, _opc, _opcexe )

return


function OSifBudzet()

O_RJ
O_FUNK
O_FOND
O_BUDZET
O_PAREK
O_BUIZ
O_KONTO
O_TRFP2

return




