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
function IzvjP()
private Opc:={}
private opcexe:={}
AADD(Opc, "1. kartica - prodavnica                          ")
AADD(opcexe, {|| KarticaP()})
AADD(Opc, "2. lager lista - prodavnica")
AADD(opcexe, {|| LLP()})
AADD(Opc, "3. finansijsko stanje prodavnice")
AADD(opcexe, {|| FLLP()})
AADD(Opc,  "---------------------------------")
AADD(opcexe, NIL)
AADD(Opc,  "4. porezi")
AADD(opcexe, {|| PoreziProd()})
AADD(Opc,  "---------------------------------")
AADD(opcexe, NIL)
AADD(Opc,  "5. pregled za vise objekata")
AADD(opcexe, {|| RekProd()})
private Izbor:=1
Menu_SC("izp")
return nil

// porezi - prodavnica
function PoreziProd()
private Opc:={}
private opcexe:={}
AADD(Opc, "1. ukalkulisani porezi           ")
AADD(opcexe, {|| RekKPor()})
AADD(Opc, "2. realizovani porezi")
AADD(opcexe, {|| RekRPor()})
AADD(Opc, "3. popis 31.12.05 i obracun pdv")
AADD(opcexe, {|| rpt_uio()})

private Izbor:=1
Menu_SC("porp")
return nil

// pregledi za vise objekata
function RekProd()
private Izbor
private opc:={}
private opcexe:={}
AADD(opc, "1. sinteticka lager lista                  ")
AADD(opcexe, {|| LLPS()})
AADD(opc, "2. rekapitulacija fin stanja po objektima")
AADD(opcexe, {|| RFLLP()})
AADD(opc, "3. dnevni promet za sve objekte")
AADD(opcexe, {|| DnevProm()})
AADD(opc, "4. pregled prometa prodavnica za period")
AADD(opcexe, {|| PPProd()})
AADD(opc, "5. (vise)dnevni promet za sve objekte")
AADD(opcexe, {|| PromPeriod()})

Izbor:=1
Menu_SC("prsi")
return nil


