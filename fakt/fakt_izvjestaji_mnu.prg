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


#include "fakt.ch"

// ------------------------------------------------------------
// glavni menij izvjestaja
// ------------------------------------------------------------
function fakt_izvjestaji()
local _opc:={}
local _opcexe:={}
local _izbor:=1

// PTXT compatibility  sa ver < 1.52
gPtxtC50 := .t.

AADD(_opc,"1. stanje robe                                          ") 
AADD(_opcexe,{|| fakt_stanje_robe()})
AADD(_opc,"2. lager lista - specifikacija   ")
AADD(_opcexe,{|| fakt_lager_lista()})
AADD(_opc,"3. kartica")
AADD(_opcexe,{|| fakt_kartica()})
AADD(_opc,"4. uporedna lager lista fakt1 <-> fakt2")
AADD(_opcexe,{|| uporedna_lista_fakt_kalk(.t.)})
AADD(_opc,"5. uporedna lager lista fakt <-> kalk")
AADD(_opcexe,{|| uporedna_lista_fakt_kalk(.f.)})
AADD(_opc,"6. realizacija kumulativno po partnerima")
AADD(_opcexe,{|| fakt_real_partnera()})
AADD(_opc,"7. specifikacija prodaje")
AADD(_opcexe,{|| fakt_real_kolicina()})
AADD(_opc,"8. kolicinski pregled isporuke robe po partnerima ")
AADD(_opcexe,{|| spec_kol_partn()})
AADD(_opc,"9. realizacija maloprodaje ")
AADD(_opcexe,{|| fakt_real_maloprodaje()})

if gFc_use == "D"
    AADD(_opc,"10. fiskalni izvjestaji i komande ")
    AADD(_opcexe,{|| fisc_rpt()})
endif

//if IsRudnik() 
	AADD(_opc,"R. specificni izvjestaji (rmu)")
	AADD(_opcexe, {|| mnu_sp_rudnik() })
//endif
	
if IsStampa()
	AADD(_opc,"S. stampa")
	AADD(_opcexe,{|| MnuStampa()})
endif

if IsKonsig()
	AADD(_opc,"K. konsignacija")
	AADD(_opcexe,{|| KarticaKons()})
endif    	


private fID_J:=.f.
if IzFmkIni('SifRoba','ID_J','N')=="D"
	private fId_J:=.t.
  	AADD(_opc,"C. osvjezi promjene sifarskog sistema u prometu")
	AADD(_opcexe,{|| OsvjeziIdJ()})
endif

f18_menu( "izvj", .f., _izbor, _opc, _opcexe )

return


