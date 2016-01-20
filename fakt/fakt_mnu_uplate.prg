/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

function mnu_fakt_uplate()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc,"1. evidentiranje uplata                   ")
AADD(_opcexe,{|| Uplate()})
AADD(_opc,"2. lista salda kupaca")
AADD(_opcexe,{|| SaldaKupaca()})
AADD(_opc,"3. pocetno stanje za evidenciju uplata")
AADD(_opcexe,{|| GPSUplata()})

f18_menu("upl", .f., _izbor, _opc, _opcexe)

CLOSERET
return .f.
