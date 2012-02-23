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


function kalk_izvjestaji_magacina()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. kartica - magacin                        ")
AADD(_opcexe,{|| KarticaM()})
AADD(_Opc,"2. lager lista - magacin")
AADD(_opcexe,{|| LLM()})
AADD(_Opc,"3. lager lista - proizvoljni sort")
AADD(_opcexe,{|| KaLagM()})

AADD(_Opc,"4. finansijsko stanje magacina")
AADD(_opcexe, {|| FLLM()})
AADD(_Opc,"5. realizacija po partnerima")
AADD(_opcexe,{||  kalk_real_partnera()})
AADD(_Opc,"6. promet grupe partnera")
AADD(_opcexe,{|| PrometGP()})
AADD(_opc,"7. pregled robe za dobavljaca")
AADD(_opcexe, {|| ProbDob()})
AADD(_Opc,"8. TKV")
AADD(_opcexe, {|| kalk_tkv() })
AADD(_Opc,"9. kalkulacija cijena")
AADD(_opcexe, {|| kalkulacija_cijena_vp() })
AADD(_Opc,"----------------------------------")
AADD(_opcexe, nil)
AADD(_Opc,"P. porezi")
AADD(_opcexe,{|| MPoreziMag()})
AADD(_Opc,"----------------------------------")
AADD(_opcexe, nil)

if is_uobrada()
    AADD(_Opc,"R. unutrasnja obrada - pregled ulaza i izlaza")
    AADD(_opcexe, {|| r_uobrada() })
endif

AADD(_Opc,"K. kontrolni izvjestaji")
AADD(_opcexe, {|| m_ctrl_rpt() })
AADD(_Opc,"S. pregledi za vise objekata")
AADD(_opcexe, {|| MRekMag() })
AADD(_Opc,"T. lista trebovanja po sastavnicama")
AADD(_opcexe, {|| g_sast_list() })
AADD(_Opc,"U. specifikacija izlaza po sastavnicama")
AADD(_opcexe, {|| rpt_prspec() })

f18_menu( "imag", .f., _izbor, _opc, _opcexe )

close all
return


// ----------------------------------------------------
// kontrolni izvjestaji
// ----------------------------------------------------
function m_ctrl_rpt()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_Opc,"1. kontrola sastavnica               ")
AADD(_opcexe,{|| r_ct_sast()})

f18_menu( "ctrl", .f., _izbor, _opc, _opcexe )

return


function MPoreziMag()
local _opc := {}
local _opcexe:={}
local _izbor := 1

AADD(_Opc,"1. realizacija - veleprodaja po tarifama")
AADD(_opcexe,{|| RekPorMag()})
AADD(_Opc,"2. porez na promet ")
AADD(_opcexe,{|| RekPorNap()})
AADD(_Opc,"3. rekapitulacija po tarifama")
AADD(_opcexe,{|| RekmagTar()})

f18_menu( "porm", .f., _izbor, _opc, _opcexe )

close all
return


function MRekMag()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. rekapitulacija finansijskog stanja")
AADD(_opcexe, {|| RFLLM() } )

f18_menu( "rmag", .f., _izbor, _opc, _opcexe )
close all
return



