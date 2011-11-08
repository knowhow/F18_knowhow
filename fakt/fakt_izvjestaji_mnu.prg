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
function Izvj()
private opc:={}
private opcexe:={}
private Izbor:=1

// PTXT compatibility  sa ver < 1.52
gPtxtC50 := .t.

AADD(opc,"1. stanje robe                               ")
AADD(opcexe,{|| StanjeRobe()})
AADD(opc,"2. lager lista - specifikacija   ")
AADD(opcexe,{|| Lager()})
AADD(opc,"3. kartica")
AADD(opcexe,{|| fakt_kartica()})
AADD(opc,"4. uporedna lager lista fakt1 <-> fakt2")
AADD(opcexe,{|| Fakt_Kalk(.t.)})
AADD(opc,"5. uporedna lager lista fakt <-> kalk")
AADD(opcexe,{|| Fakt_Kalk(.f.)})
AADD(opc,"6. realizacija kumulativno po partnerima")
AADD(opcexe,{|| fakt_real_partnera()})
AADD(opc,"7. specifikacija prodaje")
AADD(opcexe,{|| RealKol()})
AADD(opc,"8. specifikacija prodaje po parternima ")
AADD(opcexe,{|| spec_kol_partn()})
AADD(opc,"9. realizacija maloprodaje ")
AADD(opcexe,{|| real_mp()})
AADD(opc,"10. fiskalni izvjestaji i komande ")
AADD(opcexe,{|| fisc_rpt()})

if IsRudnik() 
	AADD(opc,"R. rudnik")
	AADD(opcexe,{|| MnuRudnik()})
endif
	
if IsStampa()
	AADD(opc,"S. stampa")
	AADD(opcexe,{|| MnuStampa()})
endif

if IsKonsig()
	AADD(opc,"K. konsignacija")
	AADD(opcexe,{|| KarticaKons()})
endif    	


private fID_J:=.f.
if IzFmkIni('SifRoba','ID_J','N')=="D"
	private fId_J:=.t.
  	AADD(opc,"C. osvjezi promjene sifarskog sistema u prometu")
	AADD(opcexe,{|| OsvjeziIdJ()})
endif

Menu_SC("izvj")

return
*}

