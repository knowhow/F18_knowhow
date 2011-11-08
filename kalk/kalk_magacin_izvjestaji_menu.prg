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


function IzvjM()
private Opc:={}
private opcexe:={}
AADD(Opc,"1. kartica - magacin                        ")
AADD(opcexe,{|| KarticaM()})
AADD(Opc,"2. lager lista - magacin")
AADD(opcexe,{|| LLM()})
AADD(Opc,"3. lager lista - proizvoljni sort")
AADD(opcexe,{|| KaLagM()})

AADD(Opc,"4. finansijsko stanje magacina")
AADD(opcexe, {|| FLLM()})
AADD(Opc,"5. realizacija po partnerima")
AADD(opcexe,{||  RealPartn()})
AADD(Opc,"6. promet grupe partnera")
AADD(opcexe,{|| PrometGP()})
AADD(opc,"7. pregled robe za dobavljaca")
AADD(opcexe, {|| ProbDob()})

AADD(Opc,"----------------------------------")
AADD(opcexe, nil)
AADD(Opc,"8. porezi")
AADD(opcexe,{|| MPoreziMag()})
AADD(Opc,"----------------------------------")
AADD(opcexe, nil)
if is_uobrada()
	AADD(Opc,"R. unutrasnja obrada - pregled ulaza i izlaza")
	AADD(opcexe, {|| r_uobrada() })
endif

AADD(Opc,"K. kontrolni izvjestaji")
AADD(opcexe, {|| m_ctrl_rpt() })


AADD(Opc,"S. pregledi za vise objekata")
AADD(opcexe, {|| MRekMag() })
AADD(Opc,"T. lista trebovanja po sastavnicama")
AADD(opcexe, {|| g_sast_list() })
AADD(Opc,"U. specifikacija izlaza po sastavnicama")
AADD(opcexe, {|| rpt_prspec() })


private Izbor:=1
Menu_SC("imag")
CLOSERET
return


// ----------------------------------------------------
// kontrolni izvjestaji
// ----------------------------------------------------
function m_ctrl_rpt()
private Opc:={}
private opcexe:={}

AADD(Opc,"1. kontrola sastavnica               ")
AADD(opcexe,{|| r_ct_sast()})

private Izbor:=1
Menu_SC("ctrl")

return





/*! \fn MPoreziMag()
 *  \brief Meni izvjestaja o porezima
 */

function MPoreziMag()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. realizacija - veleprodaja po tarifama")
AADD(opcexe,{|| RekPorMag()})
AADD(Opc,"2. porez na promet ")
AADD(opcexe,{|| RekPorNap()})
AADD(Opc,"3. rekapitulacija po tarifama")
AADD(opcexe,{|| RekmagTar()})
private Izbor:=1
Menu_SC("porm")
CLOSERET
return
*}




/*! \fn MRekMag()
 *  \brief Meni izvjestaja za vise objekata(konta)
 */
 
function MRekMag()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. rekapitulacija finansijskog stanja")
AADD(opcexe, {|| RFLLM() } )
private Izbor:=1
Menu_SC("rmag")
CLOSERET
return
*}




