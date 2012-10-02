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


#include "kalk.ch"

// menij izvjestaji prodavnica
function kalk_izvjestaji_prodavnice()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_Opc, "1. kartica - prodavnica                          ")
AADD(_opcexe, {|| KarticaP()})
AADD(_Opc, "2. lager lista - prodavnica")
AADD(_opcexe, {|| LLP()})
AADD(_Opc, "3. finansijsko stanje prodavnice")
AADD(_opcexe, {|| FLLP()})
AADD(_Opc, "4. TKM")
AADD(_opcexe, {|| kalk_tkm() })
AADD(_Opc, "5. specifikacija asortimana po dobavljacu")
AADD(_opcexe, {|| kalk_spec_mp_po_dob() })
AADD(_Opc,  "---------------------------------")
AADD(_opcexe, NIL)
AADD(_Opc,  "P. porezi")
AADD(_opcexe, {|| PoreziProd()})
AADD(_Opc,  "---------------------------------")
AADD(_opcexe, NIL)
AADD(_Opc,  "V. pregled za vise objekata")
AADD(_opcexe, {|| RekProd()})

f18_menu( "izp", .f., _izbor, _opc, _opcexe )

return nil


// porezi - prodavnica
function PoreziProd()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_Opc, "1. ukalkulisani porezi           ")
AADD(_opcexe, {|| RekKPor()})
AADD(_Opc, "2. realizovani porezi")
AADD(_opcexe, {|| RekRPor()})
AADD(_Opc, "3. popis 31.12.05 i obracun pdv")
AADD(_opcexe, {|| rpt_uio()})

f18_menu( "porp", .f., _izbor, _opc, _opcexe )

return nil


// pregledi za vise objekata
function RekProd()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD(_opc, "1. sinteticka lager lista                  ")
AADD(_opcexe, {|| LLPS()})
AADD(_opc, "2. rekapitulacija fin stanja po objektima")
AADD(_opcexe, {|| RFLLP()})
AADD(_opc, "3. dnevni promet za sve objekte")
AADD(_opcexe, {|| DnevProm()})
AADD(_opc, "4. pregled prometa prodavnica za period")
AADD(_opcexe, {|| PPProd()})
AADD(_opc, "5. (vise)dnevni promet za sve objekte")
AADD(_opcexe, {|| PromPeriod()})

f18_menu( "prsi", .f., _izbor, _opc, _opcexe )

return nil


