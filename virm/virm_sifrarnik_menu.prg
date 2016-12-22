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


#include "f18.ch"


function virm_sifarnici()
local _opc:={}
local _opcexe:={}
local _izbor:=1

OSifVirm()

AADD(_opc, "1. opci sifarnici          ")
AADD(_opcexe, {|| _sif_opc()})
AADD(_opc, "2. specificni sifarnici ")
AADD(_opcexe, {|| _sif_spec()})

f18_menu( "sif", .f. , _izbor, _opc, _opcexe )
return



static function _sif_opc()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc, "1. partneri                    ")
AADD(_opcexe, {|| p_partner()})
AADD(_opc, "2. valute")
AADD(_opcexe, {|| P_Valuta()})
AADD(_opc, "3. opcine")
AADD(_opcexe, {|| P_Ops()})
AADD(_opc, "4. banke")
AADD(_opcexe, {|| P_Banke()})
AADD(_opc, "5. sifk")
AADD(_opcexe, {|| P_SifK()})

f18_menu("sopc", .f., _izbor, _opc, _opcexe )
return



static function _sif_spec()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc, "1. vrste primalaca                          ")
AADD(_opcexe, {|| P_VrPrim()})
AADD(_opc, "2. javni prihodi")
AADD(_opcexe, {|| P_JPrih()})
AADD(_opc, "3. ld   -> virm")
AADD(_opcexe, {|| P_LdVirm()})
AADD(_opc, "4. kalk -> virm")
AADD(_opcexe, {|| P_KalVir()})

f18_menu("ssp", .f., _izbor, _opc, _opcexe )

return



function OSifVirm()
O_SIFK
O_SIFV
O_PARTN
O_VRPRIM
O_VRPRIM2
O_VALUTE
O_LDVIRM
O_KALVIR
O_JPRIH
O_BANKE
O_OPS
return



